# nvpro vk_denoise_dlssrr Donor Profile

Source: https://github.com/nvpro-samples/vk_denoise_dlssrr  
Tier: `dependency-candidate`  
Backend signal: native-vulkan
License signal: Apache-2.0 sample license, with NVIDIA DLSS/NGX SDK dependency and release-package terms;
inspect `LICENSE`, CMake download logic, media, and DLSS SDK terms at the exact revision used.

## Use First For

- Compact Vulkan DLSS Ray Reconstruction integration.
- NGX context setup, DLSS-RR wrapper shape, feature availability, and evaluation flow.
- Guide-buffer definitions for color, albedo, normal/roughness, motion vectors, depth, and specular hit
  distance.
- Debug views that show input buffers and output-resolution behavior.

## First Upstream Areas To Inspect

- `README.md` for integration contract, guide buffers, matrix/depth conventions, and sample limitations.
- `dlss_rr/src/dlssrr_sample.cpp` for app-side orchestration.
- `dlss_rr/src/dlssrr_wrapper.cpp` and `.hpp` for compact Vulkan wrapper patterns.
- `dlss_rr/shaders/` for path-tracing and guide-buffer production examples.
- CMake NGX/DLSS package wiring before adopting dependency policy.

## Integration Notes

- Use this when direct DLSS-RR integration is more appropriate than a broader Streamline path.
- Preserve raw RT output as a comparison lane so DLSS-RR input mistakes can be isolated.
- Record depth, matrix, motion-vector, jitter, render-resolution, and output-resolution conventions in the
  target project.
- Keep SDK binaries out of reusable templates; install/download them only when the target project accepts
  the dependency.

## Validation Ideas

- Add debug buffer screenshots for every DLSS-RR input resource.
- Test sky motion vectors, mirror-like surface handling, missing optional guide buffers, and matrix layout.
- Verify startup-only and short interactive smoke runs with DLSS disabled and enabled separately.
- Log exact quality, preset, input extent, output extent, and SDK version.

## Caveats

- The sample is Apache-2.0, but the DLSS/NGX dependency is not.
- DLSS-RR output can hide bad guide buffers; inspect inputs first.
