## Donor References

When choosing external 3D, graphics, GPU, AI-runtime, or ML-kernel dependencies, read:

- `{{DONOR_ROOT}}/README.md`
- `{{DONOR_ROOT}}/selection-policy.md`
- `{{DONOR_ROOT}}/agent-lookup.md` when more than one donor category could fit the dependency request
- `{{DONOR_ROOT}}/production/native-engineering-infrastructure.md` when the request is about project
  scaffolding, build/test/profiling lanes, CI, dependency policy, or template update safety
- `{{DONOR_ROOT}}/native-engineering-infrastructure.md` for CMake/project templates, testing,
  validation, static analysis, dependency management, profiling, and GPU CI donors
- `{{REFERENCE_ROOT}}/project-archetypes.md`

Use permissive donors for reusable code. Keep study-only references out of templates and shared
infrastructure.

For native C++ project infrastructure, route through
`{{DONOR_ROOT}}/native-engineering-infrastructure.md` before proposing CMake templates, package
managers, test frameworks, sanitizer lanes, profiling integrations, GPU CI, or update workflows. Treat
cmake-init, cpp-best-practices/cmake_template, modern-cpp-template, Copier, Cruft, vcpkg, Conan,
GoogleTest, Catch2, doctest, clang tools, Compute Sanitizer, SPIR-V tooling, Tracy, Perfetto,
RenderDoc, Nsight, and GitHub Actions runner docs as infrastructure donors; preserve the target
repo's existing dependency and update policy unless the user explicitly asks to change it.

For Vulkan foundation dependencies, route memory allocation, loader/bootstrap, and shader-tooling
questions through `{{DONOR_ROOT}}/vulkan-foundation-tooling.md`. For runtime 3D asset loading,
glTF/GLB validation, or viewer/importer dependencies, route through
`{{DONOR_ROOT}}/gltf-runtime-assets.md`.

For renderer backbone, graphics middleware, runtime mesh import, mesh conditioning, BVH, or
physics/collision dependency choices, route through `{{DONOR_ROOT}}/graphics-rendering.md` and
`{{DONOR_ROOT}}/geometry-simulation.md` before proposing CMake dependency wiring. Treat Filament,
Diligent Engine, bgfx, Dawn, Falcor, OSPRay, assimp, Embree, Jolt, Bullet, Godot Engine, and Open 3D
Engine as dependency candidates unless the target repo explicitly accepts them; meshoptimizer, Magnum,
madmann91/bvh, three.js, Babylon.js, pbrt-v4, Mitsuba 3, and THREE.js PathTracing Renderer can be
narrower safe or reference donors after exact-version review. Use engine-scale donors for architecture
only unless the project intentionally adopts the engine.

For AI-runtime, ML compiler, neural 3D, or model-serving dependency choices, route through
`{{DONOR_ROOT}}/ai-runtimes-kernels.md` and `{{DONOR_ROOT}}/neural-3d.md` before proposing CMake or
package wiring. Treat ONNX Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, PyTorch, Nerfstudio, Kaolin,
PyTorch3D, and Open3D as dependency candidates unless the target repo explicitly accepts them; keep
model weights, generated engines, compiled artifacts, datasets, and tokenizer files out of reusable
templates.

For DCC, volume, medical/scientific volume, texture/material/color, asset/NURBS, terrain/geospatial,
BIM/IFC, CAD, geometry-processing, simulation, muscle/flesh, VFX/particles, animation/crowd, or XR
dependencies, route through the matching donor category before proposing package wiring. Treat OpenUSD,
Alembic, MaterialX, OpenTimelineIO, OpenVDB, fVDB, VTK, ITK, DCMTK, HDF5, TensorStore, OpenNURBS,
Draco, OpenAssetIO, Cesium Native, GDAL, IfcOpenShell, OCCT, CGAL, OpenSim, FEBio, Monado, and Godot
OpenXR Vendors as dependency candidates unless the target repo explicitly accepts them; keep Blender,
FreeCAD, HairWorks, Voreen, NVIDIA Flow, and vendor SDKs study-only unless the user explicitly accepts
their license/dependency shape. TinyEXR, OpenXR-Hpp, OpenSubdiv, ozz-animation, ACL, tinynurbs,
xatlas, Vortex2D, and narrow Basis Universal use can be smaller donors after exact-version review.

Donors are domain references first, not lane locks. A donor's CUDA, Vulkan, OpenCL, DirectX, CPU, or
DCC backend signal describes upstream implementation context only. Keep the target project's selected
lane and dependency policy intact, and route backend-specific translation through `cpp-cuda-vulkan-studio`
plus the active CUDA or Vulkan companion skill.
