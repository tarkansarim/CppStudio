#!/usr/bin/env python3
"""Validate the CppStudio trigger-regression matrix references."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("matrix", type=Path, help="Path to trigger-matrix.json")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    return parser.parse_args()


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

    case_names: set[str] = set()
    for index, case in enumerate(matrix.get("cases", []), 1):
        name = case.get("name")
        if not isinstance(name, str) or not name:
            errors.append(f"case #{index}: missing name")
            continue
        if name in case_names:
            errors.append(f"duplicate case name: {name}")
        case_names.add(name)

        expected_paths = case.get("expected_paths", [])
        if not expected_paths:
            errors.append(f"{name}: expected_paths must not be empty")
        for relative in expected_paths:
            path = repo_root / relative
            if not isinstance(relative, str) or relative.startswith("/"):
                errors.append(f"{name}: expected path must be repo-relative: {relative!r}")
            elif not path.exists():
                errors.append(f"{name}: missing expected path {relative}")

        must_not_trigger = case.get("must_not_trigger_paths", [])
        for relative in must_not_trigger:
            if not isinstance(relative, str) or relative.startswith("/"):
                errors.append(f"{name}: must-not-trigger path must be repo-relative: {relative!r}")

    if not case_names:
        errors.append("trigger matrix has no cases")

    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        print(f"Trigger matrix validation failed: {len(errors)} error(s)", file=sys.stderr)
        return 1

    print("Trigger matrix validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
