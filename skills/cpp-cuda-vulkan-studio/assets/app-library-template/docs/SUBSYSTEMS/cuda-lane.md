# CUDA Lane

Explicit CUDA-only work, kernels, launch wrappers, CUDA architecture policy, and Compute Sanitizer
lanes.

## Canonical Docs

- `docs/DEVELOPMENT_ENVIRONMENT.md`
- `docs/VALIDATION_PIPELINE.md`

## Primary Paths

- `src/cuda/`
- `include/*/cuda_vector_add.hpp`

## Update When

- CUDA kernels, launch wrappers, architecture policy, CUDA tests, sanitizer commands, or runtime GPU
  selection behavior changes
- CUDA becomes required by a feature that was previously Vulkan-only
- CUDA/Vulkan combined-lane boundaries change
