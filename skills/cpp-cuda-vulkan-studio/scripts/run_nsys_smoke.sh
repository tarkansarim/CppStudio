#!/usr/bin/env bash
set -euo pipefail

if ! command -v nsys >/dev/null 2>&1; then
    echo "nsys is required" >&2
    exit 1
fi

build_dir="${BUILD_DIR:-build/dev}"
output_dir="${NSYS_OUTPUT_DIR:-artifacts/profiling}"
trace="${NSYS_TRACE:-cuda,nvtx,osrt}"
mkdir -p "${output_dir}"

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
elif [[ -n "${APP_COMMAND:-}" ]]; then
    # shellcheck disable=SC2206
    command_to_run=(${APP_COMMAND})
else
    app_candidate="$(find "${build_dir}" -maxdepth 1 -type f -perm -111 -name '*_app' | sort | head -n 1 || true)"
    if [[ -z "${app_candidate}" ]]; then
        echo "No app command supplied and no *_app executable found in ${build_dir}" >&2
        exit 1
    fi
    command_to_run=("${app_candidate}" --smoke-test)
fi

report_prefix="${output_dir}/nsys_smoke"
nsys profile \
    --trace="${trace}" \
    --sample=none \
    --force-overwrite=true \
    --output="${report_prefix}" \
    "${command_to_run[@]}"

report_path="${report_prefix}.nsys-rep"
if [[ ! -f "${report_path}" ]]; then
    echo "nsys did not emit ${report_path}" >&2
    exit 1
fi

stats_path="${output_dir}/nsys_smoke_stats.txt"
nsys stats --report cuda_api_gpu_sum,cuda_gpu_kern_sum "${report_path}" >"${stats_path}" 2>&1 || {
    cat "${stats_path}" >&2
    exit 1
}

echo "Wrote ${report_path}"
echo "Wrote ${stats_path}"
