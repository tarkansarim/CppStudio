# CUDA Lane Source Map

Last researched: 2026-04-30

## Official CUDA And Toolchain Sources

| Source | URL | Use |
| --- | --- | --- |
| CUDA Toolkit Release Notes | https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/ | Current toolkit, driver compatibility, CUDA library release notes, deprecations, known issues. |
| CUDA C++ Programming Guide | https://docs.nvidia.com/cuda/cuda-c-programming-guide/index.html | Streams, graphs, memory hierarchy, runtime model, CUDA/Vulkan external resource interop. |
| CUDA Runtime API | https://docs.nvidia.com/cuda/cuda-runtime-api/index.html | Runtime calls, error handling, memory, streams, events, graphs, device management. |
| CUDA C++ Best Practices Guide | https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/index.html | Assess/parallelize/optimize/deploy workflow, profiling, memory throughput, occupancy, deployment compatibility. |
| Compute Sanitizer | https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html | `memcheck`, `racecheck`, `initcheck`, `synccheck`, suppression, and report behavior. |
| Nsight Systems User Guide | https://docs.nvidia.com/nsight-systems/2025.3/UserGuide/index.html | Whole-application timeline, CPU/GPU scheduling, API trace, NVTX ranges, report/stat handling. |
| Nsight Compute User Guide | https://docs.nvidia.com/nsight-compute/2025.3/NsightCompute/index.html | CUDA kernel profiler, report comparison, metric collection, rule-based analysis. |
| CUDA GPU Compute Capability | https://developer.nvidia.com/cuda-gpus | Mapping from GPU products to compute capability, including Blackwell data-center, workstation, consumer, Jetson, and DGX Spark devices. |
| CMake `CMAKE_CUDA_ARCHITECTURES` | https://cmake.org/cmake/help/latest/variable/CMAKE_CUDA_ARCHITECTURES.html | Project-level default for target `CUDA_ARCHITECTURES`; CMake recommends overriding compiler/version-dependent defaults. |
| CMake `CUDA_ARCHITECTURES` target property | https://cmake.org/cmake/help/latest/prop_tgt/CUDA_ARCHITECTURES.html | Target code-generation architecture list and special values such as `native`, `all`, and `all-major`. |
| CMake policy `CMP0104` | https://cmake.org/cmake/help/latest/policy/CMP0104.html | Empty CUDA architecture handling and compatibility behavior. |

## Donor Sources

| Source | URL | Use |
| --- | --- | --- |
| CUTLASS | https://github.com/NVIDIA/cutlass | CUDA GEMM/convolution/reduction templates, CuTe layout model, Blackwell/Hopper/Ampere kernel policy examples. |
| FlashAttention | https://github.com/Dao-AILab/flash-attention | IO-aware attention kernels, CUDA/PyTorch extension layout, attention benchmarks and tests. |
| Triton | https://github.com/triton-lang/triton | Python-authored GPU kernels, MLIR compiler stack, custom deep-learning primitive design. |
| gsplat | https://github.com/nerfstudio-project/gsplat | CUDA Gaussian splatting rasterization, Python bindings, neural 3D operator packaging. |
| Khronos Vulkan-Samples | https://github.com/KhronosGroup/Vulkan-Samples | Vulkan correctness and best-practice samples to pair with CUDA/Vulkan interop or render lanes. |
| NVIDIA vk_mini_samples | https://github.com/nvpro-samples/vk_mini_samples | NVIDIA Vulkan extension/tooling samples, ray tracing, descriptor heap, shader printf, offscreen rendering. |

## Current-Version Notes

- CUDA Toolkit release notes currently identify CUDA 13.2 Update 1 as the current release line in the
  primary documentation URL. The same release notes list Linux driver compatibility for 13.2 Update 1
  and include library-specific caveats, including cuBLAS patch notes.
- CUDA 13.x release notes are active versioned documents. Before installing or pinning CUDA 13.2 for
  a project, inspect the exact release note date, driver row, and any relevant cuBLAS/cuFFT/cuSPARSE
  known issues.
- Compute capability mappings now distinguish Blackwell data-center IDs, Blackwell RTX/workstation
  IDs, Jetson Thor IDs, and DGX Spark IDs. Do not collapse all Blackwell targets into one architecture
  number.
