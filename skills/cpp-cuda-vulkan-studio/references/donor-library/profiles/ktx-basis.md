# KTX-Software And Basis Universal Donor Profile

Sources: https://github.com/KhronosGroup/KTX-Software and https://github.com/BinomialLLC/basis_universal  
Tier: `dependency-candidate` for KTX-Software, `safe-donor` for narrow Basis Universal transcoder
patterns  
Backend signal: api-agnostic, native-vulkan, native-cpu
License signal: KTX-Software files generally fall under Apache-2.0 with many compatible licenses and
special cases; Basis Universal is Apache-2.0 with third-party codec/dependency notices. Inspect
`LICENSE.md`, `LICENSES/`, `.reuse/dep5`, `NOTICE`, and codec subdirectories at the exact revision used.

## Use First For

- KTX/KTX2 texture containers, mip levels, array/cubemap metadata, supercompression, and Vulkan texture
  delivery.
- Basis Universal compression/transcoding concepts and runtime GPU texture format negotiation.
- glTF-oriented texture pipelines and cross-GPU texture asset packaging.
- Tooling decisions around offline texture processing versus runtime transcoding.

## First Upstream Areas To Inspect

- KTX-Software library and command-line tools for read/write and conversion behavior.
- KTX-Software tests for container metadata and format edge cases.
- Basis Universal transcoder code for runtime format selection and dependency-minimal decode paths.
- Basis encoder code only when offline compression behavior is part of the target tool.
- License manifests before copying any codec, third-party, or tool code.

## Integration Notes

- Keep offline compression tools separate from runtime texture loading.
- In Vulkan paths, test format feature support before selecting a transcoded target format.
- Track color space, mip count, image orientation, normal-map handling, HDR/LDR state, and alpha mode in
  texture fixtures.
- Prefer library/tool invocation for full KTX workflows; adapt small runtime concepts only when the target
  dependency policy requires it.

## Validation Ideas

- Load a tiny KTX2 texture with mip levels and verify dimensions, format, levels, and upload layout.
- Test fallback transcoding across BC, ETC, ASTC, PVRTC, and uncompressed paths only on devices that
  advertise the required format features.
- Add a normal-map fixture and an sRGB/base-color fixture to catch color-space mistakes.
- Compare runtime output against an offline-converted reference image.

## Caveats

- KTX-Software has explicit special-case files and many incorporated licenses. Check file-level license
  metadata before copying.
- Texture assets, HDRIs, and sample files are separate license surfaces.
- Runtime transcoding choices are hardware-dependent; avoid hard-coding one compressed target format.
