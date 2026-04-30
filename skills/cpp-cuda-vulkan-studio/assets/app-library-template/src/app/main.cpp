#include "{{PROJECT_NAME}}/version.hpp"

#ifdef PROJECT_HAS_CUDA
#include "{{PROJECT_NAME}}/cuda_vector_add.hpp"
#endif

#ifdef PROJECT_HAS_VULKAN
#include "{{PROJECT_NAME}}/vulkan_probe.hpp"
#endif

#include <iostream>
#include <string_view>

namespace {

bool has_arg(int argc, char** argv, std::string_view wanted) {
    for (int index = 1; index < argc; ++index) {
        if (argv[index] == wanted) {
            return true;
        }
    }
    return false;
}

} // namespace

int main(int argc, char** argv) {
    if (has_arg(argc, argv, "--smoke-test")) {
        if ({{CPP_NAMESPACE}}::add(20, 22) != 42) {
            return 2;
        }
        std::cout << {{CPP_NAMESPACE}}::project_name() << " smoke ok\n";
        return 0;
    }

    std::cout << "Project: " << {{CPP_NAMESPACE}}::project_name() << '\n';
#ifdef PROJECT_HAS_CUDA
    std::cout << "CUDA smoke: " << ({{CPP_NAMESPACE}}::cuda_vector_add_smoke() ? "ok" : "failed") << '\n';
#else
    std::cout << "CUDA: disabled\n";
#endif
#ifdef PROJECT_HAS_VULKAN
    std::cout << "Vulkan loader: " << ({{CPP_NAMESPACE}}::vulkan_loader_probe() ? "ok" : "failed") << '\n';
    const auto vulkan_smoke = {{CPP_NAMESPACE}}::vulkan_full_smoke();
    std::cout << "Vulkan smoke: " << (vulkan_smoke.ok ? "ok" : vulkan_smoke.message) << '\n';
#else
    std::cout << "Vulkan: disabled\n";
#endif
    return 0;
}
