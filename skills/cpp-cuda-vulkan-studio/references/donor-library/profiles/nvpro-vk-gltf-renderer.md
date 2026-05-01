# nvpro Vulkan glTF Renderer Donor Profile

Source: https://github.com/nvpro-samples/vk_gltf_renderer  
Tier: `dependency-candidate`  
Backend signal: native-vulkan
License signal: Apache-2.0 core signal; inspect `LICENSE`, third-party dependencies, resources, scene
assets, DLSS/OptiX/CUDA paths, and downloaded packages at the exact revision used.

## Use First For

- Production-scale Vulkan ray tracing and path tracing around glTF 2.0 scenes.
- PBR materials, HDR environments, scene editing, raster fallback, path tracing, and denoising integration.
- BLAS/TLAS scene ownership, renderer resource lifetime, timeline pacing, and headless/batch behavior.
- Slang-based shader organization in a Vulkan renderer.

## First Upstream Areas To Inspect

- `docs/RENDERING_ARCHITECTURE.md` for data flow and renderer ownership.
- `docs/developer.md` and `docs/user-guide.md` for architecture and feature behavior.
- `src/renderer_pathtracer.cpp` for path-tracing shell and resource usage.
- `src/gltf_scene_rtx.cpp` for acceleration-structure scene ownership.
- `src/dlss_wrapper.cpp` for optional DLSS integration.
- `shaders/` for Slang shader organization and PBR/path-tracing flow.

## Integration Notes

- Treat this as a renderer-scale architecture donor, not a minimal dependency.
- Keep glTF import, scene editing, raster preview, path tracing, denoising, and OptiX/CUDA features as
  separable project choices.
- For a Vulkan-first project, borrow renderer ownership and validation patterns without automatically
  adding NVIDIA-only denoising or CUDA/OptiX dependencies.
- Use smaller glTF loaders or meshoptimizer when only asset import is needed.

## Validation Ideas

- Build small glTF fixture scenes for static meshes, materials, cameras, environment maps, animation, and
  missing assets.
- Add separate CTest labels for raster preview, raw RT/path tracing, denoising, headless capture, and
  scene save/load.
- Run validation layers and one graphics-debugger capture before trusting final images.
- Profile steady-state frame time without hidden `waitForIdle()` or readback costs.

## Caveats

- The project is dependency-heavy and feature-rich; avoid importing its architecture wholesale into small
  viewers.
- DLSS, OptiX, CUDA, scene resources, and third-party packages have separate license/runtime surfaces.
