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

usage() {
    cat <<EOF
Usage: $0

Validate and roll out the CppStudio skill to user-level Codex, then install companion-skill donor
library links.

Environment:
  SYNC_CODEX_HOME  Defaults to ${HOME}/.codex
  TARGET_DIR       Override exact installed CppStudio skill directory
  VALIDATOR        Override quick_validate.py path
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

if [[ ! -f "${VALIDATOR}" && ! -x "${VALIDATOR}" ]]; then
    echo "Missing skill validator: ${VALIDATOR}" >&2
    exit 1
fi

for snippet in \
    "${SNIPPET_ROOT}/cuda-kernel-authoring/donor-library.md" \
    "${SNIPPET_ROOT}/vulkan-compute-sync/donor-library.md" \
    "${SNIPPET_ROOT}/modern-cpp-cmake/donor-library.md"
do
    if [[ ! -f "${snippet}" ]]; then
        echo "Missing companion snippet: ${snippet}" >&2
        exit 1
    fi
done

"${ROOT_DIR}/scripts/validate.sh"
SYNC_CODEX_HOME="${CODEX_HOME_DIR}" TARGET_DIR="${TARGET_DIR}" VALIDATOR="${VALIDATOR}" \
    "${ROOT_DIR}/scripts/sync_to_codex.sh"

required_donor_files=(
    README.md
    selection-policy.md
    graphics-rendering.md
    geometry-simulation.md
    ai-runtimes-kernels.md
    neural-3d.md
    hair-grooming-fur.md
    dcc-scene-pipeline.md
    volumes-voxels.md
    animation-rigging.md
    surfaces-subdivision.md
    texture-material-color.md
    cad-precision-geometry.md
    simulation-gpu.md
    xr-spatial.md
    profiles/cutlass.md
    profiles/flashattention.md
    profiles/triton.md
    profiles/khronos-vulkan-samples.md
    profiles/nvidia-vk-mini-samples.md
    profiles/gsplat.md
    profiles/tressfx.md
    profiles/openusd.md
    profiles/alembic.md
    profiles/materialx.md
    profiles/openvdb-nanovdb.md
    profiles/ozz-animation.md
    profiles/acl.md
    profiles/opensubdiv.md
    profiles/ktx-basis.md
    profiles/opencolorio-openimageio.md
    profiles/open-cascade.md
    profiles/openxr-sdk.md
)

for donor_file in "${required_donor_files[@]}"; do
    if [[ ! -f "${DONOR_ROOT}/${donor_file}" ]]; then
        echo "Missing rolled-out donor file: ${DONOR_ROOT}/${donor_file}" >&2
        exit 1
    fi
done

python3 - "$CODEX_HOME_DIR" "$DONOR_ROOT" "$SNIPPET_ROOT" <<'PY'
from pathlib import Path
import sys

codex_home = Path(sys.argv[1])
donor_root = Path(sys.argv[2])
snippet_root = Path(sys.argv[3])
skills_root = codex_home / "skills"

BEGIN = "<!-- cppstudio-donor-library:begin -->"
END = "<!-- cppstudio-donor-library:end -->"


def replace_marked_block(text: str, block: str) -> str:
    if BEGIN in text and END in text:
        start = text.index(BEGIN)
        end = text.index(END) + len(END)
        while end < len(text) and text[end] in "\r\n":
            end += 1
        return text[:start].rstrip() + "\n\n" + block + "\n\n" + text[end:].lstrip()
    return text


def remove_legacy_cuda(text: str) -> str:
    legacy = f"""## Donor References

When selecting external kernel, runtime, or compiler donors, read:

- `{donor_root / "selection-policy.md"}`
- `{donor_root / "ai-runtimes-kernels.md"}`

Use the donor library to compare CUTLASS, Triton, FlashAttention, tiny-cuda-nn, llama.cpp/ggml,
ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, and PyTorch before writing or recommending custom
GPU code. Keep non-commercial or study-only donors out of reusable implementation code.
"""
    return text.replace(legacy + "\n", "").replace(legacy, "")


def remove_legacy_vulkan(text: str) -> str:
    legacy = f"""## Donor References

When selecting Vulkan, renderer, WebGPU, or 3D graphics donors, read:

- `{donor_root / "selection-policy.md"}`
- `{donor_root / "graphics-rendering.md"}`
- `{donor_root / "geometry-simulation.md"}`

Use Khronos samples as the first correctness reference, then vendor samples for vendor-specific
extensions or tools. Keep study-only and non-commercial references out of reusable Vulkan code.
"""
    return text.replace(legacy + "\n", "").replace(legacy, "")


def remove_legacy_modern_cpp(text: str) -> str:
    legacy = (
        f"- When choosing external 3D, graphics, GPU, or AI dependencies, read "
        f"`{donor_root / 'README.md'}` and `selection-policy.md` first. Use permissive donors "
        "for reusable code; keep study-only references out of templates and shared infrastructure.\n"
    )
    return text.replace(legacy, "")


def install_block(skill_name: str, marker: str, block: str, cleanup) -> None:
    skill_path = skills_root / skill_name / "SKILL.md"
    if not skill_path.is_file():
        raise SystemExit(f"Missing installed companion skill: {skill_path}")

    original = skill_path.read_text(encoding="utf-8")
    text = replace_marked_block(cleanup(original), block)
    if BEGIN not in text:
        if marker not in text:
            raise SystemExit(f"Could not find insertion marker {marker!r} in {skill_path}")
        text = text.replace(marker, block + "\n\n" + marker, 1)

    if text != original:
        skill_path.write_text(text, encoding="utf-8")
        print(f"updated: {skill_path}")
    else:
        print(f"ok: {skill_path}")


def render_snippet(skill_name: str) -> str:
    snippet = snippet_root / skill_name / "donor-library.md"
    text = snippet.read_text(encoding="utf-8")
    text = text.replace("{{DONOR_ROOT}}", str(donor_root))
    text = text.replace("{{REFERENCE_ROOT}}", str(donor_root.parent))
    return f"{BEGIN}\n{text.rstrip()}\n{END}"


cuda_block = render_snippet("cuda-kernel-authoring")
vulkan_block = render_snippet("vulkan-compute-sync")
modern_cpp_block = render_snippet("modern-cpp-cmake")

install_block("cuda-kernel-authoring", "## Design Rules", cuda_block, remove_legacy_cuda)
install_block("vulkan-compute-sync", "## Compute Pipeline Checklist", vulkan_block, remove_legacy_vulkan)
install_block("modern-cpp-cmake", "## Renderer Bootstrap", modern_cpp_block, remove_legacy_modern_cpp)
PY

for skill in \
    "${TARGET_DIR}" \
    "${CODEX_HOME_DIR}/skills/cuda-kernel-authoring" \
    "${CODEX_HOME_DIR}/skills/vulkan-compute-sync" \
    "${CODEX_HOME_DIR}/skills/modern-cpp-cmake"
do
    python3 "${VALIDATOR}" "${skill}"
done

diff -qr "${SOURCE_DIR}" "${TARGET_DIR}" >/dev/null

echo "Rolled out ${SOURCE_DIR} -> ${TARGET_DIR}"
echo "Verified donor library at ${DONOR_ROOT}"
echo "Verified companion skill links in ${CODEX_HOME_DIR}/skills"
