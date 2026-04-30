# CUDA Lane To Vulkan Lane Gap Analysis

This file records gaps to consider later in plan mode. It is not an edit plan.

## Current CUDA-Oriented Surfaces And Vulkan Counterparts

| Current CUDA Surface | Vulkan Counterpart Needed |
| --- | --- |
| `PROJECT_ENABLE_CUDA` | Existing `PROJECT_ENABLE_VULKAN`, plus validation/shader/capture sub-options. |
| `PROJECT_CUDA_ARCHITECTURES` | Vulkan API version, required extensions, required features, queue requirements, and optional Vulkan Profile. |
| `cmake/CudaArchitectures.cmake` | A Vulkan CMake module for SDK/tool/component discovery and runtime probe wiring. |
| `find_package(CUDAToolkit REQUIRED)` | `find_package(Vulkan REQUIRED COMPONENTS glslc glslangValidator SPIRV-Tools dxc volk)` as appropriate. |
| `.cu` source compiled by CMake CUDA language | Shader sources compiled to SPIR-V build artifacts. |
| CUDA smoke kernel/test | Vulkan compute dispatch smoke plus optional offscreen render smoke. |
| `compute-sanitizer` script | Validation-layer, sync-validation, GPU-assisted validation, and shader printf scripts. |
| `cuda-debug` preset | `vulkan-debug`, `vulkan-validation`, `vulkan-sync-validation`, `vulkan-profile`, or similar presets. |
| `gpu;cuda` CTest labels | `gpu;vulkan;compute`, `gpu;vulkan;render`, `vulkan;shader`, `vulkan;validation`, `gui;vulkan`. |
| Nsight Systems smoke | Nsight Graphics/RenderDoc capture smoke plus continued Nsight Systems timing lane. |
| NVIDIA GPU selection via `nvidia-smi` | Vulkan physical-device selection/reporting; keep vendor-specific optimization explicit and lane-scoped. |

## Template Gaps Seen From Research

The current template has a Vulkan probe target and a `gpu;vulkan` test label, which is a useful
start. Research suggests the following unmatched surfaces:

- No Vulkan-specific CMake helper module parallel to CUDA architecture handling.
- No shader compilation custom command or shader validation target.
- No Vulkan debug/validation CMake preset.
- No Vulkan sync-validation or GPU-assisted validation script.
- No Vulkan capability dump/probe script.
- No explicit loader vs ICD vs SDK diagnostic taxonomy.
- No RenderDoc/Nsight Graphics capture workflow.
- No VMA-backed memory policy or documentation.
- No dynamic rendering example target.
- No Vulkan compute dispatch smoke analogous to CUDA vector add.
- No swapchain/WSI separation from offscreen/headless render tests.
- No Vulkan Profiles or feature-baseline policy.
- No `VK_EXT_debug_utils` object naming/labeling pattern in the template.

## Documentation Gaps

Existing template docs mention Vulkan SDK and shader tools, but the Vulkan lane would benefit from
dedicated sections for:

- Vulkan SDK setup vs driver/ICD setup.
- `vulkaninfo` diagnostics and expected failure classes.
- Shader build pipeline and artifact policy.
- Validation mode matrix.
- RenderDoc and Nsight Graphics capture workflow.
- Synchronization2 barrier checklist.
- Memory/VMA usage patterns.
- Swapchain resize/out-of-date behavior.
- Vulkan Profiles/capability baselines.

## Likely Skill Split

Research points to multiple layers of future skill content:

- Keep `cpp-cuda-vulkan-studio` as the infrastructure coordinator.
- Expand Vulkan parts of the template/backbone.
- Keep deep synchronization/debugging rules in `vulkan-compute-sync`.
- Potentially add a narrower Vulkan shader/toolchain skill only if shader workflows become large
  enough to justify it.
- Use environment-specific profiling guidance for RenderDoc/Nsight command details when available.

## Risk Notes For Later Planning

- Do not make Slang mandatory just because Khronos' tutorial now uses it; existing projects may be
  GLSL or HLSL.
- Do not make Vulkan 1.4 mandatory unless the generated project explicitly targets it.
- Do not hide missing ICDs behind a build-only success.
- Do not treat software Vulkan as equivalent to hardware GPU validation.
- Do not enable every validation feature at once by default.
- Do not add RenderDoc/Nsight capture requirements to normal quick tests.
- Do not put project-specific renderer policy into the reusable global skill.
