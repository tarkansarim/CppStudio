# NVIDIA RTXCR Donor Profile

Source: https://github.com/NVIDIA-RTX/RTXCR  
Tier: `dependency-candidate`  
Backend signal: native-vulkan, native-directx
License signal: NVIDIA RTX SDKs license; inspect `License.txt`, submodules, binary SDK pieces,
sample assets, and RTXCR-Assets terms at the exact revision used.

## Use First For

- Path-traced hair and skin rendering architecture for native realtime viewers.
- Linear Swept Sphere (LSS) and Disjoint Orthogonal Triangle Strip (DOTS) hair rendering concepts.
- Hair material plumbing around Chiang and Far-Field BSDF modes.
- DLSS-RR and NRD comparison structure in an RTX character-rendering sample.
- Environment lighting, lookdev controls, reference accumulation, and RTX-oriented path-tracer shell
  behavior.

## First Upstream Areas To Inspect

- `docs/RtxcrHairGuide.md` for hair data, material, and integration notes.
- `docs/RtxcrLssPerf.md` for LSS performance and memory tradeoffs.
- `docs/RtxcrUserGuide.md` for renderer controls, environment lighting, accumulation, and sample UX.
- `samples/pathtracer/src/` for acceleration-structure and renderer orchestration patterns.
- `samples/pathtracer/shaders/` for raygen, closest-hit, miss, G-buffer, and hair-shading flow.
- `libraries/rtxcr/` only after the license and binary/source boundary is understood.

## Integration Notes

- Treat RTXCR as a high-value hair rendering and ray-tracing reference, not a small snippet donor.
- Keep the NVIDIA SDK boundary explicit in CMake options, documentation, CI labels, and runtime
  capability checks.
- Use its hair material and LSS/DOTS concepts even when the target project stays Vulkan-first; do not
  silently add DLSS, NRD, or other NVIDIA-only dependencies unless the user chooses them.
- Keep RTXCR sample assets and downloadable content out of reusable templates until asset licenses are
  reviewed.

## Validation Ideas

- Build a tiny strand/LSS fixture and compare bounds, BLAS/TLAS updates, and closest-hit coverage.
- Add A/B captures for raw RT, denoised/reconstructed output, and raster fallback when applicable.
- Verify unsupported GPU, missing SDK, missing DLL/shared-library, disabled Streamline, and missing
  asset paths fail clearly.
- Profile primary-only tracing before adding denoising or multi-bounce features.

## Caveats

- The license is not a generic permissive open-source license; treat RTXCR as dependency-scale until
  legal and release requirements are checked.
- The sample is NVIDIA/RTX-oriented and may pull Streamline, DLSS, NRD, assets, and framework code into
  scope.
- Do not import source-project-specific integration decisions when using this donor; keep project glue
  local to the target repo.
