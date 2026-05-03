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

- **Native C++ GPU architecture brainstorming or design proposals**: do not answer from skill framing
  or general model knowledge alone. Open [project-archetypes.md](../project-archetypes.md),
  [selection-policy.md](selection-policy.md), then the smallest category/profile set for the design.
  For realtime Vulkan fluids/fire/smoke/water/destruction brainstorming, start with
  [simulation-gpu.md](simulation-gpu.md) and
  [Fluids, Smoke, Fire, And Solver References](profiles/fluids-smoke-fire.md); add
  [vfx-particles.md](vfx-particles.md) for realtime effect presentation,
  [volumes-voxels.md](volumes-voxels.md) for smoke/fire volume representation, and
  [geometry-simulation.md](geometry-simulation.md) for rigid fragments, collisions, and destruction.
  Always do a small web ceiling check for this fluids/fire/smoke/water/destruction brainstorm shape,
  even when the user only says "brainstorm"; use upstream repos, vendor docs, papers, or project docs
  to avoid relying on stale model memory before ranking recommendations.
- **VFX studio department terms such as modeling, texturing, rigging, creature FX, look development,
  lighting, or FX**: open [production/vfx-studio.md](production/vfx-studio.md) first, then the
  smallest technical category set it names. Use department language only as a router; keep
  [selection-policy.md](selection-policy.md) and category profile caveats authoritative.
- **Game studio terms such as character art, environment/world art, technical art, gameplay
  animation, realtime VFX, lighting/post, rendering, tools/pipeline engineering, physics, or XR
  games**: open [production/games.md](production/games.md) first, then the smallest technical category
  set it names. Consider runtime budgets, platform constraints, asset cooking, and repeated iteration
  before choosing dependency-heavy donors.
- **Native engineering infrastructure, project scaffolding, CMake/build layout, dependency policy,
  testing, validation, profiling, CI, GPU runners, or template update safety**: open
  [production/native-engineering-infrastructure.md](production/native-engineering-infrastructure.md)
  and [native-engineering-infrastructure.md](native-engineering-infrastructure.md). Start with
  [CMake Project Templates](profiles/cmake-project-templates.md),
  [Template Update Systems](profiles/template-update-systems.md),
  [Dependency Management](profiles/dependency-management.md),
  [Testing Infrastructure](profiles/testing-infrastructure.md),
  [Static Analysis And Formatting](profiles/static-analysis-formatting.md),
  [Sanitizer And Validation Lanes](profiles/sanitizer-validation-lanes.md),
  [GPU Shader Validation](profiles/gpu-shader-validation.md),
  [Profiling And Observability](profiles/profiling-observability.md), or
  [CI And GPU Runners](profiles/ci-gpu-runners.md) depending on the infrastructure request. Do not
  route generic project-management, frontend, or non-native app work here.
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
  open [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md),
  [nvpro Vulkan Ray Tracing Tutorial KHR](profiles/nvpro-vk-raytracing-tutorial-khr.md),
  [NVIDIA NVRHI](profiles/nvrhi.md), or [NVIDIA NRI](profiles/nri.md). For DLSS-RR, NRD,
  denoising/reconstruction, guide buffers, or Streamline requests, start with
  [nvpro vk_denoise_dlssrr](profiles/nvpro-vk-denoise-dlssrr.md),
  [NVIDIA DLSS SDK](profiles/nvidia-dlss-sdk.md), [NVIDIA Streamline](profiles/nvidia-streamline.md),
  [NVIDIA Streamline Sample](profiles/nvidia-streamline-sample.md),
  [NVIDIA NRD](profiles/nrd.md), or [NVIDIA NRD Sample](profiles/nrd-sample.md). For
  production-scale Vulkan glTF path tracing, open
  [nvpro Vulkan glTF Renderer](profiles/nvpro-vk-gltf-renderer.md). Keep WebGPU/browser donors as
  behavior references unless the user chooses a web target.
