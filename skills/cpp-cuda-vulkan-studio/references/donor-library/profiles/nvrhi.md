# NVIDIA NVRHI Donor Profile

Source: https://github.com/NVIDIA-RTX/NVRHI  
Tier: `safe-donor`  
Backend signal: mixed-backend
License signal: MIT; inspect `LICENSE.txt`, `ThirdPartyLicenses.txt`, submodules, and optional SDK
integrations such as RTXMU/NVAPI at the exact revision used.

## Use First For

- Cross-API renderer hardware-interface patterns over Vulkan, Direct3D 11, and Direct3D 12.
- Resource state tracking, barrier placement, deferred destruction, and descriptor/resource binding.
- Ray tracing pipeline and acceleration-structure abstraction boundaries.
- Keeping low-level API access possible while still centralizing resource lifetime and validation.

## First Upstream Areas To Inspect

- `include/nvrhi/` for API shape, resource descriptions, binding sets, and command lists.
- `src/vulkan/` for Vulkan implementation details, especially ray tracing and barriers.
- `doc/ProgrammingGuide.md` for intended usage and lifetime model.
- `ThirdPartyLicenses.txt` and submodules before copying build or integration policy.

## Integration Notes

- Use NVRHI as an architecture donor or dependency candidate for larger renderers, not as a mandatory
  CppStudio template dependency.
- If a project remains direct-Vulkan, borrow the state/lifetime model without adding the abstraction.
- Keep NVRHI-owned state transitions separate from manual Vulkan barriers; mixing the two without a
  boundary creates validation and lifetime ambiguity.
- Treat optional NVAPI and RTXMU support as separate dependency decisions.

## Validation Ideas

- Add resource-lifetime tests around deferred destruction, resize, swapchain recreation, and command-list
  reuse.
- Capture Vulkan validation output before and after introducing an abstraction layer.
- Label NVRHI abstraction tests separately from direct Vulkan tests.
- Stress descriptor rebinding, transient uploads, and multi-frame resource retirement.

## Caveats

- NVRHI can dominate renderer architecture; small Vulkan apps may be better served by direct Vulkan plus
  focused helpers.
- Optional NVIDIA SDK integrations have separate licenses and platform requirements.
