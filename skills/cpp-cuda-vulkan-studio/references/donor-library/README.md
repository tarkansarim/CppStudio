# Donor Library

Last researched: 2026-05-01

Use this library when a C++/CUDA/Vulkan/3D/AI-runtime/ML-kernel task needs
source-backed donor projects, examples, architecture patterns, dependency candidates, or validation
fixtures. Treat donors as domain references first, not permission to copy large blocks of code.

## Progressive Loading

1. Read [selection-policy.md](selection-policy.md) before copying, adapting, or recommending donor code.
2. If the request uses VFX, game-studio, or engineering-infrastructure vocabulary, read
   [production/README.md](production/README.md) and choose one overlay route.
3. If the request is broad or crosses overlays, read [agent-lookup.md](agent-lookup.md) and choose the
   smallest matching category set.
4. Open the smallest matching category set. Choose one primary category first when possible; open
   secondary categories only when the selected overlay or task requires them.
5. Open [profiles/README.md](profiles/README.md) only when the needed category points to a specific
   deep profile or when auditing the whole donor inventory.

## Production Overlays

Use these overlays before technical category files when the prompt is phrased in studio or
engineering discipline terms:

- [production/vfx-studio.md](production/vfx-studio.md): modeling, texturing, rigging, creature FX,
  look development, lighting, and FX.
- [production/games.md](production/games.md): character/world art, technical art, gameplay animation,
  realtime VFX, lighting/post, rendering, tools, physics, and XR games.
- [production/native-engineering-infrastructure.md](production/native-engineering-infrastructure.md):
  project templates, CMake/build layout, testing, validation, profiling, CI, dependency policy, and
  template update safety.

## Category Router

3D, graphics, simulation, assets, and XR:

- [vulkan-foundation-tooling.md](vulkan-foundation-tooling.md): Vulkan allocation, bootstrap,
  validation, shader compilation/reflection, and SPIR-V tooling.
- [graphics-rendering.md](graphics-rendering.md): renderer backbones, render graphs, WebGPU/WebGL,
  PBR, path tracing, denoising, and reconstruction.
- [native-gui-hud.md](native-gui-hud.md): native C++ GUI toolkits, debug HUDs, editor panels,
  viewport overlays, gizmos, plotting, desktop app shells, runtime/game UI, and embedded web UI.
- [gltf-runtime-assets.md](gltf-runtime-assets.md): glTF loading, validation, fixtures, and runtime
  asset handoff.
- [assets-meshes-materials.md](assets-meshes-materials.md): NURBS/Rhino, UV atlases, compressed
  geometry, texture tooling, OpenPBR, and production asset management.
- [geometry-simulation.md](geometry-simulation.md): asset import, mesh conditioning, BVH, point
  clouds, physics, and engine/runtime architecture.
- [terrain-geospatial.md](terrain-geospatial.md): geospatial runtimes, terrain, 3D Tiles, CRS,
  point clouds, and map/vector-tile rendering.
- [vfx-particles.md](vfx-particles.md): realtime VFX, GPU particles, indirect rendering, sorting,
  and effects middleware.
- [bim-aec-ifc.md](bim-aec-ifc.md): IFC/BIM/AEC geometry, validation, BCF, and building model
  interchange.
- [simulation-gpu.md](simulation-gpu.md): differentiable simulation, fluids, smoke/fire, cloth,
  deformables, multiphysics, and CUDA/Vulkan solver references.
- [muscle-flesh-biomechanics.md](muscle-flesh-biomechanics.md): muscles, flesh, soft tissue,
  biomechanical solvers, and realtime deformation references.
- [neural-3d.md](neural-3d.md): NeRFs, Gaussian splatting, differentiable rendering, and neural 3D
  workflows.
- [hair-grooming-fur.md](hair-grooming-fur.md): realtime hair/fur, strand data, grooming brush
  authoring, groom interchange, and hair materials.
- [dcc-scene-pipeline.md](dcc-scene-pipeline.md): USD, Alembic, MaterialX, DCC interchange,
  editorial pipelines, and virtual production.
- [volumes-voxels.md](volumes-voxels.md): sparse volumes, VDB/NanoVDB, voxel grids, GPU volume
  traversal, and scientific volume rendering.
- [medical-scientific-volumes.md](medical-scientific-volumes.md): medical image IO, DICOM/NIfTI,
  scientific volume IO, transfer functions, and large array formats.
- [animation-rigging.md](animation-rigging.md): skeletal animation, skinning, runtime sampling,
  compression, retargeting, and crowds.
- [surfaces-subdivision.md](surfaces-subdivision.md): subdivision surfaces, geometry processing,
  remeshing, and robust geometry.
- [texture-material-color.md](texture-material-color.md): KTX/Basis, image IO, color management,
  material graphs, and texture compression.
- [cad-precision-geometry.md](cad-precision-geometry.md): B-reps, NURBS, STEP/IGES, CAD kernels,
  exact tolerances, and precision modeling workflows.
- [xr-spatial.md](xr-spatial.md): OpenXR, spatial interaction, headset/controller input, stereo
  swapchains, vendor extensions, and XR diagnostics.

AI, ML, and kernel infrastructure:

- [ai-runtimes-kernels.md](ai-runtimes-kernels.md): LLM runtimes, inference engines, CUDA kernels,
  ML compilers, graph runtimes, and tensor execution backends.

Native project infrastructure:

- [native-engineering-infrastructure.md](native-engineering-infrastructure.md): project templates,
  CMake/build layout, dependency policy, testing, validation, static analysis, profiling, GPU CI, and
  template update safety.

## Donor Tiers

- `safe-donor`: permissive source license such as MIT, Apache-2.0, BSD-2/3-Clause, zlib, or CC0.
- `dependency-candidate`: dependency-scale, license-sensitive, copyleft-with-exception,
  mixed-license, or transitive-dependency-heavy source. Use only after exact-version dependency and
  license review.
- `study-only`: non-commercial, source-available, GPL-family, unclear, or dependency/license-mixed
  source. Concepts can inform design, but code should not be copied without explicit approval.

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
- Do not assume a repo-level license covers assets, models, datasets, sample scenes, or submodules.
- Prefer official repos and docs over summaries.
- Before vendoring code, inspect the repo license file and any third-party notice files at the exact
  revision used.
- Prefer linking or package-manager integration over copying whole donor trees.
- Before copying code into a native C++ repo, confirm the specific donor files are C or C++. Otherwise
  keep the donor as reference-only and implement an independent C++/CUDA/Vulkan port.
- Treat non-C/C++ donors as reference-only for native C++/CUDA/Vulkan targets unless the user
  explicitly chooses that runtime. Use them for behavior, algorithms, tests, UX, and architecture.
- Backend mismatch is not a rejection reason by itself. Keep the selected implementation lane fixed
  and translate backend-specific details through the active Vulkan, CUDA, or explicit interop lane.
