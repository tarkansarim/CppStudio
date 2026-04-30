function(project_enable_vulkan)
    if(NOT PROJECT_VULKAN_API_VERSION STREQUAL "1.4")
        message(FATAL_ERROR "This template currently supports PROJECT_VULKAN_API_VERSION=1.4")
    endif()

    find_package(Vulkan 1.4 REQUIRED COMPONENTS glslc)
    find_program(PROJECT_SPIRV_VAL_EXECUTABLE NAMES spirv-val HINTS "$ENV{VULKAN_SDK}/bin" REQUIRED)

    set(PROJECT_VULKAN_SPIRV_DIR
        "${CMAKE_CURRENT_BINARY_DIR}/shaders"
        CACHE INTERNAL
        "Generated SPIR-V shader output directory"
    )

    message(STATUS "Vulkan version: ${Vulkan_VERSION}")
    message(STATUS "Vulkan shader compiler: ${Vulkan_GLSLC_EXECUTABLE}")
    message(STATUS "SPIR-V validator: ${PROJECT_SPIRV_VAL_EXECUTABLE}")
endfunction()

function(project_compile_vulkan_shader out_var shader_source)
    if(NOT TARGET Vulkan::glslc)
        message(FATAL_ERROR "Vulkan::glslc is required before compiling Vulkan shaders")
    endif()
    if(NOT PROJECT_SPIRV_VAL_EXECUTABLE)
        message(FATAL_ERROR "PROJECT_SPIRV_VAL_EXECUTABLE is required before validating Vulkan shaders")
    endif()

    get_filename_component(shader_name "${shader_source}" NAME)
    set(shader_input "${CMAKE_CURRENT_SOURCE_DIR}/${shader_source}")
    set(shader_output "${PROJECT_VULKAN_SPIRV_DIR}/${shader_name}.spv")

    add_custom_command(
        OUTPUT "${shader_output}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${PROJECT_VULKAN_SPIRV_DIR}"
        COMMAND Vulkan::glslc --target-env=vulkan1.4 "${shader_input}" -o "${shader_output}"
        COMMAND "${PROJECT_SPIRV_VAL_EXECUTABLE}" --target-env vulkan1.4 "${shader_output}"
        DEPENDS "${shader_input}"
        VERBATIM
        COMMENT "Compiling and validating ${shader_source}"
    )

    set(${out_var} "${shader_output}" PARENT_SCOPE)
endfunction()

function(project_configure_vulkan_target target_name)
    target_compile_definitions(${target_name}
        PRIVATE
            PROJECT_VULKAN_SHADER_DIR="${PROJECT_VULKAN_SPIRV_DIR}"
            PROJECT_VULKAN_TARGET_API_VERSION=VK_API_VERSION_1_4
            PROJECT_VULKAN_ENABLE_VALIDATION=$<BOOL:${PROJECT_ENABLE_VULKAN_VALIDATION}>
            PROJECT_VULKAN_ENABLE_DEBUG_UTILS=$<BOOL:${PROJECT_ENABLE_VULKAN_DEBUG_UTILS}>
            PROJECT_VULKAN_ENABLE_PORTABILITY=$<BOOL:${PROJECT_ENABLE_VULKAN_PORTABILITY}>
    )
endfunction()
