# OpenVDB And NanoVDB Donor Profile

Source: https://github.com/AcademySoftwareFoundation/openvdb  
Tier: `dependency-candidate` for OpenVDB, `safe-donor` for narrow NanoVDB-style runtime concepts  
License signal: current OpenVDB releases are Apache-2.0 after re-licensing from MPL-2.0; inspect
`LICENSE`, `RE-LICENSE_NOTE.txt`, NanoVDB files, optional components, and dependencies at the exact
revision used.

## Use First For

- Sparse volume storage, VDB file IO, level sets, fog volumes, and production VFX volume workflows.
- GPU-friendly static volume traversal and compact runtime volume data through NanoVDB.
- Volume import/export boundaries for renderers, simulation tools, collision fields, and neural 3D.
- ML sparse-volume exploration when fVDB or PyTorch-oriented workflows are intentionally in scope.

## First Upstream Areas To Inspect

- `openvdb/openvdb/` for core sparse tree, grid, transform, and IO structures.
- `nanovdb/` for compact GPU-friendly representation and traversal examples.
- `openvdb_ax/` only when expression language or procedural volume operations are required.
- Build docs for optional components, TBB, compression, Python, Houdini, NanoVDB, and AX.
- Example tools before designing custom converters or viewers.

## Integration Notes

- Treat OpenVDB as a dependency for IO and authoring; treat NanoVDB as the first runtime reference for
  compact GPU traversal.
- Keep file conversion, CPU grid manipulation, GPU upload, shader traversal, and renderer integration
  as separate layers.
- Record voxel size, transform, active value semantics, background value, and unit conventions in tests.
- Avoid adding Houdini, Python, or AX dependencies unless the target workflow explicitly needs them.

## Validation Ideas

- Load a tiny VDB, verify grid names, transforms, bounds, active voxel counts, and sample values.
- Convert a small grid to NanoVDB and compare CPU samples against GPU traversal samples.
- Test empty grids, constant grids, negative transforms, large sparse bounds, and missing metadata.
- Add offscreen volume-render smoke frames only after data import tests are stable.

## Caveats

- OpenVDB has many optional components. A target repo should pin the subset it actually uses.
- Older releases may carry MPL-2.0 licensing; do not generalize from current trunk to all versions.
- Volume assets and DCC-generated caches often have separate licenses from the OpenVDB code.
