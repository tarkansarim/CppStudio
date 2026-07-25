#!/usr/bin/env python3
"""Maintain a compact active slice-watchlist for agent work."""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


LEDGER_DIR = Path("docs/agent-context")
MARKDOWN_NAME = "SLICE_WATCHLIST.md"
JSONL_NAME = "slice-watchlist.jsonl"
LEGACY_MARKDOWN_NAME = "IMPORTANT_USER_INSTRUCTIONS.md"
LEGACY_JSONL_NAME = "important-user-instructions.jsonl"


@dataclass(frozen=True)
class Entry:
    timestamp: str
    status: str
    slice: str
    scope: str
    watch: str
    source: str
    trigger: str
    gate: str
    evidence: str


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")


def resolve_project(path_text: str) -> Path:
    project = Path(path_text).expanduser().resolve(strict=False)
    if not project.exists() or not project.is_dir():
        raise SystemExit(f"Project directory does not exist: {project}")
    return project


def paths(project: Path) -> tuple[Path, Path]:
    root = project / LEDGER_DIR
    return root / MARKDOWN_NAME, root / JSONL_NAME


def legacy_paths(project: Path) -> tuple[Path, Path]:
    root = project / LEDGER_DIR
    return root / LEGACY_MARKDOWN_NAME, root / LEGACY_JSONL_NAME


def load_entries(jsonl_path: Path) -> list[Entry]:
    if not jsonl_path.exists():
        return []
    entries: list[Entry] = []
    with jsonl_path.open("r", encoding="utf-8") as handle:
        for line_number, line in enumerate(handle, start=1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                data = json.loads(stripped)
            except json.JSONDecodeError as exc:
                raise SystemExit(f"{jsonl_path}:{line_number}: invalid JSONL entry: {exc}") from exc
            entries.append(
                Entry(
                    timestamp=str(data.get("timestamp", "")),
                    status=str(data.get("status", "")),
                    slice=str(data.get("slice", "global")),
                    scope=str(data.get("scope", "")),
                    watch=str(data.get("watch", data.get("summary", ""))),
                    source=str(data.get("source", "")),
                    trigger=str(data.get("trigger", "")),
                    gate=str(data.get("gate", "")),
                    evidence=str(data.get("evidence", "")),
                )
            )
    return entries


def load_project_entries(project: Path, jsonl_path: Path) -> list[Entry]:
    if jsonl_path.exists():
        return load_entries(jsonl_path)
    _, legacy_jsonl_path = legacy_paths(project)
    return load_entries(legacy_jsonl_path)


def render_markdown(entries: Iterable[Entry]) -> str:
    active = [entry for entry in entries if entry.status == "active"]
    other = [entry for entry in entries if entry.status != "active"]
    lines = [
        "# Active Slice Watchlist",
        "",
        "This file is agent-maintained. It lists what the supervising or direct agent must keep",
        "watching during each implementation slice: constraints, risks, gates, donor facts, user",
        "rules, verification expectations, and rejection conditions that must survive compaction and",
        "worker handoffs.",
        "",
        "## Active",
        "",
    ]
    if active:
        for index, entry in enumerate(active, start=1):
            lines.extend(render_entry(index, entry))
    else:
        lines.append("- No active entries.")
    lines.extend(["", "## Superseded Or Historical", ""])
    if other:
        for index, entry in enumerate(other, start=1):
            lines.extend(render_entry(index, entry))
    else:
        lines.append("- No historical entries.")
    return "\n".join(lines).rstrip() + "\n"


def render_entry(index: int, entry: Entry) -> list[str]:
    return [
        f"{index}. **{entry.watch}**",
        f"   - Status: `{entry.status}`",
        f"   - Slice: `{entry.slice}`",
        f"   - Scope: `{entry.scope}`",
        f"   - Source: {entry.source}",
        f"   - Revisit when: {entry.trigger}",
        f"   - Gate: {entry.gate or 'none recorded'}",
        f"   - Evidence: {entry.evidence or 'none recorded'}",
        f"   - Recorded: `{entry.timestamp}`",
        "",
    ]


def write_entries(markdown_path: Path, jsonl_path: Path, entries: list[Entry]) -> None:
    markdown_path.parent.mkdir(parents=True, exist_ok=True)
    with jsonl_path.open("w", encoding="utf-8") as handle:
        for entry in entries:
            handle.write(json.dumps(asdict(entry), sort_keys=True) + "\n")
    markdown_path.write_text(render_markdown(entries), encoding="utf-8")


def print_review(project: Path, markdown_path: Path, entries: list[Entry]) -> None:
    active = [entry for entry in entries if entry.status == "active"]
    print(f"Slice watchlist: {markdown_path}")
    print(f"Active entries: {len(active)}")
    for entry in active:
        print(f"- [{entry.slice} | {entry.scope}] {entry.watch}")
        print(f"  Revisit when: {entry.trigger}")
        if entry.gate:
            print(f"  Gate: {entry.gate}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="Create the watchlist files if missing.")
    init_parser.add_argument("--project", required=True)

    review_parser = subparsers.add_parser("review", help="Print active watchlist items.")
    review_parser.add_argument("--project", required=True)

    append_parser = subparsers.add_parser("append", help="Append one watchlist entry.")
    append_parser.add_argument("--project", required=True)
    append_parser.add_argument("--watch", help="What the agent must actively watch or reject.")
    append_parser.add_argument("--summary", help="Deprecated alias for --watch.")
    append_parser.add_argument("--slice", default="current-slice")
    append_parser.add_argument("--scope", required=True)
    append_parser.add_argument("--source", required=True)
    append_parser.add_argument("--trigger", required=True)
    append_parser.add_argument("--gate", default="")
    append_parser.add_argument("--evidence", default="")
    append_parser.add_argument(
        "--status",
        default="active",
        choices=("active", "superseded", "historical"),
    )

    args = parser.parse_args()
    project = resolve_project(args.project)
    markdown_path, jsonl_path = paths(project)
    entries = load_project_entries(project, jsonl_path)

    if args.command == "init":
        write_entries(markdown_path, jsonl_path, entries)
        print_review(project, markdown_path, entries)
        return 0
    if args.command == "review":
        print_review(project, markdown_path, entries)
        return 0
    if args.command == "append":
        watch = args.watch or args.summary
        if not watch:
            raise SystemExit("append requires --watch or deprecated --summary")
        entry = Entry(
            timestamp=utc_now(),
            status=args.status,
            slice=args.slice,
            scope=args.scope,
            watch=watch,
            source=args.source,
            trigger=args.trigger,
            gate=args.gate,
            evidence=args.evidence,
        )
        entries.append(entry)
        write_entries(markdown_path, jsonl_path, entries)
        print_review(project, markdown_path, entries)
        return 0
    raise AssertionError(args.command)


if __name__ == "__main__":
    raise SystemExit(main())
