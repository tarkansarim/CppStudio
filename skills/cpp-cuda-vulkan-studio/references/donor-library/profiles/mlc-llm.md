# MLC-LLM Donor Profile

Source: https://github.com/mlc-ai/mlc-llm  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0; inspect `LICENSE`, TVM dependencies, compiled runtime artifacts, mobile/Web
packaging, model assets, and third-party notices at the exact revision used.

## Use First For

- Cross-platform compiled LLM deployment across GPU, mobile, browser, and native runtime targets.
- TVM-backed model compilation, runtime packaging, quantization, WebGPU/mobile deployment, and portable
  serving ideas.
- Comparing ahead-of-time compiled inference against llama.cpp, ONNX Runtime, TensorRT-LLM, and vLLM.

## First Upstream Areas To Inspect

- `python/mlc_llm/`, `cpp/`, examples, docs, and package/build scripts.
- Model compilation, quantization, runtime packaging, serving, Android/iOS/WebGPU, and CLI examples.
- TVM integration boundaries and generated artifacts.
- Third-party notices and model download paths before adopting package workflows.

## Integration Notes

- Treat compiled model artifacts and generated libraries as deployment outputs with their own provenance.
- Keep model conversion, compilation, runtime loading, serving, and platform packaging separate.
- For Vulkan/WebGPU-style portability, use MLC-LLM as a compiler/runtime architecture donor, not as a
  reason to skip project-owned Vulkan validation.
- Preserve exact compiler/runtime version coupling in docs and tests.

## Validation Ideas

- Compile and run a tiny supported model or official smoke fixture on one selected backend.
- Test missing compiler runtime, unsupported backend, unsupported model, missing generated artifact, and
  mismatched artifact/runtime version.
- Record compilation config, quantization, target backend, generated files, and model revision.
- Compare numerical output before measuring latency or footprint.

## Caveats

- Compiler/runtime stacks are version-sensitive and artifact-heavy.
- Mobile and browser targets introduce packaging, SDK, and store-policy surfaces.
- Model licenses and generated outputs are separate from repository code.
