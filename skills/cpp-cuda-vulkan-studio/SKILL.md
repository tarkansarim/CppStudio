---
name: cpp-cuda-vulkan-studio
description: "Route native C++ GPU, Vulkan, CUDA, CMake, GUI, profiling, code-map, donor, planning, supervision, and viewport work to the smallest CppStudio module."
---

<!-- thin-relay:v1 -->
# CppStudio Router

Read `modules/studio-core.md` first. It selects one process state and the
smallest technical overlay set needed for the current work item.

- Default bounded work: `modules/process/standard.md`
- Unclear ownership, diagnosis, architecture, or evidence:
  `modules/process/investigative.md`
- Connected work items or nontrivial coordination:
  `modules/process/governed.md`
- Active false-proof, patch-stacking, or repeated-failure incident:
  `modules/process/recovery.md`
- Technical overlay selection: `modules/technical-overlays.md`
- Governed C++ GPU engineering intake for Planning Harness:
  `modules/cppstudio-project-planner/GUIDE.md`
- Supervised C++ GPU worker lanes:
  `modules/cppstudio-supervisor/GUIDE.md`
- Native editor, GUI, HUD, docking, gizmos, or plotting:
  `modules/native-cpp-gui-hud/GUIDE.md`
- App launch, control, readback, HTTP, CLI, or MCP surfaces:
  `modules/agentic-control-harness/GUIDE.md`
- Viewport gesture replay and visible interaction proof:
  `modules/viewport-session-testing/GUIDE.md`
- CMake, targets, presets, CTest, or build structure:
  `modules/modern-cpp-cmake/GUIDE.md`
- CUDA kernels and numerical GPU implementation:
  `modules/cuda-kernel-authoring/GUIDE.md`
- Vulkan compute/render synchronization:
  `modules/vulkan-compute-sync/GUIDE.md`
- Nsight, RenderDoc, perf, sanitizers, or hardware profiling:
  `modules/gpu-profiling-workstation/GUIDE.md`

Do not read every module by default. Use exactly one process state. Add only
technical overlays that match the current work. Recovery is an incident state,
not a permanent higher tier.
