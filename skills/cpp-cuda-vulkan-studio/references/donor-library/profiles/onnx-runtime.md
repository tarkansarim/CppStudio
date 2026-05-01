# ONNX Runtime Donor Profile

Source: https://github.com/microsoft/onnxruntime  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: MIT for ONNX Runtime code; inspect `LICENSE`, `ThirdPartyNotices.txt`, execution
provider dependencies, generated code, training components, and package notices at the exact revision used.

## Use First For

- Cross-platform model inference, graph optimization, execution provider routing, model IO, and production
  inference API patterns.
- Comparing CUDA, TensorRT, DirectML, CPU, OpenVINO, NNAPI, Web, and other execution-provider boundaries.
- ONNX model validation, session configuration, allocator/threading policy, and operator-coverage
  diagnostics.

## First Upstream Areas To Inspect

- `onnxruntime/core/` for session, graph, allocator, and provider architecture.
- Execution provider directories for CUDA, TensorRT, CPU, DirectML, OpenVINO, and platform-specific code.
- `onnxruntime/test/` for model/session/operator tests and failure modes.
- Build files, package manifests, and third-party notices before dependency adoption.

## Integration Notes

- Treat ONNX Runtime as a deliberate dependency boundary, not a snippet donor.
- Keep model conversion/export, runtime session creation, execution-provider selection, and result
  postprocessing separate.
- Document exact provider requirements and fallback order; do not hide missing provider libraries behind
  CPU-only success.
- For Vulkan or CUDA target repos, route backend-specific work through the active lane instead of copying
  execution-provider internals.

## Validation Ideas

- Run one tiny ONNX fixture through CPU and the selected provider, comparing outputs with tolerances.
- Test missing provider, unsupported operator, dynamic-shape, external-data, and invalid-model failures.
- Capture model metadata, opset, provider list, and provider options in test logs.
- Add performance smoke records only after numerical fixtures pass.

## Caveats

- Provider dependencies can change the effective license and deployment footprint.
- Training and inference surfaces have different dependency cost.
- Exact model opset/operator coverage matters more than generic ONNX compatibility claims.
