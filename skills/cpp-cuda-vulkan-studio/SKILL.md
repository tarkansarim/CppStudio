---
name: cpp-cuda-vulkan-studio
description: "Create, audit, or upgrade reusable C++/CUDA/Vulkan project infrastructure with a studio-grade backbone: app+library layout, CMake presets, CTest labels, CUDA architecture policy, Vulkan/shader tooling, sanitizer/profile lanes, self-hosted GPU CI, dependency documentation, validation scripts, and curated 3D/AI/GPU donor-reference selection. Use for new GPU C++ repos, infrastructure upgrades, build/test/profiling standardization, or when Codex needs vetted donors for graphics, 3D, neural 3D, Gaussian splatting, grooming/fur, DCC scene pipelines, volumes/voxels, animation/rigging, textures/materials/color, CAD geometry, simulation, XR, CUDA, Vulkan, rendering, or AI-runtime work."
---

# C++ CUDA Vulkan Studio

Use this skill when a C++/CUDA/Vulkan repo needs a repeatable professional development backbone, not a one-off local build. This skill coordinates the more specific global skills instead of replacing them.

## Coordination

- Use `modern-cpp-cmake` for CMake target structure, source ownership, presets, CTest, and dependency wiring.
- Use `cuda-kernel-authoring` when adding or reviewing custom CUDA kernels or launch wrappers.
- Use `vulkan-compute-sync` when the project contains Vulkan compute, render, synchronization, descriptor, or frame-lifetime work.
- Use `gpu-profiling-workstation` when local profiling or frame debugging commands are needed on this workstation.
- Use `verification-before-completion` before claiming the generated or upgraded backbone is valid.

## Workflow

1. Inspect the target repo first: `CMakeLists.txt`, `CMakePresets.json`, package manifests, `.github/workflows`, `cmake/`, `tests/`, `scripts/`, and docs.
2. For a greenfield repo, run `scripts/scaffold_gpu_cpp_project.py` from this skill and then adapt only project names and required dependency switches.
3. For an existing repo, run `scripts/apply_studio_backbone.py` against a temporary copy first unless the user explicitly wants direct modification.
4. Preserve any existing package manager or project-specific dependency policy. Do not introduce vcpkg, Conan, containers, FetchContent, or submodules unless there is a concrete reason.
5. Keep CUDA and Vulkan optional through CMake cache options, but default the app+library template to both enabled.
6. For new Vulkan template work, target Vulkan 1.4 with Vulkan-Hpp RAII, GLSL compiled by `glslc`, and SPIR-V validation by `spirv-val`; keep MoltenVK/iOS portability explicit through capability checks and portability extension notes.
7. Register tests with CTest labels so quick, GPU, GUI, Vulkan, CUDA, shader, compute, render, validation, perf, and nightly lanes can be selected independently.
8. Treat profiling as evidence only when the report is readable and the command matches the workload being claimed.
9. Before greenfield scaffolding or major backbone edits, read `references/project-archetypes.md` and pick the closest lane: CUDA library, Vulkan app, CUDA+Vulkan interop app, AI runtime, neural 3D viewer, grooming/fur tool, DCC scene pipeline, volume/voxel renderer, animation runtime, material pipeline, CAD geometry tool, simulation tool, or XR app.
10. When borrowing patterns, APIs, examples, or dependency ideas from external 3D/AI/GPU projects, read `references/donor-library/README.md` first and then the relevant category/profile file. Keep permissive donor code, dependency candidates, and study-only references separated.

## Bundled Assets

- `assets/app-library-template/`: full app+library C++/CUDA/Vulkan starter layout with CMake presets, CTest, sample C++ library/app, optional CUDA/Vulkan targets, docs, clang tooling, and GitHub self-hosted GPU CI.

## Bundled References

- `references/donor-library/`: curated donor-source library for graphics, Vulkan, rendering, geometry, simulation, AI runtimes, CUDA kernels, neural 3D, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, and XR code. Start with `references/donor-library/README.md`; load only the category file needed for the active task.
- `references/project-archetypes.md`: lane-selection guide for CUDA-only, Vulkan-only, CUDA+Vulkan interop, AI runtime, neural 3D, grooming, DCC, volume, animation, material, CAD, simulation, and XR projects.

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
/home/tarkan/.codex/skills/.system/skill-creator/scripts/quick_validate.py /home/tarkan/.codex/skills/cpp-cuda-vulkan-studio
```
