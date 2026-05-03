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

collect_nsys_reports() {
    nsys stats --help-reports 2>/dev/null | awk '
        /^[[:space:]]+[[:alnum:]_].* -- / {
            gsub(/^[[:space:]]+/, "", $0)
            split($0, fields, " ")
            split(fields[1], name, /[:[]/)
            print name[1]
        }
    ' || true
}

collect_nsys_formats() {
    nsys stats --help 2>/dev/null | awk '
        /^[[:space:]]+(column|table|csv|tsv|json|hdoc|htable)[[:space:]]/ {
            print $1
        }
    ' || true
}

has_line() {
    local needle="$1"
    local haystack="$2"
    grep -Fxq "${needle}" <<<"${haystack}"
}

join_by_comma() {
    local joined=""
    local value

    for value in "$@"; do
        if [[ -z "${value}" ]]; then
            continue
        fi
        if [[ -n "${joined}" ]]; then
            joined+=","
        fi
        joined+="${value}"
    done
    printf "%s" "${joined}"
}

trim_value() {
    local value="$1"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    printf "%s" "${value}"
}

select_stats_format() {
    local available_formats="$1"
    local requested_format="${NSYS_STATS_FORMAT:-}"
    local candidate

    if [[ -n "${requested_format}" ]]; then
        if [[ -n "${available_formats}" ]] && ! has_line "${requested_format}" "${available_formats}"; then
            echo "NSYS_STATS_FORMAT=${requested_format} is not supported by this nsys install" >&2
            echo "Supported formats:" >&2
            echo "${available_formats}" >&2
            exit 2
        fi
        printf "%s" "${requested_format}"
        return
    fi

    if [[ -z "${available_formats}" ]]; then
        return
    fi

    for candidate in column table csv tsv json; do
        if has_line "${candidate}" "${available_formats}"; then
            printf "%s" "${candidate}"
            return
        fi
    done
}

select_stats_reports() {
    local available_reports="$1"
    shift
    local selected=()
    local requested_reports="${NSYS_STATS_REPORTS:-}"
    local report raw_report

    if [[ -n "${requested_reports}" ]]; then
        IFS=',' read -r -a selected <<<"${requested_reports}"
        for raw_report in "${selected[@]}"; do
            report="$(trim_value "${raw_report}")"
            if [[ -z "${report}" ]]; then
                continue
            fi
            if [[ -n "${available_reports}" ]] && ! has_line "${report}" "${available_reports}"; then
                echo "NSYS_STATS_REPORTS requested unsupported report: ${report}" >&2
                echo "Supported reports:" >&2
                echo "${available_reports}" >&2
                exit 2
            fi
            printf "%s\n" "${report}"
        done
        return
    fi

    for report in "$@"; do
        if [[ -z "${available_reports}" ]] || has_line "${report}" "${available_reports}"; then
            printf "%s\n" "${report}"
        fi
    done
}

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
    if [[ "${APP_COMMAND}" =~ [[:space:]] ]]; then
        echo "APP_COMMAND must be a single executable path without whitespace; pass command and args directly to run_nsys_smoke.sh" >&2
        exit 2
    fi
    command_to_run=("${APP_COMMAND}")
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

case "${profile_lane}" in
    vulkan)
        preferred_reports=(vulkan_api_sum osrt_sum nvtx_sum)
        ;;
    cuda)
        preferred_reports=(cuda_api_gpu_sum cuda_gpu_kern_sum osrt_sum nvtx_sum)
        ;;
    all)
        preferred_reports=(cuda_api_gpu_sum cuda_gpu_kern_sum vulkan_api_sum osrt_sum nvtx_sum)
        ;;
esac

stats_path="${output_dir}/nsys_smoke_stats.txt"
available_reports="$(collect_nsys_reports)"
available_formats="$(collect_nsys_formats)"
stats_format="$(select_stats_format "${available_formats}")"
mapfile -t stats_reports < <(select_stats_reports "${available_reports}" "${preferred_reports[@]}")

if ((${#stats_reports[@]} == 0)); then
    {
        echo "nsys profile succeeded but no compatible stats reports were found for PROFILE_LANE=${profile_lane}."
        echo "Run 'nsys stats --help-reports' on this machine and set NSYS_STATS_REPORTS explicitly if needed."
    } >"${stats_path}"
    cat "${stats_path}" >&2
    exit 1
fi

: >"${stats_path}"
stats_reports_csv="$(join_by_comma "${stats_reports[@]}")"
{
    echo "==== nsys stats reports: ${stats_reports_csv} ===="
    echo "format=${stats_format:-default}"
    echo "force_export=true"
} >>"${stats_path}"

stats_cmd=(nsys stats --force-export=true --report "${stats_reports_csv}")
if [[ -n "${stats_format}" ]]; then
    stats_cmd+=(--format "${stats_format}")
fi
stats_cmd+=("${report_path}")

if ! "${stats_cmd[@]}" >>"${stats_path}" 2>&1; then
    cat "${stats_path}" >&2
    echo "nsys profile succeeded but stats readback failed for reports: ${stats_reports_csv}" >&2
    echo "Inspect ${report_path} directly in Nsight Systems or set NSYS_STATS_REPORTS to reports supported by this install." >&2
    exit 1
fi

echo "Wrote ${report_path}"
echo "Wrote ${stats_path}"
