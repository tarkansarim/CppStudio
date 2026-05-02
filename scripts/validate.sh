#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${ROOT_DIR}/skills/cpp-cuda-vulkan-studio"
VALIDATOR="${VALIDATOR:-${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py}"
full=0
VALIDATE_TMP="$(mktemp -d "${TMPDIR:-/tmp}/cppstudio_validate.XXXXXX")"

cleanup_validate_tmp() {
    if [[ "${KEEP_VALIDATE_TMP:-0}" == "1" ]]; then
        echo "Preserved validation temp directory at ${VALIDATE_TMP}"
    else
        rm -rf "${VALIDATE_TMP}"
    fi
}
trap cleanup_validate_tmp EXIT

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
Usage: $0 [--full]

Validate the canonical CppStudio skill.

  default  Skill metadata, Python syntax, and shell syntax.
  --full   Also scaffold a temporary sample project and run CMake/CTest CPU, Vulkan, CUDA,
           mixed CUDA/Vulkan, and sanitizer quick lanes.
EOF
}

while (($# > 0)); do
    case "$1" in
        --full)
            full=1
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

if [[ ! -f "${SKILL_DIR}/SKILL.md" ]]; then
    echo "Missing skill: ${SKILL_DIR}" >&2
    exit 1
fi

require_python310

required_repo_files=(
    "scripts/install_companion_donor_links.py"
    "scripts/install_user_agents_relay.py"
    "scripts/quick_validate_skill.py"
    "companion-skill-snippets/user-agents/cppstudio-relay.md"
    "research/donor-library/trigger-regression-checklist.md"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/.gitignore"
)
for rel_path in "${required_repo_files[@]}"; do
    if [[ ! -e "${ROOT_DIR}/${rel_path}" ]]; then
        echo "Missing required package file: ${rel_path}" >&2
        exit 1
    fi
done
if git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    for rel_path in "${required_repo_files[@]}"; do
        if ! git -C "${ROOT_DIR}" ls-files --error-unmatch "${rel_path}" >/dev/null 2>&1; then
            echo "Required package file is not tracked by git: ${rel_path}" >&2
            exit 1
        fi
    done
    maintainer_path_pattern="/home/tar""kan"
    maintainer_path_hits="$(
        git -C "${ROOT_DIR}" grep -n "${maintainer_path_pattern}" -- \
            "*.md" "*.py" "*.sh" "*.json" "*.yml" "*.yaml" "*.txt" || true
    )"
    if [[ -n "${maintainer_path_hits}" ]]; then
        printf "%s\n" "${maintainer_path_hits}" >&2
        echo "Maintainer-local absolute paths must not be shipped in tracked public text" >&2
        exit 1
    fi
    private_provenance_hits=""
    private_provenance_patterns=(
        "Cuda""Groom""Tool"
        "Comfy""Native"
        "cuda""groom"
        "RT_""RESTART"
        "HAIR_""RENDER_""UPGRADE"
        ".codex/skills/""rt-"
        "unreal-hair-""reference"
        "unity-hair-""reference"
    )
    for private_pattern in "${private_provenance_patterns[@]}"; do
        pattern_hits="$(
            git -C "${ROOT_DIR}" grep -ni -- "${private_pattern}" -- \
                "*.md" "*.py" "*.sh" "*.json" "*.yml" "*.yaml" "*.txt" || true
        )"
        if [[ -n "${pattern_hits}" ]]; then
            private_provenance_hits+="${pattern_hits}"$'\n'
        fi
    done
    private_filename_regex="cuda""groom|RT_""RESTART|HAIR_""RENDER_""UPGRADE|unreal-hair-""reference|unity-hair-""reference"
    private_filename_hits="$(git -C "${ROOT_DIR}" ls-files | grep -Ei "${private_filename_regex}" || true)"
    if [[ -n "${private_filename_hits}" ]]; then
        private_provenance_hits+="${private_filename_hits}"$'\n'
    fi
    if [[ -n "${private_provenance_hits}" ]]; then
        printf "%s" "${private_provenance_hits}" >&2
        echo "Private maintainer-project provenance must not be shipped in tracked public text or filenames" >&2
        exit 1
    fi
fi

expect_failure() {
    local description="$1"
    local expected="$2"
    shift
    shift
    local output_file
    output_file="$(mktemp "${VALIDATE_TMP}/expect_failure.XXXXXX")"
    if "$@" >"${output_file}" 2>&1; then
        cat "${output_file}" >&2
        echo "Expected failure passed unexpectedly: ${description}" >&2
        exit 1
    fi
    if grep -q "Traceback" "${output_file}"; then
        cat "${output_file}" >&2
        echo "Expected failure produced a Python traceback: ${description}" >&2
        exit 1
    fi
    if ! grep -Fq "${expected}" "${output_file}"; then
        cat "${output_file}" >&2
        echo "Expected failure did not contain diagnostic '${expected}': ${description}" >&2
        exit 1
    fi
}

