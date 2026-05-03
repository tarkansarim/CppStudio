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
DEFAULT_PCT_PEAK_THRESHOLD = 95.0
DEFAULT_MAX_MINUTES_PER_TARGET = 120.0
DEFAULT_SPEEDUP_THRESHOLD = 2.0
DEFAULT_DIVERGENCE_THRESHOLD_PCT = 50.0
DEFAULT_CONVERGENCE_ROUNDS = 5
DEFAULT_CONVERGENCE_MIN_IMPROVEMENT_PCT = 0.1
DEFAULT_UNDERUTILIZED_THRESHOLD_PCT = 60.0
DEFAULT_TENSOR_CORE_THRESHOLD_PCT = 5.0
DEFAULT_BEAM_WIDTH = 2
DEFAULT_BOTTLENECK_DIRECTIONS = "memory,compute,underutilized"
METRIC_RE = re.compile(
    r"(?P<name>elapsed_us|latency_us|duration_us|frame_us|time_us|elapsed_ms|latency_ms|"
    r"duration_ms|frame_ms|time_ms|fps|throughput_tflops|throughput|items_per_s|"
    r"samples_per_s|gbps|gib_per_s)\s*[:=]\s*"
    r"(?P<value>[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)(?:x|%)?",
    re.IGNORECASE,
)
CORRECTNESS_RE = re.compile(r"\bcorrectness\s*[:=]\s*(?P<value>PASS|FAIL|OK|ERROR|CRASH|TRUE|FALSE)\b", re.IGNORECASE)
FLOAT_FIELD_RE = re.compile(
    r"\b(?P<name>pct_peak_compute|pct_peak_bandwidth|compute_sol_pct|memory_sol_pct|"
    r"sol_efficiency_pct|tensor_core_pct|peak_vram_mb|occupancy_pct)\s*[:=]\s*"
    r"(?P<value>[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)(?:%)?",
    re.IGNORECASE,
)
BOTTLENECK_RE = re.compile(r"\bbottleneck\s*[:=]\s*(?P<value>[A-Za-z0-9_.-]+)", re.IGNORECASE)
PROFILE_VALUE_RE = re.compile(
    r"(?P<name>[A-Za-z_][A-Za-z0-9_.-]*)\s*[:=]\s*"
    r"(?P<value>[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)(?:%)?",
    re.IGNORECASE,
)
HARDWARE_METRIC_ALIASES = {
    "pct_peak_compute": "compute_sol_pct",
    "compute_sol_pct": "compute_sol_pct",
    "sm__throughput.avg.pct_of_peak_sustained_elapsed": "compute_sol_pct",
    "sm__pipe_tensor_cycles_active.avg.pct_of_peak_sustained_elapsed": "tensor_core_pct",
    "sm__pipe_tensor_cycles_active.avg.pct_of_peak_sustained_active": "tensor_core_pct",
    "pct_peak_bandwidth": "memory_sol_pct",
    "memory_sol_pct": "memory_sol_pct",
    "gpu__compute_memory_throughput.avg.pct_of_peak_sustained_elapsed": "memory_sol_pct",
    "gpu__dram_throughput.avg.pct_of_peak_sustained_elapsed": "memory_sol_pct",
    "dram__throughput.avg.pct_of_peak_sustained_elapsed": "memory_sol_pct",
    "sol_efficiency_pct": "sol_efficiency_pct",
    "tensor_core_pct": "tensor_core_pct",
    "occupancy_pct": "occupancy_pct",
    "sm__warps_active.avg.pct_of_peak_sustained_active": "occupancy_pct",
    "peak_vram_mb": "peak_vram_mb",
}
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
    "compute_sol_pct",
    "memory_sol_pct",
    "sol_efficiency_pct",
    "roofline_bottleneck",
    "roofline_status",
    "profile_status",
    "round_id",
    "worker_id",
    "parent_attempt_id",
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
    settings = state.setdefault("settings", {})
    settings.setdefault("divergence_threshold_pct", DEFAULT_DIVERGENCE_THRESHOLD_PCT)
    settings.setdefault("convergence_rounds", DEFAULT_CONVERGENCE_ROUNDS)
    settings.setdefault("convergence_min_improvement_pct", DEFAULT_CONVERGENCE_MIN_IMPROVEMENT_PCT)
    settings.setdefault("underutilized_threshold_pct", DEFAULT_UNDERUTILIZED_THRESHOLD_PCT)
    settings.setdefault("tensor_core_threshold_pct", DEFAULT_TENSOR_CORE_THRESHOLD_PCT)
    settings.setdefault("beam_width", DEFAULT_BEAM_WIDTH)
    settings.setdefault(
        "bottleneck_directions",
        [part.strip() for part in DEFAULT_BOTTLENECK_DIRECTIONS.split(",") if part.strip()],
    )
    for target in state["targets"].values():
        if isinstance(target, dict):
            target.setdefault("profile_cmd", "")
            target.setdefault("best_sol_pct", None)
            target.setdefault("best_sol_attempt_id", "")
            target.setdefault("last_roofline", {})
            target.setdefault("best_history", [])
            target.setdefault("current_round", 0)
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
                "profile_cmd": (row.get("profile_cmd") or "").strip(),
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
                "best_sol_pct": None,
                "best_sol_attempt_id": "",
                "last_roofline": {},
                "best_history": [],
                "current_round": 0,
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
            key = match.group("name").lower()
            parsed[key] = value
            canonical = HARDWARE_METRIC_ALIASES.get(key)
            if canonical:
                parsed[canonical] = value
    return parsed


