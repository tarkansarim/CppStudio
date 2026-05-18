---
name: vulkan-compute-sync
description: "Vulkan compute and render synchronization guidance for C++ engines: SPIR-V shader compilation, compute pipeline setup, descriptor sets, push constants, specialization constants, vkCmdDispatch, synchronization2 barriers, image layout transitions, frames in flight, command pools, queue ownership, swapchain acquire/present, validation layers, RenderDoc, and Nsight Graphics. Use when implementing or debugging Vulkan compute shaders, barriers, resource lifetime, or GPU/CPU coordination."
---

# Vulkan Compute Sync

Use this skill for Vulkan compute or render synchronization work. Prefer the repository's existing Vulkan wrapper and naming first. Apply these rules when the code lacks a clear local convention or when validation, frame capture, or synchronization bugs are being investigated.

## First Principles

- CPU thread synchronization, CPU/GPU synchronization, GPU/GPU queue synchronization, and GPU memory visibility are different problems.
- Use CPU primitives for CPU threads.
- Use fences for CPU waiting on GPU completion.
- Use semaphores for GPU queue ordering and swapchain acquire/present.
- Use pipeline barriers for memory dependencies and image layout transitions.
- Prefer Vulkan 1.3 `VK_KHR_synchronization2` APIs in new code unless the repo intentionally uses legacy barriers.
- Keep validation layers enabled during development and treat validation errors as bugs until proven otherwise.

## Gather Inputs First

Before changing synchronization or compute pipeline code, identify:

- Vulkan API version and enabled extensions.
- Whether synchronization2, dynamic rendering, descriptor indexing, timeline semaphores, or ray tracing extensions are enabled.
- Queue families used for graphics, compute, transfer, and present.
- Resource owners and lifetimes: buffers, images, descriptor sets, command pools, command buffers, fences, semaphores, and per-frame data.
- Whether resources are host-visible, device-local, persistently mapped, staging-only, or shared across queues.
- Exact producer and consumer for every synchronized resource.
- Existing validation-layer output and the frame/debug capture command available on this workstation.

## Donor References

For broad Vulkan, renderer, WebGPU, XR, 3D graphics, asset, volume, VFX, simulation, or native UI
context, use the CppStudio donor library after this skill fires. Default installed path:

`${CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio/references/donor-library`

Start with:

- `selection-policy.md`
- `agent-lookup.md` when Vulkan is mixed with broad 3D, renderer, simulation, asset-pipeline,
  volume, neural, or XR wording
- `vulkan-foundation-tooling.md` for memory allocation, loader/bootstrap, shader reflection,
  SPIR-V validation, and shader compilation/cross-compilation
- `graphics-rendering.md` plus the relevant renderer profile
- `native-gui-hud.md` when Vulkan work includes native GUI/HUD/editor UI integration

Use Khronos samples as the first portable correctness reference, then vendor samples for
vendor-specific extensions or tools. Keep study-only and non-commercial references out of reusable
Vulkan code.

## Compute Pipeline Checklist

For compute shader work:

- Compile GLSL/HLSL to SPIR-V with the repo's existing compiler path. If none exists, prefer `glslc` or `glslangValidator`, then validate with `spirv-val`.
- Keep shader descriptor set and binding declarations in sync with host `VkDescriptorSetLayoutBinding` setup.
- Use push constants only for small per-dispatch values; respect device push-constant limits.
- Use specialization constants for compile-time workgroup tunables.
- Compute dispatch dimensions with ceiling division and guard out-of-range invocations in the shader.
- Bind pipeline, descriptor sets, and push constants before dispatch.
- Insert a precise barrier when shader writes are consumed by another shader, transfer, vertex/index input, acceleration-structure build, host readback, or presentation path.

## Synchronization2 Barrier Pattern

For new code, express dependencies with `VkMemoryBarrier2`, `VkBufferMemoryBarrier2`, or `VkImageMemoryBarrier2` inside `VkDependencyInfo`.

