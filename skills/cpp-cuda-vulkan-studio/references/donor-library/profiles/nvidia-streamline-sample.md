# NVIDIA Streamline Sample Donor Profile

Source: https://github.com/NVIDIA-RTX/Streamline_Sample  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: NVIDIA RTX SDKs sample license plus Donut/third-party notices; inspect the sample
license, `donut/ThirdPartyLicenses.txt`, `donut/LICENSE.txt`, plugin binaries, and feature SDK terms at
the exact revision used.

## Use First For

- App-side Streamline usage patterns after the core Streamline API has been selected.
- Feature wiring, frame constants, resource tagging, and per-frame evaluation flow.
- Practical sample-shell behavior for DLSS, frame generation, reflex/latency, and plugin packaging.
- Comparing direct NGX/DLSS integration against a Streamline-hosted feature path.

## First Upstream Areas To Inspect

- Sample application source that initializes Streamline and evaluates selected features.
- Resource/frame tagging code around color, depth, motion, exposure, and output resources.
- Build and deployment scripts for plugin binaries and runtime DLL/shared-library placement.
- Donut framework and third-party license files before borrowing build or windowing patterns.

## Integration Notes

- Read [NVIDIA Streamline](nvidia-streamline.md) first for the core API and license boundary.
- Treat this sample as app-side usage guidance, not as a renderer architecture to import wholesale.
- Keep plugin packaging, feature flags, SDK binary distribution, and fallback lanes explicit in target
  project documentation.
- Do not replace a simpler direct NGX/DLSS integration with Streamline unless Streamline's plugin model is
  a deliberate project choice.

## Validation Ideas

- Test all feature-disabled paths without initializing plugin features.
- Verify resource tags, frame constants, jitter, motion vectors, and output extents with debug overlays or
  SDK diagnostics.
- Add packaging tests that fail clearly when plugin binaries are missing.
- Record Streamline, sample, and feature-SDK versions in captures and logs.

## Caveats

- The sample combines core Streamline source, NVIDIA SDK feature terms, binary plugins, and Donut framework
  dependencies.
- It is useful for integration flow, but small Vulkan renderers should avoid inheriting its whole sample
  shell by accident.
