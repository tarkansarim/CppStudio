# Donor Source Map

Accessed: 2026-04-30
Expanded: 2026-05-01

This source map lists the first-pass donor candidates for 3D, graphics, GPU, AI, production-routing,
and native engineering infrastructure work. License notes are routing signals, not a replacement for
checking the upstream license file before reuse.

Language/runtime caveat: `safe-donor` does not mean "direct native C++ donor." Python, JavaScript,
TypeScript, notebook, JIT/DSL, service-runtime, web-engine, DCC-script, model, dataset, and asset
sources are reference-only for native C++/CUDA/Vulkan unless the user explicitly chooses that
runtime or artifact. Use them for behavior, algorithms, fixtures, architecture, and validation
targets; implement native code through the active C++/CUDA/Vulkan lane.

## Graphics And Rendering

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [Khronos Vulkan-Samples](https://github.com/KhronosGroup/Vulkan-Samples) | Vulkan foundations | safe-donor | Apache-2.0 samples covering API, performance, extensions, tooling, and headless/offscreen usage. |
| [NVIDIA vk_mini_samples](https://github.com/nvpro-samples/vk_mini_samples) | Vulkan foundations | safe-donor | Apache-2.0 modern Vulkan samples for ray tracing, descriptors, mesh shaders, shader printf, compute, and NVIDIA tooling. |
| [Google Filament](https://github.com/google/filament) | Renderer backbone | dependency-candidate | Apache-2.0 real-time PBR renderer with Vulkan/OpenGL/Metal/WebGL backends and glTF tooling. |
| [Diligent Engine](https://github.com/DiligentGraphics/DiligentEngine) | Renderer backbone | dependency-candidate | Apache-2.0 cross-API rendering framework over Vulkan, D3D, Metal, OpenGL, WebGPU. |
| [bgfx](https://github.com/bkaradzic/bgfx) | Renderer backbone | dependency-candidate | BSD-2-Clause/CC0 signals; cross-platform graphics API abstraction and shader tools. |
| [Magnum](https://github.com/mosra/magnum) | C++ graphics middleware | safe-donor | MIT/Expat lightweight graphics middleware and examples. |
| [Google Dawn](https://github.com/google/dawn) | WebGPU | dependency-candidate | BSD-3-Clause native WebGPU implementation and Tint/WGSL tooling. |
| [three.js](https://github.com/mrdoob/three.js) | Web 3D | safe-donor | MIT browser 3D library with a large example ecosystem. Reference-only for native C++. |
| [Babylon.js](https://github.com/BabylonJS/Babylon.js/) | Web 3D | safe-donor | Apache-2.0 TypeScript/WebGPU/WebXR 3D engine. Reference-only for native C++. |
| [pbrt-v4](https://github.com/mmp/pbrt-v4) | Physical rendering | safe-donor | Apache-2.0 reference renderer for physically based rendering. |
| [Mitsuba 3](https://github.com/mitsuba-renderer/mitsuba3) | Physical/differentiable rendering | safe-donor | BSD-style retargetable renderer with differentiable rendering support. |
| [NVIDIA Falcor](https://github.com/NVIDIAGameWorks/Falcor) | Realtime ray tracing | dependency-candidate | BSD-3-Clause core with separate component licenses for DLSS/RTXGI/RTXDI/NRD. |
| [THREE.js PathTracing Renderer](https://github.com/erichlof/THREE.js-PathTracing-Renderer) | Web path tracing | safe-donor | CC0-1.0 WebGL path tracing examples. Reference-only for native C++. |

## Native GUI, HUD, And Editor UI

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [Dear ImGui](https://github.com/ocornut/imgui) | Immediate-mode tool UI | safe-donor | MIT C++ debug HUD, editor panel, viewport overlay, and realtime tool UI stack with multiple renderer backends. |
| [ImGuizmo](https://github.com/CedricGuillemet/ImGuizmo) | Viewport gizmos | safe-donor | MIT Dear ImGui extension for transform/view gizmos and adjacent editor controls. |
| [ImPlot](https://github.com/epezent/implot) | Plotting and telemetry | safe-donor | MIT Dear ImGui plotting extension for realtime profiler, telemetry, curves, and heatmaps. |
| [Qt](https://doc.qt.io/qt-6/) | Desktop app framework | dependency-candidate | Commercial/GPL/LGPL module mix; full C++ desktop/QML framework and tooling. |
| [wxWidgets](https://wxwidgets.org/) | Native desktop widgets | dependency-candidate | wxWindows License with exception; C++ cross-platform native-widget desktop apps. |
| [RmlUi](https://github.com/mikke89/RmlUi) | Runtime/game UI | safe-donor | MIT HTML/CSS-like C++ UI library for game HUDs, menus, overlays, and tool UI. |
| [NoesisGUI](https://www.noesisengine.com/noesisgui/) | Commercial runtime UI | dependency-candidate | Commercial XAML-style UI middleware for games and realtime applications. |
| [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear) | Tiny immediate-mode UI | safe-donor | MIT/public-domain single-header C immediate-mode GUI. |
| [FLTK](https://www.fltk.org/) | Lightweight desktop UI | dependency-candidate | LGPL with exception; small cross-platform C++ GUI toolkit. |
| [libui-ng](https://github.com/libui-ng/libui-ng) | Small native widgets | dependency-candidate | MIT portable C native-widget library; maturity risk to evaluate. |
| [Chromium Embedded Framework](https://chromiumembedded.github.io/cef/) | Embedded web UI | dependency-candidate | BSD-style CEF plus Chromium notice/deployment surface for HTML/CSS/JS UI in native apps. |

## Geometry, Assets, And Simulation

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [assimp](https://github.com/assimp/assimp) | Asset import/export | dependency-candidate | BSD-3-Clause based importer/exporter for many 3D formats. |
| [meshoptimizer](https://github.com/zeux/meshoptimizer) | Mesh optimization | safe-donor | MIT mesh optimization, compression, simplification, and glTF-friendly pipeline code. |
| [Open3D](https://github.com/isl-org/Open3D) | 3D data processing | dependency-candidate | MIT C++/Python library for point clouds, reconstruction, mesh processing, rendering, and ML integration. |
| [Embree](https://github.com/RenderKit/embree) | CPU ray tracing | dependency-candidate | Apache-2.0 high-performance ray tracing kernels. |
| [OSPRay](https://github.com/RenderKit/ospray) | CPU rendering | dependency-candidate | Apache-2.0 scalable CPU rendering engine built around RenderKit components. |
| [madmann91/bvh](https://github.com/madmann91/bvh) | BVH | safe-donor | MIT standalone C++20 BVH construction/traversal. |
| [Jolt Physics](https://github.com/jrouwe/JoltPhysics) | Physics | dependency-candidate | MIT modern C++ rigid body physics/collision library. |
| [Bullet Physics](https://github.com/bulletphysics/bullet3) | Physics | dependency-candidate | zlib physics/collision SDK with robotics and ML simulation usage. |
| [Godot Engine](https://github.com/godotengine/godot) | Engine architecture | dependency-candidate | MIT engine/editor architecture; large enough to use primarily as design reference. |
| [Open 3D Engine](https://github.com/o3de/o3de) | Engine architecture | dependency-candidate | Apache-2.0/MIT dual-license default, with third-party component caveats; large engine architecture, asset pipeline, component systems. |

## AI Runtimes, Kernels, And Compilers

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [llama.cpp](https://github.com/ggml-org/llama.cpp) | Local LLM inference | safe-donor | MIT C/C++ LLM runtime with quantization and multiple GPU backends. |
| [ggml](https://ggml.ai/) | Tensor runtime | safe-donor | MIT lightweight tensor and quantization runtime foundation. |
| [ONNX Runtime](https://github.com/microsoft/onnxruntime) | Inference runtime | dependency-candidate | MIT production inference/training accelerator with execution providers. |
| [TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM) | NVIDIA LLM serving | dependency-candidate | Apache-2.0 plus notices; NVIDIA-optimized LLM serving and C++ runtime pieces. |
| [vLLM](https://github.com/vllm-project/vllm) | LLM serving | dependency-candidate | Apache-2.0 high-throughput serving with paged attention/continuous batching. |
| [MLC-LLM](https://github.com/mlc-ai/mlc-llm) | Cross-platform LLM deployment | dependency-candidate | Apache-2.0 TVM-powered deployment across GPUs, mobile, and WebGPU. |
| [CUTLASS](https://github.com/NVIDIA/cutlass) | CUDA kernels | safe-donor | BSD-3-Clause CUDA GEMM/convolution/reduction templates. |
| [Triton](https://github.com/triton-lang/triton) | GPU kernel DSL/compiler | safe-donor | MIT Python/JIT language/compiler for custom deep-learning primitives. Reference-only for native C++ unless that toolchain is explicitly chosen. |
| [FlashAttention](https://github.com/Dao-AILab/flash-attention) | Attention kernels | safe-donor | BSD-3-Clause efficient exact attention kernels and PyTorch extension patterns. Inspect CUDA/C++ kernels separately from Python/PyTorch packaging. |
| [tiny-cuda-nn](https://github.com/NVlabs/tiny-cuda-nn) | Neural CUDA kernels | safe-donor | BSD-3-Clause fused MLPs and hash-grid encoding patterns. |
| [Apache TVM](https://github.com/apache/tvm) | ML compiler | dependency-candidate | Apache-2.0 compiler/runtime stack for model deployment across hardware backends. |
| [PyTorch](https://github.com/pytorch/pytorch) | Tensor framework | dependency-candidate | BSD-style tensor/autograd/CUDA dispatch reference; dependency-scale architecture/reference unless PyTorch/libtorch is explicitly chosen. |

## Neural 3D

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [Nerfstudio](https://github.com/nerfstudio-project/nerfstudio) | NeRF/3DGS workflows | dependency-candidate | Apache-2.0 modular framework for neural radiance fields and Gaussian splatting workflows. Workflow reference-only for native C++. |
| [gsplat](https://github.com/nerfstudio-project/gsplat) | Gaussian splatting | safe-donor | Apache-2.0 CUDA accelerated Gaussian rasterization with Python bindings. Inspect CUDA/C++ operator code separately; Python/PyTorch wrapper is reference-only for native C++. |
| [NVIDIA Kaolin](https://github.com/NVIDIAGameWorks/kaolin) | 3D deep learning | dependency-candidate | Mostly Apache-2.0, with restricted `kaolin/non_commercial` area. Python/PyTorch reference-only for native C++. |
| [PyTorch3D](https://github.com/facebookresearch/pytorch3d) | Differentiable 3D ops | dependency-candidate | BSD-style reusable components for 3D deep learning. Python/PyTorch reference-only for native C++. |
| [graphdeco-inria/gaussian-splatting](https://github.com/graphdeco-inria/gaussian-splatting) | Original 3DGS | study-only | Non-commercial/research-only license; use for concepts and behavior checks only. |
| [NVlabs/instant-ngp](https://github.com/NVlabs/instant-ngp) | Neural graphics primitives | study-only | NVIDIA Source Code License with non-commercial use limitation. |
| [Kaolin Wisp](https://github.com/NVIDIAGameWorks/kaolin-wisp) | Neural fields | study-only | NVIDIA Source Code License with non-commercial use limitation. |

## Hair, Grooming, And Fur

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [AMD TressFX](https://github.com/GPUOpen-Effects/TressFX) | Hair/fur runtime | safe-donor | MIT GPU hair/fur simulation and rendering with Vulkan/DX12 sample paths. |
| [O3DE Atom TressFX Gem](https://docs.o3de.org/docs/user-guide/gems/reference/rendering/amd/atom-tressfx/) | Engine integration | dependency-candidate | O3DE license defaults plus component notices; useful for TressFX-style engine integration. |
| [NVIDIA HairWorks docs](https://docs.nvidia.com/gameworks/content/artisttools/hairworks/) | Hair authoring/runtime concepts | study-only | GameWorks terms; use for concepts only unless project has an explicit license path. |
| [Blender Curves Groom Brushes](https://github.com/blender/blender/tree/main/source/blender/editors/sculpt_paint/curves) | Groom brush source study | study-only | GPL-family source; extract behavior contracts for curve sculpt brushes, pressure/falloff, masks, surface binding, and validation only. |
| [Blender Hair Curves](https://docs.blender.org/manual/en/latest/modeling/geometry_nodes/hair/index.html) | Groom authoring UX | study-only | Blender code is GPL; study guide/follow, clump, trim, attach, and grooming workflows. |

## DCC Scene Pipelines

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [OpenUSD](https://github.com/PixarAnimationStudios/OpenUSD) | Scene composition | dependency-candidate | Modified Apache-style license plus third-party notices; scene layers, variants, payloads, schemas. |
| [Alembic](https://github.com/alembic/alembic) | Animated geometry cache | dependency-candidate | BSD-style license; baked animated geometry, curves, and DCC caches. |
| [MaterialX](https://github.com/AcademySoftwareFoundation/MaterialX) | Material interchange | dependency-candidate | Apache-2.0 material/look-development graph standard. |
| [OpenTimelineIO](https://github.com/AcademySoftwareFoundation/OpenTimelineIO) | Editorial interchange | dependency-candidate | Apache-2.0 timeline interchange for review, virtual production, and multi-shot tools. |

## Volumes And Voxels

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [OpenVDB](https://github.com/AcademySoftwareFoundation/openvdb) | Sparse volumes | dependency-candidate | Apache-2.0 current releases; older releases were MPL-2.0. |
| [NanoVDB](https://developer.nvidia.com/nanovdb) | GPU VDB traversal | safe-donor | Part of OpenVDB; compact GPU-friendly VDB representation and traversal. |
| [fVDB](https://openvdb.github.io/fvdb-core/) | GPU sparse-volume tensors | dependency-candidate | Apache-2.0 sparse-volume tensors and neural 3D/ML-oriented volume work. Reference-only for native C++ unless Python/PyTorch/CUDA is explicit. |
| [VTK](https://docs.vtk.org/en/latest/about.html) | Scientific visualization | dependency-candidate | BSD-style visualization toolkit for volume rendering and image processing. |

## Animation And Rigging

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [ozz-animation](https://github.com/guillaumeblanc/ozz-animation) | Skeletal runtime | safe-donor | MIT data-oriented C++ skeletal animation runtime and offline conversion. |
| [Animation Compression Library](https://github.com/nfrechette/acl) | Animation compression | safe-donor | MIT animation clip compression/decompression and accuracy/performance tests. |
| [OpenUSD UsdSkel](https://openusd.org/dev/api/usd_skel_page_front.html) | Animation interchange | dependency-candidate | USD skeletal animation, skinning, and blend-shape schema reference. |

## Surfaces, Subdivision, And Geometry Processing

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [OpenSubdiv](https://github.com/PixarAnimationStudios/OpenSubdiv) | Subdivision surfaces | safe-donor | Apache-style Tomorrow license; Catmull-Clark and feature-adaptive subdivision. |
| [libigl](https://github.com/libigl/libigl) | Geometry processing | dependency-candidate | Primarily MPL-2.0 with GPL/copyleft subfolders and third-party caveats. |
| [CGAL](https://www.cgal.org/) | Robust geometry | dependency-candidate | Mixed LGPL/GPL by package with commercial option. |
| [meshoptimizer](https://github.com/zeux/meshoptimizer) | Runtime mesh conditioning | safe-donor | MIT mesh simplification, optimization, compression, and glTF-friendly pipeline code. |

## Texture, Material, And Color

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [KTX-Software](https://github.com/KhronosGroup/KTX-Software) | KTX/KTX2 tooling | dependency-candidate | Mostly Apache-2.0-compatible with many licenses and explicit special cases. |
| [Basis Universal](https://github.com/BinomialLLC/basis_universal) | Texture compression/transcoding | safe-donor | Apache-2.0 portable GPU supercompressed texture codec. |
| [OpenImageIO](https://github.com/AcademySoftwareFoundation/OpenImageIO) | Image IO | dependency-candidate | Apache-2.0 original code; docs CC BY 4.0; VFX image processing. |
| [OpenColorIO](https://github.com/AcademySoftwareFoundation/OpenColorIO) | Color management | dependency-candidate | BSD-3-Clause color management for VFX and animation. |
| [TinyEXR](https://github.com/syoyo/tinyexr) | Minimal EXR IO | safe-donor | BSD-3-Clause lightweight EXR read/write patterns. |

## CAD And Precision Geometry

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [Open CASCADE Technology](https://github.com/Open-Cascade-SAS/OCCT) | CAD kernel | dependency-candidate | LGPL-2.1 with Open CASCADE exception; B-rep/NURBS, STEP/IGES, topology. |
| [FreeCAD](https://github.com/FreeCAD/FreeCAD) | CAD UX and workflows | study-only | LGPL/GPL mix and dependency-heavy app architecture; study workflow concepts only by default. |

## Advanced Simulation And GPU Simulation

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [NVIDIA Warp](https://github.com/NVIDIA/warp) | GPU/differentiable simulation | dependency-candidate | Apache-2.0 Python CUDA simulation, robotics, and spatial computing framework. Prototype/reference-only for native C++ unless Python/JIT is explicit. |
| [Taichi](https://github.com/taichi-dev/taichi) | Portable simulation DSL | dependency-candidate | Apache-2.0 Python CPU/GPU programming DSL for simulation and differentiable programming. Reference-only for native C++. |
| [PositionBasedDynamics](https://github.com/InteractiveComputerGraphics/PositionBasedDynamics) | PBD simulation | safe-donor | MIT rigid/deformable/fluid position-based simulation library. |
| [Project Chrono](https://projectchrono.org/) | Multiphysics | dependency-candidate | BSD-3-Clause multibody, vehicle, terrain, granular, FEA, and fluid-solid simulation. |
| [SOFA](https://github.com/sofa-framework/sofa) | Deformable/medical simulation | dependency-candidate | LGPL-2.1/GPL/plugin mix; inspect module licenses. |
| [NVIDIA PhysX](https://github.com/NVIDIA-Omniverse/PhysX) | Realtime physics | dependency-candidate | BSD-3-Clause signals; inspect SDK notices and optional components. |

## XR And Spatial Interaction

| Source | Category | Tier | Signal |
| --- | --- | --- | --- |
| [Khronos OpenXR-SDK-Source](https://github.com/KhronosGroup/OpenXR-SDK-Source) | OpenXR foundations | safe-donor | Apache-2.0 plus generated-file notices; loader, layers, samples, and `hello_xr`. |
| [OpenXR-Hpp](https://github.com/KhronosGroup/OpenXR-Hpp) | C++ OpenXR bindings | safe-donor | Apache-2.0 type-safe OpenXR wrapper patterns. |
| [Monado](https://monado.dev/) | OpenXR runtime | dependency-candidate | Permissive open-source OpenXR runtime architecture for Linux, Windows, and Android. |
| [Godot XR docs](https://docs.godotengine.org/en/stable/tutorials/xr/index.html) | Engine XR UX | dependency-candidate | Godot MIT; plugin/vendor assets and SDKs vary. |

## 2026-05-01 Gap-Pass Additions

These additions were promoted from staged research into nested category files and compact deep-profile
bundles. Category files are the normal routing layer; profile bundles are the third layer for deeper
selection and caveats.

| Source Bundle | Category File | Deep Profile | Signal |
| --- | --- | --- | --- |
| NURBS, Rhino `.3dm`, UV atlases, Draco, ASTC/DDS tooling, OpenPBR, OpenAssetIO | [assets-meshes-materials.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/assets-meshes-materials.md) | [asset-pipeline-nurbs-textures.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/asset-pipeline-nurbs-textures.md) | Mixed safe/dependency donor set for asset-pipeline routing. |
| Fluids, smoke, fire, SPH, Vulkan fluids, CUDA samples, CFD/LBM study routes | [simulation-gpu.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/simulation-gpu.md) | [fluids-smoke-fire.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/fluids-smoke-fire.md) | Mixed CUDA/Vulkan/CPU/OpenCL solver references with strong license caveats. |
| Terrain, geospatial, 3D Tiles, CRS, point clouds, vector maps | [terrain-geospatial.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/terrain-geospatial.md) | [terrain-geospatial-3dtiles.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/terrain-geospatial-3dtiles.md) | Native C++ geospatial runtime and conversion donor set. |
| Realtime VFX, particles, indirect drawing, GPU sorting, effect runtimes | [vfx-particles.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/vfx-particles.md) | [vfx-particles-gpu-driven.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/vfx-particles-gpu-driven.md) | Mixed Vulkan/CUDA/cross-API VFX donor set. |
| BIM, AEC, IFC, buildingSMART validation, BCF | [bim-aec-ifc.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/bim-aec-ifc.md) | [bim-ifc-aec.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/bim-ifc-aec.md) | IFC/BIM routing with geometry, schema, validation, and license separation. |
| Retargeting, skinning decomposition, crowds, steering | [animation-rigging.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/animation-rigging.md) | [animation-retargeting-crowds.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/animation-retargeting-crowds.md) | Animation/crowd donor expansion with fixture-license caveats. |
| Muscles, flesh, soft tissue, biomechanics, anatomical references | [muscle-flesh-biomechanics.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/muscle-flesh-biomechanics.md) | [muscle-flesh-biomechanics.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/muscle-flesh-biomechanics.md) | Biomechanics versus realtime deformation routing with data/model caveats. |
| Medical/scientific volume IO, DICOM/NIfTI, transfer functions, large arrays | [medical-scientific-volumes.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/medical-scientific-volumes.md) | [medical-scientific-volume-io.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/medical-scientific-volume-io.md) | Medical/scientific dense-volume routing with patient-data caveats. |
| XR interaction, vendor extensions, spatial input, API layers, multi-GPU XR | [xr-spatial.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/xr-spatial.md) | [xr-interaction-spatial-input.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/xr-interaction-spatial-input.md) | Portable OpenXR plus vendor/system/performance reference routing. |

## 2026-05-01 Production Routing And Native Infrastructure

These additions add production-language overlays and a coding-infrastructure donor category without
duplicating the canonical technical donor files.

| Source Bundle | Routing File | Deep Profile | Signal |
| --- | --- | --- | --- |
| VFX studio departments: modeling, texturing, rigging, creature FX, look development, lighting, FX | [vfx-studio.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/production/vfx-studio.md) | Existing technical categories | Production overlay for VFX/animation department vocabulary. |
| Game studio disciplines: character/world art, technical art, gameplay animation, realtime VFX, rendering, tools, physics, XR games | [games.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/production/games.md) | Existing technical categories | Production overlay for game-studio and realtime-engine vocabulary. |
| Native engineering infrastructure routing: templates, build, dependency, testing, validation, profiling, CI, update safety | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | Native infrastructure profiles | Canonical coding-infrastructure donor category. |
| CMake templates, cmake-init, cpp-best-practices/cmake_template, modern-cpp-template, Pitchfork | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [cmake-project-templates.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/cmake-project-templates.md) | C++ project layout and CMake template donors. |
| Copier, Cruft, Cookiecutter, Yeoman | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [template-update-systems.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/template-update-systems.md) | Update-aware template and scaffold workflow donors. |
| vcpkg, Conan, CPM.cmake, CMake FetchContent | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [dependency-management.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/dependency-management.md) | Native dependency and package-policy donors. |
| GoogleTest, Catch2, doctest, Google Benchmark, CTest/GoogleTest CMake integration | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [testing-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/testing-infrastructure.md) | Test harness and benchmark donor set. |
| clang-format, clang-tidy, include-what-you-use, cppcheck | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [static-analysis-formatting.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/static-analysis-formatting.md) | Static-analysis and formatting donor set. |
| LLVM sanitizers and NVIDIA Compute Sanitizer | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [sanitizer-validation-lanes.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/sanitizer-validation-lanes.md) | CPU/GPU sanitizer lane references. |
| SPIRV-Tools, shaderc, glslang, Vulkan ValidationLayers | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [gpu-shader-validation.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/gpu-shader-validation.md) | Shader and Vulkan validation lane donors. |
| Tracy, Perfetto, RenderDoc, Nsight Systems | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [profiling-observability.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/profiling-observability.md) | Profiling and observability donor set. |
| GitHub Actions self-hosted runners, Actions runner, NVIDIA container toolkit | [native-engineering-infrastructure.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md) | [ci-gpu-runners.md](../../skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/ci-gpu-runners.md) | GPU CI and runner infrastructure references. |
