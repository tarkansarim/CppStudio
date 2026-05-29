# GPU Optimization Loop

Use this loop when improving CUDA kernels, Vulkan compute shaders, render passes, simulation kernels,
or realtime frame time. The goal is to make performance work reproducible: define success criteria,
baseline, profile, log one focused hypothesis, validate, benchmark, keep or revert, then consolidate
the evidence before claiming a speedup.

## Target Table

Create a project-owned TSV such as `docs/GPU_OPTIMIZATION_TARGETS.tsv`:

```text
target_id	lane	workload	share_pct	benchmark_cmd	verify_cmd	profile_cmd	scope_paths	success_criteria	validation_passes	metric_name	direction	notes
cuda_vector_add	cuda	CUDA vector add benchmark	12	ctest --preset benchmark --output-on-failure	ctest --preset cuda --output-on-failure	ncu --csv --page=raw --metrics sm__throughput.avg.pct_of_peak_sustained_elapsed,gpu__compute_memory_throughput.avg.pct_of_peak_sustained_elapsed ./build/dev/tests/cuda_vector_add_bench	src/cuda;include	correctness stays green and elapsed_us improves on the representative benchmark	2	elapsed_us	lower	replace share with profiler evidence
vulkan_compute	vulkan	Vulkan compute dispatch	18	ctest --preset benchmark --output-on-failure	ctest --preset vulkan-compute --output-on-failure	<project-owned Vulkan profile command that prints pct_peak_compute/pct_peak_bandwidth/bottleneck>	src/render;shaders	correctness stays green and frame_ms improves on the representative dispatch	2	frame_ms	lower	representative dispatch or frame workload
```

Required columns are `target_id`, `lane`, `workload`, `share_pct`, `benchmark_cmd`, `verify_cmd`,
`scope_paths`, and `success_criteria`. `profile_cmd` is optional but recommended for CUDA, Vulkan
compute, render-pass, or frame-time work where hardware counters are available. `validation_passes`
is optional and defaults to `2`; if present it must be at least `2`. Use semicolons in `scope_paths`
when one target owns more than one directory.

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

Record hardware counters and a roofline/SOL diagnosis before editing:

```bash
scripts/run_gpu_optimization_loop.py profile \
  --session opt-session \
  --target-id cuda_vector_add \
  --profile-id baseline-ncu
```

If the target machine cannot expose the required profiler or hardware counters, record the gap as an
artifact instead of skipping the profiling phase silently:

```bash
scripts/run_gpu_optimization_loop.py profile \
  --session opt-session \
  --target-id cuda_vector_add \
  --profile-id profiler-unavailable \
  --tool-gap "Nsight Compute counters are unavailable on this runner"
```

Optional breaking-point search can map the workload size where the target first fails or degrades
beyond the declared threshold:

```bash
scripts/run_gpu_optimization_loop.py breaking-point \
  --session opt-session \
  --target-id cuda_vector_add \
  --param-name elements \
  --param-env PERF_PARAM_VALUE \
  --min 10000 \
  --max 1000000 \
  --threshold 5000 \
  --direction lower \
  --cmd './build/dev/tests/cuda_vector_add_bench --elements {value}'
```

When multiple directions are worth trying, create beam-style worker artifacts for parallel agents:

```bash
scripts/run_gpu_optimization_loop.py plan-round \
  --session opt-session \
  --target-id cuda_vector_add \
  --beam-width 2 \
  --bottlenecks memory,compute,underutilized
```

Each worker gets `targets/<target>/rounds/<round>/workers/<worker>/worker.json` describing the
parent attempt, bottleneck direction, scope paths, and commands. Run each worker in its own branch or
worktree when agents are editing in parallel.

Before editing, log the hypothesis that the attempt will test:

```bash
scripts/run_gpu_optimization_loop.py hypothesis \
  --session opt-session \
  --target-id cuda_vector_add \
  --hypothesis-id H1 \
  --confidence medium \
  --summary "Shared-memory tiling should reduce global load pressure." \
  --evidence "baseline-ncu reports bottleneck=memory and low compute SOL" \
  --expected-effect "elapsed_us lower and memory SOL closer to compute SOL"
```

Make one focused edit under the target's declared `scope_paths`, then measure it:

```bash
scripts/run_gpu_optimization_loop.py attempt \
  --session opt-session \
  --target-id cuda_vector_add \
  --round-id round001 \
  --worker-id worker001 \
  --parent-attempt-id baseline \
  --attempt-id tile-128 \
  --tag tile-128 \
  --hypothesis-id H1 \
  --description "Test 128-thread tile layout." \
  --auto-revert
```