write_companion_fixtures() {
    local codex_home="$1"
    rm -rf \
        "${codex_home}/skills/cuda-kernel-authoring" \
        "${codex_home}/skills/vulkan-compute-sync" \
        "${codex_home}/skills/modern-cpp-cmake"
    mkdir -p \
        "${codex_home}/skills/cuda-kernel-authoring" \
        "${codex_home}/skills/vulkan-compute-sync" \
        "${codex_home}/skills/modern-cpp-cmake"
    cat >"${codex_home}/skills/cuda-kernel-authoring/SKILL.md" <<'EOF'
---
name: cuda-kernel-authoring
description: Test fixture.
---
# CUDA Kernel Authoring
## Design Rules
EOF
    cat >"${codex_home}/skills/vulkan-compute-sync/SKILL.md" <<'EOF'
---
name: vulkan-compute-sync
description: Test fixture.
---
# Vulkan Compute Sync
## Compute Pipeline Checklist
EOF
    cat >"${codex_home}/skills/modern-cpp-cmake/SKILL.md" <<'EOF'
---
name: modern-cpp-cmake
description: Test fixture.
---
# Modern Cpp CMake
## Renderer Bootstrap
EOF
}

python3 "${VALIDATOR}" "${SKILL_DIR}"
if [[ -d "${ROOT_DIR}/.codex/skills" ]]; then
    while IFS= read -r -d '' project_skill; do
        python3 "${VALIDATOR}" "${project_skill}"
    done < <(find "${ROOT_DIR}/.codex/skills" -mindepth 1 -maxdepth 1 -type d -print0)
