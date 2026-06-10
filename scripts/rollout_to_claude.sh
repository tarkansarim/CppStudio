#!/usr/bin/env bash
set -euo pipefail

# Claude-lane rollout. Mirrors rollout_to_codex.sh but installs into ~/.claude/skills via the SEPARATE
# Claude lane (managed_claude_skills.sh, sync_to_claude.sh, Claude audit log). Per the
# provider-lane-separation doctrine this never touches ~/.codex.
#
# The ~/.claude/CLAUDE.md relay is intentionally NOT installed here: ~/.claude/CLAUDE.md is owned
# by the user's local doctrine tooling, so the relay block is routed through that tooling (slice 4),
# not written by this lane.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/managed_claude_skills.sh
source "${ROOT_DIR}/scripts/managed_claude_skills.sh"
SKILL_NAME="${SKILL_NAME:-${CPPSTUDIO_CLAUDE_MAIN_SKILL}}"
AUXILIARY_SKILL_NAMES=("${CPPSTUDIO_CLAUDE_AUXILIARY_SKILL_NAMES[@]}")
CLAUDE_HOME_DIR="${SYNC_CLAUDE_HOME:-${HOME}/.claude}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
TARGET_DIR="${TARGET_DIR:-${CLAUDE_HOME_DIR}/skills/${SKILL_NAME}}"
VALIDATOR="${VALIDATOR:-${ROOT_DIR}/scripts/quick_validate_skill.py}"
PACKAGE_VALIDATOR="${ROOT_DIR}/scripts/validate_skill_package.py"
DONOR_VALIDATOR="${ROOT_DIR}/scripts/validate_donor_library.py"
DONOR_ROOT="${TARGET_DIR}/references/donor-library"
EXPECTED_TARGET_DIR="${CLAUDE_HOME_DIR}/skills/${SKILL_NAME}"
AUDIT_LOG="${CPPSTUDIO_CLAUDE_AUDIT_LOG:-${CLAUDE_HOME_DIR}/cppstudio-claude-install-audit.jsonl}"
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
    raise SystemExit("Python 3.10+ is required")
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
action, skill_name = sys.argv[2], sys.argv[3]
repo_root = Path(sys.argv[4])
source_dir = Path(sys.argv[5])
target = sys.argv[6]
success = sys.argv[7].lower() in {"1", "true", "yes"}
message = sys.argv[8]

try:
    source_commit = subprocess.check_output(
        ["git", "-C", str(repo_root), "rev-parse", "--short=12", "HEAD"],
        text=True, stderr=subprocess.DEVNULL).strip()
except Exception:
    source_commit = None

manifest_path = source_dir / "package-manifest.json"
try:
    manifest_sha256 = hashlib.sha256(manifest_path.read_bytes()).hexdigest()
except OSError:
    manifest_sha256 = None

entry = {
    "schema_version": 1, "tool": "cppstudio", "lane": "claude", "action": action,
    "skill": skill_name, "success": success, "target": target,
    "source_commit": source_commit, "package_manifest_sha256": manifest_sha256,
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
    echo "Rolled back CppStudio Claude rollout after failure." >&2
    return "${exit_code}"
}

usage() {
    cat <<EOF
Usage: $0

Validate and roll out the CppStudio skill + slice-1 Claude auxiliary skills to user-level Claude
(~/.claude/skills). Separate lane from Codex; does not touch ~/.codex. The ~/.claude/CLAUDE.md relay
is handled separately via the user's local doctrine tooling and is NOT installed by this script.

Environment:
  SYNC_CLAUDE_HOME  Defaults to ${HOME}/.claude
  CPPSTUDIO_CLAUDE_AUDIT_LOG  Defaults to ${CLAUDE_HOME_DIR}/cppstudio-claude-install-audit.jsonl
EOF
}

