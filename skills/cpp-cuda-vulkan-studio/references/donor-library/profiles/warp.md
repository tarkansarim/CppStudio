# NVIDIA Warp Donor Profile

Source: https://github.com/NVIDIA/warp  
Tier: `dependency-candidate`  
Backend signal: native-cuda, native-cpu
License signal: Apache-2.0 for Warp, with additional third-party downloads and NVIDIA libmathdx license
surfaces called out by upstream; inspect `LICENSE.md`, `licenses/`, build scripts, package metadata, and
example assets at the exact revision used.

## Use First For

- Python-authored CUDA kernels for simulation, robotics, geometry processing, and differentiable physics.
- Rapid GPU simulation prototyping where Python/JIT tooling is acceptable.
- Differentiable kernels that need to integrate with PyTorch, JAX, or similar ML pipelines.
- GPU particle, mesh, volume, FEM, fluid, optimization, and spatial computing examples.

## First Upstream Areas To Inspect

- `warp/` for core kernel language, array, type, launch, autodiff, and runtime behavior.
- `warp/examples/` for physics, FEM, fluids, mesh, volume, optimization, graph capture, and tile examples.
- `docs/` and notebooks for supported patterns and current API behavior.
- Build scripts and `licenses/` before adopting source-build or packaged binary assumptions.

## Integration Notes

- Treat Warp as a Python/JIT dependency, not a default C++ engine runtime dependency.
- Keep simulation kernel prototypes, generated outputs, ML training data, and runtime C++ code separated.
- Record CUDA driver, GPU, Warp version, and optional dependency versions for benchmark claims.
- If the final project needs native C++ kernels, use Warp as a behavior/prototype donor and port the
  kernel intentionally with reference tests.

## Validation Ideas

- Run a tiny deterministic particle or spring fixture on CPU and CUDA and compare positions/energy within
  explicit tolerances.
- Test gradient/autodiff behavior separately from forward simulation when differentiability is the point.
- Compare a Warp prototype against a project-native CPU reference before porting to CUDA C++.
- Capture generated USD/example outputs only as small, license-tracked fixtures.

## Caveats

- Source builds and packages can involve downloaded third-party components with separate terms.
- Python/JIT startup and compilation costs can dominate small workloads.
- Warp examples are excellent prototypes, but do not assume they match a target C++ engine's memory,
  scheduling, or asset ownership model.
