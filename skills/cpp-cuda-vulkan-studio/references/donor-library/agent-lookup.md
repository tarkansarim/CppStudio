# Agent Donor Lookup

Use this file when the request is broad enough that more than one donor category could apply. Open
[selection-policy.md](selection-policy.md) first, then use the closest intent below to choose the
minimum category/profile set. If the prompt is already specific, skip this file and open that category
directly.

## Core Routing Rule

Donors are domain references first. CUDA, Vulkan, OpenCL, DirectX, CPU, WebGPU, and DCC backend
signals describe the upstream source, not the target lane. Keep the target project in its selected
CUDA or Vulkan lane unless the user explicitly asks for a mixed lane or real interop is required.
For native C++/CUDA/Vulkan projects, non-C/C++ donors are reference-only unless the user explicitly
chooses that runtime; use them for behavior, algorithms, architecture, fixtures, and validation
targets, then implement through the active lane skill.

## Prompt Intent Map

- **Vulkan setup, memory, shaders, descriptors, validation**: open
  [vulkan-foundation-tooling.md](vulkan-foundation-tooling.md). Start with
  [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md),
  [Vulkan Memory Allocator](profiles/vulkan-memory-allocator.md),
  [volk](profiles/volk.md), [vk-bootstrap](profiles/vk-bootstrap.md),
  [SPIR-V Toolchain](profiles/spirv-toolchain.md), or [Slang](profiles/slang.md).
  Do not route to CUDA donors for ordinary Vulkan correctness work.
- **Renderer architecture, PBR, render graphs, WebGPU/WebGL, path tracing**: open
  [graphics-rendering.md](graphics-rendering.md). Start with
  [Filament](profiles/filament.md), [Diligent Engine](profiles/diligent-engine.md),
  [bgfx](profiles/bgfx.md), [Magnum](profiles/magnum.md), [Dawn](profiles/dawn.md),
  [pbrt-v4](profiles/pbrt-v4.md), [Mitsuba 3](profiles/mitsuba3.md), or
  [Falcor](profiles/falcor.md). When RTX SDK boundaries, NVIDIA Vulkan extensions, mesh/task
  shaders, Nsight/Aftermath tooling, or vendor-specific Vulkan ray-tracing samples are in scope, also
  open [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md). Keep WebGPU/browser donors as
  behavior references unless the user chooses a web target.
- **Runtime assets, glTF/GLB, importer fixtures, renderer-ready buffers**: open
  [gltf-runtime-assets.md](gltf-runtime-assets.md). Start with
  [glTF C/C++ Loaders](profiles/fastgltf-cgltf-tinygltf.md) and
  [meshoptimizer](profiles/meshoptimizer.md). Use [texture-material-color.md](texture-material-color.md)
  only when texture containers, color, EXR/HDR, or material graphs are in scope.
- **Mesh processing, broad import, BVH, CPU ray references, physics/collision**: open
  [geometry-simulation.md](geometry-simulation.md). Start with [assimp](profiles/assimp.md),
  [meshoptimizer](profiles/meshoptimizer.md), [Embree](profiles/embree.md),
  [madmann91/bvh](profiles/madmann91-bvh.md), [Jolt Physics](profiles/jolt-physics.md), or
  [Bullet Physics](profiles/bullet-physics.md). Use engine donors only when editor/runtime scale is
  explicit.
- **AI runtime, model serving, inference, ML compilers, custom CUDA kernels**: open
  [ai-runtimes-kernels.md](ai-runtimes-kernels.md). Start with
  [llama.cpp and ggml](profiles/llama-ggml.md), [ONNX Runtime](profiles/onnx-runtime.md),
  [TensorRT-LLM](profiles/tensorrt-llm.md), [vLLM](profiles/vllm.md),
  [MLC-LLM](profiles/mlc-llm.md), [CUTLASS](profiles/cutlass.md),
  [FlashAttention](profiles/flashattention.md), [Triton](profiles/triton.md), or
  [tiny-cuda-nn](profiles/tiny-cuda-nn.md). Do not trigger this category for ordinary AI assistant
  apps unless local model runtime, GPU kernels, C++ integration, or model serving is requested.
- **Neural 3D, NeRF, Gaussian splatting, differentiable 3D, reconstruction ML**: open
  [neural-3d.md](neural-3d.md). Start with [gsplat](profiles/gsplat.md),
  [Nerfstudio](profiles/nerfstudio.md), [PyTorch3D](profiles/pytorch3d.md),
  [Kaolin](profiles/kaolin.md), [Open3D](profiles/open3d.md), and
  [Neural Graphics Study-Only References](profiles/neural-graphics-study-only.md). CUDA-heavy donors
  can guide Vulkan implementations without adding CUDA.
