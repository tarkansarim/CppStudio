# pbrt-v4 Donor Profile

Source: https://github.com/mmp/pbrt-v4  
Tier: `safe-donor`  
Backend signal: native-cpu, native-cuda
License signal: Apache-2.0; inspect `LICENSE.txt`, `THIRD_PARTY.md`, scene repositories, images,
OptiX/GPU components, and external asset licenses at the exact revision used.

## Use First For

- Physically based rendering algorithms, sampling, materials, lights, integrators, camera models, scene
  description, spectral/color decisions, and CPU/GPU path-tracing architecture.
- Reference behavior for renderer correctness tests, path-tracing math, and scene-format design.
- Comparing offline renderer structure against realtime Vulkan or CUDA renderers.

## First Upstream Areas To Inspect

- `src/pbrt/`, integrators, materials, lights, shapes, cameras, filters, samplers, and film code.
- GPU build paths and OptiX-related helpers only when NVIDIA GPU rendering is in scope.
- Scene description docs, user guide, and official scene repositories before using fixtures.
- `THIRD_PARTY.md` before copying implementation or sample scenes.

## Integration Notes

- Use pbrt primarily as an algorithm/reference donor, not a dependency for realtime viewers.
- Keep offline scene parsing, renderer math, GPU acceleration, denoising, and asset fixtures separated.
- For Vulkan projects, translate rendering algorithms and tests through Vulkan ray tracing or compute
  guidance instead of adding CUDA/OptiX by default.
- Cite exact algorithm or fixture consulted when adapting concepts.

## Validation Ideas

- Add tiny Cornell-box-like, sphere, triangle, material, texture, and light fixtures.
- Compare CPU/reference outputs with tolerant image metrics and deterministic seeds.
- Test sampling edge cases, NaNs, extreme radiance, empty scenes, and invalid scene descriptions.
- Keep denoiser/GPU build tests separate from algorithmic correctness tests.

## Caveats

- Offline renderer quality and realtime frame-time goals are different.
- Official scenes, images, and third-party data have separate licenses.
- GPU/OptiX paths are NVIDIA-specific and should not silently change target lanes.
