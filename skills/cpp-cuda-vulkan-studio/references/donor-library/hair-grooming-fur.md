# Hair, Grooming, And Fur Donors

Use these donors for strand data, guide/follow interpolation, hair/fur simulation, curve grooming,
hair rendering, and DCC groom interchange.

## Runtime Hair And Fur

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [AMD TressFX](https://github.com/GPUOpen-Effects/TressFX) | safe-donor | MIT | GPU hair/fur simulation and rendering, strand data, skinning, LOD, Vulkan/DX12 sample architecture. |
| [O3DE Atom TressFX Gem](https://docs.o3de.org/docs/user-guide/gems/reference/rendering/amd/atom-tressfx/) | dependency-candidate | O3DE Apache-2.0/MIT default; component notices vary | Engine integration of TressFX-style hair/fur, Marschner lighting, Atom renderer integration. |
| [NVIDIA HairWorks docs](https://docs.nvidia.com/gameworks/content/artisttools/hairworks/) | study-only | GameWorks SDK/source terms; verify before reuse | Hair asset concepts, artist controls, frame-rate-independent rendering, DX11/DX12 sample behavior. |

## Groom Authoring And Interchange

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Blender Hair Curves](https://docs.blender.org/manual/en/latest/modeling/geometry_nodes/hair/index.html) | study-only | Blender code is GPL; docs/assets vary | Grooming UX, guide curves, hair nodes, attach/deform/interpolate/trim/clump workflows. |
| [OpenUSD BasisCurves](https://openusd.org/dev/api/class_usd_geom_basis_curves.html) | dependency-candidate | Modified Apache-2.0 style; inspect exact repo license | Curve/strand interchange, widths, basis/wrap, scene composition around groom data. |
| [Alembic](https://github.com/alembic/alembic) | dependency-candidate | BSD-style/license file; inspect plugins and third-party deps | Animated curve and geometry interchange between DCC tools. |

## Selection Notes

- For reusable C++/Vulkan/CUDA hair implementation patterns, start with TressFX.
- Treat TressFX, HairWorks, Blender hair, USD curves, and Alembic as domain references even when their
  runtime/API lane differs from the target. Port simulation, strand layout, and render behavior through
  the selected Vulkan or CUDA lane instead of changing lanes because of the donor backend.
- For grooming UI and artist workflow ideas, study Blender hair curves but do not copy GPL code into
  permissive templates.
- For interchange, prefer OpenUSD curves for modern scene pipelines and Alembic for established
  animated-geometry/groom cache workflows.
- Treat HairWorks as study-only until a project has an explicit GameWorks/license path.
- Prefer TressFX for permissive implementation patterns when HairWorks and Blender only provide concept
  or artist-workflow references.

## Deep Profiles

- [AMD TressFX](profiles/tressfx.md): read before adapting realtime hair/fur simulation or rendering.
- [OpenUSD](profiles/openusd.md): read before choosing USD curves or scene composition for grooms.
- [Alembic](profiles/alembic.md): read before using baked animated curve or groom caches.
- [Blender Study-Only](profiles/blender-study-only.md): read for grooming UX, hair curves, geometry-node, and artist workflow concepts without code reuse.
- [NVIDIA HairWorks Study-Only](profiles/hairworks-study-only.md): read for GameWorks hair authoring/runtime concepts without code reuse.
