#!/usr/bin/env python3
"""Apply reusable studio-backbone files to an existing repository."""

from __future__ import annotations

import argparse
import os
import re
import shutil
import tempfile
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
    ".gitignore",
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


def atomic_write_text(target: Path, text: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    mode = target.stat().st_mode if target.exists() else 0o644
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=target.parent, delete=False) as handle:
        handle.write(text)
        temp_name = handle.name
    temp_path = Path(temp_name)
    try:
        os.chmod(temp_path, mode)
        os.replace(temp_path, target)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise


def atomic_copy(source: Path, target: Path, executable: bool) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("wb", dir=target.parent, delete=False) as handle:
        temp_path = Path(handle.name)
    try:
        shutil.copy2(source, temp_path)
        if executable:
            temp_path.chmod(temp_path.stat().st_mode | 0o111)
        os.replace(temp_path, target)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise


def render_template_file(relative: str, replacements: dict[str, str]) -> str:
    source = TEMPLATE_ROOT / relative
    if not source.is_file():
        raise FileNotFoundError(f"missing template file: {source}")
    return render_text(source.read_text(encoding="utf-8"), replacements)


def planned_text(relative: str, target: Path, replacements: dict[str, str], force: bool) -> str:
    text = render_template_file(relative, replacements)
    if target.exists() and not force:
        raise FileExistsError(f"refusing to overwrite existing file: {target}")
    return text


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", help="Existing repository root")
    parser.add_argument("--project-name", help="Override project name used in rendered templates")
    parser.add_argument("--namespace", help="C++ namespace used only if replacing the root CMake/sample source")
    parser.add_argument("--force", action="store_true", help="Overwrite existing backbone files")
    parser.add_argument("--dry-run", action="store_true", help="Show planned writes without changing files")
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
        "PROJECT_DESCRIPTION": "Vulkan-first C++ project with optional CUDA lanes",
    }

    paths = list(BACKBONE_PATHS)
    if args.replace_cmake_lists:
        paths.insert(0, "CMakeLists.txt")

    rendered_files: list[tuple[str, Path, str]] = []
    for relative in paths:
        target = repo / relative
        rendered_files.append((relative, target, planned_text(relative, target, replacements, args.force)))

    scripts_dir = repo / "scripts"
    script_copies: list[tuple[Path, Path]] = []
    for script_name in RUNTIME_SCRIPTS:
        source = SKILL_ROOT / "scripts" / script_name
        if not source.is_file():
            raise FileNotFoundError(f"missing runtime script: {source}")
        target = scripts_dir / script_name
        if target.exists() and not args.force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        script_copies.append((source, target))

    if args.dry_run:
        for relative, target, _ in rendered_files:
            print(f"write: {target}")
        for _, target in script_copies:
            print(f"copy: {target}")
        print(f"Dry run complete for {repo}")
        return 0

    for _, target, text in rendered_files:
        atomic_write_text(target, text)

    for source, target in script_copies:
        atomic_copy(source, target, executable=True)

    print(f"Applied studio backbone support files to {repo}")
    print("Review CMake integration before enabling CI on an existing repo.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
