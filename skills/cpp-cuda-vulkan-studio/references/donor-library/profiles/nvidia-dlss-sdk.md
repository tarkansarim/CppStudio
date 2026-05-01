# NVIDIA DLSS SDK Donor Profile

Source: https://github.com/NVIDIA/DLSS  
Tier: `dependency-candidate`  
Backend signal: native-vulkan, native-directx
License signal: NVIDIA RTX SDKs license plus release-package and sample-source terms; inspect
`LICENSE.txt`, release binaries, docs, and bundled NVIDIA Image Scaling notices at the exact revision
used.

## Use First For

- Official NGX and DLSS Ray Reconstruction feature contracts.
- Vulkan and DirectX DLSS/DLSS-RR headers, parameters, flags, and guide-buffer requirements.
- Runtime capability checks, feature creation, evaluation, and shutdown sequencing.
- Understanding which resources are SDK-managed versus project-managed.

## First Upstream Areas To Inspect

- `include/` for NGX and DLSS/DLSS-RR API headers.
- `doc/` for programming and DLSS-RR integration guides.
- Release packages for binaries, redistributables, and sample application contents.
- The NVIDIA Image Scaling submodule when spatial scaling fallback is in scope.

## Integration Notes

- Treat DLSS as an explicit optional NVIDIA runtime dependency.
- Do not make DLSS a hidden requirement for a Vulkan-first renderer; keep raw or non-DLSS lanes available.
- Document input/output resolution semantics, jitter, motion-vector convention, depth convention, and guide
  buffers in project docs.
- Keep SDK initialization and shutdown ordering covered by tests, especially when a renderer can run with
  DLSS disabled.

## Validation Ideas

- Test missing SDK/binaries, unsupported GPU, disabled feature, and fallback raw path.
- Add debug captures for color, motion vectors, depth, normal/roughness, albedo, and specular hit distance.
- Verify output sizing and upscaler/reconstruction mode labels in screenshots/profiler logs.
- Run short smoke tests with DLSS off, DLSS-SR, and DLSS-RR if supported.

## Caveats

- This is not a permissive source donor; it is an SDK dependency with binary/runtime terms.
- DLSS behavior is model, driver, SDK, platform, and GPU dependent. Avoid brittle pixel-perfect tests for
  SDK output.
