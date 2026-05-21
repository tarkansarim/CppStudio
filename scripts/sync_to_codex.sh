#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
CODEX_HOME_DIR="${SYNC_CODEX_HOME:-${HOME}/.codex}"
TARGET_DIR="${TARGET_DIR:-${CODEX_HOME_DIR}/skills/${SKILL_NAME}}"
SYSTEM_VALIDATOR="${CODEX_HOME_DIR}/skills/.system/skill-creator/scripts/quick_validate.py"
REPO_VALIDATOR="${ROOT_DIR}/scripts/quick_validate_skill.py"
PACKAGE_VALIDATOR="${ROOT_DIR}/scripts/validate_skill_package.py"
if [[ -z "${VALIDATOR:-}" ]]; then
    if [[ -f "${SYSTEM_VALIDATOR}" || -x "${SYSTEM_VALIDATOR}" ]]; then
        VALIDATOR="${SYSTEM_VALIDATOR}"
    else
        VALIDATOR="${REPO_VALIDATOR}"
    fi
fi
EXPECTED_TARGET_DIR="${CODEX_HOME_DIR}/skills/${SKILL_NAME}"
AUDIT_LOG="${CPPSTUDIO_AUDIT_LOG:-${CODEX_HOME_DIR}/cppstudio-install-audit.jsonl}"

dry_run=0
delete_args=(--delete)
sync_tmp_parent=""
sync_backup_path=""
sync_tmp_root=""
sync_backup_root=""
sync_target_existed=0
sync_backup_created=0
sync_transaction_complete=0
sync_audit_logged=0

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

resolve_path() {
    python3 - "$1" <<'PY'
import sys
from pathlib import Path

print(Path(sys.argv[1]).expanduser().resolve(strict=False))
PY
}

is_within_path() {
    python3 - "$1" "$2" <<'PY'
import sys
from pathlib import Path

candidate = Path(sys.argv[1]).resolve(strict=False)
parent = Path(sys.argv[2]).resolve(strict=False)
try:
    candidate.relative_to(parent)
except ValueError:
    raise SystemExit(1)
raise SystemExit(0)
PY
}

write_cppstudio_audit() {
    local action="$1"
    local success="$2"
    local target="$3"
    local message="${4:-}"
    python3 - "${AUDIT_LOG}" "${action}" "${SKILL_NAME}" "${ROOT_DIR}" "${SOURCE_DIR}" "${target}" "${success}" "${message}" <<'PY' || true
import hashlib
import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

log_path = Path(sys.argv[1]).expanduser()
action = sys.argv[2]
skill_name = sys.argv[3]
repo_root = Path(sys.argv[4])
source_dir = Path(sys.argv[5])
target = sys.argv[6]
success = sys.argv[7].lower() in {"1", "true", "yes"}
message = sys.argv[8]

try:
    source_commit = subprocess.check_output(
        ["git", "-C", str(repo_root), "rev-parse", "--short=12", "HEAD"],
        text=True,
        stderr=subprocess.DEVNULL,
    ).strip()
except Exception:
    source_commit = None

manifest_path = source_dir / "package-manifest.json"
try:
    manifest_sha256 = hashlib.sha256(manifest_path.read_bytes()).hexdigest()
except OSError:
    manifest_sha256 = None

entry = {
    "schema_version": 1,
    "tool": "cppstudio",
    "action": action,
    "skill": skill_name,
    "success": success,
    "target": target,
    "source_commit": source_commit,
    "package_manifest_sha256": manifest_sha256,
    "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
}
if message:
    entry["message"] = message

log_path.parent.mkdir(parents=True, exist_ok=True)
with log_path.open("a", encoding="utf-8") as handle:
    handle.write(json.dumps(entry, sort_keys=True) + "\n")
PY
}

audit_sync_on_exit() {
    local exit_code=$?
    if (( exit_code != 0 && ! dry_run && ! sync_audit_logged )); then
        write_cppstudio_audit "sync" "false" "${TARGET_DIR}" "exit_code=${exit_code}"
    fi
}