def parse_bottleneck(output: str) -> str:
    matches = list(BOTTLENECK_RE.finditer(output))
    return matches[-1].group("value").lower() if matches else ""


def parse_profile_metrics(output: str) -> dict[str, float]:
    parsed = parse_float_fields(output)
    for match in PROFILE_VALUE_RE.finditer(output):
        key = match.group("name").lower()
        canonical = HARDWARE_METRIC_ALIASES.get(key)
        if not canonical:
            continue
        value = float(match.group("value"))
        if math.isfinite(value):
            parsed[canonical] = value
            parsed[key] = value
    return parsed


def parse_profile_csv(path: Path) -> dict[str, float]:
    if not path.exists():
        raise ToolError(f"profile CSV does not exist: {path}")
    try:
        with path.open("r", encoding="utf-8", newline="") as handle:
            rows = list(csv.DictReader(handle, skipinitialspace=True))
    except csv.Error as error:
        raise ToolError(f"profile CSV could not be parsed: {error}") from error
    parsed: dict[str, float] = {}
    for row in rows:
        for key, raw in row.items():
            if key is None:
                continue
            canonical = HARDWARE_METRIC_ALIASES.get(key.strip().lower())
            if not canonical:
                continue
            value_text = str(raw).replace(",", "").replace("%", "").strip()
            if not value_text:
                continue
            try:
                value = float(value_text)
            except ValueError:
                continue
            if math.isfinite(value):
                parsed[canonical] = value
                parsed[key.strip().lower()] = value
    return parsed


def classify_roofline(fields: dict[str, float], settings: dict[str, Any]) -> dict[str, object]:
    compute = fields.get("compute_sol_pct", fields.get("pct_peak_compute"))
    memory = fields.get("memory_sol_pct", fields.get("pct_peak_bandwidth"))
    tensor = fields.get("tensor_core_pct", 0.0)
    threshold = float(settings.get("pct_peak_threshold", DEFAULT_PCT_PEAK_THRESHOLD))
    underutilized = float(settings.get("underutilized_threshold_pct", DEFAULT_UNDERUTILIZED_THRESHOLD_PCT))
    tensor_threshold = float(settings.get("tensor_core_threshold_pct", DEFAULT_TENSOR_CORE_THRESHOLD_PCT))
    warnings: list[str] = []
    if compute is None:
        warnings.append("compute SOL missing")
        compute_value = 0.0
    else:
        compute_value = float(compute)
    if memory is None:
        warnings.append("memory SOL missing")
        memory_value = 0.0
    else:
        memory_value = float(memory)
    if compute is None and memory is None:
        bottleneck = "unknown"
        efficiency = 0.0
    else:
        efficiency = max(compute_value, memory_value)
        if compute_value < underutilized and memory_value < underutilized:
            bottleneck = "underutilized"
        elif memory_value >= compute_value:
            bottleneck = "memory"
        else:
            bottleneck = "compute"
    return {
        "compute_sol_pct": round(compute_value, 6),
        "memory_sol_pct": round(memory_value, 6),
        "sol_efficiency_pct": round(efficiency, 6),
        "bottleneck": bottleneck,
        "at_roofline": efficiency >= threshold,
        "headroom_pct": round(max(0.0, 100.0 - efficiency), 6),
        "uses_tensor_cores": float(tensor) > tensor_threshold,
        "warnings": warnings,
    }


