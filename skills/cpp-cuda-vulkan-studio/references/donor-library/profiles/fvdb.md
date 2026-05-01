# fVDB Donor Profile

Source: https://openvdb.github.io/fvdb-core/  
Tier: `dependency-candidate`  
Backend signal: native-cuda, native-cpu
License signal: Apache-2.0 as part of the OpenVDB project; inspect repository license files,
PyTorch/CUDA extension code, NVIDIA components, examples, notebooks, datasets, and model assets at the
exact revision used.

## Use First For

- GPU sparse-volume tensors, jagged tensor batching, sparse convolutions, neural 3D volumes, and
  PyTorch-facing large-domain spatial ML.
- Volume rendering, ray queries, sparse grid topology/data separation, and NanoVDB-backed GPU workflows.
- Comparing neural-volume or sparse-grid ML behavior against OpenVDB/NanoVDB runtime volume paths.

## First Upstream Areas To Inspect

- Documentation for sparse grids, jagged tensors, neural network layers, volume rendering, and IO.
- CUDA/PyTorch extension boundaries before adopting build or package patterns.
- Tutorials and TEACHME-style lessons for expected user workflow and API shape.
- Dataset, reconstruction, visualization, and notebook assets before using fixtures.

## Integration Notes

- Treat fVDB as an ML/research/runtime dependency candidate, not a lightweight C++ volume loader.
- Keep sparse grid topology, tensor attributes, neural network layers, visualization, and file IO as
  separate integration boundaries.
- For Vulkan volume renderers, use fVDB as a behavior and data-layout reference without adding Python,
  PyTorch, or CUDA runtime dependencies unless explicitly chosen.
- Prefer OpenVDB/NanoVDB when the task is production VDB IO or static GPU traversal rather than ML.

## Validation Ideas

- Build tiny sparse-grid fixtures with empty, dense, sparse, and large-coordinate bounds.
- Test jagged batch behavior, missing CUDA/PyTorch support, unsupported dtype, and invalid grid metadata.
- Compare neural or volume-rendering outputs against deterministic small fixtures.
- Keep dataset/model tests separate from code/runtime tests.

## Caveats

- fVDB is Python/PyTorch and CUDA-extension oriented.
- Volume datasets, trained models, notebooks, and visualization assets are separate license surfaces.
- It should not silently move a Vulkan target into the CUDA or Python lane.
