# vk-bootstrap Donor Profile

Source: https://github.com/charles-lunarg/vk-bootstrap  
Tier: `safe-donor`  
Backend signal: native-vulkan
License signal: MIT; inspect `LICENSE.txt`, examples, docs, and tests at the exact revision used.

## Use First For

- Vulkan instance, physical-device, logical-device, queue, surface, and swapchain bootstrap decisions.
- Reducing repetitive setup code while keeping requested extensions, features, and queues explicit.
- Understanding bootstrap failure diagnostics for device and swapchain selection.

## First Upstream Areas To Inspect

- `src/` and public headers for builder APIs and ownership.
- `example/` for instance/device/swapchain construction flow.
- `docs/` and tests for feature/extension selection behavior.

## Integration Notes

- Keep required and optional features/extensions visible in target-project configuration.
- Keep bootstrap helpers out of core renderer abstractions unless the target repo accepts the dependency.
- Validate swapchain recreation, headless/offscreen modes, and portability enumeration separately.

## Validation Ideas

- Run instance/device selection with validation layers enabled.
- Test missing-extension and unsuitable-device failure messages.
- Verify queue family, surface format, present mode, and swapchain extent decisions with small fixtures.

## Caveats

- Bootstrap helpers do not replace renderer synchronization, descriptor, memory, or frame-graph policy.
- Window-system and surface assumptions still need platform-specific validation.
