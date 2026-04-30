#!/usr/bin/env bash
set -euo pipefail

require_cuda="${REQUIRE_CUDA:-0}"
require_vulkan="${REQUIRE_VULKAN:-1}"
require_profiling="${REQUIRE_PROFILING:-0}"
require_cuda_profiling="${REQUIRE_CUDA_PROFILING:-0}"

missing=0

need_cmd() {
    local name="$1"
    if ! command -v "${name}" >/dev/null 2>&1; then
        echo "MISSING required command: ${name}" >&2
        missing=1
    else
        echo "ok: ${name} -> $(command -v "${name}")"
    fi
}

want_cmd() {
    local name="$1"
    if ! command -v "${name}" >/dev/null 2>&1; then
        echo "warn: optional command not found: ${name}" >&2
    else
        echo "ok: ${name} -> $(command -v "${name}")"
    fi
}

need_cmd cmake
need_cmd c++
need_cmd git

if [[ "${require_cuda}" == "1" ]]; then
    need_cmd nvcc
    need_cmd nvidia-smi
    need_cmd compute-sanitizer
else
    want_cmd nvcc
    want_cmd nvidia-smi
    want_cmd compute-sanitizer
fi

if [[ "${require_vulkan}" == "1" ]]; then
    need_cmd glslc
    need_cmd spirv-val
    need_cmd vulkaninfo
    if [[ -n "${VULKAN_SDK:-}" ]]; then
        echo "ok: VULKAN_SDK=${VULKAN_SDK}"
        if [[ -f "${VULKAN_SDK}/include/vma/vk_mem_alloc.h" ]]; then
            echo "ok: VMA header -> ${VULKAN_SDK}/include/vma/vk_mem_alloc.h"
        else
            echo "warn: VMA header not found under VULKAN_SDK include path" >&2
        fi
    else
        echo "warn: VULKAN_SDK is not set; CMake may fall back to system Vulkan headers/tools" >&2
    fi
else
    want_cmd glslc
    want_cmd glslangValidator
    want_cmd spirv-val
    want_cmd vulkaninfo
fi

if [[ "${require_profiling}" == "1" ]]; then
    need_cmd nsys
else
    want_cmd nsys
fi

if [[ "${require_cuda_profiling}" == "1" ]]; then
    need_cmd ncu
else
    want_cmd ncu
fi

want_cmd clang-format
want_cmd clang-tidy
want_cmd run-clang-tidy
want_cmd renderdoccmd
want_cmd ngfx-capture

exit "${missing}"
