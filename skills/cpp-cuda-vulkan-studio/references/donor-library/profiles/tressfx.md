# AMD TressFX Donor Profile

Source: https://github.com/GPUOpen-Effects/TressFX  
Tier: `safe-donor`  
Backend signal: native-vulkan, native-directx
License signal: MIT; inspect `license.txt`, bundled Cauldron code, sample assets, exporters, and
third-party notices at the exact revision used.

## Use First For

- Realtime GPU hair and fur simulation and rendering.
- Strand storage, skinning, guide/follow behavior, LOD, and collision-field concepts.
- Vulkan or DirectX 12 sample structure for integrating hair into an engine render loop.
- Production-facing grooming/exporter concepts when the target project already has a DCC pipeline.

## First Upstream Areas To Inspect

- `src/TressFX/` for API-agnostic hair simulation and rendering logic.
- `src/Shaders/` for compute and rendering shader structure.
- `src/VK/` for the Vulkan engine-interface implementation.
- `src/Common/` and `libs/cauldron/` for sample-framework assumptions that should not leak into a
  target repo by accident.
- `doc/` and `tool/ Maya/` for integration, authoring, and exporter workflow notes.

## Integration Notes

- Prefer adapting the engine-interface boundary and data model over copying the full Cauldron sample.
- Keep strand asset IO, simulation buffers, collision representation, render material parameters, and
  DCC exporters as separate modules.
- If the target shader lane is GLSL-first, translate HLSL/SM6 assumptions deliberately and validate the
  generated SPIR-V.
- Make groom assets and sample scenes explicit test fixtures with their own license checks.

## Validation Ideas

- Run a tiny groom with deterministic frame stepping and compare strand bounds before and after skinning.
- Test collision against a simple animated primitive before using complex character meshes.
- Capture a short Vulkan run with validation enabled, then inspect one frame in RenderDoc or Nsight
  Graphics after validation messages are classified.
- Add visual regression frames for LOD, fast motion, and zero-width or sparse-strand edge cases.

## Caveats

- The public sample is old enough that SDK, compiler, shader-model, and platform assumptions need local
  verification before reuse.
- The Cauldron sample framework is useful context but should not become a hidden dependency unless the
  target repo intentionally accepts it.
- DCC exporter code and example assets are separate license and maintenance surfaces from the runtime
  hair library.
