#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
AUXILIARY_SKILL_NAMES=("native-cpp-gui-hud" "cppstudio-project-planner" "agentic-control-harness" "viewport-session-testing" "important-instruction-ledger" "vulkan-compute-sync")
CODEX_HOME_DIR="${SYNC_CODEX_HOME:-${HOME}/.codex}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
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
DONOR_ROOT="${TARGET_DIR}/references/donor-library"
SNIPPET_ROOT="${ROOT_DIR}/companion-skill-snippets"
EXPECTED_TARGET_DIR="${CODEX_HOME_DIR}/skills/${SKILL_NAME}"
AUDIT_LOG="${CPPSTUDIO_AUDIT_LOG:-${CODEX_HOME_DIR}/cppstudio-install-audit.jsonl}"
DONOR_VALIDATOR="${ROOT_DIR}/scripts/validate_donor_library.py"
COMPANION_INSTALLER="${ROOT_DIR}/scripts/install_companion_donor_links.py"
USER_AGENTS_RELAY_INSTALLER="${ROOT_DIR}/scripts/install_user_agents_relay.py"
USER_AGENTS_RELAY_SNIPPET="${SNIPPET_ROOT}/user-agents/cppstudio-relay.md"
USER_AGENTS_RELAY_TARGET="${USER_AGENTS_RELAY_TARGET:-${CODEX_HOME_DIR}/AGENTS.md}"
INSTALL_USER_AGENTS_RELAY="${INSTALL_USER_AGENTS_RELAY:-1}"
if [[ "${SKIP_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    INSTALL_USER_AGENTS_RELAY=0
fi
ROLLBACK_TMP=""
rollback_paths=()
rollback_backups=()
rollback_existed=()
rollout_transaction_complete=0
rollout_audit_logged=0

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

reject_symlink_rollout_path() {
    local path="$1"
    local label="$2"
    if [[ -L "${path}" ]]; then
        echo "Refusing symlinked ${label}: ${path}" >&2
        exit 1
    fi
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

audit_rollout_on_exit() {
    local exit_code=$?
    if (( exit_code != 0 && ! rollout_audit_logged )); then
        write_cppstudio_audit "rollout" "false" "${TARGET_DIR}" "exit_code=${exit_code}"
    fi
}

backup_rollout_path() {
    local path="$1"
    local backup_path="${ROLLBACK_TMP}/item_${#rollback_paths[@]}"
    reject_symlink_rollout_path "${path}" "rollout rollback target"
    rollback_paths+=("${path}")
    rollback_backups+=("${backup_path}")
    if [[ -e "${path}" ]]; then
        rollback_existed+=("1")
        cp -a "${path}" "${backup_path}"
    else
        rollback_existed+=("0")
    fi
}

restore_rollout_backups() {
    local exit_code=$?
    local index
    if (( rollout_transaction_complete )); then
        return "${exit_code}"
    fi
    for (( index=${#rollback_paths[@]} - 1; index >= 0; index-- )); do
        local path="${rollback_paths[index]}"
        local backup_path="${rollback_backups[index]}"
        if [[ "${rollback_existed[index]}" == "1" ]]; then
            rm -rf "${path}"
            mkdir -p "$(dirname "${path}")"
            mv "${backup_path}" "${path}"
        else
            rm -rf "${path}"
        fi
    done
    rm -rf "${ROLLBACK_TMP}"
    echo "Rolled back CppStudio rollout after failure." >&2
    return "${exit_code}"
}

usage() {
    cat <<EOF
Usage: $0

Validate and roll out the CppStudio skill to user-level Codex, then install companion-skill donor
library links.

Environment:
  SYNC_CODEX_HOME  Defaults to ${HOME}/.codex
  TARGET_DIR       Override exact installed CppStudio skill directory
  VALIDATOR        Override quick_validate.py path. By default, use the target Codex system
                  validator when present, then the repo-local validator fallback.
  CPPSTUDIO_AUDIT_LOG
                  Optional JSONL audit log path. Defaults to
                  ${CODEX_HOME_DIR}/cppstudio-install-audit.jsonl.
  ALLOW_ROLLOUT_TARGET_OVERRIDE=1
                  Allow TARGET_DIR outside ${EXPECTED_TARGET_DIR}. Companion-skill donor links will
                  point at TARGET_DIR, so use this only for deliberate staging.
  INSTALL_USER_AGENTS_RELAY
                  Defaults to 1. Merge the minimal CppStudio relay into USER_AGENTS_RELAY_TARGET.
  SKIP_USER_AGENTS_RELAY=1
                  Opt out of installing or updating the user-level AGENTS.md relay.
  USER_AGENTS_RELAY_TARGET
                  Defaults to ${CODEX_HOME_DIR}/AGENTS.md when relay install is enabled.
  ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1
                  Allow USER_AGENTS_RELAY_TARGET to differ from ${CODEX_HOME_DIR}/AGENTS.md.
                  The target must still be named AGENTS.md and must not be a symlink.
  STRICT_COMPANION_SKILLS=1
                  Require all known companion skills to exist. By default, rollout updates only
                  matching installed companion skills and skips missing optional companions.
EOF
}

if (($# > 0)); then
    case "$1" in
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
fi

trap audit_rollout_on_exit EXIT

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Missing source skill directory: ${SOURCE_DIR}" >&2
    exit 1
fi
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    auxiliary_source_dir="${ROOT_DIR}/skills/${auxiliary_skill_name}"
    if [[ ! -f "${auxiliary_source_dir}/SKILL.md" ]]; then
        echo "Missing auxiliary source skill: ${auxiliary_source_dir}/SKILL.md" >&2
        exit 1
    fi
done

require_python310

target_resolved="$(resolve_path "${TARGET_DIR}")"
expected_resolved="$(resolve_path "${EXPECTED_TARGET_DIR}")"
target_skills_dir="$(dirname "${target_resolved}")"

if [[ -L "${CODEX_HOME_DIR}/skills" ]]; then
    echo "Refusing symlinked Codex skills root: ${CODEX_HOME_DIR}/skills" >&2
    exit 1
fi

if [[ -L "${TARGET_DIR}" ]]; then
    echo "Refusing symlinked rollout TARGET_DIR: ${TARGET_DIR}" >&2
    exit 1
fi

if [[ "${target_resolved}" != "${expected_resolved}" && "${ALLOW_ROLLOUT_TARGET_OVERRIDE:-0}" != "1" ]]; then
    echo "Refusing rollout with TARGET_DIR outside the installed skill path:" >&2
    echo "  TARGET_DIR=${TARGET_DIR}" >&2
    echo "  expected=${EXPECTED_TARGET_DIR}" >&2
    echo "Set ALLOW_ROLLOUT_TARGET_OVERRIDE=1 only if companion links should point at that target." >&2
    exit 1
fi

if [[ "${target_resolved}" != */skills/"${SKILL_NAME}" ]]; then
    echo "Refusing rollout TARGET_DIR that is not an exact skill directory ending in skills/${SKILL_NAME}:" >&2
    echo "  TARGET_DIR=${TARGET_DIR}" >&2
    exit 1
fi

for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    reject_symlink_rollout_path \
        "${target_skills_dir}/${auxiliary_skill_name}" \
        "auxiliary skill target"
done
for companion in cuda-kernel-authoring modern-cpp-cmake; do
    reject_symlink_rollout_path \
        "${CODEX_HOME_DIR}/skills/${companion}" \
        "companion skill directory"
    reject_symlink_rollout_path \
        "${CODEX_HOME_DIR}/skills/${companion}/SKILL.md" \
        "companion skill file"
done
if [[ "${INSTALL_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    reject_symlink_rollout_path "${USER_AGENTS_RELAY_TARGET}" "user AGENTS relay target"
fi

if [[ ! -f "${VALIDATOR}" && ! -x "${VALIDATOR}" ]]; then
    echo "Missing skill validator: ${VALIDATOR}" >&2
    exit 1
fi

if [[ ! -f "${DONOR_VALIDATOR}" ]]; then
    echo "Missing donor library validator: ${DONOR_VALIDATOR}" >&2
    exit 1
fi

if [[ ! -x "${PACKAGE_VALIDATOR}" && ! -f "${PACKAGE_VALIDATOR}" ]]; then
    echo "Missing package validator: ${PACKAGE_VALIDATOR}" >&2
    exit 1
fi

if [[ ! -f "${COMPANION_INSTALLER}" ]]; then
    echo "Missing companion installer: ${COMPANION_INSTALLER}" >&2
    exit 1
fi

if [[ ! -f "${USER_AGENTS_RELAY_INSTALLER}" ]]; then
    echo "Missing user AGENTS relay installer: ${USER_AGENTS_RELAY_INSTALLER}" >&2
    exit 1
fi

for snippet in \
    "${SNIPPET_ROOT}/cuda-kernel-authoring/donor-library.md" \
    "${SNIPPET_ROOT}/modern-cpp-cmake/donor-library.md" \
    "${USER_AGENTS_RELAY_SNIPPET}"
do
    if [[ ! -f "${snippet}" ]]; then
        echo "Missing companion snippet: ${snippet}" >&2
        exit 1
    fi
done

CPPSTUDIO_SKIP_ROLLOUT_VALIDATOR_REGRESSION=1 \
    SYNC_CODEX_HOME="${CODEX_HOME_DIR}" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/validate.sh"
companion_args=(
    --codex-home "${CODEX_HOME_DIR}"
    --donor-root "${DONOR_ROOT}"
    --source-skill-dir "${SOURCE_DIR}"
    --snippet-root "${SNIPPET_ROOT}"
)
if [[ "${STRICT_COMPANION_SKILLS:-0}" == "1" ]]; then
    companion_args+=(--strict)
fi

python3 "${COMPANION_INSTALLER}" \
    --preflight \
    "${companion_args[@]}"

relay_args=(
    --target "${USER_AGENTS_RELAY_TARGET}"
    --snippet "${USER_AGENTS_RELAY_SNIPPET}"
    --expected-target "${CODEX_HOME_DIR}/AGENTS.md"
)
if [[ "${ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE:-0}" == "1" ]]; then
    relay_args+=(--allow-target-override)
fi

if [[ "${INSTALL_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    python3 "${USER_AGENTS_RELAY_INSTALLER}" \
        --preflight \
        "${relay_args[@]}"
fi

ROLLBACK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/cppstudio_rollout_rollback.XXXXXX")"
backup_rollout_path "${target_resolved}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    backup_rollout_path "${target_skills_dir}/${auxiliary_skill_name}"
done
for companion in cuda-kernel-authoring modern-cpp-cmake; do
    companion_skill="${CODEX_HOME_DIR}/skills/${companion}/SKILL.md"
    if [[ -e "${companion_skill}" ]]; then
        backup_rollout_path "${companion_skill}"
    fi
done
if [[ "${INSTALL_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    backup_rollout_path "${USER_AGENTS_RELAY_TARGET}"
fi
trap restore_rollout_backups ERR INT TERM

if [[ "${ALLOW_ROLLOUT_TARGET_OVERRIDE:-0}" == "1" ]]; then
    ALLOW_SYNC_TARGET_OVERRIDE=1 SYNC_CODEX_HOME="${CODEX_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" \
        VALIDATOR="${VALIDATOR}" "${ROOT_DIR}/scripts/sync_to_codex.sh"
else
    SYNC_CODEX_HOME="${CODEX_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" VALIDATOR="${VALIDATOR}" \
        "${ROOT_DIR}/scripts/sync_to_codex.sh"
fi
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    SYNC_CODEX_HOME="${CODEX_HOME_DIR}" \
        SKILL_NAME="${auxiliary_skill_name}" \
        TARGET_DIR="${target_skills_dir}/${auxiliary_skill_name}" \
        ALLOW_SYNC_TARGET_OVERRIDE=1 \
        VALIDATOR="${VALIDATOR}" \
        "${ROOT_DIR}/scripts/sync_to_codex.sh"
done

python3 "${DONOR_VALIDATOR}" "${DONOR_ROOT}" --reference-root "${TARGET_DIR}/references"
python3 "${COMPANION_INSTALLER}" \
    --install \
    "${companion_args[@]}"

if [[ "${INSTALL_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    python3 "${USER_AGENTS_RELAY_INSTALLER}" \
        --install \
        "${relay_args[@]}"
fi

python3 "${VALIDATOR}" "${TARGET_DIR}"
python3 "${PACKAGE_VALIDATOR}" "${TARGET_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    auxiliary_target_dir="${target_skills_dir}/${auxiliary_skill_name}"
    python3 "${VALIDATOR}" "${auxiliary_target_dir}"
    python3 "${PACKAGE_VALIDATOR}" "${auxiliary_target_dir}"
done
for companion in cuda-kernel-authoring modern-cpp-cmake; do
    companion_dir="${CODEX_HOME_DIR}/skills/${companion}"
    if [[ -d "${companion_dir}" ]]; then
        python3 "${VALIDATOR}" "${companion_dir}"
    elif [[ "${STRICT_COMPANION_SKILLS:-0}" == "1" ]]; then
        echo "Missing required companion skill: ${companion_dir}" >&2
        exit 1
    else
        echo "Skipped missing companion skill: ${companion_dir}"
    fi
done

diff -qr \
    --exclude "__pycache__" \
    --exclude "*.pyc" \
    --exclude ".DS_Store" \
    "${SOURCE_DIR}" "${TARGET_DIR}" >/dev/null
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    diff -qr \
        --exclude "__pycache__" \
        --exclude "*.pyc" \
        --exclude ".DS_Store" \
        "${ROOT_DIR}/skills/${auxiliary_skill_name}" "${target_skills_dir}/${auxiliary_skill_name}" >/dev/null
done
rollout_transaction_complete=1
trap - ERR INT TERM
rm -rf "${ROLLBACK_TMP}"
write_cppstudio_audit "rollout" "true" "${TARGET_DIR}" "rolled out"
rollout_audit_logged=1

echo "Rolled out ${SOURCE_DIR} -> ${TARGET_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    echo "Rolled out ${ROOT_DIR}/skills/${auxiliary_skill_name} -> ${target_skills_dir}/${auxiliary_skill_name}"
done
echo "Verified donor library at ${DONOR_ROOT}"
echo "Verified companion skill links for matching installed skills in ${CODEX_HOME_DIR}/skills"
