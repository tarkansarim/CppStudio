#!/usr/bin/env python3
"""Preflight or install CppStudio donor-library links in companion skills."""

from __future__ import annotations

import argparse
import os
import re
import tempfile
from dataclasses import dataclass
from pathlib import Path


BEGIN = "<!-- cppstudio-donor-library:begin -->"
END = "<!-- cppstudio-donor-library:end -->"

COMPANIONS = {
    "cuda-kernel-authoring": "## Design Rules",
    "vulkan-compute-sync": "## Compute Pipeline Checklist",
    "modern-cpp-cmake": "## Renderer Bootstrap",
}


@dataclass(frozen=True)
class RenderedSkill:
    name: str
    path: Path
    text: str


@dataclass(frozen=True)
class SkippedSkill:
    name: str
    path: Path
    reason: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--preflight", action="store_true", help="Validate all planned edits without writing")
    mode.add_argument("--install", action="store_true", help="Atomically write companion skill updates")
    parser.add_argument("--codex-home", type=Path, required=True)
    parser.add_argument("--donor-root", type=Path, required=True)
    parser.add_argument("--source-skill-dir", type=Path, required=True)
    parser.add_argument("--snippet-root", type=Path, required=True)
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Require every known companion skill to be installed instead of skipping missing skills.",
    )
    return parser.parse_args()


def replace_marked_block(text: str, block: str, skill_path: Path) -> str:
    begin_count = text.count(BEGIN)
    end_count = text.count(END)
    if begin_count != end_count:
        raise ValueError(f"malformed cppstudio donor marker block in {skill_path}: begin/end markers do not match")
    if begin_count > 1:
        raise ValueError(f"malformed cppstudio donor marker block in {skill_path}: multiple marker blocks found")
    if begin_count == 1:
        start = text.index(BEGIN)
        end_start = text.index(END)
        if end_start <= start:
            raise ValueError(f"malformed cppstudio donor marker block in {skill_path}: end marker precedes begin marker")
        end = end_start + len(END)
        while end < len(text) and text[end] in "\r\n":
            end += 1
        prefix = text[:start].rstrip()
        suffix = text[end:].lstrip()
        if suffix:
            return prefix + "\n\n" + block + "\n\n" + suffix if prefix else block + "\n\n" + suffix
        return prefix + "\n\n" + block + "\n" if prefix else block + "\n"
    return text


def frontmatter_name(text: str, skill_path: Path) -> str:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise ValueError(f"missing YAML frontmatter in installed companion skill: {skill_path}")

    names: list[str] = []
    closed = False
    for line in lines[1:]:
        if line == "---":
            closed = True
            break
        if line.startswith("name:"):
            names.append(line[len("name:") :].strip().strip("\"'"))

    if not closed:
        raise ValueError(f"unterminated YAML frontmatter in installed companion skill: {skill_path}")
    if len(names) != 1:
        raise ValueError(f"expected exactly one frontmatter name in installed companion skill: {skill_path}")
    return names[0]


def validate_companion_skill(skill_name: str, skill_path: Path, text: str) -> None:
    actual_name = frontmatter_name(text, skill_path)
    if actual_name != skill_name:
        raise ValueError(
            f"installed companion skill name mismatch for {skill_path}: expected {skill_name!r}, "
            f"found {actual_name!r}"
        )


def validate_under_root(path: Path, root: Path, description: str) -> None:
    try:
        path.relative_to(root)
    except ValueError as error:
        raise ValueError(f"{description} escapes Codex skills root: {path} not under {root}") from error


def validate_skills_root(skills_root: Path, strict: bool) -> Path:
    if skills_root.is_symlink():
        raise ValueError(f"Codex skills root must not be a symlink: {skills_root}")
    if not skills_root.exists():
        if strict:
            raise FileNotFoundError(f"missing Codex skills root: {skills_root}")
        return skills_root.resolve(strict=False)
    if not skills_root.is_dir():
        raise ValueError(f"Codex skills root is not a directory: {skills_root}")
    return skills_root.resolve(strict=True)


def companion_skill_path(skill_name: str, skills_root: Path, skills_root_resolved: Path, strict: bool) -> Path | None:
    skill_dir = skills_root / skill_name
    skill_path = skill_dir / "SKILL.md"
    if skill_dir.is_symlink():
        raise ValueError(f"installed companion skill directory must not be a symlink: {skill_dir}")
    if not skill_dir.exists():
        if strict:
            raise FileNotFoundError(f"missing installed companion skill: {skill_path}")
        return None
    if not skill_dir.is_dir():
        raise ValueError(f"installed companion skill path is not a directory: {skill_dir}")
    skill_dir_resolved = skill_dir.resolve(strict=True)
    validate_under_root(skill_dir_resolved, skills_root_resolved, "installed companion skill directory")

    if skill_path.is_symlink():
        raise ValueError(f"installed companion SKILL.md must not be a symlink: {skill_path}")
    if not skill_path.exists():
        raise FileNotFoundError(f"installed companion skill directory is missing SKILL.md: {skill_path}")
    if not skill_path.is_file():
        raise ValueError(f"installed companion SKILL.md is not a file: {skill_path}")
    skill_path_resolved = skill_path.resolve(strict=True)
    validate_under_root(skill_path_resolved, skills_root_resolved, "installed companion SKILL.md")
    return skill_path


