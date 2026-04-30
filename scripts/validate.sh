#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${ROOT_DIR}/skills/cpp-cuda-vulkan-studio"
VALIDATOR="${VALIDATOR:-${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py}"
full=0

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

required_repo_files=(
    "scripts/install_companion_donor_links.py"
    "scripts/install_user_agents_relay.py"
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
fi

expect_failure() {
    local description="$1"
    shift
    local output_file
    output_file="$(mktemp /tmp/cppstudio_expect_failure.XXXXXX)"
    if "$@" >"${output_file}" 2>&1; then
        cat "${output_file}" >&2
        rm -f "${output_file}"
        echo "Expected failure passed unexpectedly: ${description}" >&2
        exit 1
    fi
    rm -f "${output_file}"
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
python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u /tmp/cppstudio_agents_relay.XXXXXX)/AGENTS.md" \
    --expected-target "$(mktemp -u /tmp/cppstudio_agents_relay.XXXXXX)/AGENTS.md" \
    --allow-target-override \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
expect_failure "relay target without expected target" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u /tmp/cppstudio_agents_relay_no_expected.XXXXXX)/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
relay_bad_snippet_tmp="$(mktemp -d /tmp/cppstudio_agents_relay_bad_snippet.XXXXXX)"
{
    printf "<!-- cppstudio-user-agents-relay:end -->\n"
    printf "bad relay body\n"
    printf "<!-- cppstudio-user-agents-relay:begin -->\n"
} >"${relay_bad_snippet_tmp}/relay.md"
expect_failure "reversed CppStudio relay snippet markers" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_bad_snippet_tmp}/AGENTS.md" \
    --expected-target "${relay_bad_snippet_tmp}/AGENTS.md" \
    --snippet "${relay_bad_snippet_tmp}/relay.md"
rm -rf "${relay_bad_snippet_tmp}"
expect_failure "unsafe relay target basename" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "$(mktemp -u /tmp/cppstudio_agents_relay_bad.XXXXXX)/NOT_AGENTS.md" \
    --expected-target "$(mktemp -u /tmp/cppstudio_agents_relay_bad.XXXXXX)/NOT_AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
relay_symlink_tmp="$(mktemp -d /tmp/cppstudio_agents_relay_symlink.XXXXXX)"
touch "${relay_symlink_tmp}/real_AGENTS.md"
ln -s "${relay_symlink_tmp}/real_AGENTS.md" "${relay_symlink_tmp}/AGENTS.md"
expect_failure "relay target symlink" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_symlink_tmp}/AGENTS.md" \
    --expected-target "${relay_symlink_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_symlink_tmp}"
relay_override_tmp="$(mktemp -d /tmp/cppstudio_agents_relay_override.XXXXXX)"
expect_failure "relay custom target without override" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_override_tmp}/AGENTS.md" \
    --expected-target "${relay_override_tmp}/expected/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_override_tmp}"
relay_reversed_tmp="$(mktemp -d /tmp/cppstudio_agents_relay_reversed.XXXXXX)"
{
    printf "<!-- cppstudio-user-agents-relay:end -->\n"
    printf "bad relay body\n"
    printf "<!-- cppstudio-user-agents-relay:begin -->\n"
} >"${relay_reversed_tmp}/AGENTS.md"
expect_failure "reversed CppStudio relay markers" \
    python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_reversed_tmp}/AGENTS.md" \
    --expected-target "${relay_reversed_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
rm -rf "${relay_reversed_tmp}"
relay_duplicate_tmp="$(mktemp -d /tmp/cppstudio_agents_relay_duplicate.XXXXXX)"
{
    cat "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
    printf "\n\n"
    cat "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md"
} > "${relay_duplicate_tmp}/AGENTS.md"
if python3 "${ROOT_DIR}/scripts/install_user_agents_relay.py" \
    --preflight \
    --target "${relay_duplicate_tmp}/AGENTS.md" \
    --expected-target "${relay_duplicate_tmp}/AGENTS.md" \
    --snippet "${ROOT_DIR}/companion-skill-snippets/user-agents/cppstudio-relay.md" >/tmp/cppstudio_agents_relay_duplicate.out 2>&1
then
    cat /tmp/cppstudio_agents_relay_duplicate.out >&2
    rm -rf "${relay_duplicate_tmp}" /tmp/cppstudio_agents_relay_duplicate.out
    echo "Duplicate CppStudio relay blocks were accepted" >&2
    exit 1
fi
rm -rf "${relay_duplicate_tmp}" /tmp/cppstudio_agents_relay_duplicate.out

companion_tmp="$(mktemp -d /tmp/cppstudio_companion_install.XXXXXX)"
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
missing_companion_tmp="$(mktemp -d /tmp/cppstudio_companion_missing.XXXXXX)"
write_companion_fixtures "${missing_companion_tmp}"
rm -rf \
    "${missing_companion_tmp}/skills/vulkan-compute-sync" \
    "${missing_companion_tmp}/skills/modern-cpp-cmake"
python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${missing_companion_tmp}" \
    --donor-root "${missing_companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets" >/tmp/cppstudio_companion_missing.out
grep -q "preflight skipped: ${missing_companion_tmp}/skills/vulkan-compute-sync/SKILL.md" \
    /tmp/cppstudio_companion_missing.out
expect_failure "strict companion skill missing" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${missing_companion_tmp}" \
    --donor-root "${missing_companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets" \
    --strict
rm -rf "${missing_companion_tmp}" /tmp/cppstudio_companion_missing.out
{
    cat "${ROOT_DIR}/companion-skill-snippets/cuda-kernel-authoring/donor-library.md" \
        | sed "s#{{DONOR_ROOT}}#${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library#g" \
        | sed "s#{{REFERENCE_ROOT}}#${companion_tmp}/skills/cpp-cuda-vulkan-studio/references#g"
    printf "\n"
} >"${companion_tmp}/rendered_cuda_block.md"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:end -->\n\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:end -->\n"
} >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "duplicate companion donor marker blocks" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:end -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
    printf "<!-- cppstudio-donor-library:begin -->\n"
} >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "reversed companion donor markers" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:begin -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
} >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "single begin companion donor marker" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
{
    cat "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
    printf "\n<!-- cppstudio-donor-library:end -->\n"
    cat "${companion_tmp}/rendered_cuda_block.md"
} >"${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "single end companion donor marker" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
write_companion_fixtures "${companion_tmp}"
mv "${companion_tmp}/skills/cuda-kernel-authoring" "${companion_tmp}/real-cuda-kernel-authoring"
ln -s "${companion_tmp}/real-cuda-kernel-authoring" "${companion_tmp}/skills/cuda-kernel-authoring"
expect_failure "symlinked companion skill directory" \
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
expect_failure "symlinked companion SKILL.md" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
skills_root_symlink_tmp="$(mktemp -d /tmp/cppstudio_companion_skills_symlink.XXXXXX)"
mkdir -p "${skills_root_symlink_tmp}/codex" "${skills_root_symlink_tmp}/real-skills"
ln -s "${skills_root_symlink_tmp}/real-skills" "${skills_root_symlink_tmp}/codex/skills"
expect_failure "symlinked Codex skills root" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${skills_root_symlink_tmp}/codex" \
    --donor-root "${skills_root_symlink_tmp}/codex/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${ROOT_DIR}/companion-skill-snippets"
