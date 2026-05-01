# NVIDIA NRI Donor Profile

Source: https://github.com/NVIDIA-RTX/NRI  
Tier: `safe-donor`  
Backend signal: mixed-backend
License signal: MIT; inspect `LICENSE.txt`, bundled dependencies, wrappers, and extension modules at
the exact revision used.

## Use First For

- Low-level render-interface abstraction over Vulkan and Direct3D 12.
- Cross-backend capability queries and renderer initialization policy.
- Upscaler and ray-tracing extension boundaries, especially around NRI wrappers.
- Projects that need a thinner interface than a full engine framework but more structure than raw API
  calls.

## First Upstream Areas To Inspect

- `Include/` for core interface types and backend wrappers.
- `Include/Extensions/NRIRayTracing.h` for ray-tracing extension shape.
- `Include/Extensions/NRIUpscaler.h` for upscaler integration boundary.
- `Source/Shared/` for shared implementation and extension plumbing.

## Integration Notes

- Use NRI when cross-backend renderer plumbing is a real product requirement.
- For direct Vulkan projects, borrow capability-detection and extension-boundary ideas without adding a
  new abstraction layer by default.
- Keep NRI upscaler, ray tracing, and wrapper extensions separately configurable in build options.
- Treat NGX/DLSS/NRD integrations that use NRI as separate license and runtime surfaces.

## Validation Ideas

- Test unsupported backend, unsupported feature, missing Vulkan extension, and missing DLL/shared-library
  cases.
- Validate ray-tracing capability reporting before creating acceleration structures.
- Add a tiny backend smoke test for resource creation, dispatch/draw, and cleanup.
- Compare behavior between direct Vulkan and NRI-backed lanes only when both are intentionally present.

## Caveats

- NRI is useful architecture context even when not selected as a dependency.
- It does not remove the need to understand Vulkan synchronization and resource ownership underneath.
