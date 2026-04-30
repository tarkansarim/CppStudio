# Testing, CI, And Portability Research

## Test Lane Separation

Vulkan tests should be label-separated because different checks need different machine capabilities.

Candidate CTest labels:

- `quick`: CPU-only or build-output checks.
- `shader`: shader compilation and SPIR-V validation.
- `vulkan`: requires Vulkan loader and at least one ICD.
- `gpu`: requires real GPU execution.
- `compute`: Vulkan compute dispatch tests.
- `render`: offscreen render tests.
- `gui`: WSI/swapchain/window tests.
- `validation`: validation-layer run.
- `sync-validation`: synchronization validation run.
- `capture`: RenderDoc/Nsight capture-assisted run.
- `profile`: profiling smoke or benchmark lane.
- `nightly`: longer or hardware-sensitive coverage.

This is parallel to the current CUDA/GPU labels but separates Vulkan-specific runtime surfaces.

## CI Capability Classes

Research suggests four useful CI classes:

1. Build-only Vulkan lane:
   - Requires compiler, CMake, Vulkan headers, and maybe shader compiler tools.
   - Does not require a working ICD.
   - Should not claim GPU runtime correctness.

2. Shader lane:
   - Compiles all shaders.
   - Runs `spirv-val`.
   - Optionally runs reflection checks.
   - Does not require a GPU.

3. Loader/runtime probe lane:
   - Runs `vulkaninfo` or a minimal instance/device/queue probe.
   - Records selected physical device, driver, API version, queue families, and required features.
   - Fails clearly when SDK exists but no ICD is visible.

4. Hardware execution lane:
   - Runs compute/render tests on a real Vulkan device.
   - Runs validation on small representative workloads.
   - Optionally performs capture/profiling smoke tests on self-hosted machines.

Software or CPU Vulkan implementations can be useful for narrow portability checks, but they should
not be labeled as equivalent to hardware GPU validation.

## Capability Dumps

A Vulkan backbone should capture enough startup data to make bug reports useful:

- Vulkan API version requested and selected.
- Instance extensions enabled.
- Device extensions enabled.
- Physical device name, vendor ID, device ID, driver version, and device type.
- Queue family properties and chosen queue families.
- Enabled features, especially Vulkan 1.2/1.3 feature structs.
- Swapchain surface formats/present modes when WSI is used.
- Memory heaps and budget when memory behavior is relevant.

This information can be emitted by a small project probe executable or a generated helper.

## Vulkan Profiles

Vulkan Profiles define capability baselines: features, extensions, limits, formats, and related
properties. Khronos' docs describe profile support checks and device creation configuration through
the profiles library.

Research implications:

- Profiles can reduce repetitive feature/extension enabling boilerplate.
- Profiles are useful for communicating a supported hardware baseline.
- A generated project can still expose manual feature checks when a profile is not appropriate.
- Future planning should decide whether the studio backbone ships a profile example, a capability
  dump, or both.

## Portability And MoltenVK

Vulkan portability paths such as MoltenVK are not identical to native desktop Vulkan:

- Non-conformant portability implementations may require
  `VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`.
- `VK_KHR_portability_subset` must be queried and handled deliberately.
- MoltenVK should be a named portability lane, not silently treated as normal native Vulkan.

This is mostly a future-proofing concern for a reusable skill. The current workstation appears
Linux-focused, so native Linux ICD behavior should remain the first target unless the user asks for
macOS/iOS portability.

## Offscreen, GUI, And Capture

Vulkan render tests should distinguish:

- Compute-only dispatch with readback.
- Offscreen image render with readback.
- Swapchain/presentation render.
- GUI/windowed render.
- Frame capture/debugger-assisted render.

This separation avoids false confidence. A compute readback test can prove queue, descriptor, shader,
barrier, and memory basics without proving swapchain handling. A swapchain smoke test can prove WSI
without proving image contents. A capture can prove event/resource state but may not be practical in
all CI environments.

## Failure Reporting

Vulkan failures should report the failing layer:

- Missing SDK/tool.
- Missing loader.
- Missing ICD.
- No physical devices.
- Required queue family unavailable.
- Required instance/device extension unavailable.
- Required feature unavailable.
- Shader compiler missing.
- SPIR-V validation failed.
- Validation layer unavailable.
- Validation error during execution.
- Swapchain/surface unsupported.
- Render output mismatch.

This error taxonomy should prevent "Vulkan failed" from becoming an unhelpful catch-all.

