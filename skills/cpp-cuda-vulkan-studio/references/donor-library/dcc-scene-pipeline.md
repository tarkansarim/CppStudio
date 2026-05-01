# DCC Scene Pipeline Donors

Use these donors for scene interchange, DCC import/export, material exchange, composition, editorial
timelines, and offline-to-runtime asset pipelines.

## Scene And Asset Interchange

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenUSD](https://github.com/PixarAnimationStudios/OpenUSD) | dependency-candidate | Modified Apache-2.0 style; inspect exact license/third-party notices | Scene composition, layering, variants, payloads, instancing, animation, curves, materials, DCC interchange. |
| [Alembic](https://github.com/alembic/alembic) | dependency-candidate | BSD-style/license file; inspect DCC plugins | Animated geometry caches, curves, simulation caches, Maya/Houdini/RenderMan plugin examples. |
| [assimp](https://github.com/assimp/assimp) | dependency-candidate | BSD-3-Clause based | Broad import/export coverage when full USD/Alembic scene semantics are unnecessary. |
| [Blender](https://projects.blender.org/blender/blender) | study-only | GPL | DCC UX, import/export workflows, geometry nodes, grooming, animation authoring, and editor architecture. |

## Materials, Looks, And Editorial

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [MaterialX](https://github.com/AcademySoftwareFoundation/MaterialX) | dependency-candidate | Apache-2.0 | Look-development interchange, shader generation, material graphs, DCC renderer interoperability. |
| [OpenTimelineIO](https://github.com/AcademySoftwareFoundation/OpenTimelineIO) | dependency-candidate | Apache-2.0 | Editorial timeline interchange for virtual production, review, and multi-shot tools. |
| [OpenSubdiv](https://github.com/PixarAnimationStudios/OpenSubdiv) | safe-donor | Apache-2.0 style; inspect license and optional GPU deps | Production subdivision surface evaluation used across DCC pipelines. |

## Selection Notes

- Use OpenUSD when composition, layering, variants, payloads, or DCC collaboration matter.
- Use Alembic when the problem is baked animated geometry or curves, not live scene composition.
- Use MaterialX for material graph interchange instead of inventing renderer-specific material schemas.
- Keep DCC plugins, example assets, sample scenes, and proprietary SDK bridges as separate license
  surfaces from the core donor library.

## Deep Profiles

- [OpenUSD](profiles/openusd.md): read before designing scene composition or USD-based interchange.
- [Alembic](profiles/alembic.md): read before designing baked animated geometry, curves, or simulation caches.
- [assimp](profiles/assimp.md): read when broad asset import/export is enough and full USD/Alembic semantics are unnecessary.
- [MaterialX](profiles/materialx.md): read before adding material/look-development interchange.
- [OpenSubdiv](profiles/opensubdiv.md): read when subdivision surfaces are part of the scene pipeline.
