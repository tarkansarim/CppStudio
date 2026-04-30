# Triton Donor Profile

Source: https://github.com/triton-lang/triton  
Tier: `safe-donor`  
License signal: MIT; inspect `LICENSE`, `third_party/`, and compiler/runtime dependencies at the exact
revision used.

## Use First For

- Python-authored GPU kernels for deep-learning primitives.
- MLIR/compiler architecture for tiled tensor programs.
- Rapid kernel iteration where a Python runtime and JIT/compiler dependency are acceptable.
- Comparative kernel prototypes before committing to hand-written CUDA C++.

## First Upstream Areas To Inspect

- Official Triton documentation linked from the repository README.
- `python/` for front-end API and runtime behavior.
- `lib/` and compiler-related directories for MLIR/lowering concepts.
- `test/` or `tests/` for correctness and backend coverage patterns.
- Tutorials and examples for matmul, reductions, softmax, and fused operations.

## Integration Notes

- Treat Triton as a runtime/compiler dependency, not a drop-in C++ CUDA library.
- Use Triton to prototype a kernel shape only if the target project can accept Python or generated-code
  tooling in its workflow.
- Preserve a C++/CUDA path when the deliverable must be standalone native code.
- Document whether Triton code is production runtime, research prototype, or benchmark baseline.

## Validation Ideas

- Compare against PyTorch, cuBLAS/cuDNN, or a C++ reference.
- Benchmark warmup/JIT cost separately from steady-state kernel time.
- Test generated kernels on every GPU architecture the project claims.
- Keep reproducible scripts for generated code, cache location, and dependency versions.

## Caveats

- Triton is excellent for ML kernel productivity, but it changes the deployment shape of a C++ repo.
- JIT compilation, Python packaging, and backend support can dominate integration risk.
- Do not cite Triton performance without separating compilation overhead from steady-state execution.
