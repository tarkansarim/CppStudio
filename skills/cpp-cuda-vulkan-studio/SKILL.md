---
name: cpp-cuda-vulkan-studio
description: "Create, audit, or upgrade reusable C++/CUDA/Vulkan project infrastructure with a studio-grade backbone: app+library layout, CMake presets, CTest labels, CUDA architecture policy, Vulkan/shader tooling, sanitizer/profile lanes, self-hosted GPU CI, dependency documentation, validation scripts, and curated 3D/AI/GPU donor-reference selection. Use for new GPU C++ repos, infrastructure upgrades, build/test/profiling standardization, or when Codex needs vetted donors for graphics, 3D, Vulkan foundation tooling, glTF/runtime assets, WebGPU/WebGL, renderer backbones, path tracing, engine architecture, runtime mesh pipelines, AI runtimes, ML compilers, neural 3D, Gaussian splatting, grooming/fur, DCC scene pipelines, volumes/voxels, animation/rigging, textures/materials/color, CAD geometry, 3D/physics/GPU simulation, XR, CUDA, Vulkan, rendering, or AI-runtime work."
---

# C++ CUDA Vulkan Studio

Use this skill when a C++/CUDA/Vulkan repo needs a repeatable professional development backbone, not a one-off local build. This skill coordinates the more specific global skills instead of replacing them.

## Coordination

- Use `modern-cpp-cmake` for CMake target structure, source ownership, presets, CTest, and dependency wiring.
- Use `cuda-kernel-authoring` when adding or reviewing custom CUDA kernels or launch wrappers.
- Use `vulkan-compute-sync` when the project contains Vulkan compute, render, synchronization, descriptor, or frame-lifetime work.
- Use `gpu-profiling-workstation` only when the active session exposes it and the user needs environment-specific profiling or frame-debugging commands.
- Use `verification-before-completion` before claiming the generated or upgraded backbone is valid.

## Workflow

1. Inspect the target repo first: `CMakeLists.txt`, `CMakePresets.json`, package manifests, `.github/workflows`, `cmake/`, `tests/`, `scripts/`, and docs.
2. For a greenfield repo, run `scripts/scaffold_gpu_cpp_project.py` from this skill and then adapt only project names and required dependency switches.
3. For an existing repo, run `scripts/apply_studio_backbone.py` against a temporary copy first unless the user explicitly wants direct modification.
4. Preserve any existing package manager or project-specific dependency policy. Do not introduce vcpkg, Conan, containers, FetchContent, or submodules unless there is a concrete reason.
5. Keep CUDA and Vulkan optional through CMake cache options. For unspecified new GPU/3D/realtime/XR/cross-platform C++ projects, recommend and scaffold Vulkan-first: the normal `dev` preset is Vulkan-only, CUDA stays off unless the user explicitly chooses the CUDA lane or the requirements force CUDA.
6. Do not mix CUDA into a Vulkan-chosen or Vulkan-assumed project by default. Use CUDA only for explicit CUDA/Vulkan interop, CUDA-specific compute, NVIDIA-only libraries, CUDA graphs, or custom CUDA kernels. When the user explicitly chooses CUDA, Vulkan may be added for presentation, realtime visualization, XR, swapchain/display work, or interop if the boundary is documented.
7. For new Vulkan template work, target Vulkan 1.4 with Vulkan-Hpp RAII, GLSL compiled by `glslc`, SPIR-V validation by `spirv-val`, and optional portability-enumeration support for MoltenVK-style platforms.
8. Register tests with CTest labels so quick, GPU, GUI, Vulkan, CUDA, shader, compute, render, validation, perf, and nightly lanes can be selected independently.
9. Treat profiling as evidence only when the report is readable and the command matches the workload being claimed.
10. Before greenfield scaffolding or major backbone edits, read `references/project-archetypes.md` and pick the closest lane: Vulkan app, CUDA library, CUDA+Vulkan interop app, AI runtime, neural 3D viewer, grooming/fur tool, glTF/runtime asset viewer, renderer backbone/runtime mesh pipeline, DCC scene pipeline, volume/voxel renderer, animation runtime, material pipeline, CAD geometry tool, 3D/physics/GPU simulation tool, or XR app.
11. When borrowing patterns, APIs, examples, or dependency ideas from external 3D/AI/GPU projects, read `references/donor-library/README.md` first and then the relevant category/profile file. For broad or overlapping prompts such as "3D viewer", "renderer", "simulation", "asset pipeline", "AI runtime", "volume viewer", or "XR app", read `references/donor-library/agent-lookup.md` before choosing category files. Treat donors as domain references first: a CUDA, Vulkan, OpenCL, DirectX, CPU, or DCC donor can still guide another target backend. Keep the selected implementation lane fixed, translate backend-specific details through the active lane skill, and keep permissive donor code, dependency candidates, and study-only references separated.

## Bundled Assets

- `assets/app-library-template/`: full app+library C++/Vulkan-first/CUDA-optional starter layout with CMake presets, CTest, sample C++ library/app, Vulkan default targets, explicit CUDA and CUDA+Vulkan interop lanes, docs, clang tooling, and GitHub self-hosted GPU CI.

## Bundled References

- `references/donor-library/`: curated donor-source library for Vulkan foundation tooling, glTF/runtime assets, WebGPU/WebGL, renderer backbones, path tracing, engine architecture, runtime mesh pipelines, graphics, rendering, geometry, 3D/physics/GPU simulation, AI runtimes, ML compilers, CUDA kernels, neural 3D, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, and XR code. Donor backend signals describe the upstream implementation, not a restriction on target lanes. Start with `references/donor-library/README.md`; for broad or ambiguous donor requests use `references/donor-library/agent-lookup.md`, then load only the category file needed for the active task.
- `references/project-archetypes.md`: lane-selection guide for CUDA-only, Vulkan-only, CUDA+Vulkan interop, AI runtime, neural 3D, grooming, glTF/runtime assets, renderer backbone/runtime mesh pipeline, DCC, volume, animation, material, CAD, 3D/physics/GPU simulation, and XR projects.

## Bundled Scripts

- `scripts/scaffold_gpu_cpp_project.py`: create a new project from the template.
- `scripts/apply_studio_backbone.py`: copy backbone files into an existing repo without overwriting by default.
- `scripts/validate_studio_backbone.py`: check that required backbone files and labels are present.
- `scripts/check_dev_tools.sh`: verify compilers, CUDA, Vulkan, shader, and optional profiler tools.
- `scripts/select_idle_gpu.sh`: choose an idle NVIDIA GPU, optionally constrained by `GPU_ALLOWED_INDICES`, using utilization and display-server subtraction.
- `scripts/run_compute_sanitizer.sh`: run a command or GPU CTest preset under Compute Sanitizer.
- `scripts/run_vulkan_validation.sh`: run a Vulkan command or validation CTest preset with Khronos validation enabled.
- `scripts/dump_vulkan_capabilities.sh`: capture `vulkaninfo` summary and text reports for loader/ICD diagnostics.
- `scripts/run_nsys_smoke.sh`: run an app/probe under Nsight Systems and verify stats can read the report.
- `scripts/format_check.sh`: run clang-format in check-only mode.
- `scripts/tidy_check.sh`: run clang-tidy against a compile database in check-only mode.

## Acceptance

For a new scaffold, verify:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

For this skill itself, verify:

```bash
${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py ${HOME}/.codex/skills/cpp-cuda-vulkan-studio
```
