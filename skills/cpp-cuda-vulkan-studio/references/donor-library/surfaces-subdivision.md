# Surfaces, Subdivision, And Geometry Processing Donors

Use these donors for subdivision surfaces, high-order surface evaluation, remeshing, parameterization,
geometric operators, mesh deformation, and precise surface processing.

## Surface Evaluation And Geometry Processing

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenSubdiv](https://github.com/PixarAnimationStudios/OpenSubdiv) | safe-donor | Apache-2.0 style; inspect optional CPU/GPU deps | Catmull-Clark subdivision, feature-adaptive subdivision, CPU/GPU evaluation, DCC-compatible smooth surfaces. |
| [libigl](https://github.com/libigl/libigl) | dependency-candidate | Primarily MPL-2.0; GPL/copyleft subfolders and third-party caveats | Geometry processing algorithms, deformation, remeshing, parameterization, tutorials/tests. |
| [CGAL](https://www.cgal.org/) | dependency-candidate | Mixed LGPL/GPL by package; commercial option exists | Robust computational geometry, mesh processing, triangulation, arrangements, Boolean/solid algorithms. |
| [meshoptimizer](https://github.com/zeux/meshoptimizer) | safe-donor | MIT | Runtime mesh conditioning, simplification, vertex/index optimization, mesh compression. |

## Selection Notes

- Use OpenSubdiv for subdivision surface semantics and GPU/CPU evaluation.
- Use libigl for research-grade mesh processing patterns, checking per-module licenses before reuse.
- Use CGAL when exactness and robust computational geometry matter; verify package-level GPL/LGPL
  constraints before recommending it for reusable/proprietary-compatible code.
- Use meshoptimizer for production-friendly mesh conditioning when high-order geometry is not required.

## Deep Profiles

- [OpenSubdiv](profiles/opensubdiv.md): read before adopting subdivision-surface evaluation.
- [meshoptimizer](profiles/meshoptimizer.md): read when evaluated or imported meshes need runtime conditioning, simplification, or compression.
