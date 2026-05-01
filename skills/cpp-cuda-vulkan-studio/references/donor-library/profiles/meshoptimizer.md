# meshoptimizer Donor Profile

Source: https://github.com/zeux/meshoptimizer  
Tier: `safe-donor`  
Backend signal: api-agnostic, native-cpu
License signal: MIT; inspect `LICENSE.md`, `extern/`, tools, demo assets, glTF pipeline helpers, and
companion project notices at the exact revision used.

## Use First For

- Runtime and offline mesh conditioning: indexing, vertex-cache optimization, overdraw optimization,
  vertex-fetch optimization, quantization, simplification, and compression.
- glTF-friendly optimization and `EXT_meshopt_compression` pipeline decisions.
- Small C/C++ dependency integration where renderer-ready vertex/index buffers need predictable layout.

## First Upstream Areas To Inspect

- `src/meshoptimizer.h` and focused `src/*.cpp` files for the needed algorithm surface.
- `gltf/` and `tools/` for glTF optimization, `gltfpack`, and asset-conditioning workflows.
- Tests and demo assets for simplification, remap, compression, and quantization behavior.
- `extern/` and companion projects before copying tools or example assets.

## Integration Notes

- Run optimization after importer normalization and before final GPU buffer upload.
- Keep source asset import, mesh conditioning, compression, and renderer upload as separate stages.
- Preserve tangent/normal/UV/skin/morph attribute semantics when remapping or simplifying vertices.
- For Vulkan or CUDA targets, use meshoptimizer as CPU-side data preparation unless a project explicitly
  owns GPU-side mesh processing.

## Validation Ideas

- Add tiny triangle, indexed mesh, duplicate-vertex, skinned mesh, morph target, and UV seam fixtures.
- Verify remap tables preserve attribute associations and bounds.
- Compare pre/post optimization render output on a small fixture.
- Test meshopt-compressed glTF assets through validator and loader paths before renderer upload.

## Caveats

- Mesh optimization can change ordering and precision; tests must protect semantic attributes.
- Overdraw optimization is view and hardware sensitive; benchmark before enforcing it.
- Compression support adds decoder/runtime dependency decisions beyond basic optimization.
