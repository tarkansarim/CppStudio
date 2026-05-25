#!/usr/bin/env python3
"""Check whether changed source paths are covered by an enabled CppStudio code map."""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import shlex
import shutil
import subprocess
import tempfile
import time
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
SIDECAR_FOCUS_PATH_LIMIT = 6
SIDECAR_SNAPSHOT_ROOT_ENV = "CPPSTUDIO_CODE_MAP_SIDECAR_SNAPSHOT_ROOT"


def run_git(repo: Path, args: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=repo,
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )


def command_available(name: str) -> bool:
    return shutil.which(name) is not None


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


def collect_snapshot_paths(repo: Path) -> list[str]:
    tracked = run_git(repo, ["ls-files", "-z"]).stdout.split("\0")
    untracked = run_git(repo, ["ls-files", "--others", "--exclude-standard", "-z"]).stdout.split("\0")
    paths = sorted({normalize_path(path) for path in [*tracked, *untracked] if path.strip()})
    return [path for path in paths if path and not is_ignored(path)]


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


def sidecar_focus(reason: str, paths: Iterable[str]) -> str:
    normalized_paths = [normalize_path(path) for path in paths]
    if not normalized_paths:
        return reason
    shown_paths = normalized_paths[:SIDECAR_FOCUS_PATH_LIMIT]
    path_summary = ", ".join(shown_paths)
    omitted_count = len(normalized_paths) - len(shown_paths)
    if omitted_count:
        path_summary = f"{path_summary}, and {omitted_count} more"
    return f"{reason}: {path_summary}"


def sidecar_snapshot_root() -> Path:
    configured = os.environ.get(SIDECAR_SNAPSHOT_ROOT_ENV)
    if configured:
        root = Path(configured).expanduser()
    else:
        state_home = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"))
        root = state_home / "cppstudio" / "code-map-sidecar-snapshots"
    root.mkdir(parents=True, exist_ok=True)
    return root.resolve()


def create_sidecar_snapshot(repo: Path) -> tuple[Path, str]:
    timestamp = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    snapshot_dir = Path(
        tempfile.mkdtemp(
            prefix=f"{repo.name}-code-map-{timestamp}-",
            dir=sidecar_snapshot_root(),
        )
    ).resolve()
    for relative in collect_snapshot_paths(repo):
        source = repo / relative
        if not source.is_file() or source.is_symlink():
            continue
        target = snapshot_dir / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)
    head = run_git(repo, ["rev-parse", "--verify", "HEAD"], check=False)
    head_text = head.stdout.strip() if head.returncode == 0 else "no-git-head"
    anchor = f"snapshot-{timestamp}-{head_text[:12]}"
    (snapshot_dir / "SIDECAR_SNAPSHOT_ANCHOR.txt").write_text(
        f"source_repo={repo}\nanchor={anchor}\nhead={head_text}\ncreated_utc={timestamp}\n",
        encoding="utf-8",
    )
    return snapshot_dir, anchor


def launch_sidecar(repo: Path, reason: str, paths: Iterable[str]) -> int:
    if not command_available("agent-tmux"):
        print("Code-map sidecar launch blocked: agent-tmux is not available on PATH.")
        return 127
    snapshot_dir, anchor = create_sidecar_snapshot(repo)
    focus = sidecar_focus(reason, paths)
    command = ["agent-tmux", "codex-code-map-sidecar", str(snapshot_dir), anchor, focus]
    print("Code-map sidecar auto-launch:")
    print(f"  source repo: {repo}")
    print(f"  frozen snapshot: {snapshot_dir}")
    print(f"  anchor: {anchor}")
    print(f"  command: {shlex.join(command)}")
    completed = subprocess.run(command, text=True)
    if completed.returncode != 0:
        print(f"Code-map sidecar auto-launch failed with exit code {completed.returncode}.")
    return completed.returncode


def print_sidecar_action(repo: Path, reason: str, paths: Iterable[str], *, launch: bool) -> int:
    focus = sidecar_focus(reason, paths)
    command = shlex.join(
        [
            "agent-tmux",
            "codex-code-map-sidecar",
            str(repo),
            "ANCHOR",
            focus,
        ]
    )
    print(
        "Code-map maintenance action required: resolve this before staging or committing. "
        "Do not ask the user to prompt the map update."
    )
    print(
        "Worker action: update the map directly when the route change is small and clear, "
        "or create/choose a fixed snapshot anchor and launch the guarded sidecar yourself:"
    )
    print(f"  {command}")
    print(
        "Replace ANCHOR with a Rewind checkpoint, temporary git anchor, commit, "
        "isolated worktree copy, or archive snapshot; validate and apply sidecar artifacts "
        "before committing."
    )
    if launch:
        return launch_sidecar(repo, reason, paths)
    return 0


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
    parser.add_argument(
        "--strict-review",
        action="store_true",
        help=(
            "Fail when routable files changed but code-map files did not, unless "
            "--reviewed-no-map-change is supplied after an explicit semantic map review"
        ),
    )
    parser.add_argument(
        "--reviewed-no-map-change",
        action="store_true",
        help=(
            "Acknowledge that changed routable files were reviewed and do not require "
            "manifest or subsystem-doc updates for this slice"
        ),
    )
    parser.add_argument(
        "--launch-sidecar",
        choices=("never", "auto"),
        default="never",
        help=(
            "When maintenance is unresolved, create a frozen snapshot and launch the guarded "
            "agent-tmux codex-code-map-sidecar helper automatically. Default never keeps CI "
            "and read-only validation from spawning workers."
        ),
    )
    args = parser.parse_args()
    launch_sidecar_auto = args.launch_sidecar == "auto"

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
        sidecar_rc = print_sidecar_action(
            repo,
            "Update code-map routes for uncovered paths",
            uncovered,
            launch=launch_sidecar_auto,
        )
        if launch_sidecar_auto and sidecar_rc != 0:
            return sidecar_rc
        return 1

    print(f"Code map drift check passed: {len(routable_paths)} changed routable path(s) covered")
    if routable_paths and not map_touched(changed_paths):
        print(
            "Map review note: source/build/docs changed but map files did not. "
            "Confirm no ownership, data-flow, backend-boundary, validation, or public behavior route changed."
        )
        if args.reviewed_no_map_change:
            print(
                "Map semantic review acknowledged: caller asserts no manifest or subsystem-doc "
                "update is required for this slice."
            )
        else:
            sidecar_rc = print_sidecar_action(
                repo,
                "Review semantic code-map maintenance for changed routable paths",
                routable_paths,
                launch=launch_sidecar_auto,
            )
            if launch_sidecar_auto and sidecar_rc != 0:
                return sidecar_rc
            if args.strict_review:
                print(
                    "Strict review mode: map review is unresolved. Update the map, launch the "
                    "sidecar, or rerun with --reviewed-no-map-change only after checking that "
                    "ownership, data flow, backend boundaries, validation, and public routing stayed current."
                )
                return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
