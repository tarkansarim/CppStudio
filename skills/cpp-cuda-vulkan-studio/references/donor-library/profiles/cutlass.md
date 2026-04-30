# CUTLASS Donor Profile

Source: https://github.com/NVIDIA/cutlass  
Tier: `safe-donor`  
Backend signal: native-cuda
License signal: BSD-3-Clause; inspect `LICENSE.txt`, `EULA.txt`, submodules, and third-party notices at
the exact revision used.

## Use First For

- GEMM, convolution, tensor-core, reduction, and epilogue design in C++ CUDA.
- CuTe layout/tensor concepts and hierarchical tiling policy.
- Architecture-specific CUDA kernel policy for Ampere, Ada, Hopper, and Blackwell.
- Benchmark/profiler patterns for matrix math kernels.

## First Upstream Areas To Inspect

- `examples/` for minimal integration patterns.
- `include/cutlass/` and `include/cute/` for reusable C++ abstractions.
- `tools/profiler/` for benchmark and kernel-selection patterns.
- CUTLASS docs for quick start, GEMM API, CuTe, functionality, and programming guidelines.

## Integration Notes

- Prefer using CUTLASS as a dependency or adapting a small concept. Do not copy broad template trees into
  a target repo.
- Translate donor architecture flags into the target repo's `PROJECT_CUDA_ARCHITECTURES` policy.
- Preserve a reference CPU or library result when adapting a CUTLASS-style kernel.
- Run small shape tests, odd shape tests, and representative production shapes before making performance
  claims.

## Validation Ideas

- Compare against cuBLAS/cuBLASLt or a CPU reference for deterministic small cases.
- Run Compute Sanitizer on narrow test shapes before large performance shapes.
- Benchmark against a library baseline before adopting a custom CUTLASS-derived kernel.
- Capture Nsight Compute only after a specific kernel is identified as hot.

## Caveats

- CUTLASS architecture-accelerated targets such as Hopper/Blackwell `a` variants are not interchangeable
  with generic SM targets.
- CUTLASS release notes and compatibility tables can move faster than local CUDA/CMake installations.
- Some examples depend on newer hardware or toolkit behavior. Verify the donor's own build matrix before
  making it a reusable project dependency.
