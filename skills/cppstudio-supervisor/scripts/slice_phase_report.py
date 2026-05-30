#!/usr/bin/env python3
"""Summarize CppStudio supervised-slice phase markers.

Workers and supervisors can write compact marker lines into transcripts or logs:

CPPSTUDIO_PHASE event=start phase=research ts=2026-05-30T01:00:00Z note="donors"
CPPSTUDIO_PHASE event=end phase=research ts=2026-05-30T01:04:30Z status=ok
CPPSTUDIO_PHASE event=end phase=ostm_ui ts=2026-05-30T01:09:00Z classification=required_acceptance ostm_job=7578 artifact=/tmp/ui

The parser is intentionally line-oriented so it can run on captured tmux logs,
worker-written phase logs, or pasted transcript snippets without a database.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass, field
from datetime import datetime, timezone
import json
from pathlib import Path
import shlex
import sys
from typing import Iterable


MARKER = "CPPSTUDIO_PHASE"
VALID_EVENTS = {"start", "end", "note"}
VALID_CLASSIFICATIONS = {
    "required_acceptance",
    "supporting",
    "redundant",
    "stale_rejected",
    "failed_tooling",
    "not_applicable",
}
VERIFICATION_PHASES = {
    "build_test",
    "ostm_ui",
    "ostm_profile",
    "viewport_session",
    "profile",
    "review",
    "validation",
}


@dataclass
class MarkerEvent:
    line: int
    event: str
    phase: str
    ts: datetime | None
    fields: dict[str, str]


@dataclass
class PhaseSpan:
    phase: str
    start: datetime | None
    end: datetime | None
    start_line: int | None = None
    end_line: int | None = None
    fields: dict[str, str] = field(default_factory=dict)
    notes: list[str] = field(default_factory=list)

    @property
    def seconds(self) -> float | None:
        if self.start is None or self.end is None:
            return None
        return max(0.0, (self.end - self.start).total_seconds())


def parse_timestamp(value: str) -> datetime:
    text = value.strip()
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    parsed = datetime.fromisoformat(text)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def marker_payload(line: str) -> str | None:
    index = line.find(MARKER)
    if index < 0:
        return None
    payload = line[index + len(MARKER) :].strip()
    if payload.startswith(":"):
        payload = payload[1:].strip()
    if payload.startswith("[") and payload.endswith("]"):
        payload = payload[1:-1].strip()
    return payload


def parse_marker(line_text: str, line_number: int) -> MarkerEvent | None:
    payload = marker_payload(line_text)
    if payload is None:
        return None
    try:
        parts = shlex.split(payload)
    except ValueError as exc:
        raise ValueError(f"line {line_number}: invalid marker quoting: {exc}") from exc
    fields: dict[str, str] = {}
    for part in parts:
        if "=" not in part:
            raise ValueError(f"line {line_number}: marker token lacks '=': {part!r}")
        key, value = part.split("=", 1)
        key = key.strip().lower()
        if not key:
            raise ValueError(f"line {line_number}: empty marker key")
        fields[key] = value
    event = fields.get("event")
    phase = fields.get("phase")
    if event not in VALID_EVENTS:
        raise ValueError(f"line {line_number}: event must be one of {sorted(VALID_EVENTS)}")
    if not phase:
        raise ValueError(f"line {line_number}: missing phase")
    classification = fields.get("classification")
    if classification and classification not in VALID_CLASSIFICATIONS:
        raise ValueError(
            f"line {line_number}: classification must be one of {sorted(VALID_CLASSIFICATIONS)}"
        )
    timestamp = parse_timestamp(fields["ts"]) if "ts" in fields else None
    return MarkerEvent(line=line_number, event=event, phase=phase, ts=timestamp, fields=fields)


def parse_events(lines: Iterable[str]) -> list[MarkerEvent]:
    events: list[MarkerEvent] = []
    for line_number, line in enumerate(lines, start=1):
        marker = parse_marker(line, line_number)
        if marker is not None:
            events.append(marker)
    return events


def build_spans(events: list[MarkerEvent]) -> tuple[list[PhaseSpan], list[str]]:
    active: dict[str, PhaseSpan] = {}
    spans: list[PhaseSpan] = []
    warnings: list[str] = []
    for event in events:
        if event.event == "start":
            if event.phase in active:
                warnings.append(
                    f"line {event.line}: phase {event.phase!r} started before prior span ended"
                )
                spans.append(active.pop(event.phase))
            active[event.phase] = PhaseSpan(
                phase=event.phase,
                start=event.ts,
                end=None,
                start_line=event.line,
                fields=dict(event.fields),
            )
            continue
        if event.event == "note":
            note = event.fields.get("note", "")
            if event.phase in active:
                active[event.phase].notes.append(note)
            else:
                spans.append(
                    PhaseSpan(
                        phase=event.phase,
                        start=event.ts,
                        end=event.ts,
                        start_line=event.line,
                        end_line=event.line,
                        fields=dict(event.fields),
                        notes=[note] if note else [],
                    )
                )
            continue
        span = active.pop(event.phase, None)
        if span is None:
            warnings.append(f"line {event.line}: end without matching start for {event.phase!r}")
            span = PhaseSpan(
                phase=event.phase,
                start=event.ts,
                end=event.ts,
                start_line=event.line,
            )
        span.end = event.ts
        span.end_line = event.line
        span.fields.update(event.fields)
        note = event.fields.get("note")
        if note:
            span.notes.append(note)
        spans.append(span)
    for phase, span in sorted(active.items()):
        warnings.append(f"phase {phase!r} has a start marker but no end marker")
        spans.append(span)
    spans.sort(key=lambda item: (item.start or datetime.min.replace(tzinfo=timezone.utc), item.start_line or 0))
    return spans, warnings


def summarize(spans: list[PhaseSpan], warnings: list[str]) -> dict[str, object]:
    by_phase: dict[str, float] = {}
    verification: dict[str, dict[str, float | int]] = {}
    missing_classification: list[str] = []
    total_seconds = 0.0
    measured = 0
    for span in spans:
        seconds = span.seconds
        if seconds is None:
            continue
        measured += 1
        total_seconds += seconds
        by_phase[span.phase] = by_phase.get(span.phase, 0.0) + seconds
        classification = span.fields.get("classification")
        if span.phase in VERIFICATION_PHASES:
            if not classification:
                missing_classification.append(span.phase)
            else:
                bucket = verification.setdefault(classification, {"seconds": 0.0, "count": 0})
                bucket["seconds"] = float(bucket["seconds"]) + seconds
                bucket["count"] = int(bucket["count"]) + 1
    return {
        "schema": "cppstudio.slice_phase_report.v1",
        "total_seconds": round(total_seconds, 3),
        "measured_spans": measured,
        "phase_seconds": {key: round(value, 3) for key, value in sorted(by_phase.items())},
        "verification_seconds": {
            key: {"seconds": round(float(value["seconds"]), 3), "count": int(value["count"])}
            for key, value in sorted(verification.items())
        },
        "missing_verification_classification": sorted(set(missing_classification)),
        "warnings": warnings,
    }


def span_to_json(span: PhaseSpan) -> dict[str, object]:
    return {
        "phase": span.phase,
        "start": span.start.isoformat() if span.start else None,
        "end": span.end.isoformat() if span.end else None,
        "seconds": round(span.seconds, 3) if span.seconds is not None else None,
        "classification": span.fields.get("classification"),
        "status": span.fields.get("status"),
        "ostm_job": span.fields.get("ostm_job"),
        "artifact": span.fields.get("artifact"),
        "note": "; ".join(note for note in span.notes if note),
        "start_line": span.start_line,
        "end_line": span.end_line,
    }


def render_markdown(spans: list[PhaseSpan], report: dict[str, object]) -> str:
    lines = [
        "# CppStudio Slice Phase Report",
        "",
        f"- Total measured time: `{report['total_seconds']}s`",
        f"- Measured spans: `{report['measured_spans']}`",
    ]
    warnings = report["warnings"]
    if isinstance(warnings, list) and warnings:
        lines.append(f"- Warnings: `{len(warnings)}`")
    missing = report["missing_verification_classification"]
    if isinstance(missing, list) and missing:
        lines.append("- Missing verification classification: " + ", ".join(f"`{item}`" for item in missing))
    lines.extend(
        [
            "",
            "| Phase | Seconds | Classification | Status | OSTM | Artifact | Note |",
            "|---|---:|---|---|---|---|---|",
        ]
    )
    for span in spans:
        row = span_to_json(span)
        lines.append(
            "| {phase} | {seconds} | {classification} | {status} | {ostm_job} | {artifact} | {note} |".format(
                phase=row["phase"],
                seconds="" if row["seconds"] is None else row["seconds"],
                classification=row["classification"] or "",
                status=row["status"] or "",
                ostm_job=row["ostm_job"] or "",
                artifact=row["artifact"] or "",
                note=str(row["note"]).replace("|", "\\|"),
            )
        )
    if isinstance(warnings, list) and warnings:
        lines.extend(["", "## Warnings"])
        lines.extend(f"- {warning}" for warning in warnings)
    return "\n".join(lines) + "\n"


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, default=None, help="Log/transcript file. Defaults to stdin.")
    parser.add_argument("--output", type=Path, default=None, help="Write report to this path.")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    parser.add_argument(
        "--require-markers",
        action="store_true",
        help="Fail when no CPPSTUDIO_PHASE markers are present.",
    )
    args = parser.parse_args(argv)

    try:
        if args.input:
            lines = args.input.read_text(encoding="utf-8").splitlines()
        else:
            lines = sys.stdin.read().splitlines()
        events = parse_events(lines)
        if args.require_markers and not events:
            raise ValueError("no CPPSTUDIO_PHASE markers found")
        spans, warnings = build_spans(events)
        report = summarize(spans, warnings)
        if args.format == "json":
            payload = {
                **report,
                "spans": [span_to_json(span) for span in spans],
            }
            rendered = json.dumps(payload, indent=2, sort_keys=False) + "\n"
        else:
            rendered = render_markdown(spans, report)
        if args.output:
            args.output.parent.mkdir(parents=True, exist_ok=True)
            args.output.write_text(rendered, encoding="utf-8")
        else:
            sys.stdout.write(rendered)
    except (OSError, ValueError) as exc:
        print(f"slice_phase_report: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
