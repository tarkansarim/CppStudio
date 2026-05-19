---
name: modern-cpp-cmake
description: "Modern C++/CUDA project structure with CMake targets, source ownership, presets, CTest, imported GPU targets, clang tools, and build hygiene."
---

# Modern C++ CMake

Use this skill to shape C++ or C++/CUDA projects so the build graph, source layout, and verification path stay clear. Prefer the repository's existing conventions first; apply these rules when the repo has no stronger local pattern.

## Initial Read

Before editing project structure or build files:

1. Read the root `CMakeLists.txt`, `CMakePresets.json`, and package files such as `conanfile.*`, `vcpkg.json`, or toolchain files.
2. Inspect the current source layout and identify which files are host-only, CUDA-only, renderer/graphics-facing, tests, tools, or public API.
3. Find all build targets affected by the change and the test command that proves those targets still compile.
4. Check whether the project already pins C++ and CUDA standards, compiler warnings, sanitizer options, and GPU architectures.

## Default Layout

For greenfield or weakly structured C++/CUDA projects, prefer:

- `CMakeLists.txt` at the repo root.
- `cmake/` for toolchains, package helpers, and presets.
- `include/<project>/` for stable public headers.
- `src/app/` for executable entrypoints, CLI, window loops, input, and orchestration.
- `src/core/` for host-only shared logic, config, math, and data structures.
- `src/cuda/` for kernels, launch wrappers, CUDA-specific helpers, and `.cuh` files.
- `src/render/` for renderer orchestration, graphics interop, swapchain/presenter code, and API-specific code.
- `tests/unit/` and `tests/integration/` for correctness coverage.
- Optional benchmark, shader, asset, and tool directories only when the project needs them.

Do not dump all headers or sources into the repo root. Create only boundaries that correspond to real ownership.

## File Ownership

- Use `.cpp` for host-only translation units compiled by the C++ compiler.
- Use `.hpp` or `.h` for host-only public or private declarations that do not require CUDA syntax.
- Use `.cu` for kernels, launch wrappers, or translation units that require `nvcc`.
- Use `.cuh` for CUDA-specific declarations, device helpers, CUDA vector types, and shared kernel declarations.
- Keep CUDA runtime headers out of public host-only headers unless the public API genuinely exposes CUDA types.
- Split graphics headers away from `nvcc`-compiled units when Vulkan, OpenGL, GLFW, or platform headers fight CUDA compilation.
- Keep kernel parameter structs compact and explicit; avoid sprawling kernel argument lists when a small POD struct gives a stable contract.

## CMake Rules

- Use first-class language support: `project(<name> LANGUAGES CXX CUDA)` when CUDA is part of the target graph.
- Do not use deprecated `find_package(CUDA)` in new work.
- Set `CMAKE_CXX_STANDARD` and `CMAKE_CUDA_STANDARD` explicitly, or use target properties when the repo already does.
- Set `CMAKE_CUDA_ARCHITECTURES` explicitly. Do not rely on compiler defaults for GPU code.
- Use `find_package(CUDAToolkit REQUIRED)` and imported targets such as `CUDA::cudart`, `CUDA::cublas`, or `CUDA::cuda_driver` when toolkit libraries are needed.
- Prefer target-scoped includes, compile definitions, compile options, and link libraries.
- Prefer out-of-source builds in `build/` or configured preset directories.
- Keep the first executable path simple; split libraries only when the boundary is real and improves testability or reuse.
- Wire tests through `enable_testing()` and CTest. Use `gtest_discover_tests()` when the repo uses GoogleTest.
- Avoid global warning or optimization flags that leak into vendored dependencies.

## Dependency Policy

- Prefer the repository's existing package manager. Do not introduce Conan, vcpkg, FetchContent, submodules, or system packages without a concrete reason.
- For CUDA libraries, prefer imported CMake targets over raw library paths.
- For Vulkan, GLFW, OpenGL, or shader tools, keep discovery local and explicit. If a binary such as `glslc`, `glslangValidator`, or `spirv-val` is required, make the build fail clearly when it is absent.
- For tests, do not silently download large dependencies unless the repo already uses that pattern.

## Donor References

When choosing external 3D, graphics, GPU, AI-runtime, or ML-kernel dependencies, use the CppStudio
donor library after this skill fires. Default installed paths:

