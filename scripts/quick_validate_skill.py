#!/usr/bin/env python3
"""Small CI-safe validator for Codex skill metadata.

The canonical Codex validator lives in the user's Codex home. Public CI runners do
not have that home, so this script checks the metadata contract this repo needs
without depending on Codex installation state.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


FIELD_RE = re.compile(r"^([A-Za-z0-9_-]+):\s*(.*)$")
NAME_RE = re.compile(r"^[A-Za-z0-9_.-]+$")


def unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def parse_frontmatter(skill_md: Path) -> dict[str, str]:
    text = skill_md.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("SKILL.md must start with YAML-style front matter")

    closing_index = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            closing_index = index
            break
    if closing_index is None:
        raise ValueError("SKILL.md front matter is missing the closing --- marker")
    if closing_index == 1:
        raise ValueError("SKILL.md front matter is empty")

    fields: dict[str, str] = {}
    for line_number, line in enumerate(lines[1:closing_index], start=2):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        match = FIELD_RE.match(line)
        if not match:
            raise ValueError(f"invalid front matter line {line_number}: {line!r}")
        key, value = match.groups()
        fields[key] = unquote(value)

    body = "\n".join(lines[closing_index + 1 :]).strip()
    if not body:
        raise ValueError("SKILL.md must contain body content after front matter")

    return fields


def validate_skill(skill_dir: Path) -> None:
    if not skill_dir.exists():
        raise ValueError(f"skill directory does not exist: {skill_dir}")
    if not skill_dir.is_dir():
        raise ValueError(f"skill path is not a directory: {skill_dir}")

    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        raise ValueError(f"missing SKILL.md in {skill_dir}")

    fields = parse_frontmatter(skill_md)
    name = fields.get("name", "").strip()
    description = fields.get("description", "").strip()

    if not name:
        raise ValueError("front matter must include non-empty name")
    if not NAME_RE.match(name):
        raise ValueError(f"skill name contains unsupported characters: {name!r}")
    if not description:
        raise ValueError("front matter must include non-empty description")

    print(f"Skill metadata is valid: {skill_dir}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_dirs", nargs="+", type=Path)
    args = parser.parse_args(argv)

    for skill_dir in args.skill_dirs:
        try:
            validate_skill(skill_dir)
        except ValueError as exc:
            print(f"{skill_dir}: {exc}", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
