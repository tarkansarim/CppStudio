#include "{{PROJECT_NAME}}/vulkan_probe.hpp"

#include <iostream>

int main() {
    if (!{{CPP_NAMESPACE}}::vulkan_loader_probe()) {
        std::cerr << "Vulkan loader probe failed\n";
        return 1;
    }
    return 0;
}