- `${CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio/references/donor-library`
- `${CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio/references/project-archetypes.md`

Start with:

- `README.md`
- `selection-policy.md`
- `agent-lookup.md` when more than one donor category could fit the dependency request
- `production/native-engineering-infrastructure.md` when the request is about project scaffolding,
  build/test/profiling lanes, CI, dependency policy, or template update safety
- `native-engineering-infrastructure.md` for CMake/project templates, testing, validation, static
  analysis, dependency management, profiling, and GPU CI donors
- `project-archetypes.md`

Use permissive donors for reusable code. Keep study-only references out of templates and shared
infrastructure.

For native C++ project infrastructure, route through `native-engineering-infrastructure.md` before
proposing CMake templates, package
managers, test frameworks, sanitizer lanes, profiling integrations, GPU CI, or update workflows. Treat
cmake-init, cpp-best-practices/cmake_template, modern-cpp-template, Copier, Cruft, vcpkg, Conan,
GoogleTest, Catch2, doctest, clang tools, Compute Sanitizer, SPIR-V tooling, Tracy, Perfetto,
RenderDoc, Nsight, and GitHub Actions runner docs as infrastructure donors; preserve the target
repo's existing dependency and update policy unless the user explicitly asks to change it.

For Vulkan foundation dependencies, route memory allocation, loader/bootstrap, and shader-tooling
questions through `vulkan-foundation-tooling.md`. For runtime 3D asset loading, glTF/GLB validation,
or viewer/importer dependencies, route through `gltf-runtime-assets.md`.

For native C++ GUI, HUD, editor panels, viewport overlays, docking, gizmos, plotting, desktop app UI,
runtime/game UI, or embedded web UI dependencies, route through `native-gui-hud.md` before proposing
Qt, wxWidgets, Dear ImGui, ImGuizmo, ImPlot, RmlUi, NoesisGUI, Nuklear, FLTK, libui-ng, or CEF
wiring. Include visual inspection links when presenting the options to the user.

For renderer backbone, graphics middleware, runtime mesh import, mesh conditioning, BVH, or
physics/collision dependency choices, route through `graphics-rendering.md` and
`geometry-simulation.md` before proposing CMake dependency wiring. Treat Filament,
Diligent Engine, bgfx, Dawn, Falcor, OSPRay, assimp, Embree, Jolt, Bullet, Godot Engine, and Open 3D
Engine as dependency candidates unless the target repo explicitly accepts them; meshoptimizer, Magnum,
madmann91/bvh, three.js, Babylon.js, pbrt-v4, Mitsuba 3, and THREE.js PathTracing Renderer can be
narrower safe or reference donors after exact-version review. Use engine-scale donors for architecture
only unless the project intentionally adopts the engine.

For AI-runtime, ML compiler, neural 3D, or model-serving dependency choices, route through
`ai-runtimes-kernels.md` and `neural-3d.md` before proposing CMake or package wiring. Treat ONNX
Runtime, TensorRT-LLM, vLLM, MLC-LLM, TVM, PyTorch, Nerfstudio, Kaolin, PyTorch3D, and Open3D as
dependency candidates unless the target repo explicitly accepts them; keep model weights, generated
engines, compiled artifacts, datasets, and tokenizer files out of reusable templates.

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

## Renderer Bootstrap

For a renderer-style CUDA application, start with the smallest coherent path:

- `include/<project>/types.hpp` or `common.hpp`
- `src/app/main.cpp`
- `include/<project>/camera.hpp` plus `src/app/camera.cpp` when camera logic is host-side
- `include/<project>/renderer.hpp` plus `src/render/renderer.cpp`
- `src/cuda/render_kernels.cu`
- `src/cuda/<kernel_domain>.cuh` when kernels share device helpers

Keep camera, UI, config, and app state host-side unless kernels truly need the data. Pass kernels compact, versionable parameter structs.

## Review Checklist

Before claiming the layout or build change is ready:

- Every touched target has a clear owner and compile language.
- Public headers expose only stable API and do not drag in avoidable implementation headers.
- CUDA architecture selection is explicit when CUDA is enabled.
- Test targets still build and are discoverable through CTest or the repo's test runner.
- Build commands are documented by evidence from the repo, not guessed.
- No empty files, empty directories, or speculative abstractions were added.
