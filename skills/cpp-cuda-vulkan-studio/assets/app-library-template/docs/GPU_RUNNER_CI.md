# GPU Runner CI

This project expects GPU-dependent GitHub Actions jobs to run on self-hosted Linux runners. Hosted
runners are acceptable for lint-only or build-only lanes only when CUDA/Vulkan runtime tests are
disabled.

## Runner Labels

The default workflow uses:

```text
self-hosted, linux, cuda, vulkan, gpu
```

Use narrower labels when a runner only supports one lane:

- `cuda`: CUDA Toolkit, NVIDIA driver, and CUDA runtime tests are available.
- `vulkan`: Vulkan SDK tools, loader, ICD, validation layers, and a usable Vulkan physical device are available.
- `gpu`: a physical GPU is attached and available to the runner.
- `profile`: optional label for runners allowed to produce profiling artifacts.

## Required Tools

- CMake 3.25 or newer
- C++20 compiler
- CUDA Toolkit when CUDA jobs are enabled
- NVIDIA driver compatible with the selected CUDA Toolkit
- Vulkan SDK 1.4 or newer when Vulkan jobs are enabled
- `glslc`, `spirv-val`, and `vulkaninfo`
- `compute-sanitizer` for scheduled/manual CUDA sanitizer jobs
- `nsys` for profiling smoke jobs
- `ncu`, RenderDoc, or Nsight Graphics on profiling/debug workstations when deeper analysis is needed

## Environment Policy

- Set `PROJECT_CUDA_ARCHITECTURES` explicitly for CI and release builds. Avoid relying on `native` for
  artifacts that represent more than one machine.
- The default workflow reads the GitHub repository variable `PROJECT_CUDA_ARCHITECTURES` and falls back
  to `native` for single-machine smoke lanes.
- For realtime CUDA lanes on multi-GPU Linux runners, set `CUDA_VISIBLE_DEVICES` directly or set
  `GPU_ALLOWED_INDICES` to the physical `nvidia-smi` indexes that the runner may use. This avoids
  accidentally running latency-sensitive CUDA work on a display/compositor-bound GPU.
- Keep Vulkan SDK environment setup in the runner image or runner service configuration, not inside
  project source.
- Keep driver installation outside the repo. The Vulkan SDK does not install GPU drivers.
- Use project scripts to classify tool gaps before changing code:

```bash
scripts/check_dev_tools.sh
scripts/dump_vulkan_capabilities.sh
```

## Lane Matrix

| Lane | Trigger | Purpose | Artifact Policy |
| --- | --- | --- | --- |
| `toolcheck` | push/PR | Detect missing compilers, SDKs, drivers, shader tools, and profilers. | Logs only. |
| `build-dev` | push/PR | Compile default development preset. | Logs only. |
| `quick-tests` | push/PR | Run fast deterministic CPU/CUDA/Vulkan smoke tests. | Logs on failure. |
| `gpu-smoke` | push/PR or manual | Run CTest GPU labels on attached hardware. | Logs on failure. |
| `vulkan-shader` | push/PR | Compile and validate SPIR-V shader assets. | Logs on failure. |
| `vulkan-runtime` | push/PR or manual | Prove a usable Vulkan device and runtime paths. | Capability dump on failure. |
| `vulkan-validation` | schedule/manual | Run validation-layer wrapped Vulkan tests. | Upload `artifacts/vulkan/`. |
| `compute-sanitizer` | schedule/manual | Run CUDA tests under Compute Sanitizer. | Upload `artifacts/sanitizer/`. |
| `profile-smoke` | schedule/manual | Prove profiler tools can produce readable reports. | Upload `artifacts/profiling/`. |

## Failure Classification

- Missing SDK/tool: fix the runner image or environment.
- Missing driver/ICD/device: fix machine provisioning or runner labels.
- Wrong GPU selected for realtime CUDA: set `CUDA_VISIBLE_DEVICES` or `GPU_ALLOWED_INDICES` in the
  runner/job environment.
- Unsupported CUDA architecture: update `PROJECT_CUDA_ARCHITECTURES` or runner/toolkit policy.
- Vulkan validation message: fix or explicitly classify the Vulkan code path.
- Compute Sanitizer error: fix the CUDA code path before profiling.
- Timing drift without a recorded baseline: upload evidence, do not fail CI solely on timing.
