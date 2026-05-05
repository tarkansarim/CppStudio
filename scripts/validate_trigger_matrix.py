#!/usr/bin/env python3
"""Validate CppStudio trigger-matrix schema and path integrity.

This check does not prove runtime skill-trigger behavior. It only keeps the manual/subagent trigger
matrix connected to real repo paths and catches malformed case metadata.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


POLARITY_TAGS = {"positive", "negative"}
ALLOWED_TAGS = {
    "ai-runtime",
    "assets",
    "browser",
    "bvh",
    "cad",
    "cuda",
    "dcc",
    "engine",
    "geometry",
    "gui",
    "graphics",
    "games",
    "harness",
    "hud",
    "infrastructure",
    "lookup",
    "materials",
    "neural-3d",
    "path-tracing",
    "planning",
    "positive",
    "negative",
    "rendering",
    "simulation",
    "smoke",
    "study-only",
    "vfx",
    "vulkan",
    "volumes",
    "webgpu",
    "xr",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("matrix", type=Path, help="Path to trigger-matrix.json")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


def validate_relative_path(repo_root: Path, case_name: str, field_name: str, relative: object, errors: list[str]) -> Path | None:
    if not isinstance(relative, str) or relative.startswith("/"):
        errors.append(f"{case_name}: {field_name} path must be repo-relative: {relative!r}")
        return None
    resolved = (repo_root / relative).resolve()
    try:
        resolved.relative_to(repo_root)
    except ValueError:
        errors.append(f"{case_name}: {field_name} path escapes repo root: {relative!r}")
        return None
    if not resolved.exists():
        errors.append(f"{case_name}: missing {field_name} path {relative}")
        return None
    return resolved


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    matrix_path = args.matrix.resolve()
    errors: list[str] = []

    if not matrix_path.is_file():
        print(f"Missing trigger matrix: {matrix_path}", file=sys.stderr)
        return 1

    try:
        matrix = json.loads(matrix_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        print(f"Invalid trigger matrix JSON: {error}", file=sys.stderr)
        return 1

    cases = matrix.get("cases")
    if not isinstance(cases, list):
        errors.append("trigger matrix cases must be a list")
        cases = []

    case_names: set[str] = set()
    for index, case in enumerate(cases, 1):
        if not isinstance(case, dict):
            errors.append(f"case #{index}: case must be an object")
            continue

        name = case.get("name")
        if not isinstance(name, str) or not name:
            errors.append(f"case #{index}: missing name")
            continue
        if name in case_names:
            errors.append(f"duplicate case name: {name}")
        case_names.add(name)

        for field_name in ("prompt_shape", "expected_behavior"):
            value = case.get(field_name)
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{name}: {field_name} must be a non-empty string")

        tags = case.get("tags")
        if not isinstance(tags, list) or not tags:
            errors.append(f"{name}: tags must be a non-empty list")
            tags = []
        seen_tags: set[str] = set()
        for tag in tags:
            if not isinstance(tag, str) or not tag.strip():
                errors.append(f"{name}: tags must contain only non-empty strings")
                continue
            if tag not in ALLOWED_TAGS:
                errors.append(f"{name}: unknown tag {tag!r}")
            if tag in seen_tags:
                errors.append(f"{name}: duplicate tag {tag!r}")
            seen_tags.add(tag)
        polarity = seen_tags & POLARITY_TAGS
        if len(polarity) != 1:
            errors.append(f"{name}: tags must contain exactly one polarity tag: positive or negative")
        is_positive = "positive" in seen_tags
        is_negative = "negative" in seen_tags

        expected_paths = case.get("expected_paths", [])
        if not isinstance(expected_paths, list):
            errors.append(f"{name}: expected_paths must be a list when present")
            expected_paths = []
        elif is_positive and not expected_paths:
            errors.append(f"{name}: positive cases must have non-empty expected_paths")
        elif is_negative and expected_paths:
            errors.append(f"{name}: negative cases must leave expected_paths empty and use must_not_trigger_paths")
        expected_resolved: set[Path] = set()
        for relative in expected_paths:
            resolved = validate_relative_path(repo_root, name, "expected", relative, errors)
            if resolved is not None:
                expected_resolved.add(resolved)

        must_not_trigger = case.get("must_not_trigger_paths", [])
        if not isinstance(must_not_trigger, list):
            errors.append(f"{name}: must_not_trigger_paths must be a list when present")
            must_not_trigger = []
        must_not_resolved: set[Path] = set()
        for relative in must_not_trigger:
            resolved = validate_relative_path(repo_root, name, "must-not-trigger", relative, errors)
            if resolved is not None:
                must_not_resolved.add(resolved)

        overlap = expected_resolved & must_not_resolved
        for path in sorted(overlap):
            errors.append(f"{name}: path appears in both expected and must-not-trigger lists: {path.relative_to(repo_root)}")

    if not case_names:
        errors.append("trigger matrix has no cases")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        print(f"Trigger matrix path-integrity validation failed: {len(errors)} error(s)", file=sys.stderr)
        return 1

    print("Trigger matrix validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
