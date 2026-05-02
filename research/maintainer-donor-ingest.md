# Maintainer Donor Ingest Notes

Date: 2026-05-01

Scope: extract reusable upstream donor references from maintainer-provided private research notes
without copying private implementation code, assets, shaders, tests, fixtures, generated artifacts, or
project-specific rules.

## Source Material Reviewed

Maintainer-local design notes, component matrices, rendering-upgrade notes, and private project skill
drafts were reviewed only to identify public upstream donor projects and license signals. Those local
notes and private skills are not part of CppStudio.

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

- No private `src/`, `include/`, `shaders/`, `tests/`, fixtures, recordings, screenshots, or generated
  artifacts were copied into CppStudio.
- Private project rules, local GPU/workstation notes, and project-specific skills were not moved into
  the generic CppStudio skill.
- Local donor checkouts were used only to verify names, roles, and license signals; the public donor
  profiles point at upstream sources instead.
