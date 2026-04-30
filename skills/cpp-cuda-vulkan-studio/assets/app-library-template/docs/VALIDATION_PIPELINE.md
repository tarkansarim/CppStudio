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

GPU gate:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset gpu --output-on-failure
scripts/run_compute_sanitizer.sh
```

When only a subset of physical GPUs is usable for realtime CUDA work, set `CUDA_VISIBLE_DEVICES`
directly or use the helper allowlist:

```bash
GPU_ALLOWED_INDICES=1 CUDA_VISIBLE_DEVICES="$(scripts/select_idle_gpu.sh)" ctest --preset gpu --output-on-failure
GPU_ALLOWED_INDICES=1 scripts/run_compute_sanitizer.sh
```

Vulkan shader gate:

```bash
cmake --preset dev
cmake --build --preset dev
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
require a usable Vulkan ICD with a Vulkan 1.4 physical device and a graphics+compute queue.

Use `scripts/dump_vulkan_capabilities.sh` when a Vulkan runtime lane fails before changing code. The
failure class matters: missing SDK tools, missing loader, missing ICD, no physical devices,
unsupported API version, unavailable features, shader validation failure, and validation-layer
messages are different problems.

Profiling smoke gate:

```bash
scripts/run_nsys_smoke.sh
```

Use `GPU_ALLOWED_INDICES=... scripts/run_nsys_smoke.sh` when profiling must avoid display-bound GPUs.

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
