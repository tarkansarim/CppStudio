function(project_enable_host_sanitizers target_name)
    if(NOT PROJECT_ENABLE_HOST_SANITIZERS)
        return()
    endif()

    if(MSVC)
        message(FATAL_ERROR "PROJECT_ENABLE_HOST_SANITIZERS is not configured for MSVC in this template")
    endif()

    target_compile_options(${target_name}
        PRIVATE
            $<$<COMPILE_LANGUAGE:CXX>:-fsanitize=address,undefined -fno-omit-frame-pointer>
    )
    target_link_options(${target_name}
        PRIVATE
            -fsanitize=address,undefined
    )
endfunction()
