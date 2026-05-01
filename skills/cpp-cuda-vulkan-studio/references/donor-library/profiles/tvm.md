# Apache TVM Donor Profile

Source: https://github.com/apache/tvm  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0; inspect `LICENSE`, `NOTICE`, `3rdparty/`, generated code, runtime
dependencies, model inputs, and target-specific libraries at the exact revision used.

## Use First For

- ML compiler architecture, tensor IR, graph/runtime separation, scheduling, auto-tuning, generated
  kernels, and multi-target deployment.
- Comparing CUDA, Vulkan, OpenCL, Metal, WebGPU, CPU, and accelerator code generation boundaries.
- Runtime packaging and compiler/runtime versioning ideas for model deployment.

## First Upstream Areas To Inspect

- `src/`, `include/`, `python/`, `tests/`, `apps/`, and target/runtime directories.
- Tutorials for Relay/Relax, tensor expressions, scheduling, auto-tuning, and selected target backends.
- Generated-code and runtime-loading examples before adopting a compiler workflow.
- `3rdparty/`, target libraries, and package notices before dependency decisions.

## Integration Notes

- Treat TVM as a compiler stack dependency, not a direct replacement for hand-written kernels by default.
- Keep model import, scheduling/compilation, generated artifacts, runtime loading, and target backend
  validation separate.
- For Vulkan/CUDA projects, generated code must still obey the active lane's build, validation, and
  profiler policy.
- Preserve exact compiler/runtime/target versions when recording benchmark or correctness evidence.

## Validation Ideas

- Compile a tiny operator/model for the selected backend and compare against a reference output.
- Test unsupported operator, target feature mismatch, missing runtime artifact, and generated-code
  version mismatch.
- Record target string, schedule, generated files, runtime library, and input shapes.
- Separate compiler tests from target runtime smoke tests.

## Caveats

- TVM adds compiler complexity and generated artifacts.
- Auto-tuning results are hardware and shape specific.
- Multi-target support is not a reason to enable unrelated runtime backends in the target project.
