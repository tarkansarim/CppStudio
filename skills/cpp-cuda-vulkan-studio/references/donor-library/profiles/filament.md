# Google Filament Donor Profile

Source: https://github.com/google/filament  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0 for core code; inspect `LICENSE`, `third_party/`, tools, sample assets,
and release-package notices at the exact revision used.

## Use First For

- Realtime PBR renderer architecture, material systems, tone mapping, image-based lighting, and glTF
  viewer/runtime organization.
- Cross-platform renderer backend separation across Vulkan, OpenGL, Metal, WebGPU, WebGL, and mobile.
- Asset-pipeline boundaries between runtime library, offline tools, compiled materials, and packaged
  environment/texture assets.

## First Upstream Areas To Inspect

- `filament/`, `libs/`, and `shaders/` for renderer and material architecture.
- `samples/` and `libs/filamentapp/` for app integration and window/swapchain setup.
- `tools/`, `matc`, `cmgen`, and `gltfio` for material, environment, texture, and glTF pipeline shape.
- `third_party/`, packaged assets, and release archives before copying or vendoring.

## Integration Notes

- Treat Filament as a renderer dependency or architecture donor, not a snippet source for small apps.
- Keep material compilation and runtime rendering version-locked if consuming Filament tools.
- For Vulkan-first projects, borrow renderer/module boundaries without adopting non-Vulkan backends
  unless the target repo wants a multi-backend renderer.
- Keep Filament glTF handling separate from generic glTF loader selection unless adopting Filament as
  the renderer.

## Validation Ideas

- Render a tiny glTF or primitive scene offscreen and compare image hashes or golden screenshots.
- Test material compilation, runtime material loading, and missing-resource failures separately.
- Verify backend selection and capability errors on Vulkan, headless, and windowed environments.
- Add fixtures for linear/sRGB color, IBL availability, skinning, and texture-extension coverage.

## Caveats

- The ecosystem is tool-heavy; runtime and tool versions must match.
- Sample assets, environment maps, and texture inputs have separate license surfaces.
- A full renderer dependency can dominate project architecture; do not add it for simple import/viewer
  prototypes without an explicit dependency decision.
