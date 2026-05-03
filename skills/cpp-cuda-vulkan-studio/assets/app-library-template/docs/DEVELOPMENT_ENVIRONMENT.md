# Development Environment

This project follows the reusable Vulkan-first C++ studio backbone with explicit CUDA lanes.

Required baseline tools:

- CMake 3.25 or newer
- Ninja
- A C++20 compiler
- CUDA Toolkit when `PROJECT_ENABLE_CUDA=ON`
- Vulkan SDK 1.3 or newer when `PROJECT_ENABLE_VULKAN=ON`
- `glslc` and `spirv-val` for the default GLSL-to-SPIR-V shader workflow
- A Vulkan ICD/driver when running `vulkan`, `vulkan-compute`, or `vulkan-render` tests

Recommended GPU tools:

- `compute-sanitizer`
- `nsys`
- `ncu`
- Nsight Graphics or RenderDoc for graphics captures

Self-hosted GPU runner expectations live in [GPU_RUNNER_CI.md](GPU_RUNNER_CI.md). Keep driver,
CUDA Toolkit, Vulkan SDK, and profiler installation in the runner or developer environment rather
than inside project source.

Configure and build:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

The default `dev` preset enables Vulkan and leaves CUDA off. Use `cuda-debug` for CUDA-only work and
`cuda-vulkan-combined` only when a CUDA-selected lane intentionally needs Vulkan presentation,
realtime visualization, XR, or swapchain/display work. The combined preset proves both APIs can build
together; it does not implement CUDA/Vulkan external-memory or semaphore interop by itself.

The default CUDA architecture is `native`. For release artifacts or shared CI, set
`PROJECT_CUDA_ARCHITECTURES` to the explicit target SM list for the supported GPU fleet. Use the CUDA
Toolkit release notes and NVIDIA compute capability table before adding new architecture IDs.

For realtime CUDA runs on multi-GPU Linux systems, the display/compositor GPU may be unsuitable
even when it is visible to the driver. Pin runtime work explicitly with `CUDA_VISIBLE_DEVICES`, or set
`GPU_ALLOWED_INDICES` to the physical `nvidia-smi` GPU indexes that are allowed for realtime CUDA:

```bash
GPU_ALLOWED_INDICES=<physical-index> CUDA_VISIBLE_DEVICES="$(scripts/select_idle_gpu.sh)" ctest --preset cuda --output-on-failure
GPU_ALLOWED_INDICES=<physical-index> scripts/run_compute_sanitizer.sh
GPU_ALLOWED_INDICES=<physical-index> PROFILE_LANE=cuda BUILD_DIR=build/cuda-debug scripts/run_nsys_smoke.sh
```

`GPU_ALLOWED_INDICES` accepts comma, semicolon, or space separated physical indexes. The helper emits a
single physical index suitable for `CUDA_VISIBLE_DEVICES`.

The default Vulkan API target is `PROJECT_VULKAN_API_VERSION=1.3` with synchronization2 and dynamic
rendering. The SDK provides headers, shader tools, validation layers, and debugging tools, but it
does not install GPU drivers. Use:

```bash
scripts/check_dev_tools.sh
scripts/dump_vulkan_capabilities.sh
```

to distinguish SDK/tool availability from loader, ICD, physical-device, and queue-family runtime
availability. A build-only Vulkan lane can pass without proving a usable hardware device.
`scripts/check_dev_tools.sh` is Vulkan-first by default; use `REQUIRE_CUDA=1` only when validating
CUDA lanes, `REQUIRE_PROFILING=1` when validating Nsight Systems profiling, and
`REQUIRE_CUDA_PROFILING=1` only when validating Nsight Compute/CUDA profiling.

Nsight Systems report names and stats formats are version-specific. Before writing manual `nsys
stats` commands, check `nsys stats --help-reports` and `nsys stats --help`; prefer
`scripts/run_nsys_smoke.sh` because it discovers compatible reports for the active `PROFILE_LANE`.

Shader sources live in `shaders/`. Generated `.spv` files are build artifacts under the CMake binary
directory and should not be edited or committed unless a project intentionally vendors binary
assets. The default shader path is GLSL through `glslc`, followed by `spirv-val`.

For Apple/iOS-oriented work, treat MoltenVK as a named portability target. Configure the
`vulkan-portability` preset or set `PROJECT_ENABLE_VULKAN_PORTABILITY=ON` so the sample enables
`VK_KHR_portability_enumeration` and `VK_KHR_portability_subset` when the platform advertises them.

VMA is recommended for production Vulkan resource allocation policy, memory budget tracking,
staging, and readback paths. This template documents and checks for the SDK-provided VMA header, but
does not make VMA a required runtime dependency.
