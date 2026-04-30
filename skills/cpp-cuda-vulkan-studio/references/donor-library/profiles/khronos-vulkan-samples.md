# Khronos Vulkan-Samples Donor Profile

Source: https://github.com/KhronosGroup/Vulkan-Samples  
Tier: `safe-donor`  
License signal: Apache-2.0 for code; inspect `LICENSE`, `third_party/`, submodules, and asset licenses
at the exact revision used.

## Use First For

- Vulkan API correctness, best practices, and validation-friendly examples.
- Dynamic rendering, synchronization, swapchain, headless/offscreen, compute, and performance sample
  patterns.
- Tutorials that explain Vulkan decisions with profiling or performance context.
- Cross-checking vendor-specific Vulkan samples against Khronos guidance.

## First Upstream Areas To Inspect

- `samples/` for focused Vulkan features.
- `framework/` for reusable setup and resource handling patterns.
- `docs/` and docs.vulkan.org sample pages for explanations.
- `shaders/` for shader compilation and layout conventions.
- `third_party/` and asset submodules before copying or vendoring anything.

## Integration Notes

- Start here before vendor samples when the question is Vulkan correctness or portable best practice.
- Copy concepts and small patterns, not the whole framework, unless the target repo accepts that
  dependency shape.
- Keep Vulkan SDK, driver/ICD, validation layer, and physical-device failures classified separately.
- For CI, prefer headless/offscreen sample ideas over foreground window requirements.

## Validation Ideas

- Run with validation layers enabled.
- Use `vulkaninfo` or project capability dumps before changing code for runtime failures.
- Capture with RenderDoc or Nsight Graphics after validation messages are clean or classified.
- Add CTest labels for shader, compute, render, validation, and GUI/headless lanes.

## Caveats

- The repository uses submodules and assets with their own license surfaces.
- Some samples require newer Vulkan versions or extensions.
- Performance samples are educational references; do not turn their timings into target-project
  thresholds without local baselines.
