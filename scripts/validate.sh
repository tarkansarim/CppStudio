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
  --full   Also scaffold a temporary sample project and run CMake/CTest quick lanes.
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
rm -rf "${ROOT_DIR}/scripts/__pycache__"
rm -rf "${SKILL_DIR}/scripts/__pycache__"
bash -n "${ROOT_DIR}"/scripts/*.sh
bash -n "${SKILL_DIR}"/scripts/*.sh

if (( full )); then
    sample_dir="$(mktemp -d /tmp/cppstudio_validate.XXXXXX)"
    "${SKILL_DIR}/scripts/scaffold_gpu_cpp_project.py" --name StudioValidate --output "${sample_dir}"
    "${SKILL_DIR}/scripts/validate_studio_backbone.py" "${sample_dir}" --strict-source-layout
    (
        cd "${sample_dir}"
        cmake --preset dev
        cmake --build --preset dev
        ctest --preset quick --output-on-failure
        cmake --preset asan-ubsan
        cmake --build --preset asan-ubsan
        ctest --preset asan-ubsan-quick --output-on-failure
    )
fi

echo "CppStudio validation passed"
