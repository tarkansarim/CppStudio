#pragma once

#include <string>

namespace {{CPP_NAMESPACE}} {

struct VulkanSmokeResult {
    bool ok = false;
    std::string message;
};

bool vulkan_loader_probe();
VulkanSmokeResult vulkan_compute_smoke();
VulkanSmokeResult vulkan_offscreen_render_smoke();
VulkanSmokeResult vulkan_full_smoke();

} // namespace {{CPP_NAMESPACE}}
