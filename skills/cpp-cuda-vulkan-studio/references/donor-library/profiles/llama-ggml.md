# llama.cpp And ggml Donor Profile

Sources: https://github.com/ggml-org/llama.cpp and https://ggml.ai/  
Tier: `safe-donor`  
Backend signal: mixed-backend
License signal: MIT for llama.cpp and ggml code; inspect `LICENSE`, `licenses/`, model conversion
tools, vendor code, examples, and model/weight licenses at the exact revision used.

## Use First For

- Local C/C++ LLM inference, GGUF model handling, quantization, tokenizer/model conversion, and small
  embeddable inference runtimes.
- Comparing CPU, CUDA, Vulkan, Metal, HIP, SYCL, and hybrid CPU/GPU backend organization.
- OpenAI-compatible local server behavior, command-line tooling, model loading, batching, sampling, and
  memory-footprint tradeoffs.

## First Upstream Areas To Inspect

- `include/`, `src/`, `ggml/`, `common/`, `examples/`, `tools/`, and `tests/` in llama.cpp.
- ggml tensor APIs, backend abstraction, quantization kernels, and GGUF utilities.
- Conversion scripts and Python tooling only when the target repo accepts that Python dependency surface.
- `licenses/`, `vendor/`, model-download helpers, and example assets before copying or vendoring.

## Integration Notes

- Treat model weights, GGUF files, tokenizer assets, prompts, and datasets as separate license surfaces.
- Keep runtime embedding, CLI/server wrappers, model conversion, and backend selection as separate modules.
- For Vulkan-first inference, use llama.cpp/ggml for backend and quantization ideas, then keep Vulkan
  shader/runtime policy in the Vulkan lane.
- For CUDA targets, use ggml/llama.cpp kernels as donor references only when they match the target
  operation; use CUTLASS or FlashAttention for matrix/attention kernels when they fit better.

## Validation Ideas

- Load a tiny model fixture or mock model metadata and verify deterministic tokenization/model-load
  errors separately from generation quality.
- Test quantized tensor shape, alignment, and dequantization reference paths.
- Record backend capability detection and clear fallback errors for unavailable GPU backends.
- Separate numerical checks, server API smoke tests, throughput records, and memory-footprint records.

## Caveats

- Upstream changes quickly; pin exact revisions when adopting APIs or command behavior.
- Model licenses and Hugging Face artifacts are independent from code license.
- Multi-backend support is a donor signal, not permission to silently add every backend to a target repo.
