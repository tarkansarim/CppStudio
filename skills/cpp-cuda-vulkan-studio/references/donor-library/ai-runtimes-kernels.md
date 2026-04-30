# AI Runtime, Kernel, And Compiler Donors

Use these donors for local inference, LLM serving, tensor runtimes, CUDA kernels, attention,
quantization, and ML compiler patterns.

## Inference And Serving

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [llama.cpp](https://github.com/ggml-org/llama.cpp) | safe-donor | MIT | Portable C/C++ LLM inference, GGUF, quantization, CPU/CUDA/Vulkan/Metal backend patterns, OpenAI-compatible server. |
| [ggml](https://ggml.ai/) | safe-donor | MIT | Minimal tensor library design, quantized ops, portable backend abstractions. |
| [ONNX Runtime](https://github.com/microsoft/onnxruntime) | dependency-candidate | MIT | Cross-platform model inference, execution providers, graph optimization, production serving API patterns. |
| [TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM) | dependency-candidate | Apache-2.0 plus notices | NVIDIA-optimized LLM serving, batching, KV cache, C++ runtime orchestration, TensorRT integration. |
| [vLLM](https://github.com/vllm-project/vllm) | dependency-candidate | Apache-2.0 | High-throughput LLM serving, paged attention, continuous batching, OpenAI-compatible API. |
| [MLC-LLM](https://github.com/mlc-ai/mlc-llm) | dependency-candidate | Apache-2.0 | Cross-platform compiled LLM deployment, TVM-backed GPU/mobile/WebGPU runtime ideas. |

## Kernels And Compilers

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [CUTLASS](https://github.com/NVIDIA/cutlass) | safe-donor | BSD-3-Clause | CUDA GEMM/convolution/reduction templates, tiling policies, Blackwell/Hopper/Ampere kernels. |
| [Triton](https://github.com/triton-lang/triton) | safe-donor | MIT | Python-authored GPU kernels, MLIR compiler design, custom deep-learning primitives. |
| [FlashAttention](https://github.com/Dao-AILab/flash-attention) | safe-donor | BSD-3-Clause | Efficient attention kernels, IO-aware algorithm design, CUDA/PyTorch extension patterns. |
| [tiny-cuda-nn](https://github.com/NVlabs/tiny-cuda-nn) | safe-donor | BSD-3-Clause | Fused MLPs, multiresolution hash encodings, compact CUDA neural-network kernels. |
| [Apache TVM](https://github.com/apache/tvm) | dependency-candidate | Apache-2.0 | ML compiler pipelines, tensor IR, GPU/Vulkan/OpenCL/Metal/WebGPU targets, auto-tuning. |
| [PyTorch](https://github.com/pytorch/pytorch) | dependency-candidate | BSD-style | Tensor/autograd/runtime architecture, extension patterns, CUDA dispatch conventions. Usually study architecture or integrate through package dependencies. |

## Selection Notes

- For simple local LLM integration, start with llama.cpp/ggml.
- For production model serving on NVIDIA GPUs, compare TensorRT-LLM and vLLM; use ONNX Runtime when model portability matters.
- For CUDA kernel authoring, use CUTLASS for matrix math and FlashAttention/tiny-cuda-nn for domain-specific fused kernel patterns.
- For DSL/compiler exploration, Triton and TVM are better donors than hand-written CUDA when portability or code generation is the goal.
- For Vulkan, OpenCL, WebGPU, or CPU inference targets, CUDA-heavy donors still provide useful algorithm,
  tiling, numerical, and test references. Do not add CUDA runtime requirements unless the user chose the
  CUDA lane or a CUDA-specific dependency is required.

## Deep Profiles

- [CUTLASS](profiles/cutlass.md): read before adapting CUDA matrix math, tiling, CuTe, or tensor-core kernel policy.
- [FlashAttention](profiles/flashattention.md): read before adapting attention kernels or IO-aware fused attention patterns.
- [Triton](profiles/triton.md): read before recommending Triton as a runtime/compiler dependency or benchmark donor.