Barrier design steps:

1. Name the producer stage and access mask.
2. Name the consumer stage and access mask.
3. Select the exact buffer range or image subresource range.
4. Include queue-family ownership transfer only when ownership actually changes.
5. Include old and new image layouts only for image layout transitions.
6. Keep barriers as narrow as the resource dependency allows.

Common dependencies:

- Compute shader write to compute shader read: shader storage write to shader storage read.
- Compute shader write to transfer read: shader storage write to transfer read.
- Transfer write to shader read: transfer write to shader sampled read or storage read.
- Host write to shader read: host write to shader read, with mapped-memory flush when memory is not host coherent.
- Color attachment write to present: color attachment output write to present layout transition.

Avoid broad `ALL_COMMANDS` or full-resource barriers unless diagnosing an issue or matching an established conservative project pattern.

## Frames In Flight

- Allocate per-frame copies of dynamic CPU-to-GPU data that can be overwritten while earlier frames are still executing.
- Wait on a frame fence before reusing that frame's command buffers, descriptor pools, staging allocations, or dynamic buffers.
- Reset fences only after a successful wait and before the submit that will signal them.
- Keep acquire, render/compute submit, and present semaphores tied to the frame or swapchain-image policy used by the repo.
- Handle swapchain resize and `VK_ERROR_OUT_OF_DATE_KHR`/`VK_SUBOPTIMAL_KHR` without leaking per-frame resources.

## Command Pools And Threads

- `VkCommandPool` is externally synchronized. Do not allocate or reset command buffers from the same pool concurrently.
- Use one command pool per recording thread per frame when recording in parallel.
- Record secondary command buffers in parallel only when the render pass or dynamic-rendering inheritance rules are correct.
- Serialize queue submission unless the project has a deliberate submission scheduler.
- Do not use Vulkan semaphores or fences as CPU thread barriers.

## Descriptor And Resource Lifetime

- Descriptor writes must outlive command buffer execution that reads them.
- Do not recycle descriptor sets, staging buffers, or scratch buffers until the fence protecting their last use has signaled.
- For persistently mapped memory, flush non-coherent host writes before GPU reads and invalidate non-coherent memory before host reads.
- Track acceleration-structure scratch, instance, and geometry buffers with the same fence discipline as other GPU resources.
- For bindless or descriptor indexing paths, verify update-after-bind flags and pool/layout flags match the intended use.

## Image Layout Rules

- Treat layout as part of the image state contract.
- Transition swapchain images to the rendering layout before drawing and to present layout before present.
- Transition storage images to `GENERAL` for compute writes unless a more specific layout is valid.
- Transition sampled images to shader-read layouts before sampling.
- Match aspect masks, mip levels, array layers, and queue-family ownership to the actual image use.

## Debug Workflow

1. Capture validation-layer output first.
2. Reproduce with the smallest frame, dispatch, or resource set that still fails.
3. Name the exact producer and consumer for the suspect resource.
4. Add or narrow one barrier at a time.
5. Use `gpu-profiling-workstation` for local Nsight Graphics or RenderDoc capture commands when frame contents or RT/Vulkan event order must be inspected.
6. Use `nsys` only when the question is whole-frame timing or CPU/GPU overlap.
7. Remove diagnostic over-barriers once the minimal dependency is understood.

## Review Checklist

Before claiming a Vulkan compute or synchronization change is ready:

- Validation layers are clean for the exercised path, or remaining messages are explicitly explained.
- Every barrier has a named producer, consumer, stage mask, access mask, and resource range.
- Per-frame resources are not reused before their fence signals.
- Command pools are not shared unsafely across recording threads.
- Descriptor lifetimes cover all in-flight command buffers that reference them.
- Swapchain out-of-date and resize paths still release and recreate dependent resources safely.
- Frame capture or screenshot evidence exists when the change affects visible rendering.
