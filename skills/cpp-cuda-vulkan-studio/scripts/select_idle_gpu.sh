#!/usr/bin/env bash
set -euo pipefail

threshold="${GPU_IDLE_THRESHOLD:-5}"
sleep_seconds="${GPU_IDLE_RETRY_SECONDS:-30}"
max_attempts="${GPU_IDLE_MAX_ATTEMPTS:-0}"
allowed_indices="${GPU_ALLOWED_INDICES:-}"

if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "nvidia-smi is required for GPU selection" >&2
    exit 1
fi

gpu_index_allowed() {
    local candidate="$1"
    local normalized

    if [[ -z "${allowed_indices}" ]]; then
        return 0
    fi

    normalized="${allowed_indices//,/ }"
    normalized="${normalized//;/ }"
    for allowed in ${normalized}; do
        if [[ "${candidate}" == "${allowed}" ]]; then
            return 0
        fi
    done

    return 1
}

attempt=0
while true; do
    attempt=$((attempt + 1))
    if ! gpu_query_output="$(nvidia-smi --query-gpu=index,utilization.gpu --format=csv,noheader,nounits)"; then
        echo "nvidia-smi failed while querying GPU utilization" >&2
        exit 1
    fi
    mapfile -t gpu_rows <<<"${gpu_query_output}"
    pmon_output="$(nvidia-smi pmon -c 1 2>/dev/null || true)"

    seen_allowed=0
    for row in "${gpu_rows[@]}"; do
        index="$(awk -F, '{gsub(/ /, "", $1); print $1}' <<<"${row}")"
        util="$(awk -F, '{gsub(/ /, "", $2); print $2}' <<<"${row}")"
        if [[ -z "${index}" || -z "${util}" ]]; then
            continue
        fi
        if ! gpu_index_allowed "${index}"; then
            continue
        fi
        seen_allowed=1
        display_util="$(awk -v gpu="${index}" '
            $1 == gpu && ($NF == "Xorg" || $NF == "Xwayland") {
                if ($4 ~ /^[0-9]+$/) total += $4
            }
            END { print total + 0 }
        ' <<<"${pmon_output}")"
        effective=$((util - display_util))
        if (( effective < 0 )); then
            effective=0
        fi
        if (( effective <= threshold )); then
            echo "${index}"
            exit 0
        fi
    done

    if [[ -n "${allowed_indices}" && "${seen_allowed}" == "0" ]]; then
        echo "none of GPU_ALLOWED_INDICES (${allowed_indices}) were reported by nvidia-smi" >&2
        exit 1
    fi

    if (( max_attempts > 0 && attempt >= max_attempts )); then
        echo "no idle GPU found after ${attempt} attempts" >&2
        exit 1
    fi

    sleep "${sleep_seconds}"
done
