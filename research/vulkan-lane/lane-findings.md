# Vulkan Lane Findings

## Vulkan Is A State And Evidence Lane

CUDA infrastructure can focus heavily on kernels, launch wrappers, device architecture selection,
numerical tests, and tools like Compute Sanitizer. Vulkan has compute, but its day-to-day failure
modes are broader:

- The loader, SDK, ICD, layers, and application are separate moving parts.
- Device feature and extension negotiation is part of app startup correctness.
- Shaders become build artifacts and must match pipeline layouts and descriptor layouts.
- Queues, command buffers, image layouts, descriptors, memory visibility, and swapchain state form a
  runtime object graph.
- Render correctness often needs visual or capture evidence, not only pass/fail unit tests.

The Vulkan lane should therefore emphasize reproducibility and evidence:

- `vulkaninfo` or equivalent capability capture.
- Validation layer logs.
- Debug object names and command labels.
- Shader compile and SPIR-V validation logs.
- RenderDoc or Nsight captures for visible render paths.
- CTest labels that separate build-only, loader, shader, compute, render, GUI, validation, and
  profiling work.

## Modern Baseline Signals

The Khronos tutorial currently teaches Vulkan with a modern stack: Vulkan 1.4, dynamic rendering,
timeline semaphores, Slang, C++20, and Vulkan-Hpp RAII. Khronos samples and guide pages also put
`VK_KHR_synchronization2` and dynamic rendering front and center, both promoted to Vulkan 1.3.

This does not automatically mean every generated project must require Vulkan 1.4. It does mean the
skill should avoid old defaults unless a target repo already chose them:

- Prefer synchronization2 APIs for new helper code and checklists.
- Prefer dynamic rendering for new graphics scaffolds unless render pass compatibility is required.
- Treat timeline semaphores as the default advanced queue coordination primitive.
- Make the target API version and required features explicit in generated docs/presets.
- Keep profile/extension capability checks visible instead of burying them in ad hoc startup code.

## SDK Presence Is Not Driver Availability

LunarG's SDK documentation is explicit that the SDK provides development tools and libraries, not a
Vulkan driver. A reliable Vulkan lane must test these separately:

- SDK/tool presence: headers, loader library, validation layer manifests, shader compilers,
  SPIR-V tools, Vulkan Configurator, GFXReconstruct, Volk, and VMA.
- Runtime driver presence: ICD manifests, physical devices, queue families, API version, and
  feature/extension support.
- Capture/profiling presence: RenderDoc, Nsight Graphics, Nsight Systems, or vendor equivalents.

This matters for CI because a machine can compile Vulkan code and shaders while still having no
usable ICD. That should be reported as a lane distinction, not hidden as a generic "Vulkan failed".

## Vulkan Needs Feature Policy, Not Architecture Policy

The CUDA lane has `PROJECT_CUDA_ARCHITECTURES` and GPU architecture resolution. Vulkan needs a
different policy layer:

- Target Vulkan API version.
- Required instance extensions.
- Required device extensions.
- Required device features and feature-structure chains.
- Queue family requirements.
- Swapchain and presentation requirements when GUI/rendering is enabled.
- Optional profile target, such as a Vulkan Profile or project-specific capability baseline.
- Portability policy for MoltenVK or `VK_KHR_portability_subset`.

The equivalent of "what SMs do we build for" is "what feature/profile contract do we require, and
how do we prove the selected physical device satisfies it".

## Shaders Are Build Products

The current template has a shader file, but a mature Vulkan lane should treat shaders like source
with a real build pipeline:

- Choose language: Slang, GLSL, HLSL via DXC, or project-specific.
- Compile to SPIR-V with dependency-aware build rules.
- Validate SPIR-V with `spirv-val`.
- Optionally optimize or normalize with `spirv-opt`.
- Optionally reflect with SPIRV-Reflect or SPIRV-Cross to verify descriptor/push-constant contracts.
- Decide whether SPIR-V is embedded, installed, copied beside binaries, or loaded from assets.

Khronos' current tutorial shift toward Slang is important, especially because Slang can target
Vulkan/SPIR-V and CUDA. That may become useful for a shared GPU studio story, but it should remain a
deliberate choice instead of displacing established GLSL/HLSL workflows without review.

## Validation Modes Should Be Separate Lanes

The validation layer ecosystem is broad enough that a single "validation on" switch is not enough:

- Core validation catches many specification/API usage errors.
- Synchronization validation targets resource access hazards.
- GPU-assisted validation instruments shaders for runtime checks.
- Shader printf is a targeted shader debugging mode.
- Best-practices validation reports warnings that are not necessarily spec violations.

Some modes carry substantial overhead and some do not combine cleanly. A skill should therefore
recommend named validation presets or scripts instead of asking users to turn on every check all the
time.

## Debug Markers Are Infrastructure

`VK_EXT_debug_utils` is not decoration. It is the difference between usable and opaque validation,
RenderDoc, and Nsight sessions. A Vulkan-ready template should consider:

- Object naming wrappers for important handles.
- Scoped command-buffer labels.
- Queue labels around major submits.
- Build-mode guards so labels are cheap and consistent.
- Naming conventions for images, buffers, pipelines, descriptor sets, and per-frame resources.

## Memory Needs A Standard Story

The Vulkan spec exposes memory types, heaps, mapping, flush/invalidate rules, and resource binding at
a lower level than most applications want to hand-roll repeatedly. VMA is established enough to be
the default research target for project infrastructure:

- GPU-only resources.
- Staging upload buffers.
- Readback buffers.
- Persistently mapped CPU-to-GPU buffers.
- Memory budget tracking.
- Debug statistics and JSON dumps.
- Defragmentation only when the resource system can move and rebind resources safely.

The skill should still understand raw Vulkan memory rules because VMA does not remove synchronization
or lifetime responsibilities.

## Profiling And Debugging Tool Split

The Vulkan lane needs a tool decision table:

- Validation layers first for API correctness.
- RenderDoc for frame inspection, resources, pipeline state, and event analysis.
- Nsight Graphics Frame Debugger for NVIDIA frame inspection, shader performance, GPU pipeline state,
  pixel history, and Vulkan-specific views.
- Nsight Graphics GPU Trace for frame-level GPU profiling and queue/event timing.
- Nsight Systems for whole-system CPU/GPU overlap and scheduling questions.
- Vendor performance guides only after correctness and capture evidence exist.

The research does not recommend replacing existing `run_nsys_smoke.sh`; it suggests adding a
Vulkan-specific graphics/debug counterpart later.
