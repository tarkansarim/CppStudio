# Validation Pipeline

Recommended local gate:

```bash
scripts/check_dev_tools.sh
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

Self-hosted CI runner expectations and artifact paths are documented in
[GPU_RUNNER_CI.md](GPU_RUNNER_CI.md).

Host sanitizer gate:

```bash
cmake --preset asan-ubsan
cmake --build --preset asan-ubsan
ctest --preset asan-ubsan-quick --output-on-failure
```

The `asan-ubsan` preset uses ASan+UBSan on Clang/GCC-style toolchains. On MSVC it enables
AddressSanitizer only because MSVC does not provide the same UBSan lane.

GPU gate:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset gpu --output-on-failure
```

CUDA sanitizer gate:

```bash
cmake --preset cuda-debug
cmake --build --preset cuda-debug
scripts/run_compute_sanitizer.sh
```

When only a subset of physical GPUs is usable for realtime CUDA work, set `CUDA_VISIBLE_DEVICES`
directly or use the helper allowlist:

```bash
GPU_ALLOWED_INDICES=<physical-index> CUDA_VISIBLE_DEVICES="$(scripts/select_idle_gpu.sh)" ctest --preset cuda --output-on-failure
GPU_ALLOWED_INDICES=<physical-index> scripts/run_compute_sanitizer.sh
```

Vulkan shader gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan-shader --output-on-failure
```

Vulkan runtime gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan --output-on-failure
```

Vulkan validation gate:

```bash
cmake --preset vulkan-validation
cmake --build --preset vulkan-validation
scripts/run_vulkan_validation.sh
```

Run `ctest --preset vulkan-compute` for compute dispatch coverage and
`ctest --preset vulkan-render` for the headless offscreen dynamic-rendering smoke test. These lanes
require a usable Vulkan ICD with a Vulkan 1.3 physical device, synchronization2, dynamic rendering,
and a graphics+compute queue.

Benchmark smoke gate:

```bash
cmake --preset benchmark
cmake --build --preset benchmark
ctest --preset benchmark --output-on-failure
```

GPU optimization loop:

```bash
scripts/run_gpu_optimization_loop.py init --session opt-session --targets docs/GPU_OPTIMIZATION_TARGETS.tsv
scripts/run_gpu_optimization_loop.py baseline --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py profile --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py breaking-point --session opt-session --target-id <target> --param-name <name> --min <n> --max <n> --threshold <metric-threshold> --direction lower --cmd '<benchmark using {value}>'
scripts/run_gpu_optimization_loop.py plan-round --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py hypothesis --session opt-session --target-id <target> --hypothesis-id H1 --confidence medium --summary "<hypothesis>" --evidence "<profile or code evidence>" --expected-effect "<expected metric effect>"
scripts/run_gpu_optimization_loop.py attempt --session opt-session --target-id <target> --round-id <round> --worker-id <worker> --tag <tag> --hypothesis-id H1 --description "<focused change>" --auto-revert
scripts/run_gpu_optimization_loop.py report --session opt-session
```

The loop is for deliberate performance sessions, not the default CI gate. It writes ignored
artifacts under `artifacts/optimization/`; use [GPU_OPTIMIZATION_LOOP.md](GPU_OPTIMIZATION_LOOP.md)
for the target-table schema, success-criteria gate, hypothesis log, profiler/SOL contract,
breaking-point search, benchmark contract, repeated validation passes, beam-round planning, and
keep/revert rules.

Use `scripts/dump_vulkan_capabilities.sh` when a Vulkan runtime lane fails before changing code. The
failure class matters: missing SDK tools, missing loader, missing ICD, no physical devices,
unsupported API version, unavailable features, shader validation failure, and validation-layer
messages are different problems.

Profiling smoke gate:

```bash
scripts/run_nsys_smoke.sh
```

The profiler smoke defaults to the Vulkan app path and requires `nsys`. Use
`REQUIRE_CUDA_PROFILING=1 PROFILE_LANE=cuda BUILD_DIR=build/cuda-debug scripts/run_nsys_smoke.sh`
when CUDA profiling also requires Nsight Compute tooling. Use `GPU_ALLOWED_INDICES=<physical-index>`
when CUDA profiling must avoid display-bound GPUs.

`run_nsys_smoke.sh` treats the `.nsys-rep` file as the primary artifact, then queries the installed
Nsight Systems CLI for supported stats reports and output formats before reading summaries. Do not
assume legacy report names such as `summary` or unsupported formats such as `text`; report names vary
between Nsight Systems versions. Override the auto-selected summaries only after checking the local
tool:

```bash
nsys stats --help-reports
nsys stats --help
PROFILE_LANE=vulkan NSYS_STATS_REPORTS=vulkan_api_sum,nvtx_sum,osrt_sum scripts/run_nsys_smoke.sh
PROFILE_LANE=cuda NSYS_STATS_REPORTS=cuda_api_gpu_sum,cuda_gpu_kern_sum,nvtx_sum,osrt_sum scripts/run_nsys_smoke.sh
```

Benchmark and profiling result records should follow [BENCHMARKS.md](BENCHMARKS.md). Do not add
timing thresholds to CI until baselines are recorded for the exact runner hardware.

Vulkan debugging order:

1. Run with validation first.
2. Fix or classify validation messages.
3. Capture with RenderDoc or Nsight Graphics when visible render output or event order needs
   inspection.
4. Use Nsight Systems only for whole-frame CPU/GPU scheduling and overlap questions.

GUI or windowed tests must go through the project-approved offscreen/background launcher when the
repo defines one. Do not add foreground GUI automation to CI by default.
