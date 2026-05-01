# libigl Donor Profile

Source: https://github.com/libigl/libigl  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: Primarily MPL-2.0 with GPL/copyleft subfolders and third-party caveats; inspect
`LICENSE*`, optional modules, tutorial dependencies, and exact files before reuse.

## Use First For

- Mesh processing algorithms, deformation, remeshing, parameterization, discrete differential geometry,
  signed distance, and geometry-processing tutorials.
- Reference outputs for mesh repair, mesh analysis, and shape-processing prototypes.
- Comparing mesh-side processing options against CGAL, Open3D, meshoptimizer, or CAD-kernel workflows.

## First Upstream Areas To Inspect

- Tutorial code and examples matching the target operation.
- Header paths and optional modules before treating code as embeddable.
- License files and GPL/copyleft subdirectories before copying snippets.
- Test fixtures or tutorial data for expected numerical behavior.

## Integration Notes

- Treat libigl as dependency-candidate or algorithm reference, not automatically safe snippet material.
- Keep geometry processing, viewer/debug UI, linear algebra dependencies, and optional solver modules
  separated.
- Use meshoptimizer for runtime mesh conditioning when high-level geometry processing is unnecessary.
- Use CGAL or OCCT when robustness, exact predicates, B-reps, or CAD semantics dominate.

## Validation Ideas

- Add tiny mesh fixtures covering triangles, boundaries, nonmanifold cases, degenerate faces, and empty
  meshes.
- Compare algorithm outputs with tolerances and topology checks rather than exact floating-point dumps.
- Test missing optional solver/backend dependencies separately from core algorithm tests.
- Record which files/modules were consulted for license review.

## Caveats

- MPL-2.0 and GPL/copyleft areas require exact-file license review.
- Tutorial code can pull in optional dependencies that are not appropriate for reusable templates.
- Geometry-processing algorithms often fail on degenerate real-world meshes without explicit policy.
