# Donor Library

Last researched: 2026-04-30

Use this library when a C++/CUDA/Vulkan/3D/AI-runtime/ML-kernel task needs source-backed donor
projects, examples, architecture patterns, or dependency candidates. It covers Vulkan foundation
tooling, runtime assets, renderer backbones, runtime mesh pipelines, WebGPU/WebGL, browser 3D,
path tracing, physical rendering, engine architecture, geometry, AI runtimes, ML compilers, neural
3D, grooming, DCC scene pipelines, volumes, animation, materials, CAD, 3D/physics/GPU simulation,
and XR. Treat it as a domain-first selection map, not permission to copy large blocks of code.

## How To Use

1. Read [selection-policy.md](selection-policy.md) before copying, adapting, or recommending any donor.
2. For broad or overlapping prompts, read [agent-lookup.md](agent-lookup.md) to choose the smallest
   category/profile set. Skip it when the request already names a specific category.
3. Pick one relevant category file and load only that file:
   - [vulkan-foundation-tooling.md](vulkan-foundation-tooling.md): Vulkan memory allocation, loader/bootstrap, shader reflection, SPIR-V tooling.
   - [graphics-rendering.md](graphics-rendering.md): renderer backbones, render graphs, WebGPU/WebGL, PBR, path tracing.
   - [gltf-runtime-assets.md](gltf-runtime-assets.md): glTF loading, validation, fixtures, runtime asset handoff.
   - [geometry-simulation.md](geometry-simulation.md): asset import, mesh conditioning, BVH, point clouds, physics.
   - [ai-runtimes-kernels.md](ai-runtimes-kernels.md): LLM runtimes, inference engines, CUDA kernels, ML compilers.
   - [neural-3d.md](neural-3d.md): NeRFs, Gaussian splatting, differentiable rendering, 3D ML workflows.
   - [hair-grooming-fur.md](hair-grooming-fur.md): realtime hair/fur, strand data, grooming, groom interchange.
   - [dcc-scene-pipeline.md](dcc-scene-pipeline.md): USD, Alembic, MaterialX, DCC interchange, editorial pipelines.
   - [volumes-voxels.md](volumes-voxels.md): sparse volumes, VDB/NanoVDB, voxel grids, GPU volume rendering.
   - [animation-rigging.md](animation-rigging.md): skeletal animation, skinning, runtime sampling, compression.
   - [surfaces-subdivision.md](surfaces-subdivision.md): subdivision surfaces, geometry processing, remeshing.
   - [texture-material-color.md](texture-material-color.md): KTX/Basis, image IO, color management, material graphs.
   - [cad-precision-geometry.md](cad-precision-geometry.md): B-reps, NURBS, STEP/IGES, CAD kernels, exact geometry.
   - [simulation-gpu.md](simulation-gpu.md): differentiable simulation, cloth, fluids, deformables, multiphysics.
   - [xr-spatial.md](xr-spatial.md): OpenXR, spatial interaction, headset/controller input, stereo swapchains.
   - [profiles/](profiles/): deeper first-stop notes for the highest-value donors.
4. For implementation work, prefer these outputs:
   - Use permissive safe donors for implementation patterns, small adapted snippets, and tests.
   - Use dependency candidates as package/API/architecture references unless the target repo already accepts
     that dependency and license shape.
   - Use study-only donors for concepts only; do not copy code into reusable skills, templates, or project code.
   - Treat non-C/C++ donors as reference-only for native C++/CUDA/Vulkan targets unless the user explicitly
     chooses that runtime. A permissive Python, TypeScript, JavaScript, notebook, JIT/DSL, service, or DCC
     project can guide algorithms, behavior, tests, UX, and architecture, but it is not a direct C++ code donor.
5. Keep donor backend and target backend separate:
   - Use donors for domain behavior, algorithms, data models, tests, architecture, and dependency shape even
     when their upstream backend is CUDA, Vulkan, OpenCL, DirectX, CPU, or DCC-specific.
   - Use the selected lane skill to translate backend-specific code, synchronization, memory ownership,
     shaders, kernels, build flags, and runtime dependencies.
   - Do not switch a Vulkan project to CUDA, or a CUDA project to Vulkan, just because the best donor uses the
     other backend. Mixed lanes require explicit user choice or a real interop requirement.
