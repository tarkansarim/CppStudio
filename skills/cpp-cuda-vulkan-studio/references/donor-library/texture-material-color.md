# Texture, Material, And Color Donors

Use these donors for GPU texture containers, texture compression/transcoding, image IO, HDR/EXR,
color management, ACES/OCIO configs, and material/look-development exchange.

## Texture Containers And Compression

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [KTX-Software](https://github.com/KhronosGroup/KTX-Software) | dependency-candidate | Mostly Apache-2.0-compatible; license file has special cases | KTX/KTX2 texture IO, Basis Universal transcoding, Vulkan/glTF texture pipeline tooling. |
| [Basis Universal](https://github.com/BinomialLLC/basis_universal) | safe-donor | Apache-2.0 signals; inspect exact license | Supercompressed GPU texture codec and runtime transcoding concepts. |

## Image, Color, And Material Pipeline

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenImageIO](https://github.com/AcademySoftwareFoundation/OpenImageIO) | dependency-candidate | Apache-2.0 for original code; docs CC BY 4.0 | VFX-grade image IO, texture conversion, metadata, format-agnostic image processing. |
| [OpenColorIO](https://github.com/AcademySoftwareFoundation/OpenColorIO) | dependency-candidate | BSD-3-Clause style; inspect exact repo license | Color management, OCIO configs, DCC/renderer color consistency, ACES workflows. |
| [MaterialX](https://github.com/AcademySoftwareFoundation/MaterialX) | dependency-candidate | Apache-2.0 | Material/look-development graph interchange and shader generation. |
| [TinyEXR](https://github.com/syoyo/tinyexr) | safe-donor | BSD-3-Clause | Small EXR loading/writing patterns when OpenImageIO is too heavy. |

## Selection Notes

- Use KTX/KTX2 for runtime GPU texture delivery, especially Vulkan/glTF workflows.
- For whole-scene glTF/GLB runtime asset loading, read
  [gltf-runtime-assets.md](gltf-runtime-assets.md) before choosing texture or material dependencies.
- Use Basis Universal when universal compressed texture distribution/transcoding is the core issue.
- Use OpenImageIO and OpenColorIO for production DCC/VFX pipelines; they are usually dependencies, not
  snippets to copy.
- Use TinyEXR for dependency-minimal EXR/HDR fixtures or tools, not as a replacement for production
  color/image pipelines.
- Keep color configs, LUTs, sample textures, HDRIs, and material assets as separate license surfaces.

## Deep Profiles

- [KTX-Software And Basis Universal](profiles/ktx-basis.md): read before adding GPU texture pipeline support.
- [OpenColorIO And OpenImageIO](profiles/opencolorio-openimageio.md): read before adding color or image IO pipeline support.
- [MaterialX](profiles/materialx.md): read before adding material graph interchange.
- [TinyEXR](profiles/tinyexr.md): read before adding minimal EXR/HDR image loading, writing, or small renderer image fixtures.
