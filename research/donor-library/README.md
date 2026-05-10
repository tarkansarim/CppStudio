# 3D, AI, And Native Infrastructure Donor Library Research

Generated: 2026-04-30
Expanded: 2026-05-01

This folder records the research basis for the reusable donor library and production routing overlays
wired into
`skills/cpp-cuda-vulkan-studio/references/donor-library/`.

The installed skill should use the reference files under the skill directory. This research folder is
for discussion, expansion, and source provenance before future skill updates.

## Files

- [source-map.md](source-map.md): donor candidates, links, license tier, and category.
- [trigger-matrix.json](trigger-matrix.json): routing regression cases for skill and donor discovery.
- [trigger-regression-checklist.md](trigger-regression-checklist.md): manual/subagent trigger-lane
  expectations.
- `scripts/audit_donor_freshness.py`: optional report-only source URL and `Last checked` metadata
  audit for donor profiles.

## Policy Summary

- Prefer permissive donors for reusable code and templates: MIT, Apache-2.0, BSD-2/3-Clause, zlib, CC0.
- Keep non-commercial, research-only, GPL-family, unclear, and source-available projects in a separate
  study-only bucket.
- Treat code, assets, model weights, datasets, and submodules as separate license surfaces.
- Before vendoring or adapting code, verify the exact upstream license and third-party notices at the
  revision used.

## Skill Linkage

The main skill now points agents to:

- `references/donor-library/README.md`
- `references/donor-library/selection-policy.md`
- category files for Vulkan foundation tooling, glTF/runtime assets, renderer backbones, runtime mesh
  pipelines, WebGPU/WebGL, browser 3D, native GUI/HUD/editor UI, path tracing, physical rendering, engine architecture,
  geometry/simulation, sculpting/brush tools, AI runtimes/kernels, ML compilers, neural 3D, hair/grooming/fur, DCC scene
  pipelines, volumes/voxels, medical/scientific volumes, animation/rigging, VFX/particles,
  surfaces/subdivision, texture/material/color, assets/NURBS, BIM/IFC, terrain/geospatial,
  CAD/precision geometry, advanced simulation, muscle/flesh/biomechanics, XR/spatial work, VFX studio
  and games production overlays, and native engineering infrastructure.
