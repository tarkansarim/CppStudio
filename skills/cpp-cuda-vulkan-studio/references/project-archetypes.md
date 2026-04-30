# Project Archetypes

Use this reference before scaffolding a greenfield project or applying the backbone to a repo whose
GPU lane is unclear. If the user does not choose CUDA or Vulkan, recommend Vulkan and start from the
Vulkan-only default `dev` preset for cross-platform and cross-vendor compatibility. Add CUDA only for
an explicit CUDA lane, a CUDA-specific compute requirement, or deliberate CUDA/Vulkan interop. Do not
create separate generated templates unless the user asks for a new reusable template family.

## CUDA Library

Use when the project is primarily a C++ library with CUDA kernels and optional command-line smoke tests.

- Enable CUDA and C++ tests; Vulkan can be off by default.
- Set explicit `PROJECT_CUDA_ARCHITECTURES` for CI/release.
- Read [donor-library/ai-runtimes-kernels.md](donor-library/ai-runtimes-kernels.md), then the matching
  CUTLASS, FlashAttention, or Triton profile.
- Verification priority: CPU/reference comparisons, CTest `quick`, CTest `gpu`, Compute Sanitizer,
  then Nsight Systems/Compute only after a hot path is identified.

## Vulkan Renderer Or Compute App

Use when the project is a renderer, simulation visualizer, Vulkan compute tool, or headless rendering
app without CUDA kernels.

- Enable Vulkan; CUDA can be off by default.
- Keep shader compilation and SPIR-V validation in the normal build.
- Read [donor-library/graphics-rendering.md](donor-library/graphics-rendering.md), then Khronos
  Vulkan-Samples before vendor-specific samples.
- Verification priority: `scripts/dump_vulkan_capabilities.sh`, shader CTest, Vulkan validation,
  offscreen render/compute CTest, then RenderDoc or Nsight Graphics.

## CUDA Plus Vulkan Interop App

Use when CUDA produces or transforms data consumed by Vulkan, or Vulkan resources are shared with CUDA.

- Use the explicit `cuda-vulkan-interop` preset. Do not use this archetype for ordinary Vulkan-first
  projects that merely need GPU compute or rendering.
- Prove each lane independently before adding external memory or semaphore interop tests.
- Read CUDA external resource interop docs, [donor-library/ai-runtimes-kernels.md](donor-library/ai-runtimes-kernels.md),
  and [donor-library/graphics-rendering.md](donor-library/graphics-rendering.md).
- Verification priority: CUDA reference tests, Vulkan validation, UUID/LUID device matching, imported
  memory/semaphore lifetime tests, then whole-frame profiling.

## AI Inference Or Custom-Kernel Runtime

Use when the project wraps model inference, local serving, custom CUDA kernels, quantization, batching,
or tensor-runtime integration.

- Preserve the target repo's dependency policy; do not introduce PyTorch, Triton, ONNX Runtime, or
  TensorRT-LLM without a concrete integration reason.
- Read [donor-library/ai-runtimes-kernels.md](donor-library/ai-runtimes-kernels.md) and the relevant
  deep profiles.
- Keep model weights, datasets, tokenizer files, and generated engines out of reusable templates.
- Verification priority: numerical reference tests, deterministic small model/input tests, throughput
  benchmark records, memory-footprint records, then scheduled sanitizer/profile lanes.

## Neural 3D Or Gaussian Splat Viewer

Use when the project renders, trains, or inspects NeRF, Gaussian splatting, differentiable rendering, or
3D ML data.

- Expect both graphics and AI dependency surfaces. Keep datasets, captures, models, and assets licensed
  separately from code.
- Read [donor-library/neural-3d.md](donor-library/neural-3d.md), [donor-library/graphics-rendering.md](donor-library/graphics-rendering.md),
  and [donor-library/profiles/gsplat.md](donor-library/profiles/gsplat.md).
- Prefer `gsplat` over non-commercial original 3DGS code for reusable implementation patterns.
- Verification priority: camera convention tests, small scene tests, offscreen visual artifacts,
  image-metric baselines, CUDA sanitizer on reduced kernels, then frame/profile traces.

## Hair, Grooming, Or Fur Tool

Use when the project simulates, renders, imports, exports, or authors hair/fur strand data.

- Enable Vulkan when realtime rendering is in scope; enable CUDA only for project-owned kernels.
- Read [donor-library/hair-grooming-fur.md](donor-library/hair-grooming-fur.md), then the TressFX and
  OpenUSD profiles when runtime hair or USD curves are involved.
- Keep groom assets, DCC exporters, simulation buffers, render materials, and collision fields separated.
- Verification priority: tiny groom fixture, skinning/collision tests, Vulkan validation, offscreen
  strand-render frames, then frame profiling.

