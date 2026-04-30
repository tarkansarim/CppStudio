# Vulkan Source Map

Accessed: 2026-04-29

This source map records the primary references used for the Vulkan lane research. The notes capture
why each source matters for later skill or template planning.

## Khronos Vulkan Documentation

| Area | Source | Key Signal For This Repo |
| --- | --- | --- |
| Current tutorial baseline | [Khronos Vulkan Tutorial introduction](https://docs.vulkan.org/tutorial/latest/00_Introduction.html) | The current Khronos tutorial presents modern Vulkan with Vulkan 1.4, dynamic rendering, timeline semaphores, Slang, modern C++20, and Vulkan-Hpp RAII. |
| Synchronization overview | [Vulkan Guide: Synchronization](https://docs.vulkan.org/guide/latest/synchronization.html) | Synchronization is explicitly complex and application-managed; validation support exists but must be enabled and interpreted. |
| Synchronization recipes | [Vulkan Guide: Synchronization Examples](https://docs.vulkan.org/guide/latest/synchronization_examples.html) | New examples are written around `VK_KHR_synchronization2`, making sync2 the right default research target for new code. |
| Synchronization2 extension | [Vulkan Guide: VK_KHR_synchronization2](https://docs.vulkan.org/guide/latest/extensions/VK_KHR_synchronization2.html) | Sync2 ties stage and access masks together, improves barriers, events, image layouts, and queue submission syntax; promoted to Vulkan 1.3. |
| Queue semantics | [Vulkan Guide: Queues](https://docs.vulkan.org/guide/latest/queues.html) | Work on different queues is unordered unless explicitly synchronized; queue submission is externally synchronized. |
| Device and queue model | [Vulkan Spec: Devices and Queues](https://docs.vulkan.org/spec/latest/chapters/devsandqueues.html) | Device creation, physical/logical device separation, and queue family capability queries are foundational setup work. |
| Descriptor model | [Vulkan Spec: Descriptor Sets](https://docs.vulkan.org/spec/latest/chapters/descriptorsets.html) | Descriptor set layouts define shader/API contracts; pipeline layout compatibility and descriptor validity matter for runtime correctness. |
| Resource descriptors | [Vulkan Spec: Resource Descriptors](https://docs.vulkan.org/spec/latest/chapters/descriptors.html) | Descriptor buffers, descriptor sets, and shader resource mapping are core concepts for bindless and modern descriptor strategies. |
| Memory model | [Vulkan Spec: Memory Allocation](https://docs.vulkan.org/spec/latest/chapters/memory.html) | Host-visible/coherent/cached memory and non-coherent flush/invalidate rules must be treated as correctness constraints. |
| Memory budgets | [VK_EXT_memory_budget](https://docs.vulkan.org/refpages/latest/refpages/source/VK_EXT_memory_budget.html) | Runtime memory budget queries are part of robust Vulkan memory management. |
| Dynamic rendering | [Khronos Vulkan Samples: Dynamic Rendering](https://docs.vulkan.org/samples/latest/samples/extensions/dynamic_rendering/README.html) | Dynamic rendering removes render pass/framebuffer objects for many workflows and is promoted to Vulkan 1.3. |
| Timeline semaphores | [Khronos Vulkan Samples: Timeline Semaphore](https://docs.vulkan.org/samples/latest/samples/extensions/timeline_semaphore/README.html) | Timeline semaphores address multi-queue and multi-producer/consumer synchronization patterns. |
| Validation tutorial | [Khronos Vulkan Tutorial: Validation Layers](https://docs.vulkan.org/tutorial/latest/03_Drawing_a_triangle/00_Setup/02_Validation_layers.html) | Validation layers compensate for Vulkan's intentionally low default error checking. |
| Debug utils | [Vulkan Guide: VK_EXT_debug_utils](https://docs.vulkan.org/guide/latest/extensions/VK_EXT_debug_utils.html) | Object names and command labels are essential for readable validation and RenderDoc/Nsight captures. |
| Debugging spec | [Vulkan Spec: Debugging](https://docs.vulkan.org/spec/latest/chapters/debugging.html) | Debug markers, object annotation, command buffer markers, and device-loss checkpoints are explicit Vulkan debugging facilities. |
| Dynamic rendering extension | [VK_KHR_dynamic_rendering](https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_dynamic_rendering.html) | Dynamic rendering is ratified and promoted to Vulkan 1.3. |
| Shader objects | [VK_EXT_shader_object](https://docs.vulkan.org/refpages/latest/refpages/source/VK_EXT_shader_object.html) | Shader objects are a flexible alternative to traditional pipeline objects, but remain an extension-level design choice. |
| Descriptor buffers | [VK_EXT_descriptor_buffer](https://docs.vulkan.org/refpages/latest/refpages/source/VK_EXT_descriptor_buffer.html) | Descriptor buffer is powerful but already superseded directionally by descriptor heap work; use deliberately, not as default. |
| Vulkan Profiles | [Vulkan Guide: Vulkan Profiles](https://docs.vulkan.org/guide/latest/vulkan_profiles.html) | Profiles define capability baselines that reduce manual feature/extension boilerplate and clarify portability targets. |
| Profiles sample | [Khronos Vulkan Samples: Using Vulkan Profiles](https://docs.vulkan.org/samples/latest/samples/tooling/profiles/README.html) | Profiles can check support and configure instance/device creation for required features and extensions. |
| Portability subset | [Khronos Vulkan Samples: Portability Extension](https://docs.vulkan.org/samples/latest/samples/extensions/portability/README.html) | MoltenVK and non-conformant portability paths require explicit instance flags and portability subset handling. |

## SDK, Build, And Loader Sources

| Area | Source | Key Signal For This Repo |
| --- | --- | --- |
| SDK contents | [LunarG Vulkan SDK Linux getting started](https://vulkan.lunarg.com/doc/view/latest/linux/getting_started.html) | SDK supplies validation, shader tools, GFXReconstruct, Vulkan Configurator, Volk, VMA, and headers/libraries, but not drivers. |
| CMake discovery | [CMake `FindVulkan`](https://cmake.org/cmake/help/latest/module/FindVulkan.html) | CMake exposes imported targets for `Vulkan::Vulkan`, `Vulkan::Headers`, `glslc`, `glslangValidator`, `SPIRV-Tools`, DXC, MoltenVK, and Volk. |
| Loader architecture | [Khronos Vulkan Loader architecture](https://github.com/KhronosGroup/Vulkan-Loader/blob/main/docs/LoaderInterfaceArchitecture.md) | Loader, layers, and ICDs are separate; environment and manifest issues are first-class Vulkan failures. |
| Loader repository | [Khronos Vulkan Loader README](https://github.com/KhronosGroup/Vulkan-Loader) | Loader supports multiple drivers/ICDs and inserts layers between the app and drivers. |
| Validation repository | [Khronos Vulkan Validation Layers README](https://github.com/KhronosGroup/Vulkan-ValidationLayers) | Validation layers are the official development-time checking layer, with SDK tags distinct from regular version tags. |
| Validation features | [VkValidationFeatureEnableEXT](https://registry.khronos.org/vulkan/specs/latest/man/html/VkValidationFeatureEnableEXT.html) | GPU-assisted, best-practices, debug printf, and synchronization validation are explicit feature switches. |

## Shader And SPIR-V Sources

| Area | Source | Key Signal For This Repo |
| --- | --- | --- |
| Slang | [shader-slang/slang README](https://github.com/shader-slang/slang) | Slang targets Vulkan/SPIR-V, ships in the Vulkan SDK since 1.3.296.0, and also targets CUDA, making it relevant to a combined GPU studio lane. |
| GLSL reference frontend | [Khronos glslang README](https://github.com/KhronosGroup/glslang) | glslang is the Khronos reference frontend and SPIR-V generator; HLSL frontend status is changing, so DXC/Slang should be considered for HLSL. |
| Shaderc/glslc | [google/shaderc README](https://github.com/google/shaderc) | `glslc` wraps glslang and SPIRV-Tools with a build-system-friendly command-line interface. |
| DXC SPIR-V | [DirectXShaderCompiler README](https://github.com/microsoft/DirectXShaderCompiler) | DXC supports HLSL to SPIR-V and CMake notes that the Vulkan SDK DXC is typically required for Vulkan-capable DXC. |
| SPIR-V Tools | [Khronos SPIRV-Tools README](https://github.com/KhronosGroup/SPIRV-Tools) | Provides `spirv-val`, `spirv-opt`, assembler/disassembler, and a validation/optimization API. |
| SPIRV-Reflect | [Khronos SPIRV-Reflect README](https://github.com/KhronosGroup/SPIRV-Reflect) | Lightweight C/C++ reflection for descriptors, pipeline layouts, push constants, and shader IO. |
| SPIRV-Cross | [Khronos SPIRV-Cross README](https://github.com/KhronosGroup/SPIRV-Cross) | Reflection and cross-compilation from SPIR-V to GLSL/MSL/HLSL; useful for portability and shader inspection workflows. |
| Volk | [zeux/volk README](https://github.com/zeux/volk) | Vulkan meta-loader that simplifies dynamic entrypoint loading and extension function lookup. |

## Memory, Debugger, And Profiler Sources

| Area | Source | Key Signal For This Repo |
| --- | --- | --- |
| VMA overview | [Vulkan Memory Allocator product page](https://gpuopen.com/vulkan-memory-allocator/) | VMA is an established open-source Vulkan allocation library used in games and Khronos samples. |
| VMA documentation | [Vulkan Memory Allocator docs](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/) | VMA docs cover setup, memory type selection, mapping, budget tracking, and custom pools. |
| VMA usage patterns | [VMA recommended usage patterns](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/usage_patterns.html) | GPU-only, staging, readback, and mapped memory patterns can be encoded into project docs/checklists. |
| VMA budget tracking | [VMA staying within budget](https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/staying_within_budget.html) | Budget queries are fast enough to use regularly; deep statistics are debug-only. |
| RenderDoc | [RenderDoc README](https://github.com/baldurk/renderdoc) | RenderDoc is a Vulkan-capable frame-capture debugger; use it for render inspection, not as a substitute for validation. |
| RenderDoc Vulkan notes | [RenderDoc Vulkan wiki](https://github.com/baldurk/renderdoc/wiki/Vulkan) | RenderDoc should be used after validation is clean because captures assume valid API usage. |
| Nsight Graphics frame debugger | [Nsight Graphics Frame Debugger Overview](https://docs.nvidia.com/nsight-graphics/2025.5/UserGuide/frame-debugger-overview.html) | Frame debugger inspects rendering calls, GPU pipeline state, resources, pixel history, and shader performance. |
| Nsight Graphics CLI capture | [Nsight Graphics Capture CLI](https://docs.nvidia.com/nsight-graphics/UserGuide/graphics-capture-cli.html) | `ngfx-capture` can create standalone graphics capture files from command-line workflows. |

