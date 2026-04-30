#!/usr/bin/env bash
set -euo pipefail

if ! command -v nsys >/dev/null 2>&1; then
    echo "nsys is required" >&2
    exit 1
fi

if [[ "${REQUIRE_CUDA_PROFILING:-0}" == "1" ]] && ! command -v ncu >/dev/null 2>&1; then
    echo "ncu is required when REQUIRE_CUDA_PROFILING=1" >&2
    exit 1
fi

profile_lane="${PROFILE_LANE:-vulkan}"
build_dir="${BUILD_DIR:-build/dev}"
output_dir="${NSYS_OUTPUT_DIR:-artifacts/profiling}"
case "${profile_lane}" in
    vulkan)
        default_trace="vulkan,nvtx,osrt"
        default_app_arg="--vulkan-smoke"
        ;;
    cuda)
        default_trace="cuda,nvtx,osrt"
        default_app_arg="--cuda-smoke"
        ;;
    all)
        default_trace="cuda,vulkan,nvtx,osrt"
        default_app_arg="--gpu-smoke"
        ;;
    *)
        echo "PROFILE_LANE must be one of: vulkan, cuda, all" >&2
        exit 2
        ;;
esac
trace="${NSYS_TRACE:-${default_trace}}"
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
    command_to_run=("${app_candidate}" "${default_app_arg}")
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
nsys stats "${report_path}" >"${stats_path}" 2>&1 || {
    cat "${stats_path}" >&2
    exit 1
}

echo "Wrote ${report_path}"
echo "Wrote ${stats_path}"
