# FlashAttention Donor Profile

Source: https://github.com/Dao-AILab/flash-attention  
Tier: `safe-donor`  
License signal: BSD-3-Clause; inspect `LICENSE`, `third_party/`, and Python package metadata at the
exact revision used.

## Use First For

- Exact attention kernels where memory traffic is the limiting cost.
- IO-aware algorithm structure, tiled attention, softmax stability, and fused forward/backward patterns.
- CUDA/PyTorch extension packaging for high-performance attention operators.
- Benchmark and correctness tests for attention variants.

## First Upstream Areas To Inspect

- `csrc/` for CUDA/C++ extension implementation.
- `hopper/` for Hopper-focused paths and architecture-specific organization.
- `benchmarks/` for attention performance measurement patterns.
- `tests/` for numerical comparison, shape coverage, and regression patterns.
- `flash_attn/` for Python API and packaging contracts.

## Integration Notes

- Borrow algorithm structure and test strategy before copying code.
- Keep numerical tolerances explicit by dtype, sequence length, causality, masking, and layout.
- If the target project is C++-first, isolate any PyTorch dependency rather than letting it define the
  whole runtime.
- Use CUTLASS/cuBLAS/cuDNN baselines where the target operation is not attention-specific.

## Validation Ideas

- Test causal/non-causal, short/long sequences, head dimensions, batch sizes, and dtype combinations.
- Compare against a straightforward reference attention implementation.
- Run Compute Sanitizer on reduced shapes.
- Benchmark memory bandwidth, latency, and end-to-end model impact separately.

## Caveats

- The repo is optimized around PyTorch extension workflows and specific GPU generations.
- Attention kernels are numerically sensitive. Minor layout or precision changes can silently alter
  stability.
- Study the IO-aware design when the target operation is not actually attention; do not force the whole
  donor architecture onto unrelated kernels.
