#!/usr/bin/env python3
"""Validate a CppStudio codebase map state and manifest."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote
from typing import Any


STATE_PATH = Path(".cppstudio/code-map-state.json")
VALID_STATES = {"enabled", "declined"}
GENERATED_SKILL_ROOT = "skills"
GENERATED_SUBSYSTEM_IDS = {
    "build_and_presets",
    "app_core",
    "vulkan_lane",
    "cuda_lane",
    "validation_ci",
}
LINK_RE = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
EXTERNAL_RE = re.compile(r"^[A-Za-z][A-Za-z0-9+.-]*:")


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


def normalized_path_parts(path_text: str) -> list[str]:
    return path_text.replace("\\", "/").split("/")


def local_path_error(path_text: str) -> str | None:
    if not path_text or "\0" in path_text:
        return "path is empty or contains a NUL byte"
    if EXTERNAL_RE.match(path_text):
        return "path must be a repo-relative local path, not a URL or URI"
    if path_text.startswith(("/", "~")) or Path(path_text).is_absolute():
        return "path must be relative to the repository root"
    if any(part == ".." for part in normalized_path_parts(path_text)):
        return "path must not contain '..'"
    return None


def path_exists(repo: Path, path_text: str) -> bool:
    if path_has_glob(path_text):
        return any(repo.glob(path_text))
    return (repo / path_text).exists()


def normalize_link_target(raw_target: str) -> str:
    target = raw_target.strip()
    if target.startswith("<") and ">" in target:
        target = target[1 : target.index(">")]
    else:
        target = target.split()[0] if target.split() else ""
    return unquote(target.split("#", 1)[0])


def collect_index_links(repo: Path, index_path: Path) -> tuple[set[str], list[str]]:
    links: set[str] = set()
    failures: list[str] = []
    repo_resolved = repo.resolve()
    text = index_path.read_text(encoding="utf-8")
    line_starts = [0]
    for line in text.splitlines(True):
        line_starts.append(line_starts[-1] + len(line))
    for match in LINK_RE.finditer(text):
        target = normalize_link_target(match.group(1))
        if not target or target.startswith("#") or EXTERNAL_RE.match(target):
            continue
        line_number = 1
        for index, start in enumerate(line_starts):
            if start > match.start():
                line_number = index
                break
        error = local_path_error(target)
        if error:
            failures.append(f"{index_path}: line {line_number}: invalid local link {target!r}: {error}")
            continue
        resolved = (index_path.parent / target).resolve()
        try:
            links.add(resolved.relative_to(repo_resolved).as_posix())
        except ValueError:
            failures.append(f"{index_path}: line {line_number}: local link escapes repository: {target!r}")
    return links, failures


def validate_manifest_path(repo: Path, path_text: str, context: str) -> str | None:
    error = local_path_error(path_text)
    if error:
        return f"{context}: invalid path {path_text!r}: {error}"
    repo_resolved = repo.resolve()
    resolved = (repo / path_text).resolve()
    if path_has_glob(path_text):
        try:
            matches = list(repo.glob(path_text))
        except ValueError as error:
            return f"{context}: invalid glob path {path_text!r}: {error}"
        for match in matches:
            try:
                match.resolve().relative_to(repo_resolved)
            except ValueError:
                return f"{context}: glob path escapes repository: {path_text}"
    else:
        try:
            resolved.relative_to(repo_resolved)
        except ValueError:
            return f"{context}: path escapes repository: {path_text}"
    return None


def validate_manifest(repo: Path, manifest_path: Path, index_links: set[str] | None = None) -> list[str]:
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

        path_failure = validate_manifest_path(repo, router_doc, f"{context}: router_doc")
        if path_failure:
            failures.append(path_failure)
        elif not path_exists(repo, router_doc):
            failures.append(f"{context}: router_doc does not exist: {router_doc}")
        if index_links is not None and not path_failure and router_doc not in index_links:
            failures.append(f"{context}: router_doc is not linked from index: {router_doc}")

        skill_path = subsystem.get("skill_path")
        if skill_path is not None:
            if not isinstance(skill_path, str) or not skill_path.strip():
                failures.append(f"{context}: skill_path must be a non-empty string when present")
            else:
                path_failure = validate_manifest_path(repo, skill_path, f"{context}: skill_path")
                if path_failure:
                    failures.append(path_failure)
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
                path_failure = validate_manifest_path(repo, value, f"{context}: {field_name}")
                if path_failure:
                    failures.append(path_failure)
                elif not path_exists(repo, value):
                    failures.append(f"{context}: {field_name} entry does not exist: {value}")

    if manifest.get("skill_root") == GENERATED_SKILL_ROOT and seen_ids != GENERATED_SUBSYSTEM_IDS:
        failures.append(
            f"{manifest_path}: generated map subsystem ids must be "
            f"{sorted(GENERATED_SUBSYSTEM_IDS)}, found {sorted(seen_ids)}"
        )

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
    for field_name, path_text in (("index", index), ("manifest", manifest)):
        path_failure = validate_manifest_path(repo, path_text, f"{STATE_PATH}: {field_name}")
        if path_failure:
            failures.append(path_failure)
    index_path = repo / index
    manifest_path = repo / manifest

    if failures:
        return failures

    if not index_path.is_file():
        failures.append(f"{STATE_PATH}: index does not exist: {index}")
        index_links = None
    else:
        index_links, link_failures = collect_index_links(repo, index_path)
        failures.extend(link_failures)
    if not manifest_path.is_file():
        failures.append(f"{STATE_PATH}: manifest does not exist: {manifest}")
    else:
        failures.extend(validate_manifest(repo, manifest_path, index_links))

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
