#!/usr/bin/env python3
"""Regression tests for the bundled important-instruction-ledger helper."""

from __future__ import annotations

import importlib.util
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LEDGER_SCRIPT = ROOT / "skills/important-instruction-ledger/scripts/important_instruction_ledger.py"


def load_ledger_module():
    spec = importlib.util.spec_from_file_location("important_instruction_ledger", LEDGER_SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load ledger script: {LEDGER_SCRIPT}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def assert_single_final_newline(text: str, context: str) -> None:
    if not text.endswith("\n"):
        raise AssertionError(f"{context}: missing final newline")
    if text.endswith("\n\n"):
        raise AssertionError(f"{context}: has blank line at EOF")


def test_render_markdown_final_newline() -> None:
    ledger = load_ledger_module()
    entry = ledger.Entry(
        timestamp="2026-05-21T00:00:00Z",
        status="active",
        slice="test",
        scope="project",
        watch="watch this",
        source="unit test",
        trigger="before closeout",
        gate="git diff --check",
        evidence="synthetic",
    )

    assert_single_final_newline(ledger.render_markdown([]), "empty ledger")
    assert_single_final_newline(ledger.render_markdown([entry]), "active entry")
    historical = ledger.Entry(**{**entry.__dict__, "status": "historical"})
    assert_single_final_newline(ledger.render_markdown([historical]), "historical entry")


def test_append_command_preserves_diff_check_hygiene() -> None:
    with tempfile.TemporaryDirectory(prefix="cppstudio_ledger_test_") as tmp:
        project = Path(tmp)
        subprocess.run(
            [
                "python3",
                str(LEDGER_SCRIPT),
                "append",
                "--project",
                str(project),
                "--watch",
                "watch this",
                "--slice",
                "test",
                "--scope",
                "project",
                "--source",
                "regression test",
                "--trigger",
                "before closeout",
                "--gate",
                "git diff --check",
                "--evidence",
                "synthetic",
            ],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        markdown = project / "docs/agent-context/SLICE_WATCHLIST.md"
        assert_single_final_newline(markdown.read_text(encoding="utf-8"), "append output")


def main() -> int:
    test_render_markdown_final_newline()
    test_append_command_preserves_diff_check_hygiene()
    print("important instruction ledger regression tests passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
