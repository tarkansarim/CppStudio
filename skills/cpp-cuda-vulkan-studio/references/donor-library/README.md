# Donor Library

Last researched: 2026-04-30

Use this library when a C++/CUDA/Vulkan/3D/AI-runtime/ML-kernel task needs source-backed donor
projects, examples, architecture patterns, or dependency candidates. It covers rendering, geometry,
neural 3D, grooming, DCC scene pipelines, volumes, animation, materials, CAD, 3D/physics/GPU
simulation, and XR. Treat it as a selection map, not permission to copy large blocks of code.

## How To Use

1. Read [selection-policy.md](selection-policy.md) before copying, adapting, or recommending any donor.
2. Pick one relevant category file and load only that file:
   - [graphics-rendering.md](graphics-rendering.md): Vulkan, renderer backbones, WebGPU/WebGL, PBR, path tracing.
   - [geometry-simulation.md](geometry-simulation.md): asset import, mesh processing, BVH, point clouds, physics.
   - [ai-runtimes-kernels.md](ai-runtimes-kernels.md): LLM runtimes, inference engines, CUDA kernels, ML compilers.
   - [neural-3d.md](neural-3d.md): NeRFs, Gaussian splatting, differentiable rendering, 3D ML.
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
3. For implementation work, prefer these outputs:
   - Use permissive safe donors for implementation patterns, small adapted snippets, and tests.
   - Use dependency candidates as package/API/architecture references unless the target repo already accepts
     that dependency and license shape.
   - Use study-only donors for concepts only; do not copy code into reusable skills, templates, or project code.
4. Record the donor name, URL, license, and exact feature borrowed in project docs or comments when adopting code.

## License Tiers

- `safe-donor`: permissive source license such as MIT, Apache-2.0, BSD-2/3-Clause, zlib, or CC0.
- `dependency-candidate`: dependency-scale, license-sensitive, copyleft-with-exception, mixed-license, or
  transitive-dependency-heavy source. Use only after exact-version dependency and license review.
- `study-only`: non-commercial, source-available, GPL-family, unclear, or dependency/license-mixed source. Concepts can inform design, but code should not be copied without explicit approval.

## Agent Rules

- Do not mix `study-only` code into `safe-donor` outputs.
- Do not assume a repo-level license covers assets, models, datasets, or submodules.
- Prefer official repos and docs over summaries.
- Before vendoring code, inspect the repo license file and any third-party notice files at the exact revision used.
- Prefer linking or package-manager integration over copying whole donor trees.
- For AI/model pipelines, treat model weights and datasets as separate license surfaces from code.

## Deep Profiles

Read these only when the task matches the donor:

- [CUTLASS](profiles/cutlass.md): CUDA GEMM/convolution/reduction templates, CuTe, tiling, tensor-core kernels.
- [FlashAttention](profiles/flashattention.md): IO-aware exact attention kernels and CUDA/PyTorch extension patterns.
- [Triton](profiles/triton.md): Python-authored GPU kernel DSL/compiler patterns.
- [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md): portable Vulkan correctness and best-practice samples.
- [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md): NVIDIA Vulkan extensions, tooling, and compact samples.
- [gsplat](profiles/gsplat.md): CUDA Gaussian splatting rasterization and neural 3D operator packaging.
- [AMD TressFX](profiles/tressfx.md): realtime GPU hair/fur simulation and rendering.
- [OpenUSD](profiles/openusd.md): scene composition, USD schemas, DCC interchange, curves, skeletons, materials.
- [Alembic](profiles/alembic.md): baked animated geometry, curves, simulation caches, and DCC cache IO.
- [MaterialX](profiles/materialx.md): material/look-development graph interchange and shader generation boundaries.
- [OpenVDB and NanoVDB](profiles/openvdb-nanovdb.md): sparse volume IO and GPU-friendly VDB traversal.
- [ozz-animation](profiles/ozz-animation.md): data-oriented skeletal animation runtime and offline conversion.
- [Animation Compression Library](profiles/acl.md): animation clip compression, decompression, and accuracy benchmarks.
- [OpenSubdiv](profiles/opensubdiv.md): subdivision-surface semantics and CPU/GPU evaluation.
- [KTX-Software and Basis Universal](profiles/ktx-basis.md): KTX2 texture containers and GPU texture transcoding.
- [OpenColorIO and OpenImageIO](profiles/opencolorio-openimageio.md): color management and VFX image IO.
- [Open CASCADE Technology](profiles/open-cascade.md): CAD-native B-rep/NURBS, STEP/IGES, and precision geometry.
- [OpenXR SDK](profiles/openxr-sdk.md): portable OpenXR loader, samples, validation layers, and Vulkan/XR structure.
- [NVIDIA Warp](profiles/warp.md): Python-authored CUDA simulation kernels and differentiable simulation.
- [Taichi](profiles/taichi.md): portable CPU/GPU simulation DSL and differentiable physical simulation.
- [PositionBasedDynamics](profiles/positionbaseddynamics.md): C++ PBD/XPBD constraints for interactive simulation.
- [Project Chrono](profiles/project-chrono.md): multiphysics and multibody dynamics simulation.
- [SOFA](profiles/sofa.md): medical/robotics multiphysics simulation architecture.
- [NVIDIA PhysX](profiles/physx.md): realtime physics, collision, constraints, destruction, and fluid/fire SDK lanes.
