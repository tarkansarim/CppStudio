# Nerfstudio Donor Profile

Source: https://github.com/nerfstudio-project/nerfstudio  
Tier: `dependency-candidate`  
Backend signal: native-cuda
License signal: Apache-2.0; inspect `LICENSE`, dependencies, viewer assets, datasets, model checkpoints,
examples, and plugin/package notices at the exact revision used.

## Use First For

- NeRF and Gaussian-splatting training workflows, camera/data processing, experiment configuration,
  viewer/export flows, and neural 3D pipeline organization.
- Dataset/camera convention handling, scene normalization, evaluation, metrics, and experiment structure.
- Comparing neural 3D workflow shape before choosing lower-level donors such as gsplat, PyTorch3D,
  Kaolin, tiny-cuda-nn, or Open3D.

## First Upstream Areas To Inspect

- `nerfstudio/`, `scripts/`, `tests/`, docs, viewer code, and pipeline/dataparser/model modules.
- Export and viewer paths for runtime handoff ideas.
- Dataset download helpers, model checkpoints, and examples before using fixtures.
- Plugin and package dependency surfaces before recommending integration.

## Integration Notes

- Use Nerfstudio as a workflow/reference donor; do not copy its full Python training stack into C++
  infrastructure.
- Keep capture/dataset ingestion, training, evaluation, export, viewer/runtime, and renderer integration
  separate.
- For Vulkan-first viewers, use Nerfstudio for camera/data/export conventions, then implement rendering
  through Vulkan donors.
- Prefer gsplat for permissive low-level 3DGS rasterization patterns.

## Validation Ideas

- Test camera convention, transform, bounds, scale, and image-set metadata on tiny synthetic fixtures.
- Validate exported assets or splat/mesh outputs before renderer upload.
- Separate training metrics, viewer smoke tests, and runtime import tests.
- Track dataset/model provenance independently of code.

## Caveats

- Nerfstudio is Python/PyTorch workflow shaped and can pull substantial dependencies.
- Datasets, captures, trained weights, viewer assets, and generated exports have separate licenses.
- It is not a C++ runtime donor by itself.
