# PyTorch Donor Profile

Source: https://github.com/pytorch/pytorch  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
Native C++ use: dependency-scale architecture/reference only unless the user explicitly chooses PyTorch or
libtorch integration.
License signal: BSD-style; inspect `LICENSE`, `NOTICE`, `third_party/`, generated code, binary package
notices, CUDA/ROCm/oneDNN/MKL/NCCL/cuDNN dependencies, and model/assets licenses at the exact revision used.

## Use First For

- Tensor/autograd/runtime architecture, dispatch systems, extension patterns, CUDA/CPU operator testing,
  and Python/C++ API boundaries.
- Studying custom operator packaging, ATen-style tensor semantics, memory formats, and numerical test
  organization.
- Integrating model or training workflows when the target repo explicitly accepts PyTorch as a dependency.

## First Upstream Areas To Inspect

- `aten/`, `c10/`, `torch/`, `torch/csrc/`, `test/`, `benchmarks/`, and extension examples.
- Dispatch, tensor metadata, CUDA/CPU kernels, autograd, serialization, and package/build boundaries.
- `third_party/`, binary package notices, and CUDA/ROCm vendor dependency terms before integration.

## Integration Notes

- Treat PyTorch as a package dependency or architecture reference, not a snippet donor for reusable C++
  infrastructure.
- Keep training scripts, custom ops, C++ extensions, model export, and runtime inference separated.
- For pure C++/Vulkan targets, prefer ONNX Runtime, MLC-LLM, TVM, or project-native backends unless
  PyTorch is explicitly required.
- Use PyTorch reference outputs to validate CUDA/Vulkan custom kernels when the project already has a
  Python test lane.

## Validation Ideas

- Compare custom op outputs to PyTorch references with tolerances and shape/dtype coverage.
- Test CPU/CUDA parity, non-contiguous tensors, empty tensors, dtype promotion, and gradient behavior
  only when gradients matter.
- Keep Python package, C++ extension, and project-native tests separately labelled.
- Record PyTorch, CUDA/ROCm, driver, and dependency versions for numerical/performance evidence.

## Caveats

- PyTorch is dependency-scale and can dominate build, ABI, packaging, and deployment policy.
- Binary packages and optional accelerator libraries carry separate notices.
- Do not introduce PyTorch solely to get a convenient test reference without user approval.
