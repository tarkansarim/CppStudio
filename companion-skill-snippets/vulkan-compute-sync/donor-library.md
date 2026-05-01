## Donor References

When selecting Vulkan, renderer, WebGPU, or 3D graphics donors, read:

- `{{DONOR_ROOT}}/selection-policy.md`
- `{{DONOR_ROOT}}/agent-lookup.md` first when the prompt mixes Vulkan with broad 3D, renderer,
  simulation, asset-pipeline, volume, neural, or XR wording
- `{{DONOR_ROOT}}/native-engineering-infrastructure.md` when Vulkan work includes project templates,
  shader validation scripts, profiling lanes, GPU CI, or update-safe generated infrastructure
- `{{DONOR_ROOT}}/vulkan-foundation-tooling.md` for memory allocation, loader/bootstrap, shader
  reflection, SPIR-V validation, and shader compilation/cross-compilation
- `{{DONOR_ROOT}}/graphics-rendering.md`
- `{{DONOR_ROOT}}/profiles/vulkan-memory-allocator.md` for allocation and memory-budget policy
- `{{DONOR_ROOT}}/profiles/spirv-toolchain.md` for shader toolchain/reflection policy
- `{{DONOR_ROOT}}/profiles/khronos-vulkan-samples.md` for portable Vulkan correctness
- `{{DONOR_ROOT}}/profiles/nvidia-vk-mini-samples.md` for NVIDIA extension/tooling samples
- `{{DONOR_ROOT}}/profiles/filament.md`, `{{DONOR_ROOT}}/profiles/diligent-engine.md`,
  `{{DONOR_ROOT}}/profiles/bgfx.md`, or `{{DONOR_ROOT}}/profiles/magnum.md` when choosing a renderer
  backbone or graphics middleware
- `{{DONOR_ROOT}}/profiles/dawn.md` when native WebGPU, `webgpu.h`, WGSL/Tint, or WebGPU backend
  portability is explicitly in scope
- `{{DONOR_ROOT}}/profiles/pbrt-v4.md`, `{{DONOR_ROOT}}/profiles/mitsuba3.md`,
  `{{DONOR_ROOT}}/profiles/falcor.md`, or `{{DONOR_ROOT}}/profiles/threejs-pathtracing.md` when
  path tracing, physical rendering, differentiable rendering, render graphs, or realtime ray-tracing
  framework concepts are relevant

For glTF/GLB runtime asset loading or Vulkan viewers, also read `{{DONOR_ROOT}}/gltf-runtime-assets.md`
and `{{DONOR_ROOT}}/profiles/fastgltf-cgltf-tinygltf.md`. For renderer-ready mesh conditioning, broad
asset import, BVH, ray-query, physics, point-cloud, or simulation context, also read
`{{DONOR_ROOT}}/geometry-simulation.md` plus the matching meshoptimizer, assimp, BVH, Embree, Jolt, or
Bullet profile. Use OSPRay as a CPU visualization reference, and Godot Engine or Open 3D Engine only
for engine/editor architecture references when that scale is in scope. For OpenXR, VR, AR, MR,
headset/controller, or spatial interaction context, also read
`{{DONOR_ROOT}}/xr-spatial.md` and
`{{DONOR_ROOT}}/profiles/openxr-sdk.md`. Use Khronos samples as the first correctness reference, then
vendor samples for vendor-specific extensions or tools. Keep study-only and non-commercial references
out of reusable Vulkan code.

For Vulkan-adjacent volume, medical/scientific volume, texture, material, NURBS/asset-pipeline,
terrain/geospatial, BIM/IFC, CAD viewing, VFX/particles, fluids, muscle/flesh, or XR work, also route
through `{{DONOR_ROOT}}/volumes-voxels.md`, `{{DONOR_ROOT}}/medical-scientific-volumes.md`,
`{{DONOR_ROOT}}/texture-material-color.md`, `{{DONOR_ROOT}}/assets-meshes-materials.md`,
`{{DONOR_ROOT}}/terrain-geospatial.md`, `{{DONOR_ROOT}}/bim-aec-ifc.md`,
`{{DONOR_ROOT}}/cad-precision-geometry.md`, `{{DONOR_ROOT}}/vfx-particles.md`,
`{{DONOR_ROOT}}/simulation-gpu.md`, `{{DONOR_ROOT}}/muscle-flesh-biomechanics.md`, and
`{{DONOR_ROOT}}/xr-spatial.md` as needed. Use fVDB, VTK, ITK, HDF5, Cesium Native, IfcOpenShell, CGAL,
Monado, and Godot OpenXR Vendors as dependency/reference-scale donors; use TinyEXR, tinynurbs, xatlas,
Vortex2D, OpenXR-Hpp, and NVIDIA xr_multi_gpu only for narrow matching needs. Keep Blender, FreeCAD,
HairWorks, Voreen, NVIDIA Flow, and vendor SDKs study-only.

For Vulkan-first neural 3D, Gaussian splatting, or AI-runtime visualization, also read
`{{DONOR_ROOT}}/neural-3d.md` and the relevant gsplat, Nerfstudio, PyTorch3D, Kaolin, Open3D, or
study-only neural graphics profile. Use CUDA-heavy neural donors for algorithms, layouts, and tests;
do not add CUDA runtime requirements unless the user explicitly chooses CUDA or mixed interop.

The donor library is shared across CUDA, Vulkan, CPU, DirectX, OpenCL, DCC, and other backend sources.
Do not reject a CUDA or non-Vulkan donor when it is the best domain reference; use it for algorithms,
data models, tests, or architecture, then translate backend-specific kernels, synchronization, memory
ownership, shaders, and build requirements into the Vulkan lane. Do not add CUDA runtime requirements
or CUDA/Vulkan interop to a Vulkan project unless the user explicitly chooses that mixed lane or the
requirements force it.
