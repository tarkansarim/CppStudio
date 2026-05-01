# Open CASCADE Technology Donor Profile

Source: https://github.com/Open-Cascade-SAS/OCCT  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: LGPL-2.1 with Open CASCADE exception; inspect `LICENSE_LGPL_21.txt`,
`OCCT_LGPL_EXCEPTION.txt`, optional modules, third-party dependencies, and sample assets at the exact
revision used.

## Use First For

- CAD-native B-rep and NURBS modeling.
- STEP/IGES import/export, topology, tessellation, Boolean operations, and precision geometry workflows.
- CAD/CAM/CAE tool architecture when exact geometry semantics matter.
- Converting CAD data to renderer or simulation meshes with traceable tolerances.

## First Upstream Areas To Inspect

- Modeling data and topology packages before designing a project-owned CAD representation.
- STEP/IGES exchange packages for import/export behavior.
- BRepMesh and visualization examples for tessellation and display handoff.
- Geometry kernel docs around tolerances, units, locations, and topology ownership.
- Sample applications for workflow ideas, not as code to copy directly into generated projects.

## Integration Notes

- Treat OCCT as a dependency boundary. Keep project UI, render mesh, simulation mesh, and CAD kernel data
  separated.
- Make tolerance, unit, orientation, manifoldness, and tessellation-quality policy explicit.
- Export both a coarse visual mesh and source CAD metadata when downstream tools need traceability.
- Check LGPL exception and dynamic/static linking implications with the target project's distribution
  model before adoption.

## Validation Ideas

- Import a tiny STEP fixture, verify body count, bounding boxes, units, and topology structure.
- Tessellate with two quality settings and verify triangle counts and bounds without assuming exact
  vertex ordering.
- Test Boolean and fillet edge cases with known failure handling.
- Round-trip STEP/IGES only for the subset of entities the project claims to support.

## Caveats

- CAD kernels are tolerance-driven. Exact-looking code can still fail on real-world dirty models.
- FreeCAD is useful workflow context but has a different license/dependency profile and should stay
  study-only unless explicitly accepted.
- Sample CAD files, vendor files, and generated meshes need their own provenance checks.
