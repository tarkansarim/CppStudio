# Embree Donor Profile

Source: https://github.com/RenderKit/embree  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: Apache-2.0; inspect `LICENSE.txt`, third-party program notices, tutorials, tests,
and optional oneAPI/TBB-related dependency notices at the exact revision used.

## Use First For

- CPU ray tracing kernels, BVH build/traversal APIs, ray/geometry intersection behavior, and robust
  acceleration-structure testing.
- Offline validation of renderer or geometry pipelines before implementing GPU acceleration.
- High-performance CPU reference paths for ray queries, visibility, path tracing, and collision-adjacent
  geometry checks.

## First Upstream Areas To Inspect

- `include/embree4/` for public API and scene/geometry ownership.
- `kernels/` for architecture ideas only; prefer API use over copying internals.
- `tutorials/`, `tests/`, and `doc/` for minimal scenes, ray packets, motion blur, instancing, and
  geometry edge cases.
- Third-party program notice files before linking or vendoring.

## Integration Notes

- Use Embree as a dependency candidate or CPU reference, not a small snippet donor.
- Keep CPU acceleration structures separate from Vulkan ray tracing acceleration structures.
- Preserve coordinate, winding, motion, instance, and geometry-type conventions in tests.
- For Vulkan/CUDA targets, use Embree output as a validation reference unless the project deliberately
  ships a CPU ray tracing path.

## Validation Ideas

- Compare ray hits/misses on tiny triangle, quad, sphere/curve, instance, and motion fixtures.
- Test degenerate triangles, NaNs, zero-area geometry, and large coordinate ranges.
- Cross-check GPU ray query or BVH results against Embree for a small deterministic scene.
- Label CPU reference tests separately from GPU render tests.

## Caveats

- Embree is dependency-scale and CPU-oriented.
- SIMD, threading, and optional dependencies affect reproducibility and deployment.
- Do not assume Embree BVH internals map directly onto Vulkan or CUDA acceleration structures.
