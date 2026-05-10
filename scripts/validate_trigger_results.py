#!/usr/bin/env python3
"""Validate recorded trigger-probe result artifacts.

The trigger matrix says what a fresh agent should load. Result artifacts say what a concrete
fresh-agent probe actually loaded. This check prevents a recorded `pass` verdict from silently
missing expected skill or donor paths.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


PASS_VERDICT = "pass"
ALLOWED_VERDICTS = {"pending", "pass", "partial", "needs-review", "fail"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("results", type=Path, nargs="+", help="Path(s) to trigger result JSON artifacts")
    parser.add_argument("--matrix", type=Path, default=None, help="Anchor result cases to trigger-matrix.json")
    parser.add_argument("--repo-root", type=Path, default=Path.cwd(), help="Repo root for rendering matrix paths")
    parser.add_argument("--codex-home", type=Path, default=None, help="Codex home for installed path-mode results")
    parser.add_argument(
        "--expected-path-mode",
        choices=("repo", "installed", "portable-installed"),
        default=None,
        help="Require the artifact path_mode and matrix rendering mode to match this value.",
    )
    parser.add_argument(
        "--require-case",
        action="append",
        default=[],
        help="Require a case name to be present in every result artifact; repeatable.",
    )
    return parser.parse_args()


def string_list(value: object, artifact: Path, case_name: str, field_name: str, errors: list[str]) -> list[str]:
    if not isinstance(value, list):
        errors.append(f"{artifact}:{case_name}: {field_name} must be a list")
        return []
    strings: list[str] = []
    for index, item in enumerate(value, 1):
        if not isinstance(item, str) or not item.strip():
            errors.append(f"{artifact}:{case_name}: {field_name}[{index}] must be a non-empty string")
            continue
        strings.append(item.strip())
    return strings


def installed_codex_home(raw: Path | None) -> Path:
    if raw is not None:
        return raw.expanduser().resolve()
    env_home = os.environ.get("SYNC_CODEX_HOME")
    if env_home:
        return Path(env_home).expanduser().resolve()
    return (Path.home() / ".codex").resolve()


def display_path(relative: str, repo_root: Path, codex_home: Path | None, portable_installed: bool = False) -> str:
    if codex_home is None:
        return relative
    if portable_installed:
        if relative == "AGENTS.md":
            return "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
        if relative.startswith("skills/"):
            return f"${{CODEX_HOME:-$HOME/.codex}}/{relative}"
        return f"${{CPPSTUDIO_SOURCE_ROOT:-<CppStudio source>}}/{relative}"
    if relative == "AGENTS.md":
        return str(codex_home / "AGENTS.md")
    if relative.startswith("skills/"):
        return str(codex_home / relative)
    return str(repo_root / relative)


def load_matrix_contracts(
    matrix_path: Path | None,
    repo_root: Path,
    path_mode: str,
    codex_home_arg: Path | None,
) -> dict[str, dict[str, list[str]]] | None:
    if matrix_path is None:
        return None
    try:
        matrix = json.loads(matrix_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise SystemExit(f"missing trigger matrix: {matrix_path}") from None
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid trigger matrix JSON: {error}") from None
    cases = matrix.get("cases") if isinstance(matrix, dict) else None
    if not isinstance(cases, list):
        raise SystemExit(f"{matrix_path}: trigger matrix cases must be a list")

    if path_mode == "repo":
        codex_home = None
        portable_installed = False
    elif path_mode == "installed":
        codex_home = installed_codex_home(codex_home_arg)
        portable_installed = False
    elif path_mode == "portable-installed":
        codex_home = installed_codex_home(codex_home_arg)
        portable_installed = True
    else:
        raise SystemExit(f"unsupported trigger result path_mode for matrix anchoring: {path_mode!r}")

    contracts: dict[str, dict[str, list[str]]] = {}
    for case in cases:
        if not isinstance(case, dict) or not isinstance(case.get("name"), str):
            continue
        contracts[case["name"]] = {
            "expected_paths": [
                display_path(str(path), repo_root, codex_home, portable_installed)
                for path in case.get("expected_paths", [])
            ],
            "forbidden_paths": [
                display_path(str(path), repo_root, codex_home, portable_installed)
                for path in case.get("must_not_trigger_paths", [])
            ],
        }
    return contracts


def validate_run_metadata(artifact: Path, payload: dict[str, object], pass_cases: bool, errors: list[str]) -> None:
    if not pass_cases:
        return
    run = payload.get("run")
    if not isinstance(run, dict):
        errors.append(f"{artifact}: pass cases require a run metadata object")
        return
    for field_name in ("run_date", "agent_environment", "render_command"):
        value = run.get(field_name)
        if not isinstance(value, str) or not value.strip():
            errors.append(f"{artifact}: pass cases require run.{field_name}")


def validate_artifact(
    artifact: Path,
    matrix_contracts: dict[str, dict[str, list[str]]] | None,
    expected_path_mode: str | None,
    required_cases: set[str],
) -> list[str]:
    errors: list[str] = []
    if not artifact.is_file():
        return [f"missing trigger result artifact: {artifact}"]

    try:
        payload = json.loads(artifact.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        return [f"{artifact}: invalid JSON: {error}"]
    if not isinstance(payload, dict):
        return [f"{artifact}: result artifact must be a JSON object"]

    cases = payload.get("cases")
    if not isinstance(cases, list):
        return [f"{artifact}: cases must be a list"]

    path_mode = payload.get("path_mode", "repo")
    if expected_path_mode is not None and path_mode != expected_path_mode:
        errors.append(f"{artifact}: path_mode {path_mode!r} does not match required {expected_path_mode!r}")

    pass_cases = False
    seen_names: set[str] = set()
    for index, case in enumerate(cases, 1):
        if not isinstance(case, dict):
            errors.append(f"{artifact}: case #{index} must be an object")
            continue
        name = case.get("name")
        if not isinstance(name, str) or not name.strip():
            errors.append(f"{artifact}: case #{index} missing name")
            name = f"case #{index}"
        elif name in seen_names:
            errors.append(f"{artifact}:{name}: duplicate case name")
        else:
            seen_names.add(name)

        expected_paths = string_list(case.get("expected_paths", []), artifact, str(name), "expected_paths", errors)
        forbidden_paths = string_list(case.get("forbidden_paths", []), artifact, str(name), "forbidden_paths", errors)
        if matrix_contracts is not None:
            contract = matrix_contracts.get(str(name))
            if contract is None:
                errors.append(f"{artifact}:{name}: result case is not present in trigger matrix")
            else:
                contract_expected = contract["expected_paths"]
                contract_forbidden = contract["forbidden_paths"]
                if expected_paths != contract_expected:
                    errors.append(
                        f"{artifact}:{name}: expected_paths do not match trigger matrix: "
                        f"artifact={expected_paths!r} matrix={contract_expected!r}"
                    )
                if forbidden_paths != contract_forbidden:
                    errors.append(
                        f"{artifact}:{name}: forbidden_paths do not match trigger matrix: "
                        f"artifact={forbidden_paths!r} matrix={contract_forbidden!r}"
                    )
        result = case.get("result")
        if not isinstance(result, dict):
            errors.append(f"{artifact}:{name}: result must be an object")
            continue

        verdict = result.get("verdict")
        if verdict not in ALLOWED_VERDICTS:
            errors.append(f"{artifact}:{name}: result.verdict must be one of {sorted(ALLOWED_VERDICTS)}")
            verdict = None

        opened_files = string_list(result.get("opened_files", []), artifact, str(name), "result.opened_files", errors)
        opened_set = set(opened_files)
        missing_expected = sorted(path for path in expected_paths if path not in opened_set)
        forbidden_used = sorted(path for path in forbidden_paths if path in opened_set)

        if forbidden_used:
            errors.append(f"{artifact}:{name}: forbidden path opened: {', '.join(forbidden_used)}")

        if verdict == PASS_VERDICT:
            pass_cases = True
            if result.get("forbidden_paths_used") is not False:
                errors.append(f"{artifact}:{name}: pass requires result.forbidden_paths_used=false")
            if missing_expected:
                errors.append(f"{artifact}:{name}: pass missing expected opened path(s): {', '.join(missing_expected)}")
            if not opened_files:
                errors.append(f"{artifact}:{name}: pass requires non-empty result.opened_files")
            if not string_list(result.get("selected_skills", []), artifact, str(name), "result.selected_skills", errors):
                errors.append(f"{artifact}:{name}: pass requires non-empty result.selected_skills")

    declared_count = payload.get("case_count")
    if isinstance(declared_count, int) and declared_count != len(cases):
        errors.append(f"{artifact}: case_count {declared_count} does not match cases length {len(cases)}")
    for required_case in sorted(required_cases - seen_names):
        errors.append(f"{artifact}: missing required result case: {required_case}")
    if pass_cases and matrix_contracts is None:
        errors.append(f"{artifact}: pass cases require --matrix anchoring to trigger-matrix.json")
    validate_run_metadata(artifact, payload, pass_cases, errors)
    return errors


def main() -> int:
    args = parse_args()
    errors: list[str] = []
    for artifact in args.results:
        try:
            payload = json.loads(artifact.read_text(encoding="utf-8"))
            artifact_path_mode = str(payload.get("path_mode", "repo")) if isinstance(payload, dict) else "repo"
        except (FileNotFoundError, json.JSONDecodeError):
            artifact_path_mode = "repo"
        path_mode = args.expected_path_mode or artifact_path_mode
        matrix_contracts = load_matrix_contracts(
            args.matrix,
            args.repo_root.resolve(),
            path_mode,
            args.codex_home,
        )
        errors.extend(validate_artifact(artifact, matrix_contracts, args.expected_path_mode, set(args.require_case)))
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        print(f"Trigger result validation failed: {len(errors)} error(s)", file=sys.stderr)
        return 1
    print("Trigger result validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
