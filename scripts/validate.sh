#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${ROOT_DIR}/skills/cpp-cuda-vulkan-studio"
CORE_MODULE="${SKILL_DIR}/modules/studio-core.md"
# shellcheck source=scripts/managed_skills.sh
source "${ROOT_DIR}/scripts/managed_skills.sh"
AUXILIARY_SKILL_NAMES=("${CPPSTUDIO_AUXILIARY_SKILL_NAMES[@]}")
CODEX_HOME_DIR="${SYNC_CODEX_HOME:-${HOME}/.codex}"
SYSTEM_VALIDATOR="${CODEX_HOME_DIR}/skills/.system/skill-creator/scripts/quick_validate.py"
REPO_VALIDATOR="${ROOT_DIR}/scripts/quick_validate_skill.py"
PACKAGE_VALIDATOR="${ROOT_DIR}/scripts/validate_skill_package.py"
SKILL_LOAD_HYGIENE_VALIDATOR="${ROOT_DIR}/scripts/validate_skill_load_hygiene.py"
if [[ -z "${VALIDATOR:-}" ]]; then
    if [[ -f "${SYSTEM_VALIDATOR}" || -x "${SYSTEM_VALIDATOR}" ]]; then
        VALIDATOR="${SYSTEM_VALIDATOR}"
    else
        VALIDATOR="${REPO_VALIDATOR}"
    fi
fi
full=0
full_cuda_architectures="${CPPSTUDIO_FULL_CUDA_ARCHITECTURES:-native}"
skip_cuda_runtime_tests="${CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS:-0}"
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
  --full   Also scaffold a default Vulkan-only sample and an explicit CUDA-capable sample, then run
           CMake/CTest CPU, Vulkan, CUDA, mixed CUDA/Vulkan, and sanitizer quick lanes. Set
           CPPSTUDIO_FULL_CUDA_ARCHITECTURES on CI hosts without a discoverable NVIDIA GPU; set
           CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS=1 only when CUDA can be compiled but no CUDA runtime
           device is available.

Validator resolution:
  VALIDATOR override, target Codex system validator, then repo-local quick_validate_skill.py.
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
    "scripts/install_user_agents_relay.py"
    "scripts/managed_skills.sh"
    "scripts/bootstrap_code_map.py"
    "scripts/validate_code_map.py"
    "scripts/check_code_map_drift.py"
    "scripts/quick_validate_skill.py"
    "scripts/validate_skill_package.py"
    "scripts/validate_skill_load_hygiene.py"
    "scripts/test_important_instruction_ledger.py"
    "scripts/audit_donor_freshness.py"
    "scripts/render_trigger_eval_prompt.py"
    "scripts/validate_trigger_matrix.py"
    "scripts/validate_trigger_results.py"
    ".cppstudio/code-map-state.json"
    "CHANGELOG.md"
    "docs/CODEBASE_ARCHITECTURE_INDEX.md"
    "docs/CODEBASE_SUBSYSTEM_MANIFEST.json"
    "research/skill-packaging-agent-skills-mapping.md"
    "research/donor-library/trigger-results-2026-05-10-installed.json"
    "companion-skill-snippets/user-agents/cppstudio-relay.md"
    "skills/cpp-cuda-vulkan-studio/package-manifest.json"
    "skills/cpp-cuda-vulkan-studio/modules/technical-overlays.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/standard.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/investigative.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/governed.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/recovery.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/strict-doctrine-index.md"
    "skills/cpp-cuda-vulkan-studio/modules/process/strict-doctrine-reference.md"
    "skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/references/gui-options.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
    "skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/references/control-harness.md"
    "skills/cpp-cuda-vulkan-studio/modules/viewport-session-testing/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/viewport-session-testing/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/viewport-session-testing/references/viewport-session-testing.md"
    "skills/cpp-cuda-vulkan-studio/modules/important-instruction-ledger/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/important-instruction-ledger/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/important-instruction-ledger/scripts/important_instruction_ledger.py"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/references/strict-supervisor.md"
    "skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/scripts/slice_phase_report.py"
    "skills/cpp-cuda-vulkan-studio/modules/vulkan-compute-sync/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/vulkan-compute-sync/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/modern-cpp-cmake/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/modern-cpp-cmake/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/cuda-kernel-authoring/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/cuda-kernel-authoring/agents/openai.yaml"
    "skills/cpp-cuda-vulkan-studio/modules/gpu-profiling-workstation/GUIDE.md"
    "skills/cpp-cuda-vulkan-studio/modules/gpu-profiling-workstation/references/TOOL_INVENTORY.md"
    "docs/agent-context/SLICE_WATCHLIST.md"
    "research/donor-library/trigger-regression-checklist.md"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/.gitignore"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/CODEBASE_ARCHITECTURE_INDEX.md"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/CODEBASE_SUBSYSTEM_MANIFEST.json"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/GPU_OPTIMIZATION_LOOP.md"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/VIEWPORT_SESSION_TESTING.md"
    "skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/SUBSYSTEMS/viewport-session-testing.md"
    "skills/cpp-cuda-vulkan-studio/scripts/run_gpu_optimization_loop.py"
    "skills/cpp-cuda-vulkan-studio/scripts/run_viewport_session_smoke.py"
    "research/gpu-optimization-autokernel-mapping.md"
    "research/gpu-optimization-kernelagent-mapping.md"
    "research/gpu-optimization-agentsys-mapping.md"
)
for rel_path in "${required_repo_files[@]}"; do
    if [[ ! -e "${ROOT_DIR}/${rel_path}" ]]; then
        echo "Missing required package file: ${rel_path}" >&2
        exit 1
    fi
done
grep -q "scripts/bootstrap_code_map.py --enable --force" \
    "${SKILL_DIR}/assets/app-library-template/README.md"
grep -q "base invariants + one process state + relevant technical overlays" \
    "${CORE_MODULE}"
grep -q "Task size and consequence are separate" \
    "${CORE_MODULE}"
grep -q "A focused attempt is:" \
    "${CORE_MODULE}"
grep -q "Planning Harness is the sole owner" \
    "${CORE_MODULE}"
grep -q "Do not run reviews on a fixed slice cadence" \
    "${CORE_MODULE}"
grep -q "Recovery is an incident state" \
    "${CORE_MODULE}"
grep -q "temporarily replaces the active process" \
    "${CORE_MODULE}"
grep -q "One failed Standard hypothesis moves to Investigative, not Recovery" \
    "${CORE_MODULE}"
grep -q "Standard, Investigative, and Governed must not read it" \
    "${CORE_MODULE}"
grep -q "Standard does not require:" \
    "${SKILL_DIR}/modules/process/standard.md"
grep -q "one canonical proof route" \
    "${SKILL_DIR}/modules/process/investigative.md"
grep -q "Planning Harness is the only durable planning authority" \
    "${SKILL_DIR}/modules/process/governed.md"
grep -q "No fixed two-slice or three-slice review cadence" \
    "${SKILL_DIR}/modules/process/governed.md"
grep -q "Freeze new speculative implementation" \
    "${SKILL_DIR}/modules/process/recovery.md"
grep -q "Do not enter full Recovery merely because one test failed" \
    "${SKILL_DIR}/modules/process/recovery.md"
grep -q "Governed process controls stay inactive while Recovery is active" \
    "${SKILL_DIR}/modules/process/recovery.md"
grep -q "Technical overlays are independent of process state" \
    "${SKILL_DIR}/modules/technical-overlays.md"
grep -q "Standardized contracts require official semantics" \
    "${SKILL_DIR}/modules/technical-overlays.md"
grep -q "Planning Harness is the sole durable planning authority" \
    "${SKILL_DIR}/modules/cppstudio-project-planner/GUIDE.md"
grep -q "Research is decision-driven" \
    "${SKILL_DIR}/modules/cppstudio-project-planner/GUIDE.md"
grep -q "Do not use a fixed review cadence" \
    "${SKILL_DIR}/modules/cppstudio-supervisor/GUIDE.md"
grep -q "Phase telemetry is optional in ordinary supervision" \
    "${SKILL_DIR}/modules/cppstudio-supervisor/GUIDE.md"
grep -q "Hard realignment rule" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "Planning depth before source" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "Slice Phase Telemetry" \
    "${SKILL_DIR}/modules/cppstudio-supervisor/references/strict-supervisor.md"
grep -q "Level 4 - Slice Readiness" \
    "${SKILL_DIR}/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "Strict Doctrine Index" \
    "${SKILL_DIR}/modules/process/strict-doctrine-index.md"

for lean_module in \
    "${CORE_MODULE}" \
    "${SKILL_DIR}/modules/technical-overlays.md" \
    "${SKILL_DIR}/modules/process/standard.md" \
    "${SKILL_DIR}/modules/process/investigative.md" \
    "${SKILL_DIR}/modules/process/governed.md" \
    "${SKILL_DIR}/modules/process/recovery.md" \
    "${SKILL_DIR}/modules/cppstudio-project-planner/GUIDE.md" \
    "${SKILL_DIR}/modules/cppstudio-supervisor/GUIDE.md"; do
    if (( $(wc -l <"${lean_module}") > 180 )); then
        echo "Progressive-enforcement module is too large: ${lean_module}" >&2
        exit 1
    fi
done

grep -q "Planning depth contract:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "primary user-visible loop" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/GUIDE.md"
grep -q "shared tool substrate" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "Level 2 whole-product scaffold" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "just-in-time slice readiness packet" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "parallelization map" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "Do not hide the" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "Primary visible loop:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "First solid tool:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Whole-product scaffold:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Donor feature disposition matrix:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "before plan creation" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Slice readiness packet:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Parallelization map:" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Use these headings explicitly" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Product visible loop" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "Shared tool substrate" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "Capability priority ladder" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "Donor feature disposition matrix" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "For shader donors, this breakdown" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "Slice readiness packet" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "primary visible interaction loop" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
grep -q "GUI/product-surface" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "authoring model/source of truth" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "comparable current tools" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/project-intake.md"
grep -q "Authoring Model Choices" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/choice-matrix.md"
grep -q "agentic control harness in the initial plan by default" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "primary control and observation layer" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
grep -q "what the user is seeing" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
grep -q "visible link table has been shown" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
grep -q "I am UI-blind on this" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "harness-only or JSON-only" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "not progress on the reported visible bug" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
grep -q "JSON state change" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
grep -q "Hard realignment rule" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "realignment note" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "Direct foreground app launches are" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "sculpting-brushes.md" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "If GUI or interaction work stalls" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
grep -q "through \`ostm\` when the offscreen-test-manager" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/native-cpp-gui-hud/GUIDE.md"
grep -q "After two focused attempts or roughly 20 minutes" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
grep -q "viewport-session-testing" \
    "${SKILL_DIR}/SKILL.md"
grep -q "record/replay real widget" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/agentic-control-harness/GUIDE.md"
grep -q "User-facing verification is the acceptance surface" \
    "${SKILL_DIR}/modules/process/strict-doctrine-reference.md"
grep -q "visible record/stop/replay" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/viewport-session-testing/GUIDE.md"
grep -q "held-button or stylus-contact move samples" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/viewport-session-testing/references/viewport-session-testing.md"
grep -q "primary_button_down" \
    "${SKILL_DIR}/assets/app-library-template/include/{{PROJECT_NAME}}/viewport_session.hpp"
grep -q "primary_button_down" \
    "${SKILL_DIR}/assets/app-library-template/src/testing/viewport_session.cpp"
