#!/usr/bin/env python3
"""Run the generated project's viewport-session smoke lane and verify artifacts."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def discover_app(build_dir: Path) -> Path:
    candidates = sorted(
        path for path in build_dir.rglob("*_app") if path.is_file() and path.stat().st_mode & 0o111
    )
    if not candidates:
        raise SystemExit(f"no generated app executable ending in _app found under {build_dir}")
    if len(candidates) > 1:
        names = ", ".join(str(path) for path in candidates[:5])
        raise SystemExit(f"multiple generated app executables found; pass --app explicitly: {names}")
    return candidates[0]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--app", type=Path, help="Path to the generated app executable.")
    parser.add_argument("--build-dir", type=Path, default=Path("build/dev"), help="Build dir for app discovery.")
    parser.add_argument(
        "--session-dir",
        type=Path,
        default=Path("artifacts/viewport-sessions/smoke"),
        help="Output directory for viewport-session artifacts.",
    )
    args = parser.parse_args()

    app = args.app if args.app is not None else discover_app(args.build_dir)
    session_dir = args.session_dir
    command = [
        str(app),
        "--viewport-session-smoke",
        "--viewport-session-dir",
        str(session_dir),
    ]
    completed = subprocess.run(command, text=True)
    if completed.returncode != 0:
        return completed.returncode

    required = [
        session_dir / "metadata.json",
        session_dir / "events.jsonl",
        session_dir / "state_initial.json",
        session_dir / "state_final.json",
        session_dir / "report.json",
        session_dir / "captures" / "final.ppm",
    ]
    missing = [str(path) for path in required if not path.is_file()]
    if missing:
        raise SystemExit("viewport-session smoke did not produce required artifacts: " + ", ".join(missing))

    report = json.loads((session_dir / "report.json").read_text(encoding="utf-8"))
    if not report.get("ok"):
        raise SystemExit(f"viewport-session report failed: {report.get('message', 'unknown')}")
    if report.get("steps_executed", 0) < 1:
        raise SystemExit("viewport-session report did not execute events")

    events_text = (session_dir / "events.jsonl").read_text(encoding="utf-8")
    if '"type":"mouse_move"' not in events_text or '"primary_button_down":true' not in events_text:
        raise SystemExit(
            "viewport-session smoke did not record a held-button move sample; "
            "continuous gestures would be unproven"
        )

    print(f"viewport-session smoke ok: {session_dir / 'report.json'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
