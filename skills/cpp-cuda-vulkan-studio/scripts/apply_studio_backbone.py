#!/usr/bin/env python3
"""Apply reusable studio-backbone files to an existing repository."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_ROOT = SKILL_ROOT / "assets" / "app-library-template"
BACKBONE_PATHS = [
    "CMakePresets.json",
    "cmake/ProjectOptions.cmake",
    "cmake/Warnings.cmake",
    "cmake/Sanitizers.cmake",
    "cmake/CudaArchitectures.cmake",
    "cmake/ProjectVulkan.cmake",
    "cmake/Testing.cmake",
    ".clang-format",
    ".clang-tidy",
    ".github/workflows/gpu-cpp.yml",
    "docs/DEVELOPMENT_ENVIRONMENT.md",
    "docs/VALIDATION_PIPELINE.md",
    "docs/BENCHMARKS.md",
    "docs/GPU_RUNNER_CI.md",
    "shaders/compute.comp",
    "shaders/offscreen_triangle.vert",
    "shaders/offscreen_triangle.frag",
]
RUNTIME_SCRIPTS = [
    "check_dev_tools.sh",
    "select_idle_gpu.sh",
    "run_compute_sanitizer.sh",
    "run_vulkan_validation.sh",
    "dump_vulkan_capabilities.sh",
    "run_nsys_smoke.sh",
    "format_check.sh",
    "tidy_check.sh",
]


def derive_project_name(repo: Path, explicit: str | None) -> str:
    if explicit:
        return normalize_project_name(explicit)
    cmake = repo / "CMakeLists.txt"
    if cmake.exists():
        match = re.search(r"project\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)", cmake.read_text(encoding="utf-8"))
        if match:
            return normalize_project_name(match.group(1))
    return normalize_project_name(repo.name)


def normalize_project_name(raw: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]", "_", raw.strip())
    cleaned = re.sub(r"_+", "_", cleaned).strip("_")
    if not cleaned or not re.match(r"^[A-Za-z_]", cleaned):
        raise ValueError("project name must contain letters and start with a letter or underscore")
    return cleaned


def lower_name(project_name: str) -> str:
    words = re.findall(r"[A-Z]?[a-z0-9]+|[A-Z]+(?=[A-Z]|$)", project_name)
    if not words:
        words = [project_name]
    return "_".join(word.lower() for word in words)


def render_text(text: str, replacements: dict[str, str]) -> str:
    for key, value in replacements.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def write_rendered(source: Path, target: Path, replacements: dict[str, str], force: bool) -> None:
    if target.exists() and not force:
        raise FileExistsError(f"refusing to overwrite existing file: {target}")
    target.parent.mkdir(parents=True, exist_ok=True)
    text = source.read_text(encoding="utf-8")
    target.write_text(render_text(text, replacements), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", help="Existing repository root")
    parser.add_argument("--project-name", help="Override project name used in rendered templates")
    parser.add_argument("--namespace", help="C++ namespace used only if replacing the root CMake/sample source")
    parser.add_argument("--force", action="store_true", help="Overwrite existing backbone files")
    parser.add_argument(
        "--replace-cmake-lists",
        action="store_true",
        help="Replace root CMakeLists.txt with the template. This is destructive without --force discipline.",
    )
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    if not repo.exists() or not repo.is_dir():
        raise SystemExit(f"repo directory does not exist: {repo}")

    project_name = derive_project_name(repo, args.project_name)
    project_lower = lower_name(project_name)
    replacements = {
        "PROJECT_NAME": project_name,
        "PROJECT_NAME_LOWER": project_lower,
        "PROJECT_NAME_UPPER": project_lower.upper(),
        "CPP_NAMESPACE": args.namespace or project_lower,
        "PROJECT_DESCRIPTION": "C++/CUDA/Vulkan project",
    }

    paths = list(BACKBONE_PATHS)
    if args.replace_cmake_lists:
        paths.insert(0, "CMakeLists.txt")

    for relative in paths:
        write_rendered(TEMPLATE_ROOT / relative, repo / relative, replacements, args.force)

    scripts_dir = repo / "scripts"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    for script_name in RUNTIME_SCRIPTS:
        target = scripts_dir / script_name
        if target.exists() and not args.force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        shutil.copy2(SKILL_ROOT / "scripts" / script_name, target)
        target.chmod(target.stat().st_mode | 0o111)

    print(f"Applied studio backbone support files to {repo}")
    print("Review CMake integration before enabling CI on an existing repo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
