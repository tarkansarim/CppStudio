## Donor References

When selecting Vulkan, renderer, WebGPU, or 3D graphics donors, read:

- `{{DONOR_ROOT}}/selection-policy.md`
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

For glTF/GLB runtime asset loading or Vulkan viewers, also read `{{DONOR_ROOT}}/gltf-runtime-assets.md`
and `{{DONOR_ROOT}}/profiles/fastgltf-cgltf-tinygltf.md`. For renderer-ready mesh conditioning, broad
asset import, BVH, ray-query, physics, point-cloud, or simulation context, also read
`{{DONOR_ROOT}}/geometry-simulation.md` plus the matching meshoptimizer, assimp, BVH, Embree, Jolt, or
Bullet profile. For OpenXR, VR, AR, MR, headset/controller, or spatial interaction context, also read
`{{DONOR_ROOT}}/xr-spatial.md` and
`{{DONOR_ROOT}}/profiles/openxr-sdk.md`. Use Khronos samples as the first correctness reference, then
vendor samples for vendor-specific extensions or tools. Keep study-only and non-commercial references
out of reusable Vulkan code.

The donor library is shared across CUDA, Vulkan, CPU, DirectX, OpenCL, DCC, and other backend sources.
Do not reject a CUDA or non-Vulkan donor when it is the best domain reference; use it for algorithms,
data models, tests, or architecture, then translate backend-specific kernels, synchronization, memory
ownership, shaders, and build requirements into the Vulkan lane. Do not add CUDA runtime requirements
or CUDA/Vulkan interop to a Vulkan project unless the user explicitly chooses that mixed lane or the
requirements force it.
