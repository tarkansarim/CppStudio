# NVIDIA NRD Sample Donor Profile

Source: https://github.com/NVIDIA-RTX/NRD-Sample  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: license and third-party notices must be reviewed in the sample checkout; it depends on
NRI/NRD and may involve SDK or data package terms.

## Use First For

- End-to-end path tracing plus denoising best practices for games.
- Comparing NRD and DLSS Ray Reconstruction input/output contracts.
- Guide-buffer debugging, reference accumulation, and denoiser validation UX.
- Fast path tracing choices such as probabilistic lobe selection, radiance caching, and reconstruction
  tradeoffs.

## First Upstream Areas To Inspect

- `README.md` for recommended branches, runtime modes, and feature overview.
- `Source/NRDSample.cpp` for host orchestration and UI/runtime toggles.
- `Shaders/` for guide-buffer generation, ray tracing, denoiser inputs, and reconstruction comparisons.
- NRI, NRD, and data/resource setup before adopting dependency policy.

## Integration Notes

- Use the sample as a reference implementation for staging and validation, not as a small library.
- Keep NRD, DLSS-RR, raw RT, and reference accumulation as separate modes when borrowing UX or tests.
- Translate NRI-backed patterns deliberately if the target renderer is direct Vulkan.
- Keep sample data and downloaded resources separate from reusable test fixtures until licenses are
  reviewed.

## Validation Ideas

- Build minimal scenes that exercise diffuse, specular, mirror-like, transparent, hair/thin-geometry, and
  animated cases.
- Add per-buffer debug captures before comparing final denoised images.
- Record the active reconstruction mode and input resolution in screenshots and profiler output.
- Use fixed camera/reference accumulation captures as controls for realtime reconstruction paths.

## Caveats

- The sample is dependency-heavy and not a small vendorable donor.
- Exact source and asset license review is required before reusing anything beyond concepts.
