# Benchmarks

Benchmarks are evidence, not decoration. Record enough context that another developer can reproduce
the result or explain why it changed.

## Required Record

- exact executable and arguments
- git revision or working-tree diff scope
- CMake preset, build type, and enabled feature options
- GPU model and driver/toolkit versions
- selected CUDA runtime device, including `CUDA_VISIBLE_DEVICES` or `GPU_ALLOWED_INDICES` if set
- `PROJECT_CUDA_ARCHITECTURES` when CUDA is enabled
- Vulkan API version, ICD/driver, and validation-layer state when Vulkan is measured
- workload size, input data, precision, batch size, and warmup/iteration counts
- median and p95 timing or throughput
- profiler artifact path when a profiler was used
- before/after comparison when the benchmark supports a change claim
- success criteria for the scenario before optimization starts
- hypothesis id, evidence, and validation-pass count for measured optimization attempts

## Baseline Format

Use this compact format in issue comments, PR notes, or a project-owned benchmark log:

```text
Benchmark: <name>
Revision: <git sha or diff label>
Preset: <cmake preset>, build <type>, CUDA arch <value>
Device: <GPU>, driver <version>, CUDA <version>, Vulkan <version/ICD if used>
Runtime GPU selection: <CUDA_VISIBLE_DEVICES/GPU_ALLOWED_INDICES or none>
Workload: <input, dimensions, dtype, batch, frames/iterations>
Command: <exact command>
Result: median <value>, p95 <value>, throughput <value>
Artifacts: <profile/report/log paths>
Notes: <thermal/power/clock/validation caveats>
```

## Profiling Order

Use validation layers first for Vulkan correctness questions. Use RenderDoc or Nsight Graphics Frame
Debugger for frame contents, pipeline state, descriptors, and event order. Use Nsight Graphics GPU
Trace or `nsys` for frame timing and queue overlap. Use Nsight Systems first for CUDA launch/overlap
questions. Use `ncu` only after a hot CUDA kernel has been identified.

When using `nsys stats`, choose reports from the installed tool with `nsys stats --help-reports`
instead of assuming a generic summary report exists. For generated CppStudio projects,
`scripts/run_nsys_smoke.sh` selects lane-appropriate Vulkan, CUDA, NVTX, and OS runtime reports that
the local Nsight Systems version advertises.

## Optimization Sessions

Use [GPU_OPTIMIZATION_LOOP.md](GPU_OPTIMIZATION_LOOP.md) for agent-run performance work. Its script
keeps baselines, hardware profile logs, roofline/SOL summaries, beam-round worker plans, attempt
logs, repeated validation-pass logs, hypothesis records, breaking-point searches, patch snapshots,
target state, and final consolidation reports under `artifacts/optimization/<session>/`. Copy only
durable summaries into tracked docs or PR notes.

## CI Policy

Do not enforce timing thresholds in CI until stable baselines are intentionally recorded for the target
hardware. Early CI should upload benchmark/profiler artifacts and fail only on correctness, missing
artifacts, crashed runs, or explicitly configured regression checks.