rm -rf "${skills_root_symlink_tmp}"
write_companion_fixtures "${companion_tmp}"
sed -i 's/^name: cuda-kernel-authoring$/name: wrong-skill/' "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
sed -i '/cppstudio-donor-library/d' "${companion_tmp}/skills/cuda-kernel-authoring/SKILL.md"
expect_failure "companion skill frontmatter name mismatch" \
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
expect_failure "companion skill duplicate frontmatter name" \
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
expect_failure "companion snippet with managed markers" \
    python3 "${ROOT_DIR}/scripts/install_companion_donor_links.py" \
    --preflight \
    --codex-home "${companion_tmp}" \
    --donor-root "${companion_tmp}/skills/cpp-cuda-vulkan-studio/references/donor-library" \
    --source-skill-dir "${SKILL_DIR}" \
    --snippet-root "${snippet_tmp}"
rm -rf "${companion_tmp}"

donor_tmp="$(mktemp -d /tmp/cppstudio_donor_validate.XXXXXX)"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
sed -i '/^Backend signal:/d' "${donor_tmp}/donor-library/profiles/gsplat.md"
expect_failure "missing donor backend signal" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"
donor_tmp="$(mktemp -d /tmp/cppstudio_donor_validate_tier.XXXXXX)"
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
expect_failure "category/profile donor tier mismatch" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"
donor_tmp="$(mktemp -d /tmp/cppstudio_donor_validate_backend.XXXXXX)"
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
expect_failure "category/profile donor backend mismatch" \
    python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${donor_tmp}/donor-library" \
    --reference-root "${donor_tmp}"
rm -rf "${donor_tmp}"

matrix_tmp="$(mktemp /tmp/cppstudio_trigger_matrix.XXXXXX.json)"
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
expect_failure "missing trigger matrix must-not-trigger path" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp /tmp/cppstudio_trigger_matrix_escape.XXXXXX.json)"
escape_tmp="$(mktemp -d /tmp/cppstudio_trigger_escape.XXXXXX)"
touch "${escape_tmp}/outside.md"
escaped_relative="$(realpath --relative-to "${ROOT_DIR}" "${escape_tmp}/outside.md")"
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
expect_failure "trigger matrix escaped expected path" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
rm -rf "${escape_tmp}"
matrix_tmp="$(mktemp /tmp/cppstudio_trigger_matrix_overlap.XXXXXX.json)"
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
expect_failure "trigger matrix expected/must-not overlap" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
rm -rf "${ROOT_DIR}/scripts/__pycache__"
rm -rf "${SKILL_DIR}/scripts/__pycache__"
bash -n "${ROOT_DIR}"/scripts/*.sh
bash -n "${SKILL_DIR}"/scripts/*.sh

if (( full )); then
    sample_dir="$(mktemp -d /tmp/cppstudio_validate.XXXXXX)"
    cleanup_sample() {
        if [[ "${KEEP_VALIDATE_TMP:-0}" == "1" ]]; then
            echo "Preserved validation sample at ${sample_dir}"
        else
            rm -rf "${sample_dir}"
        fi
    }
    trap cleanup_sample EXIT

    "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" --name StudioValidate --output "${sample_dir}"
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${sample_dir}" --strict-source-layout
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
        cmake --preset cuda-vulkan-interop
        cmake --build --preset cuda-vulkan-interop
        cmake --preset asan-ubsan
        cmake --build --preset asan-ubsan
        ctest --preset asan-ubsan-quick --output-on-failure --no-tests=error
    )
fi

echo "CppStudio validation passed"
