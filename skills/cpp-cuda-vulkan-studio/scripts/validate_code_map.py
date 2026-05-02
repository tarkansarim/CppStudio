#!/usr/bin/env python3
"""Validate a CppStudio codebase map state and manifest."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


STATE_PATH = Path(".cppstudio/code-map-state.json")
VALID_STATES = {"enabled", "declined"}


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid JSON: {error}") from error


def require_string(container: dict[str, Any], key: str, context: str) -> str:
    value = container.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValueError(f"{context}: missing non-empty string field {key!r}")
    return value


def path_has_glob(path_text: str) -> bool:
    return any(marker in path_text for marker in "*?[")


def path_exists(repo: Path, path_text: str) -> bool:
    if path_has_glob(path_text):
        return any(repo.glob(path_text))
    return (repo / path_text).exists()


def validate_manifest(repo: Path, manifest_path: Path) -> list[str]:
    failures: list[str] = []
    manifest = load_json(manifest_path)
    if not isinstance(manifest, dict):
        return [f"{manifest_path}: manifest root must be an object"]

    version = manifest.get("version")
    if version != 1:
        failures.append(f"{manifest_path}: version must be 1")

    subsystems = manifest.get("subsystems")
    if not isinstance(subsystems, list) or not subsystems:
        failures.append(f"{manifest_path}: subsystems must be a non-empty list")
        return failures

    seen_ids: set[str] = set()
    for index, subsystem in enumerate(subsystems, start=1):
        context = f"{manifest_path}: subsystem[{index}]"
        if not isinstance(subsystem, dict):
            failures.append(f"{context}: must be an object")
            continue

        try:
            subsystem_id = require_string(subsystem, "id", context)
            router_doc = require_string(subsystem, "router_doc", context)
        except ValueError as error:
            failures.append(str(error))
            continue

        if subsystem_id in seen_ids:
            failures.append(f"{context}: duplicate subsystem id {subsystem_id!r}")
        seen_ids.add(subsystem_id)

        if not path_exists(repo, router_doc):
            failures.append(f"{context}: router_doc does not exist: {router_doc}")

        skill_path = subsystem.get("skill_path")
        if skill_path is not None:
            if not isinstance(skill_path, str) or not skill_path.strip():
                failures.append(f"{context}: skill_path must be a non-empty string when present")
            elif not path_exists(repo, skill_path):
                failures.append(f"{context}: skill_path does not exist: {skill_path}")

        for field_name in ("canonical_docs", "primary_paths"):
            values = subsystem.get(field_name, [])
            if not isinstance(values, list):
                failures.append(f"{context}: {field_name} must be a list")
                continue
            for value in values:
                if not isinstance(value, str) or not value.strip():
                    failures.append(f"{context}: {field_name} entries must be non-empty strings")
                    continue
                if not path_exists(repo, value):
                    failures.append(f"{context}: {field_name} entry does not exist: {value}")

    return failures


def validate_repo(repo: Path, require_enabled: bool) -> list[str]:
    failures: list[str] = []
    state_path = repo / STATE_PATH
    if not state_path.exists():
        if require_enabled:
            return [f"missing required code map state: {STATE_PATH}"]
        print(f"No CppStudio code map state found at {STATE_PATH}; skipping")
        return failures

    state = load_json(state_path)
    if not isinstance(state, dict):
        return [f"{STATE_PATH}: state root must be an object"]

    status = state.get("code_map")
    if status not in VALID_STATES:
        failures.append(f"{STATE_PATH}: code_map must be one of {sorted(VALID_STATES)}")
        return failures

    if status == "declined":
        if require_enabled:
            failures.append(f"{STATE_PATH}: code map is declined but enabled state is required")
        return failures

    index = require_string(state, "index", str(STATE_PATH))
    manifest = require_string(state, "manifest", str(STATE_PATH))
    index_path = repo / index
    manifest_path = repo / manifest

    if not index_path.is_file():
        failures.append(f"{STATE_PATH}: index does not exist: {index}")
    if not manifest_path.is_file():
        failures.append(f"{STATE_PATH}: manifest does not exist: {manifest}")
    else:
        failures.extend(validate_manifest(repo, manifest_path))

    return failures


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository root to validate")
    parser.add_argument("--require-enabled", action="store_true", help="Fail when the code map is missing or declined")
    args = parser.parse_args(argv)

    repo = Path(args.repo).expanduser().resolve()
    failures = validate_repo(repo, args.require_enabled)
    if failures:
        for failure in failures:
            print(f"FAIL: {failure}", file=sys.stderr)
        return 1
    print(f"Code map validation passed: {repo}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
