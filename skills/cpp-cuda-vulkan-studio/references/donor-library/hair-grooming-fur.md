# Hair, Grooming, And Fur Donors

Use these donors for strand data, guide/follow interpolation, hair/fur simulation, feather-like
strand/card systems, curve grooming, hair rendering, and DCC groom interchange.

## Runtime Hair And Fur

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [AMD TressFX](https://github.com/GPUOpen-Effects/TressFX) | safe-donor | MIT | GPU hair/fur simulation and rendering, strand data, skinning, LOD, Vulkan/DX12 sample architecture. |
| [NVIDIA RTXCR](profiles/rtxcr.md) | dependency-candidate | NVIDIA RTX SDKs license | Path-traced hair/skin rendering, LSS/DOTS hair geometry, Chiang/Far-Field hair material modes, and RT lookdev shell behavior. |
| [RTXCR Material Library](profiles/rtxcr-material-library.md) | dependency-candidate | NVIDIA RTX SDKs license | Hair material contracts, Chiang and Far-Field BSDFs, and shader-side hair parameter mapping. |
| [RTXCR Geometry Library](profiles/rtxcr-geometry-library.md) | dependency-candidate | NVIDIA RTX SDKs license | Curve tessellation, LSS/DOTS geometry helpers, and strand-to-ray-tracing geometry adapter concepts. |
| [O3DE Atom TressFX Gem](https://docs.o3de.org/docs/user-guide/gems/reference/rendering/amd/atom-tressfx/) | dependency-candidate | O3DE Apache-2.0/MIT default; component notices vary | Engine integration of TressFX-style hair/fur, Marschner lighting, Atom renderer integration. |
| [NVIDIA HairWorks docs](https://docs.nvidia.com/gameworks/content/artisttools/hairworks/) | study-only | GameWorks SDK/source terms; verify before reuse | Hair asset concepts, artist controls, frame-rate-independent rendering, DX11/DX12 sample behavior. |
| [Unreal HairStrands](profiles/unreal-hairstrands-study-only.md) | study-only | Unreal Engine source/EULA terms | Groom runtime architecture, interpolation, binding, voxelization, deep shadows, transmittance, visibility, and cards concepts. |
| [Unity HDRP Hair](profiles/unity-hdrp-hair-study-only.md) | study-only | Unity package and sample terms; inspect exact package | HDRP hair shading, Shader Graph controls, multiple-scattering LUTs, card/strand material options, and line-rendering references. |

## Groom Authoring And Interchange

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Blender Hair Curves](https://docs.blender.org/manual/en/latest/modeling/geometry_nodes/hair/index.html) | study-only | Blender code is GPL; docs/assets vary | Grooming UX, guide curves, hair nodes, attach/deform/interpolate/trim/clump workflows. |
| [OpenUSD BasisCurves](https://openusd.org/dev/api/class_usd_geom_basis_curves.html) | dependency-candidate | Modified Apache-2.0 style; inspect exact repo license | Curve/strand interchange, widths, basis/wrap, scene composition around groom data. |
| [Alembic](https://github.com/alembic/alembic) | dependency-candidate | BSD-style/license file; inspect plugins and third-party deps | Animated curve and geometry interchange between DCC tools. |

## Selection Notes

- For reusable C++/Vulkan/CUDA hair simulation and raster implementation patterns, start with TressFX.
- For feathers, use this category as the closest creature-groom route. Translate feather cards, barbs,
  guide curves, LODs, and attachment behavior from hair/fur and groom donors unless a target project
  provides a dedicated feather donor.
- For ray-traced hair, hair BSDFs, LSS/DOTS geometry, or RTX path-tracing architecture, inspect RTXCR,
  RTXCR Material Library, and RTXCR Geometry Library after confirming the target project accepts their
  SDK-style dependency and license shape.
- For Vulkan ray-traced hair, pair RTXCR-specific hair material or LSS/DOTS research with
  `nvpro-vk-raytracing-tutorial-khr` for the safe Vulkan RT fundamentals: BLAS/TLAS, shader binding
  tables, shadow rays, and raw RT validation.
- Treat TressFX, HairWorks, Blender hair, USD curves, and Alembic as domain references even when their
  runtime/API lane differs from the target. Port simulation, strand layout, and render behavior through
  the selected Vulkan or CUDA lane instead of changing lanes because of the donor backend.
- For grooming UI and artist workflow ideas, study Blender hair curves but do not copy GPL code into
  permissive templates.
- Use Unreal HairStrands as the strongest study-only runtime groom reference for interpolation, binding,
  voxelization, visibility, deep shadows, and transmittance. Use Unity HDRP Hair mostly for material,
  Shader Graph, multiple-scattering, and line-rendering comparisons.
- For interchange, prefer OpenUSD curves for modern scene pipelines and Alembic for established
  animated-geometry/groom cache workflows.
- Treat HairWorks, Unreal, and Unity as study-only until a project has an explicit license path.
- Prefer TressFX for permissive implementation patterns when HairWorks and Blender only provide concept
  or artist-workflow references.

## Deep Profiles

- [AMD TressFX](profiles/tressfx.md): read before adapting realtime hair/fur simulation or rendering.
- [NVIDIA RTXCR](profiles/rtxcr.md): read before adapting ray-traced hair, LSS/DOTS geometry, Chiang/Far-Field hair shading, or RTX character-rendering shell behavior.
- [RTXCR Material Library](profiles/rtxcr-material-library.md): read before mapping hair material controls to RTXCR-style BSDF inputs.
- [RTXCR Geometry Library](profiles/rtxcr-geometry-library.md): read before adapting curve tessellation or LSS/DOTS geometry helper concepts.
- [nvpro Vulkan Ray Tracing Tutorial KHR](profiles/nvpro-vk-raytracing-tutorial-khr.md): read alongside RTXCR when the target implementation needs direct Vulkan RT fundamentals before hair-specific shading.
- [OpenUSD](profiles/openusd.md): read before choosing USD curves or scene composition for grooms.
- [Alembic](profiles/alembic.md): read before using baked animated curve or groom caches.
- [Blender Study-Only](profiles/blender-study-only.md): read for grooming UX, hair curves, geometry-node, and artist workflow concepts without code reuse.
- [NVIDIA HairWorks Study-Only](profiles/hairworks-study-only.md): read for GameWorks hair authoring/runtime concepts without code reuse.
- [Unreal HairStrands Study-Only](profiles/unreal-hairstrands-study-only.md): read for full groom runtime, interpolation, voxelization, deep shadow, and visibility architecture concepts without code reuse.
- [Unity HDRP Hair Study-Only](profiles/unity-hdrp-hair-study-only.md): read for HDRP hair material, multiple scattering, Shader Graph, and line-rendering concepts without code reuse.
