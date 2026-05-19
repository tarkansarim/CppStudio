---
name: cuda-kernel-authoring
description: "CUDA kernel design, launch wrappers, correctness tests, sanitizer plans, numerical stability, reductions, shared memory, warp primitives, and profiling."
---

# CUDA Kernel Authoring

Use this skill when custom CUDA code is being designed, changed, reviewed, or debugged. It complements `cuda-debug` and `gpu-profiling-workstation`: this skill owns kernel design and test discipline; those skills own local tool choice and machine-specific profiling commands.

## First Principle

Correctness comes before performance. Do not optimize a kernel that lacks a trusted reference, fails sanitizer, has untested boundary shapes, or produces unexplained numerical drift.

## Gather Inputs First

Before writing or changing a kernel, identify:

- Mathematical operation and exact output contract.
- Input and output shapes, strides, layouts, and alignment assumptions.
- Supported dtypes and accumulator dtypes.
- Target GPUs or minimum SM architecture.
- Whether determinism is required.
- Existing reference implementation: CPU, PyTorch, CUB, cuBLAS, CUTLASS, Thrust, or a known-correct simple kernel.
- Launch wrapper ownership and synchronization semantics.
- Test runner, benchmark runner, and sanitizer command available in the repo.

If any of these are unknown and cannot be inferred from source, stop and establish the contract before coding.

## Library-First Decision

Use a custom kernel only when it has a real reason:

- The operation is fused and avoiding a global memory round trip matters.
- The operation has custom indexing, masking, layout, or epilogue logic.
- A standard library call does not support the shape, dtype, or semantics.
- The project needs an educational or research implementation and accepts the maintenance cost.

Prefer proven libraries for standard work:

- Use CUB or Thrust for standard reductions, scans, sorts, and selections.
- Use cuBLAS or CUTLASS for dense GEMM unless custom fusion or layout justifies otherwise.
- Use cuDNN or framework primitives for common neural-network operators when integration cost is lower than kernel maintenance.

## Donor References

When selecting external CUDA kernel, GPU runtime, ML inference runtime, or GPU compiler donors, use
the CppStudio donor library after this skill fires. Default installed path:

`${CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio/references/donor-library`

Start with:

- `selection-policy.md`
- `agent-lookup.md` for non-AI CUDA geometry, simulation, rendering, volume, texture, CAD, or
  neural-3D prompts where several donor categories could apply
- `native-engineering-infrastructure.md` when CUDA work includes project scaffolding, sanitizer
  lanes, profiling scripts, GPU CI, dependency policy, or update-safe generated infrastructure
- `ai-runtimes-kernels.md` for tensor, inference, attention, GEMM, quantization, fused-op, and GPU
  compiler work
- `simulation-gpu.md` for cloth, particles, fluids, deformables, differentiable simulation,
  robotics, or physics kernels
- `vfx-particles.md` for CUDA/Vulkan particle, smoke-particle, indirect-rendering, or GPU sorting
  references where the output is a realtime effect rather than a full solver
- `muscle-flesh-biomechanics.md` for biomechanical muscles, soft tissue, or flesh deformation
  kernels
- `neural-3d.md` for CUDA-heavy neural 3D or Gaussian splatting operators
- `geometry-simulation.md` for mesh conditioning, BVH, collision, or geometry-processing donors that
  inform CUDA kernels without adding Vulkan or other runtime dependencies
- `graphics-rendering.md` plus the pbrt-v4, Mitsuba 3, Falcor, or THREE.js PathTracing Renderer
  profiles when CUDA rendering kernels need physical rendering, path-tracing, render-graph, or
  reference-image behavior
- `volumes-voxels.md`, `medical-scientific-volumes.md`, `texture-material-color.md`,
  `assets-meshes-materials.md`, or `cad-precision-geometry.md` when CUDA kernels need sparse
  volume, medical/scientific volume, image/EXR, texture, NURBS/asset-pipeline, exact-geometry, or
  mesh-processing reference behavior
- `profiles/cutlass.md` for GEMM/convolution/reduction/tensor-core policy
- `profiles/flashattention.md` for attention kernels
- `profiles/triton.md` for Triton DSL/compiler tradeoffs
- `profiles/tiny-cuda-nn.md` for fused MLP, hash-grid, or CUDA neural graphics kernels
- `profiles/pytorch.md` for PyTorch reference outputs, custom-op boundaries, or package dependency
  decisions

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

