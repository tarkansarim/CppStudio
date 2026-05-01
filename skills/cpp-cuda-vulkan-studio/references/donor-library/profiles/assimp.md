# assimp Donor Profile

Source: https://github.com/assimp/assimp  
Tier: `dependency-candidate`  
Backend signal: api-agnostic, native-cpu, dcc-interchange
License signal: BSD-3-Clause style for core code; inspect `LICENSE`, `contrib/`, `test/models`,
`test/models-nonbsd`, importers/exporters, and sample assets at the exact revision used.

## Use First For

- Broad 3D asset import/export coverage across legacy, DCC, CAD-adjacent, and game formats.
- Importer normalization, scene traversal, material/mesh/animation extraction, and conversion tooling.
- Asset-pipeline prototyping when glTF-only loaders are too narrow.

## First Upstream Areas To Inspect

- `code/AssetLib/` for format-specific importer/exporter behavior.
- `include/` and `code/Common/` for public scene data structures and traversal patterns.
- `code/PostProcessing/` for triangulation, tangent generation, coordinate conversion, and mesh cleanup.
- `test/models`, `test/models-nonbsd`, `contrib/`, and `tools/` before using fixtures or dependencies.

## Integration Notes

- Treat assimp as a dependency candidate for broad import, not the default for simple glTF runtime loading.
- Keep imported scene data distinct from renderer-ready meshes, materials, textures, and animations.
- Normalize units, axes, handedness, triangulation, tangent space, and material conventions explicitly.
- Prefer exact-format loaders for production paths when the target format set is narrow.

## Validation Ideas

- Test one tiny fixture per accepted format and reject unsupported formats clearly.
- Add round-trip or golden-metadata tests for transforms, hierarchy, material slots, indices, UVs, and
  animation keys.
- Run sanitizer/fuzzer-style tests for untrusted assets before accepting user-supplied files.
- Verify fixture licenses separately from assimp code.

## Caveats

- Format breadth brings transitive parser and fixture license surfaces.
- Post-processing flags can silently change geometry and material semantics.
- Not every supported format has equal fidelity; document accepted formats and known losses.
