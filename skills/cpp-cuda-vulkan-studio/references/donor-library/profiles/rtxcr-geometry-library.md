# RTXCR Geometry Library Donor Profile

Source: https://github.com/NVIDIA-RTX/RTXCR-Geometry-Library  
Tier: `dependency-candidate`  
Backend signal: api-agnostic
License signal: NVIDIA RTX SDKs license; inspect `License.txt`, headers, shader includes, and any SDK
notice files at the exact revision used.

## Use First For

- Curve-to-ray-tracing geometry conversion concepts for strand hair.
- Linear Swept Sphere (LSS) and Disjoint Orthogonal Triangle Strip (DOTS) helper design.
- Curve tessellation math for hair RT acceleration structures.
- Separating canonical groom/strand data from render-specific geometry payloads.

## First Upstream Areas To Inspect

- `include/CurveTessellation.h` for curve tessellation API shape.
- `include/CurveTessellationMath.h` for geometry math and edge cases.
- `shaders/include/rtxcr/geometry.hlsli` for shader-side geometry access patterns.
- RTXCR docs that explain LSS and DOTS tradeoffs.

## Integration Notes

- Keep the target project's source groom representation separate from RTXCR-style render geometry.
- Build an explicit adapter from strands, guide curves, or points into the target renderer's BLAS/TLAS
  inputs.
- Translate backend-specific shader details through Vulkan or CUDA lane guidance as needed.
- Treat hardware LSS paths as optional and capability-gated; provide a fallback geometry path when a
  project needs broader hardware support.

## Validation Ideas

- Test straight, curved, short, zero-length, sparse, and high-radius strand segments.
- Validate generated AABBs and acceleration-structure inputs before debugging shading.
- Compare geometry-only visibility and hit attributes before adding material logic.
- Add stress tests for dynamic hair updates and BLAS refit/rebuild decisions.

## Caveats

- The license is SDK-style and requires explicit review before source reuse.
- Hardware LSS support is vendor/generation specific; do not make it a hidden baseline requirement in
  Vulkan-first reusable templates.