- **Runtime assets, glTF/GLB, importer fixtures, renderer-ready buffers**: open
  [gltf-runtime-assets.md](gltf-runtime-assets.md). Start with
  [glTF C/C++ Loaders](profiles/fastgltf-cgltf-tinygltf.md) and
  [meshoptimizer](profiles/meshoptimizer.md). Use [texture-material-color.md](texture-material-color.md)
  only when texture containers, color, EXR/HDR, or material graphs are in scope.
- **NURBS assets, Rhino `.3dm`, UV atlases, compressed geometry, ASTC/DDS tooling, OpenPBR, or
  production asset resolver work**: open [assets-meshes-materials.md](assets-meshes-materials.md).
  Start with OpenNURBS or tinynurbs for NURBS, xatlas for UV atlases, Draco for compressed geometry,
  Arm ASTC Encoder or DirectXTex for offline texture conversion, and OpenAssetIO for production asset
  identity. Use [cad-precision-geometry.md](cad-precision-geometry.md) for CAD kernels and
  [texture-material-color.md](texture-material-color.md) for color/image pipeline work.
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
  [NVIDIA RTXCR](profiles/rtxcr.md), [RTXCR Material Library](profiles/rtxcr-material-library.md),
  [RTXCR Geometry Library](profiles/rtxcr-geometry-library.md),
  [OpenUSD](profiles/openusd.md), [Alembic](profiles/alembic.md),
  [Blender Study-Only](profiles/blender-study-only.md), or
  [NVIDIA HairWorks Study-Only](profiles/hairworks-study-only.md). For full groom runtime,
  interpolation, voxelization, visibility, or deep-shadow architecture, use
  [Unreal HairStrands Study-Only](profiles/unreal-hairstrands-study-only.md). For hair material,
  multiple-scattering LUT, Shader Graph, or line-rendering references, use
  [Unity HDRP Hair Study-Only](profiles/unity-hdrp-hair-study-only.md). Keep study-only grooming
  sources conceptual.
- **Realtime VFX, particles, GPU-driven effects, indirect drawing, particle sorting, or effect
  authoring runtimes**: open [vfx-particles.md](vfx-particles.md). Start with Effekseer for
  authoring/runtime effects, The Forge or Wicked Engine for engine integration, Khronos/SaschaWillems
  samples for Vulkan particles/indirect rendering, CUDA Samples for CUDA smoke/particles, and
  FidelityFX Parallel Sort for GPU sorting. Keep solver physics in [simulation-gpu.md](simulation-gpu.md).
- **DCC scene pipelines, USD, Alembic, MaterialX, editorial timelines, virtual production**: open
  [dcc-scene-pipeline.md](dcc-scene-pipeline.md). Start with [OpenUSD](profiles/openusd.md),
  [Alembic](profiles/alembic.md), [MaterialX](profiles/materialx.md),
  [OpenTimelineIO](profiles/opentimelineio.md), or [Blender Study-Only](profiles/blender-study-only.md).
  Keep DCC plugins, assets, and app licenses separate from reusable code.
- **Volumes, voxels, VDB/NanoVDB, scientific volume visualization, sparse-volume ML**: open
  [volumes-voxels.md](volumes-voxels.md). Start with
  [OpenVDB and NanoVDB](profiles/openvdb-nanovdb.md), [fVDB](profiles/fvdb.md), or
  [VTK](profiles/vtk.md). Keep volume IO, ML tensor work, and renderer upload as separate choices.
- **Medical/scientific volume IO, DICOM, NIfTI, OME-Zarr, transfer functions, tomography, or large
  scientific arrays**: open [medical-scientific-volumes.md](medical-scientific-volumes.md). Start
  with ITK/DCMTK/GDCM/dcm2niix for medical IO, VTK/Inviwo/OSPRay/Open VKL for visualization and
  transfer functions, and HDF5/netCDF/ADIOS2/TensorStore/Zarr/OME NGFF for large array storage.
  Do not bundle patient data or ambiguous clinical fixtures.
