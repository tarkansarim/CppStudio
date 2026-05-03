#!/usr/bin/env python3
"""Run evidence-gated GPU optimization loops for CppStudio projects."""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


STATE_VERSION = 1
DEFAULT_MIN_IMPROVEMENT_PCT = 1.0
DEFAULT_CONSECUTIVE_REVERTS = 5
DEFAULT_PCT_PEAK_THRESHOLD = 90.0
DEFAULT_MAX_MINUTES_PER_TARGET = 120.0
DEFAULT_SPEEDUP_THRESHOLD = 2.0
METRIC_RE = re.compile(
    r"(?P<name>elapsed_us|latency_us|duration_us|frame_us|time_us|elapsed_ms|latency_ms|"
    r"duration_ms|frame_ms|time_ms|fps|throughput_tflops|throughput|items_per_s|"
    r"samples_per_s|gbps|gib_per_s)\s*[:=]\s*"
    r"(?P<value>[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)(?:x|%)?",
    re.IGNORECASE,
)
CORRECTNESS_RE = re.compile(r"\bcorrectness\s*[:=]\s*(?P<value>PASS|FAIL|OK|ERROR|CRASH|TRUE|FALSE)\b", re.IGNORECASE)
FLOAT_FIELD_RE = re.compile(
    r"\b(?P<name>pct_peak_compute|pct_peak_bandwidth|peak_vram_mb)\s*[:=]\s*"
    r"(?P<value>[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)(?:%)?",
    re.IGNORECASE,
)
BOTTLENECK_RE = re.compile(r"\bbottleneck\s*[:=]\s*(?P<value>[A-Za-z0-9_.-]+)", re.IGNORECASE)
RESULT_FIELDS = [
    "timestamp",
    "session",
    "target_id",
    "kind",
    "attempt_id",
    "tag",
    "decision",
    "correctness",
    "metric_name",
    "metric_value",
    "direction",
    "baseline_value",
    "reference_value",
    "improvement_pct",
    "local_speedup",
    "share_pct",
    "estimated_end_to_end_speedup",
    "pct_peak_compute",
    "pct_peak_bandwidth",
    "bottleneck",
    "peak_vram_mb",
    "verify_status",
    "benchmark_status",
    "changed_paths",
    "patch_path",
    "commit",
    "log_dir",
    "notes",
]


class ToolError(RuntimeError):
    """Raised for command failures that should be printed without a traceback."""


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def default_session() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")


def sanitize_id(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_.-]+", "-", value.strip()).strip("-._")
    if not cleaned:
        raise ToolError("identifier must contain at least one alphanumeric character")
    return cleaned


def artifact_root(repo: Path, session: str) -> Path:
    return repo / "artifacts" / "optimization" / sanitize_id(session)


def state_path(root: Path) -> Path:
    return root / "state.json"


def results_path(root: Path) -> Path:
    return root / "results.tsv"


def run_git(repo: Path, args: list[str], *, check: bool = False) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(["git", *args], cwd=repo, text=True, capture_output=True, check=False)
    if check and result.returncode != 0:
        raise ToolError(f"git {' '.join(args)} failed:\n{result.stdout}{result.stderr}")
    return result


def require_git_repo(repo: Path) -> None:
    result = run_git(repo, ["rev-parse", "--is-inside-work-tree"])
    if result.returncode != 0 or result.stdout.strip() != "true":
        raise ToolError("optimization attempts require a git repository so patches can be captured safely")


def append_event(root: Path, event: str, **fields: object) -> None:
    root.mkdir(parents=True, exist_ok=True)
    record = {"timestamp": utc_now(), "event": event, **fields}
    with (root / "run.log").open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(record, sort_keys=True) + "\n")


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def load_state(root: Path) -> dict[str, Any]:
    path = state_path(root)
    if not path.exists():
        raise ToolError("no optimization state found; run init first")
    try:
        state = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise ToolError(f"state.json is invalid JSON: {error}") from error
    if state.get("version") != STATE_VERSION or not isinstance(state.get("targets"), dict):
        raise ToolError("state.json has an unsupported format")
    return state


def save_state(root: Path, state: dict[str, Any]) -> None:
    write_json(state_path(root), state)


