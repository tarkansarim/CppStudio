#include "{{PROJECT_NAME}}/vulkan_probe.hpp"

#include <iostream>

int main() {
    const auto result = {{CPP_NAMESPACE}}::vulkan_offscreen_render_smoke();
    if (!result.ok) {
        std::cerr << "Vulkan offscreen render smoke failed: " << result.message << '\n';
        return 1;
    }
    return 0;
}
