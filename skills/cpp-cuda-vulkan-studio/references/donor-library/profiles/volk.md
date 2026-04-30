# volk Donor Profile

Source: https://github.com/zeux/volk  
Tier: `safe-donor`  
Backend signal: native-vulkan
License signal: MIT; inspect `LICENSE.md`, generated loader code, and package metadata at the exact
revision used.

## Use First For

- Vulkan function loading, instance/device dispatch, and extension entrypoint loading.
- Simplifying loader setup in projects that avoid a heavier framework.
- Understanding where global, instance, and device-level Vulkan commands become available.

## First Upstream Areas To Inspect

- `volk.h` and `volk.c` for API surface and initialization order.
- CMake/package integration examples.
- Tests and generator scripts before modifying generated loader behavior.

## Integration Notes

- Call loader initialization before creating Vulkan instances, then load instance/device function
  pointers at the matching lifetime boundary.
- Keep loader setup separate from swapchain, allocator, and renderer bootstrap policy.
- Avoid mixing multiple Vulkan loader helpers unless initialization ownership is explicit.

## Validation Ideas

- Run a loader-only smoke test that creates an instance and resolves a device extension function.
- Test behavior when the Vulkan loader or required extension is missing.
- Keep `vulkaninfo` or capability dumps separate from loader-code failures.

## Caveats

- volk does not choose physical devices, extensions, queues, surfaces, or swapchains.
- Generated loader files should be updated intentionally when Vulkan headers change.
