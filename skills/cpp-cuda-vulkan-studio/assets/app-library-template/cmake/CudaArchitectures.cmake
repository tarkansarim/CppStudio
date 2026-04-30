function(project_resolve_cuda_architectures out_var)
    set(requested_architectures "${PROJECT_CUDA_ARCHITECTURES}")
    if(requested_architectures STREQUAL "native")
        find_program(PROJECT_NVIDIA_SMI_EXECUTABLE NAMES nvidia-smi)
        if(PROJECT_NVIDIA_SMI_EXECUTABLE)
            execute_process(
                COMMAND
                    "${PROJECT_NVIDIA_SMI_EXECUTABLE}"
                    --query-gpu=compute_cap
                    --format=csv,noheader,nounits
                OUTPUT_VARIABLE project_compute_caps
                RESULT_VARIABLE project_nvidia_smi_result
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            if(project_nvidia_smi_result EQUAL 0 AND NOT project_compute_caps STREQUAL "")
                set(resolved_architectures "")
                string(REPLACE "\n" ";" project_compute_cap_list "${project_compute_caps}")
                foreach(compute_cap IN LISTS project_compute_cap_list)
                    string(STRIP "${compute_cap}" compute_cap)
                    if(compute_cap MATCHES "^([0-9]+)\\.([0-9]+)$")
                        string(APPEND cuda_arch "${CMAKE_MATCH_1}${CMAKE_MATCH_2}")
                        list(APPEND resolved_architectures "${cuda_arch}")
                        unset(cuda_arch)
                    endif()
                endforeach()
                if(resolved_architectures)
                    list(REMOVE_DUPLICATES resolved_architectures)
                    list(JOIN resolved_architectures ";" resolved_architectures)
                    set(${out_var} "${resolved_architectures}" PARENT_SCOPE)
                    return()
                endif()
            endif()
        endif()
    endif()

    set(${out_var} "${requested_architectures}" PARENT_SCOPE)
endfunction()

macro(project_enable_cuda_language)
    project_resolve_cuda_architectures(resolved_cuda_architectures)
    set(PROJECT_RESOLVED_CUDA_ARCHITECTURES
        "${resolved_cuda_architectures}"
        CACHE INTERNAL
        "Resolved CUDA architectures for project CUDA targets"
    )
    set(CMAKE_CUDA_ARCHITECTURES "${PROJECT_RESOLVED_CUDA_ARCHITECTURES}" CACHE STRING "CUDA architectures" FORCE)
    message(STATUS "CUDA architectures: ${PROJECT_RESOLVED_CUDA_ARCHITECTURES}")
    enable_language(CUDA)
    find_package(CUDAToolkit REQUIRED)
endmacro()

function(project_configure_cuda_target target_name)
    set_target_properties(${target_name}
        PROPERTIES
            CUDA_STANDARD 17
            CUDA_STANDARD_REQUIRED ON
            CUDA_SEPARABLE_COMPILATION ON
            CUDA_ARCHITECTURES "${PROJECT_RESOLVED_CUDA_ARCHITECTURES}"
    )
    target_compile_options(${target_name}
        PRIVATE
            $<$<COMPILE_LANGUAGE:CUDA>:--extended-lambda>
    )
endfunction()
