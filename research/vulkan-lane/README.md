# Vulkan Lane Research

Generated: 2026-04-29

This folder is a research staging area for bringing the Vulkan side of the reusable C++/CUDA/Vulkan
studio backbone up to the same practical depth as the CUDA lane. It is intentionally not a skill
update plan and does not edit `skills/cpp-cuda-vulkan-studio/`.

## Scope

The research focuses on source-backed Vulkan development infrastructure:

- SDK, loader, ICD, and CMake discovery.
- Shader language and SPIR-V toolchain choices.
- Validation layers, debug utils, frame capture, and profiling.
- Synchronization, resource lifetime, descriptor lifetime, memory allocation, and swapchain rules.
- Test, CI, portability, and capability-targeting lanes.
- Gaps between the current CUDA-oriented infrastructure and a Vulkan-first workflow.

Primary sources are preferred: Khronos Vulkan documentation, Vulkan SDK documentation, CMake
documentation, Khronos GitHub projects, and vendor/tool documentation.

## Files

- [source-map.md](source-map.md): source inventory with the key signal from each source.
- [lane-findings.md](lane-findings.md): cross-cutting conclusions for a Vulkan-first backbone.
- [build-and-shaders.md](build-and-shaders.md): SDK, CMake, shader compilation, and SPIR-V tooling.
- [synchronization-and-lifetime.md](synchronization-and-lifetime.md): queues, sync2, frames in flight,
  descriptors, memory, and swapchain constraints.
- [validation-debugging-profiling.md](validation-debugging-profiling.md): validation, debug markers,
  RenderDoc, Nsight Graphics, and evidence expectations.
- [testing-ci-portability.md](testing-ci-portability.md): test labels, CI lanes, ICD handling, Vulkan
  Profiles, and portability concerns.
- [cuda-lane-gap-analysis.md](cuda-lane-gap-analysis.md): concrete differences to consider later when
  planning skill and template updates.

## Key Takeaways

1. Vulkan should not simply mirror CUDA. CUDA infrastructure centers on kernels, architectures,
   launch wrappers, and compute sanitizers. Vulkan infrastructure needs explicit runtime state,
   feature negotiation, shader artifacts, queue and memory synchronization, frame capture, and
   render/compute validation.
2. Modern Vulkan references now emphasize Vulkan 1.3/1.4-era workflows: synchronization2, timeline
   semaphores, dynamic rendering, validation layers, and richer shader toolchains.
3. The Vulkan SDK does not install a GPU driver. A real Vulkan lane must distinguish SDK/tool
   presence from ICD/driver availability.
4. CMake's `FindVulkan` has enough imported targets to make shader compilers, SPIR-V tools, DXC,
   MoltenVK, and Volk deliberate dependencies instead of ad hoc executable searches.
5. Validation needs first-class modes. Core validation, synchronization validation, GPU-assisted
   validation, best-practices validation, and shader printf are not equivalent and should be run
   with clear intent.
6. Debug evidence is different from CUDA. RenderDoc/Nsight frame captures, debug object names,
   queue/event timelines, validation logs, and reproducible screenshots matter as much as test exit
   codes for render paths.
7. VMA and memory budgets are central enough to be treated as a standard Vulkan infrastructure topic,
   not an optional future add-on.

No placeholders or simplifications.
