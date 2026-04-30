# Vulkan Memory Allocator Donor Profile

Source: https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator  
Tier: `safe-donor`  
Backend signal: native-vulkan
License signal: MIT; inspect `LICENSE.txt`, docs, examples, and optional bindings at the exact
revision used.

## Use First For

- Vulkan memory allocation policy, suballocation, budget tracking, pools, mapping, and dedicated allocations.
- Handling buffer/image allocation metadata without turning allocation policy into ad hoc project code.
- Designing tests around allocation lifetime, persistent mapping, and memory-budget behavior.

## First Upstream Areas To Inspect

- Main VMA header/source for allocation APIs and object ownership.
- Documentation chapters for choosing memory types, mapping, pools, and budget tracking.
- Samples and tests for allocator initialization, allocation flags, and Vulkan object lifetime.
- Optional bindings only after the target repo accepts their language and dependency shape.

## Integration Notes

- Keep allocator lifetime tied to Vulkan instance/device/physical-device ownership.
- Keep allocation, staging, upload, and destruction order visible in tests and debug names.
- Do not mix custom suballocators with VMA unless the boundary and ownership model are explicit.
- Prefer package integration or a narrow vendored header review over copying unrelated examples.

## Validation Ideas

- Allocate tiny buffer/image fixtures and verify destruction order under validation layers.
- Exercise mapped, unmapped, staging, and device-local allocation paths.
- Record budget queries on devices that expose the required memory budget extension.
- Add leak/lifetime checks around swapchain recreation and device shutdown.

## Caveats

- Memory-budget behavior is device/driver dependent.
- Example projects and bindings are separate license and dependency surfaces.
- VMA solves allocation mechanics, not higher-level resource lifetime or frame-in-flight policy.
