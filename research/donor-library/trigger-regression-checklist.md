# Trigger Regression Checklist

Use this checklist when rerunning the donor-library trigger lane with a fresh subagent or reviewer.
The static validator only proves that paths in `trigger-matrix.json` still exist.

Generate the prompt pack from the matrix instead of hand-copying cases:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --tag smoke
```

Use `--installed-paths` after rollout when the evaluator should inspect `${SYNC_CODEX_HOME:-$HOME/.codex}`
paths. Useful tags include `smoke`, `lookup`, `negative`, `cuda`, `vulkan`, `assets`, `simulation`,
`ai-runtime`, and `xr`.

## Required Evidence

- Record the run date, agent type, and whether the test used source paths or installed skill paths.
- For each case in `trigger-matrix.json`, record the prompt shape, selected skills, opened donor or
  reference files, and whether any forbidden path/category was used.
- For negative controls, record that `cpp-cuda-vulkan-studio` and donor-library files were not used.
- Treat ambiguous triggers as findings only when they would route an implementation to the wrong
  lane or donor category.
- For broad prompts, record whether `agent-lookup.md` was opened before category files and whether it
  narrowed the request instead of causing broad library loading.

## Expected Routing

- Unspecified C++ realtime, 3D, rendering, XR, or cross-platform GPU work should route to
  `cpp-cuda-vulkan-studio`, recommend Vulkan first, and avoid CUDA donors unless requirements force
  CUDA.
- Broad or overlapping donor prompts such as 3D viewer, renderer, simulation, asset pipeline,
  scientific volume viewer, AI-runtime visualization, or XR app should open `agent-lookup.md` first,
  then the smallest matching category set.
- Vulkan memory allocation, loader/bootstrap, shader reflection, shader compilation, SPIR-V validation,
  or Slang evaluation should route to `vulkan-foundation-tooling.md`.
- glTF/GLB runtime loading, Vulkan viewers, asset validation, or importer dependency choices should
  route to `gltf-runtime-assets.md` without confusing generic JSON parsing with glTF work.
- Renderer backbone, render graph, PBR renderer, graphics middleware, or multi-backend renderer
  dependency questions should route to `graphics-rendering.md` and the matching Filament, Diligent
  Engine, bgfx, or Magnum profiles.
- Native WebGPU, `webgpu.h`, WGSL/Tint, browser 3D, WebXR, or browser path-tracing work should route
  through `graphics-rendering.md` and the matching Dawn, three.js, Babylon.js, or THREE.js PathTracing
  Renderer profile without silently changing a Vulkan-first C++ project into WebGPU.
- Physical rendering, differentiable rendering, path tracing, realtime ray tracing, RTX framework, or
  render-graph architecture work should route to `graphics-rendering.md` and the matching pbrt-v4,
  Mitsuba 3, Falcor, or THREE.js PathTracing Renderer profile.
- Runtime mesh conditioning, broad 3D asset import, BVH/ray-query, CPU ray tracing reference,
  physics/collision, or renderer-ready mesh handoff should route to `geometry-simulation.md` and the
  matching meshoptimizer, assimp, Embree, madmann91/bvh, Jolt, or Bullet profile.
- CPU visualization renderer, scientific visualization, volume renderer API, engine/editor
  architecture, scene tree, asset processor, component system, or editor/runtime split work should route
  to `geometry-simulation.md` and the matching OSPRay, Godot Engine, or Open 3D Engine profile.
- DCC scene interchange, USD/Alembic caches, MaterialX, editorial timelines, virtual production, OTIO, or
  Blender workflow study should route to `dcc-scene-pipeline.md` and the matching OpenUSD, Alembic,
  MaterialX, OpenTimelineIO, OpenSubdiv, or Blender study-only profile.
- Sparse volumes, VDB/NanoVDB, fVDB, VTK, volume rendering, voxel grids, scientific visualization, or
  sparse-volume ML should route to `volumes-voxels.md` and the matching OpenVDB/NanoVDB, fVDB, or VTK
  profile.
- Texture containers, KTX/KTX2, Basis, EXR/HDR, TinyEXR, OpenImageIO, OpenColorIO, ACES/OCIO, or
  MaterialX should route to `texture-material-color.md` and the matching profile.
- CAD kernels, B-reps, NURBS, STEP/IGES, exact geometry, robust triangulation, Booleans, CGAL, libigl,
  or FreeCAD workflow study should route to `cad-precision-geometry.md` or
  `surfaces-subdivision.md` and the matching profile.
- OpenXR, OpenXR-Hpp, Monado runtime diagnostics, vendor-specific XR extensions, stereo swapchains,
  actions, or XR frame timing should route to `xr-spatial.md` and keep portable OpenXR baseline separate
  from vendor-specific extension references.
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
- Generic web UI, ordinary frontend layout, game-story/design-only brainstorming, or non-implementation
  design writing should not trigger WebGPU, renderer, engine-architecture, or donor-library routing.
- Ordinary video editing, image upload/resize, CAD-looking mockups, or VR storyboarding should not
  trigger DCC, texture/material/color, CAD, or XR donor routing unless implementation asks for those
  technical domains explicitly.
- Generic "AI assistant" application work, ordinary Python ML scripts, or non-C++/GPU/model-runtime
  tasks should not trigger CppStudio lookup or AI-runtime donors.
- Non-GPU Python, CLI, parser, virtualenv, or business-simulation work should not trigger CppStudio
  donor routing or `agent-lookup.md`.
