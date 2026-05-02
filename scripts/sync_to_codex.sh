#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
CODEX_HOME_DIR="${SYNC_CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${TARGET_DIR:-${CODEX_HOME_DIR}/skills/${SKILL_NAME}}"
VALIDATOR="${VALIDATOR:-${CODEX_HOME_DIR}/skills/.system/skill-creator/scripts/quick_validate.py}"
EXPECTED_TARGET_DIR="${CODEX_HOME_DIR}/skills/${SKILL_NAME}"

dry_run=0
delete_args=(--delete)

require_python310() {
    python3 - <<'PY'
import sys

if sys.version_info < (3, 10):
    raise SystemExit(
        "Python 3.10+ is required; found "
        f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    )
PY
}

usage() {
    cat <<EOF
Usage: $0 [--dry-run] [--no-delete]

Sync ${SOURCE_DIR} to ${TARGET_DIR}.

Environment:
  SYNC_CODEX_HOME  Defaults to ${HOME}/.codex
  TARGET_DIR       Override the exact installed skill directory
  VALIDATOR        Override quick_validate.py path
  ALLOW_SYNC_TARGET_OVERRIDE=1
                  Allow TARGET_DIR outside ${EXPECTED_TARGET_DIR}. Refuses dangerous paths even
                  with this override.

Note:
  This repo publishes the user-level skill copy by default. Nested Codex sessions may set
  CODEX_HOME to an isolated home, so this script intentionally ignores CODEX_HOME unless
  TARGET_DIR or SYNC_CODEX_HOME is provided explicitly.
EOF
}

while (($# > 0)); do
    case "$1" in
        --dry-run)
            dry_run=1
            ;;
        --no-delete)
            delete_args=()
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

if [[ ! -f "${SOURCE_DIR}/SKILL.md" ]]; then
    echo "Missing source skill: ${SOURCE_DIR}/SKILL.md" >&2
    exit 1
fi

require_python310

if [[ ! -x "${VALIDATOR}" && ! -f "${VALIDATOR}" ]]; then
    echo "Missing skill validator: ${VALIDATOR}" >&2
    exit 1
fi

target_resolved="$(realpath -m "${TARGET_DIR}")"
expected_resolved="$(realpath -m "${EXPECTED_TARGET_DIR}")"
root_resolved="$(realpath -m "${ROOT_DIR}")"
source_resolved="$(realpath -m "${SOURCE_DIR}")"
home_resolved="$(realpath -m "${HOME}")"
codex_home_resolved="$(realpath -m "${CODEX_HOME_DIR}")"
codex_skills_resolved="$(realpath -m "${CODEX_HOME_DIR}/skills")"

if [[ -L "${CODEX_HOME_DIR}/skills" ]]; then
    echo "Refusing symlinked Codex skills root: ${CODEX_HOME_DIR}/skills" >&2
    exit 1
fi

if [[ -L "${TARGET_DIR}" ]]; then
    echo "Refusing symlinked TARGET_DIR for rsync --delete: ${TARGET_DIR}" >&2
    exit 1
fi

if [[ "${target_resolved}" != "${expected_resolved}" && "${ALLOW_SYNC_TARGET_OVERRIDE:-0}" != "1" ]]; then
    echo "Refusing sync with TARGET_DIR outside the installed skill path:" >&2
    echo "  TARGET_DIR=${TARGET_DIR}" >&2
    echo "  expected=${EXPECTED_TARGET_DIR}" >&2
    echo "Set ALLOW_SYNC_TARGET_OVERRIDE=1 only for deliberate staging targets." >&2
    exit 1
fi

if [[ "${target_resolved}" != */skills/"${SKILL_NAME}" ]]; then
    echo "Refusing TARGET_DIR that is not an exact skill directory ending in skills/${SKILL_NAME}:" >&2
    echo "  TARGET_DIR=${TARGET_DIR}" >&2
    exit 1
fi

case "${target_resolved}" in
    "/"|"${home_resolved}"|"${codex_home_resolved}"|"${codex_skills_resolved}"|"${root_resolved}"|"${source_resolved}")
        echo "Refusing dangerous TARGET_DIR for rsync --delete: ${TARGET_DIR}" >&2
        exit 1
        ;;
    "${root_resolved}"/*)
        echo "Refusing TARGET_DIR inside this repo: ${TARGET_DIR}" >&2
        exit 1
        ;;
esac

if [[ -e "${target_resolved}" && ! -d "${target_resolved}" ]]; then
    echo "Refusing TARGET_DIR that exists but is not a directory: ${TARGET_DIR}" >&2
    exit 1
fi

if [[ -d "${target_resolved}" ]]; then
    if find "${target_resolved}" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
        if [[ ! -f "${target_resolved}/SKILL.md" ]]; then
            echo "Refusing to sync into non-empty directory without SKILL.md: ${TARGET_DIR}" >&2
            exit 1
        fi
        if ! grep -Eq "^name:[[:space:]]*['\"]?${SKILL_NAME}['\"]?[[:space:]]*$" "${target_resolved}/SKILL.md"; then
            echo "Refusing to sync into directory whose SKILL.md is not ${SKILL_NAME}: ${TARGET_DIR}" >&2
            exit 1
        fi
    fi
fi

python3 "${VALIDATOR}" "${SOURCE_DIR}"

if (( ! dry_run )); then
    mkdir -p "$(dirname "${TARGET_DIR}")"
fi

rsync_args=(
    -a
    --omit-dir-times
    "${delete_args[@]}"
    --exclude "__pycache__/"
    --exclude "*.pyc"
    --exclude ".DS_Store"
)

if (( dry_run )); then
    rsync_args+=(--dry-run --itemize-changes)
fi

rsync "${rsync_args[@]}" "${SOURCE_DIR}/" "${TARGET_DIR}/"

if (( ! dry_run )); then
    find "${TARGET_DIR}/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true
    python3 "${VALIDATOR}" "${TARGET_DIR}"
    echo "Synced ${SOURCE_DIR} -> ${TARGET_DIR}"
else
    echo "Dry run complete for ${SOURCE_DIR} -> ${TARGET_DIR}"
fi
