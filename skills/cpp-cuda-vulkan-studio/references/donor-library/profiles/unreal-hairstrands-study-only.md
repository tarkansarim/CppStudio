# Unreal HairStrands Study-Only Donor Profile

Source: https://github.com/EpicGames/UnrealEngine  
Tier: `study-only`  
Backend signal: mixed-backend
License signal: Unreal Engine source and EULA terms; local engine access, plugins, shaders, samples, and
assets require explicit license review before reuse.

## Use First For

- Strand/groom runtime architecture, interpolation, mesh binding, guide/follow payloads, and cards
  deformation.
- GPU hair voxelization, virtual voxel pages, deep shadows, transmittance, and visibility passes.
- Renderer-side groom scheduling, RDG-style resource staging, and performance tradeoffs.
- Study references for HairStrands shader organization, LUT-backed dual scattering, and runtime buffers.

## First Upstream Areas To Inspect

- `Engine/Plugins/Runtime/HairStrands` for groom assets, interpolation, binding, cards, and runtime data.
- `Engine/Source/Runtime/Renderer/Private/HairStrands` for renderer integration, visibility, voxelization,
  deep shadows, and transmittance.
- `Engine/Shaders/Private/HairStrands` and hair shading shader includes for runtime shader behavior.
- Groom binding, interpolation, voxelization, visibility, deep-shadow, and simulation paths separately.

## Integration Notes

- Use Unreal as a concept and architecture reference only. Do not copy engine code into reusable
  CppStudio templates or permissive projects.
- Borrow the separation of offline build data, runtime deformation, visibility, transmittance, and shading
  rather than the RDG/RHI framework.
- Treat single-guide, multi-guide, imported closest-guide, and generic builder paths as distinct concepts.
- Prefer smaller permissive donors for implementation when they cover the same feature.

## Validation Ideas

- Build target-owned fixtures for guide interpolation, binding, deformation, voxel coverage, and deep
  shadow/transmittance behavior.
- Add tests that distinguish source-authored guides from generated guides.
- Capture debug buffers for visibility, transmittance, voxel pages, and final shading separately.
- Document which Unreal behavior was studied and which project-owned implementation or permissive donor
  provides the code.

## Caveats

- Unreal is a large engine architecture with RDG/RHI assumptions; copying those assumptions into a small
  native tool usually creates more work than it saves.
- Source, shaders, and examples are governed by Unreal-specific terms and remain study-only here.
