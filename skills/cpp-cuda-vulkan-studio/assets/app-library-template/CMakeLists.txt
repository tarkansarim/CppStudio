cmake_minimum_required(VERSION 3.25)

project({{PROJECT_NAME}} VERSION 0.1.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(ProjectOptions)
include(Warnings)
include(Sanitizers)
include(CudaArchitectures)
include(ProjectVulkan)

if(PROJECT_ENABLE_CUDA)
    project_enable_cuda_language()
endif()

if(PROJECT_ENABLE_VULKAN)
    project_enable_vulkan()
endif()

add_library({{PROJECT_NAME_LOWER}}_core
    src/core/library.cpp
    src/testing/viewport_session.cpp
)
add_library({{PROJECT_NAME}}::core ALIAS {{PROJECT_NAME_LOWER}}_core)

target_include_directories({{PROJECT_NAME_LOWER}}_core
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_compile_features({{PROJECT_NAME_LOWER}}_core PUBLIC cxx_std_20)
project_set_warnings({{PROJECT_NAME_LOWER}}_core)
project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_core)

if(PROJECT_ENABLE_CUDA)
    add_library({{PROJECT_NAME_LOWER}}_cuda
        src/cuda/vector_add.cu
    )
    add_library({{PROJECT_NAME}}::cuda ALIAS {{PROJECT_NAME_LOWER}}_cuda)

    target_include_directories({{PROJECT_NAME_LOWER}}_cuda
        PUBLIC
            "${CMAKE_CURRENT_SOURCE_DIR}/include"
    )
    target_link_libraries({{PROJECT_NAME_LOWER}}_cuda
        PUBLIC
            {{PROJECT_NAME}}::core
            CUDA::cudart
    )
    target_compile_definitions({{PROJECT_NAME_LOWER}}_cuda PUBLIC PROJECT_HAS_CUDA=1)
    project_configure_cuda_target({{PROJECT_NAME_LOWER}}_cuda)
    project_set_warnings({{PROJECT_NAME_LOWER}}_cuda)
endif()

if(PROJECT_ENABLE_VULKAN)
    project_compile_vulkan_shader(project_compute_shader_spv shaders/compute.comp)
    project_compile_vulkan_shader(project_offscreen_vertex_shader_spv shaders/offscreen_triangle.vert)
    project_compile_vulkan_shader(project_offscreen_fragment_shader_spv shaders/offscreen_triangle.frag)
    add_custom_target({{PROJECT_NAME_LOWER}}_vulkan_shaders
        DEPENDS
            "${project_compute_shader_spv}"
            "${project_offscreen_vertex_shader_spv}"
            "${project_offscreen_fragment_shader_spv}"
    )

    add_library({{PROJECT_NAME_LOWER}}_render
        src/render/vulkan_probe.cpp
    )
    add_library({{PROJECT_NAME}}::render ALIAS {{PROJECT_NAME_LOWER}}_render)

    target_include_directories({{PROJECT_NAME_LOWER}}_render
        PUBLIC
            "${CMAKE_CURRENT_SOURCE_DIR}/include"
    )
    target_link_libraries({{PROJECT_NAME_LOWER}}_render
        PUBLIC
            {{PROJECT_NAME}}::core
            Vulkan::Vulkan
    )
    target_compile_definitions({{PROJECT_NAME_LOWER}}_render PUBLIC PROJECT_HAS_VULKAN=1)
    add_dependencies({{PROJECT_NAME_LOWER}}_render {{PROJECT_NAME_LOWER}}_vulkan_shaders)
    project_configure_vulkan_target({{PROJECT_NAME_LOWER}}_render)
    project_set_warnings({{PROJECT_NAME_LOWER}}_render)
    project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_render)
endif()

add_executable({{PROJECT_NAME_LOWER}}_app
    src/app/main.cpp
)

target_link_libraries({{PROJECT_NAME_LOWER}}_app
    PRIVATE
        {{PROJECT_NAME}}::core
)

if(PROJECT_ENABLE_CUDA)
    target_link_libraries({{PROJECT_NAME_LOWER}}_app PRIVATE {{PROJECT_NAME}}::cuda)
endif()

if(PROJECT_ENABLE_VULKAN)
    target_link_libraries({{PROJECT_NAME_LOWER}}_app PRIVATE {{PROJECT_NAME}}::render)
endif()

project_set_warnings({{PROJECT_NAME_LOWER}}_app)
project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_app)

if(PROJECT_BUILD_BENCHMARKS)
    add_executable({{PROJECT_NAME_LOWER}}_benchmark_smoke
        benchmarks/benchmark_smoke.cpp
    )
    target_link_libraries({{PROJECT_NAME_LOWER}}_benchmark_smoke PRIVATE {{PROJECT_NAME}}::core)
    project_set_warnings({{PROJECT_NAME_LOWER}}_benchmark_smoke)
    project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_benchmark_smoke)
endif()

