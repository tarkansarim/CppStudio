#!/usr/bin/env python3
"""Merge the minimal CppStudio relay into a user-level AGENTS.md."""

from __future__ import annotations

import argparse
import os
import tempfile
from pathlib import Path


BEGIN = "<!-- cppstudio-user-agents-relay:begin -->"
END = "<!-- cppstudio-user-agents-relay:end -->"
MAX_RELAY_CHARS = 500


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--preflight", action="store_true", help="Validate the merge without writing")
    mode.add_argument("--install", action="store_true", help="Atomically write the merged AGENTS.md")
    parser.add_argument("--target", type=Path, required=True, help="User-level AGENTS.md path")
    parser.add_argument("--snippet", type=Path, required=True, help="Minimal relay snippet")
    parser.add_argument(
        "--expected-target",
        type=Path,
        required=True,
        help="Expected user-level AGENTS.md path. Different targets require --allow-target-override.",
    )
    parser.add_argument(
        "--allow-target-override",
        action="store_true",
        help="Allow --target to differ from --expected-target after safety checks.",
    )
    return parser.parse_args()


def read_relay(snippet: Path) -> str:
    if not snippet.is_file():
        raise FileNotFoundError(f"missing relay snippet: {snippet}")
    text = snippet.read_text(encoding="utf-8").strip()
    begin_count = text.count(BEGIN)
    end_count = text.count(END)
    if begin_count != 1 or end_count != 1:
        raise ValueError(
            f"relay snippet must contain exactly one {BEGIN!r} and one {END!r}: {snippet}"
        )
    if text.index(END) <= text.index(BEGIN):
        raise ValueError(f"relay snippet has reversed markers: {snippet}")
    if "{{" in text or "}}" in text:
        raise ValueError(f"relay snippet contains unresolved placeholders: {snippet}")
    if len(text) > MAX_RELAY_CHARS:
        raise ValueError(f"relay snippet is too large for AGENTS.md injection: {len(text)} chars")
    return text


def merge_relay(existing: str, relay: str, target: Path) -> str:
    begin_count = existing.count(BEGIN)
    end_count = existing.count(END)
    if begin_count != end_count:
        raise ValueError(f"target AGENTS.md has mismatched CppStudio relay markers: {target}")
    if begin_count > 1:
        raise ValueError(f"target AGENTS.md has multiple CppStudio relay blocks: {target}")
    if begin_count == 1:
        start = existing.index(BEGIN)
        end_start = existing.index(END)
        if end_start <= start:
            raise ValueError(f"target AGENTS.md has reversed CppStudio relay markers: {target}")
        end = end_start + len(END)
        while end < len(existing) and existing[end] in "\r\n":
            end += 1
        prefix = existing[:start].rstrip()
        suffix = existing[end:].lstrip()
        if suffix:
            return prefix + "\n\n" + relay + "\n\n" + suffix if prefix else relay + "\n\n" + suffix
        return prefix + "\n\n" + relay + "\n" if prefix else relay + "\n"

    if relay in existing:
        return existing
    separator = "\n\n" if existing.rstrip() else ""
    return existing.rstrip() + separator + relay + "\n"


def atomic_write(path: Path, text: str) -> None:
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


def validate_target(target: Path, expected_target: Path | None, allow_override: bool) -> Path:
    expanded = target.expanduser()
    if expanded.name != "AGENTS.md":
        raise ValueError(f"relay target must be named AGENTS.md: {expanded}")
    if expanded.is_symlink():
        raise ValueError(f"relay target must not be a symlink: {expanded}")

    resolved = expanded.resolve(strict=False)
    if expected_target is not None:
        expected_resolved = expected_target.expanduser().resolve(strict=False)
        if resolved != expected_resolved and not allow_override:
            raise ValueError(
                "relay target differs from expected user-level AGENTS.md; "
                "pass --allow-target-override only for deliberate staging targets: "
                f"{resolved} != {expected_resolved}"
            )
    return resolved


def main() -> int:
    args = parse_args()
    target = validate_target(args.target, args.expected_target, args.allow_target_override)
    relay = read_relay(args.snippet.expanduser().resolve())
    existing = target.read_text(encoding="utf-8") if target.exists() else ""
    merged = merge_relay(existing, relay, target)

    if args.preflight:
        action = "unchanged" if merged == existing else "merge"
        print(f"preflight ok: {action} {target}")
        return 0

    if merged == existing:
        print(f"ok: {target}")
    else:
        atomic_write(target, merged)
        print(f"updated: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