6. Record the donor name, URL, license, backend signal, and exact feature borrowed in project docs or comments when adopting code.

## License Tiers

- `safe-donor`: permissive source license such as MIT, Apache-2.0, BSD-2/3-Clause, zlib, or CC0.
- `dependency-candidate`: dependency-scale, license-sensitive, copyleft-with-exception, mixed-license, or
  transitive-dependency-heavy source. Use only after exact-version dependency and license review.
- `study-only`: non-commercial, source-available, GPL-family, unclear, or dependency/license-mixed source. Concepts can inform design, but code should not be copied without explicit approval.

## Backend Signals

Backend signals describe where the upstream donor's examples or implementation live. They are not
target-lane restrictions.

- `native-vulkan`, `native-cuda`, `native-opencl`, `native-directx`, `native-opengl`,
  `native-webgpu`, `native-metal`: donor has substantial backend-specific implementation in that API.
- `native-cpu`: donor is primarily CPU/native C++ or CPU-first.
- `dcc-interchange`: donor is primarily scene, asset, material, animation, groom, or DCC pipeline data.
- `api-agnostic`: donor is mainly format, architecture, algorithm, or API-independent guidance.
- `mixed-backend`: donor intentionally supports or demonstrates multiple execution/rendering backends.

## Agent Rules

- Do not mix `study-only` code into `safe-donor` outputs.
- Do not assume a repo-level license covers assets, models, datasets, or submodules.
- Prefer official repos and docs over summaries.
- Before vendoring code, inspect the repo license file and any third-party notice files at the exact revision used.
- Prefer linking or package-manager integration over copying whole donor trees.
- Before copying code into a native C++ repo, confirm the specific donor files are C or C++. Otherwise keep
  the donor as reference-only and implement an independent C++/CUDA/Vulkan port.
- For AI/model pipelines, treat model weights and datasets as separate license surfaces from code.
- Backend mismatch is not a rejection reason by itself. It is a porting note for the lane-specific skill.

## Deep Profiles

Read these only when the task matches the donor:

