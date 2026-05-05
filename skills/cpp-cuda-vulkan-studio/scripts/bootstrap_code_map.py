#!/usr/bin/env python3
"""Audit, bootstrap, or decline a CppStudio codebase architecture map."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any


STATE_PATH = Path(".cppstudio/code-map-state.json")
INDEX_PATH = Path("docs/CODEBASE_ARCHITECTURE_INDEX.md")
MANIFEST_PATH = Path("docs/CODEBASE_SUBSYSTEM_MANIFEST.json")
AUDIT_PATH = Path("docs/CODEMAP_BOOTSTRAP_AUDIT.md")

IGNORED_DIRS = {
    ".git",
    ".hg",
    ".svn",
    ".cache",
    ".cppstudio",
    ".pytest_cache",
    "__pycache__",
    "artifacts",
    "bin",
    "build",
    "builds",
    "cmake-build-debug",
    "cmake-build-release",
    "dist",
    "external",
    "node_modules",
    "out",
    "third_party",
    "vendor",
}

SOURCE_SUFFIXES = {
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
}

SHADER_SUFFIXES = {
    ".comp",
    ".frag",
    ".geom",
    ".glsl",
    ".hlsl",
    ".mesh",
    ".slang",
    ".tesc",
    ".tese",
    ".vert",
}

BUILD_ARTIFACT_NAMES = {
    "CMakeCache.txt",
    "CMakeFiles",
    "Testing",
    "compile_commands.json",
}

BUILD_ARTIFACT_DIRS = {
    "bin",
    "build",
    "builds",
    "cmake-build-debug",
    "cmake-build-release",
    "dist",
    "out",
}


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


@dataclass(frozen=True)
class AuditFinding:
    severity: str
    title: str
    evidence: str
    recommendation: str


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


def has_path(repo: Path, path_text: str) -> bool:
    return (repo / path_text).exists()


def iter_project_files(repo: Path) -> list[Path]:
    files: list[Path] = []
    for path in repo.rglob("*"):
        try:
            rel = path.relative_to(repo)
        except ValueError:
            continue
        if any(part in IGNORED_DIRS for part in rel.parts):
            continue
        if path.is_file():
            files.append(rel)
    return sorted(files, key=lambda item: item.as_posix())


def sample_paths(paths: list[Path], limit: int = 6) -> str:
    if not paths:
        return "none"
    rendered = [f"`{path.as_posix()}`" for path in paths[:limit]]
    if len(paths) > limit:
        rendered.append(f"... plus {len(paths) - limit} more")
    return ", ".join(rendered)


def assess_restructure_cost(findings: list[AuditFinding]) -> tuple[str, str]:
    weights = {"high": 3, "medium": 2, "low": 1}
    score = sum(weights.get(finding.severity, 1) for finding in findings)
    if score >= 8:
        return ("large", "broad restructuring is likely; plan staged work before enabling the maintained map.")
    if score >= 4:
        return ("medium", "a focused cleanup pass is likely before or alongside map creation.")
    if score > 0:
        return ("small", "a short cleanup pass or documented exception is likely enough.")
    return ("none", "no obvious restructuring needed before enabling the maintained map.")


def audit_existing_repo(repo: Path) -> tuple[list[AuditFinding], dict[str, str]]:
    files = iter_project_files(repo)
    source_files = [path for path in files if path.suffix in SOURCE_SUFFIXES]
    shader_files = [path for path in files if path.suffix in SHADER_SUFFIXES]
    top_level_sources = [path for path in source_files if len(path.parts) == 1]
    top_level_build_dirs = [Path(name) for name in sorted(BUILD_ARTIFACT_DIRS) if (repo / name).exists()]
    build_artifacts = [
        path
        for path in files
        if path.name in BUILD_ARTIFACT_NAMES or any(part in BUILD_ARTIFACT_NAMES for part in path.parts)
    ] + top_level_build_dirs

    has_cuda = any(path.suffix in {".cu", ".cuh"} for path in source_files)
    has_vulkan = any("vulkan" in path.as_posix().lower() for path in source_files + shader_files)
    has_root_cmake = has_path(repo, "CMakeLists.txt")
    has_presets = has_path(repo, "CMakePresets.json")
    has_src = has_path(repo, "src")
    has_include = has_path(repo, "include")
    has_tests = has_path(repo, "tests")
    has_docs = has_path(repo, "docs")
    has_scripts = has_path(repo, "scripts")
    has_cmake_dir = has_path(repo, "cmake")
    has_ci = has_path(repo, ".github/workflows")

    findings: list[AuditFinding] = []
    if not has_root_cmake:
        findings.append(
            AuditFinding(
                "high",
                "Missing root CMake entrypoint",
                "`CMakeLists.txt` was not found at the repository root.",
                "Decide whether this is intentionally non-CMake or whether to normalize around a root CMake entrypoint before enabling the map.",
            )
        )
    if has_root_cmake and not has_presets:
        findings.append(
            AuditFinding(
                "medium",
                "Missing CMake presets",
                "`CMakeLists.txt` exists but `CMakePresets.json` was not found.",
                "Consider adding presets for quick, Vulkan, CUDA, sanitizer, benchmark, and validation lanes before freezing the map.",
            )
        )
    if source_files and not has_src:
        findings.append(
            AuditFinding(
                "medium",
                "No `src/` implementation directory",
                f"Source-like files were found, but no `src/` directory exists. Examples: {sample_paths(source_files)}.",
                "Consider moving implementation code into `src/` with app, library, render, cuda, or domain-specific subdirectories.",
            )
        )
    if top_level_sources:
        findings.append(
            AuditFinding(
                "medium",
                "Source files live at repository root",
                f"Top-level source-like files: {sample_paths(top_level_sources)}.",
                "Consider moving root source files into `src/`, `include/`, `tests/`, or `tools/` before enabling the map.",
            )
        )
    if source_files and not has_include:
        findings.append(
            AuditFinding(
                "low",
                "No public include directory",
                "Source-like files exist, but `include/` was not found.",
                "If the repo exposes reusable APIs, consider a project-owned `include/` tree; otherwise document that headers are private.",
            )
        )
    if not has_tests:
        findings.append(
            AuditFinding(
                "medium",
                "No test directory",
                "`tests/` was not found.",
                "Consider adding at least a smoke/unit-test lane before enabling the map so future agents have validation anchors.",
            )
        )
    if not has_docs:
        findings.append(
            AuditFinding(
                "low",
                "No docs directory",
                "`docs/` was not found before audit output.",
                "Keep architecture, setup, validation, and subsystem map docs under `docs/`.",
            )
        )
    if has_root_cmake and not has_cmake_dir:
        findings.append(
            AuditFinding(
                "low",
                "No `cmake/` helper module directory",
                "`CMakeLists.txt` exists but `cmake/` was not found.",
                "For non-trivial native GPU projects, consider moving reusable CMake modules into `cmake/`.",
            )
        )
    if shader_files and not has_path(repo, "shaders"):
        findings.append(
            AuditFinding(
                "medium",
                "Shader files are not under a `shaders/` root",
                f"Shader-like files were found outside a standard shader root. Examples: {sample_paths(shader_files)}.",
                "Consider collecting shader sources under `shaders/` or document the existing shader ownership in the map.",
            )
        )
    if has_cuda and not has_path(repo, "src/cuda"):
        cuda_files = [path for path in source_files if path.suffix in {".cu", ".cuh"}]
        findings.append(
            AuditFinding(
                "medium",
                "CUDA files are not isolated under `src/cuda`",
                f"CUDA-like files found: {sample_paths(cuda_files)}.",
                "Consider isolating CUDA kernels and launch wrappers behind explicit CUDA build options before enabling the map.",
            )
        )
    if has_vulkan and not (has_path(repo, "src/render") or has_path(repo, "src/vulkan")):
        findings.append(
            AuditFinding(
                "low",
                "Vulkan ownership path is unclear",
                "Vulkan-related names were found, but neither `src/render/` nor `src/vulkan/` exists.",
                "Create a clear render/backend owner directory or document the current Vulkan ownership in the map.",
            )
        )
    if build_artifacts:
        findings.append(
            AuditFinding(
                "medium",
                "Build artifacts appear inside the source tree",
                f"Build-output-like files found: {sample_paths(build_artifacts)}.",
                "Move generated build outputs outside the source tree or add ignore rules before treating the map as durable.",
            )
        )
    if not has_scripts:
        findings.append(
            AuditFinding(
                "low",
                "No scripts directory",
                "`scripts/` was not found.",
                "Consider adding scripts for tool checks, validation wrappers, profiling, or reproducible local workflows.",
            )
        )
    if not has_ci:
        findings.append(
            AuditFinding(
                "low",
                "No GitHub workflow directory",
                "`.github/workflows/` was not found.",
                "If the project is shared through GitHub, consider host-only validation and optional self-hosted GPU lanes.",
            )
        )

    signals = {
        "root CMakeLists.txt": "yes" if has_root_cmake else "no",
        "CMakePresets.json": "yes" if has_presets else "no",
        "src/": "yes" if has_src else "no",
        "include/": "yes" if has_include else "no",
        "tests/": "yes" if has_tests else "no",
        "docs/": "yes" if has_docs else "no",
        "scripts/": "yes" if has_scripts else "no",
        "cmake/": "yes" if has_cmake_dir else "no",
        ".github/workflows/": "yes" if has_ci else "no",
        "source-like files": str(len(source_files)),
        "shader-like files": str(len(shader_files)),
        "CUDA files present": "yes" if has_cuda else "no",
        "Vulkan signals present": "yes" if has_vulkan else "no",
    }
    return findings, signals


def audit_text(repo: Path, findings: list[AuditFinding], signals: dict[str, str]) -> str:
    project_title = title_from_repo(repo)
    cost, cost_note = assess_restructure_cost(findings)
    signal_rows = "\n".join(f"- {key}: {value}" for key, value in signals.items())
    if findings:
        finding_rows = "\n\n".join(
            f"### {index}. {finding.title}\n\n"
            f"- Severity: `{finding.severity}`\n"
            f"- Evidence: {finding.evidence}\n"
            f"- Recommended action: {finding.recommendation}"
            for index, finding in enumerate(findings, start=1)
        )
    else:
        finding_rows = "No obvious structure issues were detected by this lightweight audit."

    return f"""# {project_title} Code Map Readiness Audit

