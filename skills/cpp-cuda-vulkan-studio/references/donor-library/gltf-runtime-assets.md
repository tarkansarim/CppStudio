# glTF Runtime Asset Donors

Use these donors for runtime 3D asset loading, glTF validation, test fixtures, mesh and material
handoff, and Vulkan viewer/importer pipelines.

## Specification, Validation, And Fixtures

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Khronos glTF](https://github.com/KhronosGroup/glTF) | dependency-candidate | Khronos specification/license terms; inspect `LICENSES/`, `LICENSE.adoc`, and `COPYING.adoc` | glTF 2.0 schema, extensions, runtime asset semantics, PBR material rules, animation/skinning rules, and interoperability requirements. |
| [Khronos glTF Validator](https://github.com/KhronosGroup/glTF-Validator) | dependency-candidate | Apache-2.0 signals; inspect exact repo license and packages | Asset validation reports, importer CI checks, GLB correctness, JSON schema validation, and extension compatibility checks. |
| [Khronos glTF Sample Assets](https://github.khronos.org/glTF-Assets/) | study-only | Per-asset license metadata; inspect every model before reuse | Importer/viewer fixtures, PBR and extension coverage, animation/skinning samples, KTX/WebP/Meshopt/Draco test coverage. |

## C And C++ Loaders

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [fastgltf](https://github.com/spnda/fastgltf) | safe-donor | MIT | Modern C++17 glTF parsing, GLB loading, extension handling, buffer-source policy, and direct asset-to-runtime staging. |
| [cgltf](https://github.com/jkuhlmann/cgltf) | safe-donor | MIT | Small single-file C99 glTF loader/writer patterns, dependency-minimal import tests, and easy vendoring review. |
| [tinygltf](https://github.com/syoyo/tinygltf) | safe-donor | MIT | Header-only C++ glTF loading/saving, lightweight importer tests, and small tool prototypes. |

## Selection Notes

- Use the Khronos specification and validator before treating a loader failure as a renderer bug.
- For reusable C++ runtime importers, compare fastgltf, cgltf, and tinygltf against the target repo's
  C++ standard, dependency policy, extension needs, and asset-size expectations.
- Keep mesh optimization, texture containers, material graphs, and color management routed through
  `geometry-simulation.md`, `texture-material-color.md`, and DCC/material profiles instead of forcing
  all asset policy into the loader.
- Treat sample assets, screenshots, source DCC files, model textures, and HDRIs as separate license
  surfaces from loader code.
- For Vulkan viewers, keep CPU import, GPU buffer staging, texture upload, material translation, and
  render-pipeline state as separate modules and tests.

## Deep Profiles

- [glTF C/C++ Loaders](profiles/fastgltf-cgltf-tinygltf.md): read before choosing or adapting a glTF runtime loader.
- [KTX-Software And Basis Universal](profiles/ktx-basis.md): read when glTF textures use KTX2, Basis Universal, or runtime transcoding.
- [MaterialX](profiles/materialx.md): read when glTF materials must bridge into DCC or shader-generation pipelines.
