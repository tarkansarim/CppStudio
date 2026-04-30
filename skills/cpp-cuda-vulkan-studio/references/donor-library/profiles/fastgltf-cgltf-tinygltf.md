# glTF C/C++ Loaders Donor Profile

Sources: https://github.com/spnda/fastgltf, https://github.com/jkuhlmann/cgltf, and
https://github.com/syoyo/tinygltf  
Tier: `safe-donor`  
Backend signal: api-agnostic, native-cpu
License signal: fastgltf, cgltf, and tinygltf have MIT license signals. Inspect `LICENSE`, bundled
JSON/image/base64 dependencies, examples, and tests at the exact revision used.

## Use First For

- Runtime glTF/GLB import, lightweight asset tests, buffer/image URI handling, and extension policy.
- Choosing between modern C++17 APIs, single-file C loaders, and header-only C++ loaders.
- Separating CPU asset parsing from Vulkan buffer staging, texture upload, and material translation.

## First Upstream Areas To Inspect

- fastgltf parser options, asset model, extension handling, and examples.
- cgltf single-file loader/writer API and tests for dependency-minimal pipelines.
- tinygltf loader/saver API, image/JSON dependencies, examples, and known TODOs.
- Khronos validator and sample assets before classifying importer failures.

## Integration Notes

- Keep importer output as CPU-side asset data; use a separate renderer module for GPU upload.
- Track coordinate system, units, node transforms, skinning, animation interpolation, material alpha,
  texture color space, and extension support explicitly.
- Keep Draco, Meshopt, KTX2, WebP, and other optional extension support behind dependency choices.
- Do not copy sample assets into reusable templates without per-asset license review.

## Validation Ideas

- Validate fixtures with Khronos glTF Validator before testing importer behavior.
- Load tiny GLB, external-buffer glTF, textured material, animation, skinning, morph target, and sparse
  accessor fixtures as separate tests.
- Compare parsed bounds, material alpha mode, texture color space, and animation sample values against
  expected fixture metadata.
- Add a Vulkan viewer smoke only after CPU import and GPU upload are separately testable.

## Caveats

- Loader libraries do not define renderer material policy or GPU resource lifetime.
- Some glTF extensions require additional codecs or compression libraries with separate licenses.
- Sample models, textures, screenshots, and DCC source files are independent license surfaces.
