#!/usr/bin/env python3
"""Check whether changed source paths are covered by an enabled CppStudio code map."""

from __future__ import annotations

import argparse
import fnmatch
import json
import subprocess
from pathlib import Path
from typing import Iterable


STATE_PATH = Path(".cppstudio/code-map-state.json")
MANIFEST_PATH = Path("docs/CODEBASE_SUBSYSTEM_MANIFEST.json")
ROUTABLE_EXTENSIONS = {
    ".c",
    ".cc",
    ".cpp",
    ".cxx",
    ".h",
    ".hh",
    ".hpp",
    ".hxx",
    ".cu",
    ".cuh",
    ".glsl",
    ".vert",
    ".frag",
    ".comp",
    ".geom",
    ".tesc",
    ".tese",
    ".mesh",
    ".task",
    ".rgen",
    ".rchit",
    ".rmiss",
    ".hlsl",
    ".metal",
    ".cmake",
    ".md",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".py",
}
ROUTABLE_TOP_LEVELS = {
    ".github",
    "benchmarks",
    "cmake",
    "docs",
    "include",
    "scripts",
    "shaders",
    "src",
    "tests",
    "tools",
}
IGNORED_PARTS = {
    ".git",
    ".cache",
    ".cppstudio",
    "__pycache__",
    "artifacts",
    "build",
    "cmake-build-debug",
    "cmake-build-release",
    "dist",
    "out",
}
IGNORED_SUFFIXES = {
    ".abc",
    ".bin",
    ".bmp",
    ".exr",
    ".gif",
    ".jpg",
    ".jpeg",
    ".log",
    ".mp4",
    ".nsys-rep",
    ".obj",
    ".png",
    ".sqlite",
    ".tmp",
}
MAP_PATHS = {
    str(STATE_PATH),
    "docs/CODEBASE_ARCHITECTURE_INDEX.md",
    str(MANIFEST_PATH),
}


def run_git(repo: Path, args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=repo,
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def git_available(repo: Path) -> bool:
    return run_git(repo, ["rev-parse", "--is-inside-work-tree"], check=False).returncode == 0


def normalize_path(raw: str) -> str:
    path = raw.strip().replace("\\", "/")
    while path.startswith("./"):
        path = path[2:]
    return path


def collect_git_paths(repo: Path, mode: str, include_untracked: bool) -> list[str]:
    if mode == "staged":
        commands = [["diff", "--cached", "--name-only", "--diff-filter=ACMR"]]
    elif mode == "unstaged":
        commands = [["diff", "--name-only", "--diff-filter=ACMR"]]
    elif mode == "since-head":
        commands = [["diff", "--name-only", "--diff-filter=ACMR", "HEAD"]]
    else:
        commands = [
            ["diff", "--cached", "--name-only", "--diff-filter=ACMR"],
            ["diff", "--name-only", "--diff-filter=ACMR"],
        ]

    paths: set[str] = set()
    for command in commands:
        result = run_git(repo, command)
        paths.update(normalize_path(line) for line in result.stdout.splitlines() if line.strip())

    if include_untracked and mode in {"working-tree", "unstaged"}:
        result = run_git(repo, ["ls-files", "--others", "--exclude-standard"])
        paths.update(normalize_path(line) for line in result.stdout.splitlines() if line.strip())

    return sorted(paths)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise SystemExit(f"{path}: invalid JSON: {error}") from error


def code_map_enabled(repo: Path, require_enabled: bool) -> bool:
    state_path = repo / STATE_PATH
    if not state_path.is_file():
        if require_enabled:
            raise SystemExit(f"missing required code map state: {STATE_PATH}")
        print(f"No CppStudio code map state found at {STATE_PATH}; skipping drift check")
        return False
    state = load_json(state_path)
    status = state.get("code_map")
    if status == "enabled":
        return True
    if require_enabled:
        raise SystemExit(f"{STATE_PATH}: code map is {status!r}, but enabled state is required")
    print(f"CppStudio code map is {status!r}; skipping drift check")
    return False


def manifest_paths(manifest: dict) -> list[str]:
    paths: list[str] = []
    root_router = manifest.get("router_doc")
    if isinstance(root_router, str):
        paths.append(root_router)
    for subsystem in manifest.get("subsystems", []):
        if not isinstance(subsystem, dict):
            continue
        for key in ("router_doc",):
            value = subsystem.get(key)
            if isinstance(value, str):
                paths.append(value)
        for key in ("canonical_docs", "primary_paths"):
            values = subsystem.get(key, [])
            if isinstance(values, list):
                paths.extend(value for value in values if isinstance(value, str))
    return sorted({normalize_path(path) for path in paths if normalize_path(path)})


def is_ignored(path: str) -> bool:
    candidate = Path(path)
    if any(part in IGNORED_PARTS for part in candidate.parts):
        return True
    if candidate.suffix.lower() in IGNORED_SUFFIXES:
        return True
    return False


def is_routable(path: str) -> bool:
    candidate = Path(path)
    if not candidate.parts:
        return False
    if is_ignored(path):
        return False
    if path in MAP_PATHS or path.startswith("docs/SUBSYSTEMS/"):
        return False
    if candidate.parts[0] in ROUTABLE_TOP_LEVELS:
        return True
    return candidate.suffix.lower() in ROUTABLE_EXTENSIONS


def path_is_covered(path: str, routes: Iterable[str]) -> bool:
    path = normalize_path(path)
    for route in routes:
        route = normalize_path(route)
        if not route:
            continue
        if any(char in route for char in "*?["):
            if fnmatch.fnmatch(path, route):
                return True
            continue
        if path == route or path.startswith(route.rstrip("/") + "/"):
            return True
    return False


def map_touched(paths: Iterable[str]) -> bool:
    return any(path in MAP_PATHS or path.startswith("docs/SUBSYSTEMS/") for path in paths)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository root")
    parser.add_argument(
        "--mode",
        choices=("working-tree", "staged", "unstaged", "since-head"),
        default="working-tree",
        help="Which git changes to inspect",
    )
    parser.add_argument(
        "--include-untracked",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Include untracked files when checking working-tree or unstaged mode",
    )
    parser.add_argument(
        "--require-enabled",
        action="store_true",
        help="Fail if the CppStudio code map is missing or declined",
    )
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    if not repo.is_dir():
        raise SystemExit(f"repo directory does not exist: {repo}")
    if not code_map_enabled(repo, args.require_enabled):
        return 0
    manifest_path = repo / MANIFEST_PATH
    if not manifest_path.is_file():
        raise SystemExit(f"missing code map manifest: {MANIFEST_PATH}")
    if not git_available(repo):
        raise SystemExit(f"not a git repository: {repo}")

    changed_paths = collect_git_paths(repo, args.mode, args.include_untracked)
    routable_paths = [path for path in changed_paths if is_routable(path)]
    routes = manifest_paths(load_json(manifest_path))
    uncovered = [path for path in routable_paths if not path_is_covered(path, routes)]

    if uncovered:
        print("Code map drift check failed: changed routable paths are not covered by the manifest.")
        for path in uncovered:
            print(f"- {path}")
        print(
            "Update docs/CODEBASE_SUBSYSTEM_MANIFEST.json and the matching docs/SUBSYSTEMS/*.md "
            "route, or explicitly add the owning directory/glob if the subsystem already owns it."
        )
        return 1

    print(f"Code map drift check passed: {len(routable_paths)} changed routable path(s) covered")
    if routable_paths and not map_touched(changed_paths):
        print(
            "Map review note: source/build/docs changed but map files did not. "
            "Confirm no ownership, data-flow, backend-boundary, validation, or public behavior route changed."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
