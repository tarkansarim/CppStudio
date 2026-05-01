#include "{{PROJECT_NAME}}/vulkan_probe.hpp"

#include <vulkan/vulkan_raii.hpp>

#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <limits>
#include <optional>
#include <stdexcept>
#include <string>
#include <string_view>
#include <vector>

namespace {{CPP_NAMESPACE}} {
namespace {

constexpr std::uint32_t kComputeExpectedValue = 0xdecafbadU;
constexpr vk::Format kRenderFormat = vk::Format::eR8G8B8A8Unorm;
constexpr std::uint32_t kRenderWidth = 4;
constexpr std::uint32_t kRenderHeight = 4;
constexpr std::uint64_t kFenceTimeoutNs = 5'000'000'000ULL;

struct ValidationState {
    bool error_seen = false;
};

bool string_equals(const char* left, std::string_view right) {
    return std::strncmp(left, right.data(), right.size()) == 0 && left[right.size()] == '\0';
}

bool has_extension(const std::vector<vk::ExtensionProperties>& properties, std::string_view name) {
    return std::any_of(properties.begin(), properties.end(), [name](const auto& property) {
        return string_equals(property.extensionName, name);
    });
}

bool has_layer(const std::vector<vk::LayerProperties>& properties, std::string_view name) {
    return std::any_of(properties.begin(), properties.end(), [name](const auto& property) {
        return string_equals(property.layerName, name);
    });
}

std::vector<std::uint32_t> read_spirv(const std::filesystem::path& path) {
    std::ifstream file(path, std::ios::binary | std::ios::ate);
    if (!file) {
        throw std::runtime_error("failed to open SPIR-V file: " + path.string());
    }

    const auto size = file.tellg();
    if (size <= 0 || size % static_cast<std::streamoff>(sizeof(std::uint32_t)) != 0) {
        throw std::runtime_error("SPIR-V file has invalid size: " + path.string());
    }

    std::vector<std::uint32_t> words(static_cast<std::size_t>(size) / sizeof(std::uint32_t));
    file.seekg(0);
    file.read(reinterpret_cast<char*>(words.data()), size);
    if (!file) {
        throw std::runtime_error("failed to read SPIR-V file: " + path.string());
    }
    return words;
}

VKAPI_ATTR vk::Bool32 VKAPI_CALL
debug_callback(vk::DebugUtilsMessageSeverityFlagBitsEXT severity, vk::DebugUtilsMessageTypeFlagsEXT,
               const vk::DebugUtilsMessengerCallbackDataEXT* callback_data, void* user_data) {
    const bool is_error = (severity & vk::DebugUtilsMessageSeverityFlagBitsEXT::eError) ==
                          vk::DebugUtilsMessageSeverityFlagBitsEXT::eError;
    if (is_error && user_data) {
        static_cast<ValidationState*>(user_data)->error_seen = true;
    }
    if (callback_data && callback_data->pMessage) {
        std::fprintf(stderr, "Vulkan validation %s: %s\n", is_error ? "error" : "warning",
                     callback_data->pMessage);
    }
    return VK_FALSE;
}

vk::raii::Instance create_instance(vk::raii::Context& context, bool& debug_utils_enabled) {
    const auto instance_extensions = context.enumerateInstanceExtensionProperties();
    const auto instance_layers = context.enumerateInstanceLayerProperties();

    std::vector<const char*> enabled_extensions;
    debug_utils_enabled = PROJECT_VULKAN_ENABLE_DEBUG_UTILS &&
                          has_extension(instance_extensions, VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    if (debug_utils_enabled) {
        enabled_extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    }
#if PROJECT_VULKAN_ENABLE_PORTABILITY
    bool portability_enumeration_enabled = false;
    if (has_extension(instance_extensions, VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)) {
        enabled_extensions.push_back(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME);
        portability_enumeration_enabled = true;
    }
#endif

    std::vector<const char*> enabled_layers;
    if (PROJECT_VULKAN_ENABLE_VALIDATION) {
        if (!has_layer(instance_layers, "VK_LAYER_KHRONOS_validation")) {
            throw std::runtime_error("PROJECT_ENABLE_VULKAN_VALIDATION is ON but "
                                     "VK_LAYER_KHRONOS_validation is unavailable");
        }
        enabled_layers.push_back("VK_LAYER_KHRONOS_validation");
    }

    const vk::ApplicationInfo application_info("{{PROJECT_NAME}} Vulkan smoke", 1, "{{PROJECT_NAME}}",
                                               1, PROJECT_VULKAN_TARGET_API_VERSION);

    vk::InstanceCreateInfo create_info;
    create_info.setPApplicationInfo(&application_info)
        .setPEnabledLayerNames(enabled_layers)
        .setPEnabledExtensionNames(enabled_extensions);
#if PROJECT_VULKAN_ENABLE_PORTABILITY
    if (portability_enumeration_enabled) {
        create_info.setFlags(vk::InstanceCreateFlagBits::eEnumeratePortabilityKHR);
    }
#endif

    return vk::raii::Instance(context, create_info);
}

std::optional<vk::raii::DebugUtilsMessengerEXT>
create_debug_messenger(const vk::raii::Instance& instance, bool debug_utils_enabled,
                       ValidationState& validation_state) {
    if (!debug_utils_enabled) {
        return std::nullopt;
    }

    vk::DebugUtilsMessengerCreateInfoEXT create_info;
    create_info
        .setMessageSeverity(vk::DebugUtilsMessageSeverityFlagBitsEXT::eWarning |
                            vk::DebugUtilsMessageSeverityFlagBitsEXT::eError)
        .setMessageType(vk::DebugUtilsMessageTypeFlagBitsEXT::eGeneral |
                        vk::DebugUtilsMessageTypeFlagBitsEXT::eValidation |
                        vk::DebugUtilsMessageTypeFlagBitsEXT::ePerformance)
        .setPfnUserCallback(debug_callback)
        .setPUserData(&validation_state);

    return vk::raii::DebugUtilsMessengerEXT(instance, create_info);
}

struct DeviceSelection {
    vk::raii::PhysicalDevice physical_device;
    std::uint32_t queue_family_index = 0;
};

std::optional<DeviceSelection> select_device(const vk::raii::Instance& instance) {
    auto physical_devices = instance.enumeratePhysicalDevices();
    for (const auto& candidate : physical_devices) {
        const auto properties = candidate.getProperties();
        if (properties.apiVersion < PROJECT_VULKAN_TARGET_API_VERSION) {
            continue;
        }

        const auto feature_chain =
            candidate
                .getFeatures2<vk::PhysicalDeviceFeatures2, vk::PhysicalDeviceVulkan13Features>();
        const auto& vulkan13_features = feature_chain.get<vk::PhysicalDeviceVulkan13Features>();
        if (!vulkan13_features.dynamicRendering || !vulkan13_features.synchronization2) {
            continue;
        }

        const auto format_properties = candidate.getFormatProperties(kRenderFormat);
        const auto required_format_features =
            vk::FormatFeatureFlagBits::eColorAttachment | vk::FormatFeatureFlagBits::eTransferSrc;
        if ((format_properties.optimalTilingFeatures & required_format_features) !=
            required_format_features) {
            continue;
        }

        const auto queue_families = candidate.getQueueFamilyProperties();
        for (std::uint32_t index = 0; index < queue_families.size(); ++index) {
            const auto flags = queue_families[index].queueFlags;
            if ((flags & vk::QueueFlagBits::eGraphics) && (flags & vk::QueueFlagBits::eCompute)) {
                return DeviceSelection{candidate, index};
            }
        }
    }

    return std::nullopt;
}

struct VulkanSmokeContext {
    vk::raii::Context context;
    ValidationState validation_state;
    bool debug_utils_enabled = false;
    vk::raii::Instance instance;
    std::optional<vk::raii::DebugUtilsMessengerEXT> debug_messenger;
    vk::raii::PhysicalDevice physical_device{nullptr};
    vk::PhysicalDeviceMemoryProperties memory_properties{};
    std::uint32_t queue_family_index = 0;
    vk::raii::Device device{nullptr};
    vk::raii::Queue queue{nullptr};

    VulkanSmokeContext()
        : context(), instance(create_instance(context, debug_utils_enabled)),
          debug_messenger(create_debug_messenger(instance, debug_utils_enabled, validation_state)) {
        auto selection = select_device(instance);
        if (!selection) {
            throw std::runtime_error("no Vulkan 1.3 physical device with graphics+compute queue, "
                                     "synchronization2, and dynamic rendering");
        }

        physical_device = selection->physical_device;
        queue_family_index = selection->queue_family_index;
        memory_properties = physical_device.getMemoryProperties();

        const float queue_priority = 1.0F;
        vk::DeviceQueueCreateInfo queue_info;
        queue_info.setQueueFamilyIndex(queue_family_index).setQueuePriorities(queue_priority);

        vk::PhysicalDeviceVulkan13Features enabled_vulkan13_features;
        enabled_vulkan13_features.setSynchronization2(VK_TRUE).setDynamicRendering(VK_TRUE);

        std::vector<const char*> enabled_device_extensions;
#if PROJECT_VULKAN_ENABLE_PORTABILITY
        const auto device_extensions = physical_device.enumerateDeviceExtensionProperties();
#ifdef VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME
        if (has_extension(device_extensions, VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME)) {
            enabled_device_extensions.push_back(VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME);
        }
#else
        (void)device_extensions;
#endif
#endif

        vk::DeviceCreateInfo device_info;
        device_info.setQueueCreateInfos(queue_info)
            .setPNext(&enabled_vulkan13_features)
            .setPEnabledExtensionNames(enabled_device_extensions);

        device = vk::raii::Device(physical_device, device_info);
        queue = vk::raii::Queue(device, queue_family_index, 0);
    }

    std::uint32_t find_memory_type(std::uint32_t type_bits,
                                   vk::MemoryPropertyFlags required) const {
        for (std::uint32_t index = 0; index < memory_properties.memoryTypeCount; ++index) {
            const bool type_is_allowed = (type_bits & (1U << index)) != 0;
            const auto flags = memory_properties.memoryTypes[index].propertyFlags;
            if (type_is_allowed && (flags & required) == required) {
                return index;
            }
        }
        throw std::runtime_error("no compatible Vulkan memory type found");
    }

    void name_object(const vk::Buffer& buffer, const std::string& name) const {
        if (debug_utils_enabled) {
            device.setDebugUtilsObjectNameEXT(buffer, name);
        }
    }

    void name_object(const vk::Image& image, const std::string& name) const {
        if (debug_utils_enabled) {
            device.setDebugUtilsObjectNameEXT(image, name);
        }
    }

    void name_object(const vk::Pipeline& pipeline, const std::string& name) const {
        if (debug_utils_enabled) {
            device.setDebugUtilsObjectNameEXT(pipeline, name);
        }
    }

    void throw_if_validation_failed() const {
        if (validation_state.error_seen) {
            throw std::runtime_error("Vulkan validation error reported");
        }
    }
};

struct BufferResource {
    vk::raii::DeviceMemory memory{nullptr};
    vk::raii::Buffer buffer{nullptr};
    vk::DeviceSize size = 0;
};

struct ImageResource {
    vk::raii::DeviceMemory memory{nullptr};
    vk::raii::Image image{nullptr};
    vk::raii::ImageView view{nullptr};
};

BufferResource create_buffer(const VulkanSmokeContext& context, vk::DeviceSize size,
                             vk::BufferUsageFlags usage, vk::MemoryPropertyFlags memory_flags,
                             std::string_view debug_name) {
    BufferResource resource;
    resource.size = size;

    vk::BufferCreateInfo buffer_info;
    buffer_info.setSize(size).setUsage(usage).setSharingMode(vk::SharingMode::eExclusive);
    resource.buffer = vk::raii::Buffer(context.device, buffer_info);

    const auto requirements = resource.buffer.getMemoryRequirements();
    vk::MemoryAllocateInfo allocate_info;
    allocate_info.setAllocationSize(requirements.size)
        .setMemoryTypeIndex(context.find_memory_type(requirements.memoryTypeBits, memory_flags));
    resource.memory = vk::raii::DeviceMemory(context.device, allocate_info);
    resource.buffer.bindMemory(*resource.memory, 0);
    context.name_object(*resource.buffer, std::string(debug_name));

    return resource;
}

ImageResource create_render_image(const VulkanSmokeContext& context) {
    ImageResource resource;

    vk::ImageCreateInfo image_info;
    image_info.setImageType(vk::ImageType::e2D)
        .setFormat(kRenderFormat)
        .setExtent(vk::Extent3D{kRenderWidth, kRenderHeight, 1})
        .setMipLevels(1)
        .setArrayLayers(1)
        .setSamples(vk::SampleCountFlagBits::e1)
        .setTiling(vk::ImageTiling::eOptimal)
        .setUsage(vk::ImageUsageFlagBits::eColorAttachment | vk::ImageUsageFlagBits::eTransferSrc)
        .setSharingMode(vk::SharingMode::eExclusive)
        .setInitialLayout(vk::ImageLayout::eUndefined);
    resource.image = vk::raii::Image(context.device, image_info);

    const auto requirements = resource.image.getMemoryRequirements();
    vk::MemoryAllocateInfo allocate_info;
    allocate_info.setAllocationSize(requirements.size)
        .setMemoryTypeIndex(context.find_memory_type(requirements.memoryTypeBits,
                                                     vk::MemoryPropertyFlagBits::eDeviceLocal));
    resource.memory = vk::raii::DeviceMemory(context.device, allocate_info);
    resource.image.bindMemory(*resource.memory, 0);
    context.name_object(*resource.image, "offscreen smoke color image");

    vk::ImageViewCreateInfo view_info;
    view_info.setImage(*resource.image)
        .setViewType(vk::ImageViewType::e2D)
        .setFormat(kRenderFormat)
        .setSubresourceRange(
            vk::ImageSubresourceRange{vk::ImageAspectFlagBits::eColor, 0, 1, 0, 1});
    resource.view = vk::raii::ImageView(context.device, view_info);

    return resource;
}

vk::raii::ShaderModule create_shader_module(const VulkanSmokeContext& context,
                                            const std::filesystem::path& path) {
    const auto words = read_spirv(path);
    vk::ShaderModuleCreateInfo create_info;
    create_info.setCode(words);
    return vk::raii::ShaderModule(context.device, create_info);
}

template <typename Recorder>
void submit_immediate(const VulkanSmokeContext& context, Recorder&& recorder) {
    vk::CommandPoolCreateInfo pool_info;
    pool_info.setFlags(vk::CommandPoolCreateFlagBits::eTransient)
        .setQueueFamilyIndex(context.queue_family_index);
    vk::raii::CommandPool command_pool(context.device, pool_info);

    vk::CommandBufferAllocateInfo allocate_info;
    allocate_info.setCommandPool(*command_pool)
        .setLevel(vk::CommandBufferLevel::ePrimary)
        .setCommandBufferCount(1);
    vk::raii::CommandBuffers command_buffers(context.device, allocate_info);
    const auto& command_buffer = command_buffers.front();

    command_buffer.begin(
        vk::CommandBufferBeginInfo{vk::CommandBufferUsageFlagBits::eOneTimeSubmit});
    recorder(command_buffer);
    command_buffer.end();

    vk::CommandBufferSubmitInfo command_buffer_info;
    command_buffer_info.setCommandBuffer(*command_buffer);
    vk::SubmitInfo2 submit_info;
    submit_info.setCommandBufferInfos(command_buffer_info);

    vk::raii::Fence fence(context.device, vk::FenceCreateInfo{});
    context.queue.submit2(submit_info, *fence);
    if (context.device.waitForFences(*fence, VK_TRUE, kFenceTimeoutNs) != vk::Result::eSuccess) {
        throw std::runtime_error("timed out waiting for Vulkan smoke command buffer");
    }
}

vk::PipelineShaderStageCreateInfo shader_stage(vk::ShaderStageFlagBits stage,
                                               const vk::raii::ShaderModule& shader_module) {
    vk::PipelineShaderStageCreateInfo stage_info;
    stage_info.setStage(stage).setModule(*shader_module).setPName("main");
    return stage_info;
}

void run_compute_smoke() {
    VulkanSmokeContext context;

    auto storage_buffer = create_buffer(
        context, sizeof(std::uint32_t), vk::BufferUsageFlagBits::eStorageBuffer,
        vk::MemoryPropertyFlagBits::eHostVisible | vk::MemoryPropertyFlagBits::eHostCoherent,
        "compute smoke storage buffer");

    {
        void* mapped = storage_buffer.memory.mapMemory(0, storage_buffer.size);
        const std::uint32_t zero = 0;
        std::memcpy(mapped, &zero, sizeof(zero));
        storage_buffer.memory.unmapMemory();
    }

    vk::DescriptorSetLayoutBinding storage_binding;
    storage_binding.setBinding(0)
        .setDescriptorType(vk::DescriptorType::eStorageBuffer)
        .setDescriptorCount(1)
        .setStageFlags(vk::ShaderStageFlagBits::eCompute);
    vk::raii::DescriptorSetLayout descriptor_set_layout(
        context.device, vk::DescriptorSetLayoutCreateInfo{}.setBindings(storage_binding));

    vk::DescriptorPoolSize pool_size;
    pool_size.setType(vk::DescriptorType::eStorageBuffer).setDescriptorCount(1);
    vk::DescriptorPoolCreateInfo descriptor_pool_info;
    descriptor_pool_info.setMaxSets(1).setPoolSizes(pool_size);
    vk::raii::DescriptorPool descriptor_pool(context.device, descriptor_pool_info);

    vk::DescriptorSetAllocateInfo descriptor_set_info;
    descriptor_set_info.setDescriptorPool(*descriptor_pool).setSetLayouts(*descriptor_set_layout);
    vk::raii::DescriptorSets descriptor_sets(context.device, descriptor_set_info);
    const auto& descriptor_set = descriptor_sets.front();

    vk::DescriptorBufferInfo buffer_info;
    buffer_info.setBuffer(*storage_buffer.buffer).setOffset(0).setRange(storage_buffer.size);
    vk::WriteDescriptorSet descriptor_write;
    descriptor_write.setDstSet(*descriptor_set)
        .setDstBinding(0)
        .setDescriptorType(vk::DescriptorType::eStorageBuffer)
        .setBufferInfo(buffer_info);
    context.device.updateDescriptorSets(descriptor_write, {});

    vk::raii::PipelineLayout pipeline_layout(
        context.device, vk::PipelineLayoutCreateInfo{}.setSetLayouts(*descriptor_set_layout));
    const auto shader_path = std::filesystem::path(PROJECT_VULKAN_SHADER_DIR) / "compute.comp.spv";
    auto shader_module = create_shader_module(context, shader_path);

    vk::ComputePipelineCreateInfo pipeline_info;
    pipeline_info.setStage(shader_stage(vk::ShaderStageFlagBits::eCompute, shader_module))
        .setLayout(*pipeline_layout);
    auto pipeline = context.device.createComputePipeline(nullptr, pipeline_info);
    context.name_object(*pipeline, "compute smoke pipeline");

    submit_immediate(context, [&](const vk::raii::CommandBuffer& command_buffer) {
        if (context.debug_utils_enabled) {
            command_buffer.beginDebugUtilsLabelEXT(
                vk::DebugUtilsLabelEXT{}.setPLabelName("compute smoke dispatch"));
        }
        command_buffer.bindPipeline(vk::PipelineBindPoint::eCompute, *pipeline);
        command_buffer.bindDescriptorSets(vk::PipelineBindPoint::eCompute, *pipeline_layout, 0,
                                          *descriptor_set, {});
        command_buffer.dispatch(1, 1, 1);

        vk::MemoryBarrier2 barrier;
        barrier.setSrcStageMask(vk::PipelineStageFlagBits2::eComputeShader)
            .setSrcAccessMask(vk::AccessFlagBits2::eShaderStorageWrite)
            .setDstStageMask(vk::PipelineStageFlagBits2::eHost)
            .setDstAccessMask(vk::AccessFlagBits2::eHostRead);
        vk::DependencyInfo dependency;
        dependency.setMemoryBarriers(barrier);
        command_buffer.pipelineBarrier2(dependency);
        if (context.debug_utils_enabled) {
            command_buffer.endDebugUtilsLabelEXT();
        }
    });

    std::uint32_t value = 0;
    {
        void* mapped = storage_buffer.memory.mapMemory(0, storage_buffer.size);
        std::memcpy(&value, mapped, sizeof(value));
        storage_buffer.memory.unmapMemory();
    }

    if (value != kComputeExpectedValue) {
        throw std::runtime_error("compute shader wrote unexpected value");
    }
    context.throw_if_validation_failed();
}

void run_offscreen_render_smoke() {
    VulkanSmokeContext context;

    auto render_image = create_render_image(context);
    auto readback_buffer = create_buffer(
        context, kRenderWidth * kRenderHeight * 4, vk::BufferUsageFlagBits::eTransferDst,
        vk::MemoryPropertyFlagBits::eHostVisible | vk::MemoryPropertyFlagBits::eHostCoherent,
        "render smoke readback buffer");

    const auto vertex_path =
        std::filesystem::path(PROJECT_VULKAN_SHADER_DIR) / "offscreen_triangle.vert.spv";
    const auto fragment_path =
        std::filesystem::path(PROJECT_VULKAN_SHADER_DIR) / "offscreen_triangle.frag.spv";
    auto vertex_shader = create_shader_module(context, vertex_path);
    auto fragment_shader = create_shader_module(context, fragment_path);

    vk::raii::PipelineLayout pipeline_layout(context.device, vk::PipelineLayoutCreateInfo{});

    std::array<vk::PipelineShaderStageCreateInfo, 2> shader_stages = {
        shader_stage(vk::ShaderStageFlagBits::eVertex, vertex_shader),
        shader_stage(vk::ShaderStageFlagBits::eFragment, fragment_shader),
    };

    vk::PipelineVertexInputStateCreateInfo vertex_input;
    vk::PipelineInputAssemblyStateCreateInfo input_assembly;
    input_assembly.setTopology(vk::PrimitiveTopology::eTriangleList);
    const vk::Viewport viewport(0.0F, 0.0F, static_cast<float>(kRenderWidth),
                                static_cast<float>(kRenderHeight), 0.0F, 1.0F);
    const vk::Rect2D scissor({0, 0}, {kRenderWidth, kRenderHeight});
    vk::PipelineViewportStateCreateInfo viewport_state;
    viewport_state.setViewports(viewport).setScissors(scissor);
    vk::PipelineRasterizationStateCreateInfo rasterization;
    rasterization.setPolygonMode(vk::PolygonMode::eFill)
        .setCullMode(vk::CullModeFlagBits::eNone)
        .setFrontFace(vk::FrontFace::eCounterClockwise)
        .setLineWidth(1.0F);
    vk::PipelineMultisampleStateCreateInfo multisample;
    multisample.setRasterizationSamples(vk::SampleCountFlagBits::e1);
    vk::PipelineColorBlendAttachmentState color_blend_attachment;
    color_blend_attachment.setColorWriteMask(
        vk::ColorComponentFlagBits::eR | vk::ColorComponentFlagBits::eG |
        vk::ColorComponentFlagBits::eB | vk::ColorComponentFlagBits::eA);
    vk::PipelineColorBlendStateCreateInfo color_blend;
    color_blend.setAttachments(color_blend_attachment);
    vk::PipelineRenderingCreateInfo rendering_info;
    rendering_info.setColorAttachmentFormats(kRenderFormat);

    vk::GraphicsPipelineCreateInfo pipeline_info;
    pipeline_info.setPNext(&rendering_info)
        .setStages(shader_stages)
        .setPVertexInputState(&vertex_input)
        .setPInputAssemblyState(&input_assembly)
        .setPViewportState(&viewport_state)
        .setPRasterizationState(&rasterization)
        .setPMultisampleState(&multisample)
        .setPColorBlendState(&color_blend)
        .setLayout(*pipeline_layout);
    auto pipeline = context.device.createGraphicsPipeline(nullptr, pipeline_info);
    context.name_object(*pipeline, "offscreen render smoke pipeline");

    submit_immediate(context, [&](const vk::raii::CommandBuffer& command_buffer) {
        if (context.debug_utils_enabled) {
            command_buffer.beginDebugUtilsLabelEXT(
                vk::DebugUtilsLabelEXT{}.setPLabelName("offscreen render smoke"));
        }

        const vk::ImageSubresourceRange color_range(vk::ImageAspectFlagBits::eColor, 0, 1, 0, 1);
        vk::ImageMemoryBarrier2 to_color_attachment;
        to_color_attachment.setSrcStageMask(vk::PipelineStageFlagBits2::eTopOfPipe)
            .setSrcAccessMask({})
            .setDstStageMask(vk::PipelineStageFlagBits2::eColorAttachmentOutput)
            .setDstAccessMask(vk::AccessFlagBits2::eColorAttachmentWrite)
            .setOldLayout(vk::ImageLayout::eUndefined)
            .setNewLayout(vk::ImageLayout::eColorAttachmentOptimal)
            .setSrcQueueFamilyIndex(VK_QUEUE_FAMILY_IGNORED)
            .setDstQueueFamilyIndex(VK_QUEUE_FAMILY_IGNORED)
            .setImage(*render_image.image)
            .setSubresourceRange(color_range);
        vk::DependencyInfo to_color_dependency;
        to_color_dependency.setImageMemoryBarriers(to_color_attachment);
        command_buffer.pipelineBarrier2(to_color_dependency);

        const vk::ClearValue clear_value(
            vk::ClearColorValue(std::array<float, 4>{0.0F, 0.0F, 0.0F, 1.0F}));
        vk::RenderingAttachmentInfo color_attachment;
        color_attachment.setImageView(*render_image.view)
            .setImageLayout(vk::ImageLayout::eColorAttachmentOptimal)
            .setLoadOp(vk::AttachmentLoadOp::eClear)
            .setStoreOp(vk::AttachmentStoreOp::eStore)
            .setClearValue(clear_value);
        vk::RenderingInfo rendering;
        rendering.setRenderArea(vk::Rect2D({0, 0}, {kRenderWidth, kRenderHeight}))
            .setLayerCount(1)
            .setColorAttachments(color_attachment);
        command_buffer.beginRendering(rendering);
        command_buffer.bindPipeline(vk::PipelineBindPoint::eGraphics, *pipeline);
        command_buffer.draw(3, 1, 0, 0);
        command_buffer.endRendering();

        vk::ImageMemoryBarrier2 to_transfer_src;
        to_transfer_src.setSrcStageMask(vk::PipelineStageFlagBits2::eColorAttachmentOutput)
            .setSrcAccessMask(vk::AccessFlagBits2::eColorAttachmentWrite)
            .setDstStageMask(vk::PipelineStageFlagBits2::eTransfer)
            .setDstAccessMask(vk::AccessFlagBits2::eTransferRead)
            .setOldLayout(vk::ImageLayout::eColorAttachmentOptimal)
            .setNewLayout(vk::ImageLayout::eTransferSrcOptimal)
            .setSrcQueueFamilyIndex(VK_QUEUE_FAMILY_IGNORED)
            .setDstQueueFamilyIndex(VK_QUEUE_FAMILY_IGNORED)
            .setImage(*render_image.image)
            .setSubresourceRange(color_range);
        vk::DependencyInfo to_transfer_dependency;
        to_transfer_dependency.setImageMemoryBarriers(to_transfer_src);
        command_buffer.pipelineBarrier2(to_transfer_dependency);

        vk::BufferImageCopy copy_region;
        copy_region.setBufferOffset(0)
            .setImageSubresource(
                vk::ImageSubresourceLayers(vk::ImageAspectFlagBits::eColor, 0, 0, 1))
            .setImageExtent(vk::Extent3D{kRenderWidth, kRenderHeight, 1});
        command_buffer.copyImageToBuffer(*render_image.image, vk::ImageLayout::eTransferSrcOptimal,
                                         *readback_buffer.buffer, copy_region);

        vk::MemoryBarrier2 host_read_barrier;
        host_read_barrier.setSrcStageMask(vk::PipelineStageFlagBits2::eTransfer)
            .setSrcAccessMask(vk::AccessFlagBits2::eTransferWrite)
            .setDstStageMask(vk::PipelineStageFlagBits2::eHost)
            .setDstAccessMask(vk::AccessFlagBits2::eHostRead);
        vk::DependencyInfo host_read_dependency;
        host_read_dependency.setMemoryBarriers(host_read_barrier);
        command_buffer.pipelineBarrier2(host_read_dependency);

        if (context.debug_utils_enabled) {
            command_buffer.endDebugUtilsLabelEXT();
        }
    });

    std::array<std::uint8_t, 4> pixel{};
    {
        void* mapped = readback_buffer.memory.mapMemory(0, readback_buffer.size);
        std::memcpy(pixel.data(), mapped, pixel.size());
        readback_buffer.memory.unmapMemory();
    }

    if (pixel[0] != 0 || pixel[1] < 250 || pixel[2] != 0 || pixel[3] < 250) {
        throw std::runtime_error("offscreen render produced unexpected RGBA pixel");
    }
    context.throw_if_validation_failed();
}

VulkanSmokeResult capture_result(void (*operation)(), std::string_view success_message) {
    try {
        operation();
        return {true, std::string(success_message)};
    } catch (const std::exception& error) {
        return {false, error.what()};
    }
}

} // namespace

bool vulkan_loader_probe() {
    try {
        vk::raii::Context context;
        const auto api_version = context.enumerateInstanceVersion();
        return api_version >= PROJECT_VULKAN_TARGET_API_VERSION;
    } catch (...) {
        return false;
    }
}

VulkanSmokeResult vulkan_compute_smoke() {
    return capture_result(run_compute_smoke, "Vulkan compute smoke ok");
}

VulkanSmokeResult vulkan_offscreen_render_smoke() {
    return capture_result(run_offscreen_render_smoke, "Vulkan offscreen render smoke ok");
}

VulkanSmokeResult vulkan_full_smoke() {
    const auto compute = vulkan_compute_smoke();
    if (!compute.ok) {
        return compute;
    }
    return vulkan_offscreen_render_smoke();
}

} // namespace {{CPP_NAMESPACE}}
