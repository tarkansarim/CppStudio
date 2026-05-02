---
name: cpp-cuda-vulkan-studio
description: "Create, audit, or upgrade native C++ GPU project infrastructure for Vulkan-first, CUDA, or explicit CUDA/Vulkan interop lanes: app+library layout, CMake presets, CTest labels, CUDA architecture policy, Vulkan/shader tooling, sanitizer/profile lanes, self-hosted GPU CI, validation scripts, and donor-reference routing. Use for new or existing C++ repos, build/test/profiling standardization, custom CUDA/Vulkan implementation, or donor selection for native graphics/renderers, glTF/runtime assets, WebGPU/WebGL/OpenXR, path tracing, engine/runtime mesh pipelines, AI runtimes, ML compilers, neural 3D, Gaussian splatting, grooming/fur, DCC scene pipelines, volumes, animation, materials/color, CAD, physics/simulation, CUDA, Vulkan, or cross-backend GPU code. Do not use for design-only, frontend-only, storyboarding, generic image/video, generic AI assistant/product UI, plain text rendering, or ordinary data import unless native C++ GPU infrastructure or donor-reference selection is explicit."
---

# C++ CUDA Vulkan Studio

Use this skill when a native C++ GPU, C++/Vulkan, C++/CUDA, or mixed CUDA/Vulkan repo needs a repeatable professional development backbone, not a one-off local build. This skill coordinates the more specific global skills instead of replacing them.

## Agent Mindset

When this skill is active, work like a native C++ GPU systems engineer:

- Treat Vulkan as an explicit-lifetime API. Resource ownership, synchronization, image layouts, queue
  ownership, descriptor lifetime, command-buffer reuse, and frames-in-flight must be designed
  deliberately.
- Keep the active lane disciplined. Prefer Vulkan for unspecified reusable GPU/3D/realtime work, keep
  CUDA separate unless the user chooses it or the requirements force it, and document any deliberate
  CUDA/Vulkan interop boundary.
- Do not silently downgrade the work to get a green run. If CMake, CUDA, Vulkan SDK tools, shader
  compilation, validation layers, GPU selection, profilers, or tests fail, surface the failure and fix
  the root cause when it is in scope.
- Inspect before editing. Read the build graph, presets, target ownership, shader or kernel paths,
  dispatch/render loop, and direct callers before changing native GPU infrastructure.
- Before major C++/GPU edits, name the likely failure modes: synchronization or lifetime bugs, wrong
  device/backend lane, missing validation/profiling evidence, portability breaks, and
  dependency/license mistakes.
- Before risky GPU refactors, broad CMake/build-system changes, backend rewrites, synchronization
  changes, or target-project deployment/install script edits, create or confirm a recent git commit
  so rollback is exact and cheap. If the target repo has no suitable recent commit, ask before
  proceeding with high-risk edits.
- Use evidence before claims. Builds, CTest labels, shader compilation, Vulkan validation,
  Compute Sanitizer, RenderDoc/Nsight captures, screenshots, image comparisons, and profiler output
  matter more than plausible explanations.
- For realtime rendering, viewport, simulation, XR, or GPU-performance work, measure frame time/FPS
  or profiler timings while implementing and verify the actual visual output.
- Be donor-first. Use the donor library for architecture, edge cases, tests, algorithms, and
  dependency choices before inventing a new subsystem; when no suitable donor exists, add donor
  research before designing the implementation.
- Never copy study-only, incompatible-license, non-C++ reference-only, or backend-mismatched donor
  code into generated projects. Use those donors for concepts, then translate through the active
  Vulkan, CUDA, or explicit interop lane.
- Preserve user and project state. Managed markers may be replaced by this package, but project files,
  local rules, custom skills, and content outside managed marker blocks are user-owned.
- Produce usable infrastructure. Avoid stubs, toy-only scaffolds, disabled tests, placeholder kernels,
  or sample-only shortcuts unless the user explicitly asks for a throwaway prototype.
- Keep code maps lazy. Check only `.cppstudio/code-map-state.json` first; load the codebase map only
  when that state says `enabled`, and do not keep prompting when it says `declined`.

## Coordination

- Use `modern-cpp-cmake` for CMake target structure, source ownership, presets, CTest, and dependency wiring.
- Use `cuda-kernel-authoring` when adding or reviewing custom CUDA kernels or launch wrappers.
- Use `vulkan-compute-sync` when the project contains Vulkan compute, render, synchronization, descriptor, or frame-lifetime work.
- Use available profiling or frame-debugging skills and local profiler tools only when the active environment exposes them and the user needs performance or capture evidence.
- Use `verification-before-completion` before claiming the generated or upgraded backbone is valid.

