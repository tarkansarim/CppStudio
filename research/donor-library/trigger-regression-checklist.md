# Trigger Regression Checklist

Use this checklist when rerunning the donor-library trigger lane with a fresh subagent or reviewer.
The static validator only proves that paths in `trigger-matrix.json` still exist.

## Required Evidence

- Record the run date, agent type, and whether the test used source paths or installed skill paths.
- For each case in `trigger-matrix.json`, record the prompt shape, selected skills, opened donor or
  reference files, and whether any forbidden path/category was used.
- For negative controls, record that `cpp-cuda-vulkan-studio` and donor-library files were not used.
- Treat ambiguous triggers as findings only when they would route an implementation to the wrong
  lane or donor category.

## Expected Routing

- Unspecified C++ realtime, 3D, rendering, XR, or cross-platform GPU work should route to
  `cpp-cuda-vulkan-studio`, recommend Vulkan first, and avoid CUDA donors unless requirements force
  CUDA.
- Vulkan memory allocation, loader/bootstrap, shader reflection, shader compilation, SPIR-V validation,
  or Slang evaluation should route to `vulkan-foundation-tooling.md`.
- glTF/GLB runtime loading, Vulkan viewers, asset validation, or importer dependency choices should
  route to `gltf-runtime-assets.md` without confusing generic JSON parsing with glTF work.
- Renderer backbone, render graph, PBR renderer, graphics middleware, or multi-backend renderer
  dependency questions should route to `graphics-rendering.md` and the matching Filament, Diligent
  Engine, bgfx, or Magnum profiles.
- Runtime mesh conditioning, broad 3D asset import, BVH/ray-query, CPU ray tracing reference,
  physics/collision, or renderer-ready mesh handoff should route to `geometry-simulation.md` and the
  matching meshoptimizer, assimp, Embree, madmann91/bvh, Jolt, or Bullet profile.
- Local LLM inference, production serving, execution-provider routing, ML compilers, fused neural
  kernels, or tensor/autograd reference work should route to `ai-runtimes-kernels.md` and the matching
  llama.cpp/ggml, ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, tiny-cuda-nn, TVM, or PyTorch profile.
- Neural 3D, NeRF, Gaussian splatting, differentiable rendering, point-cloud/reconstruction ML, or
  neural graphics workflow work should route to `neural-3d.md` and keep restricted GraphDeco,
  instant-ngp, and Kaolin Wisp sources study-only.
- Explicit CUDA kernel, CUTLASS, FlashAttention, CUDA graph, or NVIDIA-only runtime work should route
  to CUDA-specific donors and skills first.
- Explicit CUDA/Vulkan interop should use the mixed lane and keep the CUDA/Vulkan boundary visible.
- Backend-mismatched donors should remain available as domain references. A Vulkan target may use CUDA,
  OpenCL, DirectX, CPU, or DCC donors without adding those runtimes; a CUDA target may use Vulkan,
  OpenCL, DirectX, CPU, or DCC donors without switching lanes.
- Mixed CUDA/Vulkan routing should happen only when the user explicitly requests interop/mixing or when
  the technical requirements force actual cross-backend resource sharing.
- Generic document rendering, text templating, CSV/JSON/business-data import, or non-3D import work
  should not trigger renderer, glTF, geometry, assimp, or meshoptimizer donor routing.
- Generic "AI assistant" application work, ordinary Python ML scripts, or non-C++/GPU/model-runtime
  tasks should not trigger CppStudio AI-runtime donors.
- Non-GPU Python, CLI, parser, virtualenv, or business-simulation work should not trigger CppStudio
  donor routing.
