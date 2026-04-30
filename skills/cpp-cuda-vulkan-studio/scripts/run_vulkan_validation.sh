#!/usr/bin/env bash
set -euo pipefail

output_dir="${VULKAN_VALIDATION_OUTPUT_DIR:-artifacts/vulkan}"
mkdir -p "${output_dir}"

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
