# Assets, Meshes, Materials, And NURBS Donors

Use these donors for NURBS/Rhino asset interchange, UV atlas generation, compressed geometry,
offline texture conversion, material semantics, and production asset-management pipelines. For glTF
runtime loading start with [gltf-runtime-assets.md](gltf-runtime-assets.md); for full CAD kernels
start with [cad-precision-geometry.md](cad-precision-geometry.md).

## NURBS And CAD Asset IO

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenNURBS](https://github.com/mcneel/opennurbs) | dependency-candidate | Custom openNURBS license; review exact terms | Rhino `.3dm` interchange, NURBS curves/surfaces, CAD-to-renderer asset handoff. |
| [tinynurbs](https://github.com/pradeep-pyro/tinynurbs) | safe-donor | BSD-3-Clause | Compact C++14 NURBS curves/surfaces, derivatives, knot insertion, splitting, and tiny fixtures. |

## Mesh Conditioning And Asset Delivery

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [meshoptimizer](profiles/meshoptimizer.md) | safe-donor | MIT | Runtime mesh optimization, simplification, compression, and glTF meshopt pipelines. |
| [xatlas](https://github.com/jpcy/xatlas) | safe-donor | MIT | UV unwrapping, atlas generation, lightmap UVs, texture-baking prep, and coordinate repair. |
| [Draco](https://github.com/google/draco) | dependency-candidate | Apache-2.0 | Mesh and point-cloud compression, `KHR_draco_mesh_compression`, streaming asset delivery. |

## Texture Tooling And Material Semantics

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [KTX-Software and Basis Universal](profiles/ktx-basis.md) | dependency-candidate | KTX license has special cases; Basis has Apache-2.0 signals | KTX2 texture containers and GPU texture transcoding. |
| [Arm ASTC Encoder](https://github.com/ARM-software/astc-encoder) | dependency-candidate | Apache-2.0 | ASTC compression, mobile/cross-platform texture delivery, quality/performance presets. |
| [DirectXTex](https://github.com/microsoft/DirectXTex) | dependency-candidate | MIT | DDS/TGA/HDR/WIC processing, mip generation, BC formats, and Windows texture tooling. |
| [MaterialX](profiles/materialx.md) | dependency-candidate | Apache-2.0 | Material graph interchange and shader-generation boundaries. |
| [OpenPBR](https://github.com/AcademySoftwareFoundation/OpenPBR) | dependency-candidate | Apache-2.0 | Material semantics, OpenPBR/MaterialX bridge decisions, DCC-to-renderer material fidelity. |
| [OpenAssetIO](https://github.com/OpenAssetIO/OpenAssetIO) | dependency-candidate | Apache-2.0 | Asset identity, publishing, production asset resolver boundaries, and DCC pipeline integration. |

## Selection Notes

- Use tinynurbs for lightweight native C++ NURBS math; use OpenNURBS when `.3dm` interoperability is
  the requirement.
- Use xatlas before writing a custom UV atlas generator.
- Use Draco for compressed geometry interoperability, not as a general mesh optimizer.
- Use Arm ASTC Encoder and DirectXTex as offline/content-pipeline donors; keep runtime Vulkan upload
  policy in the Vulkan lane.
- Keep OpenAssetIO out of runtime asset loading unless the target explicitly needs production asset
  identity and publishing.
- Treat CAD source files, DCC assets, material libraries, texture corpora, and sample scenes as
  separate provenance surfaces.

## Deep Profiles

- [Asset Pipeline, NURBS, And Texture Tooling](profiles/asset-pipeline-nurbs-textures.md): read before designing NURBS asset import, UV atlas generation, compressed geometry, offline texture conversion, OpenPBR, or OpenAssetIO integration.
- [meshoptimizer](profiles/meshoptimizer.md): read before designing mesh conditioning, simplification, compression, or glTF meshopt pipelines.
- [KTX-Software and Basis Universal](profiles/ktx-basis.md): read before adding GPU texture pipeline support.
- [MaterialX](profiles/materialx.md): read before adding material graph interchange.
