# Mitsuba 3 Donor Profile

Source: https://github.com/mitsuba-renderer/mitsuba3  
Tier: `safe-donor`  
Backend signal: native-cpu, native-cuda
License signal: BSD-3-Clause style; inspect `LICENSE`, `ext/`, plugins, resources, tutorials,
Dr.Jit dependency notices, scenes, and datasets at the exact revision used.

## Use First For

- Differentiable rendering, inverse rendering, spectral/polarization rendering, retargetable renderer
  architecture, plugin systems, and research-grade light transport references.
- Comparing CPU, LLVM, CUDA, and OptiX-backed renderer variants.
- Behavior checks for gradients, differentiable materials, camera parameters, and inverse-rendering
  experiments.

## First Upstream Areas To Inspect

- `src/`, `include/mitsuba/`, `docs/`, `tutorials`, `resources/`, plugins, and tests.
- Dr.Jit integration and variant selection before adopting runtime or build patterns.
- Example scenes and notebooks only after license/provenance checks.
- Python package behavior when using Mitsuba as a reference-output donor.

## Integration Notes

- Use Mitsuba as a rendering research/reference donor; avoid making it a hidden dependency in native C++
  viewers.
- Keep differentiable/rendering math, plugin architecture, Python workflow, and GPU backend concerns
  separated.
- For Vulkan ports, treat CUDA/OptiX variants as reference behavior and translate implementation through
  Vulkan lane guidance.
- Prefer pbrt for classic physically based rendering pedagogy and Mitsuba for differentiable/retargetable
  rendering questions.

## Validation Ideas

- Test tiny scene render, camera derivative, material parameter derivative, and spectral/RGB variants
  only when relevant.
- Compare inverse-rendering or differentiable behavior with small deterministic fixtures.
- Record selected Mitsuba variant and Dr.Jit backend with every reference result.
- Keep Python notebook/reference-output tests separate from native runtime tests.

## Caveats

- Python-first and Dr.Jit-driven workflows can be dependency-heavy.
- CUDA/OptiX paths are NVIDIA-specific.
- Research examples and datasets are separate license surfaces.