grep -q "visible record/stop/replay" \
    "${SKILL_DIR}/assets/app-library-template/docs/VIEWPORT_SESSION_TESTING.md"
grep -q "app-owned viewport-session testing lane" \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/references/strict-project-planner.md"
grep -q "Viewport Session Testing" \
    "${SKILL_DIR}/assets/app-library-template/docs/VIEWPORT_SESSION_TESTING.md"
grep -q "run_viewport_session_smoke.py" \
    "${SKILL_DIR}/assets/app-library-template/README.md"
grep -q "viewport-session" \
    "${SKILL_DIR}/assets/app-library-template/CMakeLists.txt"
grep -q "Pointer-to-stroke contract" \
    "${SKILL_DIR}/references/donor-library/profiles/blender-sculpt-brushes-study-only.md"
grep -q "Brush naming contract" \
    "${SKILL_DIR}/references/donor-library/profiles/blender-sculpt-brushes-study-only.md"
grep -q "Use target peer-tool vocabulary" \
    "${SKILL_DIR}/references/donor-library/sculpting-brushes.md"
grep -q "Standard/Sculpt displacement" \
    "${SKILL_DIR}/references/donor-library/profiles/blender-sculpt-brushes-study-only.md"
grep -q "roughly 20" \
    "${SKILL_DIR}/assets/app-library-template/docs/VALIDATION_PIPELINE.md"
grep -q "visible-loop proof" \
    "${SKILL_DIR}/assets/app-library-template/docs/VALIDATION_PIPELINE.md"
grep -q "shared substrate" \
    "${SKILL_DIR}/assets/app-library-template/docs/VALIDATION_PIPELINE.md"
if git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    for rel_path in "${required_repo_files[@]}"; do
        if ! git -C "${ROOT_DIR}" ls-files --error-unmatch "${rel_path}" >/dev/null 2>&1; then
            echo "Required package file is not tracked by git: ${rel_path}" >&2
            exit 1
        fi
    done
    maintainer_path_pattern="/home/tar""kan"
    # Scan ALL tracked text files (-I skips binaries): an extension allowlist
    # let an extensionless metadata file ship a maintainer-local absolute path.
    maintainer_path_hits="$(
        git -C "${ROOT_DIR}" grep -nI "${maintainer_path_pattern}" || true
    )"
    if [[ -n "${maintainer_path_hits}" ]]; then
        printf "%s\n" "${maintainer_path_hits}" >&2
        echo "Maintainer-local absolute paths must not be shipped in tracked public text" >&2
        exit 1
    fi
    private_provenance_hits=""
    # Public README sample labels such as "CUDA Groom Tool" and "Wetbrush Paint Simulation" are
    # allowed. This guard blocks compact private codenames, local paths, and private provenance
    # markers that should not leak into the reusable public package.
    private_provenance_patterns=(
        "Cuda""Groom""Tool"
        "Comfy""Native"
        "cuda""groom"
        "RT_""RESTART"
        "HAIR_""RENDER_""UPGRADE"
        ".codex/skills/""rt-"
        "unreal-hair-""reference"
        "unity-hair-""reference"
        # Private local repo/tooling names: CppStudio is public and must not name or hard-rely on
        # the maintainer's private repos. The camel-case forms below match only those repo names,
        # not the public skill names (e.g. the agentic-control-harness skill).
        "My""Tools/"
        "Agent""-Doctrine"
        "Native""Gui""Hud"
        "Agentic""Control""Harness"
        "PLANE""-2"
    )
    public_sample_labels=(
        "CUDA Groom Tool"
        "Wetbrush Paint Simulation"
    )
    for public_sample_label in "${public_sample_labels[@]}"; do
        for private_pattern in "${private_provenance_patterns[@]}"; do
            if [[ "${public_sample_label,,}" == "${private_pattern,,}" ]]; then
                echo "Public sample label is also listed as blocked private provenance: ${public_sample_label}" >&2
                exit 1
            fi
        done
    done
    for private_pattern in "${private_provenance_patterns[@]}"; do
        pattern_hits="$(
            git -C "${ROOT_DIR}" grep -niI -- "${private_pattern}" || true
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
    if ! grep -Fq -- "${expected}" "${output_file}"; then
        cat "${output_file}" >&2
        echo "Expected failure did not contain diagnostic '${expected}': ${description}" >&2
        exit 1
    fi
}

write_code_map_project_fixture() {
    local repo="$1"
    mkdir -p \
        "${repo}/.github/workflows" \
        "${repo}/benchmarks" \
        "${repo}/cmake" \
        "${repo}/docs" \
        "${repo}/include/studio_validate" \
        "${repo}/scripts" \
        "${repo}/shaders" \
        "${repo}/src/app" \
        "${repo}/src/core" \
        "${repo}/src/cuda" \
        "${repo}/src/render" \
        "${repo}/src/testing" \
        "${repo}/tests/unit"
    touch \
        "${repo}/CMakeLists.txt" \
        "${repo}/CMakePresets.json" \
        "${repo}/README.md" \
        "${repo}/docs/BENCHMARKS.md" \
        "${repo}/docs/DEVELOPMENT_ENVIRONMENT.md" \
        "${repo}/docs/GPU_OPTIMIZATION_LOOP.md" \
        "${repo}/docs/GPU_RUNNER_CI.md" \
        "${repo}/docs/VALIDATION_PIPELINE.md" \
        "${repo}/docs/VIEWPORT_SESSION_TESTING.md" \
        "${repo}/include/studio_validate/cuda_vector_add.hpp" \
        "${repo}/include/studio_validate/viewport_session.hpp" \
        "${repo}/src/app.cpp" \
        "${repo}/src/flat_app_state.hpp" \
        "${repo}/src/ui_panel_brush_slider_value_controller.h" \
        "${repo}/src/testing/viewport_session.cpp" \
        "${repo}/tests/unit/viewport_session_test.cpp" \
        "${repo}/scripts/run_viewport_session_smoke.py"
}

python3 "${VALIDATOR}" "${SKILL_DIR}"
python3 "${PACKAGE_VALIDATOR}" "${SKILL_DIR}"
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    auxiliary_skill_dir="${ROOT_DIR}/skills/${auxiliary_skill_name}"
    python3 "${VALIDATOR}" "${auxiliary_skill_dir}"
    python3 "${PACKAGE_VALIDATOR}" "${auxiliary_skill_dir}"
done
python3 "${SKILL_LOAD_HYGIENE_VALIDATOR}" --self-test
python3 "${SKILL_LOAD_HYGIENE_VALIDATOR}" \
    --skills-root "${ROOT_DIR}/skills"
expected_skill_dirs=("${SKILL_DIR}")
for auxiliary_skill_name in "${AUXILIARY_SKILL_NAMES[@]}"; do
    expected_skill_dirs+=("${ROOT_DIR}/skills/${auxiliary_skill_name}")
done
while IFS= read -r -d '' skill_file; do
    skill_dir="$(dirname "${skill_file}")"
    found_expected=0
    for expected_skill_dir in "${expected_skill_dirs[@]}"; do
        if [[ "${skill_dir}" == "${expected_skill_dir}" ]]; then
            found_expected=1
            break
        fi
    done
    if [[ "${found_expected}" != "1" ]]; then
        echo "Unexpected top-level CppStudio skill package: ${skill_dir#"${ROOT_DIR}"/}" >&2
        echo "Add it to scripts/managed_skills.sh with owner rationale, or move it out of skills/." >&2
        exit 1
    fi
