# OpenUSD Donor Profile

Source: https://github.com/PixarAnimationStudios/OpenUSD  
Tier: `dependency-candidate`  
Backend signal: dcc-interchange, native-cpu
License signal: modified Apache-style Tomorrow Open Source Technology License plus bundled third-party
notices; inspect `LICENSE.txt`, `NOTICE.txt`, plugins, imaging backends, and bundled dependencies at the
exact revision used.

## Use First For

- Scene composition, layers, references, payloads, variants, instancing, and time-sampled data.
- DCC interchange involving geometry, materials, cameras, animation, grooms, volumes, and shots.
- `UsdGeomBasisCurves`, `UsdSkel`, and `UsdShade` schema decisions.
- Pipeline tools that need stable interchange more than minimal runtime footprint.

## First Upstream Areas To Inspect

- `pxr/usd/usd/` for core composition and layer behavior.
- `pxr/usd/usdGeom/` for meshes, curves, cameras, points, and transforms.
- `pxr/usd/usdShade/` and MaterialX-related docs for material interchange.
- `pxr/usd/usdSkel/` for skeletal animation, skinning, and blend shape interchange.
- `pxr/usdImaging/` only when viewer or Hydra integration is part of the task.
- Official tutorials and schema docs before designing new project-specific schemas.

## Integration Notes

- Treat USD as a dependency boundary, not a snippet donor. Keep project-native runtime data structures
  separate from USD authoring and import/export code.
- Add explicit schema mapping tests for every project-owned concept: transforms, units, handedness,
  variants, payloads, materials, curves, animation, and asset paths.
- Keep generated USD caches, sample assets, and DCC plugin glue out of reusable skill templates.
- Record the minimum supported OpenUSD version because ABI, build options, and plugin availability can
  affect integration.

## Validation Ideas

- Round-trip a tiny stage containing mesh, material, camera, transform hierarchy, and time samples.
- Test payload/reference resolution with relative and absolute asset paths.
- Add focused fixtures for BasisCurves, UsdSkel, and MaterialX only when those lanes are in scope.
- Open representative stages with `usdview` or a target viewer as a smoke test after import/export
  changes.

## Caveats

- OpenUSD is powerful but heavy. Do not introduce it for simple asset loading when assimp, glTF, or a
  narrow custom format is enough.
- Plugins, imaging backends, Python bindings, and DCC bridges can carry separate dependency and license
  concerns.
- USD scene semantics should be preserved intentionally; flattening, baking, or payload expansion can
  silently change pipeline behavior.