## DCC Scene Pipeline Tool

Use when the project imports, exports, validates, or transforms scenes between DCC tools and runtime
data.

- Enable only the runtime GPU lanes the target viewer or converter actually needs.
- Read [donor-library/dcc-scene-pipeline.md](donor-library/dcc-scene-pipeline.md), then OpenUSD,
  Alembic, MaterialX, and OpenSubdiv profiles as needed.
- Keep scene composition, material translation, asset path resolution, generated caches, and DCC plugins
  as separate modules.
- Verification priority: round-trip tiny stages, path/payload tests, material fixtures, animation/curve
  fixtures, then representative production scenes.

## Volume Or Voxel Renderer

Use when the project loads, renders, edits, simulates, or converts sparse volumes or voxel grids.

- Enable Vulkan for render/compute visualization; enable CUDA only when CUDA kernels own volume work.
- Read [donor-library/volumes-voxels.md](donor-library/volumes-voxels.md), then the OpenVDB/NanoVDB
  profile.
- Keep VDB IO, CPU grid processing, GPU upload, shader traversal, and visual rendering separated.
- Verification priority: tiny volume metadata tests, CPU/GPU sample comparisons, empty-grid edge cases,
  offscreen render frames, then performance traces.

## Animation Or Rigging Runtime

Use when the project owns skeletal animation playback, skinning, clip import, retargeting, or animation
compression.

- Enable CUDA/Vulkan only for GPU skinning, visualization, or runtime rendering needs.
- Read [donor-library/animation-rigging.md](donor-library/animation-rigging.md), then the ozz-animation
  and ACL profiles as needed.
- Keep offline import/conversion separate from runtime playback.
- Verification priority: one-joint clip fixtures, hierarchy/blend tests, CPU skinning references, import
  fixtures, then GPU skinning tests.

## Texture, Material, Or Color Pipeline

Use when the project owns texture containers, compression, image processing, color management, or
material interchange.

- Enable Vulkan when runtime texture upload or material preview is in scope.
- Read [donor-library/texture-material-color.md](donor-library/texture-material-color.md), then KTX/Basis,
  OpenColorIO/OpenImageIO, or MaterialX profiles.
- Keep offline conversion, runtime loading, color transforms, shader generation, and asset metadata
  separated.
- Verification priority: tiny texture/image fixtures, metadata and color-space tests, transcoding format
  checks, material graph round-trips, then preview frames.

## CAD Or Precision Geometry Tool

Use when the project needs B-reps, NURBS, STEP/IGES, Booleans, tessellation, or exact geometry.

- Enable renderer lanes only for viewing; keep CAD kernel data separate from render meshes.
- Read [donor-library/cad-precision-geometry.md](donor-library/cad-precision-geometry.md), then the Open
  CASCADE profile and optionally CGAL/libigl notes.
- Make tolerance, units, topology ownership, orientation, and tessellation policy explicit.
- Verification priority: tiny STEP fixtures, unit/bounds checks, tessellation checks, Boolean edge cases,
  then viewer/render tests.

## Advanced Simulation Tool

Use when the project owns cloth, fluids, deformables, particles, differentiable simulation, robotics, or
multiphysics workflows beyond basic rigid-body collision.

- Enable CUDA or Vulkan compute only where the simulation backend needs it.
- Read [donor-library/simulation-gpu.md](donor-library/simulation-gpu.md), then choose Warp, Taichi,
  PositionBasedDynamics, Chrono, SOFA, or PhysX based on dependency and license fit.
- Keep solver state, collision geometry, renderer handoff, training data, and benchmark scenes separated.
- Verification priority: tiny deterministic solver fixtures, conservation/constraint checks, CPU/GPU
  comparisons, visual smoke frames, then profile traces.

## XR Or Spatial App

Use when the project targets OpenXR, VR, AR, MR, headset/controller input, stereo swapchains, or
spatial interaction.

- Enable Vulkan when it is the graphics backend; keep XR runtime detection separate from Vulkan device
  setup.
- Read [donor-library/xr-spatial.md](donor-library/xr-spatial.md), [donor-library/graphics-rendering.md](donor-library/graphics-rendering.md),
  and the OpenXR SDK profile.
- Keep runtime discovery, actions, reference spaces, swapchains, frame timing, and vendor extensions
  explicit.
- Verification priority: runtime/capability dump, action binding tests, swapchain format selection,
  minimal session smoke, then frame timing.

## Selection Rule

If a project matches more than one archetype, choose the narrowest archetype that covers the user-visible
workflow, then add the adjacent lane as an optional CMake feature. For example, a CUDA library with a
debug viewer is still a CUDA library first; a renderer with one CUDA denoising pass is an interop app.
When the user has not chosen a GPU API, make the initial recommendation and implementation plan
Vulkan-only.
