# TensorRT-LLM Donor Profile

Source: https://github.com/NVIDIA/TensorRT-LLM  
Tier: `dependency-candidate`  
Backend signal: native-cuda
License signal: Apache-2.0 signals for TensorRT-LLM repository code; inspect `LICENSE`, `NOTICE`,
third-party dependencies, TensorRT/CUDA/cuDNN/NCCL terms, model assets, and container notices.

## Use First For

- NVIDIA-optimized LLM serving, TensorRT engine orchestration, KV cache policy, batching, parallelism,
  quantization, and high-throughput deployment patterns.
- C++/Python runtime boundaries for TensorRT-backed inference.
- Comparing TensorRT-LLM against vLLM when the target is explicitly NVIDIA GPU serving.

## First Upstream Areas To Inspect

- `tensorrt_llm/`, `cpp/`, `examples/`, `benchmarks/`, and runtime APIs.
- Engine build, model conversion, plugin, quantization, and serving examples for the target model family.
- Docker/container files and deployment docs for CUDA/TensorRT version constraints.
- Third-party and model notices before copying examples or recommending containers.

## Integration Notes

- Use only when the user chose an NVIDIA/CUDA inference lane or requirements force TensorRT.
- Keep model conversion, engine build, runtime serving, tokenizer handling, and deployment packaging
  separate.
- Do not add TensorRT-LLM to Vulkan-first or CPU-portable projects as a hidden dependency.
- Treat generated engines and calibration artifacts as build/deployment outputs, not source assets.

## Validation Ideas

- Run a tiny supported model or documented smoke fixture through engine build and inference.
- Test missing TensorRT/CUDA version, unsupported model architecture, unsupported quantization, and OOM
  failures explicitly.
- Record engine metadata, GPU architecture, TensorRT version, and tokenizer/model revision.
- Compare output correctness before throughput or latency measurements.

## Caveats

- Deployment is tightly coupled to NVIDIA driver, CUDA, TensorRT, plugin, and GPU architecture versions.
- Model weights, calibration data, and generated engines have separate provenance.
- It is not a portable inference donor; use ONNX Runtime, MLC-LLM, llama.cpp, or TVM for portability.
