# NVIDIA Streamline Donor Profile

Source: https://github.com/NVIDIA-RTX/Streamline  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: MIT-like core source signal, with separate plugin, binary artifact, third-party, Nsight
Perf SDK, and DLSS feature terms; inspect `license.txt`, `3rd-party-licenses.md`, release packages, and
plugin notices at the exact revision used.

## Use First For

- Cross-IHV super-resolution and frame-generation integration boundaries.
- One integration path that can host DLSS and other vendor features through feature plugins.
- Frame tagging, resource tagging, feature evaluation, and plugin lifecycle structure.
- Modern DLSS integration when the user explicitly wants Streamline instead of direct NGX wiring.

## First Upstream Areas To Inspect

- `include/` for public API and feature interfaces.
- `source/` and `shaders/` for integration and plugin behavior that is available in source form.
- `docs/` for frame tagging, resource lifetime, and feature integration guidance.
- `license.txt`, `3rd-party-licenses.md`, release ZIPs, and binary plugin packaging.

## Integration Notes

- Keep Streamline optional and feature-gated; do not make it a default Vulkan requirement.
- Decide whether the target project uses direct NGX/DLSS or Streamline before adding wrappers.
- Track plugin binaries and release packaging separately from source build dependencies.
- State whether the build uses production-signed NVIDIA binaries or a development build.

## Validation Ideas

- Test feature unavailable, plugin missing, unsupported GPU, and disabled-upscaler paths.
- Add startup and shutdown tests that do not initialize feature plugins when they are not requested.
- Validate resource tags and frame constants with debug overlays or SDK diagnostics.
- Record exact Streamline and DLSS versions in captures and profiler output.

## Caveats

- Streamline reduces app-side integration repetition but expands runtime packaging and plugin policy.
- Some feature plugins and binaries have separate terms from the core source.