def merge_roofline_fields(row: dict[str, object], roofline: dict[str, object] | None) -> None:
    if not roofline:
        return
    row["compute_sol_pct"] = roofline.get("compute_sol_pct", "")
    row["memory_sol_pct"] = roofline.get("memory_sol_pct", "")
    row["sol_efficiency_pct"] = roofline.get("sol_efficiency_pct", "")
    row["roofline_bottleneck"] = roofline.get("bottleneck", "")
    row["roofline_status"] = "at_roofline" if roofline.get("at_roofline") else "headroom"


def update_target_roofline(target: dict[str, Any], attempt_id: str, roofline: dict[str, object]) -> None:
    if not roofline:
        return
    target["last_roofline"] = roofline
    target["pct_peak"] = roofline.get("sol_efficiency_pct")
    efficiency = float(roofline.get("sol_efficiency_pct") or 0.0)
    best_sol = target.get("best_sol_pct")
    if best_sol is None or efficiency > float(best_sol):
        target["best_sol_pct"] = round(efficiency, 6)
        target["best_sol_attempt_id"] = attempt_id


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


def regression_pct(reference: float, current: float, direction: str) -> float:
    _, pct = improvement(reference, current, direction)
    return max(0.0, -pct)


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
    compute = fields.get("compute_sol_pct", fields.get("pct_peak_compute"))
    bandwidth = fields.get("memory_sol_pct", fields.get("pct_peak_bandwidth"))
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
            "divergence_threshold_pct": args.divergence_threshold_pct,
            "convergence_rounds": args.convergence_rounds,
            "convergence_min_improvement_pct": args.convergence_min_improvement_pct,
            "underutilized_threshold_pct": args.underutilized_threshold_pct,
            "tensor_core_threshold_pct": args.tensor_core_threshold_pct,
            "beam_width": args.beam_width,
            "bottleneck_directions": [part.strip() for part in args.bottlenecks.split(",") if part.strip()],
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
    fields = parse_profile_metrics(output)
    bottleneck = parse_bottleneck(output)
    roofline = classify_roofline(fields, state["settings"])
    if bottleneck:
        roofline["bottleneck"] = bottleneck
    update_target_roofline(target, "baseline", roofline)
    pct_peak = select_pct_peak(fields, str(roofline.get("bottleneck") or bottleneck))
    target["pct_peak"] = pct_peak
    target["best_history"] = [
        {
            "attempt_id": "baseline",
            "best_value": metric_value,
            "timestamp": utc_now(),
        }
    ]
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
        "pct_peak_compute": fields.get("pct_peak_compute", fields.get("compute_sol_pct", "")),
        "pct_peak_bandwidth": fields.get("pct_peak_bandwidth", fields.get("memory_sol_pct", "")),
        "bottleneck": roofline.get("bottleneck", bottleneck),
        "peak_vram_mb": fields.get("peak_vram_mb", ""),
        "verify_status": verify["returncode"],
        "benchmark_status": benchmark["returncode"],
        "log_dir": str(baseline_dir.relative_to(repo)),
        "notes": "baseline recorded",
    }
    merge_roofline_fields(row, roofline)
    append_result(root, row)
    append_event(root, "baseline_complete", **row)
    print(
        f"cppstudio_opt_baseline session={args.session} target_id={target['target_id']} "
        f"metric_name={metric_name} metric_value={metric_value:g} direction={direction}"
    )
    return 0


