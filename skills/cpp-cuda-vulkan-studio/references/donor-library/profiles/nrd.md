# NVIDIA NRD Donor Profile

Source: https://github.com/NVIDIA-RTX/NRD  
Tier: `dependency-candidate`  
Backend signal: api-agnostic
License signal: NVIDIA RTX SDKs license; inspect `LICENSE.txt`, integration files, shaders, and
third-party notices at the exact revision used.

## Use First For

- Real-time denoiser signal contracts for path-traced or ray-traced renderers.
- Guide-buffer definitions for normal, roughness, viewZ/depth, motion, radiance, albedo, and hit
  distance.
- RELAX, REBLUR, SIGMA, and related denoiser integration strategy.
- Debug validation around temporal reconstruction and denoiser input correctness.

## First Upstream Areas To Inspect

- `README.md` and `UPDATE.md` for supported methods and integration expectations.
- `Include/NRDDescs.h` and `Include/NRDSettings.h` for signal contracts and settings.
- `Integration/NRDIntegration.h` and `Integration/NRDIntegration.hpp` for host-side integration shape.
- `Shaders/NRD.hlsli` and method-specific shader includes for input/output semantics.

## Integration Notes

- Treat NRD as dependency-scale; do not copy denoiser internals into a reusable template.
- Define guide-buffer production and validation before wiring the denoiser call.
- Keep raw RT and denoised outputs available as separate developer/debug lanes.
- For Vulkan projects, route resource transitions and image layouts through the Vulkan lane skill before
  judging denoiser behavior.

## Validation Ideas

- Add debug views for every required guide buffer before enabling the denoiser.
- Test camera motion, animated objects, disocclusion, mirror-like materials, thin geometry, and zero-motion
  scenes.
- Compare raw, NRD, and any upscaler/reconstruction output on fixed test scenes.
- Fail clearly when required guide buffers or feature support are missing.

## Caveats

- NRD's source license is not a generic permissive license.
- Denoising failures often come from bad inputs, not the denoiser itself; inspect guide buffers before
  tuning denoiser settings.
