# bgfx Donor Profile

Source: https://github.com/bkaradzic/bgfx  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: BSD-2-Clause for bgfx core; inspect `LICENSE`, bundled examples, tools, shaderc,
bx/bimg dependencies, third-party libraries, and assets at the exact revision used.

## Use First For

- Bring-your-own-engine renderer abstraction, platform/window integration boundaries, and multi-backend
  graphics API handling.
- Shader toolchain organization, runtime renderer caps, transient buffers, views, frame submission, and
  example-driven graphics feature coverage.
- Lightweight engine integration patterns when a target app needs rendering without adopting a full
  scene engine.

## First Upstream Areas To Inspect

- `examples/` for focused feature and integration samples.
- `src/`, `include/`, and renderer backends for API abstraction and submission boundaries.
- `tools/`, shader compiler integration, and `3rdparty/` before copying build or toolchain ideas.
- bx and bimg dependency shape when evaluating package-manager integration.

## Integration Notes

- Treat bgfx as a dependency decision, not a set of small snippets.
- For Vulkan-first projects, keep Vulkan validation, shader compilation, and feature checks visible even
  if bgfx abstracts runtime rendering.
- Use examples to study renderer-facing data flow, not to replace target project scene ownership.
- Keep shader source, compiled outputs, and backend selection testable per platform.

## Validation Ideas

- Build and run a minimal example with the chosen backend and validation where available.
- Add a backend-capability dump and clear failure when Vulkan, D3D, Metal, or OpenGL support is absent.
- Test shader compilation errors and missing compiled-shader artifacts.
- Compare a tiny mesh/texture render path before adding complex assets.

## Caveats

- bgfx intentionally abstracts graphics APIs; that is useful only when multi-backend support is a real
  goal.
- Toolchain dependencies and bundled third-party code need separate license review.
- Backend abstraction does not remove the need for explicit target-project render, shader, and asset
  ownership.