def profile_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    state = load_state(root)
    target = target_lookup(state, args.target_id or state.get("current_target_id", ""))
    command = args.profile_cmd or target.get("profile_cmd") or ""
    if not command:
        raise ToolError("no profile command configured; add profile_cmd to the target table or pass --profile-cmd")
    profile_id = sanitize_id(args.profile_id or f"profile-{int(time.time())}")
    profile_dir = root / "targets" / target["target_id"] / "profiles" / profile_id
    append_event(root, "profile_start", target_id=target["target_id"], profile_id=profile_id)
    result = command_log(repo, profile_dir / "profile.log", command)
    output = str(result["stdout"]) + "\n" + str(result["stderr"])
    fields = parse_profile_metrics(output)
    if args.ncu_csv:
        csv_path = Path(args.ncu_csv)
        if not csv_path.is_absolute():
            csv_path = repo / csv_path
        fields.update(parse_profile_csv(csv_path))
    bottleneck = parse_bottleneck(output)
    roofline = classify_roofline(fields, state["settings"])
    if bottleneck:
        roofline["bottleneck"] = bottleneck
    metrics_record = {
        "profile_id": profile_id,
        "target_id": target["target_id"],
        "command": command,
        "returncode": result["returncode"],
        "hardware_metrics": fields,
        "roofline": roofline,
        "log_path": result["log_path"],
        "notes": args.notes,
    }
    write_json(profile_dir / "profile_metrics.json", metrics_record)
    if int(result["returncode"]) == 0:
        update_target_roofline(target, profile_id, roofline)
        update_elapsed_minutes(target)
        save_state(root, state)
    row = {
        "timestamp": utc_now(),
        "session": args.session,
        "target_id": target["target_id"],
        "kind": "profile",
        "attempt_id": profile_id,
        "tag": args.tag or "profile",
        "decision": "PROFILE" if int(result["returncode"]) == 0 else "PROFILE_FAIL",
        "correctness": "",
        "metric_name": target.get("metric_name", ""),
        "metric_value": "",
        "direction": target.get("direction", ""),
        "baseline_value": "" if target.get("baseline_value") is None else f"{float(target['baseline_value']):.12g}",
        "reference_value": "" if target.get("best_value") is None else f"{float(target['best_value']):.12g}",
        "share_pct": f"{float(target['share_pct']):.12g}",
        "pct_peak_compute": fields.get("pct_peak_compute", fields.get("compute_sol_pct", "")),
        "pct_peak_bandwidth": fields.get("pct_peak_bandwidth", fields.get("memory_sol_pct", "")),
        "bottleneck": roofline.get("bottleneck", bottleneck),
        "peak_vram_mb": fields.get("peak_vram_mb", ""),
        "profile_status": result["returncode"],
        "log_dir": str(profile_dir.relative_to(repo)),
        "notes": args.notes or "hardware profile recorded",
    }
    merge_roofline_fields(row, roofline)
    append_result(root, row)
    append_event(root, "profile_complete", **row)
    print(
        f"cppstudio_opt_profile session={args.session} target_id={target['target_id']} "
        f"profile_id={profile_id} status={result['returncode']} "
        f"bottleneck={roofline.get('bottleneck')} sol_efficiency_pct={roofline.get('sol_efficiency_pct')}"
    )
    return 0 if int(result["returncode"]) == 0 and roofline.get("bottleneck") != "unknown" else 1


def split_csv_values(value: str) -> list[str]:
    return [part.strip() for part in value.split(",") if part.strip()]


def candidate_rows(root: Path, target: dict[str, Any], limit: int) -> list[dict[str, str]]:
    rows = [
        row
        for row in read_results(root)
        if row.get("target_id") == target["target_id"]
        and row.get("kind") in {"baseline", "attempt"}
        and row.get("decision") in {"BASELINE", "KEEP"}
        and row.get("metric_value")
    ]
    direction = str(target.get("direction") or "lower")

    def metric(row: dict[str, str]) -> float:
        try:
            return float(row.get("metric_value") or "inf")
        except ValueError:
            return float("inf")

    rows.sort(key=metric, reverse=(direction == "higher"))
    return rows[:limit]


