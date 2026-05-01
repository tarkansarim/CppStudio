# CGAL Donor Profile

Source: https://www.cgal.org/  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: GPL/commercial dual-license at project level with package-level licensing nuances;
inspect selected package licenses, examples, third-party dependencies, and commercial-license needs
before reuse.

## Use First For

- Robust computational geometry, exact predicates, triangulation, arrangements, Boolean operations,
  mesh generation, remeshing, alpha wrapping, spatial search, and CAD-adjacent geometry processing.
- Reference algorithms when numerical robustness matters more than lightweight dependency shape.
- Comparing exact/robust computational geometry against mesh-only donors such as libigl or Open3D.

## First Upstream Areas To Inspect

- The exact CGAL package documentation for the needed algorithm.
- Package license status before recommending dependency use in reusable or proprietary-compatible code.
- Kernel, traits, number-type, and robustness requirements before designing APIs.
- Examples and tests around degenerate or precision-sensitive inputs.

## Integration Notes

- Treat CGAL as a package-level dependency decision, not a single project-wide license assumption.
- Keep exact geometry, approximate render meshes, tolerances, units, and failure policy explicit.
- Prefer OCCT for CAD-native B-rep/NURBS and STEP/IGES semantics.
- Prefer meshoptimizer or libigl for smaller mesh-processing tasks when robust exact geometry is not
  central.

## Validation Ideas

- Test degenerate triangles, coincident points, near-zero edges, nonmanifold meshes, and invalid solids.
- Add fixtures for Boolean operations, triangulation, and mesh repair only for the supported package set.
- Record kernel/number-type choices with expected accuracy and performance tradeoffs.
- Verify package-license compatibility before adding dependency wiring.

## Caveats

- CGAL licensing is a major dependency decision.
- Exact predicates and robust kernels can change performance and API complexity.
- Robust geometry code still needs explicit invalid-input and tolerance policy.
