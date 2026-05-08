#!/usr/bin/env python3
"""Render a manual/subagent trigger-evaluation prompt pack from trigger-matrix.json."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("matrix", type=Path, help="Path to research/donor-library/trigger-matrix.json")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd())
    parser.add_argument("--case", action="append", dest="cases", default=[], help="Case name to include; repeatable")
    parser.add_argument("--tag", action="append", default=[], help="Tag to include; repeatable")
    parser.add_argument(
        "--installed-paths",
        action="store_true",
        help="Render source skill paths as installed user-level Codex paths.",
    )
    parser.add_argument(
        "--codex-home",
        type=Path,
        default=None,
        help="Codex home for --installed-paths; defaults to SYNC_CODEX_HOME or ~/.codex.",
    )
    parser.add_argument(
        "--write-result-template",
        type=Path,
        default=None,
        help="Write a structured JSON result template for the selected cases.",
    )
    return parser.parse_args()


def load_matrix(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise SystemExit(f"missing trigger matrix: {path}") from None
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid trigger matrix JSON: {error}") from None
    if not isinstance(data, dict):
        raise SystemExit("trigger matrix root must be an object")
    return data


def case_tags(case: dict[str, Any]) -> list[str]:
    tags = case.get("tags", [])
    if not isinstance(tags, list):
        return []
    return [tag for tag in tags if isinstance(tag, str)]


def sorted_tags(cases: list[dict[str, Any]]) -> list[str]:
    tags = {tag for case in cases for tag in case_tags(case)}
    return sorted(tags)


def validate_requested_filters(cases: list[dict[str, Any]], requested_cases: list[str], requested_tags: list[str]) -> None:
    names = {case.get("name") for case in cases if isinstance(case.get("name"), str)}
    unknown_cases = [name for name in requested_cases if name not in names]
    if unknown_cases:
        available = ", ".join(sorted(names))
        raise SystemExit(f"unknown trigger case(s): {', '.join(unknown_cases)}\navailable cases: {available}")

    tags = set(sorted_tags(cases))
    unknown_tags = [tag for tag in requested_tags if tag not in tags]
    if unknown_tags:
        available = ", ".join(sorted(tags)) or "(none)"
        raise SystemExit(f"unknown trigger tag(s): {', '.join(unknown_tags)}\navailable tags: {available}")


def filter_cases(cases: list[dict[str, Any]], requested_cases: list[str], requested_tags: list[str]) -> list[dict[str, Any]]:
    selected = cases
    if requested_cases:
        wanted = set(requested_cases)
        selected = [case for case in selected if case.get("name") in wanted]
    if requested_tags:
        wanted_tags = set(requested_tags)
        selected = [case for case in selected if wanted_tags & set(case_tags(case))]
    return selected


def installed_codex_home(raw: Path | None) -> Path:
    if raw is not None:
        return raw.expanduser().resolve()
    env_home = os.environ.get("SYNC_CODEX_HOME")
    if env_home:
        return Path(env_home).expanduser().resolve()
    return (Path.home() / ".codex").resolve()


def display_path(relative: str, repo_root: Path, codex_home: Path | None) -> str:
    if codex_home is None:
        return relative
    source_prefix = "skills/"
    if relative == "AGENTS.md":
        return str(codex_home / "AGENTS.md")
    if relative.startswith(source_prefix):
        return str(codex_home / relative)
    return str(repo_root / relative)


def render_paths(label: str, paths: list[Any], repo_root: Path, codex_home: Path | None) -> list[str]:
    if not paths:
        return [f"**{label}:** none"]
    lines = [f"**{label}:**"]
    for path in paths:
        rendered = display_path(str(path), repo_root, codex_home)
        lines.append(f"- `{rendered}`")
    return lines


def render_case(index: int, case: dict[str, Any], repo_root: Path, codex_home: Path | None) -> list[str]:
    name = str(case["name"])
    tags = case_tags(case)
    lines = [
        f"## {index}. {name}",
        "",
        f"**Tags:** {', '.join(tags) if tags else '(untagged)'}",
        "",
        "**Prompt to give the fresh evaluator:**",
        "",
        "```text",
        str(case["prompt_shape"]),
        "```",
        "",
        f"**Expected behavior:** {case['expected_behavior']}",
        "",
    ]
    lines.extend(render_paths("Expected paths", case.get("expected_paths", []), repo_root, codex_home))
    lines.append("")
    lines.extend(render_paths("Forbidden paths or files", case.get("must_not_trigger_paths", []), repo_root, codex_home))
    lines.extend(
        [
            "",
            "**Result to fill in:**",
            "- Selected skills:",
            "- Opened files:",
            "- Forbidden paths used: yes/no",
            "- Verdict: pass/fail/needs-review",
            "- Notes:",
            "",
        ]
    )
    return lines


def render_prompt(matrix: dict[str, Any], cases: list[dict[str, Any]], repo_root: Path, codex_home: Path | None) -> str:
    mode = "installed Codex paths" if codex_home is not None else "repo-relative source paths"
    lines = [
        "# CppStudio Trigger Evaluation Pack",
        "",
        str(matrix.get("description", "")).strip(),
        "",
        f"Path mode: {mode}",
        f"Cases included: {len(cases)}",
        "",
        "Instructions for the evaluator:",
        "- Use a fresh agent/subagent or reviewer context when possible.",
        "- For each case, respond with selected skills, files opened, forbidden paths used, verdict, and notes.",
        "- Treat forbidden paths as no-touch paths: do not open, read, search, stat, list, or existence-check them.",
        "- Do not infer success from this pack alone; it is a prompt/report template for a real trigger run.",
        "",
    ]
    for index, case in enumerate(cases, 1):
        lines.extend(render_case(index, case, repo_root, codex_home))
    return "\n".join(lines).rstrip() + "\n"


def result_template(matrix: dict[str, Any], cases: list[dict[str, Any]], repo_root: Path, codex_home: Path | None) -> dict[str, Any]:
    mode = "installed" if codex_home is not None else "repo"
    rendered_cases: list[dict[str, Any]] = []
    for case in cases:
        expected_paths = [display_path(str(path), repo_root, codex_home) for path in case.get("expected_paths", [])]
        forbidden_paths = [display_path(str(path), repo_root, codex_home) for path in case.get("must_not_trigger_paths", [])]
        rendered_cases.append(
            {
                "name": case.get("name"),
                "tags": case_tags(case),
                "prompt_shape": case.get("prompt_shape"),
                "expected_behavior": case.get("expected_behavior"),
                "expected_paths": expected_paths,
                "forbidden_paths": forbidden_paths,
                "result": {
                    "selected_skills": [],
                    "opened_files": [],
                    "forbidden_paths_used": None,
                    "verdict": "pending",
                    "notes": "",
                },
            }
        )
    return {
        "schema_version": 1,
        "matrix_description": matrix.get("description", ""),
        "path_mode": mode,
        "case_count": len(rendered_cases),
        "cases": rendered_cases,
    }


def main() -> int:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    matrix = load_matrix(args.matrix)
    cases = matrix.get("cases")
    if not isinstance(cases, list):
        print("trigger matrix cases must be a list", file=sys.stderr)
        return 1
    valid_cases = [case for case in cases if isinstance(case, dict)]
    validate_requested_filters(valid_cases, args.cases, args.tag)
    selected = filter_cases(valid_cases, args.cases, args.tag)
    if not selected:
        print("no trigger cases matched the requested filters", file=sys.stderr)
        return 1
    codex_home = installed_codex_home(args.codex_home) if args.installed_paths else None
    if args.write_result_template is not None:
        output_path = args.write_result_template
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(
            json.dumps(result_template(matrix, selected, repo_root, codex_home), indent=2) + "\n",
            encoding="utf-8",
        )
    sys.stdout.write(render_prompt(matrix, selected, repo_root, codex_home))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