def plan_round_command(args: argparse.Namespace) -> int:
    repo = Path(args.repo).expanduser().resolve()
    root = artifact_root(repo, args.session)
    state = load_state(root)
    target = target_lookup(state, args.target_id or state.get("current_target_id", ""))
    if target.get("baseline_value") is None:
        raise ToolError("target has no baseline; run baseline first")
    settings = state["settings"]
    beam_width = args.beam_width or int(settings.get("beam_width", DEFAULT_BEAM_WIDTH))
    bottlenecks = split_csv_values(args.bottlenecks) if args.bottlenecks else list(settings.get("bottleneck_directions", []))
    last_bottleneck = str((target.get("last_roofline") or {}).get("bottleneck") or "")
    if last_bottleneck and last_bottleneck not in {"unknown", *bottlenecks}:
        bottlenecks.insert(0, last_bottleneck)
    if not bottlenecks:
        bottlenecks = split_csv_values(DEFAULT_BOTTLENECK_DIRECTIONS)
    candidates = candidate_rows(root, target, beam_width)
    if not candidates:
        raise ToolError("no baseline or kept attempts available for round planning")
    round_num = args.round_num if args.round_num is not None else int(target.get("current_round", 0)) + 1
    target["current_round"] = max(int(target.get("current_round", 0)), round_num)
    round_id = f"round{round_num:03d}"
    round_dir = root / "targets" / target["target_id"] / "rounds" / round_id
    workers: list[dict[str, object]] = []
    worker_index = 0
    for rank, parent in enumerate(candidates, 1):
        for bottleneck in bottlenecks:
            worker_index += 1
            worker_id = f"worker{worker_index:03d}"
            worker_dir = round_dir / "workers" / worker_id
            worker_dir.mkdir(parents=True, exist_ok=True)
            worker = {
                "round_id": round_id,
                "worker_id": worker_id,
                "target_id": target["target_id"],
                "parent_rank": rank,
                "parent_attempt_id": parent.get("attempt_id", ""),
                "parent_metric_name": parent.get("metric_name", target.get("metric_name", "")),
                "parent_metric_value": parent.get("metric_value", ""),
                "bottleneck": bottleneck,
                "scope_paths": target.get("scope_paths", []),
                "verify_cmd": target.get("verify_cmd", ""),
                "benchmark_cmd": target.get("benchmark_cmd", ""),
                "profile_cmd": target.get("profile_cmd", ""),
                "instruction": "Apply one focused edit for this bottleneck direction, then run attempt with this round_id and worker_id.",
            }
            workers.append(worker)
            write_json(worker_dir / "worker.json", worker)
    plan = {
        "session": args.session,
        "target_id": target["target_id"],
        "round_id": round_id,
        "beam_width": beam_width,
        "bottlenecks": bottlenecks,
        "workers": workers,
    }
    write_json(round_dir / "round_plan.json", plan)
    tsv = round_dir / "worker_plan.tsv"
    with tsv.open("w", encoding="utf-8", newline="") as handle:
        fieldnames = ["worker_id", "parent_attempt_id", "parent_metric_value", "bottleneck", "scope_paths"]
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter="\t")
        writer.writeheader()
        for worker in workers:
            writer.writerow(
                {
                    "worker_id": worker["worker_id"],
                    "parent_attempt_id": worker["parent_attempt_id"],
                    "parent_metric_value": worker["parent_metric_value"],
                    "bottleneck": worker["bottleneck"],
                    "scope_paths": ";".join(str(path) for path in worker["scope_paths"]),
                }
            )
    save_state(root, state)
    append_event(root, "round_planned", target_id=target["target_id"], round_id=round_id, worker_count=len(workers))
    print(
        f"cppstudio_opt_round session={args.session} target_id={target['target_id']} "
        f"round_id={round_id} workers={len(workers)} plan={round_dir.relative_to(repo)}"
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
    round_id = sanitize_id(args.round_id) if args.round_id else ""
    worker_id = sanitize_id(args.worker_id) if args.worker_id else ""
    parent_attempt_id = sanitize_id(args.parent_attempt_id) if args.parent_attempt_id else str(target.get("best_attempt_id") or "baseline")
    if round_id or worker_id:
        if not round_id or not worker_id:
            raise ToolError("--round-id and --worker-id must be passed together")
        attempt_dir = root / "targets" / target["target_id"] / "rounds" / round_id / "workers" / worker_id / "attempt"
    else:
        attempt_dir = root / "targets" / target["target_id"] / "attempts" / attempt_id
    append_event(
        root,
        "attempt_start",
        target_id=target["target_id"],
        attempt_id=attempt_id,
        round_id=round_id,
        worker_id=worker_id,
        parent_attempt_id=parent_attempt_id,
        changed_paths=changed,
    )

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
    roofline: dict[str, object] | None = None
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
                fields = parse_profile_metrics(output)
                bottleneck = parse_bottleneck(output)
                roofline = classify_roofline(fields, state["settings"])
                if bottleneck:
                    roofline["bottleneck"] = bottleneck
                pct_peak = select_pct_peak(fields, str(roofline.get("bottleneck") or bottleneck))
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
                elif regression_pct(reference_value, metric_value, direction) > float(state["settings"]["divergence_threshold_pct"]):
                    decision = "REVERT" if args.auto_revert else "REJECT"
                    notes = (
                        f"diverged {regression_pct(reference_value, metric_value, direction):.6g}% from best, "
                        f"above {float(state['settings']['divergence_threshold_pct']):.6g}% threshold"
                    )
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
        if roofline:
            update_target_roofline(target, attempt_id, roofline)
        if args.commit_keep:
            commit_sha = commit_keep(repo, target, attempt_id, changed, args.tag)
            target["best_commit"] = commit_sha
    else:
        target["consecutive_reverts"] = int(target.get("consecutive_reverts", 0)) + 1
    if decision == "REVERT":
        target["consecutive_reverts"] = int(target.get("consecutive_reverts", 0)) + 1

    target["attempts_run"] = int(target.get("attempts_run", 0)) + 1
    if target.get("best_value") is not None:
        history = target.setdefault("best_history", [])
        history.append(
            {
                "attempt_id": attempt_id,
                "best_value": float(target["best_value"]),
                "timestamp": utc_now(),
            }
        )
        max_history = max(20, int(state["settings"].get("convergence_rounds", DEFAULT_CONVERGENCE_ROUNDS)) + 5)
        target["best_history"] = history[-max_history:]
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
        "pct_peak_compute": fields.get("pct_peak_compute", fields.get("compute_sol_pct", "")),
        "pct_peak_bandwidth": fields.get("pct_peak_bandwidth", fields.get("memory_sol_pct", "")),
        "bottleneck": roofline.get("bottleneck", bottleneck) if roofline else bottleneck,
        "peak_vram_mb": fields.get("peak_vram_mb", ""),
        "round_id": round_id,
        "worker_id": worker_id,
        "parent_attempt_id": parent_attempt_id,
        "verify_status": verify["returncode"],
        "benchmark_status": benchmark_status,
        "changed_paths": ",".join(changed),
        "patch_path": str(patch_path.relative_to(repo)),
        "commit": commit_sha,
        "log_dir": str(attempt_dir.relative_to(repo)),
        "notes": notes,
    }
    merge_roofline_fields(row, roofline)
    append_result(root, row)
    append_event(root, "attempt_complete", **row)
    print(
        f"cppstudio_opt_attempt session={args.session} target_id={target['target_id']} "
        f"attempt_id={attempt_id} decision={decision} correctness={correctness} "
        f"metric_name={metric_name} metric_value={'' if metric_value is None else f'{metric_value:g}'}"
    )
    return 0 if decision == "KEEP" else 1


