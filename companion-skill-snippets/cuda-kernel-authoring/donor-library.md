## Donor References

When selecting external CUDA kernel, GPU runtime, ML inference runtime, or GPU compiler donors, read:

- `{{DONOR_ROOT}}/selection-policy.md`
- `{{DONOR_ROOT}}/agent-lookup.md` first for non-AI CUDA geometry, simulation, rendering, volume,
  texture, CAD, or neural-3D prompts where several donor categories could apply
- `{{DONOR_ROOT}}/ai-runtimes-kernels.md` for tensor, inference, attention, GEMM, quantization, fused-op,
  and GPU compiler work
- `{{DONOR_ROOT}}/simulation-gpu.md` for cloth, particles, fluids, deformables, differentiable simulation,
  robotics, or physics kernels
- `{{DONOR_ROOT}}/vfx-particles.md` for CUDA/Vulkan particle, smoke-particle, indirect-rendering, or
  GPU sorting references where the output is a realtime effect rather than a full solver
- `{{DONOR_ROOT}}/muscle-flesh-biomechanics.md` for biomechanical muscles, soft tissue, or flesh
  deformation kernels
- `{{DONOR_ROOT}}/neural-3d.md` for CUDA-heavy neural 3D or Gaussian splatting operators
- `{{DONOR_ROOT}}/geometry-simulation.md` for mesh conditioning, BVH, collision, or geometry-processing
  donors that inform CUDA kernels without adding Vulkan or other runtime dependencies
- `{{DONOR_ROOT}}/graphics-rendering.md` plus the pbrt-v4, Mitsuba 3, Falcor, or THREE.js PathTracing
  Renderer profiles when CUDA rendering kernels need physical rendering, path-tracing, render-graph, or
  reference-image behavior
- `{{DONOR_ROOT}}/volumes-voxels.md`, `{{DONOR_ROOT}}/medical-scientific-volumes.md`,
  `{{DONOR_ROOT}}/texture-material-color.md`, `{{DONOR_ROOT}}/assets-meshes-materials.md`, or
  `{{DONOR_ROOT}}/cad-precision-geometry.md` when CUDA kernels need sparse volume, medical/scientific
  volume, image/EXR, texture, NURBS/asset-pipeline, exact-geometry, or mesh-processing reference behavior
- `{{DONOR_ROOT}}/profiles/cutlass.md` for GEMM/convolution/reduction/tensor-core policy
- `{{DONOR_ROOT}}/profiles/flashattention.md` for attention kernels
- `{{DONOR_ROOT}}/profiles/triton.md` for Triton DSL/compiler tradeoffs
- `{{DONOR_ROOT}}/profiles/tiny-cuda-nn.md` for fused MLP, hash-grid, or CUDA neural graphics kernels
- `{{DONOR_ROOT}}/profiles/pytorch.md` for PyTorch reference outputs, custom-op boundaries, or package
  dependency decisions

Use the donor library to compare CUTLASS, Triton, FlashAttention, tiny-cuda-nn, llama.cpp/ggml,
ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, and PyTorch before writing or recommending custom
GPU code for attention, softmax, layernorm, GEMM-like, quantized, fused, or runtime-integrated
kernels. For non-AI CUDA domains, load the matching domain category first and use AI/kernel donors only
when they actually match the operation. Keep non-commercial or study-only donors out of reusable
implementation code.

The donor library is shared across CUDA, Vulkan, CPU, DirectX, OpenCL, DCC, and other backend sources.
Do not reject a Vulkan, OpenCL, DirectX, CPU, or DCC donor when it is the best domain reference; use it
for algorithms, layouts, tests, and architecture, then translate backend-specific synchronization,
shader, memory, packaging, and runtime assumptions into CUDA kernel and launch policy. Do not add
Vulkan runtime or interop requirements to a CUDA project unless the user explicitly chooses that mixed
lane or the requirements force it.
