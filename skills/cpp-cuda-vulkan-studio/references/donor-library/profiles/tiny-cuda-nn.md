# tiny-cuda-nn Donor Profile

Source: https://github.com/NVlabs/tiny-cuda-nn  
Tier: `safe-donor`  
Backend signal: native-cuda
License signal: BSD-3-Clause; inspect `LICENSE`, bindings, examples, dependencies, benchmarks, and
any dataset/model references at the exact revision used.

## Use First For

- Compact CUDA neural-network kernels, fused MLPs, multiresolution hash grids, encodings, and neural
  graphics operator ideas.
- Instant-ngp-style data layout and small-network performance patterns under a permissive license.
- CUDA/PyTorch binding boundaries for neural fields, NeRF-like encodings, and differentiable graphics
  prototypes.

## First Upstream Areas To Inspect

- `include/`, `src/`, `bindings/torch/`, `samples/`, `benchmarks/`, and CMake integration.
- Encoding, network, optimizer, and trainer code that matches the target operation.
- Example configs and data references before copying test assets.
- GPU architecture and compiler requirements for selected kernels.

## Integration Notes

- Use for CUDA-lane neural kernels or as a data-layout/algorithm donor for Vulkan ports.
- Keep network definition/config, training loop, bindings, and project-owned kernels separated.
- Do not add CUDA to a Vulkan-first neural graphics project unless the user explicitly chooses CUDA or
  interop.
- Compare against CUTLASS/FlashAttention/Triton when the target operation is matrix math or attention.

## Validation Ideas

- Add tiny encoding and MLP fixtures with CPU/reference comparisons where possible.
- Test empty batch, small/large batch, precision modes, extreme coordinates, and architecture gates.
- Run Compute Sanitizer for project-owned CUDA adaptations.
- Record occupancy, memory footprint, and throughput only after numerical checks pass.

## Caveats

- It is NVIDIA/CUDA-specific.
- Some examples connect to research workflows or datasets with separate licenses.
- Hash-grid and fused-MLP patterns need careful porting before use in Vulkan or non-CUDA lanes.