def convergence_move_reason(target: dict[str, Any], settings: dict[str, Any]) -> str:
    rounds = int(settings.get("convergence_rounds", DEFAULT_CONVERGENCE_ROUNDS))
    if rounds <= 0:
        return ""
    history = target.get("best_history") or []
    if len(history) <= rounds:
        return ""
    direction = str(target.get("direction") or "lower")
    before = float(history[-rounds - 1]["best_value"])
    after = float(history[-1]["best_value"])
    _, pct = improvement(before, after, direction)
    min_pct = float(settings.get("convergence_min_improvement_pct", DEFAULT_CONVERGENCE_MIN_IMPROVEMENT_PCT))
    if pct < min_pct:
        return f"performance converged over {rounds} attempts ({pct:.3g}% < {min_pct:.3g}%)"
    return ""


def target_move_reason(target: dict[str, Any], settings: dict[str, Any]) -> str:
    if int(target.get("consecutive_reverts", 0)) >= int(settings["consecutive_reverts"]):
        return f"consecutive reverts reached {target.get('consecutive_reverts')}"
    pct_peak = target.get("pct_peak")
    if pct_peak is not None and float(pct_peak) >= float(settings["pct_peak_threshold"]):
        return f"near roofline/SOL utilization {float(pct_peak):.1f}%"
    convergence = convergence_move_reason(target, settings)
    if convergence:
        return convergence
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
    lines.append("| Target | Status | Share | Baseline | Best | Speedup | Best SOL | Attempts | Kept | Move-On Reason |")
    lines.append("| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |")
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
                    "" if target.get("best_sol_pct") is None else f"{float(target['best_sol_pct']):.3g}%",
                    str(target.get("attempts_run", 0)),
                    str(target.get("attempts_kept", 0)),
                    str(target.get("move_on_reason", "")),
                ]
            )
            + " |"
        )
    lines.extend(["", "## Attempt Log", ""])
    lines.append("| Attempt | Target | Round | Worker | Decision | Correctness | Metric | Improvement | Roofline | Notes |")
    lines.append("| --- | --- | --- | --- | --- | --- | --- | ---: | --- | --- |")
    for row in rows:
        metric = f"{row.get('metric_name', '')}={row.get('metric_value', '')}".strip("=")
        roofline = row.get("roofline_bottleneck", "") or row.get("bottleneck", "")
        sol = row.get("sol_efficiency_pct", "")
        if sol:
            roofline = f"{roofline} {sol}%".strip()
        lines.append(
            "| "
            + " | ".join(
                [
                    row.get("attempt_id", ""),
                    row.get("target_id", ""),
                    row.get("round_id", ""),
                    row.get("worker_id", ""),
                    row.get("decision", ""),
                    row.get("correctness", ""),
                    metric,
                    row.get("improvement_pct", ""),
                    roofline,
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
    init.add_argument("--divergence-threshold-pct", type=float, default=DEFAULT_DIVERGENCE_THRESHOLD_PCT)
    init.add_argument("--convergence-rounds", type=int, default=DEFAULT_CONVERGENCE_ROUNDS)
    init.add_argument("--convergence-min-improvement-pct", type=float, default=DEFAULT_CONVERGENCE_MIN_IMPROVEMENT_PCT)
    init.add_argument("--underutilized-threshold-pct", type=float, default=DEFAULT_UNDERUTILIZED_THRESHOLD_PCT)
    init.add_argument("--tensor-core-threshold-pct", type=float, default=DEFAULT_TENSOR_CORE_THRESHOLD_PCT)
    init.add_argument("--beam-width", type=int, default=DEFAULT_BEAM_WIDTH)
    init.add_argument("--bottlenecks", default=DEFAULT_BOTTLENECK_DIRECTIONS, help="Comma-separated beam-search bottleneck directions")
    init.set_defaults(func=init_command)

    baseline = subcommands.add_parser("baseline", help="Record a target baseline")
    add_common(baseline)
    baseline.add_argument("--target-id", help="Target id; defaults to current target")
    baseline.set_defaults(func=baseline_command)

    profile = subcommands.add_parser("profile", help="Record hardware profile and roofline/SOL diagnosis")
    add_common(profile)
    profile.add_argument("--target-id", help="Target id; defaults to current target")
    profile.add_argument("--profile-id", help="Stable profile id; defaults to timestamp")
    profile.add_argument("--profile-cmd", help="Override target profile command")
    profile.add_argument("--ncu-csv", help="Optional Nsight Compute CSV file to parse after profile command")
    profile.add_argument("--tag", help="Short profile tag")
    profile.add_argument("--notes", default="", help="Profile notes")
    profile.set_defaults(func=profile_command)

    plan_round = subcommands.add_parser("plan-round", help="Create beam-style per-round worker artifacts")
    add_common(plan_round)
    plan_round.add_argument("--target-id", help="Target id; defaults to current target")
    plan_round.add_argument("--round-num", type=int, help="Explicit round number")
    plan_round.add_argument("--beam-width", type=int, help="Number of top parent attempts to explore")
    plan_round.add_argument("--bottlenecks", help="Comma-separated bottleneck directions to explore")
    plan_round.set_defaults(func=plan_round_command)

    attempt = subcommands.add_parser("attempt", help="Measure one focused optimization attempt")
    add_common(attempt)
    attempt.add_argument("--target-id", help="Target id; defaults to current target")
    attempt.add_argument("--attempt-id", help="Stable attempt id; defaults to timestamp plus tag")
    attempt.add_argument("--tag", required=True, help="Short experiment tag")
    attempt.add_argument("--description", required=True, help="Experiment hypothesis or summary")
    attempt.add_argument("--round-id", help="Round id from plan-round")
    attempt.add_argument("--worker-id", help="Worker id from plan-round")
    attempt.add_argument("--parent-attempt-id", help="Parent attempt id from plan-round")
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
