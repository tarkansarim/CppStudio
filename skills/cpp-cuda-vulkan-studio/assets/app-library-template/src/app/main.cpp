#include "{{PROJECT_NAME}}/version.hpp"
#include "{{PROJECT_NAME}}/viewport_session.hpp"

#ifdef PROJECT_HAS_CUDA
#include "{{PROJECT_NAME}}/cuda_vector_add.hpp"
#endif

#ifdef PROJECT_HAS_VULKAN
#include "{{PROJECT_NAME}}/vulkan_probe.hpp"
#endif

#include <filesystem>
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

std::filesystem::path option_path(int argc, char** argv, std::string_view option,
                                  std::filesystem::path fallback) {
    for (int index = 1; index + 1 < argc; ++index) {
        if (argv[index] == option) {
            return argv[index + 1];
        }
    }
    return fallback;
}

int run_cuda_smoke() {
#ifdef PROJECT_HAS_CUDA
    return {{CPP_NAMESPACE}}::cuda_vector_add_smoke() ? 0 : 4;
#else
    std::cerr << "CUDA smoke requested but CUDA is disabled\n";
    return 3;
#endif
}

int run_vulkan_smoke() {
#ifdef PROJECT_HAS_VULKAN
    const auto vulkan_smoke = {{CPP_NAMESPACE}}::vulkan_full_smoke();
    if (!vulkan_smoke.ok) {
        std::cerr << "Vulkan smoke failed: " << vulkan_smoke.message << '\n';
        return 5;
    }
    return 0;
#else
    std::cerr << "Vulkan smoke requested but Vulkan is disabled\n";
    return 3;
#endif
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
    if (has_arg(argc, argv, "--cuda-smoke")) {
        return run_cuda_smoke();
    }
    if (has_arg(argc, argv, "--vulkan-smoke")) {
        return run_vulkan_smoke();
    }
    if (has_arg(argc, argv, "--gpu-smoke")) {
        const int vulkan_result = run_vulkan_smoke();
        if (vulkan_result != 0) {
            return vulkan_result;
        }
#ifdef PROJECT_HAS_CUDA
        return run_cuda_smoke();
#else
        return 0;
#endif
    }
    if (has_arg(argc, argv, "--viewport-session-smoke")) {
        const auto output_dir =
            option_path(argc, argv, "--viewport-session-dir",
                        std::filesystem::path("artifacts") / "viewport-sessions" / "smoke");
        const auto report = {{CPP_NAMESPACE}}::run_viewport_session_fake_host_smoke(output_dir);
        std::cout << "Viewport session smoke: " << (report.ok ? "ok" : report.message)
                  << " report=" << (output_dir / "report.json") << '\n';
        return report.ok ? 0 : 6;
    }

    std::cout << "Project: " << {{CPP_NAMESPACE}}::project_name() << '\n';
#ifdef PROJECT_HAS_CUDA
    std::cout << "CUDA smoke: " << ({{CPP_NAMESPACE}}::cuda_vector_add_smoke() ? "ok" : "failed")
              << '\n';
#else
    std::cout << "CUDA: disabled\n";
#endif
#ifdef PROJECT_HAS_VULKAN
    std::cout << "Vulkan loader: " << ({{CPP_NAMESPACE}}::vulkan_loader_probe() ? "ok" : "failed")
              << '\n';
    const auto vulkan_smoke = {{CPP_NAMESPACE}}::vulkan_full_smoke();
    std::cout << "Vulkan smoke: " << (vulkan_smoke.ok ? "ok" : vulkan_smoke.message) << '\n';
#else
    std::cout << "Vulkan: disabled\n";
#endif
    return 0;
}
