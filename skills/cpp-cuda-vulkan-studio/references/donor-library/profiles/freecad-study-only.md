# FreeCAD Study-Only Donor Profile

Source: https://github.com/FreeCAD/FreeCAD  
Tier: `study-only`  
Backend signal: native-cpu, dcc-interchange
License signal: LGPL/GPL mix with dependency-heavy application architecture; inspect `LICENSE`,
workbench/module licenses, bundled resources, Python scripts, Open CASCADE dependency usage, examples,
and sample files before any reuse.

## Use First For

- CAD UX, parametric modeling workflows, document object models, workbench/module organization, Python
  automation concepts, and Open CASCADE-based application architecture.
- Understanding how CAD users expect constraints, features, sketches, bodies, and document history to
  behave.
- Comparing CAD application workflows against narrower Open CASCADE kernel integration.

## First Upstream Areas To Inspect

- Workbenches and modules matching the target workflow.
- Document/object model and Python automation layers for UX concepts.
- Open CASCADE integration boundaries for kernel usage patterns.
- License files, bundled resources, examples, and macros before reuse.

## Integration Notes

- Treat FreeCAD as study-only workflow and architecture context for this package.
- Use Open CASCADE directly for reusable CAD-kernel implementation guidance.
- Keep parametric document state, kernel geometry, tessellated render meshes, and UI commands separated.
- Do not copy workbench or macro code into permissive templates without explicit license approval.

## Validation Ideas

- Translate observed workflows into tiny project-owned fixtures: sketch, extrude, Boolean, tessellate,
  export, and reopen.
- Test unit, tolerance, object-history, invalid sketch, and failed operation behavior independently.
- Record whether the concept came from workflow study or kernel documentation.
- Confirm no GPL application code or sample asset was copied.

## Caveats

- FreeCAD is valuable CAD workflow context but not a default implementation donor for permissive outputs.
- CAD UX concepts can imply large document-model commitments.
- Sample CAD files and user macros need separate provenance checks.
