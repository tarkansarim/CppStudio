#!/usr/bin/env python3
"""Bootstrap or decline a CppStudio codebase architecture map."""

from __future__ import annotations

import argparse
import json
import os
import re
import tempfile
from pathlib import Path
from typing import Any


STATE_PATH = Path(".cppstudio/code-map-state.json")
INDEX_PATH = Path("docs/CODEBASE_ARCHITECTURE_INDEX.md")
MANIFEST_PATH = Path("docs/CODEBASE_SUBSYSTEM_MANIFEST.json")


BASE_SUBSYSTEMS: list[dict[str, Any]] = [
    {
        "id": "build_and_presets",
        "name": "Build And Presets",
        "router_doc": "docs/SUBSYSTEMS/build-and-presets.md",
        "canonical_docs": ["docs/DEVELOPMENT_ENVIRONMENT.md", "docs/VALIDATION_PIPELINE.md"],
        "primary_paths": ["CMakeLists.txt", "CMakePresets.json", "cmake"],
        "summary": "CMake targets, presets, compiler options, warning policy, sanitizer wiring, and dependency switches.",
    },
    {
        "id": "app_core",
        "name": "App Core",
        "router_doc": "docs/SUBSYSTEMS/app-core.md",
        "canonical_docs": ["README.md"],
        "primary_paths": ["src/app", "src/core", "include"],
        "summary": "Application entrypoint, reusable library code, public headers, and project-owned runtime behavior.",
    },
    {
        "id": "vulkan_lane",
        "name": "Vulkan Lane",
        "router_doc": "docs/SUBSYSTEMS/vulkan-lane.md",
        "canonical_docs": ["docs/DEVELOPMENT_ENVIRONMENT.md", "docs/VALIDATION_PIPELINE.md"],
        "primary_paths": ["src/render", "shaders"],
        "summary": "Vulkan runtime code, shader assets, SPIR-V tooling, device capability checks, and validation-layer evidence.",
    },
    {
        "id": "cuda_lane",
        "name": "CUDA Lane",
        "router_doc": "docs/SUBSYSTEMS/cuda-lane.md",
        "canonical_docs": ["docs/DEVELOPMENT_ENVIRONMENT.md", "docs/VALIDATION_PIPELINE.md"],
        "primary_paths": ["src/cuda", "include/*/cuda_vector_add.hpp"],
        "summary": "Explicit CUDA-only work, kernels, launch wrappers, CUDA architecture policy, and Compute Sanitizer lanes.",
    },
    {
        "id": "validation_ci",
        "name": "Validation And CI",
        "router_doc": "docs/SUBSYSTEMS/validation-ci.md",
        "canonical_docs": ["docs/VALIDATION_PIPELINE.md", "docs/GPU_RUNNER_CI.md", "docs/BENCHMARKS.md"],
        "primary_paths": ["tests", "benchmarks", "scripts", ".github/workflows"],
        "summary": "CTest labels, smoke tests, GPU runner expectations, profiling evidence, formatting, and static analysis.",
    },
]


def title_from_repo(repo: Path) -> str:
    name = repo.name.strip() or "Project"
    words = re.sub(r"[_-]+", " ", name).strip()
    return words.title() if words else "Project"


def atomic_write_text(path: Path, text: str, force: bool) -> bool:
    if path.exists() and not force:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    mode = path.stat().st_mode if path.exists() else 0o644
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
    return True


def atomic_write_json(path: Path, data: dict[str, Any], force: bool) -> bool:
    return atomic_write_text(path, json.dumps(data, indent=2, sort_keys=False) + "\n", force)


def state_payload(status: str) -> dict[str, Any]:
    if status == "declined":
        return {
            "version": 1,
            "code_map": "declined",
            "do_not_prompt_again": True,
        }
    return {
        "version": 1,
        "code_map": "enabled",
        "index": str(INDEX_PATH),
        "manifest": str(MANIFEST_PATH),
        "maintenance": "Update the code map when subsystem ownership, data flow, build/test lanes, backend boundaries, validation, or CI behavior changes.",
    }


def manifest_payload() -> dict[str, Any]:
    return {
        "version": 1,
        "skill_root": "skills",
        "router_doc": str(INDEX_PATH),
        "subsystems": [
            {
                "id": item["id"],
                "name": item["name"],
                "router_doc": item["router_doc"],
                "canonical_docs": item["canonical_docs"],
                "primary_paths": item["primary_paths"],
            }
            for item in BASE_SUBSYSTEMS
        ],
    }


def index_text(project_title: str) -> str:
    rows = "\n".join(
        f"- {item['name']}: [{item['router_doc']}]({item['router_doc'].replace('docs/', './')})"
        for item in BASE_SUBSYSTEMS
    )
    return f"""# {project_title} Codebase Architecture Index

Start here when context is cold or when choosing the right subsystem lane before editing code.

This map is intentionally thin. It routes agents into maintained subsystem docs and the machine-readable
manifest instead of forcing every session to load all implementation notes.

## State

- State marker: `.cppstudio/code-map-state.json`
- Machine manifest: [CODEBASE_SUBSYSTEM_MANIFEST.json](./CODEBASE_SUBSYSTEM_MANIFEST.json)

## Subsystem Routes

{rows}

## Maintenance Rule

When code-map state is `enabled`, update this map in the same work stream as changes that affect
subsystem ownership, GPU backend boundaries, build/test lanes, data flow, validation, CI, or public
runtime behavior. If the map and code disagree, inspect the code and update the map.
"""


def subsystem_text(item: dict[str, Any]) -> str:
    docs = "\n".join(f"- `{doc}`" for doc in item["canonical_docs"])
    paths = "\n".join(f"- `{path}`" for path in item["primary_paths"])
    return f"""# {item['name']}

{item['summary']}

## Canonical Docs

{docs}

## Primary Paths

{paths}

## Update When

- ownership or data flow in this subsystem changes
- build, test, validation, or backend requirements change
- a new neighboring subsystem becomes part of the workflow
"""


def enable_map(repo: Path, force: bool) -> None:
    project_title = title_from_repo(repo)
    state_wrote = atomic_write_text(repo / STATE_PATH, json.dumps(state_payload("enabled"), indent=2) + "\n", True)
    print(("wrote" if state_wrote else "exists") + f": {repo / STATE_PATH}")

    writes = [
        (repo / INDEX_PATH, index_text(project_title)),
        (repo / MANIFEST_PATH, json.dumps(manifest_payload(), indent=2) + "\n"),
    ]
    for item in BASE_SUBSYSTEMS:
        writes.append((repo / item["router_doc"], subsystem_text(item)))

    for path, text in writes:
        wrote = atomic_write_text(path, text, force)
        print(("wrote" if wrote else "exists") + f": {path}")


def decline_map(repo: Path, force: bool) -> None:
    _ = force
    wrote = atomic_write_json(repo / STATE_PATH, state_payload("declined"), True)
    print(("wrote" if wrote else "exists") + f": {repo / STATE_PATH}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository root")
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--enable", action="store_true", help="Enable and create a maintained code map")
    action.add_argument("--decline", action="store_true", help="Record that the user declined the code map")
    parser.add_argument("--force", action="store_true", help="Overwrite existing generated map files")
    args = parser.parse_args()

    repo = Path(args.repo).expanduser().resolve()
    if not repo.is_dir():
        raise SystemExit(f"repo directory does not exist: {repo}")

    if args.enable:
        enable_map(repo, args.force)
    else:
        decline_map(repo, args.force)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
