#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
AUXILIARY_SKILL_NAMES=("native-cpp-gui-hud" "cppstudio-project-planner" "agentic-control-harness" "viewport-session-testing" "important-instruction-ledger" "vulkan-compute-sync")
SNIPPET_ROOT="${ROOT_DIR}/companion-skill-snippets"
SYNC_SCRIPT="${ROOT_DIR}/scripts/sync_to_codex.sh"
ROLLOUT_SCRIPT="${ROOT_DIR}/scripts/rollout_to_codex.sh"
rollout=0

usage() {
    cat <<EOF
Usage: $0 [--rollout]

Watch and publish CppStudio skill edits.

  default    Watch only ${SOURCE_DIR} and run sync_to_codex.sh.
  --rollout  Watch ${SOURCE_DIR}, auxiliary bundled skills, and companion-skill snippets, then run
             rollout_to_codex.sh.

Use --rollout when editing donor-library companion snippets; normal sync does not update companion
skills.
EOF
}

while (($# > 0)); do
    case "$1" in
        --rollout)
            rollout=1
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

if ! command -v inotifywait >/dev/null 2>&1; then
    echo "inotifywait is required for watch mode" >&2
    exit 1
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Missing source skill directory: ${SOURCE_DIR}" >&2
    exit 1
fi

if (( rollout )); then
    if [[ ! -d "${SNIPPET_ROOT}" ]]; then
        echo "Missing companion snippet directory: ${SNIPPET_ROOT}" >&2
        exit 1
    fi
    run_script="${ROLLOUT_SCRIPT}"
    watch_dirs=("${SOURCE_DIR}" "${SNIPPET_ROOT}")
    for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
        auxiliary_source_dir="${ROOT_DIR}/skills/${auxiliary_skill_name}"
        if [[ ! -d "${auxiliary_source_dir}" ]]; then
            echo "Missing auxiliary source skill directory: ${auxiliary_source_dir}" >&2
            exit 1
        fi
        watch_dirs+=("${auxiliary_source_dir}")
    done
    echo "Rollout watch mode: companion snippets will be installed into user-level skills."
else
    run_script="${SYNC_SCRIPT}"
    watch_dirs=("${SOURCE_DIR}")
    echo "Skill-only watch mode: companion snippets are not rolled out. Use --rollout for snippet edits."
fi

"${run_script}"

echo "Watching ${watch_dirs[*]}"
while true; do
    inotifywait -r -q \
        -e close_write,create,delete,move,attrib \
        --exclude '(__pycache__|\\.pyc$|~$|\\.swp$)' \
        "${watch_dirs[@]}" >/dev/null
    sleep 0.25
    "${run_script}"
done
