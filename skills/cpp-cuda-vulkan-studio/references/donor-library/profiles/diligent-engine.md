# Diligent Engine Donor Profile

Source: https://github.com/DiligentGraphics/DiligentEngine  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0 for the main repository; inspect `License.txt`, module third-party
dependency notices, submodules, samples, and asset licenses at the exact revision used.

## Use First For

- Cross-API renderer abstraction over Vulkan, Direct3D, Metal, OpenGL, WebGPU, and platform surfaces.
- Render-state packaging, shader/resource binding models, render passes, bindless resources, and
  higher-level rendering components.
- Comparing glTF viewer, USD viewer, PBR renderer, OpenXR, ray tracing, and compute tutorial patterns.

## First Upstream Areas To Inspect

- `DiligentCore`, `DiligentTools`, `DiligentFX`, and `Samples` modules for dependency boundaries.
- Tutorial samples for buffers, textures, render targets, compute, bindless resources, mesh shaders,
  ray tracing, and OpenXR.
- High-level rendering components for glTF loader, PBR renderer, post-processing, and Hydra/USD work.
- Module third-party notices before adopting any component.

## Integration Notes

- Use Diligent when the target project explicitly wants renderer abstraction or multi-backend policy.
- For Vulkan-only projects, borrow API-boundary concepts without hiding Vulkan feature, extension, and
  synchronization policy behind an abstraction too early.
- Keep DiligentFX/high-level components as optional dependency choices; they are broader than a minimal
  renderer backbone.
- Preserve target-project shader language and package-manager policy instead of copying Diligent's full
  build ecosystem by default.

## Validation Ideas

- Exercise a tiny triangle, texture upload, offscreen render target, and compute tutorial path.
- Add backend-selection tests that fail clearly when a backend or device feature is unavailable.
- Compare glTF/PBR sample output against a tiny known-good asset before adding production assets.
- Keep CTest labels for render, compute, shader, validation, XR, and backend-specific lanes.

## Caveats

- The repository is modular but large; exact module choices matter.
- Third-party dependencies differ by module and sample.
- Abstraction can obscure lane policy. Keep Vulkan or CUDA implementation choices explicit in target
  build options and docs.