fi
python3 -m py_compile "${ROOT_DIR}"/scripts/*.py "${SKILL_DIR}"/scripts/*.py
python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${SKILL_DIR}/references/donor-library" \
    --reference-root "${SKILL_DIR}/references"
python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}"
python3 - "${SKILL_DIR}/assets/app-library-template/.github/workflows/gpu-cpp.yml" <<'PY'
import sys
from pathlib import Path

workflow = Path(sys.argv[1]).read_text(encoding="utf-8")
expected_conditions = {
    "toolcheck": "github.event_name == 'push' || github.event_name == 'pull_request'",
    "build-dev": "github.event_name == 'push' || github.event_name == 'pull_request'",
    "quick-tests": "github.event_name == 'push' || github.event_name == 'pull_request'",
    "gpu-smoke": "github.event_name == 'push' || github.event_name == 'pull_request' || github.event_name == 'workflow_dispatch'",
    "vulkan-shader": "github.event_name == 'push' || github.event_name == 'pull_request'",
    "vulkan-runtime": "github.event_name == 'push' || github.event_name == 'pull_request' || github.event_name == 'workflow_dispatch'",
    "vulkan-validation": "github.event_name == 'workflow_dispatch' || github.event_name == 'schedule'",
    "compute-sanitizer": "github.event_name == 'workflow_dispatch' || github.event_name == 'schedule'",
    "profile-smoke": "github.event_name == 'workflow_dispatch' || github.event_name == 'schedule'",
}
missing = [
    job for job, condition in expected_conditions.items()
    if f"  {job}:\n    if: {condition}\n" not in workflow
]
if missing:
    raise SystemExit("workflow jobs missing expected event guards: " + ", ".join(missing))
PY
trigger_lookup_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_lookup.XXXXXX.md")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --tag lookup >"${trigger_lookup_md}"
grep -q "agent-lookup.md" "${trigger_lookup_md}"
for trigger_tag in dcc materials volumes vfx games infrastructure; do
    trigger_tag_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_${trigger_tag}.XXXXXX.md")"
    python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
        "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
        --repo-root "${ROOT_DIR}" \
        --tag "${trigger_tag}" >"${trigger_tag_md}"
    case "${trigger_tag}" in
        vfx)
            grep -q "production/vfx-studio.md" "${trigger_tag_md}"
            ;;
        games)
            grep -q "production/games.md" "${trigger_tag_md}"
            ;;
        infrastructure)
            grep -q "native-engineering-infrastructure.md" "${trigger_tag_md}"
            ;;
        *)
            grep -q "${trigger_tag}" "${trigger_tag_md}"
            ;;
    esac
done
trigger_negative_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_negative.XXXXXX.md")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --tag negative \
    --installed-paths \
    --codex-home "${ROOT_DIR}/.codex-eval" >"${trigger_negative_md}"
grep -q "${ROOT_DIR}/.codex-eval/skills/cpp-cuda-vulkan-studio" "${trigger_negative_md}"
expect_failure "unknown trigger eval tag" "unknown trigger tag" \
    python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --tag not-a-real-tag
python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u "${VALIDATE_TMP}/agents_relay.XXXXXX")/AGENTS.md" \
    --expected-target "$(mktemp -u "${VALIDATE_TMP}/agents_relay.XXXXXX")/AGENTS.md" \
    --allow-target-override \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
expect_failure "relay target without expected target" "the following arguments are required: --expected-target" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u "${VALIDATE_TMP}/agents_relay_no_expected.XXXXXX")/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
relay_bad_snippet_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_bad_snippet.XXXXXX")"
{
    printf "<!-- cppstudio-user-agents-relay:end -->\n"
    printf "bad relay body\n"
    printf "<!-- cppstudio-user-agents-relay:begin -->\n"
} >"${relay_bad_snippet_tmp}/relay.md"
expect_failure "reversed CppStudio relay snippet markers" "has reversed markers" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_bad_snippet_tmp}/AGENTS.md" \
    --expected-target "${relay_bad_snippet_tmp}/AGENTS.md" \
    --snippet "${relay_bad_snippet_tmp}/relay.md"
rm -rf "${relay_bad_snippet_tmp}"
expect_failure "unsafe relay target basename" "relay target must be named AGENTS.md" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u "${VALIDATE_TMP}/agents_relay_bad.XXXXXX")/NOT_AGENTS.md" \
    --expected-target "$(mktemp -u "${VALIDATE_TMP}/agents_relay_bad.XXXXXX")/NOT_AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
relay_symlink_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_symlink.XXXXXX")"
touch "${relay_symlink_tmp}/real_AGENTS.md"
ln -s "${relay_symlink_tmp}/real_AGENTS.md" "${relay_symlink_tmp}/AGENTS.md"
expect_failure "relay target symlink" "relay target must not be a symlink" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_symlink_tmp}/AGENTS.md" \
    --expected-target "${relay_symlink_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_symlink_tmp}"
relay_override_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_override.XXXXXX")"
expect_failure "relay custom target without override" "differs from expected" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_override_tmp}/AGENTS.md" \
    --expected-target "${relay_override_tmp}/expected/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_override_tmp}"
sync_symlink_root_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_symlink_root.XXXXXX")"
mkdir -p "${sync_symlink_root_tmp}/codex" "${sync_symlink_root_tmp}/real-skills"
ln -s "${sync_symlink_root_tmp}/real-skills" "${sync_symlink_root_tmp}/codex/skills"
expect_failure "sync symlinked Codex skills root" "Refusing symlinked Codex skills root" \
    env SYNC_CODEX_HOME="${sync_symlink_root_tmp}/codex" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh" --dry-run
expect_failure "rollout symlinked Codex skills root" "Refusing symlinked Codex skills root" \
    env SYNC_CODEX_HOME="${sync_symlink_root_tmp}/codex" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/rollout_to_codex.sh"
rm -rf "${sync_symlink_root_tmp}"
sync_symlink_target_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_symlink_target.XXXXXX")"
mkdir -p \
    "${sync_symlink_target_tmp}/codex/skills" \
    "${sync_symlink_target_tmp}/real-target"
ln -s "${sync_symlink_target_tmp}/real-target" \
    "${sync_symlink_target_tmp}/codex/skills/cpp-cuda-vulkan-studio"
expect_failure "sync symlinked target dir" "Refusing symlinked TARGET_DIR" \
    env SYNC_CODEX_HOME="${sync_symlink_target_tmp}/codex" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh" --dry-run
expect_failure "rollout symlinked target dir" "Refusing symlinked rollout TARGET_DIR" \
    env SYNC_CODEX_HOME="${sync_symlink_target_tmp}/codex" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/rollout_to_codex.sh"
rm -rf "${sync_symlink_target_tmp}"
sync_dry_run_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_dry_run_nowrite.XXXXXX")"
sync_dry_run_home="${sync_dry_run_tmp}/missing-codex-home"
sync_dry_run_out="$(mktemp "${VALIDATE_TMP}/sync_dry_run_nowrite.XXXXXX.out")"
env SYNC_CODEX_HOME="${sync_dry_run_home}" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh" --dry-run >"${sync_dry_run_out}"
grep -q "Dry run complete" "${sync_dry_run_out}"
if [[ -e "${sync_dry_run_home}" ]]; then
    find "${sync_dry_run_tmp}" -maxdepth 3 -print >&2
    echo "sync_to_codex.sh --dry-run created the target Codex home" >&2
    exit 1
fi
rm -rf "${sync_dry_run_tmp}"
relay_reversed_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_reversed.XXXXXX")"
{
    printf "<!-- cppstudio-user-agents-relay:end -->\n"
    printf "bad relay body\n"
    printf "<!-- cppstudio-user-agents-relay:begin -->\n"
} >"${relay_reversed_tmp}/AGENTS.md"
expect_failure "reversed CppStudio relay markers" "has reversed CppStudio relay markers" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_reversed_tmp}/AGENTS.md" \
    --expected-target "${relay_reversed_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_reversed_tmp}"
relay_duplicate_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_duplicate.XXXXXX")"
{
    cat "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
    printf "\n\n"
    cat "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
} > "${relay_duplicate_tmp}/AGENTS.md"
relay_duplicate_out="$(mktemp "${VALIDATE_TMP}/agents_relay_duplicate.XXXXXX.out")"
if python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_duplicate_tmp}/AGENTS.md" \
    --expected-target "${relay_duplicate_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md" >"${relay_duplicate_out}" 2>&1
then
    cat "${relay_duplicate_out}" >&2
    rm -rf "${relay_duplicate_tmp}"
    echo "Duplicate CppStudio relay blocks were accepted" >&2
    exit 1
fi
rm -rf "${relay_duplicate_tmp}"
relay_preserve_tmp="$(mktemp -d "${VALIDATE_TMP}/agents_relay_preserve.XXXXXX")"
python3 - "${relay_preserve_tmp}/AGENTS.md" <<'PY'
from pathlib import Path
import sys

Path(sys.argv[1]).write_bytes(
    b"alpha trailing spaces   \r\n"
    b"blank before\r\n"
    b"\r\n"
    b"<!-- cppstudio-user-agents-relay:begin -->\r\n"
    b"old relay body\r\n"
    b"<!-- cppstudio-user-agents-relay:end -->"
    b"\r\n\r\n\r\n"
    b"  after block with leading spaces\r\n"
    b"omega\r\n"
)
PY
python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --install \
    --target "${relay_preserve_tmp}/AGENTS.md" \
    --expected-target "${relay_preserve_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
python3 - "${relay_preserve_tmp}/AGENTS.md" <<'PY'
from pathlib import Path
import sys

data = Path(sys.argv[1]).read_bytes()
prefix = b"alpha trailing spaces   \r\nblank before\r\n\r\n"
suffix = b"\r\n\r\n\r\n  after block with leading spaces\r\nomega\r\n"
if not data.startswith(prefix):
    raise SystemExit("relay replacement did not preserve prefix outside markers")
if not data.endswith(suffix):
    raise SystemExit("relay replacement did not preserve suffix outside markers")
PY
rm -rf "${relay_preserve_tmp}"

companion_tmp="$(mktemp -d "${VALIDATE_TMP}/companion_install.XXXXXX")"
write_companion_fixtures "${companion_tmp}"
python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
mkdir -p "${companion_tmp}/skills/cpp-cuda-vulkan-studio"
cp -a "${SKILL_DIR}/references" "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references"
cat >>"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<EOF

## Donor References

When selecting external kernel, runtime, or compiler donors, read:

- \`${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library/selection-policy.md\`
- \`${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library/ai-runtimes-kernels.md\`

Use the donor library to compare CUTLASS, Triton, FlashAttention, tiny-cuda-nn, llama.cpp/ggml,
ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, and PyTorch before writing or recommending custom
GPU code. Keep non-commercial or study-only donors out of reusable implementation code.
EOF
python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --install \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
grep -q "Use the donor library to compare CUTLASS" "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
write_companion_fixtures "${companion_tmp}"
python3 - "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<'PY'
from pathlib import Path
import sys

Path(sys.argv[1]).write_bytes(
    b"---\r\n"
    b"name: cuda-kernel-authoring\r\n"
    b"description: Test fixture.\r\n"
    b"---\r\n"
    b"# CUDA Kernel Authoring\r\n"
    b"\r\n"
    b"  before donor block  \r\n"
    b"<!-- cppstudio-donor-library:begin -->\r\n"
    b"old donor body\r\n"
    b"<!-- cppstudio-donor-library:end -->"
    b"\r\n\r\n\r\n"
    b"  after donor block\r\n"
    b"## Design Rules\r\n"
)
PY
python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --install \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
python3 - "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<'PY'
from pathlib import Path
import sys

data = Path(sys.argv[1]).read_bytes()
prefix = (
    b"---\r\n"
    b"name: cuda-kernel-authoring\r\n"
    b"description: Test fixture.\r\n"
    b"---\r\n"
    b"# CUDA Kernel Authoring\r\n"
    b"\r\n"
    b"  before donor block  \r\n"
)
suffix = b"\r\n\r\n\r\n  after donor block\r\n## Design Rules\r\n"
if not data.startswith(prefix):
    raise SystemExit("companion donor replacement did not preserve prefix outside markers")
if not data.endswith(suffix):
    raise SystemExit("companion donor replacement did not preserve suffix outside markers")
PY
write_companion_fixtures "${companion_tmp}"
missing_companion_tmp="$(mktemp -d "${VALIDATE_TMP}/companion_missing.XXXXXX")"
write_companion_fixtures "${missing_companion_tmp}"
rm -rf \
    "${missing_companion_tmp}/skills/vulkan-compute-sync" \
    "${missing_companion_tmp}/skills/modern-cpp-cmake"
missing_companion_out="$(mktemp "${VALIDATE_TMP}/companion_missing.XXXXXX.out")"
python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${missing_companion_tmp}" \
    --donor-root "${missing_companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets" >"${missing_companion_out}"
grep -q "preflight skipped: ${missing_companion_tmp}/skills/vulkan-compute-sync/SKILL.md" \
    "${missing_companion_out}"
expect_failure "strict companion skill missing" "missing installed companion skill" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${missing_companion_tmp}" \
    --donor-root "${missing_companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets" \
    --strict
rm -rf "${missing_companion_tmp}"
{
    sed \
        -e "s#{{DONOR_ROOT}}#${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library#g" \
        -e "s#{{REFERENCE_ROOT}}#${companion_tmp}/skills/cpp-cuda-vulkan-studio/references#g" \
        "${ROOT_DIR}/companion-skill-snippets/cuda-kernel-authoring/donor-library.md"
    printf "\n"
} >"${companion_tmp}/rendered_cuda_block.md"
bad_companion_skill_tmp="$(mktemp "${VALIDATE_TMP}/bad_companion_skill.XXXXXX.md")"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:end -->\n\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:end -->\n"
} >"${bad_companion_skill_tmp}"
mv "${bad_companion_skill_tmp}" "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "duplicate companion donor marker blocks" "multiple marker blocks found" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
bad_companion_skill_tmp="$(mktemp "${VALIDATE_TMP}/bad_companion_skill.XXXXXX.md")"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:end -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:begin -->\n"
} >"${bad_companion_skill_tmp}"
mv "${bad_companion_skill_tmp}" "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "reversed companion donor markers" "end marker precedes begin marker" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
bad_companion_skill_tmp="$(mktemp "${VALIDATE_TMP}/bad_companion_skill.XXXXXX.md")"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
} >"${bad_companion_skill_tmp}"
mv "${bad_companion_skill_tmp}" "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "single begin companion donor marker" "begin/end markers do not match" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
bad_companion_skill_tmp="$(mktemp "${VALIDATE_TMP}/bad_companion_skill.XXXXXX.md")"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:end -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
} >"${bad_companion_skill_tmp}"
mv "${bad_companion_skill_tmp}" "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "single end companion donor marker" "begin/end markers do not match" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
mv "${companion_tmp}/skills/cuda-kernel-authoring" "${companion_tmp}/real-cuda-kernel-authoring"
ln -s "${companion_tmp}/real-cuda-kernel-authoring" "${companion_tmp}/skills/cuda-kernel-authoring"
expect_failure "symlinked companion skill directory" "installed companion skill directory must not be a symlink" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
mv "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" \
    "${companion_tmp}/skills/cuda-kernel-authoring/REAL_SKILL.md"
ln -s "${companion_tmp}/skills/cuda-kernel-authoring/REAL_SKILL.md" \
    "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "symlinked companion SKILL.md" "installed companion SKILL.md must not be a symlink" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
skills_root_symlink_tmp="$(mktemp -d "${VALIDATE_TMP}/companion_skills_symlink.XXXXXX")"
mkdir -p "${skills_root_symlink_tmp}/codex" "${skills_root_symlink_tmp}/real-skills"
ln -s "${skills_root_symlink_tmp}/real-skills" "${skills_root_symlink_tmp}/codex/skills"
expect_failure "symlinked Codex skills root" "Codex skills root must not be a symlink" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${skills_root_symlink_tmp}/codex" \
    --donor-root "${skills_root_symlink_tmp}/codex/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
rm -rf "${skills_root_symlink_tmp}"
write_companion_fixtures "${companion_tmp}"
python3 - "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("name: cuda-kernel-authoring\n", "name: wrong-skill\n", 1)
text = "\n".join(line for line in text.splitlines() if "cppstudio-donor-library" not in line) + "\n"
path.write_text(text, encoding="utf-8")
PY
expect_failure "companion skill frontmatter name mismatch" "name mismatch" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
cat >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<'EOF'
---
name: cuda-kernel-authoring
name: cuda-kernel-authoring
description: Test fixture.
---
# CUDA Kernel Authoring
## Design Rules
EOF
expect_failure "companion skill duplicate frontmatter name" "expected exactly one frontmatter name" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
snippet_tmp="${companion_tmp}/snippets"
mkdir -p \
    "${snippet_tmp}/cuda-kernel-authoring" \
    "${snippet_tmp}/vulkan-compute-sync" \
    "${snippet_tmp}/modern-cpp-cmake"
cp "${ROOT_DIR}/companion-skill-snippets/vulkan-compute-sync/donor-library.md" \
    "${snippet_tmp}/vulkan-compute-sync/donor-library.md"
cp "${ROOT_DIR}/companion-skill-snippets/modern-cpp-cmake/donor-library.md" \
    "${snippet_tmp}/modern-cpp-cmake/donor-library.md"
{
    printf "<!-- cppstudio-donor-library:begin -->\n"
    cat "${ROOT_DIR}/companion-skill-snippets/cuda-kernel-authoring/donor-library.md"
    printf "\n<!-- cppstudio-donor-library:end -->\n"
} >"${snippet_tmp}/cuda-kernel-authoring/donor-library.md"
cat >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md" <<'EOF'
---
name: cuda-kernel-authoring
description: Test fixture.
---
# CUDA Kernel Authoring
## Design Rules
EOF
expect_failure "companion snippet with managed markers" "must not contain managed donor markers" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${snippet_tmp}"
rm -rf "${companion_tmp}"

donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
python3 - "${donor_tmp}/donor-library/profiles/gsplat.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = "\n".join(line for line in text.splitlines() if not line.startswith("Backend signal:")) + "\n"
path.write_text(text, encoding="utf-8")
PY
expect_failure "missing donor backend signal" "missing or invalid Backend signal" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"
donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate_lookup.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
python3 - "${donor_tmp}/donor-library/agent-lookup.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = "[graphics-rendering.md](graphics-rendering.md)"
if old not in text:
    raise SystemExit("agent lookup graphics route fixture not found")
path.write_text(text.replace(old, "graphics rendering route removed"), encoding="utf-8")
PY
expect_failure "agent lookup missing donor category link" "does not link donor category" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"
donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate_tier.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
python3 - "${donor_tmp}/donor-library/hair-grooming-fur.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = "| [AMD TressFX](https://github.com/GPUOpen-Effects/TressFX) | safe-donor |"
new = "| [AMD TressFX](https://github.com/GPUOpen-Effects/TressFX) | dependency-candidate |"
if old not in text:
    raise SystemExit("TressFX row fixture not found")
path.write_text(text.replace(old, new), encoding="utf-8")
PY
expect_failure "category/profile donor tier mismatch" "tier" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"
donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate_backend.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
python3 - "${donor_tmp}/donor-library/hair-grooming-fur.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = "GPU hair/fur simulation and rendering, strand data, skinning, LOD, Vulkan/DX12 sample architecture."
new = "CUDA hair/fur simulation and rendering, strand data, skinning, LOD, Vulkan/DX12 sample architecture."
if old not in text:
    raise SystemExit("TressFX backend fixture not found")
path.write_text(text.replace(old, new), encoding="utf-8")
PY
expect_failure "category/profile donor backend mismatch" "backend" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"

matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["must_not_trigger_paths"] = ["missing/path/that/should/fail.md"]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "missing trigger matrix must-not-trigger path" "missing must-not-trigger path" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_escape.XXXXXX.json")"
escape_tmp="$(mktemp -d "${VALIDATE_TMP}/trigger_escape.XXXXXX")"
touch "${escape_tmp}/outside.md"
escaped_relative="$(python3 - "${ROOT_DIR}" "${escape_tmp}/outside.md" <<'PY'
import os
import sys

print(os.path.relpath(sys.argv[2], sys.argv[1]))
PY
)"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" "${escaped_relative}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
escaped = sys.argv[3]
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["expected_paths"] = [escaped]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix escaped expected path" "path escapes repo root" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
rm -rf "${escape_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_overlap.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
path = data["cases"][0]["expected_paths"][0]
data["cases"][0]["must_not_trigger_paths"] = [path]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix expected/must-not overlap" "path appears in both expected" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_bad_tags.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["tags"] = ["smoke", ""]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix empty tag" "tags must contain only non-empty strings" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_missing_polarity.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["tags"] = ["smoke", "vulkan"]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix missing polarity tag" "exactly one polarity tag" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_duplicate_polarity.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["tags"] = ["positive", "negative", "vulkan"]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix duplicate polarity tags" "exactly one polarity tag" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_unknown_tag.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"][0]["tags"] = ["positive", "not-a-real-tag"]
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "trigger matrix unknown tag" "unknown tag" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"

expect_failure "scaffold invalid namespace trailing colon" "namespace must be C++ identifiers" \
    python3 "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
    --name BadNamespace \
    --output "${VALIDATE_TMP}/bad_namespace_colon" \
    --namespace "foo:"
expect_failure "scaffold invalid namespace trailing separator" "namespace must be C++ identifiers" \
    python3 "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
    --name BadNamespace \
    --output "${VALIDATE_TMP}/bad_namespace_separator" \
    --namespace "foo::"
expect_failure "scaffold invalid namespace keyword" "namespace segment is a C++ keyword" \
    python3 "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
    --name BadNamespace \
    --output "${VALIDATE_TMP}/bad_namespace_keyword" \
    --namespace "foo::class"
description_tmp="$(mktemp -d "${VALIDATE_TMP}/description_scaffold.XXXXXX")"
python3 "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
    --name DescriptionSmoke \
    --output "${description_tmp}" \
    --description "Custom CppStudio description smoke"
grep -q "Custom CppStudio description smoke" "${description_tmp}/README.md"
apply_dry_run_tmp="$(mktemp -d "${VALIDATE_TMP}/apply_dry_run.XXXXXX")"
apply_dry_run_out="$(mktemp "${VALIDATE_TMP}/apply_dry_run.XXXXXX.out")"
python3 "${SKILL_DIR}/scripts/apply_studio_backbone.py" \
    "${apply_dry_run_tmp}" \
    --dry-run >"${apply_dry_run_out}"
grep -q "CMakePresets.json" "${apply_dry_run_out}"
apply_conflict_tmp="$(mktemp -d "${VALIDATE_TMP}/apply_conflict.XXXXXX")"
touch "${apply_conflict_tmp}/.gitignore" "${apply_conflict_tmp}/CMakePresets.json"
apply_conflict_out="$(mktemp "${VALIDATE_TMP}/apply_conflict.XXXXXX.out")"
if python3 "${SKILL_DIR}/scripts/apply_studio_backbone.py" \
    "${apply_conflict_tmp}" \
    --dry-run >"${apply_conflict_out}" 2>&1
then
    cat "${apply_conflict_out}" >&2
    echo "Existing-repo dry run with conflicts passed unexpectedly" >&2
    exit 1
fi
if grep -q "Traceback" "${apply_conflict_out}"; then
    cat "${apply_conflict_out}" >&2
    echo "Existing-repo dry run with conflicts produced a traceback" >&2
    exit 1
fi
grep -q "exists: ${apply_conflict_tmp}/.gitignore" "${apply_conflict_out}"
grep -q "exists: ${apply_conflict_tmp}/CMakePresets.json" "${apply_conflict_out}"
grep -q "Dry run found existing files" "${apply_conflict_out}"
apply_force_out="$(mktemp "${VALIDATE_TMP}/apply_force.XXXXXX.out")"
python3 "${SKILL_DIR}/scripts/apply_studio_backbone.py" \
    "${apply_conflict_tmp}" \
    --dry-run \
    --force >"${apply_force_out}"
grep -q "overwrite: ${apply_conflict_tmp}/.gitignore" "${apply_force_out}"
grep -q "overwrite: ${apply_conflict_tmp}/CMakePresets.json" "${apply_force_out}"

python3 - "${SKILL_DIR}/scripts/validate_studio_backbone.py" <<'PY'
import importlib.util
import sys
from pathlib import Path

path = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location("validate_studio_backbone", path)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

empty_failures = module.validate_ctest_json('{"tests": []}', {"quick"})
if not empty_failures:
    raise SystemExit("empty CTest JSON unexpectedly passed")
missing_label_failures = module.validate_ctest_json(
    '{"tests": [{"name": "wrong_lane", "properties": [{"name": "LABELS", "value": ["gpu"]}]}]}',
    {"quick"},
)
if not missing_label_failures:
    raise SystemExit("CTest JSON without quick label unexpectedly passed")
valid_failures = module.validate_ctest_json(
    '{"tests": [{"name": "smoke", "properties": [{"name": "LABELS", "value": ["quick"]}]}]}',
    {"quick"},
)
if valid_failures:
    raise SystemExit("valid CTest JSON unexpectedly failed: " + "; ".join(valid_failures))
PY
malformed_backbone_tmp="$(mktemp -d "${VALIDATE_TMP}/malformed_backbone.XXXXXX")"
python3 "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
    --name MalformedPresets \
    --output "${malformed_backbone_tmp}"
python3 - "${malformed_backbone_tmp}/CMakePresets.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = json.loads(path.read_text(encoding="utf-8"))
data["configurePresets"] = ["bad"]
data["testPresets"] = ["bad"]
path.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "malformed CMakePresets preset entries" "configurePresets[1] must be an object" \
    python3 "${SKILL_DIR}/scripts/validate_studio_backbone.py" \
    "${malformed_backbone_tmp}" \
    --strict-source-layout
rm -rf "${ROOT_DIR}/scripts/__pycache__"
rm -rf "${SKILL_DIR}/scripts/__pycache__"
bash -n "${ROOT_DIR}"/scripts/*.sh
bash -n "${SKILL_DIR}"/scripts/*.sh
compute_fake_dir="$(mktemp -d "${VALIDATE_TMP}/compute_fake.XXXXXX")"
cat >"${compute_fake_dir}/compute-sanitizer" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf "%s\n" "$@" >"${COMPUTE_SANITIZER_ARGV_CAPTURE:?}"
EOF
chmod +x "${compute_fake_dir}/compute-sanitizer"
compute_direct_tmp="$(mktemp -d "${VALIDATE_TMP}/compute_direct.XXXXXX")"
compute_direct_capture="$(mktemp "${VALIDATE_TMP}/compute_direct_argv.XXXXXX")"
(
    cd "${compute_direct_tmp}"
    PATH="${compute_fake_dir}:${PATH}" \
        COMPUTE_SANITIZER_ARGV_CAPTURE="${compute_direct_capture}" \
        "${SKILL_DIR}/scripts/run_compute_sanitizer.sh" \
        "${VALIDATE_TMP}/cuda app with spaces" \
        "--flag" \
        "value with spaces"
)
grep -Fx -- "--error-exitcode=99" "${compute_direct_capture}"
grep -Fx -- "--target-processes" "${compute_direct_capture}"
grep -Fx "all" "${compute_direct_capture}"
grep -Fx "${VALIDATE_TMP}/cuda app with spaces" "${compute_direct_capture}"
grep -Fx -- "--flag" "${compute_direct_capture}"
grep -Fx "value with spaces" "${compute_direct_capture}"
test -f "${compute_direct_tmp}/artifacts/sanitizer/compute-sanitizer.log"
compute_default_tmp="$(mktemp -d "${VALIDATE_TMP}/compute_default.XXXXXX")"
compute_default_capture="$(mktemp "${VALIDATE_TMP}/compute_default_argv.XXXXXX")"
(
    cd "${compute_default_tmp}"
    PATH="${compute_fake_dir}:${PATH}" \
        COMPUTE_SANITIZER_ARGV_CAPTURE="${compute_default_capture}" \
        "${SKILL_DIR}/scripts/run_compute_sanitizer.sh"
)
grep -Fx -- "--error-exitcode=99" "${compute_default_capture}"
grep -Fx "ctest" "${compute_default_capture}"
grep -Fx -- "--preset" "${compute_default_capture}"
grep -Fx "cuda" "${compute_default_capture}"
grep -Fx -- "--output-on-failure" "${compute_default_capture}"
grep -Fx -- "--no-tests=error" "${compute_default_capture}"
nsys_fake_dir="$(mktemp -d "${VALIDATE_TMP}/nsys_fake.XXXXXX")"
cat >"${nsys_fake_dir}/nsys" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

case "$1" in
    profile)
        shift
        output_prefix=""
        while (($# > 0)); do
            case "$1" in
                --output=*)
                    output_prefix="${1#--output=}"
                    shift
                    ;;
                --*)
                    shift
                    ;;
                *)
                    break
                    ;;
            esac
        done
        if [[ -z "${output_prefix}" ]]; then
            echo "missing --output" >&2
            exit 2
        fi
        printf "%s\n" "$@" >"${NSYS_ARGV_CAPTURE:?}"
        touch "${output_prefix}.nsys-rep"
        ;;
    stats)
        printf "stats for %s\n" "$2"
        ;;
    *)
        echo "unexpected nsys command: $1" >&2
        exit 2
        ;;
esac
EOF
chmod +x "${nsys_fake_dir}/nsys"
nsys_arg_capture="$(mktemp "${VALIDATE_TMP}/nsys_argv.XXXXXX")"
PATH="${nsys_fake_dir}:${PATH}" \
    NSYS_ARGV_CAPTURE="${nsys_arg_capture}" \
    NSYS_OUTPUT_DIR="${VALIDATE_TMP}/nsys_arg_out" \
    "${SKILL_DIR}/scripts/run_nsys_smoke.sh" \
    "${VALIDATE_TMP}/app with spaces" \
    "--flag" \
    "value with spaces"
grep -Fx "${VALIDATE_TMP}/app with spaces" "${nsys_arg_capture}"
grep -Fx -- "--flag" "${nsys_arg_capture}"
grep -Fx "value with spaces" "${nsys_arg_capture}"
expect_failure "APP_COMMAND rejects shell-split command strings" "APP_COMMAND must be a single executable path without whitespace" \
    env PATH="${nsys_fake_dir}:${PATH}" \
    NSYS_ARGV_CAPTURE="${nsys_arg_capture}" \
    NSYS_OUTPUT_DIR="${VALIDATE_TMP}/nsys_bad_app_command" \
    APP_COMMAND="${VALIDATE_TMP}/app with spaces --flag" \
    "${SKILL_DIR}/scripts/run_nsys_smoke.sh"

if (( full )); then
    sample_dir="$(mktemp -d "${VALIDATE_TMP}/generated_project.XXXXXX")"

    "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" --name StudioValidate --output "${sample_dir}"
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${sample_dir}" --strict-source-layout --integration
    (
        cd "${sample_dir}"
        scripts/format_check.sh
        cmake --preset dev
        cmake --build --preset dev
        ctest --preset quick --output-on-failure --no-tests=error
        cmake --preset vulkan-debug
        cmake --build --preset vulkan-debug
        ctest --preset vulkan --output-on-failure --no-tests=error
        cmake --preset vulkan-portability
        cmake --build --preset vulkan-portability
        ctest --test-dir build/vulkan-portability --output-on-failure --no-tests=error -L vulkan
        scripts/run_vulkan_validation.sh
        cmake --preset cuda-debug
        cmake --build --preset cuda-debug
        ctest --preset cuda --output-on-failure --no-tests=error
        compute_generated_capture="$(mktemp "${VALIDATE_TMP}/compute_generated_argv.XXXXXX")"
        PATH="${compute_fake_dir}:${PATH}" \
            COMPUTE_SANITIZER_ARGV_CAPTURE="${compute_generated_capture}" \
            scripts/run_compute_sanitizer.sh
        grep -Fx -- "--error-exitcode=99" "${compute_generated_capture}"
        grep -Fx "ctest" "${compute_generated_capture}"
        grep -Fx -- "--preset" "${compute_generated_capture}"
        grep -Fx "cuda" "${compute_generated_capture}"
        cmake --preset cuda-vulkan-combined
        cmake --build --preset cuda-vulkan-combined
        cmake --preset benchmark
        cmake --build --preset benchmark
        ctest --preset benchmark --output-on-failure --no-tests=error
        cmake --preset asan-ubsan
        cmake --build --preset asan-ubsan
        ctest --preset asan-ubsan-quick --output-on-failure --no-tests=error
    )
fi

echo "CppStudio validation passed"