if(PROJECT_BUILD_TESTS)
    include(Testing)

    if(PROJECT_BUILD_BENCHMARKS)
        add_test(NAME {{PROJECT_NAME_LOWER}}_benchmark_smoke COMMAND {{PROJECT_NAME_LOWER}}_benchmark_smoke)
        set_tests_properties({{PROJECT_NAME_LOWER}}_benchmark_smoke PROPERTIES LABELS "perf;benchmark")
    endif()

    add_executable({{PROJECT_NAME_LOWER}}_core_test
        tests/unit/core_test.cpp
    )
    target_link_libraries({{PROJECT_NAME_LOWER}}_core_test PRIVATE {{PROJECT_NAME}}::core)
    project_set_warnings({{PROJECT_NAME_LOWER}}_core_test)
    project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_core_test)
    project_add_labeled_test({{PROJECT_NAME_LOWER}}_core_test {{PROJECT_NAME_LOWER}}_core_test "quick")

    add_test(NAME {{PROJECT_NAME_LOWER}}_app_smoke COMMAND {{PROJECT_NAME_LOWER}}_app --smoke-test)
    set_tests_properties({{PROJECT_NAME_LOWER}}_app_smoke PROPERTIES LABELS "quick")

    add_executable({{PROJECT_NAME_LOWER}}_viewport_session_test
        tests/unit/viewport_session_test.cpp
    )
    target_link_libraries({{PROJECT_NAME_LOWER}}_viewport_session_test PRIVATE {{PROJECT_NAME}}::core)
    project_set_warnings({{PROJECT_NAME_LOWER}}_viewport_session_test)
    project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_viewport_session_test)
    project_add_labeled_test(
        {{PROJECT_NAME_LOWER}}_viewport_session_test
        {{PROJECT_NAME_LOWER}}_viewport_session_test
        "quick;viewport-session"
    )

    add_test(
        NAME {{PROJECT_NAME_LOWER}}_viewport_session_smoke
        COMMAND {{PROJECT_NAME_LOWER}}_app --viewport-session-smoke --viewport-session-dir "${CMAKE_BINARY_DIR}/viewport-session-smoke"
    )
    set_tests_properties({{PROJECT_NAME_LOWER}}_viewport_session_smoke PROPERTIES LABELS "quick;viewport-session")

    if(PROJECT_ENABLE_CUDA)
        add_executable({{PROJECT_NAME_LOWER}}_cuda_test
            tests/unit/cuda_vector_add_test.cpp
        )
        target_link_libraries({{PROJECT_NAME_LOWER}}_cuda_test PRIVATE {{PROJECT_NAME}}::cuda)
        project_configure_cuda_target({{PROJECT_NAME_LOWER}}_cuda_test)
        project_set_warnings({{PROJECT_NAME_LOWER}}_cuda_test)
        project_add_labeled_test({{PROJECT_NAME_LOWER}}_cuda_test {{PROJECT_NAME_LOWER}}_cuda_test "gpu;cuda")
    endif()

    if(PROJECT_ENABLE_VULKAN)
        add_executable({{PROJECT_NAME_LOWER}}_vulkan_test
            tests/unit/vulkan_probe_test.cpp
        )
        target_link_libraries({{PROJECT_NAME_LOWER}}_vulkan_test PRIVATE {{PROJECT_NAME}}::render)
        project_set_warnings({{PROJECT_NAME_LOWER}}_vulkan_test)
        project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_vulkan_test)
        project_add_labeled_test({{PROJECT_NAME_LOWER}}_vulkan_test {{PROJECT_NAME_LOWER}}_vulkan_test "vulkan;loader")

        add_executable({{PROJECT_NAME_LOWER}}_vulkan_compute_test
            tests/unit/vulkan_compute_test.cpp
        )
        target_link_libraries({{PROJECT_NAME_LOWER}}_vulkan_compute_test PRIVATE {{PROJECT_NAME}}::render)
        project_set_warnings({{PROJECT_NAME_LOWER}}_vulkan_compute_test)
        project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_vulkan_compute_test)
        project_add_labeled_test(
            {{PROJECT_NAME_LOWER}}_vulkan_compute_test
            {{PROJECT_NAME_LOWER}}_vulkan_compute_test
            "gpu;vulkan;compute"
        )

        add_executable({{PROJECT_NAME_LOWER}}_vulkan_render_test
            tests/unit/vulkan_render_test.cpp
        )
        target_link_libraries({{PROJECT_NAME_LOWER}}_vulkan_render_test PRIVATE {{PROJECT_NAME}}::render)
        project_set_warnings({{PROJECT_NAME_LOWER}}_vulkan_render_test)
        project_enable_host_sanitizers({{PROJECT_NAME_LOWER}}_vulkan_render_test)
        project_add_labeled_test(
            {{PROJECT_NAME_LOWER}}_vulkan_render_test
            {{PROJECT_NAME_LOWER}}_vulkan_render_test
            "gpu;vulkan;render"
        )

        add_test(
            NAME {{PROJECT_NAME_LOWER}}_vulkan_shader_validation
            COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_BINARY_DIR}" --target {{PROJECT_NAME_LOWER}}_vulkan_shaders
        )
        set_tests_properties({{PROJECT_NAME_LOWER}}_vulkan_shader_validation PROPERTIES LABELS "vulkan;shader")
    endif()
endif()
