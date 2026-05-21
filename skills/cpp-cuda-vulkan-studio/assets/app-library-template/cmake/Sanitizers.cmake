function(project_enable_host_sanitizers target_name)
    if(NOT PROJECT_ENABLE_HOST_SANITIZERS)
        return()
    endif()

    get_target_property(project_target_type ${target_name} TYPE)

    if(MSVC)
        target_compile_options(${target_name}
            PRIVATE
                $<$<COMPILE_LANGUAGE:CXX>:/fsanitize=address /Zi>
        )
        if(NOT project_target_type STREQUAL "STATIC_LIBRARY" AND NOT project_target_type STREQUAL "OBJECT_LIBRARY")
            target_link_options(${target_name}
                PRIVATE
                    /fsanitize=address
            )
        endif()
        return()
    endif()

    target_compile_options(${target_name}
        PRIVATE
            $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=address,undefined -fno-omit-frame-pointer>
    )
    if(NOT project_target_type STREQUAL "STATIC_LIBRARY" AND NOT project_target_type STREQUAL "OBJECT_LIBRARY")
        target_link_options(${target_name}
            PRIVATE
        -fsanitize=address,undefined
    )
    endif()
endfunction()

function(project_enable_host_coverage target_name)
    if(NOT PROJECT_ENABLE_HOST_COVERAGE)
        return()
    endif()

    get_target_property(project_target_type ${target_name} TYPE)

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        target_compile_options(${target_name}
            PRIVATE
                $<$<COMPILE_LANGUAGE:CXX>:-fprofile-instr-generate -fcoverage-mapping>
        )
        if(NOT project_target_type STREQUAL "STATIC_LIBRARY" AND NOT project_target_type STREQUAL "OBJECT_LIBRARY")
            target_link_options(${target_name}
                PRIVATE
                    -fprofile-instr-generate
            )
        endif()
        return()
    endif()

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(${target_name}
            PRIVATE
                $<$<COMPILE_LANGUAGE:CXX>:-ftest-coverage -fprofile-arcs>
        )
        if(NOT project_target_type STREQUAL "STATIC_LIBRARY" AND NOT project_target_type STREQUAL "OBJECT_LIBRARY")
            target_link_options(${target_name}
                PRIVATE
                    --coverage
            )
        endif()
        return()
    endif()

    message(FATAL_ERROR "PROJECT_ENABLE_HOST_COVERAGE requires Clang/LLVM or GCC coverage instrumentation")
endfunction()