def sanitize_cell(value: object) -> str:
    return str(value).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def append_result(root: Path, row: dict[str, object]) -> None:
    path = results_path(root)
    exists = path.exists()
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=RESULT_FIELDS, delimiter="\t", extrasaction="ignore")
        if not exists:
            writer.writeheader()
        writer.writerow({field: sanitize_cell(row.get(field, "")) for field in RESULT_FIELDS})


def read_results(root: Path) -> list[dict[str, str]]:
    path = results_path(root)
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def command_log(repo: Path, log_path: Path, command: str) -> dict[str, object]:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    result = subprocess.run(command, cwd=repo, shell=True, text=True, capture_output=True, check=False)
    elapsed_ms = int((time.monotonic() - started) * 1000)
    log_path.write_text(
        "\n".join(
            [
                f"$ {command}",
                f"returncode={result.returncode}",
                f"duration_ms={elapsed_ms}",
                "",
                "== stdout ==",
                result.stdout,
                "== stderr ==",
                result.stderr,
            ]
        ),
        encoding="utf-8",
    )
    return {
        "command": command,
        "returncode": result.returncode,
        "duration_ms": elapsed_ms,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "log_path": str(log_path.relative_to(repo)),
    }


def parse_targets(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        raise ToolError(f"target table does not exist: {path}")
    with path.open("r", encoding="utf-8", newline="") as handle:
        sample = handle.read(4096)
        handle.seek(0)
        dialect = csv.excel_tab if "\t" in sample else csv.excel
        rows = list(csv.DictReader(handle, dialect=dialect))
    if not rows:
        raise ToolError("target table is empty")

    required = {"target_id", "lane", "workload", "share_pct", "benchmark_cmd", "verify_cmd", "scope_paths"}
    missing = required - set(rows[0].keys())
    if missing:
        raise ToolError("target table is missing columns: " + ", ".join(sorted(missing)))

    targets: list[dict[str, Any]] = []
    seen: set[str] = set()
    has_explicit_rank = False
    for index, row in enumerate(rows, 1):
        target_id = sanitize_id(row["target_id"])
        if target_id in seen:
            raise ToolError(f"duplicate target_id in target table: {target_id}")
        seen.add(target_id)
        try:
            share_pct = float(row["share_pct"])
        except ValueError as error:
            raise ToolError(f"target {target_id} has non-numeric share_pct") from error
        if share_pct < 0 or share_pct > 100 or not math.isfinite(share_pct):
            raise ToolError(f"target {target_id} share_pct must be between 0 and 100")
        rank_text = (row.get("rank") or "").strip()
        has_explicit_rank = has_explicit_rank or bool(rank_text)
        rank = int(rank_text) if rank_text else None
        scope_paths = [part.strip() for part in re.split(r"[;,]", row["scope_paths"]) if part.strip()]
        if not scope_paths:
            raise ToolError(f"target {target_id} must declare at least one scope path")
        direction = (row.get("direction") or "").strip().lower()
        if direction and direction not in {"lower", "higher"}:
            raise ToolError(f"target {target_id} direction must be 'lower' or 'higher'")
        min_improvement = (row.get("min_improvement_pct") or "").strip()
        targets.append(
            {
                "target_id": target_id,
                "rank": rank if rank is not None else index,
                "lane": row["lane"].strip(),
                "workload": row["workload"].strip(),
                "share_pct": share_pct,
                "benchmark_cmd": row["benchmark_cmd"].strip(),
                "verify_cmd": row["verify_cmd"].strip(),
                "scope_paths": scope_paths,
                "metric_name": (row.get("metric_name") or "").strip(),
                "direction": direction,
                "min_improvement_pct": float(min_improvement) if min_improvement else None,
                "notes": (row.get("notes") or "").strip(),
                "status": "pending",
                "started_at": "",
                "baseline_value": None,
                "baseline_attempt_id": "",
                "best_value": None,
                "best_attempt_id": "",
                "best_commit": "",
                "attempts_run": 0,
                "attempts_kept": 0,
                "consecutive_reverts": 0,
                "time_spent_minutes": 0.0,
                "pct_peak": None,
                "speedup": None,
                "move_on_reason": "",
            }
        )
    if not has_explicit_rank:
        targets.sort(key=lambda item: float(item["share_pct"]), reverse=True)
        for index, target in enumerate(targets, 1):
            target["rank"] = index
    else:
        targets.sort(key=lambda item: (int(item["rank"]), -float(item["share_pct"])))
    return targets


def target_lookup(state: dict[str, Any], target_id: str) -> dict[str, Any]:
    targets = state["targets"]
    clean = sanitize_id(target_id)
    if clean not in targets:
        raise ToolError(f"unknown target_id: {target_id}")
    target = targets[clean]
    if not isinstance(target, dict):
        raise ToolError(f"target state is invalid for {target_id}")
    return target


def infer_direction(metric_name: str, explicit: str | None) -> str:
    if explicit:
        return explicit
    lowered = metric_name.lower()
    if any(token in lowered for token in ("fps", "throughput", "items_per_s", "samples_per_s", "gbps", "gib_per_s")):
        return "higher"
    if any(token in lowered for token in ("elapsed", "latency", "duration", "frame", "time", "_ms", "_us")):
        return "lower"
    raise ToolError(f"cannot infer direction for metric {metric_name!r}; set direction in the target table")


def parse_metric(output: str, metric_name: str | None) -> tuple[str, float]:
    matches = list(METRIC_RE.finditer(output))
    if not matches:
        raise ToolError("benchmark output did not contain a supported primary metric")
    selected = None
    requested = metric_name.lower() if metric_name else ""
    if requested:
        for match in matches:
            if match.group("name").lower() == requested:
                selected = match
        if selected is None:
            raise ToolError(f"benchmark output did not contain requested metric {metric_name!r}")
    else:
        selected = matches[-1]
    name = selected.group("name").lower()
    value = float(selected.group("value"))
    if not math.isfinite(value):
        raise ToolError("metric value must be finite")
    return name, value


def parse_correctness(output: str) -> str | None:
    matches = list(CORRECTNESS_RE.finditer(output))
    if not matches:
        return None
    raw = matches[-1].group("value").upper()
    if raw in {"PASS", "OK", "TRUE"}:
        return "PASS"
    return "FAIL"


def parse_float_fields(output: str) -> dict[str, float]:
    parsed: dict[str, float] = {}
    for match in FLOAT_FIELD_RE.finditer(output):
        value = float(match.group("value"))
        if math.isfinite(value):
            parsed[match.group("name").lower()] = value
    return parsed


def parse_bottleneck(output: str) -> str:
    matches = list(BOTTLENECK_RE.finditer(output))
    return matches[-1].group("value").lower() if matches else ""


def improvement(reference: float, current: float, direction: str) -> tuple[float, float]:
    if reference <= 0 or current <= 0:
        raise ToolError("reference and current metrics must be positive")
    if direction == "lower":
        local_speedup = reference / current
        pct = ((reference - current) / reference) * 100.0
    elif direction == "higher":
        local_speedup = current / reference
        pct = ((current - reference) / reference) * 100.0
    else:
        raise ToolError(f"unknown direction: {direction}")
    return local_speedup, pct


def amdahl_speedup(local_speedup: float, share_pct: float) -> float:
    share = share_pct / 100.0
    return 1.0 / ((1.0 - share) + (share / local_speedup))


def update_elapsed_minutes(target: dict[str, Any]) -> None:
    started = target.get("started_at")
    if not started:
        return
    try:
        start_dt = datetime.fromisoformat(str(started))
        if start_dt.tzinfo is None:
            start_dt = start_dt.replace(tzinfo=timezone.utc)
    except ValueError:
        return
    delta = datetime.now(timezone.utc) - start_dt
    target["time_spent_minutes"] = round(delta.total_seconds() / 60.0, 3)


def select_pct_peak(fields: dict[str, float], bottleneck: str) -> float | None:
    compute = fields.get("pct_peak_compute")
    bandwidth = fields.get("pct_peak_bandwidth")
    if bottleneck == "memory" and bandwidth is not None:
        return bandwidth
    if bottleneck == "compute" and compute is not None:
        return compute
    values = [value for value in (compute, bandwidth) if value is not None]
    return max(values) if values else None


def path_allowed(path: str, scopes: Iterable[str]) -> bool:
    normalized = path.strip("/")
    for scope in scopes:
        prefix = scope.strip("/")
        if normalized == prefix or normalized.startswith(prefix + "/"):
            return True
    return False


def changed_files_for_attempt(repo: Path, scopes: list[str]) -> list[str]:
    staged = [line.strip() for line in run_git(repo, ["diff", "--cached", "--name-only"], check=True).stdout.splitlines() if line.strip()]
    if staged:
        raise ToolError("staged changes are not supported for optimization attempts; commit or unstage them first")
    changed = [line.strip() for line in run_git(repo, ["diff", "--name-only"], check=True).stdout.splitlines() if line.strip()]
    if not changed:
        raise ToolError("attempt requires a tracked file diff before it can be measured")
    outside = [path for path in changed if not path_allowed(path, scopes)]
    if outside:
        raise ToolError("attempt changed files outside the target scope: " + ", ".join(outside))
    untracked = [
        line[3:].strip()
        for line in run_git(repo, ["status", "--porcelain", "--untracked-files=all"], check=True).stdout.splitlines()
        if line.startswith("?? ")
    ]
    untracked_inside = [path for path in untracked if path_allowed(path, scopes)]
    if untracked_inside:
        raise ToolError("attempt has untracked files under target scope; add them intentionally or remove them first: " + ", ".join(untracked_inside))
    return sorted(set(changed))


def capture_patch(repo: Path, root: Path, attempt_id: str, changed: list[str]) -> Path:
    patch_dir = root / "patches"
    patch_dir.mkdir(parents=True, exist_ok=True)
    patch_path = patch_dir / f"{sanitize_id(attempt_id)}.patch"
    result = run_git(repo, ["diff", "--binary", "--", *changed], check=True)
    if not result.stdout.strip():
        raise ToolError("attempt patch is empty")
    patch_path.write_text(result.stdout, encoding="utf-8")
    return patch_path


def reverse_patch(repo: Path, patch_path: Path) -> None:
    result = subprocess.run(["git", "apply", "-R", str(patch_path)], cwd=repo, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise ToolError(f"auto-revert failed:\n{result.stdout}{result.stderr}")


def commit_keep(repo: Path, target: dict[str, Any], attempt_id: str, changed: list[str], message: str) -> str:
    run_git(repo, ["add", "--", *changed], check=True)
    result = run_git(repo, ["commit", "-m", f"opt({target['target_id']}): {message}"], check=False)
    if result.returncode != 0:
        raise ToolError(f"git commit for kept attempt failed:\n{result.stdout}{result.stderr}")
    sha = run_git(repo, ["rev-parse", "--short", "HEAD"], check=True).stdout.strip()
    return sha or attempt_id


def init_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    if state_path(root).exists() and not args.force:
        raise ToolError("optimization state already exists for this session; pass --force to replace it")
    targets_path = Path(args.targets)
    if not targets_path.is_absolute():
        targets_path = repo / targets_path
    targets = parse_targets(targets_path)
    state = {
        "version": STATE_VERSION,
        "session": args.session,
        "created_at": utc_now(),
        "target_order": [target["target_id"] for target in targets],
        "current_target_id": targets[0]["target_id"] if targets else "",
        "settings": {
            "consecutive_reverts": args.consecutive_reverts,
            "pct_peak_threshold": args.pct_peak_threshold,
            "max_minutes_per_target": args.max_minutes_per_target,
            "speedup_threshold": args.speedup_threshold,
            "default_min_improvement_pct": args.default_min_improvement_pct,
        },
        "targets": {target["target_id"]: target for target in targets},
    }
    root.mkdir(parents=True, exist_ok=True)
    save_state(root, state)
    append_event(root, "init", targets=str(targets_path), target_count=len(targets))
    print(f"cppstudio_opt_init session={args.session} targets={len(targets)} current_target_id={state['current_target_id']}")
    return 0


def baseline_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    state = load_state(root)
    target = target_lookup(state, args.target_id or state.get("current_target_id", ""))
    target["status"] = "optimizing"
    if not target.get("started_at"):
        target["started_at"] = utc_now()
    baseline_dir = root / "targets" / target["target_id"] / "baseline"
    append_event(root, "baseline_start", target_id=target["target_id"])
    verify = command_log(repo, baseline_dir / "verify.log", target["verify_cmd"])
    if int(verify["returncode"]) != 0:
        append_event(root, "baseline_failed", target_id=target["target_id"], phase="verify")
        raise ToolError("baseline verification failed")
    benchmark = command_log(repo, baseline_dir / "run.log", target["benchmark_cmd"])
    if int(benchmark["returncode"]) != 0:
        append_event(root, "baseline_failed", target_id=target["target_id"], phase="benchmark")
        raise ToolError("baseline benchmark failed")

    output = str(benchmark["stdout"]) + "\n" + str(benchmark["stderr"])
    correctness = parse_correctness(output) or "PASS"
    if correctness != "PASS":
        raise ToolError("baseline benchmark reported correctness failure")
    metric_name, metric_value = parse_metric(output, target.get("metric_name") or None)
    direction = infer_direction(metric_name, target.get("direction") or None)
    target["metric_name"] = metric_name
    target["direction"] = direction
    target["baseline_value"] = metric_value
    target["best_value"] = metric_value
    target["baseline_attempt_id"] = "baseline"
    target["best_attempt_id"] = "baseline"
    target["speedup"] = 1.0
    fields = parse_float_fields(output)
    bottleneck = parse_bottleneck(output)
    pct_peak = select_pct_peak(fields, bottleneck)
    target["pct_peak"] = pct_peak
    update_elapsed_minutes(target)
    save_state(root, state)
    row = {
        "timestamp": utc_now(),
        "session": args.session,
        "target_id": target["target_id"],
        "kind": "baseline",
        "attempt_id": "baseline",
        "tag": "baseline",
        "decision": "BASELINE",
        "correctness": correctness,
        "metric_name": metric_name,
        "metric_value": f"{metric_value:.12g}",
        "direction": direction,
        "baseline_value": f"{metric_value:.12g}",
        "reference_value": f"{metric_value:.12g}",
        "local_speedup": "1",
        "share_pct": f"{float(target['share_pct']):.12g}",
        "estimated_end_to_end_speedup": "1",
        "pct_peak_compute": fields.get("pct_peak_compute", ""),
        "pct_peak_bandwidth": fields.get("pct_peak_bandwidth", ""),
        "bottleneck": bottleneck,
        "peak_vram_mb": fields.get("peak_vram_mb", ""),
        "verify_status": verify["returncode"],
        "benchmark_status": benchmark["returncode"],
        "log_dir": str(baseline_dir.relative_to(repo)),
        "notes": "baseline recorded",
    }
    append_result(root, row)
    append_event(root, "baseline_complete", **row)
    print(
        f"cppstudio_opt_baseline session={args.session} target_id={target['target_id']} "
        f"metric_name={metric_name} metric_value={metric_value:g} direction={direction}"
    )
    return 0


def attempt_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    require_git_repo(repo)
    root = artifact_root(repo, args.session)
    state = load_state(root)
    target = target_lookup(state, args.target_id or state.get("current_target_id", ""))
    if target.get("baseline_value") is None:
        raise ToolError("target has no baseline; run baseline first")
    if target.get("status") == "done":
        raise ToolError("target is already marked done; run next or start a new session")
    reference_value = float(target["best_value"])
    target["status"] = "optimizing"
    if not target.get("started_at"):
        target["started_at"] = utc_now()

    attempt_id = sanitize_id(args.attempt_id or f"{int(time.time())}-{args.tag}")
    changed = changed_files_for_attempt(repo, list(target["scope_paths"]))
    patch_path = capture_patch(repo, root, attempt_id, changed)
    attempt_dir = root / "targets" / target["target_id"] / "attempts" / attempt_id
    append_event(root, "attempt_start", target_id=target["target_id"], attempt_id=attempt_id, changed_paths=changed)

    verify = command_log(repo, attempt_dir / "verify.log", args.verify_cmd or target["verify_cmd"])
    benchmark_status: int | str = ""
    metric_name = str(target["metric_name"])
    direction = str(target["direction"])
    metric_value: float | None = None
    local_speedup: float | None = None
    improvement_pct: float | None = None
    end_to_end: float | None = None
    fields: dict[str, float] = {}
    bottleneck = ""
    correctness = "PASS" if int(verify["returncode"]) == 0 else "FAIL"
    decision = "KEEP"
    notes = args.description

    if correctness != "PASS":
        decision = "REVERT" if args.auto_revert else "FAIL"
        notes = "verification failed"
    else:
        benchmark = command_log(repo, attempt_dir / "run.log", args.benchmark_cmd or target["benchmark_cmd"])
        benchmark_status = int(benchmark["returncode"])
        output = str(benchmark["stdout"]) + "\n" + str(benchmark["stderr"])
        if int(benchmark["returncode"]) != 0:
            decision = "REVERT" if args.auto_revert else "FAIL"
            notes = "benchmark failed"
        else:
            correctness = parse_correctness(output) or "PASS"
            if correctness != "PASS":
                decision = "REVERT" if args.auto_revert else "FAIL"
                notes = "benchmark reported correctness failure"
            else:
                metric_name, metric_value = parse_metric(output, args.metric_name or target.get("metric_name") or None)
                direction = infer_direction(metric_name, args.direction or target.get("direction") or None)
                local_speedup, improvement_pct = improvement(reference_value, metric_value, direction)
                end_to_end = amdahl_speedup(local_speedup, float(target["share_pct"]))
                fields = parse_float_fields(output)
                bottleneck = parse_bottleneck(output)
                pct_peak = select_pct_peak(fields, bottleneck)
                if pct_peak is not None:
                    target["pct_peak"] = pct_peak
                required = (
                    args.min_improvement_pct
                    if args.min_improvement_pct is not None
                    else target.get("min_improvement_pct")
                    if target.get("min_improvement_pct") is not None
                    else state["settings"]["default_min_improvement_pct"]
                )
                if improvement_pct >= float(required):
                    decision = "KEEP"
                elif args.allow_simpler_equivalent and improvement_pct >= -float(args.equivalent_tolerance_pct):
                    decision = "KEEP"
                    notes = args.description + " (kept as simpler equivalent)"
                else:
                    decision = "REVERT" if args.auto_revert else "REJECT"
                    notes = f"improvement {improvement_pct:.6g}% below required {float(required):.6g}%"

    commit_sha = ""
    if decision == "REVERT":
        reverse_patch(repo, patch_path)
        append_event(root, "attempt_reverted", target_id=target["target_id"], attempt_id=attempt_id)
    elif decision == "KEEP":
        target["best_value"] = metric_value
        target["best_attempt_id"] = attempt_id
        target["attempts_kept"] = int(target.get("attempts_kept", 0)) + 1
        target["consecutive_reverts"] = 0
        baseline_speedup, _ = improvement(float(target["baseline_value"]), float(metric_value), direction)
        target["speedup"] = round(baseline_speedup, 6)
        if args.commit_keep:
            commit_sha = commit_keep(repo, target, attempt_id, changed, args.tag)
            target["best_commit"] = commit_sha
    else:
        target["consecutive_reverts"] = int(target.get("consecutive_reverts", 0)) + 1
    if decision == "REVERT":
        target["consecutive_reverts"] = int(target.get("consecutive_reverts", 0)) + 1

    target["attempts_run"] = int(target.get("attempts_run", 0)) + 1
    update_elapsed_minutes(target)
    save_state(root, state)
    row = {
        "timestamp": utc_now(),
        "session": args.session,
        "target_id": target["target_id"],
        "kind": "attempt",
        "attempt_id": attempt_id,
        "tag": args.tag,
        "decision": decision,
        "correctness": correctness,
        "metric_name": metric_name,
        "metric_value": "" if metric_value is None else f"{metric_value:.12g}",
        "direction": direction,
        "baseline_value": f"{float(target['baseline_value']):.12g}",
        "reference_value": f"{reference_value:.12g}",
        "improvement_pct": "" if improvement_pct is None else f"{improvement_pct:.12g}",
        "local_speedup": "" if local_speedup is None else f"{local_speedup:.12g}",
        "share_pct": f"{float(target['share_pct']):.12g}",
        "estimated_end_to_end_speedup": "" if end_to_end is None else f"{end_to_end:.12g}",
        "pct_peak_compute": fields.get("pct_peak_compute", ""),
        "pct_peak_bandwidth": fields.get("pct_peak_bandwidth", ""),
        "bottleneck": bottleneck,
        "peak_vram_mb": fields.get("peak_vram_mb", ""),
        "verify_status": verify["returncode"],
        "benchmark_status": benchmark_status,
        "changed_paths": ",".join(changed),
        "patch_path": str(patch_path.relative_to(repo)),
        "commit": commit_sha,
        "log_dir": str(attempt_dir.relative_to(repo)),
        "notes": notes,
    }
    append_result(root, row)
    append_event(root, "attempt_complete", **row)
    print(
        f"cppstudio_opt_attempt session={args.session} target_id={target['target_id']} "
        f"attempt_id={attempt_id} decision={decision} correctness={correctness} "
        f"metric_name={metric_name} metric_value={'' if metric_value is None else f'{metric_value:g}'}"
    )
    return 0 if decision == "KEEP" else 1


def target_move_reason(target: dict[str, Any], settings: dict[str, Any]) -> str:
    if int(target.get("consecutive_reverts", 0)) >= int(settings["consecutive_reverts"]):
        return f"consecutive reverts reached {target.get('consecutive_reverts')}"
    pct_peak = target.get("pct_peak")
    if pct_peak is not None and float(pct_peak) >= float(settings["pct_peak_threshold"]):
        return f"near peak utilization {float(pct_peak):.1f}%"
    if float(target.get("time_spent_minutes", 0.0)) >= float(settings["max_minutes_per_target"]):
        return f"time budget reached {target.get('time_spent_minutes')} minutes"
    speedup = target.get("speedup")
    if speedup is not None and float(speedup) >= float(settings["speedup_threshold"]):
        return f"speedup threshold reached {float(speedup):.3g}x"
    return ""


def next_pending_target(state: dict[str, Any]) -> str:
    for target_id in state["target_order"]:
        target = target_lookup(state, target_id)
        if target.get("status") == "pending":
            return target_id
    return ""


def next_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    state = load_state(root)
    settings = state["settings"]
    current_id = state.get("current_target_id") or next_pending_target(state)
    if not current_id:
        print(f"cppstudio_opt_next session={args.session} decision=DONE reason=no_targets")
        return 0
    current = target_lookup(state, current_id)
    update_elapsed_minutes(current)
    reason = target_move_reason(current, settings)
    if reason:
        current["status"] = "done"
        current["move_on_reason"] = reason
        next_id = next_pending_target(state)
        state["current_target_id"] = next_id
        save_state(root, state)
        if next_id:
            print(f"cppstudio_opt_next session={args.session} decision=NEXT target_id={next_id} reason={reason}")
        else:
            print(f"cppstudio_opt_next session={args.session} decision=DONE reason={reason}")
        return 0
    if current.get("status") == "pending":
        current["status"] = "optimizing"
        if not current.get("started_at"):
            current["started_at"] = utc_now()
        save_state(root, state)
    need = "baseline" if current.get("baseline_value") is None else "attempt"
    print(f"cppstudio_opt_next session={args.session} decision=CONTINUE target_id={current_id} next_step={need}")
    return 0


def aggregate_speedup(state: dict[str, Any]) -> float:
    remaining = 1.0
    for target in state["targets"].values():
        speedup = target.get("speedup")
        share_pct = target.get("share_pct", 0.0)
        if speedup is None or float(speedup) <= 1.0 or float(share_pct) <= 0:
            continue
        share = float(share_pct) / 100.0
        remaining -= share * (1.0 - 1.0 / float(speedup))
    if remaining <= 0:
        return float("inf")
    return 1.0 / remaining


def report_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    state = load_state(root)
    rows = read_results(root)
    final_status: int | str = ""
    final_log = ""
    if args.final_cmd:
        final = command_log(repo, root / "final_validation.log", args.final_cmd)
        final_status = int(final["returncode"])
        final_log = str(final["log_path"])
        append_event(root, "final_validation", command=args.final_cmd, returncode=final_status)

    lines = [
        "# GPU Optimization Report",
        "",
        f"- Session: `{args.session}`",
        f"- Generated: `{utc_now()}`",
        f"- Results rows: `{len(rows)}`",
        f"- Estimated end-to-end speedup: `{aggregate_speedup(state):.6g}x`",
    ]
    if args.final_cmd:
        lines.append(f"- Final validation: `{final_status}` (`{final_log}`)")
    lines.extend(["", "## Targets", ""])
    lines.append("| Target | Status | Share | Baseline | Best | Speedup | Attempts | Kept | Move-On Reason |")
    lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |")
    for target_id in state["target_order"]:
        target = target_lookup(state, target_id)
        lines.append(
            "| "
            + " | ".join(
                [
                    target_id,
                    str(target.get("status", "")),
                    f"{float(target.get('share_pct', 0.0)):.3g}%",
                    "" if target.get("baseline_value") is None else f"{float(target['baseline_value']):.6g}",
                    "" if target.get("best_value") is None else f"{float(target['best_value']):.6g}",
                    "" if target.get("speedup") is None else f"{float(target['speedup']):.6g}x",
                    str(target.get("attempts_run", 0)),
                    str(target.get("attempts_kept", 0)),
                    str(target.get("move_on_reason", "")),
                ]
            )
            + " |"
        )
    lines.extend(["", "## Attempt Log", ""])
    lines.append("| Attempt | Target | Decision | Correctness | Metric | Improvement | Notes |")
    lines.append("| --- | --- | --- | --- | --- | ---: | --- |")
    for row in rows:
        metric = f"{row.get('metric_name', '')}={row.get('metric_value', '')}".strip("=")
        lines.append(
            "| "
            + " | ".join(
                [
                    row.get("attempt_id", ""),
                    row.get("target_id", ""),
                    row.get("decision", ""),
                    row.get("correctness", ""),
                    metric,
                    row.get("improvement_pct", ""),
                    row.get("notes", ""),
                ]
            )
            + " |"
        )
    report = root / "final_report.md"
    report.write_text("\n".join(lines) + "\n", encoding="utf-8")
    append_event(root, "report_complete", report=str(report.relative_to(repo)), final_status=final_status)
    print(f"cppstudio_opt_report session={args.session} report={report.relative_to(repo)} final_status={final_status}")
    return 0 if final_status in {"", 0} else 1


def add_common(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--repo", default=".", help="Project repository root")
    parser.add_argument("--session", default=default_session(), help="Optimization session id")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)

    init = subcommands.add_parser("init", help="Initialize optimization state from a target table")
    add_common(init)
    init.add_argument("--targets", required=True, help="TSV/CSV target table")
    init.add_argument("--force", action="store_true", help="Replace existing session state")
    init.add_argument("--consecutive-reverts", type=int, default=DEFAULT_CONSECUTIVE_REVERTS)
    init.add_argument("--pct-peak-threshold", type=float, default=DEFAULT_PCT_PEAK_THRESHOLD)
    init.add_argument("--max-minutes-per-target", type=float, default=DEFAULT_MAX_MINUTES_PER_TARGET)
    init.add_argument("--speedup-threshold", type=float, default=DEFAULT_SPEEDUP_THRESHOLD)
    init.add_argument("--default-min-improvement-pct", type=float, default=DEFAULT_MIN_IMPROVEMENT_PCT)
    init.set_defaults(func=init_command)

    baseline = subcommands.add_parser("baseline", help="Record a target baseline")
    add_common(baseline)
    baseline.add_argument("--target-id", help="Target id; defaults to current target")
    baseline.set_defaults(func=baseline_command)

    attempt = subcommands.add_parser("attempt", help="Measure one focused optimization attempt")
    add_common(attempt)
    attempt.add_argument("--target-id", help="Target id; defaults to current target")
    attempt.add_argument("--attempt-id", help="Stable attempt id; defaults to timestamp plus tag")
    attempt.add_argument("--tag", required=True, help="Short experiment tag")
    attempt.add_argument("--description", required=True, help="Experiment hypothesis or summary")
    attempt.add_argument("--verify-cmd", help="Override target verify command")
    attempt.add_argument("--benchmark-cmd", help="Override target benchmark command")
    attempt.add_argument("--metric-name", help="Override target metric name")
    attempt.add_argument("--direction", choices=["lower", "higher"], help="Override target metric direction")
    attempt.add_argument("--min-improvement-pct", type=float, help="Override required improvement percentage")
    attempt.add_argument("--allow-simpler-equivalent", action="store_true", help="Keep equivalent simpler code")
    attempt.add_argument("--equivalent-tolerance-pct", type=float, default=0.0, help="Allowed regression for simpler equivalent code")
    attempt.add_argument("--auto-revert", action="store_true", help="Reverse rejected attempt patches")
    attempt.add_argument("--commit-keep", action="store_true", help="Commit kept attempt changes")
    attempt.set_defaults(func=attempt_command)

    next_parser = subcommands.add_parser("next", help="Print the next orchestration decision")
    add_common(next_parser)
    next_parser.set_defaults(func=next_command)

    report = subcommands.add_parser("report", help="Generate final optimization report")
    add_common(report)
    report.add_argument("--final-cmd", help="Representative final validation command to run before reporting")
    report.set_defaults(func=report_command)
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        return int(args.func(args))
    except ToolError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
