# OpenColorIO And OpenImageIO Donor Profile

Sources: https://github.com/AcademySoftwareFoundation/OpenColorIO and https://github.com/AcademySoftwareFoundation/OpenImageIO  
Tier: `dependency-candidate`  
License signal: OpenColorIO is BSD-3-Clause; OpenImageIO original code is Apache-2.0 with documentation
under CC BY 4.0 and compatible third-party licenses. Inspect license files, configs, plugins, codecs,
and sample images at the exact revision used.

## Use First For

- VFX-grade color management, OCIO config handling, display/view transforms, and ACES-style workflows.
- Production image IO, metadata, EXR/HDR handling, texture conversion, and format-agnostic processing.
- DCC-to-runtime image pipeline architecture where color correctness matters.
- Offline asset processing tools rather than tiny runtime-only image loading.

## First Upstream Areas To Inspect

- OpenColorIO processor/config APIs and tests for color transform behavior.
- OpenColorIO sample configs only after checking their own license and provenance.
- OpenImageIO ImageInput/ImageOutput, ImageBuf, and metadata APIs.
- OpenImageIO tool behavior for `oiiotool`, texture conversion, and format edge cases.
- Plugin/codec dependency lists before deciding target package requirements.

## Integration Notes

- Keep color config selection explicit. Do not bake a global OCIO assumption into reusable templates.
- Separate offline texture/image processing from runtime image loading.
- Preserve metadata that affects rendering: color space, display/view, data/window, channel order, alpha,
  orientation, bit depth, and compression.
- Use TinyEXR or narrower image donors when the task only needs simple EXR IO and not a full VFX image
  pipeline.

## Validation Ideas

- Round-trip a tiny image with metadata and verify dimensions, channels, type, and key metadata fields.
- Apply a known OCIO transform to a small color table and compare against a checked fixture.
- Test missing config, unsupported color space, unsupported codec, and high dynamic range values.
- Add visual diff fixtures for representative textures only after metadata tests are stable.

## Caveats

- OCIO configs, LUTs, sample images, and HDRIs have their own licenses.
- Image codec availability depends on build options and system packages.
- Color bugs are often silent; tests should pin numeric expectations, not just successful load/save.
