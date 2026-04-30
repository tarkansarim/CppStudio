# Taichi Donor Profile

Source: https://github.com/taichi-dev/taichi  
Tier: `dependency-candidate`  
Backend signal: mixed-backend, native-cpu, native-cuda, native-vulkan
License signal: Apache-2.0; inspect `LICENSE`, third-party dependency manifests, backend components,
examples, and package metadata at the exact revision used.

## Use First For

- Portable CPU/GPU simulation DSL workflows from Python.
- Rapid prototyping of differentiable physical simulation, sparse computation, particles, fluids, cloth,
  and geometry-heavy kernels.
- Comparing backend-portable simulation designs before committing to CUDA-only or Vulkan-only kernels.
- Education and experiment structure for GPU programming in Python.

## First Upstream Areas To Inspect

- Language/runtime docs for kernel, field, autodiff, sparse, and backend semantics.
- Examples and tests for simulation patterns, sparse data, differentiable programming, and portability.
- Backend support notes before relying on CUDA, Vulkan, Metal, OpenGL, or CPU behavior.
- Packaging/build docs for dependencies and platform constraints.

## Integration Notes

- Treat Taichi as a Python simulation/prototyping dependency unless the target project intentionally
  embeds that runtime.
- Keep Taichi kernels and generated artifacts outside reusable C++ templates.
- Preserve CPU reference fixtures and backend-specific tolerances when comparing outputs.
- Record backend and version context because behavior and performance can vary by backend.

## Validation Ideas

- Run small CPU and GPU fixtures with fixed inputs and compare against checked numeric references.
- Test sparse-grid, boundary, and zero-element cases separately from performance examples.
- Compare differentiable gradients against finite differences on tiny problems.
- Benchmark only after JIT warmup and backend selection are explicit.

## Caveats

- Taichi is a productive experiment lane, not a drop-in native C++ simulation library.
- Backend coverage and performance differ by platform and feature.
- Example assets, notebooks, and generated outputs need separate provenance checks before reuse.
