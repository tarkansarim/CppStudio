# CudaGroomTool Donor Ingest

Date: 2026-05-01

Scope: extract reusable upstream donor references from a maintainer-provided CudaGroomTool checkout
without copying CudaGroomTool implementation code, assets, shaders, tests, fixtures, or
project-specific rules.

## Local Sources Reviewed

- `docs/RT_RESTART_DONOR_RESEARCH.md`
- `docs/RT_RESTART_COMPONENT_MATRIX.md`
- `docs/HAIR_RENDER_UPGRADE_PATHS.md`
- `docs/RESEARCH.md`
- `.codex/skills/rt-*/SKILL.md`
- `.codex/skills/unreal-hair-reference/`
- `.codex/skills/unity-hair-reference/`

## Donors Added To CppStudio

- NVIDIA RTXCR
- RTXCR Material Library
- RTXCR Geometry Library
- NVIDIA NVRHI
- NVIDIA NRI
- NVIDIA NRD
- NVIDIA NRD Sample
- NVIDIA DLSS SDK
- NVIDIA Streamline
- NVIDIA Streamline Sample
- nvpro Vulkan Ray Tracing Tutorial KHR
- nvpro vk_denoise_dlssrr
- nvpro Vulkan glTF Renderer
- Unreal HairStrands study-only reference
- Unity HDRP Hair study-only reference

## Exclusions

- No CudaGroomTool `src/`, `include/`, `shaders/`, `tests/`, fixtures, recordings, screenshots, or
  generated artifacts were copied into CppStudio.
- CudaGroomTool-specific RT restart rules, local GPU/workstation notes, and project-specific skills were
  not moved into the generic CppStudio skill.
- Local donor checkouts were used only to verify names, roles, and license signals; the public donor
  profiles point at upstream sources instead.