usage() {
    cat <<EOF
Usage: $0 [--dry-run] [--no-delete]

Sync ${SOURCE_DIR} to ${TARGET_DIR}.

Environment:
  SYNC_CODEX_HOME  Defaults to ${HOME}/.codex
  TARGET_DIR       Override the exact installed skill directory
  VALIDATOR        Override quick_validate.py path. By default, use the target Codex system
                  validator when present, then the repo-local validator fallback.
  CPPSTUDIO_AUDIT_LOG
                  Optional JSONL audit log path. Defaults to
                  ${CODEX_HOME_DIR}/cppstudio-install-audit.jsonl for non-dry-run sync.
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

trap audit_sync_on_exit EXIT

if [[ ! -f "${SOURCE_DIR}/SKILL.md" ]]; then
    echo "Missing source skill: ${SOURCE_DIR}/SKILL.md" >&2
    exit 1
fi

require_python310

if [[ ! -x "${VALIDATOR}" && ! -f "${VALIDATOR}" ]]; then
    echo "Missing skill validator: ${VALIDATOR}" >&2
    exit 1
fi

if [[ ! -x "${PACKAGE_VALIDATOR}" && ! -f "${PACKAGE_VALIDATOR}" ]]; then
    echo "Missing package validator: ${PACKAGE_VALIDATOR}" >&2
    exit 1
fi

target_resolved="$(resolve_path "${TARGET_DIR}")"
expected_resolved="$(resolve_path "${EXPECTED_TARGET_DIR}")"
root_resolved="$(resolve_path "${ROOT_DIR}")"
source_resolved="$(resolve_path "${SOURCE_DIR}")"
home_resolved="$(resolve_path "${HOME}")"
codex_home_resolved="$(resolve_path "${CODEX_HOME_DIR}")"
codex_skills_resolved="$(resolve_path "${CODEX_HOME_DIR}/skills")"

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
python3 "${PACKAGE_VALIDATOR}" "${SOURCE_DIR}"

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

if (( dry_run )); then
    rsync "${rsync_args[@]}" "${SOURCE_DIR}/" "${TARGET_DIR}/"
    echo "Dry run complete for ${SOURCE_DIR} -> ${TARGET_DIR}"
else
    target_parent="$(dirname "${target_resolved}")"
    mkdir -p "${target_parent}"
    sync_tmp_root="${CPPSTUDIO_SYNC_TMP_ROOT:-${CODEX_HOME_DIR}/.cppstudio-sync-tmp}"
    sync_backup_root="${CPPSTUDIO_SYNC_BACKUP_ROOT:-${CODEX_HOME_DIR}/.cppstudio-skill-backups}"
    if is_within_path "${sync_tmp_root}" "${target_parent}" || is_within_path "${sync_backup_root}" "${target_parent}"; then
        echo "Refusing sync staging or backup root inside scanned Codex skills root:" >&2
        echo "  skills root=${target_parent}" >&2
        echo "  staging root=${sync_tmp_root}" >&2
        echo "  backup root=${sync_backup_root}" >&2
        exit 1
    fi
    mkdir -p "${sync_tmp_root}" "${sync_backup_root}"
    sync_tmp_parent="$(mktemp -d "${sync_tmp_root}/${SKILL_NAME}.sync.XXXXXX")"
    staged_target="${sync_tmp_parent}/${SKILL_NAME}"

    restore_sync_backup() {
        local exit_code=$?
        if (( sync_transaction_complete )); then
            return "${exit_code}"
        fi
        if (( sync_backup_created )); then
            rm -rf "${target_resolved}"
            mv "${sync_backup_path}" "${target_resolved}"
            echo "Restored previous skill after failed sync: ${TARGET_DIR}" >&2
        elif (( ! sync_target_existed )); then
            rm -rf "${target_resolved}"
        fi
        rm -rf "${sync_tmp_parent}"
        return "${exit_code}"
    }
    trap restore_sync_backup ERR INT TERM

    rsync "${rsync_args[@]}" "${SOURCE_DIR}/" "${staged_target}/"
    find "${staged_target}/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true
    python3 "${VALIDATOR}" "${staged_target}"
    python3 "${PACKAGE_VALIDATOR}" "${staged_target}"

    if [[ -e "${target_resolved}" ]]; then
        sync_target_existed=1
        sync_backup_path="${sync_backup_root}/${SKILL_NAME}.backup.$(date +%Y%m%d%H%M%S).$$"
        mv "${target_resolved}" "${sync_backup_path}"
        sync_backup_created=1
    fi
    mv "${staged_target}" "${target_resolved}"
    find "${TARGET_DIR}/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} + 2>/dev/null || true
    python3 "${VALIDATOR}" "${TARGET_DIR}"
    python3 "${PACKAGE_VALIDATOR}" "${TARGET_DIR}"
    sync_transaction_complete=1
    trap - ERR INT TERM
    rm -rf "${sync_backup_path}" "${sync_tmp_parent}"
    write_cppstudio_audit "sync" "true" "${TARGET_DIR}" "synced"
    sync_audit_logged=1
    echo "Synced ${SOURCE_DIR} -> ${TARGET_DIR}"
fi
