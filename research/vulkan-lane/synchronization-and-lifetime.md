# Synchronization And Lifetime Research

## Core Mental Model

Vulkan separates several concerns that are easy to conflate:

- CPU thread synchronization.
- Host waiting for GPU work.
- Queue-to-queue GPU ordering.
- GPU memory availability and visibility.
- Image layout state.
- Queue-family ownership.
- Descriptor and resource lifetime across frames in flight.

The Vulkan lane should force these distinctions in checklists and templates. A fence is not a
pipeline barrier, a semaphore is not a CPU mutex, and an image layout transition is not automatically
a complete memory dependency unless the barrier is correct.

## Queues

Khronos' queue guidance highlights several constraints that should become skill rules:

- Command buffers submitted to the same queue start in order but may proceed independently after
  that.
- Work submitted to different queues is unordered unless synchronized with a semaphore.
- Only one thread may submit to a given `VkQueue` at a time.
- Different queues may be submitted from different threads when the application owns the scheduling
  policy.
- Hardware mapping of `VkQueue` objects is implementation-defined.

Implication for reusable infrastructure:

- Serialize per-queue submission unless the repo has an explicit submission scheduler.
- Report queue family selection and queue ownership in startup diagnostics.
- Keep transfer/compute/graphics queue use deliberate; do not split queues simply because the API
  exposes them.

## Synchronization2 Default

`VK_KHR_synchronization2` is promoted to Vulkan 1.3 and improves the clarity of barriers and queue
submission. For new Vulkan code, the research supports making sync2 the preferred default.

Barrier design checklist:

1. Identify the producer operation.
2. Identify the consumer operation.
3. Pick exact source stage and access.
4. Pick exact destination stage and access.
5. Pick the exact buffer range or image subresource range.
6. Include an image layout transition only when layout changes.
7. Include queue-family ownership transfer only when ownership changes.
8. Keep the barrier narrow unless diagnosing a bug.

Common dependencies worth codifying:

- Compute shader write to compute shader read.
- Compute shader write to transfer read.
- Transfer write to shader read.
- Color/depth attachment write to shader sample.
- Offscreen render target to swapchain composite.
- Render output to present.
- Host write to shader read, including non-coherent flush.
- Device write to host read, including barrier, fence wait, and non-coherent invalidate.

## Timeline Semaphores

Khronos samples frame timeline semaphores as a better fit for advanced multi-queue and
producer/consumer cases than a pile of binary semaphores. Research implication:

- Binary semaphores remain necessary for swapchain acquire/present paths.
- Timeline semaphores are a strong default for upload queues, async compute, staged resource
  streaming, and reusable GPU completion counters.
- A future skill should distinguish frame fences, binary WSI semaphores, and timeline semaphores by
  use case.

## Dynamic Rendering

Dynamic rendering is promoted to Vulkan 1.3 and avoids creating render pass and framebuffer objects
for many single-pass workflows. Research implication:

- New graphics scaffolds should prefer dynamic rendering unless a target project needs traditional
  render passes for compatibility or subpass-specific behavior.
- Pipeline creation must still specify attachment formats through pipeline rendering create info.
- Command recording still needs correct image layouts, load/store ops, and synchronization.

## Descriptor Lifetime

Descriptor set layouts define the shader/API contract. Pipeline layouts combine descriptor set
layouts and push constant ranges. Later work should enforce:

- Shader `(set, binding)` declarations match host descriptor set layouts.
- Pipeline layouts match statically used shader resources.
- Descriptor writes outlive all in-flight command buffers that use them.
- Per-frame descriptor pools/sets are not recycled until the protecting fence signals.
- Update-after-bind and partially-bound behavior are opt-in features with matching layout and pool
  flags, not accidental behavior.
- Reflection can help detect mismatches, but host code remains responsible for the actual contract.

## Memory And Mapping

The Vulkan memory spec and VMA docs point to a standard layered approach:

- Use raw Vulkan memory rules as the correctness base.
- Prefer VMA for routine image/buffer allocation and memory type selection.
- Use GPU-only memory for render targets, storage images, storage buffers, and hot GPU resources.
- Use staging buffers for CPU-to-GPU transfers when direct host-visible memory is not the right
  performance choice.
- Use readback buffers for GPU-to-CPU verification paths.
- Track memory budgets with `VK_EXT_memory_budget`/VMA budget APIs.
- Use VMA statistics and JSON dumps for diagnostics, not every-frame hot paths.

Non-coherent memory rules to keep explicit:

- Host writes require flush before GPU reads.
- Device writes require a device-to-host dependency, host wait, and invalidate before host reads.
- Ranges must respect `nonCoherentAtomSize` alignment rules.
- Mapping/unmapping is not a substitute for synchronization.

## Swapchain And Presentation

A Vulkan graphics lane needs swapchain-specific handling that CUDA does not:

- Surface and swapchain support are not part of core compute-only Vulkan.
- Swapchain images must be acquired, rendered or copied into, transitioned for presentation, and
  presented.
- `VK_ERROR_OUT_OF_DATE_KHR` and `VK_SUBOPTIMAL_KHR` paths must recreate dependent resources without
  leaking old image views, framebuffers, pipelines, or per-frame objects.
- Presentation support is queue-family and surface dependent.
- Headless/offscreen tests should be named separately from WSI presentation tests.

## Resource Lifetime Rule

The reusable rule should be simple:

Any Vulkan resource referenced by pending command buffers must outlive the fence or timeline value
that proves its final use completed.

That includes:

- Buffers and images.
- VMA allocations.
- Descriptor sets and pools.
- Command buffers and command pools.
- Shader modules or shader objects when still referenced by creation or recording paths.
- Pipelines and pipeline layouts.
- Render targets and swapchain-dependent resources.
- Staging and readback resources.

