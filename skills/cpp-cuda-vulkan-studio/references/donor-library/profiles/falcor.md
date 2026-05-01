# NVIDIA Falcor Donor Profile

Source: https://github.com/NVIDIAGameWorks/Falcor  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Falcor core license plus component licenses; inspect `LICENSE.md`, `dependencies.xml`,
RTX/DLSS/NRD/RTXDI/NVAPI/CUDA/OptiX components, ORCA scenes, and sample assets at the exact revision used.

## Use First For

- Realtime rendering framework architecture, render graphs, ray tracing, path tracing, shader/model
  loading, Python scripting, and research/prototype renderer organization.
- Comparing DirectX 12 and Vulkan renderer abstractions for realtime ray tracing work.
- NVIDIA RTX SDK integration boundaries when the user explicitly targets NVIDIA rendering features.

## First Upstream Areas To Inspect

- `Source/`, render graph examples, sample renderers, scene/model loading, shader compilation, and docs.
- RTX, DLSS, NRD, RTXDI, NVAPI, CUDA, and OptiX integration points only when those features are explicit.
- `dependencies.xml`, setup scripts, ORCA/rendering resources, and scene assets before dependency reuse.

## Integration Notes

- Treat Falcor as a dependency-scale framework or architecture donor, not copyable snippets.
- Keep Vulkan/DirectX abstraction, render graphs, RTX features, sample scenes, and Python scripting as
  separate dependency decisions.
- For Vulkan-first projects, borrow render-graph and ray-tracing architecture without adding NVIDIA-only
  SDKs unless requirements force them.
- Document any NVIDIA-specific SDK boundary in build options, tests, and docs.

## Validation Ideas

- Reproduce a tiny render-graph or ray-tracing concept with target-project fixtures before larger scenes.
- Test missing SDK, missing RTX feature, unsupported GPU, shader compile failure, and scene-load failure.
- Label vendor-specific tests separately from portable Vulkan/render tests.
- Compare image outputs only after validation-layer or framework diagnostics are clean.

## Caveats

- Falcor has Windows, NVIDIA, RTX, and SDK coupling in common workflows.
- ORCA scenes and SDK components have separate licenses.
- It can dominate project architecture; use narrower donors for small viewers or renderer backbones.