- **Animation runtime, skeletal sampling, skinning, compression**: open
  [animation-rigging.md](animation-rigging.md). Start with
  [ozz-animation](profiles/ozz-animation.md), [Animation Compression Library](profiles/acl.md), and
  [OpenUSD](profiles/openusd.md) when interchange matters. For retargeting, skinning decomposition,
  crowds, steering, or navigation agents, also use the retargeting/crowd section in that file.
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
  CAD topology separate from display tessellation. For `.3dm` asset transfer or lightweight NURBS math,
  route to [assets-meshes-materials.md](assets-meshes-materials.md) after this file.
- **Terrain, geospatial streaming, 3D Tiles, quantized mesh, CRS/projection, point clouds, or vector
  tile maps**: open [terrain-geospatial.md](terrain-geospatial.md). Start with Cesium Native for C++
  3D Tiles/terrain streaming, GDAL/PROJ/PDAL for conversion and coordinate correctness, LASzip for
  narrow LAZ codec work, osgEarth for earth-view rendering architecture, and MapLibre Native for
  vector tile maps.
- **BIM, IFC, AEC, building models, BCF, or buildingSMART validation**: open
  [bim-aec-ifc.md](bim-aec-ifc.md). Start with IfcOpenShell for IFC geometry/Open CASCADE handoff,
  IFC++ for a smaller C++ IFC reference, web-ifc for parser/geometry behavior, and buildingSMART
  specs/validators for conformance. Keep proprietary building models license-separated.
- **3D physics, cloth, particles, fluids, deformables, differentiable simulation**: open
  [simulation-gpu.md](simulation-gpu.md). Start with [NVIDIA Warp](profiles/warp.md),
  [Taichi](profiles/taichi.md), [PositionBasedDynamics](profiles/positionbaseddynamics.md),
  [Project Chrono](profiles/project-chrono.md), [SOFA](profiles/sofa.md), or
  [NVIDIA PhysX](profiles/physx.md). For fluids/smoke/fire, start with SPlisHSPlasH,
  fluid-engine-dev, SPHinXsys, DualSPHysics, CUDA Samples, Vortex2D, MantaFlow, or NVIDIA Flow as
  listed in that file. Warp and Taichi are prototype/reference-only for native C++ unless their
  Python/JIT runtimes are explicitly chosen. Do not trigger this for business or economic simulations.
- **Muscle simulation, flesh deformation, soft tissue, biomechanics, muscle activation, tendon paths,
  or anatomical model references**: open [muscle-flesh-biomechanics.md](muscle-flesh-biomechanics.md).
  Start with OpenSim/Simbody for biomechanical muscles, FEBio/MFEM/SOFA for continuum tissue, MuJoCo
  for actuation/control, and PBD/XPBD for realtime visual deformation. Keep anatomical models and
  medical data separate from code.
- **OpenXR, VR/AR/MR, headset/controller input, stereo swapchains, runtime diagnostics**: open
  [xr-spatial.md](xr-spatial.md). Start with [OpenXR SDK](profiles/openxr-sdk.md),
  [OpenXR-Hpp](profiles/openxr-hpp.md), [Monado](profiles/monado.md), and
  [Godot OpenXR Vendors](profiles/godot-openxr-vendors.md). Use OpenXR Tutorials for guided setup,
  StereoKit for interaction ergonomics, Microsoft/Meta samples for vendor features, ILLIXR for system
  research, and NVIDIA xr_multi_gpu for Vulkan/OpenXR performance. Keep portable OpenXR baseline
  separate from vendor extensions.

## Negative Controls

- Do not route generic Python, CLI, virtualenv, business simulation, CSV/JSON import, frontend, or
  web image upload work to this donor library unless the prompt includes C++, GPU, CUDA, Vulkan, 3D,
  renderer, local model runtime, or native asset-pipeline implementation scope.
- Do not route story, concept, mockup, marketing, or design-only prompts to engine, XR, CAD, DCC, or
  renderer donors unless implementation is requested.
