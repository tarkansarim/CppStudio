## Donor References

When selecting external CUDA kernel, GPU runtime, ML inference runtime, or GPU compiler donors, read:

- `{{DONOR_ROOT}}/selection-policy.md`
- `{{DONOR_ROOT}}/ai-runtimes-kernels.md`
- `{{DONOR_ROOT}}/profiles/cutlass.md` for GEMM/convolution/reduction/tensor-core policy
- `{{DONOR_ROOT}}/profiles/flashattention.md` for attention kernels
- `{{DONOR_ROOT}}/profiles/triton.md` for Triton DSL/compiler tradeoffs

Use the donor library to compare CUTLASS, Triton, FlashAttention, tiny-cuda-nn, llama.cpp/ggml,
ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, and PyTorch before writing or recommending custom
GPU code for attention, softmax, layernorm, GEMM-like, quantized, fused, or runtime-integrated
kernels. Keep non-commercial or study-only donors out of reusable implementation code.