This advisory audit runs before enabling a maintained CppStudio code map on an existing project. It
does not modify source layout and it does not decide for the user.

## Summary

- Findings: {len(findings)}
- Estimated restructuring cost: {cost}
- Cost note: {cost_note}
- Decision timing: present the concrete audit findings first; ask for a route only after the user can
  see what, if anything, would need restructuring.

## Standard Layout Signals

{signal_rows}

## Findings

{finding_rows}

## Agent Protocol

Present this audit before enabling the map and before asking the user to pick a route. Include the
actual findings, evidence paths, and estimated cleanup cost. If the audit found no concrete
restructuring need, say that clearly instead of manufacturing one. After that evidence summary, ask
which route the user wants:

1. Restructure first, validate the new layout, then run `scripts/bootstrap_code_map.py --enable`
   or `scripts/bootstrap_code_map.py --enable --force` if replacing generated map files was accepted.
2. Keep the current layout, enable the map, and document the unorthodox structure in subsystem docs.
3. Decline the map for now with `scripts/bootstrap_code_map.py --decline`.
"""


def audit_existing(repo: Path, force: bool, write_audit: bool) -> None:
    findings, signals = audit_existing_repo(repo)
    cost, _ = assess_restructure_cost(findings)
    text = audit_text(repo, findings, signals)
    if write_audit:
        wrote = atomic_write_text(repo / AUDIT_PATH, text, force)
        print(("wrote" if wrote else "exists") + f": {repo / AUDIT_PATH}")
    else:
        print(text.rstrip())
    print(f"Code map readiness findings: {len(findings)}", file=sys.stderr)
    print(f"Estimated restructuring cost: {cost}", file=sys.stderr)
    if findings:
        print("Present these findings first; only then ask whether to restructure first or preserve the current layout before enabling the map.", file=sys.stderr)
    else:
        print("No obvious restructuring blockers found; tell the user that before asking how to proceed.", file=sys.stderr)


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
        "navigation": "Use the architecture index and manifest as the first navigation step before code changes. Pick the subsystem route, read the subsystem doc, then inspect the route's primary paths.",
        "maintenance": "Update the code map when subsystem ownership, data flow, build/test lanes, backend boundaries, validation, or CI behavior changes.",
    }


def manifest_payload() -> dict[str, Any]:
    return {
        "version": 1,
        "skill_root": "skills",
        "state": str(STATE_PATH),
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

## Navigation Rule

When code-map state is `enabled`, use this index and the manifest as the first navigation step before
code changes. Pick the matching subsystem route, read that subsystem doc, then inspect the primary
paths named by the route.

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


def generated_map_writes(repo: Path, project_title: str) -> list[tuple[Path, str]]:
    writes = [
        (repo / INDEX_PATH, index_text(project_title)),
        (repo / MANIFEST_PATH, json.dumps(manifest_payload(), indent=2) + "\n"),
    ]
    for item in BASE_SUBSYSTEMS:
        writes.append((repo / item["router_doc"], subsystem_text(item)))
    return writes


def enable_map(repo: Path, force: bool) -> None:
    project_title = title_from_repo(repo)
    writes = generated_map_writes(repo, project_title)
    existing = [path for path, _ in writes if path.exists()]
    if existing and not force:
        paths = "\n".join(f"  - {path}" for path in existing)
        raise SystemExit(
            "Refusing to enable a CppStudio code map over existing map files without --force:\n"
            f"{paths}\n"
            "Run --audit-existing first, then rerun --enable --force only if the user accepts "
            "replacing the generated map files."
        )

    for path, text in writes:
        wrote = atomic_write_text(path, text, force)
        print(("wrote" if wrote else "exists") + f": {path}")

    state_wrote = atomic_write_text(repo / STATE_PATH, json.dumps(state_payload("enabled"), indent=2) + "\n", True)
    print(("wrote" if state_wrote else "exists") + f": {repo / STATE_PATH}")


def decline_map(repo: Path, force: bool) -> None:
    _ = force
    wrote = atomic_write_json(repo / STATE_PATH, state_payload("declined"), True)
    print(("wrote" if wrote else "exists") + f": {repo / STATE_PATH}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("repo", nargs="?", default=".", help="Repository root")
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--audit-existing", action="store_true", help="Print a non-destructive existing-project code-map readiness audit")
    action.add_argument("--enable", action="store_true", help="Enable and create a maintained code map")
    action.add_argument("--decline", action="store_true", help="Record that the user declined the code map")
    parser.add_argument("--force", action="store_true", help="Overwrite existing generated map files")
    parser.add_argument("--write-audit", action="store_true", help=f"Write the audit to {AUDIT_PATH} instead of stdout")
    args = parser.parse_args()
    if args.write_audit and not args.audit_existing:
        parser.error("--write-audit can only be used with --audit-existing")

    repo = Path(args.repo).expanduser().resolve()
    if not repo.is_dir():
        raise SystemExit(f"repo directory does not exist: {repo}")

    if args.audit_existing:
        audit_existing(repo, args.force, args.write_audit)
    elif args.enable:
        enable_map(repo, args.force)
    else:
        decline_map(repo, args.force)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
