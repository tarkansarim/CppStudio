#!/usr/bin/env python3
"""Create a new Vulkan-first C++ app+library project from the bundled template."""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path


SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATE_ROOT = SKILL_ROOT / "assets" / "app-library-template"
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
CPP_KEYWORDS = {
    "alignas",
    "alignof",
    "and",
    "and_eq",
    "asm",
    "auto",
    "bitand",
    "bitor",
    "bool",
    "break",
    "case",
    "catch",
    "char",
    "char8_t",
    "char16_t",
    "char32_t",
    "class",
    "compl",
    "concept",
    "const",
    "consteval",
    "constexpr",
    "constinit",
    "const_cast",
    "continue",
    "co_await",
    "co_return",
    "co_yield",
    "decltype",
    "default",
    "delete",
    "do",
    "double",
    "dynamic_cast",
    "else",
    "enum",
    "explicit",
    "export",
    "extern",
    "false",
    "float",
    "for",
    "friend",
    "goto",
    "if",
    "import",
    "inline",
    "int",
    "long",
    "module",
    "mutable",
    "namespace",
    "new",
    "noexcept",
    "not",
    "not_eq",
    "nullptr",
    "operator",
    "or",
    "or_eq",
    "private",
    "protected",
    "public",
    "register",
    "reinterpret_cast",
    "requires",
    "return",
    "short",
    "signed",
    "sizeof",
    "static",
    "static_assert",
    "static_cast",
    "struct",
    "switch",
    "template",
    "this",
    "thread_local",
    "throw",
    "true",
    "try",
    "typedef",
    "typeid",
    "typename",
    "union",
    "unsigned",
    "using",
    "virtual",
    "void",
    "volatile",
    "wchar_t",
    "while",
    "xor",
    "xor_eq",
}
NAMESPACE_PATTERN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(::[A-Za-z_][A-Za-z0-9_]*)*$")


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


def namespace_name(raw: str | None, project_lower: str) -> str:
    value = raw.strip() if raw else project_lower
    value = re.sub(r"[^A-Za-z0-9_:]", "_", value)
    if not NAMESPACE_PATTERN.fullmatch(value):
        raise ValueError(
            "namespace must be C++ identifiers separated by '::', for example 'studio' or 'studio::render'"
        )
    keyword_segments = [segment for segment in value.split("::") if segment in CPP_KEYWORDS]
    if keyword_segments:
        raise ValueError(f"namespace segment is a C++ keyword: {keyword_segments[0]}")
    return value


def render_text(text: str, replacements: dict[str, str]) -> str:
    for key, value in replacements.items():
        text = text.replace("{{" + key + "}}", value)
    return text


def render_path(path: Path, replacements: dict[str, str]) -> Path:
    return Path(*[render_text(part, replacements) for part in path.parts])


def copy_template(destination: Path, replacements: dict[str, str], force: bool) -> None:
    for source in sorted(TEMPLATE_ROOT.rglob("*")):
        relative = source.relative_to(TEMPLATE_ROOT)
        target = destination / render_path(relative, replacements)
        if source.is_dir():
            target.mkdir(parents=True, exist_ok=True)
            continue
        if target.exists() and not force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        target.parent.mkdir(parents=True, exist_ok=True)
        try:
            text = source.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            shutil.copy2(source, target)
        else:
            target.write_text(render_text(text, replacements), encoding="utf-8")


def copy_runtime_scripts(destination: Path, force: bool) -> None:
    scripts_dir = destination / "scripts"
    scripts_dir.mkdir(parents=True, exist_ok=True)
    for script_name in RUNTIME_SCRIPTS:
        source = SKILL_ROOT / "scripts" / script_name
        target = scripts_dir / script_name
        if target.exists() and not force:
            raise FileExistsError(f"refusing to overwrite existing file: {target}")
        shutil.copy2(source, target)
        target.chmod(target.stat().st_mode | 0o111)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--name", required=True, help="Project name, e.g. RayLab")
    parser.add_argument("--output", required=True, help="Destination directory")
    parser.add_argument("--namespace", help="C++ namespace; defaults to snake_case project name")
    parser.add_argument("--description", default="Vulkan-first C++ app+library project with optional CUDA lanes")
    parser.add_argument("--force", action="store_true", help="Overwrite files that already exist")
    args = parser.parse_args()

    project_name = normalize_project_name(args.name)
    project_lower = lower_name(project_name)
    cpp_namespace = namespace_name(args.namespace, project_lower)
    destination = Path(args.output).expanduser().resolve()

    if destination.exists() and any(destination.iterdir()) and not args.force:
        raise SystemExit(f"destination is not empty; pass --force to write into it: {destination}")
    destination.mkdir(parents=True, exist_ok=True)

    replacements = {
        "PROJECT_NAME": project_name,
        "PROJECT_NAME_LOWER": project_lower,
        "PROJECT_NAME_UPPER": project_lower.upper(),
        "CPP_NAMESPACE": cpp_namespace,
        "PROJECT_DESCRIPTION": args.description,
    }

    copy_template(destination, replacements, args.force)
    copy_runtime_scripts(destination, args.force)

    print(f"Created {project_name} at {destination}")
    print("Next commands:")
    print(f"  cd {destination}")
    print("  scripts/check_dev_tools.sh")
    print("  cmake --preset dev")
    print("  cmake --build --preset dev")
    print("  ctest --preset quick --output-on-failure")
    print("Optional CUDA lane:")
    print("  cmake --preset cuda-debug && cmake --build --preset cuda-debug && ctest --preset cuda --output-on-failure")
    print("Optional mixed CUDA/Vulkan lane:")
    print("  cmake --preset cuda-vulkan-interop && cmake --build --preset cuda-vulkan-interop")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
