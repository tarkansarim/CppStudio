# CUDA Debugging, Profiling, And Testing

Last researched: 2026-04-30

## Correctness Order

1. CPU/reference comparison for small deterministic inputs.
2. Device tests with boundary sizes, non-multiple tile sizes, empty inputs, and extreme values.
3. `compute-sanitizer --tool memcheck` before other sanitizer tools.
4. `compute-sanitizer --tool racecheck` for shared/global memory race questions.
5. `compute-sanitizer --tool initcheck` for uninitialized device memory reads.
6. `compute-sanitizer --tool synccheck` for barrier and warp-synchronization hazards.

The Compute Sanitizer docs explicitly separate synchronization checks from memory access checks, so
`synccheck` should not replace `memcheck`.

## Profiling Order

- Use Nsight Systems first for end-to-end scheduling: CPU launch cost, CUDA API behavior, queue overlap,
  copies, stream usage, Vulkan/graphics queue timing, and NVTX ranges.
- Use Nsight Compute after a hot CUDA kernel is identified. Capture enough metrics to explain the
  bottleneck instead of collecting every metric by default.
- Use CUDA event timing for focused device-duration measurements and wall-clock timing for complete
  user-visible workflows.
- Keep profiler output under `artifacts/profiling/` or a project-specific ignored artifact directory.

## Benchmark Records

Every benchmark result should record:

- git revision or working-tree diff scope
- executable and exact arguments
- input data, dimensions, precision, and batch sizes
- GPU model, compute capability, driver, CUDA Toolkit, and relevant library versions
- CMake preset, build type, and `PROJECT_CUDA_ARCHITECTURES`
- median, p95, warmup count, iteration count, and measurement method
- profiler report path when profiler evidence was used

## CI Guidance

- Quick CI should compile and run deterministic smoke tests.
- Compute Sanitizer and profiling lanes belong on self-hosted GPU runners, usually scheduled or manually
  dispatched unless the project is small enough to run them for every PR.
- Do not enforce timing thresholds until the project has stable baselines for the exact runner hardware.
- Upload sanitizer/profiler logs as artifacts even on failure.
- Label GPU tests with CTest labels so `quick`, `gpu`, `cuda`, `compute`, `validation`, `perf`, and
  `nightly` lanes can be selected independently.

## Realtime GPU Selection

On multi-GPU Linux workstations, Ubuntu desktop/compositor behavior can make one visible GPU unsuitable
for realtime CUDA work even when build-only CUDA checks still pass. Treat runtime device selection as
part of the benchmark/test environment:

- Use `CUDA_VISIBLE_DEVICES=<physical-index>` for a known-good single GPU.
- Use `GPU_ALLOWED_INDICES=<physical-index-list>` with `scripts/select_idle_gpu.sh` when the project
  should choose the least busy GPU from an allowlist.
- Record the selected runtime GPU in benchmark and profiling notes.
- Do not hardcode a workstation-specific GPU index in reusable templates.
