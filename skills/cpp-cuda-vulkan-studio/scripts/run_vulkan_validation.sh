#!/usr/bin/env bash
set -euo pipefail

output_dir="${VULKAN_VALIDATION_OUTPUT_DIR:-artifacts/vulkan}"
mkdir -p "${output_dir}"

prepend_path() {
    local var_name="$1"
    local path_value="$2"
    local current_value="${!var_name:-}"

    if [[ -z "${path_value}" || ! -d "${path_value}" ]]; then
        return
    fi
    case ":${current_value}:" in
        *":${path_value}:"*) ;;
        *)
            if [[ -n "${current_value}" ]]; then
                export "${var_name}=${path_value}:${current_value}"
            else
                export "${var_name}=${path_value}"
            fi
            ;;
    esac
}

if [[ -n "${VULKAN_SDK:-}" ]]; then
    sdk_layer_dir="${VULKAN_SDK}/share/vulkan/explicit_layer.d"
    sdk_lib_dir="${VULKAN_SDK}/lib"
    if [[ -f "${sdk_layer_dir}/VkLayer_khronos_validation.json" ]]; then
        export VK_ADD_LAYER_PATH="${VK_ADD_LAYER_PATH:-${sdk_layer_dir}}"
    fi
    if [[ -f "${sdk_lib_dir}/libVkLayer_khronos_validation.so" ]]; then
        prepend_path LD_LIBRARY_PATH "${sdk_lib_dir}"
    fi
fi

if (( "$#" > 0 )); then
    command_to_run=("$@")
else
    cmake --preset vulkan-validation
    cmake --build --preset vulkan-validation
    command_to_run=(ctest --preset vulkan-validation --output-on-failure --no-tests=error)
fi

export VK_INSTANCE_LAYERS="${VK_INSTANCE_LAYERS:-VK_LAYER_KHRONOS_validation}"
log_path="${output_dir}/vulkan-validation.log"

"${command_to_run[@]}" 2>&1 | tee "${log_path}"
if grep -E "Vulkan validation error:|Validation Error|VUID-" "${log_path}" >/dev/null; then
    echo "Vulkan validation errors were reported; see ${log_path}" >&2
    exit 1
fi
echo "Wrote ${log_path}"
