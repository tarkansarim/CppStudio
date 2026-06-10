#!/usr/bin/env bash
set -euo pipefail

# Standalone audit of the installed CppStudio Claude lane (~/.claude/skills). Run any time to verify
# the deployed state without re-installing. Checks, per managed Claude skill:
#   - installed directory exists and is not a symlink (snapshot-install discipline)
#   - skill metadata validates (quick_validate_skill.py)
#   - package manifest validates (per-file SHA-256 -> detects post-install tampering)
#   - the copy is Claude-provider-specific (apply_claude_transform.py --check: no Codex host-paths,
#     transform idempotent)
# Plus the installed donor library and the absence of backup/staging debris inside the skills root.
#
# This validates the INSTALLED state only; source-repo validation stays in validate.sh.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/managed_claude_skills.sh
source "${ROOT_DIR}/scripts/managed_claude_skills.sh"
CLAUDE_HOME_DIR="${SYNC_CLAUDE_HOME:-${HOME}/.claude}"
SKILLS_ROOT="${CLAUDE_HOME_DIR}/skills"
VALIDATOR="${VALIDATOR:-${ROOT_DIR}/scripts/quick_validate_skill.py}"
PACKAGE_VALIDATOR="${ROOT_DIR}/scripts/validate_skill_package.py"
TRANSFORM="${ROOT_DIR}/scripts/apply_claude_transform.py"
DONOR_VALIDATOR="${ROOT_DIR}/scripts/validate_donor_library.py"

usage() {
    cat <<EOF
Usage: $0

Audit the installed CppStudio Claude lane at ${SKILLS_ROOT} (no changes made).

Environment:
  SYNC_CLAUDE_HOME  Defaults to ${HOME}/.claude
EOF
}

if (($# > 0)); then
    case "$1" in
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
    esac
fi

failures=0
fail() {
    echo "FAIL: $*" >&2
    failures=$((failures + 1))
}

all_skills=("${CPPSTUDIO_CLAUDE_MAIN_SKILL}" "${CPPSTUDIO_CLAUDE_AUXILIARY_SKILL_NAMES[@]}")

if [[ ! -d "${SKILLS_ROOT}" ]]; then
    echo "FAIL: Claude skills root missing: ${SKILLS_ROOT}" >&2
    exit 1
fi
if [[ -L "${SKILLS_ROOT}" ]]; then
    echo "FAIL: Claude skills root is a symlink: ${SKILLS_ROOT}" >&2
    exit 1
fi

for skill in "${all_skills[@]}"; do
    target="${SKILLS_ROOT}/${skill}"
    echo "== ${skill} =="
    if [[ ! -d "${target}" ]]; then
        fail "${skill}: not installed at ${target}"
        continue
    fi
    if [[ -L "${target}" ]]; then
        fail "${skill}: installed path is a symlink"
        continue
    fi
    python3 "${VALIDATOR}" "${target}" || fail "${skill}: skill metadata invalid"
    python3 "${PACKAGE_VALIDATOR}" "${target}" || fail "${skill}: package manifest mismatch (tampered or stale install)"
    python3 "${TRANSFORM}" --check "${target}" || fail "${skill}: not Claude-provider-specific"
done

donor_root="${SKILLS_ROOT}/${CPPSTUDIO_CLAUDE_MAIN_SKILL}/references/donor-library"
if [[ -d "${donor_root}" ]]; then
    python3 "${DONOR_VALIDATOR}" "${donor_root}" \
        --reference-root "${SKILLS_ROOT}/${CPPSTUDIO_CLAUDE_MAIN_SKILL}/references" \
        || fail "installed donor library invalid"
else
    fail "installed donor library missing: ${donor_root}"
fi

debris="$(find "${SKILLS_ROOT}" -maxdepth 2 \( -name "*.bak" -o -name "*.old" -o -name "*~" -o -name "*.orig" -o -name "*.backup.*" \) -print 2>/dev/null || true)"
if [[ -n "${debris}" ]]; then
    fail "backup/staging debris inside scanned skills root:"$'\n'"${debris}"
fi

if (( failures > 0 )); then
    echo "Claude install validation FAILED: ${failures} problem(s)." >&2
    exit 1
fi
echo "Claude install validation passed: ${#all_skills[@]} skills OK at ${SKILLS_ROOT}"
