#!/usr/bin/env bash
set -euo pipefail

output_dir="${VULKAN_CAPS_OUTPUT_DIR:-artifacts/vulkan}"
mkdir -p "${output_dir}"

if ! command -v vulkaninfo >/dev/null 2>&1; then
    echo "vulkaninfo is required" >&2
    exit 1
fi

summary_path="${output_dir}/vulkaninfo_summary.txt"
text_path="${output_dir}/vulkaninfo.txt"

vulkaninfo --summary 2>&1 | tee "${summary_path}"
vulkaninfo --text >"${text_path}" 2>&1 || {
    cat "${text_path}" >&2
    exit 1
}

echo "Wrote ${summary_path}"
echo "Wrote ${text_path}"
