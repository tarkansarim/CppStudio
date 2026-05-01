## Donor References

When choosing external 3D, graphics, GPU, AI-runtime, or ML-kernel dependencies, read:

- `{{DONOR_ROOT}}/README.md`
- `{{DONOR_ROOT}}/selection-policy.md`
- `{{REFERENCE_ROOT}}/project-archetypes.md`

Use permissive donors for reusable code. Keep study-only references out of templates and shared
infrastructure.

For Vulkan foundation dependencies, route memory allocation, loader/bootstrap, and shader-tooling
questions through `{{DONOR_ROOT}}/vulkan-foundation-tooling.md`. For runtime 3D asset loading,
glTF/GLB validation, or viewer/importer dependencies, route through
`{{DONOR_ROOT}}/gltf-runtime-assets.md`.

For renderer backbone, graphics middleware, runtime mesh import, mesh conditioning, BVH, or
physics/collision dependency choices, route through `{{DONOR_ROOT}}/graphics-rendering.md` and
`{{DONOR_ROOT}}/geometry-simulation.md` before proposing CMake dependency wiring. Treat Filament,
Diligent Engine, bgfx, assimp, Embree, Jolt, and Bullet as dependency candidates unless the target
repo explicitly accepts them; meshoptimizer, Magnum, and madmann91/bvh can be narrower safe donors
after exact-version review.

For AI-runtime, ML compiler, neural 3D, or model-serving dependency choices, route through
`{{DONOR_ROOT}}/ai-runtimes-kernels.md` and `{{DONOR_ROOT}}/neural-3d.md` before proposing CMake or
package wiring. Treat ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, PyTorch, Nerfstudio, Kaolin,
PyTorch3D, and Open3D as dependency candidates unless the target repo explicitly accepts them; keep
model weights, generated engines, compiled artifacts, datasets, and tokenizer files out of reusable
templates.

Donors are domain references first, not lane locks. A donor's CUDA, Vulkan, OpenCL, DirectX, CPU, or
DCC backend signal describes upstream implementation context only. Keep the target project's selected
lane and dependency policy intact, and route backend-specific translation through `cpp-cuda-vulkan-studio`
plus the active CUDA or Vulkan companion skill.