`attempt` runs the target verification command sequentially for the configured validation-pass count
before benchmarking. A failed validation pass rejects or reverts the attempt before performance is
considered.

When a focused edit adds a new file under `scope_paths`, run `git add -N <path>` first so the new
file is included in the measured patch without staging its content. Keep normal staged changes out
of optimization attempts.

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

## Investigation Phases

Keep performance sessions in this order unless the user explicitly narrows the work:

1. Define scenario, representative target, success criteria, and benchmark command.
2. Record a fixed baseline.
3. Optionally run breaking-point search for workload size or quality limits.
4. Profile the current target and classify the dominant bottleneck.
5. Log up to a small set of hypotheses with evidence and confidence.
6. Plan a round when multiple parent attempts or bottlenecks are worth exploring.
7. Apply one focused edit tied to one hypothesis.
8. Run two or more validation passes, then benchmark only if correctness stays green.
9. Keep, reject, or revert based on the measured representative result.
10. Generate the final consolidation report before publishing performance claims.

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

For Nsight Compute-backed CUDA diagnosis, the script also understands KernelAgent-style SOL metric
names:

```text
sm__throughput.avg.pct_of_peak_sustained_elapsed=72.4
gpu__compute_memory_throughput.avg.pct_of_peak_sustained_elapsed=38.1
sm__pipe_tensor_cycles_active.avg.pct_of_peak_sustained_active=0.0
```

`profile` can parse these from stdout/stderr or from a CSV passed with `--ncu-csv`. The roofline
classifier uses the higher of compute SOL and memory SOL as efficiency, classifies low compute plus
low memory as `underutilized`, and marks the target near-roofline at the configured SOL threshold.
For Vulkan work, make the project-owned `profile_cmd` emit the generic `pct_peak_compute`,
`pct_peak_bandwidth`, and `bottleneck` lines from the profiler available to that project, such as
Nsight Graphics GPU Trace, vendor tools, timestamp-query summaries, or engine counters. If hardware
counters are unavailable, use `profile --tool-gap "<reason>"` and continue with fixed
baseline/benchmark evidence.

Correctness always gates performance. A failed correctness command, failed benchmark command, or
benchmark line such as `correctness=FAIL` rejects the attempt.

## Decisions

- Correctness fails: reject the attempt, or revert the patch when `--auto-revert` is set.
- Benchmark parsing or metric evaluation fails: record the diagnostic and revert when
  `--auto-revert` is set.
- Correctness passes and the primary metric improves by at least the target threshold: keep.
- Correctness passes but the primary metric is unchanged or slower: reject or revert.
- Correctness passes but regresses far beyond the best-so-far value: revert when `--auto-revert` is
  set and record the divergence reason.
- Equivalent simpler code may be kept only with `--allow-simpler-equivalent`.

The default improvement threshold is 1 percent. Override it with `min_improvement_pct` in the target
table or `--min-improvement-pct` on `attempt`.

## Artifacts

Artifacts live under `artifacts/optimization/<session>/`:

- `state.json`: per-target orchestration state.
- `run.log`: session-level JSONL event log.
- `results.tsv`: greppable baseline and attempt table.
- `hypotheses.tsv`: evidence-backed hypothesis table.
- `targets/<target>/baseline/`: baseline logs.
- `targets/<target>/profiles/<profile>/`: profiler logs and parsed roofline/SOL metrics.
- `targets/<target>/hypotheses/`: per-hypothesis JSON records.
- `targets/<target>/breaking-point/<param>/`: binary-search trial logs and summary JSON.
- `targets/<target>/rounds/<round>/workers/<worker>/`: beam-style worker plans and attempt logs.
- `targets/<target>/attempts/<attempt>/`: attempt logs.
- `patches/`: patch snapshots for measured attempts.
- `final_report.md`: consolidation report with success criteria, hypotheses, breaking points,
  validation-pass evidence, accepted/rejected attempts, and final recommendation.

`artifacts/` is ignored by the template. Keep important summaries in PR notes, project-owned summaries, or
project-owned docs only after the report is generated.

## Move-On Criteria

The `next` command moves to another target when one of these thresholds is reached:

- too many consecutive reverts
- near roofline/SOL utilization from `pct_peak_compute`, `pct_peak_bandwidth`, or NCU SOL metrics
- convergence over the configured recent attempt window
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
