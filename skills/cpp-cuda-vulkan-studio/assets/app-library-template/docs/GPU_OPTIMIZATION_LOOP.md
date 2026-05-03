# GPU Optimization Loop

Use this loop when improving CUDA kernels, Vulkan compute shaders, render passes, simulation kernels,
or realtime frame time. The goal is to make performance work reproducible: baseline, one focused
hypothesis, verify, benchmark, keep or revert, then report.

## Target Table

Create a project-owned TSV such as `docs/GPU_OPTIMIZATION_TARGETS.tsv`:

```text
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	scope_paths	metric_name	direction	notes
cuda_vector_add	cuda	CUDA vector add benchmark	12	ctest --preset benchmark --output-on-failure	ctest --preset cuda --output-on-failure	src/cuda;include	elapsed_us	lower	replace share with profiler evidence
vulkan_compute	vulkan	Vulkan compute dispatch	18	ctest --preset benchmark --output-on-failure	ctest --preset vulkan-compute --output-on-failure	src/render;shaders	frame_ms	lower	representative dispatch or frame workload
```

Required columns are `target_id`, `lane`, `workload`, `share_pct`, `benchmark_cmd`, `verify_cmd`,
and `scope_paths`. Use semicolons in `scope_paths` when one target owns more than one directory.

## Workflow

Initialize a session:

```bash
scripts/run_gpu_optimization_loop.py init \
  --session opt-session \
  --targets docs/GPU_OPTIMIZATION_TARGETS.tsv
```

Record a baseline for the selected target:

```bash
scripts/run_gpu_optimization_loop.py baseline \
  --session opt-session \
  --target-id cuda_vector_add
```

Make one focused edit under the target's declared `scope_paths`, then measure it:

```bash
scripts/run_gpu_optimization_loop.py attempt \
  --session opt-session \
  --target-id cuda_vector_add \
  --attempt-id tile-128 \
  --tag tile-128 \
  --description "Test 128-thread tile layout." \
  --auto-revert
```

If an attempt is kept and more experiments will follow, create a normal git commit before making the
next edit, or pass `--commit-keep` when the user has approved autonomous optimization commits. This
keeps rejected follow-up patches reversible without discarding the last accepted change.

Ask the orchestrator what to do next:

```bash
scripts/run_gpu_optimization_loop.py next --session opt-session
```

Generate the report:

```bash
scripts/run_gpu_optimization_loop.py report --session opt-session
```

Use `--final-cmd "<representative command>"` with `report` when the project has an end-to-end app,
frame, simulation, or inference validation command.

## Benchmark Contract

The benchmark command should print compact greppable lines. Supported metric separators are `=` and
`:`:

```text
correctness=PASS
elapsed_us=4123
pct_peak_compute=54.2%
pct_peak_bandwidth=21.0%
bottleneck=compute
peak_vram_mb=128.5
```

Default metric names include `elapsed_us`, `latency_us`, `duration_us`, `frame_ms`, `time_ms`,
`fps`, `throughput`, `throughput_tflops`, `items_per_s`, `samples_per_s`, `gbps`, and `gib_per_s`.
Pass `metric_name` and `direction` in the target table when the output contains multiple metrics.

Correctness always gates performance. A failed correctness command, failed benchmark command, or
benchmark line such as `correctness=FAIL` rejects the attempt.

## Decisions

- Correctness fails: reject the attempt, or revert the patch when `--auto-revert` is set.
- Correctness passes and the primary metric improves by at least the target threshold: keep.
- Correctness passes but the primary metric is unchanged or slower: reject or revert.
- Equivalent simpler code may be kept only with `--allow-simpler-equivalent`.

The default improvement threshold is 1 percent. Override it with `min_improvement_pct` in the target
table or `--min-improvement-pct` on `attempt`.

## Artifacts

Artifacts live under `artifacts/optimization/<session>/`:

- `state.json`: per-target orchestration state.
- `run.log`: session-level JSONL event log.
- `results.tsv`: greppable baseline and attempt table.
- `targets/<target>/baseline/`: baseline logs.
- `targets/<target>/attempts/<attempt>/`: attempt logs.
- `patches/`: patch snapshots for measured attempts.
- `final_report.md`: close-out report.

`artifacts/` is ignored by the template. Keep important summaries in issue comments, PR notes, or
project-owned docs only after the report is generated.

## Move-On Criteria

The `next` command moves to another target when one of these thresholds is reached:

- too many consecutive reverts
- near theoretical peak utilization from `pct_peak_compute` or `pct_peak_bandwidth`
- per-target time budget exhausted
- target speedup threshold reached

Targets are initialized by explicit `rank` when present, otherwise by highest `share_pct` first. This
keeps optimization focused on changes that can move the representative workload.

## Playbook

- Tier 1: verify the benchmark, input size, correctness oracle, warmup, and profiler evidence.
- Tier 2: reduce algorithmic work, fuse passes, remove memory round trips, and improve data layout.
- Tier 3: improve coalescing, cache behavior, shared memory use, descriptor/update paths, and upload
  boundaries.
- Tier 4: tune occupancy, launch geometry, workgroup size, warp/subgroup operations, and queue/pass
  overlap.
- Tier 5: test precision changes, unrolling, prefetching, double buffering, and specialization
  constants only after correctness and data movement are stable.
- Tier 6: apply architecture-specific CUDA or Vulkan tuning only when the project accepts the
  portability tradeoff and records the target hardware.
