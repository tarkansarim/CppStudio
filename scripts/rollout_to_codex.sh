#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_NAME="${SKILL_NAME:-cpp-cuda-vulkan-studio}"
CODEX_HOME_DIR="${SYNC_CODEX_HOME:-${HOME}/.codex}"
SOURCE_DIR="${ROOT_DIR}/skills/${SKILL_NAME}"
TARGET_DIR="${TARGET_DIR:-${CODEX_HOME_DIR}/skills/${SKILL_NAME}}"
VALIDATOR="${VALIDATOR:-${CODEX_HOME_DIR}/skills/.system/skill-creator/scripts/quick_validate.py}"
DONOR_ROOT="${TARGET_DIR}/references/donor-library"
SNIPPET_ROOT="${ROOT_DIR}/companion-skill-snippets"
EXPECTED_TARGET_DIR="${CODEX_HOME_DIR}/skills/${SKILL_NAME}"
DONOR_VALIDATOR="${ROOT_DIR}/scripts/validate_donor_library.py"
COMPANION_INSTALLER="${ROOT_DIR}/scripts/install_companion_donor_links.py"
USER_AGENTS_RELAY_INSTALLER="${ROOT_DIR}/scripts/install_user_agents_relay.py"
USER_AGENTS_RELAY_SNIPPET="${SNIPPET_ROOT}/user-agents/cppstudio-relay.md"
USER_AGENTS_RELAY_TARGET="${USER_AGENTS_RELAY_TARGET:-${CODEX_HOME_DIR}/AGENTS.md}"

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
Usage: $0

Validate and roll out the CppStudio skill to user-level Codex, then install companion-skill donor
library links.

Environment:
  SYNC_CODEX_HOME  Defaults to ${HOME}/.codex
  TARGET_DIR       Override exact installed CppStudio skill directory
  VALIDATOR        Override quick_validate.py path
  ALLOW_ROLLOUT_TARGET_OVERRIDE=1
                  Allow TARGET_DIR outside ${EXPECTED_TARGET_DIR}. Companion-skill donor links will
                  point at TARGET_DIR, so use this only for deliberate staging.
  INSTALL_USER_AGENTS_RELAY=1
                  Merge the minimal CppStudio relay into USER_AGENTS_RELAY_TARGET.
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

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Missing source skill directory: ${SOURCE_DIR}" >&2
    exit 1
fi

require_python310

target_resolved="$(realpath -m "${TARGET_DIR}")"
expected_resolved="$(realpath -m "${EXPECTED_TARGET_DIR}")"

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

if [[ ! -f "${VALIDATOR}" && ! -x "${VALIDATOR}" ]]; then
    echo "Missing skill validator: ${VALIDATOR}" >&2
    exit 1
fi

if [[ ! -f "${DONOR_VALIDATOR}" ]]; then
    echo "Missing donor library validator: ${DONOR_VALIDATOR}" >&2
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
    "${SNIPPET_ROOT}/vulkan-compute-sync/donor-library.md" \
    "${SNIPPET_ROOT}/modern-cpp-cmake/donor-library.md" \
    "${USER_AGENTS_RELAY_SNIPPET}"
do
    if [[ ! -f "${snippet}" ]]; then
        echo "Missing companion snippet: ${snippet}" >&2
        exit 1
    fi
done

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

if [[ "${ALLOW_ROLLOUT_TARGET_OVERRIDE:-0}" == "1" ]]; then
    ALLOW_SYNC_TARGET_OVERRIDE=1 SYNC_CODEX_HOME="${CODEX_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" \
        VALIDATOR="${VALIDATOR}" "${ROOT_DIR}/scripts/sync_to_codex.sh"
else
    SYNC_CODEX_HOME="${CODEX_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" VALIDATOR="${VALIDATOR}" \
        "${ROOT_DIR}/scripts/sync_to_codex.sh"
fi

python3 "${DONOR_VALIDATOR}" "${DONOR_ROOT}" --reference-root "${TARGET_DIR}/references"
python3 "${COMPANION_INSTALLER}" \
    --install \
    "${companion_args[@]}" || {
        echo "Companion-skill install failed after main skill sync. The main skill may already be updated at ${TARGET_DIR}." >&2
        echo "Fix the companion install error and rerun ${ROOT_DIR}/scripts/rollout_to_codex.sh." >&2
        exit 1
    }

if [[ "${INSTALL_USER_AGENTS_RELAY:-0}" == "1" ]]; then
    python3 "${USER_AGENTS_RELAY_INSTALLER}" \
        --install \
        "${relay_args[@]}"
fi

python3 "${VALIDATOR}" "${TARGET_DIR}"
for companion in cuda-kernel-authoring vulkan-compute-sync modern-cpp-cmake; do
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

diff -qr "${SOURCE_DIR}" "${TARGET_DIR}" >/dev/null

echo "Rolled out ${SOURCE_DIR} -> ${TARGET_DIR}"
echo "Verified donor library at ${DONOR_ROOT}"
echo "Verified companion skill links for matching installed skills in ${CODEX_HOME_DIR}/skills"