- **Hair, fur, strands, grooming, guide curves**: open
  [hair-grooming-fur.md](hair-grooming-fur.md). Start with [AMD TressFX](profiles/tressfx.md),
  [OpenUSD](profiles/openusd.md), [Alembic](profiles/alembic.md),
  [Blender Study-Only](profiles/blender-study-only.md), or
  [NVIDIA HairWorks Study-Only](profiles/hairworks-study-only.md). Keep study-only grooming sources
  conceptual.
- **DCC scene pipelines, USD, Alembic, MaterialX, editorial timelines, virtual production**: open
  [dcc-scene-pipeline.md](dcc-scene-pipeline.md). Start with [OpenUSD](profiles/openusd.md),
  [Alembic](profiles/alembic.md), [MaterialX](profiles/materialx.md),
  [OpenTimelineIO](profiles/opentimelineio.md), or [Blender Study-Only](profiles/blender-study-only.md).
  Keep DCC plugins, assets, and app licenses separate from reusable code.
- **Volumes, voxels, VDB/NanoVDB, scientific volume visualization, sparse-volume ML**: open
  [volumes-voxels.md](volumes-voxels.md). Start with
  [OpenVDB and NanoVDB](profiles/openvdb-nanovdb.md), [fVDB](profiles/fvdb.md), or
  [VTK](profiles/vtk.md). Keep volume IO, ML tensor work, and renderer upload as separate choices.
- **Animation runtime, skeletal sampling, skinning, compression**: open
  [animation-rigging.md](animation-rigging.md). Start with
  [ozz-animation](profiles/ozz-animation.md), [Animation Compression Library](profiles/acl.md), and
  [OpenUSD](profiles/openusd.md) when interchange matters.
- **Subdivision, remeshing, robust geometry processing**: open
  [surfaces-subdivision.md](surfaces-subdivision.md). Start with
  [OpenSubdiv](profiles/opensubdiv.md), [libigl](profiles/libigl.md), [CGAL](profiles/cgal.md), or
  [meshoptimizer](profiles/meshoptimizer.md). Do not confuse CAD kernel work with runtime mesh
  conditioning.
- **Texture containers, EXR/HDR, image IO, color management, material graphs**: open
  [texture-material-color.md](texture-material-color.md). Start with
  [KTX-Software and Basis Universal](profiles/ktx-basis.md),
  [OpenColorIO and OpenImageIO](profiles/opencolorio-openimageio.md),
  [TinyEXR](profiles/tinyexr.md), or [MaterialX](profiles/materialx.md). Do not trigger this for
  ordinary web image upload or thumbnail work.
- **CAD kernels, B-reps, NURBS, STEP/IGES, exact tolerances**: open
  [cad-precision-geometry.md](cad-precision-geometry.md). Start with
  [Open CASCADE Technology](profiles/open-cascade.md), [CGAL](profiles/cgal.md),
  [libigl](profiles/libigl.md), or [FreeCAD Study-Only](profiles/freecad-study-only.md). Keep source
  CAD topology separate from display tessellation.
- **3D physics, cloth, particles, fluids, deformables, differentiable simulation**: open
  [simulation-gpu.md](simulation-gpu.md). Start with [NVIDIA Warp](profiles/warp.md),
  [Taichi](profiles/taichi.md), [PositionBasedDynamics](profiles/positionbaseddynamics.md),
  [Project Chrono](profiles/project-chrono.md), [SOFA](profiles/sofa.md), or
  [NVIDIA PhysX](profiles/physx.md). Warp and Taichi are prototype/reference-only for native C++
  unless their Python/JIT runtimes are explicitly chosen. Do not trigger this for business or economic
  simulations.
- **OpenXR, VR/AR/MR, headset/controller input, stereo swapchains, runtime diagnostics**: open
  [xr-spatial.md](xr-spatial.md). Start with [OpenXR SDK](profiles/openxr-sdk.md),
  [OpenXR-Hpp](profiles/openxr-hpp.md), [Monado](profiles/monado.md), and
  [Godot OpenXR Vendors](profiles/godot-openxr-vendors.md). Keep portable OpenXR baseline separate
  from vendor extensions.

## Negative Controls

- Do not route generic Python, CLI, virtualenv, business simulation, CSV/JSON import, frontend, or
  web image upload work to this donor library unless the prompt includes C++, GPU, CUDA, Vulkan, 3D,
  renderer, local model runtime, or native asset-pipeline implementation scope.
- Do not route story, concept, mockup, marketing, or design-only prompts to engine, XR, CAD, DCC, or
  renderer donors unless implementation is requested.