## Workflow

1. Inspect the target repo first: `CMakeLists.txt`, `CMakePresets.json`, package manifests, `.github/workflows`, `cmake/`, `tests/`, `scripts/`, docs, and `.cppstudio/code-map-state.json` when present.
2. For a greenfield repo, run `scripts/scaffold_gpu_cpp_project.py` from this skill and then adapt only project names and required dependency switches.
3. For an existing repo, run `scripts/apply_studio_backbone.py` against a temporary copy first unless the user explicitly wants direct modification.
4. For a greenfield scaffold with no `.cppstudio/code-map-state.json`, ask once whether to create a maintained codebase architecture map. State the benefits: faster cold starts, cleaner multi-agent routing, explicit subsystem ownership, and less repeated code reading. If the user accepts, run `scripts/bootstrap_code_map.py --enable`; if they decline, run `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked.
5. For an existing project with no `.cppstudio/code-map-state.json`, treat code-map enablement as a readiness protocol. Run `scripts/bootstrap_code_map.py --audit-existing` first, read `docs/CODEMAP_BOOTSTRAP_AUDIT.md`, and summarize structure findings, nonstandard layout risks, and the estimated cleanup cost. Ask whether the user wants to restructure first, preserve the current layout and document exceptions, or decline the map. Do not run `--enable` until the user chooses either restructure-complete or preserve-as-is.
6. When `.cppstudio/code-map-state.json` says `enabled`, read `docs/CODEBASE_ARCHITECTURE_INDEX.md` and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` before broad edits. Keep the map updated when ownership, data flow, GPU backend boundaries, build/test lanes, validation, CI, or public runtime behavior changes. If the user asks about a code map mid-project, explain it, run the existing-project readiness protocol, and wait for acceptance before running `scripts/bootstrap_code_map.py --enable`; for large existing repos, use parallel subsystem audits when delegation is explicitly available.
7. Preserve any existing package manager or project-specific dependency policy. Do not introduce vcpkg, Conan, containers, FetchContent, or submodules unless there is a concrete reason.
8. Keep CUDA and Vulkan optional through CMake cache options. For unspecified new GPU/3D/realtime/XR/cross-platform C++ projects, recommend and scaffold Vulkan-first: the normal `dev` preset is Vulkan-only, CUDA stays off unless the user explicitly chooses the CUDA lane or the requirements force CUDA.
9. Do not mix CUDA into a Vulkan-chosen or Vulkan-assumed project by default. Use CUDA only for explicit CUDA/Vulkan interop, CUDA-specific compute, NVIDIA-only libraries, CUDA graphs, or custom CUDA kernels. When the user explicitly chooses CUDA, Vulkan may be added for presentation, realtime visualization, XR, swapchain/display work, or interop if the boundary is documented.
10. For new Vulkan template work, target Vulkan 1.3 with Vulkan-Hpp RAII, synchronization2, dynamic rendering, GLSL compiled by `glslc`, SPIR-V validation by `spirv-val`, and optional portability-enumeration support for MoltenVK-style platforms.
11. Register tests with CTest labels so quick, GPU, GUI, Vulkan, CUDA, shader, compute, render, validation, perf, and nightly lanes can be selected independently.
12. Treat profiling as evidence only when the report is readable and the command matches the workload being claimed.
13. Before greenfield scaffolding or major backbone edits, read `references/project-archetypes.md` and pick the closest lane: Vulkan app, CUDA library, CUDA+Vulkan combined/interop app, AI runtime, neural 3D viewer, grooming/fur tool, glTF/runtime asset viewer, renderer backbone/runtime mesh pipeline, DCC scene pipeline, volume/voxel renderer, animation runtime, material pipeline, CAD geometry tool, 3D/physics/GPU simulation tool, or XR app.
14. When borrowing patterns, APIs, examples, or dependency ideas from external 3D/AI/GPU projects, use the nested donor router. Read `references/donor-library/README.md` for policy; when the prompt uses VFX studio, game studio, or native engineering infrastructure vocabulary, use the production overlays under `references/donor-library/production/`; use `references/donor-library/agent-lookup.md` only when the prompt is broad or overlapping; then open the smallest matching category set, choosing one primary category first when possible, and only the donor profiles those categories name. Treat donors as domain references first: a CUDA, Vulkan, OpenCL, DirectX, CPU, or DCC donor can still guide another target backend. Keep the selected implementation lane fixed, translate backend-specific details through the active lane skill, and keep permissive donor code, dependency candidates, and study-only references separated.
15. Do not route design-only, frontend-only, storyboarding, generic image/video, generic product-AI UI, plain text rendering, or ordinary data import requests through this skill unless the user explicitly asks for native C++ GPU implementation, C++/CUDA/Vulkan infrastructure, or donor-reference selection.