if (($# > 0)); then
    case "$1" in
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
fi

trap audit_rollout_on_exit EXIT

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Missing source skill directory: ${SOURCE_DIR}" >&2
    exit 1
fi
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    if [[ ! -f "${ROOT_DIR}/skills/${auxiliary_skill_name}/SKILL.md" ]]; then
        echo "Missing auxiliary source skill: ${ROOT_DIR}/skills/${auxiliary_skill_name}/SKILL.md" >&2
        exit 1
    fi
done

require_python310

target_resolved="$(resolve_path "${TARGET_DIR}")"
expected_resolved="$(resolve_path "${EXPECTED_TARGET_DIR}")"
target_skills_dir="$(dirname "${target_resolved}")"

if [[ -L "${CLAUDE_HOME_DIR}/skills" ]]; then
    echo "Refusing symlinked Claude skills root: ${CLAUDE_HOME_DIR}/skills" >&2
    exit 1
fi
if [[ -L "${TARGET_DIR}" ]]; then
    echo "Refusing symlinked rollout TARGET_DIR: ${TARGET_DIR}" >&2
    exit 1
fi
if [[ "${target_resolved}" != "${expected_resolved}" && "${ALLOW_ROLLOUT_TARGET_OVERRIDE:-0}" != "1" ]]; then
    echo "Refusing rollout with TARGET_DIR outside the installed skill path." >&2
    exit 1
fi
if [[ "${target_resolved}" != */skills/"${SKILL_NAME}" ]]; then
    echo "Refusing rollout TARGET_DIR not ending in skills/${SKILL_NAME}: ${TARGET_DIR}" >&2
    exit 1
fi
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    reject_symlink_rollout_path "${target_skills_dir}/${auxiliary_skill_name}" "auxiliary skill target"
done

for required in "${VALIDATOR}" "${PACKAGE_VALIDATOR}" "${DONOR_VALIDATOR}"; do
    if [[ ! -f "${required}" && ! -x "${required}" ]]; then
        echo "Missing required validator: ${required}" >&2
        exit 1
    fi
done

# Validate the source repo first (skills metadata + syntax + package/donor/trigger integrity).
CPPSTUDIO_SKIP_ROLLOUT_VALIDATOR_REGRESSION=1 VALIDATOR="${VALIDATOR}" "${ROOT_DIR}/scripts/validate.sh"

ROLLBACK_TMP="$(mktemp -d "${TMPDIR:-/tmp}/cppstudio_claude_rollout_rollback.XXXXXX")"
backup_rollout_path "${target_resolved}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    backup_rollout_path "${target_skills_dir}/${auxiliary_skill_name}"
done
trap restore_rollout_backups ERR INT TERM

SYNC_CLAUDE_HOME="${CLAUDE_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_claude.sh"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    SYNC_CLAUDE_HOME="${CLAUDE_HOME_DIR}" \
        SKILL_NAME="${auxiliary_skill_name}" \
        TARGET_DIR="${target_skills_dir}/${auxiliary_skill_name}" \
        ALLOW_SYNC_TARGET_OVERRIDE=1 \
        VALIDATOR="${VALIDATOR}" \
        "${ROOT_DIR}/scripts/sync_to_claude.sh"
done

python3 "${DONOR_VALIDATOR}" "${DONOR_ROOT}" --reference-root "${TARGET_DIR}/references"

python3 "${VALIDATOR}" "${TARGET_DIR}"
python3 "${PACKAGE_VALIDATOR}" "${TARGET_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    auxiliary_target_dir="${target_skills_dir}/${auxiliary_skill_name}"
    python3 "${VALIDATOR}" "${auxiliary_target_dir}"
    python3 "${PACKAGE_VALIDATOR}" "${auxiliary_target_dir}"
done

# Claude-lane parity is NOT byte-identity with source. The source under skills/ is Codex-flavored and
# this lane installs source -> Claude provider transform (apply_claude_transform.py). Verify instead
# that each installed copy is fully Claude-specific: no host-provider Codex skill-home path survives
# and the transform is idempotent. (Internal integrity / no post-install tampering is covered by the
# package-manifest SHA validation above.)
python3 "${ROOT_DIR}/scripts/apply_claude_transform.py" --check "${TARGET_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    python3 "${ROOT_DIR}/scripts/apply_claude_transform.py" --check "${target_skills_dir}/${auxiliary_skill_name}"
done

rollout_transaction_complete=1
trap - ERR INT TERM
rm -rf "${ROLLBACK_TMP}"
write_cppstudio_audit "rollout" "true" "${TARGET_DIR}" "rolled out (claude lane, slice 1)"
rollout_audit_logged=1

echo "Rolled out (Claude lane) ${SOURCE_DIR} -> ${TARGET_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    echo "Rolled out (Claude lane) ${ROOT_DIR}/skills/${auxiliary_skill_name} -> ${target_skills_dir}/${auxiliary_skill_name}"
done
echo "Verified donor library at ${DONOR_ROOT}"
echo "NOTE: ~/.claude/CLAUDE.md relay is handled via the local doctrine tooling (slice 4), not by this script."
