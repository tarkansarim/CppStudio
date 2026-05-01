# BIM, AEC, And IFC Profile

Sources: https://github.com/IfcOpenShell/IfcOpenShell https://github.com/ThatOpen/engine_web-ifc https://github.com/ifcquery/ifcplusplus https://github.com/xBimTeam/XbimEssentials https://github.com/xBimTeam/XbimGeometry https://github.com/buildingSMART/IFC https://github.com/buildingSMART/IDS https://github.com/buildingSMART/validate https://github.com/buildingSMART/BCF-API
Tier: `dependency-candidate`
Backend signal: api-agnostic, native-cpu
License signal: mixed LGPL/GPL/component, MIT, CDDL, and specification/reference signals; inspect exact
modules, schemas, generated files, and sample building models before reuse.

## Use First For

- IFC parsing, BIM geometry conversion, building semantics, IDS validation, BCF collaboration, and
  Open CASCADE handoff into CAD/rendering pipelines.

## Integration Notes

- Use IfcOpenShell first for geometry-rich IFC/Open CASCADE workflows.
- Use IFC++ when a smaller C++ parser/viewer reference is more appropriate.
- Treat web-ifc and xBIM as behavior/reference material for native C++ unless their runtimes are
  explicitly chosen.
- Keep IFC schema semantics, geometry tessellation, CAD kernel dependencies, and renderer upload separate.

## Validation Ideas

- Use tiny IFC fixtures with one wall, one opening, one material/property set, one placement transform,
  and one invalid schema case.
- Validate unit handling, local/world transforms, property preservation, and diagnostic quality.
