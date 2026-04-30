#!/usr/bin/env bash
set -euo pipefail

mkdir -p artifacts/sanitizer

if ! command -v compute-sanitizer >/dev/null 2>&1; then
    echo "compute-sanitizer is required" >&2
    exit 1
fi

if [[ -z "${CUDA_VISIBLE_DEVICES:-}" && ( -n "${GPU_ALLOWED_INDICES:-}" || "${GPU_AUTO_SELECT:-0}" == "1" ) ]]; then
    if [[ ! -x "scripts/select_idle_gpu.sh" ]]; then
        echo "scripts/select_idle_gpu.sh is required for GPU auto-selection" >&2
        exit 1
    fi
    CUDA_VISIBLE_DEVICES="$(scripts/select_idle_gpu.sh)"
    export CUDA_VISIBLE_DEVICES
    echo "CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}"
fi

if (( "$#" > 0 )); then
    command_to_run=("$@")
else
    command_to_run=(ctest --preset gpu --output-on-failure)
fi

log_path="artifacts/sanitizer/compute-sanitizer.log"
compute-sanitizer --target-processes all "${command_to_run[@]}" 2>&1 | tee "${log_path}"
