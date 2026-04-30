#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
SYNC_SCRIPT="${ROOT_DIR}/scripts/sync_to_codex.sh"

if ! command -v inotifywait >/dev/null 2>&1; then
    echo "inotifywait is required for watch mode" >&2
    exit 1
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Missing source skill directory: ${SOURCE_DIR}" >&2
    exit 1
fi

"${SYNC_SCRIPT}"

echo "Watching ${SOURCE_DIR}"
while true; do
    inotifywait -r -q \
        -e close_write,create,delete,move,attrib \
        --exclude '(__pycache__|\\.pyc$|~$|\\.swp$)' \
        "${SOURCE_DIR}" >/dev/null
    sleep 0.25
    "${SYNC_SCRIPT}"
done

