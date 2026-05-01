# CAD And Precision Geometry Donors

Use these donors for B-reps, NURBS, STEP/IGES interchange, exact computational geometry, CAD/CAM/CAE
geometry, tessellation, Boolean operations, and precision modeling workflows.

## CAD Kernels And Precision Geometry

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Open CASCADE Technology](https://dev.opencascade.org/) | dependency-candidate | LGPL-2.1 with exception; inspect exact version and modules | B-rep/NURBS CAD kernel, STEP/IGES, topology, tessellation, visualization, CAD tool architecture. |
| [CGAL](https://www.cgal.org/) | dependency-candidate | Mixed LGPL/GPL by package; commercial option exists | Robust computational geometry, triangulation, Boolean operations, meshing, exact predicates. |
| [libigl](https://github.com/libigl/libigl) | dependency-candidate | Primarily MPL-2.0; GPL/copyleft subfolders | Mesh-oriented geometry processing adjacent to CAD import/export or repair workflows. |
| [FreeCAD](https://github.com/FreeCAD/FreeCAD) | study-only | LGPL/GPL mix; Open CASCADE dependency | CAD UX, parametric modeling workflows, document object model, Python-driven CAD concepts. |

## Selection Notes

- Use Open CASCADE when the task requires CAD-native B-rep/NURBS or STEP/IGES behavior.
- Use CGAL when robust computational geometry matters more than CAD file semantics.
- Use libigl for mesh-side geometry processing and repair concepts.
- Treat FreeCAD as study-only unless the project explicitly accepts its license/dependency shape.
- Keep CAD source files, vendor models, generated meshes, workbench scripts, and example projects as
  separate license and provenance surfaces.

## Deep Profiles

- [Open CASCADE Technology](profiles/open-cascade.md): read before adopting CAD kernel or precision geometry patterns.
- [CGAL](profiles/cgal.md): read before adopting robust computational geometry, exact predicates, mesh generation, triangulation, or Booleans.
- [libigl](profiles/libigl.md): read before using mesh-side geometry processing, repair, deformation, or parameterization references.
- [FreeCAD Study-Only](profiles/freecad-study-only.md): read for CAD UX, parametric modeling, workbench, or Open CASCADE application workflow concepts without code reuse.