def render_snippet(skill_name: str, snippet_root: Path, donor_root: Path, source_skill_dir: Path, install: bool) -> str:
    snippet = snippet_root / skill_name / "donor-library.md"
    if not snippet.is_file():
        raise FileNotFoundError(f"missing companion snippet: {snippet}")

    reference_root = donor_root.parent
    source_reference_root = source_skill_dir / "references"
    text = snippet.read_text(encoding="utf-8")
    if BEGIN in text or END in text:
        raise ValueError(f"companion snippet must not contain managed donor markers: {snippet}")
    text = text.replace("{{DONOR_ROOT}}", str(donor_root))
    text = text.replace("{{REFERENCE_ROOT}}", str(reference_root))
    if "{{" in text or "}}" in text:
        raise ValueError(f"unresolved placeholder in rendered snippet: {snippet}")

    donor_root_resolved = donor_root.resolve(strict=False)
    reference_root_resolved = reference_root.resolve(strict=False)
    source_reference_root_resolved = source_reference_root.resolve(strict=True)

    for raw_path in re.findall(r"`(/[^`]+)`", text):
        rendered_path = Path(raw_path)
        rendered_resolved = rendered_path.resolve(strict=False)
        if install:
            if not rendered_path.exists():
                raise FileNotFoundError(f"rendered snippet references missing path: {rendered_path}")
            continue

        try:
            relative = rendered_resolved.relative_to(reference_root_resolved)
        except ValueError as error:
            raise ValueError(f"rendered snippet references path outside reference root: {rendered_path}") from error
        source_equivalent = source_reference_root_resolved / relative
        if not source_equivalent.exists():
            raise FileNotFoundError(
                f"rendered snippet references path without source equivalent: {rendered_path} -> {source_equivalent}"
            )
        if not (rendered_resolved == donor_root_resolved or donor_root_resolved in rendered_resolved.parents):
            try:
                rendered_resolved.relative_to(reference_root_resolved)
            except ValueError as error:
                raise ValueError(f"rendered snippet path is outside donor/reference roots: {rendered_path}") from error

    return f"{BEGIN}\n{text.rstrip()}\n{END}"


def render_skill(
    skill_name: str,
    skills_root: Path,
    skills_root_resolved: Path,
    snippet_root: Path,
    donor_root: Path,
    source_skill_dir: Path,
    install: bool,
) -> RenderedSkill | None:
    skill_path = companion_skill_path(skill_name, skills_root, skills_root_resolved, strict=False)
    if skill_path is None:
        return None

    original = skill_path.read_text(encoding="utf-8")
    validate_companion_skill(skill_name, skill_path, original)
    block = render_snippet(skill_name, snippet_root, donor_root, source_skill_dir, install)
    text = replace_marked_block(original, block, skill_path)
    if BEGIN not in text:
        marker = COMPANIONS[skill_name]
        if marker not in text:
            raise ValueError(f"could not find insertion marker {marker!r} in {skill_path}")
        text = text.replace(marker, block + "\n\n" + marker, 1)
    if "{{" in text or "}}" in text:
        raise ValueError(f"unresolved placeholder after rendering {skill_path}")
    if text.count(BEGIN) != 1 or text.count(END) != 1:
        raise ValueError(f"rendered skill must contain exactly one donor marker block: {skill_path}")
    return RenderedSkill(skill_name, skill_path, text)


def atomic_write(path: Path, text: str) -> None:
    mode = path.stat().st_mode
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        handle.write(text)
        temp_name = handle.name
    temp_path = Path(temp_name)
    try:
        os.chmod(temp_path, mode)
        os.replace(temp_path, path)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise


def main() -> int:
    args = parse_args()
    skills_root = args.codex_home.expanduser().resolve() / "skills"
    skills_root_resolved = validate_skills_root(skills_root, args.strict)
    donor_root = args.donor_root.expanduser().resolve()
    source_skill_dir = args.source_skill_dir.expanduser().resolve()
    snippet_root = args.snippet_root.expanduser().resolve()
    install = bool(args.install)

    if not source_skill_dir.is_dir():
        raise SystemExit(f"missing source skill directory: {source_skill_dir}")
    if not (source_skill_dir / "references" / "donor-library").is_dir():
        raise SystemExit(f"missing source donor library: {source_skill_dir / 'references' / 'donor-library'}")
    if not snippet_root.is_dir():
        raise SystemExit(f"missing snippet root: {snippet_root}")

    rendered: list[RenderedSkill] = []
    skipped: list[SkippedSkill] = []
    for name in COMPANIONS:
        skill_path = skills_root / name / "SKILL.md"
        if companion_skill_path(name, skills_root, skills_root_resolved, args.strict) is None:
            skipped.append(SkippedSkill(name, skill_path, "not installed"))
            continue
        item = render_skill(name, skills_root, skills_root_resolved, snippet_root, donor_root, source_skill_dir, install)
        if item is not None:
            rendered.append(item)

    if not install:
        for item in rendered:
            print(f"preflight ok: {item.path}")
        for item in skipped:
            print(f"preflight skipped: {item.path} ({item.reason})")
        return 0

    for item in rendered:
        original = item.path.read_text(encoding="utf-8")
        if item.text != original:
            atomic_write(item.path, item.text)
            print(f"updated: {item.path}")
        else:
            print(f"ok: {item.path}")
    for item in skipped:
        print(f"skipped: {item.path} ({item.reason})")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (FileNotFoundError, ValueError) as error:
        raise SystemExit(str(error)) from None