## Design Rules

- Write the flattened index formula for every global memory access before coding it.
- Use grid-stride loops for large 1D domains unless a tile-specific mapping is required.
- Handle sizes that are smaller than a block, not multiples of the block size, and just over a tile boundary.
- Initialize accumulators with the correct identity value.
- Accumulate fp16 and bf16 reductions in fp32 unless the application has measured and accepted narrower accumulation.
- Use explicit casts at dtype boundaries; do not rely on silent narrowing in epilogues.
- Use `__shfl_*_sync` with an explicit active mask for warp-level reductions and broadcasts.
- Put `__syncthreads()` between shared-memory write and read phases, and ensure every thread in the block reaches each barrier.
- Keep shared-memory arrays sized from block geometry and dtype, and audit bank conflicts only after correctness is established.
- Avoid atomics for floating-point reductions when reproducibility matters. Prefer a two-pass reduction.
- Split multi-block reductions into partial and final kernels unless cooperative launch is explicitly required and supported.

## Launch Configuration

- Choose block size from workload shape, register pressure, shared-memory use, and occupancy, not from a single default.
- Use `(N + block - 1) / block` style rounding for grid sizes.
- Check maximum threads per block, dynamic shared memory, and launch resource limits.
- Keep host launch wrappers responsible for argument validation, stream selection, and error checking.
- Add `cudaGetLastError()` or the repo's CUDA check macro after launches, and synchronize only where correctness, readback, or benchmarking requires it.

## Correctness Test Matrix

Every non-trivial kernel should have tests that cover:

- Size 0 or empty behavior when valid for the API.
- Size 1.
- Small non-power-of-two sizes such as 7, 13, 31, 37, 63, 65, 127, 129.
- Exact tile and block multiples.
- One less and one more than tile or block multiples.
- Large production-like sizes.
- Non-contiguous or strided layouts if the kernel claims to support them.
- All supported dtypes.
- Adversarial numeric inputs: zeros, ones, mixed signs, large finite values, near-underflow values, NaN, and Inf where behavior is defined.
- Repeated runs when non-determinism would indicate a race.

References must be independent of the kernel. A test that shares the same indexing or reduction logic can reproduce the same bug and still pass.

## Numerical Tolerance

- Set tolerances per dtype and per operation.
- Compare fp16 and bf16 kernels against fp32 or fp64 references when practical.
- For reductions, account for floating-point non-associativity while still detecting systematic precision loss.
- For quantized kernels, measure error against quantization scale and check overflow or saturation explicitly.
- Treat NaN or Inf propagation as part of the contract, not an accident.

## Debug Workflow

When output is wrong:

1. Reproduce on the smallest failing shape.
2. Compare element-by-element against the reference and classify the error pattern.
3. Decompose the first failing index into logical dimensions and flattened address formulas.
4. Test non-power-of-two and partial-tile shapes before touching performance code.
5. Run `compute-sanitizer --tool memcheck` for memory safety.
6. Run `compute-sanitizer --tool racecheck` when shared memory or warp/block synchronization is involved.
7. Temporarily restrict to one block or one row only if it isolates the failing unit; remove the restriction before final verification.
8. Use debug buffers instead of noisy device `printf` when many lanes need inspection.
9. After the fix, rerun the full shape/dtype/layout sweep and sanitizer command.

## Performance Workflow

Only profile after correctness is clean:

1. Establish a baseline against a library call or previous known-good kernel.
2. Measure with GPU-synchronized timing.
3. Report bandwidth or throughput, not just latency.
4. Use `nsys` first when the hot region is unknown.
5. Use `ncu` only after the hot kernel is identified.
6. Do not claim a speedup without before/after commands, workload shape, and metric.

## Output Expectations

When this skill drives an implementation or review, report:

- Kernel contract and gathered constraints.
- Why a custom kernel is justified, or which library should be used instead.
- Main correctness risks and how the code handles them.
- Shape/dtype/layout test matrix.
- Sanitizer and benchmark commands.
- Remaining gaps, if any.
