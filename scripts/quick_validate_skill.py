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
from dataclasses import dataclass
from pathlib import Path
from typing import Any


FIELD_RE = re.compile(r"^([A-Za-z0-9_-]+):\s*(.*)$")
NAME_RE = re.compile(r"^[A-Za-z0-9_.-]+$")
LOCAL_REFERENCE_RE = re.compile(r"`([^`\n]+)`")
LOCAL_PATH_PREFIXES = ("assets/", "references/", "scripts/")


@dataclass(frozen=True)
class ParsedSkill:
    fields: dict[str, str]
    body: str


def unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def parse_frontmatter(skill_md: Path) -> ParsedSkill:
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
        if key in fields:
            raise ValueError(f"duplicate front matter field {key!r} on line {line_number}")
        fields[key] = unquote(value)

    body = "\n".join(lines[closing_index + 1 :]).strip()
    if not body:
        raise ValueError("SKILL.md must contain body content after front matter")

    return ParsedSkill(fields=fields, body=body)


def parse_simple_scalar(raw: str) -> str:
    raw = raw.strip()
    if not raw:
        return ""
    if raw[0] in {"'", '"'}:
        quote = raw[0]
        escaped = False
        for index, character in enumerate(raw[1:], start=1):
            if quote == '"' and character == "\\" and not escaped:
                escaped = True
                continue
            if character == quote and not escaped:
                return unquote(raw[: index + 1])
            escaped = False
        return unquote(raw)
    if "#" in raw:
        raw = raw.split("#", 1)[0].rstrip()
    return raw


def parse_openai_yaml(path: Path) -> dict[str, Any]:
    data: dict[str, Any] = {}
    current_section: str | None = None
    seen_section_fields: dict[str, set[str]] = {}

    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if line.startswith(" ") or line.startswith("\t"):
            if current_section is None:
                raise ValueError(f"{path}: line {line_number}: nested field without a section")
            if not line.startswith("  ") or line.startswith("   ") or ":" not in stripped:
                raise ValueError(f"{path}: line {line_number}: unsupported YAML shape")
            key, value = stripped.split(":", 1)
            if key in seen_section_fields[current_section]:
                raise ValueError(f"{path}: line {line_number}: duplicate field {current_section}.{key}")
            seen_section_fields[current_section].add(key)
            data[current_section][key] = parse_simple_scalar(value)
            continue

        if not stripped.endswith(":"):
            raise ValueError(f"{path}: line {line_number}: top-level entries must be sections")
        section = stripped[:-1]
        if section in data:
            raise ValueError(f"{path}: line {line_number}: duplicate top-level section {section!r}")
        data[section] = {}
        seen_section_fields[section] = set()
        current_section = section

    return data


def validate_openai_agent_metadata(skill_dir: Path) -> None:
    metadata = skill_dir / "agents" / "openai.yaml"
    if not metadata.exists():
        return
    if not metadata.is_file():
        raise ValueError(f"agents/openai.yaml is not a file: {metadata}")

    data = parse_openai_yaml(metadata)
    if set(data) != {"interface"}:
        raise ValueError("agents/openai.yaml must contain only the top-level interface section")
    interface = data["interface"]
    if not isinstance(interface, dict):
        raise ValueError("agents/openai.yaml interface section must be a mapping")
    required = {"display_name", "short_description", "default_prompt"}
    missing = sorted(required - set(interface))
    if missing:
        raise ValueError(f"agents/openai.yaml interface is missing required fields: {missing}")
    unknown = sorted(set(interface) - required)
    if unknown:
        raise ValueError(f"agents/openai.yaml interface has unknown fields: {unknown}")
    for field_name in sorted(required):
        value = interface.get(field_name)
        if not isinstance(value, str) or not value.strip():
            raise ValueError(f"agents/openai.yaml interface.{field_name} must be a non-empty string")


def local_path_error(path_text: str) -> str | None:
    if not path_text or "\0" in path_text:
        return "path is empty or contains a NUL byte"
    if path_text.startswith(("/", "~")) or Path(path_text).is_absolute():
        return "path must be relative to the skill directory"
    if any(part == ".." for part in path_text.replace("\\", "/").split("/")):
        return "path must not contain '..'"
    return None


def validate_bundled_references(skill_dir: Path, body: str) -> None:
    for match in LOCAL_REFERENCE_RE.finditer(body):
        raw = match.group(1).strip()
        if not raw:
            continue
        candidate = raw.split()[0].strip(".,:;)")
        if not candidate.startswith(LOCAL_PATH_PREFIXES):
            continue
        error = local_path_error(candidate)
        if error:
            raise ValueError(f"invalid bundled reference {candidate!r}: {error}")
        if not (skill_dir / candidate).exists():
            raise ValueError(f"bundled reference does not exist: {candidate}")


def validate_skill(skill_dir: Path) -> None:
    if not skill_dir.exists():
        raise ValueError(f"skill directory does not exist: {skill_dir}")
    if not skill_dir.is_dir():
        raise ValueError(f"skill path is not a directory: {skill_dir}")

    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        raise ValueError(f"missing SKILL.md in {skill_dir}")

    parsed = parse_frontmatter(skill_md)
    fields = parsed.fields
    name = fields.get("name", "").strip()
    description = fields.get("description", "").strip()

    if not name:
        raise ValueError("front matter must include non-empty name")
    if not NAME_RE.match(name):
        raise ValueError(f"skill name contains unsupported characters: {name!r}")
    if not description:
        raise ValueError("front matter must include non-empty description")
    validate_openai_agent_metadata(skill_dir)
    validate_bundled_references(skill_dir, parsed.body)

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
