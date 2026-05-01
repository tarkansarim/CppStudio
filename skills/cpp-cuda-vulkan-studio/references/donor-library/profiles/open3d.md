# Open3D Donor Profile

Source: https://github.com/isl-org/Open3D  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: MIT for core Open3D; inspect `LICENSE`, `3rdparty/`, examples, datasets, Open3D-ML
dependencies, viewer assets, and binary package notices at the exact revision used.

## Use First For

- Point clouds, reconstruction, registration, mesh processing, visualization, PBR viewer patterns, and
  3D ML integration.
- C++/Python API comparisons for geometry processing and point-cloud pipelines.
- Open3D-ML workflows when 3D perception, segmentation, or reconstruction connects to neural 3D work.

## First Upstream Areas To Inspect

- `cpp/`, `python/`, `examples/`, `docs/`, `tests`, and CMake integration.
- Geometry, pipelines, tensor, visualization, rendering, and Open3D-ML entry points.
- `3rdparty/`, viewer assets, example data, and ML model/dataset paths before integration.

## Integration Notes

- Use Open3D as a dependency candidate for broad 3D data processing, not a small snippet donor.
- Keep point-cloud processing, reconstruction, visualization, ML, and renderer handoff as separate
  modules.
- For C++/Vulkan projects, use Open3D for CPU/GPU data processing and reference outputs; keep final
  Vulkan upload/render policy in the Vulkan lane.
- Do not treat Open3D-ML dependencies as part of the core C++ geometry dependency by default.

## Validation Ideas

- Test tiny point cloud, mesh, normal estimation, registration, reconstruction, and IO fixtures as needed.
- Compare bounds, units, transforms, normals, and topology after processing.
- Label Open3D-ML and visualization tests separately from core C++ processing tests.
- Check headless/offscreen viewer behavior only when visualization is in scope.

## Caveats

- Open3D is broad and dependency-scale, especially with Open3D-ML.
- Example datasets, viewer assets, and pretrained models have separate licenses.
- GPU acceleration details are not a substitute for target-project Vulkan or CUDA lane validation.
