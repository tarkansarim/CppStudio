# NVIDIA Kaolin Donor Profile

Source: https://github.com/NVIDIAGameWorks/kaolin  
Tier: `dependency-candidate`  
Backend signal: native-cuda
Native C++ use: Python/PyTorch behavior reference only unless the user explicitly chooses that runtime.
License signal: Mostly Apache-2.0 signals with restricted `kaolin/non_commercial`; inspect
`LICENSE`, `kaolin/non_commercial`, examples, datasets, assets, and dependency notices at the exact
revision used.

## Use First For

- 3D deep-learning operators, differentiable rendering concepts, mesh/voxel/point-cloud conversions,
  camera conventions, metrics, and dataset utilities.
- Comparing PyTorch-based 3D ML component design against PyTorch3D, Open3D, Nerfstudio, or project-native
  C++ operators.
- Prototyping behavior for CUDA or Vulkan ports while avoiding restricted subpackages.

## First Upstream Areas To Inspect

- `kaolin/`, `tests/`, `examples/`, docs, and operator modules that match the target data type.
- `kaolin/non_commercial` only as a red-flag boundary, not as a reusable source.
- Dataset, checkpoint, and example-asset download paths before using fixtures.
- CUDA/PyTorch extension boundaries before porting behavior.

## Integration Notes

- Avoid `kaolin/non_commercial` for reusable code and templates.
- Keep data conversion, differentiable ops, training scripts, dataset tools, and runtime rendering
  separated.
- Use as a behavior and operator reference for Vulkan-first targets without adding CUDA/PyTorch unless
  explicitly chosen.
- Prefer narrower donors when only one mesh, voxel, or point-cloud operation is needed.

## Validation Ideas

- Add tiny mesh, voxel, point-cloud, and camera fixtures for selected operations.
- Compare CUDA/PyTorch outputs against CPU/debug references or independent implementations.
- Test degenerate geometry, empty batches, coordinate convention mismatches, and dtype/device handling.
- Record whether any reference came from restricted areas.

## Caveats

- Restricted subtrees must not leak into reusable CppStudio outputs.
- Python/PyTorch/CUDA dependency surfaces are substantial.
- Dataset and model licenses are independent from code.
