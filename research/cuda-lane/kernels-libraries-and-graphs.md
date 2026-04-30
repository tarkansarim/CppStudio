# CUDA Kernels, Libraries, Graphs, And Interop

Last researched: 2026-04-30

## Library-First Order

Before authoring a custom CUDA kernel, check whether the operation fits:

1. cuBLAS/cuBLASLt, cuDNN, cuFFT, cuSPARSE, NPP, nvJPEG, CUB, Thrust, or libcu++.
2. CUTLASS for reusable GEMM/convolution/reduction building blocks and tiling policy examples.
3. FlashAttention for exact attention and IO-aware fused attention patterns.
4. Triton when a Python-authored kernel DSL and compiler stack fits the target repo.
5. A hand-written kernel only when the operation, data layout, integration constraints, or dependency
   policy requires it.

## Streams And Events

- Use explicit streams for overlap only after correctness is established on a simple single-stream path.
- Use CUDA events for GPU timing and dependency edges; use host wall-clock only for end-to-end workflow
  measurements.
- Keep stream ownership clear at API boundaries. A function that accepts a stream should not silently
  synchronize the device unless its contract says so.
- Avoid default-stream assumptions in reusable libraries; they make later overlap and graph capture
  difficult.

## CUDA Graphs

- Use CUDA Graphs for repeated launch sequences with stable topology and high launch overhead.
- Keep a normal stream/event implementation path understandable before capturing or manually building a
  graph.
- Validate graph-update constraints when sizes, pointers, or launch parameters can change.
- Pair graph adoption with a benchmark record and Nsight Systems trace; graph use without measured
  launch overhead is usually speculative.

## Memory Pools And Transfers

- Prefer stream-ordered allocation patterns such as `cudaMallocAsync` only when lifetime and stream
  ordering are explicit.
- Track host-pinned memory separately from ordinary host memory; pinned allocations are a scarce
  system resource and can hurt paging behavior.
- Separate staging, device-resident, unified memory, and imported external memory in code and docs.
- For library code, return errors instead of hiding allocation failure behind global synchronization.

## CUDA/Vulkan Interop

- Match CUDA and Vulkan devices explicitly. Use UUID/LUID matching where the platform requires it.
- Treat imported Vulkan memory and semaphores as external resources with clear lifetime ownership,
  synchronization, layout, and queue-family rules.
- Keep CUDA kernel tests separate from Vulkan validation tests, then add interop tests that prove the
  bridge only after both sides pass independently.
- Start with official CUDA external resource interop docs and Khronos Vulkan samples before using
  vendor-specific extension samples.

## Donor Selection

- CUTLASS: first donor for C++ CUDA matrix math and tiling.
- FlashAttention: first donor for exact attention and IO-aware kernel organization.
- Triton: first donor for DSL/compiler-based ML kernels when Python runtime is acceptable.
- gsplat: first permissive donor for CUDA Gaussian splatting rasterization.
- Khronos Vulkan-Samples: first Vulkan correctness donor.
- NVIDIA vk_mini_samples: first NVIDIA-specific Vulkan extension/tooling donor.