## Existing Project Code Map Readiness Protocol

Before enabling a maintained code map for an existing repo, confirm the repo can support durable map maintenance:

1. Run `scripts/bootstrap_code_map.py --audit-existing` to write `docs/CODEMAP_BOOTSTRAP_AUDIT.md`.
2. Review build entrypoints, source/include ownership, tests, validation scripts, CI, docs, shader/CUDA/Vulkan ownership, generated build artifacts, and dependency/vendor boundaries.
3. Classify cleanup cost as small, medium, or large. Tie the estimate to concrete findings, not general taste.
4. Present the user with three choices: restructure first, keep the current layout and document exceptions in the map, or decline the map for now.
5. If the user chooses restructure first, create or confirm a recent git commit, propose a focused restructuring plan, validate the project after the restructure, and only then enable the map.
6. If the user chooses preserve-as-is, enable the map and record the nonstandard layout explicitly in the relevant subsystem docs.
7. If the user declines, run `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked.

## Bundled Assets

- `assets/app-library-template/`: full app+library C++/Vulkan-first/CUDA-optional starter layout with CMake presets, CTest, sample C++ library/app, Vulkan default targets, explicit CUDA and combined CUDA+Vulkan build lanes, docs, clang tooling, and GitHub self-hosted GPU CI. Real CUDA/Vulkan external-memory or semaphore interop requires project-specific additions beyond the combined build preset.

## Bundled References

- `references/donor-library/`: curated donor-source library for Vulkan foundation tooling, glTF/runtime assets, WebGPU/WebGL, renderer backbones, path tracing, engine architecture, runtime mesh pipelines, graphics, rendering, geometry, 3D/physics/GPU simulation, AI runtimes, ML compilers, CUDA kernels, neural 3D, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, XR, and native engineering infrastructure. Donor backend signals describe the upstream implementation, not a restriction on target lanes. Start with `references/donor-library/README.md`; for VFX studio, games, or native infrastructure vocabulary use `references/donor-library/production/`; for broad or ambiguous donor requests use `references/donor-library/agent-lookup.md`, then load the smallest category set needed for the active task.
- `references/project-archetypes.md`: lane-selection guide for CUDA-only, Vulkan-only, CUDA+Vulkan interop, AI runtime, neural 3D, grooming, glTF/runtime assets, renderer backbone/runtime mesh pipeline, DCC, volume, animation, material, CAD, 3D/physics/GPU simulation, and XR projects.

## Bundled Scripts

- `scripts/scaffold_gpu_cpp_project.py`: create a new project from the template.
- `scripts/apply_studio_backbone.py`: copy backbone files into an existing repo without overwriting by default.
- `scripts/validate_studio_backbone.py`: check that required backbone files are present and, with `--integration`, that CMake/CTest register expected labeled tests.
- `scripts/check_dev_tools.sh`: verify compilers, CUDA, Vulkan, shader, and optional profiler tools.
- `scripts/select_idle_gpu.sh`: choose an idle NVIDIA GPU, optionally constrained by `GPU_ALLOWED_INDICES`, using utilization and display-server subtraction.
- `scripts/run_compute_sanitizer.sh`: run a command or GPU CTest preset under Compute Sanitizer.
- `scripts/run_vulkan_validation.sh`: run a Vulkan command or validation CTest preset with Khronos validation enabled.
- `scripts/dump_vulkan_capabilities.sh`: capture `vulkaninfo` summary and text reports for loader/ICD diagnostics.
- `scripts/run_nsys_smoke.sh`: run an app/probe under Nsight Systems and verify stats can read the report.
- `scripts/format_check.sh`: run clang-format in check-only mode.
- `scripts/tidy_check.sh`: run clang-tidy against a compile database in check-only mode.
- `scripts/bootstrap_code_map.py`: audit existing repo readiness, enable, or decline the opt-in CppStudio codebase map for a target repo.
- `scripts/validate_code_map.py`: validate enabled or declined CppStudio code-map state and manifest links.

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