- [CUTLASS](profiles/cutlass.md): CUDA GEMM/convolution/reduction templates, CuTe, tiling, tensor-core kernels.
- [FlashAttention](profiles/flashattention.md): IO-aware exact attention kernels and CUDA/PyTorch extension patterns; inspect CUDA/C++ kernels separately from Python/PyTorch packaging.
- [Triton](profiles/triton.md): Python-authored GPU kernel DSL/compiler patterns; reference-only for native C++ unless Python/JIT tooling is explicitly accepted.
- [llama.cpp and ggml](profiles/llama-ggml.md): local C/C++ LLM inference, GGUF, quantization, and portable backend patterns.
- [ONNX Runtime](profiles/onnx-runtime.md): ONNX inference sessions, execution providers, and graph-runtime boundaries.
- [TensorRT-LLM](profiles/tensorrt-llm.md): NVIDIA TensorRT LLM serving, engine orchestration, KV cache, and CUDA deployment.
- [vLLM](profiles/vllm.md): high-throughput LLM serving, paged attention, batching, and OpenAI-compatible APIs; service/runtime reference, not a small embedded C++ donor.
- [MLC-LLM](profiles/mlc-llm.md): compiled cross-platform LLM deployment across GPU, mobile, WebGPU, and native runtimes.
- [tiny-cuda-nn](profiles/tiny-cuda-nn.md): CUDA fused MLPs, hash grids, neural encodings, and neural graphics kernels.
- [Apache TVM](profiles/tvm.md): ML compiler architecture, tensor IR, generated kernels, and multi-target runtimes.
- [PyTorch](profiles/pytorch.md): tensor/autograd/runtime architecture, custom-op references, and package dependency boundaries; reference/dependency-scale for native C++.
- [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md): portable Vulkan correctness and best-practice samples.
- [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md): NVIDIA Vulkan extensions, tooling, and compact samples.
- [Vulkan Memory Allocator](profiles/vulkan-memory-allocator.md): Vulkan allocation, memory budgets, pools, and mapping policy.
- [volk](profiles/volk.md): Vulkan loader, dispatch, and extension entrypoint setup.
- [vk-bootstrap](profiles/vk-bootstrap.md): Vulkan instance/device/swapchain bootstrap helpers.
- [SPIR-V Toolchain](profiles/spirv-toolchain.md): SPIR-V reflection, validation, compilation, and cross-compilation.
- [Slang](profiles/slang.md): multi-target shader authoring, generics, reflection, and compiler integration.
- [glTF C/C++ Loaders](profiles/fastgltf-cgltf-tinygltf.md): fastgltf, cgltf, tinygltf runtime loader choices.
- [Google Filament](profiles/filament.md): realtime PBR renderer architecture, material tools, and glTF viewer pipelines.
- [Diligent Engine](profiles/diligent-engine.md): cross-API renderer abstraction and high-level rendering components.
- [bgfx](profiles/bgfx.md): bring-your-own-engine multi-backend renderer abstraction and shader toolchain.
- [Magnum](profiles/magnum.md): lightweight C++ graphics middleware and modular graphics utilities.
- [Google Dawn](profiles/dawn.md): native WebGPU, `webgpu.h`, WGSL/Tint tooling, and WebGPU backend portability references.
- [three.js](profiles/threejs.md): browser 3D scene, controls, loader, WebGPU/WebGL, and WebXR behavior references; reference-only for native C++.
- [Babylon.js](profiles/babylonjs.md): full browser 3D engine, WebGPU/WebXR, scene tooling, and TypeScript engine architecture; reference-only for native C++.
- [pbrt-v4](profiles/pbrt-v4.md): physically based rendering algorithms, sampling, materials, scene formats, and path-tracing references.
- [Mitsuba 3](profiles/mitsuba3.md): differentiable, retargetable, spectral, and inverse-rendering references.
- [NVIDIA Falcor](profiles/falcor.md): realtime ray-tracing framework, render graphs, and NVIDIA RTX SDK boundary references.
- [THREE.js PathTracing Renderer](profiles/threejs-pathtracing.md): browser/WebGL path-tracing demos, progressive accumulation, and interactive path-tracing UX references; reference-only for native C++.
- [meshoptimizer](profiles/meshoptimizer.md): mesh conditioning, simplification, compression, and glTF optimization.
- [assimp](profiles/assimp.md): broad 3D asset import/export and conversion pipeline boundaries.
- [Embree](profiles/embree.md): CPU ray tracing kernels, BVHs, and ray-query validation references.
- [OSPRay](profiles/ospray.md): scalable CPU visualization renderer architecture, volumes, and RenderKit-style rendering APIs.
- [madmann91/bvh](profiles/madmann91-bvh.md): compact C++20 BVH construction and traversal.
- [Jolt Physics](profiles/jolt-physics.md): modern native C++ rigid-body physics and collision.
- [Bullet Physics](profiles/bullet-physics.md): broad physics, collision, robotics, and ML simulation ecosystem references.
- [Godot Engine](profiles/godot-engine.md): engine/editor architecture, scene trees, resource ownership, and rendering/physics integration patterns.
- [Open 3D Engine](profiles/open-3d-engine.md): large-scale engine architecture, asset processor, component systems, and editor/runtime split patterns.
- [gsplat](profiles/gsplat.md): CUDA Gaussian splatting rasterization and neural 3D operator packaging; Python/PyTorch wrapper is reference-only for native C++.
- [Nerfstudio](profiles/nerfstudio.md): NeRF/3DGS training workflows, camera/data processing, viewers, and export flows; workflow reference-only for native C++.
- [NVIDIA Kaolin](profiles/kaolin.md): 3D deep-learning ops, differentiable rendering, and conversion utilities; Python/PyTorch reference-only for native C++.
- [PyTorch3D](profiles/pytorch3d.md): differentiable rendering, cameras, mesh/point-cloud ops, and reference outputs; Python/PyTorch reference-only for native C++.
- [Open3D](profiles/open3d.md): 3D data processing, point clouds, reconstruction, visualization, and Open3D-ML.
- [Neural Graphics Study-Only References](profiles/neural-graphics-study-only.md): GraphDeco Gaussian Splatting, instant-ngp, and Kaolin Wisp concepts without code reuse.
- [AMD TressFX](profiles/tressfx.md): realtime GPU hair/fur simulation and rendering.
- [NVIDIA HairWorks Study-Only](profiles/hairworks-study-only.md): GameWorks hair authoring/runtime concepts without code reuse.
- [Blender Study-Only](profiles/blender-study-only.md): DCC UX, geometry nodes, grooming, import/export, and editor workflow concepts without code reuse.
- [OpenUSD](profiles/openusd.md): scene composition, USD schemas, DCC interchange, curves, skeletons, materials.
- [Alembic](profiles/alembic.md): baked animated geometry, curves, simulation caches, and DCC cache IO.
- [MaterialX](profiles/materialx.md): material/look-development graph interchange and shader generation boundaries.
- [OpenTimelineIO](profiles/opentimelineio.md): editorial timeline, review, and virtual-production interchange.
- [OpenVDB and NanoVDB](profiles/openvdb-nanovdb.md): sparse volume IO and GPU-friendly VDB traversal.
- [fVDB](profiles/fvdb.md): sparse-volume tensors, PyTorch/CUDA sparse-grid ML, and neural-volume references; reference-only unless Python/PyTorch/CUDA is explicitly chosen.
- [VTK](profiles/vtk.md): scientific visualization, volume rendering, and VTK data/filter pipeline architecture.
- [ozz-animation](profiles/ozz-animation.md): data-oriented skeletal animation runtime and offline conversion.
- [Animation Compression Library](profiles/acl.md): animation clip compression, decompression, and accuracy benchmarks.
- [OpenSubdiv](profiles/opensubdiv.md): subdivision-surface semantics and CPU/GPU evaluation.
- [libigl](profiles/libigl.md): mesh processing, deformation, remeshing, parameterization, and geometry-processing references.
- [CGAL](profiles/cgal.md): robust computational geometry, exact predicates, triangulation, Booleans, and mesh generation.
- [KTX-Software and Basis Universal](profiles/ktx-basis.md): KTX2 texture containers and GPU texture transcoding.
- [OpenColorIO and OpenImageIO](profiles/opencolorio-openimageio.md): color management and VFX image IO.
- [TinyEXR](profiles/tinyexr.md): minimal EXR/HDR image IO and small renderer image fixtures.
- [Open CASCADE Technology](profiles/open-cascade.md): CAD-native B-rep/NURBS, STEP/IGES, and precision geometry.
- [FreeCAD Study-Only](profiles/freecad-study-only.md): CAD UX, parametric modeling, workbench, and Open CASCADE application workflow concepts without code reuse.
- [OpenXR SDK](profiles/openxr-sdk.md): portable OpenXR loader, samples, validation layers, and Vulkan/XR structure.
- [OpenXR-Hpp](profiles/openxr-hpp.md): type-safe C++ OpenXR bindings and wrapper ergonomics.
- [Monado](profiles/monado.md): OpenXR runtime architecture, diagnostics, and Linux runtime behavior references.
- [Godot OpenXR Vendors](profiles/godot-openxr-vendors.md): vendor-specific OpenXR extension wrappers and Godot XR plugin references.
- [NVIDIA Warp](profiles/warp.md): Python-authored CUDA simulation kernels and differentiable simulation; prototype/reference-only for native C++.
- [Taichi](profiles/taichi.md): portable CPU/GPU simulation DSL and differentiable physical simulation; Python DSL reference-only for native C++.
- [PositionBasedDynamics](profiles/positionbaseddynamics.md): C++ PBD/XPBD constraints for interactive simulation.
- [Project Chrono](profiles/project-chrono.md): multiphysics and multibody dynamics simulation.
- [SOFA](profiles/sofa.md): medical/robotics multiphysics simulation architecture.
- [NVIDIA PhysX](profiles/physx.md): realtime physics, collision, constraints, destruction, and fluid/fire SDK lanes.
