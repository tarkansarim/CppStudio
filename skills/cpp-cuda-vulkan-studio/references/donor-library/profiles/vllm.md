# vLLM Donor Profile

Source: https://github.com/vllm-project/vllm  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
Native C++ use: service/runtime reference only, not a direct embedded C++ inference donor.
License signal: Apache-2.0; inspect `LICENSE`, `requirements/`, `csrc/`, kernel dependencies,
third-party notices, model integrations, and serving assets at the exact revision used.

## Use First For

- High-throughput LLM serving, paged KV cache, continuous batching, prefix caching, speculative decoding,
  OpenAI-compatible APIs, and distributed inference orchestration.
- Comparing serving architecture against TensorRT-LLM, llama.cpp server mode, or custom runtime wrappers.
- Understanding Python/C++/CUDA kernel boundaries for production serving.

## First Upstream Areas To Inspect

- `vllm/` for scheduler, serving, model executor, cache, and distributed runtime logic.
- `csrc/` for custom kernels and compiled extension boundaries.
- `benchmarks/`, `tests/`, `examples/`, and `docs/` for serving behavior and failure modes.
- `requirements/` and model integration files before adopting dependencies.

## Integration Notes

- Treat vLLM as a service/runtime dependency candidate, not a donor for small embedded C++ inference.
- Keep serving API, scheduler/cache policy, model weights, tokenizer assets, and GPU kernels separate.
- For CUDA projects, use vLLM serving and scheduling ideas before borrowing kernel code; use narrower
  kernel donors when the task is only an operator.
- For Vulkan/portable targets, use vLLM for serving architecture concepts but do not add CUDA runtime
  requirements by default.

## Validation Ideas

- Smoke an OpenAI-compatible request path with a tiny model or documented test fixture.
- Test missing model, tokenizer mismatch, unsupported quantization, OOM, batching, streaming, and
  cancellation behavior.
- Record model revision, serving config, parallelism settings, cache policy, and backend hardware.
- Separate API correctness, throughput, latency, and memory tests.

## Caveats

- It is Python/service shaped even though it includes C++/CUDA code.
- Performance behavior depends heavily on model, quantization, scheduler, batch shape, and hardware.
- Model weights and downloaded artifacts are separate license surfaces.
