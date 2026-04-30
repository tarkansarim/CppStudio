# MaterialX Donor Profile

Source: https://github.com/AcademySoftwareFoundation/MaterialX  
Tier: `dependency-candidate`  
License signal: Apache-2.0; inspect `LICENSE`, `THIRD-PARTY.md`, generated shaders, examples, and
sample material assets at the exact revision used.

## Use First For

- Material and look-development interchange across DCC tools, renderers, and runtime pipelines.
- Node graph schema decisions, shader generation boundaries, and renderer-independent material authoring.
- USD/UsdShade material exchange where MaterialX documents or shader nodes are involved.
- Test fixtures for preserving material parameters through import/export.

## First Upstream Areas To Inspect

- `source/MaterialXCore/` for document, node, value, and graph semantics.
- `source/MaterialXFormat/` for file IO and validation.
- `source/MaterialXGenShader/` and shader generator backends for code-generation boundaries.
- `libraries/` for standard nodes and reference material definitions.
- `documents/` and `resources/` for examples, but check asset licenses before reuse.

## Integration Notes

- Keep MaterialX documents as interchange data; map them to target renderer materials through a narrow
  translation layer.
- Do not make generated shader text a hidden source of truth. Regenerate it from tracked MaterialX
  inputs or track both with version notes.
- Validate unit conventions, color spaces, texture paths, and unsupported nodes during import.
- Prefer package/dependency integration over copying large library code.

## Validation Ideas

- Load, validate, and round-trip a small material document with textures, constants, and layered nodes.
- Compare generated shader output or renderer material bindings against known fixtures.
- Test missing texture paths, unsupported node definitions, and color-space metadata explicitly.
- Add a USD material round-trip fixture when UsdShade is part of the target pipeline.

## Caveats

- MaterialX solves interchange, not renderer-specific shading quality by itself.
- Standard libraries and generated code evolve; pin versions and record generator assumptions.
- Example materials, textures, and generated shaders may have separate attribution or asset concerns.