done < <(find "${ROOT_DIR}/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -type f -print0)
if [[ -d "${CODEX_HOME_DIR}/skills" ]]; then
    if [[ "${CPPSTUDIO_STRICT_USER_SKILL_LOAD:-0}" == "1" ]]; then
        python3 "${SKILL_LOAD_HYGIENE_VALIDATOR}" \
            --skills-root "${CODEX_HOME_DIR}/skills"
    elif ! python3 "${SKILL_LOAD_HYGIENE_VALIDATOR}" \
        --skills-root "${CODEX_HOME_DIR}/skills"; then
        echo "Warning: user-level Codex skill-load hygiene failed; non-blocking for CppStudio source validation." >&2
        echo "Set CPPSTUDIO_STRICT_USER_SKILL_LOAD=1 to make the installed user skill root a fatal gate." >&2
    fi
else
    echo "Skill load hygiene skipped missing optional root: ${CODEX_HOME_DIR}/skills"
fi
if [[ -d "${ROOT_DIR}/.codex/skills" ]]; then
    while IFS= read -r -d '' project_skill; do
        python3 "${VALIDATOR}" "${project_skill}"
    done < <(find "${ROOT_DIR}/.codex/skills" -mindepth 1 -maxdepth 1 -type d -print0)
fi
pycache_tmp="$(mktemp -d "${VALIDATE_TMP}/pycache.XXXXXX")"
PYTHONPYCACHEPREFIX="${pycache_tmp}" python3 -m py_compile "${ROOT_DIR}"/scripts/*.py "${SKILL_DIR}"/scripts/*.py
PYTHONPYCACHEPREFIX="${pycache_tmp}" python3 -m py_compile \
    "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/scripts/slice_phase_report.py"
PYTHONDONTWRITEBYTECODE=1 python3 "${ROOT_DIR}/scripts/test_important_instruction_ledger.py"
phase_report_tmp="$(mktemp -d "${VALIDATE_TMP}/phase_report.XXXXXX")"
cat >"${phase_report_tmp}/phase.log" <<'EOF'
CPPSTUDIO_PHASE event=start phase=research ts=2026-05-30T01:00:00Z note="donor route"
CPPSTUDIO_PHASE event=end phase=research ts=2026-05-30T01:04:30Z status=ok
CPPSTUDIO_PHASE event=start phase=ostm_ui ts=2026-05-30T01:05:00Z
CPPSTUDIO_PHASE event=end phase=ostm_ui ts=2026-05-30T01:09:00Z classification=required_acceptance ostm_job=7578 artifact=/tmp/ui-proof status=ok
EOF
python3 "${ROOT_DIR}/skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/scripts/slice_phase_report.py" \
    --input "${phase_report_tmp}/phase.log" \
    --output "${phase_report_tmp}/report.md" \
    --require-markers
grep -q "Total measured time: \`510.0s\`" "${phase_report_tmp}/report.md"
grep -q "| ostm_ui | 240.0 | required_acceptance | ok | 7578 | /tmp/ui-proof |  |" \
    "${phase_report_tmp}/report.md"
quick_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/quick_validator.XXXXXX")"
mkdir -p "${quick_validator_tmp}/duplicate" "${quick_validator_tmp}/bad-openai/agents" "${quick_validator_tmp}/missing-reference"
cat >"${quick_validator_tmp}/duplicate/SKILL.md" <<'EOF'
---
name: duplicate-frontmatter
name: duplicate-frontmatter-again
description: Test fixture.
---
# Duplicate
EOF
expect_failure "quick validator duplicate frontmatter" "duplicate front matter field" \
    python3 "${ROOT_DIR}/scripts/quick_validate_skill.py" "${quick_validator_tmp}/duplicate"
cat >"${quick_validator_tmp}/bad-openai/SKILL.md" <<'EOF'
---
name: bad-openai
description: Test fixture.
---
# Bad OpenAI Metadata
EOF
cat >"${quick_validator_tmp}/bad-openai/agents/openai.yaml" <<'EOF'
interface:
  display_name: "Bad OpenAI"
  short_description: "Missing default prompt"
EOF
expect_failure "quick validator bad openai metadata" "missing required fields" \
    python3 "${ROOT_DIR}/scripts/quick_validate_skill.py" "${quick_validator_tmp}/bad-openai"
cat >"${quick_validator_tmp}/missing-reference/SKILL.md" <<'EOF'
---
name: missing-reference
description: Test fixture.
---
# Missing Reference

Use `scripts/missing.py`.
EOF
expect_failure "quick validator missing bundled reference" "bundled reference does not exist" \
    python3 "${ROOT_DIR}/scripts/quick_validate_skill.py" "${quick_validator_tmp}/missing-reference"
python3 - "${ROOT_DIR}/scripts/quick_validate_skill.py" <<'PY'
import importlib.util
import sys

sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("quick_validate_skill", sys.argv[1])
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
sys.modules[spec.name] = module
spec.loader.exec_module(module)

quoted = module.parse_simple_scalar(' "Use #include <vulkan/vulkan.hpp>" # trailing comment')
if quoted != "Use #include <vulkan/vulkan.hpp>":
    raise SystemExit(f"quoted hash scalar was parsed incorrectly: {quoted!r}")
unquoted = module.parse_simple_scalar("plain value # trailing comment")
if unquoted != "plain value":
    raise SystemExit(f"unquoted hash comment was parsed incorrectly: {unquoted!r}")
PY
rm -rf "${quick_validator_tmp}"
package_validator_write_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_write.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_write_tmp}/cpp-cuda-vulkan-studio"
rm -f "${package_validator_write_tmp}/cpp-cuda-vulkan-studio/package-manifest.json"
python3 "${PACKAGE_VALIDATOR}" \
    "${package_validator_write_tmp}/cpp-cuda-vulkan-studio" \
    --write-manifest
python3 "${PACKAGE_VALIDATOR}" "${package_validator_write_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_write_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
printf "\n# tamper\n" >>"${package_validator_tmp}/cpp-cuda-vulkan-studio/SKILL.md"
expect_failure "package validator detects tampering" "mismatch for SKILL.md" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_extra.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
touch "${package_validator_tmp}/cpp-cuda-vulkan-studio/references/extra-reference.md"
expect_failure "package validator detects unmanifested file" "unmanifested package file" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_missing.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -f "${package_validator_tmp}/cpp-cuda-vulkan-studio/agents/openai.yaml"
expect_failure "package validator detects missing file" "missing manifested file" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_unknown_top.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
python3 - "${package_validator_tmp}/cpp-cuda-vulkan-studio/package-manifest.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["generated_at"] = "not allowed"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "package validator rejects unknown manifest fields" "unexpected fields: generated_at" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_unknown_entry.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
python3 - "${package_validator_tmp}/cpp-cuda-vulkan-studio/package-manifest.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["files"][0]["local_note"] = "not allowed"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "package validator rejects unknown manifest file-entry fields" "unexpected fields: local_note" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_symlink.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
ln -s "../project-archetypes.md" \
    "${package_validator_tmp}/cpp-cuda-vulkan-studio/references/donor-library/symlink.md"
expect_failure "package validator rejects symlink" "symlink inside skill package is not allowed" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_forbidden_env.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
touch "${package_validator_tmp}/cpp-cuda-vulkan-studio/references/.env"
expect_failure "package validator refuses env files during manifest writes" "forbidden package file" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio" --write-manifest
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_forbidden_secret.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
touch "${package_validator_tmp}/cpp-cuda-vulkan-studio/references/private.pem"
expect_failure "package validator refuses secret-like files during manifest writes" "forbidden package artifact file" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio" --write-manifest
rm -rf "${package_validator_tmp}"
package_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/package_validator_forbidden_top.XXXXXX")"
cp -a "${SKILL_DIR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio"
touch "${package_validator_tmp}/cpp-cuda-vulkan-studio/README.md"
expect_failure "package validator refuses unsupported top-level files during manifest writes" "unsupported top-level package entry" \
    python3 "${PACKAGE_VALIDATOR}" "${package_validator_tmp}/cpp-cuda-vulkan-studio" --write-manifest
rm -rf "${package_validator_tmp}"
python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${ROOT_DIR}" --require-enabled
code_map_enable_tmp="$(mktemp -d "${VALIDATE_TMP}/code_map_enable.XXXXXX")"
write_code_map_project_fixture "${code_map_enable_tmp}"
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_enable_tmp}" --enable
test -x "${code_map_enable_tmp}/scripts/validate_code_map.py"
test -x "${code_map_enable_tmp}/scripts/check_code_map_drift.py"
python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_enable_tmp}" --require-enabled
git -C "${code_map_enable_tmp}" init -q
git -C "${code_map_enable_tmp}" config user.email "cppstudio@example.invalid"
git -C "${code_map_enable_tmp}" config user.name "CppStudio Validation"
python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" --require-enabled
git -C "${code_map_enable_tmp}" add .
git -C "${code_map_enable_tmp}" commit -q -m "baseline"
printf "int cppstudio_covered_change() { return 3; }\n" >>"${code_map_enable_tmp}/src/app.cpp"
drift_review_out="$(mktemp "${VALIDATE_TMP}/code_map_drift_review.XXXXXX")"
python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" --require-enabled \
    >"${drift_review_out}" 2>&1
grep -Fq "Map review note:" "${drift_review_out}"
grep -Fq "agent-tmux codex-code-map-sidecar" "${drift_review_out}"
grep -Fq "Review semantic code-map maintenance for changed routable paths" "${drift_review_out}"
grep -Fq "Worker action:" "${drift_review_out}"
drift_strict_review_out="$(mktemp "${VALIDATE_TMP}/code_map_drift_strict_review.XXXXXX")"
if python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" --require-enabled --strict-review \
    >"${drift_strict_review_out}" 2>&1; then
    cat "${drift_strict_review_out}" >&2
    echo "Expected strict code map drift review to fail until semantic map review is acknowledged" >&2
    exit 1
fi
grep -Fq "Strict review mode: map review is unresolved" "${drift_strict_review_out}"
grep -Fq "Do not ask the user to prompt the map update" "${drift_strict_review_out}"
fake_sidecar_bin="${VALIDATE_TMP}/fake-sidecar-bin"
fake_sidecar_log="${VALIDATE_TMP}/fake-sidecar-launch.log"
fake_sidecar_snapshots="${VALIDATE_TMP}/fake-sidecar-snapshots"
mkdir -p "${fake_sidecar_bin}"
cat >"${fake_sidecar_bin}/agent-tmux" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"${CPPSTUDIO_FAKE_AGENT_TMUX_LOG:?}"
if [[ "$1" != "codex-code-map-sidecar" ]]; then
    echo "unexpected agent-tmux command: $*" >&2
    exit 64
fi
if [[ ! -f "$2/SIDECAR_SNAPSHOT_ANCHOR.txt" ]]; then
    echo "missing sidecar snapshot anchor file" >&2
    exit 65
fi
if [[ ! -f "$2/src/app.cpp" ]]; then
    echo "missing copied source file in sidecar snapshot" >&2
    exit 66
fi
SH
chmod +x "${fake_sidecar_bin}/agent-tmux"
drift_auto_sidecar_out="$(mktemp "${VALIDATE_TMP}/code_map_drift_auto_sidecar.XXXXXX")"
if PATH="${fake_sidecar_bin}:${PATH}" \
    CPPSTUDIO_FAKE_AGENT_TMUX_LOG="${fake_sidecar_log}" \
    CPPSTUDIO_CODE_MAP_SIDECAR_SNAPSHOT_ROOT="${fake_sidecar_snapshots}" \
    python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" \
        --require-enabled --strict-review --launch-sidecar auto \
        >"${drift_auto_sidecar_out}" 2>&1; then
    cat "${drift_auto_sidecar_out}" >&2
    echo "Expected strict code map drift review to remain unresolved after launching sidecar" >&2
    exit 1
fi
grep -Fq "Code-map sidecar auto-launch:" "${drift_auto_sidecar_out}"
grep -Fq "frozen snapshot:" "${drift_auto_sidecar_out}"
grep -Fq "agent-tmux codex-code-map-sidecar" "${drift_auto_sidecar_out}"
grep -Fq "Review semantic code-map maintenance for changed routable paths" "${fake_sidecar_log}"
find "${fake_sidecar_snapshots}" -name SIDECAR_SNAPSHOT_ANCHOR.txt -print -quit | grep -q .
drift_ack_review_out="$(mktemp "${VALIDATE_TMP}/code_map_drift_ack_review.XXXXXX")"
python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" \
    --require-enabled --strict-review --reviewed-no-map-change \
    >"${drift_ack_review_out}" 2>&1
grep -Fq "Map semantic review acknowledged" "${drift_ack_review_out}"
if grep -Fq "Code-map maintenance action required" "${drift_ack_review_out}"; then
    cat "${drift_ack_review_out}" >&2
    echo "Acknowledged no-map-change drift review must not print unresolved maintenance action" >&2
    exit 1
fi
if grep -Fq "agent-tmux codex-code-map-sidecar" "${drift_ack_review_out}"; then
    cat "${drift_ack_review_out}" >&2
    echo "Acknowledged no-map-change drift review must not print sidecar launch command" >&2
    exit 1
fi
mkdir -p "${code_map_enable_tmp}/tools"
printf "int cppstudio_unrouted_tool() { return 7; }\n" >"${code_map_enable_tmp}/tools/new_tool.cpp"
drift_failure_out="$(mktemp "${VALIDATE_TMP}/code_map_drift_failure.XXXXXX")"
if python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" --require-enabled \
    >"${drift_failure_out}" 2>&1; then
    cat "${drift_failure_out}" >&2
    echo "Expected code map drift check to fail for unrouted source path" >&2
    exit 1
fi
if grep -q "Traceback" "${drift_failure_out}"; then
    cat "${drift_failure_out}" >&2
    echo "Code map drift failure produced a Python traceback" >&2
    exit 1
fi
grep -Fq "tools/new_tool.cpp" "${drift_failure_out}"
grep -Fq "agent-tmux codex-code-map-sidecar" "${drift_failure_out}"
grep -Fq "Code-map maintenance action required" "${drift_failure_out}"
grep -Fq "Update code-map routes for uncovered paths" "${drift_failure_out}"
python3 - "${code_map_enable_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
for subsystem in manifest["subsystems"]:
    if subsystem["id"] == "app_core":
        subsystem["primary_paths"].append("tools")
        break
else:
    raise SystemExit("missing app_core subsystem")
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
python3 - "${code_map_enable_tmp}/docs/SUBSYSTEMS/app-core.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
lines = path.read_text(encoding="utf-8").splitlines()
out = []
inserted = False
in_primary = False
for line in lines:
    if line.startswith("## "):
        if in_primary and not inserted:
            out.append("- `tools`")
            inserted = True
        in_primary = line.strip() == "## Primary Paths"
    out.append(line)
if in_primary and not inserted:
    out.append("- `tools`")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_enable_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/check_code_map_drift.py" "${code_map_enable_tmp}" --require-enabled
code_map_stale_tmp="$(mktemp -d "${VALIDATE_TMP}/code_map_stale.XXXXXX")"
write_code_map_project_fixture "${code_map_stale_tmp}"
printf "# stale architecture index\n" >"${code_map_stale_tmp}/docs/CODEBASE_ARCHITECTURE_INDEX.md"
printf '{"version":1,"skill_root":"skills","router_doc":"docs/CODEBASE_ARCHITECTURE_INDEX.md","subsystems":[]}\n' \
    >"${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json"
expect_failure "code map enable over stale files" "Refusing to enable a CppStudio code map over existing map files" \
    python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable
if [[ -e "${code_map_stale_tmp}/.cppstudio/code-map-state.json" ]]; then
    find "${code_map_stale_tmp}" -maxdepth 3 -print >&2
    echo "code map enable wrote enabled state after refusing stale files" >&2
    exit 1
fi
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["subsystems"][0]["id"] = "stale_subsystem"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "generated code map subsystem mismatch" "generated map subsystem ids must be" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_ARCHITECTURE_INDEX.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("./SUBSYSTEMS/build-and-presets.md", "./SUBSYSTEMS/stale-build-and-presets.md")
path.write_text(text, encoding="utf-8")
PY
expect_failure "generated code map index mismatch" "router_doc is not linked from index" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/.cppstudio/code-map-state.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
state = json.loads(path.read_text(encoding="utf-8"))
state["index"] = "/tmp/absolute-code-map-index.md"
path.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map state rejects absolute paths" "path must be relative" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["state"] = "docs/not-code-map-state.json"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map manifest validates root state path" "state must be" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["router_doc"] = "docs/not-the-architecture-index.md"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map manifest validates root router doc" "router_doc must be" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["subsystems"][0]["router_doc"] = "../outside.md"
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map manifest rejects escaping paths" "path must not contain '..'" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_ARCHITECTURE_INDEX.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text + "\n- Escaped: [outside](../../outside.md)\n"
path.write_text(text, encoding="utf-8")
PY
expect_failure "code map index rejects escaping local links" "path must not contain '..'" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["subsystems"][0]["primary_paths"].append("README.md")
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map validates router doc primary path parity" "router_doc Primary Paths differ from manifest primary_paths" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/bootstrap_code_map.py" "${code_map_stale_tmp}" --enable --force
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["subsystems"][0]["primary_paths"].append("docs/SUBSYSTEMS/*.md")
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
python3 - "${code_map_stale_tmp}/docs/SUBSYSTEMS/build-and-presets.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
lines = path.read_text(encoding="utf-8").splitlines()
out = []
inserted = False
in_primary = False
for line in lines:
    if line.startswith("## "):
        if in_primary and not inserted:
            out.append("- `docs/SUBSYSTEMS/*.md`")
            inserted = True
        in_primary = line.strip() == "## Primary Paths"
    out.append(line)
if in_primary and not inserted:
    out.append("- `docs/SUBSYSTEMS/*.md`")
path.write_text("\n".join(out) + "\n", encoding="utf-8")
PY
python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
touch "${VALIDATE_TMP}/outside-code-map-glob.md"
python3 - "${code_map_stale_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["subsystems"][0]["primary_paths"] = ["../*.md"]
path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "code map manifest rejects escaping globs" "path must not contain '..'" \
    python3 "${ROOT_DIR}/scripts/validate_code_map.py" "${code_map_stale_tmp}" --require-enabled
python3 "${ROOT_DIR}/scripts/generate_donor_checkout_manifest.py" "${ROOT_DIR}" --check

python3 "${ROOT_DIR}/scripts/validate_donor_library.py" \
    "${SKILL_DIR}/references/donor-library" \
    --reference-root "${SKILL_DIR}/references"
donor_audit_fixture="${VALIDATE_TMP}/donor_audit_fixture"
mkdir -p "${donor_audit_fixture}/profiles"
cat > "${donor_audit_fixture}/profiles/singular.md" <<'EOF'
# Singular Source Fixture

Source: https://example.com/singular
Last checked: 2026-01-01
Tier: `study-only`
EOF
cat > "${donor_audit_fixture}/profiles/plural.md" <<'EOF'
# Plural Sources Fixture

Sources: https://example.com/one https://example.com/two and
https://example.com/three plus
https://example.com/four
Last checked: 2026-01-01
Tier: `study-only`
EOF
python3 "${ROOT_DIR}/scripts/audit_donor_freshness.py" \
    "${donor_audit_fixture}" \
    --summary-only \
    --json-output "${VALIDATE_TMP}/donor_audit_fixture.json"
python3 - "${VALIDATE_TMP}/donor_audit_fixture.json" <<'PY'
import json
import sys
from pathlib import Path

payload = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
issues = payload["issue_counts"]
if issues.get("missing_source_url"):
    raise SystemExit(f"donor freshness audit failed to parse Source/Sources URLs: {issues}")
plural = next(report for report in payload["reports"] if report["path"] == "profiles/plural.md")
if len(plural["source_urls"]) != 4:
    raise SystemExit(f"expected four plural source URLs, got {plural['source_urls']}")
PY
python3 "${ROOT_DIR}/scripts/audit_donor_freshness.py" \
    "${SKILL_DIR}/references/donor-library" \
    --summary-only
if rg -q 'AUXILIARY_SKILL_NAMES=\("[^$]' \
    "${ROOT_DIR}/scripts/rollout_to_codex.sh" \
    "${ROOT_DIR}/scripts/watch_to_codex.sh"; then
    echo "rollout/watch scripts must source scripts/managed_skills.sh instead of declaring skill arrays" >&2
    exit 1
fi
grep -q "CPPSTUDIO_SYNC_TMP_ROOT" "${ROOT_DIR}/scripts/sync_to_codex.sh"
grep -q "CPPSTUDIO_SYNC_BACKUP_ROOT" "${ROOT_DIR}/scripts/sync_to_codex.sh"
if rg -q 'mktemp -d "\$\{target_parent\}/|\$\{target_resolved\}\.backup' "${ROOT_DIR}/scripts/sync_to_codex.sh"; then
    echo "sync_to_codex.sh must not stage or back up packages under the scanned skills root" >&2
    exit 1
fi
python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}"
python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" \
    "${ROOT_DIR}/research/donor-library/trigger-results-2026-05-10-installed.json" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode portable-installed \
    --require-case realtime-raytracing-framework-donors \
    --require-case missing-donor-promotion-boundary \
    --require-case agentic-control-harness-default \
    --require-case grooming-brush-authoring-donors \
    --require-case sculpting-brush-high-poly-donors \
    --require-case code-map-sidecar-maintenance-lane
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
grep -q "Treat forbidden paths as no-touch paths" "${trigger_lookup_md}"
grep -q "existence-check them" "${trigger_lookup_md}"
for trigger_tag in dcc materials volumes vfx games infrastructure gui planning harness viewport code-map; do
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
        gui)
            grep -q "native-gui-hud.md" "${trigger_tag_md}"
            grep -q "native-cpp-gui-hud" "${trigger_tag_md}"
            grep -q "visible link table" "${trigger_tag_md}"
            grep -q "UI convention table" "${trigger_tag_md}"
            grep -q "icon/text affordance checks" "${trigger_tag_md}"
            grep -q "screenshot product-fit scorecard" "${trigger_tag_md}"
            grep -q "UI-blind status" "${trigger_tag_md}"
            grep -q "harness-only or JSON-only" "${trigger_tag_md}"
            ;;
        planning)
            grep -q "cppstudio-project-planner" "${trigger_tag_md}"
            grep -q "project-intake.md" "${trigger_tag_md}"
            grep -q "pre-plan research brief before asking the user to switch to Plan mode" "${trigger_tag_md}"
            grep -q "extensive state-of-the-art upstream web ceiling check" "${trigger_tag_md}"
            grep -q "Project Dos And Don'ts" "${trigger_tag_md}"
            grep -q "prefer the best available option unless the user asks for a lighter route" "${trigger_tag_md}"
            grep -q "agentic-control-harness" "${trigger_tag_md}"
            grep -q "before asking the user for routine manual testing" "${trigger_tag_md}"
            grep -q "UI-blind failure reporting" "${trigger_tag_md}"
            ;;
        harness)
            grep -q "agentic-control-harness" "${trigger_tag_md}"
            grep -q "cppstudio-supervisor" "${trigger_tag_md}"
            grep -q "visual/UI or viewport evidence" "${trigger_tag_md}"
            grep -q "exact readiness invariants" "${trigger_tag_md}"
            grep -q "route registry/docs reconciliation" "${trigger_tag_md}"
            grep -q "UI action/affordance inventory" "${trigger_tag_md}"
            grep -q "before asking the user for manual verification" "${trigger_tag_md}"
            ;;
        viewport)
            grep -q "viewport-session-testing" "${trigger_tag_md}"
            grep -q "recorded or replayed user-equivalent session" "${trigger_tag_md}"
            grep -q "before/after report" "${trigger_tag_md}"
            grep -q "Backend-only commands" "${trigger_tag_md}"
            ;;
        code-map)
            grep -q "bootstrap_code_map.py" "${trigger_tag_md}"
            grep -q "check_code_map_drift.py" "${trigger_tag_md}"
            grep -q "validate_code_map.py" "${trigger_tag_md}"
            grep -q "read-only fresh-agent or subagent routing smoke" "${trigger_tag_md}"
            grep -q "non-destructive existing-project readiness audit" "${trigger_tag_md}"
            grep -q "code-map-only sidecar" "${trigger_tag_md}"
            grep -q "fixed checkpoint" "${trigger_tag_md}"
            grep -q "isolated worktree" "${trigger_tag_md}"
            grep -q "same-worktree edits require a serialized handoff" "${trigger_tag_md}"
            grep -q "final reconcile before staging or committing" "${trigger_tag_md}"
            ;;
        *)
            grep -q "${trigger_tag}" "${trigger_tag_md}"
            ;;
    esac
done
code_map_case_checks=(
    "greenfield-code-map-pre-source-gate|hard pre-source gate|accepted, declined, or explicitly deferred|bootstrap_code_map.py|code-map choice as acceptance"
    "code-map-existing-project-bootstrap|non-destructive existing-project readiness audit|bootstrap_code_map.py|check_code_map_drift.py|read-only fresh-agent or subagent routing smoke"
    "enabled-code-map-maintenance-closeout|check_code_map_drift.py|validate_code_map.py|CODEBASE_ARCHITECTURE_INDEX.md|AGENTS.md"
    "code-map-sidecar-maintenance-lane|code-map-only sidecar|isolated worktree|same-worktree edits require a serialized handoff|verified slice commit"
    "code-map-routing-smoke-proof|schema validation alone|read-only fresh-agent or subagent routing smoke|first confident subsystem route|pass/partial/fail"
)
for case_check in "${code_map_case_checks[@]}"; do
    IFS="|" read -r case_name first_pattern second_pattern third_pattern fourth_pattern <<<"${case_check}"
    trigger_case_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_${case_name}.XXXXXX.md")"
    python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
        "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
        --repo-root "${ROOT_DIR}" \
        --case "${case_name}" >"${trigger_case_md}"
    grep -q "## 1. ${case_name}" "${trigger_case_md}"
    grep -q "${first_pattern}" "${trigger_case_md}"
    grep -q "${second_pattern}" "${trigger_case_md}"
    grep -q "${third_pattern}" "${trigger_case_md}"
    grep -q "${fourth_pattern}" "${trigger_case_md}"
done
supervisor_case_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_cppstudio_supervisor.XXXXXX.md")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --case cppstudio-supervisor-worker-lane \
    --case solo-native-gpu-implementation-no-supervisor >"${supervisor_case_md}"
grep -q "cppstudio-supervisor-worker-lane" "${supervisor_case_md}"
grep -q "skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/GUIDE.md" "${supervisor_case_md}"
grep -q "fresh-context reviewers" "${supervisor_case_md}"
grep -q "Rewind readiness" "${supervisor_case_md}"
grep -q "solo-native-gpu-implementation-no-supervisor" "${supervisor_case_md}"
grep -q "Do not load cppstudio-supervisor" "${supervisor_case_md}"
trigger_negative_md="$(mktemp "${VALIDATE_TMP}/trigger_eval_negative.XXXXXX.md")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --tag negative \
    --installed-paths \
    --codex-home "${ROOT_DIR}/.codex-eval" >"${trigger_negative_md}"
grep -q "${ROOT_DIR}/.codex-eval/skills/cpp-cuda-vulkan-studio" "${trigger_negative_md}"
grep -q "Expected paths:\\*\\* none" "${trigger_negative_md}"
trigger_result_template="$(mktemp "${VALIDATE_TMP}/trigger_eval_result.XXXXXX.json")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --case python-negative-control \
    --write-result-template "${trigger_result_template}" >/dev/null
python3 - "${trigger_result_template}" <<'PY'
import json
import sys
from pathlib import Path

data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
case = data["cases"][0]
if data["schema_version"] != 1 or data["case_count"] != 1:
    raise SystemExit("bad trigger result template header")
if case["name"] != "python-negative-control":
    raise SystemExit("bad trigger result template case name")
if case["expected_paths"]:
    raise SystemExit("negative trigger result template should have no expected paths")
if case["result"]["verdict"] != "pending":
    raise SystemExit("trigger result template should start pending")
PY
python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_result_template}" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode repo \
    --require-case python-negative-control
trigger_bad_result="$(mktemp "${VALIDATE_TMP}/trigger_eval_bad_result.XXXXXX.json")"
python3 - "${trigger_result_template}" "${trigger_bad_result}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
case = data["cases"][0]
case["expected_paths"] = ["skills/cpp-cuda-vulkan-studio/SKILL.md"]
case["result"] = {
    "selected_skills": ["cpp-cuda-vulkan-studio"],
    "opened_files": [],
    "forbidden_paths_used": False,
    "verdict": "pass",
    "notes": "Fixture intentionally records a pass without opening the expected file.",
}
data["run"] = {
    "run_date": "2026-05-10",
    "agent_environment": "validation fixture",
    "render_command": "validation fixture",
}
target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "trigger result pass requires expected paths" "pass missing expected opened path" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_bad_result}" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode repo \
    --require-case python-negative-control
trigger_unanchored_result="$(mktemp "${VALIDATE_TMP}/trigger_eval_unanchored_result.XXXXXX.json")"
python3 - "${trigger_result_template}" "${trigger_unanchored_result}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
case = data["cases"][0]
case["result"] = {
    "selected_skills": ["cpp-cuda-vulkan-studio"],
    "opened_files": ["skills/cpp-cuda-vulkan-studio/SKILL.md"],
    "forbidden_paths_used": False,
    "verdict": "pass",
    "notes": "Fixture intentionally records an unanchored pass.",
}
data["run"] = {
    "run_date": "2026-05-10",
    "agent_environment": "validation fixture",
    "render_command": "validation fixture",
}
target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "trigger result pass requires matrix anchoring" "pass cases require --matrix anchoring" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_unanchored_result}"
trigger_positive_template="$(mktemp "${VALIDATE_TMP}/trigger_eval_positive_result.XXXXXX.json")"
python3 "${ROOT_DIR}/scripts/render_trigger_eval_prompt.py" \
    "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --case vulkan-default-greenfield \
    --write-result-template "${trigger_positive_template}" >/dev/null
trigger_deleted_expected="$(mktemp "${VALIDATE_TMP}/trigger_eval_deleted_expected.XXXXXX.json")"
python3 - "${trigger_positive_template}" "${trigger_deleted_expected}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
case = data["cases"][0]
case["expected_paths"] = []
case["result"] = {
    "selected_skills": ["cpp-cuda-vulkan-studio"],
    "opened_files": ["skills/cpp-cuda-vulkan-studio/SKILL.md"],
    "forbidden_paths_used": False,
    "verdict": "pass",
    "notes": "Fixture intentionally deletes the matrix expected paths.",
}
data["run"] = {
    "run_date": "2026-05-10",
    "agent_environment": "validation fixture",
    "render_command": "validation fixture",
}
target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "trigger result cannot delete matrix expected paths" "expected_paths do not match trigger matrix" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_deleted_expected}" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode repo \
    --require-case vulkan-default-greenfield
trigger_wrong_mode="$(mktemp "${VALIDATE_TMP}/trigger_eval_wrong_mode.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-results-2026-05-10-installed.json" "${trigger_wrong_mode}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["path_mode"] = "repo"
target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "installed trigger result requires portable-installed mode" "does not match required" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_wrong_mode}" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode portable-installed \
    --require-case realtime-raytracing-framework-donors \
    --require-case missing-donor-promotion-boundary \
    --require-case agentic-control-harness-default \
    --require-case grooming-brush-authoring-donors \
    --require-case sculpting-brush-high-poly-donors \
    --require-case code-map-sidecar-maintenance-lane
trigger_missing_case="$(mktemp "${VALIDATE_TMP}/trigger_eval_missing_case.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-results-2026-05-10-installed.json" "${trigger_missing_case}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
data["cases"] = [case for case in data["cases"] if case["name"] != "code-map-sidecar-maintenance-lane"]
data["case_count"] = len(data["cases"])
target.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
expect_failure "installed trigger result requires all claimed cases" "missing required result case" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_results.py" "${trigger_missing_case}" \
    --matrix "${ROOT_DIR}/research/donor-library/trigger-matrix.json" \
    --repo-root "${ROOT_DIR}" \
    --expected-path-mode portable-installed \
    --require-case realtime-raytracing-framework-donors \
    --require-case missing-donor-promotion-boundary \
    --require-case agentic-control-harness-default \
    --require-case grooming-brush-authoring-donors \
    --require-case sculpting-brush-high-poly-donors \
    --require-case code-map-sidecar-maintenance-lane
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
rollout_aux_symlink_tmp="$(mktemp -d "${VALIDATE_TMP}/rollout_aux_symlink.XXXXXX")"
mkdir -p \
    "${rollout_aux_symlink_tmp}/codex/skills" \
    "${rollout_aux_symlink_tmp}/external-aux-target"
touch "${rollout_aux_symlink_tmp}/external-aux-target/EXTERNAL_MARKER"
ln -s "${rollout_aux_symlink_tmp}/external-aux-target" \
    "${rollout_aux_symlink_tmp}/codex/skills/native-cpp-gui-hud"
expect_failure "rollout symlinked legacy skill target" "Refusing symlinked legacy top-level skill target" \
    env SYNC_CODEX_HOME="${rollout_aux_symlink_tmp}/codex" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/rollout_to_codex.sh"
test -L "${rollout_aux_symlink_tmp}/codex/skills/native-cpp-gui-hud"
test -f "${rollout_aux_symlink_tmp}/external-aux-target/EXTERNAL_MARKER"
rm -rf "${rollout_aux_symlink_tmp}"
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
sync_fresh_home_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_fresh_home.XXXXXX")"
sync_fresh_home="${sync_fresh_home_tmp}/fresh-codex-home"
sync_fresh_out="$(mktemp "${VALIDATE_TMP}/sync_fresh_home.XXXXXX.out")"
env -u VALIDATOR \
    HOME="${sync_fresh_home_tmp}/empty-home" \
    SYNC_CODEX_HOME="${sync_fresh_home}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh" --dry-run >"${sync_fresh_out}"
grep -q "Dry run complete" "${sync_fresh_out}"
if [[ -e "${sync_fresh_home}" ]]; then
    find "${sync_fresh_home_tmp}" -maxdepth 3 -print >&2
    echo "sync_to_codex.sh --dry-run with repo-local validator fallback created the target Codex home" >&2
    exit 1
fi
rm -rf "${sync_fresh_home_tmp}"
sync_audit_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_audit.XXXXXX")"
sync_audit_home="${sync_audit_tmp}/codex"
sync_audit_log="${sync_audit_tmp}/audit.jsonl"
sync_audit_out="$(mktemp "${VALIDATE_TMP}/sync_audit.XXXXXX.out")"
env SYNC_CODEX_HOME="${sync_audit_home}" \
    CPPSTUDIO_AUDIT_LOG="${sync_audit_log}" \
    VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh" >"${sync_audit_out}"
grep -q "Synced" "${sync_audit_out}"
python3 - "${sync_audit_log}" "${sync_audit_home}/skills/cpp-cuda-vulkan-studio" <<'PY'
import json
import sys
from pathlib import Path

entries = [json.loads(line) for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()]
if len(entries) != 1:
    raise SystemExit(f"expected one sync audit entry, found {len(entries)}")
entry = entries[0]
if entry.get("action") != "sync" or entry.get("success") is not True:
    raise SystemExit(f"unexpected sync audit entry: {entry}")
if entry.get("target") != sys.argv[2]:
    raise SystemExit(f"sync audit target mismatch: {entry.get('target')} != {sys.argv[2]}")
if not entry.get("package_manifest_sha256"):
    raise SystemExit("sync audit entry missing package manifest hash")
PY
rm -rf "${sync_audit_tmp}"
sync_rollback_tmp="$(mktemp -d "${VALIDATE_TMP}/sync_rollback.XXXXXX")"
sync_rollback_home="${sync_rollback_tmp}/codex"
sync_rollback_target="${sync_rollback_home}/skills/cpp-cuda-vulkan-studio"
mkdir -p "${sync_rollback_target}" "${sync_rollback_tmp}/validator"
cat >"${sync_rollback_target}/SKILL.md" <<'EOF'
---
name: cpp-cuda-vulkan-studio
description: Existing installed skill.
---
# Existing Installed Skill
EOF
touch "${sync_rollback_target}/OLD_INSTALL_MARKER"
cat >"${sync_rollback_tmp}/validator/quick_validate.py" <<'PY'
#!/usr/bin/env python3
import os
import subprocess
import sys

target = os.environ.get("FAIL_SYNC_TARGET")
if target and sys.argv[1:] and os.path.realpath(sys.argv[1]) == os.path.realpath(target):
    print("intentional final target validation failure", file=sys.stderr)
    raise SystemExit(42)
raise SystemExit(subprocess.call([sys.executable, os.environ["REPO_VALIDATOR_PATH"], *sys.argv[1:]]))
PY
chmod +x "${sync_rollback_tmp}/validator/quick_validate.py"
expect_failure "sync rollback after final validation failure" "intentional final target validation failure" \
    env SYNC_CODEX_HOME="${sync_rollback_home}" \
    FAIL_SYNC_TARGET="${sync_rollback_target}" \
    REPO_VALIDATOR_PATH="${ROOT_DIR}/scripts/quick_validate_skill.py" \
    VALIDATOR="${sync_rollback_tmp}/validator/quick_validate.py" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh"
test -f "${sync_rollback_target}/OLD_INSTALL_MARKER"
grep -q "Existing Installed Skill" "${sync_rollback_target}/SKILL.md"
sync_backup_fail_home="${sync_rollback_tmp}/backup-fail-codex"
sync_backup_fail_target="${sync_backup_fail_home}/skills/cpp-cuda-vulkan-studio"
sync_backup_fail_fakebin="${sync_rollback_tmp}/fake-bin"
mkdir -p "${sync_backup_fail_target}" "${sync_backup_fail_fakebin}"
cat >"${sync_backup_fail_target}/SKILL.md" <<'EOF'
---
name: cpp-cuda-vulkan-studio
description: Existing installed skill.
---
# Existing Installed Skill Before Backup Failure
EOF
touch "${sync_backup_fail_target}/OLD_BACKUP_FAIL_MARKER"
mv_real="$(command -v mv)"
cat >"${sync_backup_fail_fakebin}/mv" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${FAIL_BACKUP_SOURCE:-}" && "$#" -eq 2 && "$1" == "${FAIL_BACKUP_SOURCE}" && "$2" == *".backup."* ]]; then
    echo "intentional backup move failure" >&2
    exit 44
fi
exec "${MV_REAL}" "$@"
SH
chmod +x "${sync_backup_fail_fakebin}/mv"
expect_failure "sync preserves existing target after backup move failure" "intentional backup move failure" \
    env PATH="${sync_backup_fail_fakebin}:${PATH}" \
    MV_REAL="${mv_real}" \
    FAIL_BACKUP_SOURCE="${sync_backup_fail_target}" \
    SYNC_CODEX_HOME="${sync_backup_fail_home}" \
    VALIDATOR="${ROOT_DIR}/scripts/quick_validate_skill.py" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh"
test -f "${sync_backup_fail_target}/OLD_BACKUP_FAIL_MARKER"
grep -q "Existing Installed Skill Before Backup Failure" "${sync_backup_fail_target}/SKILL.md"
rm -rf "${sync_rollback_tmp}"
if [[ "${CPPSTUDIO_SKIP_ROLLOUT_VALIDATOR_REGRESSION:-0}" != "1" ]]; then
    rollout_validator_tmp="$(mktemp -d "${VALIDATE_TMP}/rollout_validator.XXXXXX")"
    rollout_codex_home="${rollout_validator_tmp}/codex"
    rollout_validator_dir="${rollout_codex_home}/skills/.system/skill-creator/scripts"
    rollout_marker="${rollout_validator_tmp}/validator-used.txt"
    rollout_audit_log="${rollout_validator_tmp}/audit.jsonl"
    mkdir -p \
        "${rollout_validator_dir}" \
        "${rollout_codex_home}/skills/native-cpp-gui-hud"
    touch "${rollout_codex_home}/skills/native-cpp-gui-hud/LEGACY_MARKER"
    cat >"${rollout_validator_dir}/quick_validate.py" <<'PY'
#!/usr/bin/env python3
import os
import subprocess
import sys

with open(os.environ["VALIDATOR_MARKER"], "a", encoding="utf-8") as marker:
    marker.write("used\n")

raise SystemExit(
    subprocess.call([sys.executable, os.environ["REPO_VALIDATOR_PATH"], *sys.argv[1:]])
)
PY
    chmod +x "${rollout_validator_dir}/quick_validate.py"
    env -u VALIDATOR \
        HOME="${rollout_validator_tmp}/empty-home" \
        SYNC_CODEX_HOME="${rollout_codex_home}" \
        CPPSTUDIO_AUDIT_LOG="${rollout_audit_log}" \
        VALIDATOR_MARKER="${rollout_marker}" \
        REPO_VALIDATOR_PATH="${ROOT_DIR}/scripts/quick_validate_skill.py" \
        "${ROOT_DIR}/scripts/rollout_to_codex.sh" >"${rollout_validator_tmp}/rollout.out"
    grep -q "used" "${rollout_marker}"
    grep -q "Rolled out" "${rollout_validator_tmp}/rollout.out"
    test ! -e "${rollout_codex_home}/skills/native-cpp-gui-hud"
    python3 - "${rollout_audit_log}" "${rollout_codex_home}/skills/cpp-cuda-vulkan-studio" <<'PY'
import json
import sys
from pathlib import Path

entries = [json.loads(line) for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines()]
actions = [(entry.get("action"), entry.get("success"), entry.get("target")) for entry in entries]
if ("sync", True, sys.argv[2]) not in actions:
    raise SystemExit(f"sync success audit missing from rollout: {actions}")
if ("rollout", True, sys.argv[2]) not in actions:
    raise SystemExit(f"rollout success audit missing: {actions}")
if not all(entry.get("package_manifest_sha256") for entry in entries):
    raise SystemExit("rollout audit entry missing package manifest hash")
PY
    rm -rf "${rollout_validator_tmp}"

fi
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
donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate_wrapped_source_tier.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
python3 - "${donor_tmp}/donor-library/gltf-runtime-assets.md" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = "| [tinygltf](https://github.com/syoyo/tinygltf) | safe-donor |"
new = "| [tinygltf](https://github.com/syoyo/tinygltf) | study-only |"
if old not in text:
    raise SystemExit("tinygltf row fixture not found")
path.write_text(text.replace(old, new), encoding="utf-8")
PY
expect_failure "wrapped Sources donor tier mismatch" "category tier" \
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
donor_tmp="$(mktemp -d "${VALIDATE_TMP}/donor_validate_escape.XXXXXX")"
cp -a "${SKILL_DIR}/references/donor-library" "${donor_tmp}/donor-library"
printf "\n[escaped](../../outside.md)\n[absolute](/tmp/outside.md)\n" >>"${donor_tmp}/donor-library/README.md"
expect_failure "donor validator rejects escaping local links" "local link target escapes reference root" \
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
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_positive_missing_expected.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
for case in data["cases"]:
    if "positive" in case["tags"]:
        case["expected_paths"] = []
        break
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "positive trigger matrix requires expected paths" "positive cases must have non-empty expected_paths" \
    python3 "${ROOT_DIR}/scripts/validate_trigger_matrix.py" \
    "${matrix_tmp}" \
    --repo-root "${ROOT_DIR}"
rm -f "${matrix_tmp}"
matrix_tmp="$(mktemp "${VALIDATE_TMP}/trigger_matrix_negative_expected.XXXXXX.json")"
python3 - "${ROOT_DIR}/research/donor-library/trigger-matrix.json" "${matrix_tmp}" <<'PY'
import json
import sys
from pathlib import Path

source = Path(sys.argv[1])
target = Path(sys.argv[2])
data = json.loads(source.read_text(encoding="utf-8"))
for case in data["cases"]:
    if "negative" in case["tags"]:
        case["expected_paths"] = ["research/donor-library/trigger-test-lane.md"]
        break
target.write_text(json.dumps(data), encoding="utf-8")
PY
expect_failure "negative trigger matrix rejects expected paths" "negative cases must leave expected_paths empty" \
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
test ! -e "${description_tmp}/src/cuda"
test ! -f "${description_tmp}/cmake/CudaArchitectures.cmake"
test ! -x "${description_tmp}/scripts/run_compute_sanitizer.sh"
test ! -x "${description_tmp}/scripts/select_idle_gpu.sh"
if grep -q "PROJECT_ENABLE_CUDA\|PROJECT_CUDA\|cuda-debug\|cuda-vulkan-combined\|cuda_lane" \
    "${description_tmp}/CMakeLists.txt" \
    "${description_tmp}/CMakePresets.json" \
    "${description_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json"; then
    echo "Default scaffold leaked CUDA lane configuration" >&2
    exit 1
fi
test -f "${description_tmp}/docs/CODEBASE_ARCHITECTURE_INDEX.md"
test -f "${description_tmp}/docs/CODEBASE_SUBSYSTEM_MANIFEST.json"
test -x "${description_tmp}/scripts/bootstrap_code_map.py"
test -x "${description_tmp}/scripts/validate_code_map.py"
python3 "${description_tmp}/scripts/validate_code_map.py" "${description_tmp}"
(
    cd "${description_tmp}"
    scripts/bootstrap_code_map.py --audit-existing >"${VALIDATE_TMP}/description_audit_stdout.md"
    grep -q "Code Map Readiness Audit" "${VALIDATE_TMP}/description_audit_stdout.md"
    if [[ -e docs/CODEMAP_BOOTSTRAP_AUDIT.md ]]; then
        echo "audit-existing wrote an audit file without --write-audit" >&2
        exit 1
    fi
    scripts/bootstrap_code_map.py --audit-existing --write-audit
    test -f docs/CODEMAP_BOOTSTRAP_AUDIT.md
    grep -q "Code Map Readiness Audit" docs/CODEMAP_BOOTSTRAP_AUDIT.md
    scripts/bootstrap_code_map.py --decline
    scripts/validate_code_map.py
)
grep -q '"code_map": "declined"' "${description_tmp}/.cppstudio/code-map-state.json"
expect_failure "declined code map is not enabled" "code map is declined" \
    python3 "${description_tmp}/scripts/validate_code_map.py" "${description_tmp}" --require-enabled
(
    cd "${description_tmp}"
    scripts/bootstrap_code_map.py --enable --force
    scripts/validate_code_map.py --require-enabled
)
python3 "${SKILL_DIR}/scripts/validate_studio_backbone.py" \
    "${description_tmp}" \
    --strict-source-layout \
    --code-map
test -x "${description_tmp}/scripts/run_gpu_optimization_loop.py"
optimization_tmp="$(mktemp -d "${VALIDATE_TMP}/gpu_optimization.XXXXXX")"
mkdir -p "${optimization_tmp}/docs" "${optimization_tmp}/scripts" "${optimization_tmp}/src/cuda"
cp "${SKILL_DIR}/scripts/run_gpu_optimization_loop.py" "${optimization_tmp}/scripts/run_gpu_optimization_loop.py"
chmod +x "${optimization_tmp}/scripts/run_gpu_optimization_loop.py"
cat >"${optimization_tmp}/src/cuda/kernel.cu" <<'EOF'
metric=100
EOF
cat >"${optimization_tmp}/verify.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
exit 0
EOF
cat >"${optimization_tmp}/benchmark.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
source src/cuda/kernel.cu
echo "correctness=PASS"
echo "elapsed_us=${metric}"
echo "pct_peak_compute=42.0%"
echo "pct_peak_bandwidth=18.0%"
echo "bottleneck=compute"
echo "peak_vram_mb=16.0"
EOF
cat >"${optimization_tmp}/profile.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "sm__throughput.avg.pct_of_peak_sustained_elapsed=44.0"
echo "gpu__compute_memory_throughput.avg.pct_of_peak_sustained_elapsed=19.0"
echo "sm__pipe_tensor_cycles_active.avg.pct_of_peak_sustained_active=0.0"
echo "bottleneck=compute"
EOF
cat >"${optimization_tmp}/breaking.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
value="${PERF_PARAM_VALUE:?}"
echo "correctness=PASS"
echo "elapsed_us=${value}"
EOF
chmod +x "${optimization_tmp}/verify.sh" "${optimization_tmp}/benchmark.sh" "${optimization_tmp}/profile.sh" "${optimization_tmp}/breaking.sh"
cat >"${optimization_tmp}/docs/GPU_OPTIMIZATION_TARGETS_BAD.tsv" <<'EOF'
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	metric_name	direction	notes
cuda_kernel	cuda	synthetic CUDA kernel	50	./benchmark.sh	./verify.sh	./profile.sh	src/cuda	elapsed_us	lower	missing success criteria fixture
EOF
cat >"${optimization_tmp}/docs/GPU_OPTIMIZATION_TARGETS_BAD_RANK.tsv" <<'EOF'
target_id	rank	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	success_criteria	validation_passes	metric_name	direction	notes
cuda_kernel	not-a-rank	cuda	synthetic CUDA kernel	50	./benchmark.sh	./verify.sh	./profile.sh	src/cuda	elapsed_us must improve while correctness stays PASS	2	elapsed_us	lower	bad rank fixture
EOF
cat >"${optimization_tmp}/docs/GPU_OPTIMIZATION_TARGETS_BAD_MIN_IMPROVEMENT.tsv" <<'EOF'
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	success_criteria	validation_passes	metric_name	direction	min_improvement_pct	notes
cuda_kernel	cuda	synthetic CUDA kernel	50	./benchmark.sh	./verify.sh	./profile.sh	src/cuda	elapsed_us must improve while correctness stays PASS	2	elapsed_us	lower	-1	bad min improvement fixture
EOF
cat >"${optimization_tmp}/docs/GPU_OPTIMIZATION_TARGETS.tsv" <<'EOF'
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	success_criteria	validation_passes	metric_name	direction	notes
cuda_kernel	cuda	synthetic CUDA kernel	50	./benchmark.sh	./verify.sh	./profile.sh	src/cuda	elapsed_us must improve while correctness stays PASS	2	elapsed_us	lower	validation fixture
EOF
git -C "${optimization_tmp}" init -q
git -C "${optimization_tmp}" config user.email "cppstudio@example.invalid"
git -C "${optimization_tmp}" config user.name "CppStudio Validate"
git -C "${optimization_tmp}" add .
git -C "${optimization_tmp}" commit -q -m "baseline"
expect_failure "GPU optimization target table requires success criteria" "missing columns: success_criteria" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" init \
        --repo "${optimization_tmp}" \
        --session opt-bad \
        --targets docs/GPU_OPTIMIZATION_TARGETS_BAD.tsv
expect_failure "GPU optimization target rank is validated" "rank must be an integer" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" init \
        --repo "${optimization_tmp}" \
        --session opt-bad-rank \
        --targets docs/GPU_OPTIMIZATION_TARGETS_BAD_RANK.tsv
expect_failure "GPU optimization min improvement is validated" "min_improvement_pct must be >= 0" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" init \
        --repo "${optimization_tmp}" \
        --session opt-bad-min-improvement \
        --targets docs/GPU_OPTIMIZATION_TARGETS_BAD_MIN_IMPROVEMENT.tsv
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" init \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --targets docs/GPU_OPTIMIZATION_TARGETS.tsv \
    --consecutive-reverts 2
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" baseline \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel
grep -q "BASELINE" "${optimization_tmp}/artifacts/optimization/opt-test/results.tsv"
grep -q "elapsed_us" "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/baseline/run.log"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" profile \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --profile-id baseline-ncu
grep -q "compute_sol_pct" \
    "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/profiles/baseline-ncu/profile_metrics.json"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" profile \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --profile-id unavailable-profiler \
    --tool-gap "Nsight unavailable in fixture CI"
grep -q "PROFILE_GAP" "${optimization_tmp}/artifacts/optimization/opt-test/results.tsv"
grep -q "Nsight unavailable in fixture CI" \
    "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/profiles/unavailable-profiler/profile_metrics.json"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" breaking-point \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --param-name elements \
    --min 10 \
    --max 160 \
    --threshold 90 \
    --direction lower \
    --cmd './breaking.sh --elements {value}'
grep -q '"largest_passing"' \
    "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/breaking-point/elements/breaking_point.json"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" plan-round \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --beam-width 1 \
    --bottlenecks compute,memory
test -f "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/rounds/round001/round_plan.json"
test -f "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/rounds/round001/workers/worker001/worker.json"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H1 \
    --confidence medium \
    --summary "Lower synthetic metric by editing the kernel fixture." \
    --evidence "baseline elapsed_us=100 and profile bottleneck=compute" \
    --expected-effect "elapsed_us lower"
grep -q "H1" "${optimization_tmp}/artifacts/optimization/opt-test/hypotheses.tsv"
printf "metric=80\n" >"${optimization_tmp}/src/cuda/kernel.cu"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --round-id round001 \
    --worker-id worker001 \
    --parent-attempt-id baseline \
    --attempt-id faster \
    --tag faster \
    --hypothesis-id H1 \
    --description "Faster synthetic kernel metric." \
    --auto-revert \
    --commit-keep
grep -q $'opt-test\tcuda_kernel\tattempt\tfaster\tfaster\tKEEP' \
    "${optimization_tmp}/artifacts/optimization/opt-test/results.tsv"
test -f "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/rounds/round001/workers/worker001/attempt/verify_pass_001.log"
test -f "${optimization_tmp}/artifacts/optimization/opt-test/targets/cuda_kernel/rounds/round001/workers/worker001/attempt/verify_pass_002.log"
git -C "${optimization_tmp}" log -1 --pretty=%s | grep -q "opt(cuda_kernel): faster"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H2 \
    --confidence low \
    --summary "A deliberately slower fixture should be rejected." \
    --evidence "validation fixture exercises revert behavior" \
    --expected-effect "elapsed_us higher and rejected"
printf "metric=120\n" >"${optimization_tmp}/src/cuda/kernel.cu"
expect_failure "slower GPU optimization attempt reverts" "decision=REVERT" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
        --repo "${optimization_tmp}" \
        --session opt-test \
        --target-id cuda_kernel \
        --attempt-id slower \
        --tag slower \
        --hypothesis-id H2 \
        --description "Slower synthetic kernel metric." \
        --auto-revert
grep -q "metric=80" "${optimization_tmp}/src/cuda/kernel.cu"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H3 \
    --confidence low \
    --summary "A failed validation command should reject before benchmarking." \
    --evidence "validation fixture overrides verify command with false" \
    --expected-effect "attempt reverts before run.log benchmark"
printf "metric=70\n" >"${optimization_tmp}/src/cuda/kernel.cu"
expect_failure "failed GPU optimization verification reverts" "decision=REVERT" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
        --repo "${optimization_tmp}" \
        --session opt-test \
        --target-id cuda_kernel \
        --attempt-id badverify \
        --tag badverify \
        --hypothesis-id H3 \
        --description "Verification failure synthetic attempt." \
        --verify-cmd false \
        --auto-revert
grep -q "metric=80" "${optimization_tmp}/src/cuda/kernel.cu"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H4 \
    --confidence low \
    --summary "Malformed benchmark output should revert instead of leaving the patch applied." \
    --evidence "validation fixture omits elapsed_us from benchmark output" \
    --expected-effect "attempt records REVERT and restores file"
printf "metric=60\n" >"${optimization_tmp}/src/cuda/kernel.cu"
expect_failure "missing requested GPU optimization metric reverts" "decision=REVERT" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
        --repo "${optimization_tmp}" \
        --session opt-test \
        --target-id cuda_kernel \
        --attempt-id missingmetric \
        --tag missingmetric \
        --hypothesis-id H4 \
        --description "Missing metric synthetic attempt." \
        --benchmark-cmd "printf 'correctness=PASS\n'" \
        --auto-revert
grep -q "metric=80" "${optimization_tmp}/src/cuda/kernel.cu"
grep -q "benchmark output did not contain" "${optimization_tmp}/artifacts/optimization/opt-test/results.tsv"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H5 \
    --confidence low \
    --summary "Nonpositive benchmark metrics should revert instead of leaving the patch applied." \
    --evidence "validation fixture reports elapsed_us=0" \
    --expected-effect "attempt records REVERT and restores file"
printf "metric=50\n" >"${optimization_tmp}/src/cuda/kernel.cu"
expect_failure "nonpositive GPU optimization metric reverts" "decision=REVERT" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
        --repo "${optimization_tmp}" \
        --session opt-test \
        --target-id cuda_kernel \
        --attempt-id zerometric \
        --tag zerometric \
        --hypothesis-id H5 \
        --description "Zero metric synthetic attempt." \
        --benchmark-cmd "printf 'correctness=PASS\nelapsed_us=0\n'" \
        --auto-revert
grep -q "metric=80" "${optimization_tmp}/src/cuda/kernel.cu"
grep -q "metric value must be positive" "${optimization_tmp}/artifacts/optimization/opt-test/results.tsv"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" hypothesis \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --target-id cuda_kernel \
    --hypothesis-id H6 \
    --confidence low \
    --summary "Intent-to-add new files should be captured as measured patches." \
    --evidence "validation fixture uses git add -N for a new in-scope file" \
    --expected-effect "attempt evaluates and auto-reverts the new file patch"
printf "// synthetic new file\n" >"${optimization_tmp}/src/cuda/new_file.cu"
git -C "${optimization_tmp}" add -N src/cuda/new_file.cu
expect_failure "intent-to-add GPU optimization new file diff is measured" "decision=REVERT" \
    python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" attempt \
        --repo "${optimization_tmp}" \
        --session opt-test \
        --target-id cuda_kernel \
        --attempt-id newfile \
        --tag newfile \
        --hypothesis-id H6 \
        --description "New in-scope file synthetic attempt." \
        --auto-revert
test ! -e "${optimization_tmp}/src/cuda/new_file.cu"
if git -C "${optimization_tmp}" status --short -- src/cuda/new_file.cu | grep -q .; then
    git -C "${optimization_tmp}" status --short -- src/cuda/new_file.cu >&2
    echo "intent-to-add new file left dirty git state after auto-revert" >&2
    exit 1
fi
optimization_next_out="$(mktemp "${VALIDATE_TMP}/gpu_optimization_next.XXXXXX.out")"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" next \
    --repo "${optimization_tmp}" \
    --session opt-test >"${optimization_next_out}"
grep -q "decision=DONE" "${optimization_next_out}"
python3 "${optimization_tmp}/scripts/run_gpu_optimization_loop.py" report \
    --repo "${optimization_tmp}" \
    --session opt-test \
    --final-cmd ./verify.sh
grep -q "GPU Optimization Report" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
grep -q "Estimated end-to-end speedup" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
grep -q "Success Criteria" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
grep -q "Hypotheses" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
grep -q "Breaking Points" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
grep -q "Consolidation" "${optimization_tmp}/artifacts/optimization/opt-test/final_report.md"
apply_dry_run_tmp="$(mktemp -d "${VALIDATE_TMP}/apply_dry_run.XXXXXX")"
apply_dry_run_out="$(mktemp "${VALIDATE_TMP}/apply_dry_run.XXXXXX.out")"
python3 "${SKILL_DIR}/scripts/apply_studio_backbone.py" \
    "${apply_dry_run_tmp}" \
    --dry-run >"${apply_dry_run_out}"
grep -q "CMakePresets.json" "${apply_dry_run_out}"
if grep -q "CODEBASE_ARCHITECTURE_INDEX" "${apply_dry_run_out}"; then
    cat "${apply_dry_run_out}" >&2
    echo "Existing-repo dry run copied code map files without --with-code-map" >&2
    exit 1
fi
apply_code_map_out="$(mktemp "${VALIDATE_TMP}/apply_code_map.XXXXXX.out")"
python3 "${SKILL_DIR}/scripts/apply_studio_backbone.py" \
    "${apply_dry_run_tmp}" \
    --dry-run \
    --with-code-map >"${apply_code_map_out}"
grep -q "CODEBASE_ARCHITECTURE_INDEX.md" "${apply_code_map_out}"
grep -q "bootstrap_code_map.py" "${apply_code_map_out}"
audit_tmp="$(mktemp -d "${VALIDATE_TMP}/code_map_audit.XXXXXX")"
touch "${audit_tmp}/main.cpp"
audit_stdout="$(mktemp "${VALIDATE_TMP}/code_map_audit_stdout.XXXXXX.md")"
python3 "${SKILL_DIR}/scripts/bootstrap_code_map.py" "${audit_tmp}" --audit-existing >"${audit_stdout}"
grep -q "Missing root CMake entrypoint" "${audit_stdout}"
grep -q "Estimated restructuring cost" "${audit_stdout}"
if [[ -e "${audit_tmp}/docs/CODEMAP_BOOTSTRAP_AUDIT.md" ]]; then
    echo "audit-existing wrote an audit file without --write-audit" >&2
    exit 1
fi
python3 "${SKILL_DIR}/scripts/bootstrap_code_map.py" "${audit_tmp}" --audit-existing --write-audit
test -f "${audit_tmp}/docs/CODEMAP_BOOTSTRAP_AUDIT.md"
expect_failure "write-audit requires audit-existing" "--write-audit can only be used with --audit-existing" \
    python3 "${SKILL_DIR}/scripts/bootstrap_code_map.py" "${audit_tmp}" --decline --write-audit
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

sys.dont_write_bytecode = True
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
bash -n "${ROOT_DIR}"/scripts/*.sh
bash -n "${SKILL_DIR}"/scripts/*.sh
if grep -R "realpath -m" "${ROOT_DIR}/scripts/sync_to_codex.sh" "${ROOT_DIR}/scripts/rollout_to_codex.sh"; then
    echo "sync/rollout scripts must not depend on GNU-only realpath -m" >&2
    exit 1
fi
vulkan_fake_sdk="$(mktemp -d "${VALIDATE_TMP}/vulkan_sdk.XXXXXX")"
mkdir -p "${vulkan_fake_sdk}/lib" "${vulkan_fake_sdk}/share/vulkan/explicit_layer.d"
touch "${vulkan_fake_sdk}/lib/libVkLayer_khronos_validation.so"
touch "${vulkan_fake_sdk}/share/vulkan/explicit_layer.d/VkLayer_khronos_validation.json"
vulkan_validation_env_capture="$(mktemp "${VALIDATE_TMP}/vulkan_validation_env.XXXXXX")"
# shellcheck disable=SC2016
env -u LD_LIBRARY_PATH -u VK_ADD_LAYER_PATH \
    VULKAN_SDK="${vulkan_fake_sdk}" \
    VULKAN_VALIDATION_OUTPUT_DIR="${VALIDATE_TMP}/vulkan_validation_artifacts" \
    "${SKILL_DIR}/scripts/run_vulkan_validation.sh" \
    bash -c 'printf "LD=%s\nVK_ADD=%s\nLAYERS=%s\n" "${LD_LIBRARY_PATH-}" "${VK_ADD_LAYER_PATH-}" "${VK_INSTANCE_LAYERS-}" >"$1"' \
    -- \
    "${vulkan_validation_env_capture}"
grep -Fx "LD=${vulkan_fake_sdk}/lib" "${vulkan_validation_env_capture}"
grep -Fx "VK_ADD=${vulkan_fake_sdk}/share/vulkan/explicit_layer.d" "${vulkan_validation_env_capture}"
grep -Fx "LAYERS=VK_LAYER_KHRONOS_validation" "${vulkan_validation_env_capture}"
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
        shift
        if [[ "${1:-}" == "--help-reports" ]]; then
            cat <<'REPORTS'

The following built-in reports are available:

  cuda_api_gpu_sum[:nvtx-name][:base|:mangled] -- CUDA Summary (API/Kernels/MemOps)
  cuda_api_sum -- CUDA API Summary
  cuda_gpu_kern_sum[:nvtx-name][:base|:mangled] -- CUDA GPU Kernel Summary
  cuda_gpu_mem_time_sum -- CUDA GPU MemOps Summary (by Time)
  cuda_kern_exec_sum[:nvtx-name][:base|:mangled] -- CUDA Kernel Launch & Exec Time Summary
  nvtx_sum -- NVTX Range Summary
  osrt_sum -- OS Runtime Summary
  vulkan_api_sum -- Vulkan API Summary
  vulkan_api_trace -- Vulkan API Trace
  vulkan_gpu_marker_sum -- Vulkan GPU Range Summary
  vulkan_marker_sum -- Vulkan Range Summary
REPORTS
            exit 0
        fi
        if [[ "${1:-}" == "--help" ]]; then
            cat <<'FORMATS'
           Available formats (and file extensions):

             column     Human readable columns (.txt)
             table      Human readable table (.txt)
             csv        Comma Separated Values (.csv)
             tsv        Tab Separated Values (.tsv)
             json       JavaScript Object Notation (.json)
FORMATS
            exit 0
        fi
        report_name=""
        stats_format=""
        force_export=""
        input_file=""
        while (($# > 0)); do
            case "$1" in
                --force-export=*)
                    force_export="${1#--force-export=}"
                    shift
                    ;;
                --force-export)
                    force_export="$2"
                    shift 2
                    ;;
                --report)
                    report_name="$2"
                    shift 2
                    ;;
                --format)
                    stats_format="$2"
                    shift 2
                    ;;
                --*)
                    shift
                    ;;
                *)
                    input_file="$1"
                    shift
                    ;;
            esac
        done
        if [[ "${report_name}" == "summary" || "${stats_format}" == "text" ]]; then
            echo "unsupported report or format" >&2
            exit 2
        fi
        if [[ "${force_export}" != "true" ]]; then
            echo "missing --force-export=true" >&2
            exit 2
        fi
        printf "%s|%s|force=%s|%s\n" "${report_name}" "${stats_format:-default}" "${force_export}" "${input_file}" >>"${NSYS_STATS_ARGV_CAPTURE:?}"
        printf "stats report=%s format=%s force_export=%s input=%s\n" "${report_name}" "${stats_format:-default}" "${force_export}" "${input_file}"
        ;;
    *)
        echo "unexpected nsys command: $1" >&2
        exit 2
        ;;
esac
EOF
chmod +x "${nsys_fake_dir}/nsys"
nsys_arg_capture="$(mktemp "${VALIDATE_TMP}/nsys_argv.XXXXXX")"
nsys_stats_capture="$(mktemp "${VALIDATE_TMP}/nsys_stats_argv.XXXXXX")"
PATH="${nsys_fake_dir}:${PATH}" \
    NSYS_ARGV_CAPTURE="${nsys_arg_capture}" \
    NSYS_STATS_ARGV_CAPTURE="${nsys_stats_capture}" \
    NSYS_OUTPUT_DIR="${VALIDATE_TMP}/nsys_arg_out" \
    "${SKILL_DIR}/scripts/run_nsys_smoke.sh" \
    "${VALIDATE_TMP}/app with spaces" \
    "--flag" \
    "value with spaces"
grep -Fx "${VALIDATE_TMP}/app with spaces" "${nsys_arg_capture}"
grep -Fx -- "--flag" "${nsys_arg_capture}"
grep -Fx "value with spaces" "${nsys_arg_capture}"
grep -F "vulkan_api_sum,osrt_sum,nvtx_sum|column|force=true|${VALIDATE_TMP}/nsys_arg_out/nsys_smoke.nsys-rep" "${nsys_stats_capture}"
if grep -F "summary|" "${nsys_stats_capture}" >/dev/null || grep -F "|text|" "${nsys_stats_capture}" >/dev/null; then
    echo "run_nsys_smoke.sh used unsupported legacy summary/text stats options" >&2
    exit 1
fi
if grep -F "vulkan_gpu_marker_sum" "${nsys_stats_capture}" >/dev/null || grep -F "vulkan_marker_sum" "${nsys_stats_capture}" >/dev/null; then
    echo "run_nsys_smoke.sh defaulted to marker reports instead of the stable Vulkan stats set" >&2
    exit 1
fi
nsys_cuda_arg_capture="$(mktemp "${VALIDATE_TMP}/nsys_cuda_argv.XXXXXX")"
nsys_cuda_stats_capture="$(mktemp "${VALIDATE_TMP}/nsys_cuda_stats_argv.XXXXXX")"
PATH="${nsys_fake_dir}:${PATH}" \
    NSYS_ARGV_CAPTURE="${nsys_cuda_arg_capture}" \
    NSYS_STATS_ARGV_CAPTURE="${nsys_cuda_stats_capture}" \
    NSYS_OUTPUT_DIR="${VALIDATE_TMP}/nsys_cuda_arg_out" \
    PROFILE_LANE=cuda \
    "${SKILL_DIR}/scripts/run_nsys_smoke.sh" \
    "${VALIDATE_TMP}/cuda app with spaces" \
    "--flag" \
    "value with spaces"
grep -F "cuda_api_gpu_sum,cuda_gpu_kern_sum,osrt_sum,nvtx_sum|column|force=true|${VALIDATE_TMP}/nsys_cuda_arg_out/nsys_smoke.nsys-rep" "${nsys_cuda_stats_capture}"
expect_failure "APP_COMMAND rejects shell-split command strings" "APP_COMMAND must be a single executable path without whitespace" \
    env PATH="${nsys_fake_dir}:${PATH}" \
    NSYS_ARGV_CAPTURE="${nsys_arg_capture}" \
    NSYS_STATS_ARGV_CAPTURE="${nsys_stats_capture}" \
    NSYS_OUTPUT_DIR="${VALIDATE_TMP}/nsys_bad_app_command" \
    APP_COMMAND="${VALIDATE_TMP}/app with spaces --flag" \
    "${SKILL_DIR}/scripts/run_nsys_smoke.sh"

if (( full )); then
    sample_dir="$(mktemp -d "${VALIDATE_TMP}/generated_project.XXXXXX")"

    "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" --name StudioValidate --output "${sample_dir}"
    (
        cd "${sample_dir}"
        scripts/bootstrap_code_map.py --enable --force
        scripts/validate_code_map.py --require-enabled
    )
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${sample_dir}" --gpu-lane vulkan --strict-source-layout --code-map
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${sample_dir}" --gpu-lane vulkan --strict-source-layout --integration
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
        cmake --preset benchmark
        cmake --build --preset benchmark
        ctest --preset benchmark --output-on-failure --no-tests=error
        cmake --preset asan-ubsan
        cmake --build --preset asan-ubsan
        ctest --preset asan-ubsan-quick --output-on-failure --no-tests=error
        cmake --preset coverage
        cmake --build --preset coverage
        ctest --preset coverage-quick --output-on-failure --no-tests=error
    )

    cuda_sample_dir="$(mktemp -d "${VALIDATE_TMP}/generated_cuda_project.XXXXXX")"
    "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" \
        --name StudioValidateCuda \
        --gpu-lane cuda-vulkan \
        --output "${cuda_sample_dir}"
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${cuda_sample_dir}" --gpu-lane cuda-vulkan --strict-source-layout
    (
        cd "${cuda_sample_dir}"
        cmake --preset cuda-debug -DPROJECT_CUDA_ARCHITECTURES="${full_cuda_architectures}"
        cmake --build --preset cuda-debug
        if [[ "${skip_cuda_runtime_tests}" == "1" ]]; then
            echo "Skipping CUDA runtime CTest lane because CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS=1"
        else
            ctest --preset cuda --output-on-failure --no-tests=error
        fi
        compute_generated_capture="$(mktemp "${VALIDATE_TMP}/compute_generated_argv.XXXXXX")"
        PATH="${compute_fake_dir}:${PATH}" \
            COMPUTE_SANITIZER_ARGV_CAPTURE="${compute_generated_capture}" \
            scripts/run_compute_sanitizer.sh
        grep -Fx -- "--error-exitcode=99" "${compute_generated_capture}"
        grep -Fx "ctest" "${compute_generated_capture}"
        grep -Fx -- "--preset" "${compute_generated_capture}"
        grep -Fx "cuda" "${compute_generated_capture}"
        cmake --preset cuda-vulkan-combined -DPROJECT_CUDA_ARCHITECTURES="${full_cuda_architectures}"
        cmake --build --preset cuda-vulkan-combined
    )
fi

echo "CppStudio validation passed"
