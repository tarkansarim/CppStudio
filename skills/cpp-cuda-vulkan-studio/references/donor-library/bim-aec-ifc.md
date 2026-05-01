# BIM, AEC, And IFC Donors

Use these donors for building information modeling, IFC parsing, AEC geometry, semantic building
models, validation rules, BCF collaboration data, and CAD/BIM-to-runtime handoff.

## IFC Geometry And Runtime Libraries

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [IfcOpenShell](https://github.com/IfcOpenShell/IfcOpenShell) | dependency-candidate | LGPL/GPL/component mix; inspect exact modules | IFC parsing, Open CASCADE geometry generation, BlenderBIM/Bonsai workflows, BIM conversion pipelines. |
| [web-ifc](https://github.com/ThatOpen/engine_web-ifc) | dependency-candidate | MIT | IFC parsing and geometry extraction architecture; WebAssembly/TypeScript surface is reference-only for native C++. |
| [IfcPlusPlus / IFC++](https://github.com/ifcquery/ifcplusplus) | dependency-candidate | MIT | C++ IFC parsing and geometry conversion references, viewer/tool architecture. |
| [xBIM Essentials](https://github.com/xBimTeam/XbimEssentials) | dependency-candidate | CDDL-1.0 signal | IFC data-model patterns and fixtures; .NET reference-only for native C++. |
| [xBIM Geometry](https://github.com/xBimTeam/XbimGeometry) | dependency-candidate | CDDL-1.0 signal | Geometry conversion expectations and validation references; .NET/native mix requires review. |

## Standards, Validation, And Collaboration

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [buildingSMART IFC](https://github.com/buildingSMART/IFC) | dependency-candidate | Standards/specification; verify repo license | IFC schema, entities, property sets, MVD concepts, and conformance expectations. |
| [buildingSMART IDS](https://github.com/buildingSMART/IDS) | dependency-candidate | Specification/reference; verify repo license | Information Delivery Specification rules and BIM requirement validation concepts. |
| [buildingSMART Validation Service](https://github.com/buildingSMART/validate) | dependency-candidate | Reference implementation; verify repo license | IFC/IDS validation flow and diagnostics. |
| [buildingSMART BCF API](https://github.com/buildingSMART/BCF-API) | dependency-candidate | Specification/reference; verify repo license | BIM Collaboration Format issue/comment/location exchange. |

## Deferred Or Reference-Only

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Hypar Elements](https://github.com/hypar-io/Elements) | dependency-candidate | MIT | Building-element data modeling concepts; .NET reference-only for native C++. |
| [Speckle](https://github.com/specklesystems/speckle-sharp) | dependency-candidate | Apache-2.0 signal | Collaboration/object transport concepts; .NET reference-only unless target chooses Speckle. |
| [xeokit SDK](https://github.com/xeokit/xeokit-sdk) | dependency-candidate | AGPL/commercial signal | Browser BIM viewer behavior reference only unless license path is explicit. |

## Selection Notes

- Use IfcOpenShell first when geometry extraction and Open CASCADE handoff matter.
- Use IFC++ when the target needs a smaller C++ IFC parser/viewer reference.
- Use buildingSMART specs/validators for conformance and data-model behavior; do not treat specs as
  implementation code.
- Keep BIM semantics, geometry tessellation, CAD kernel use, and renderer upload as separate stages.
- Do not bundle proprietary building models or sample IFC files without explicit data-license review.

## Deep Profiles

- [BIM, AEC, And IFC](profiles/bim-ifc-aec.md): read before selecting IFC parsers, BIM geometry conversion, buildingSMART validation, or BCF collaboration donors.
