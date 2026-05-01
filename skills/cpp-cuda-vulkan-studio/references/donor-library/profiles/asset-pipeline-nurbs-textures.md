# Asset Pipeline, NURBS, And Texture Tooling Profile

Sources: https://github.com/mcneel/opennurbs https://github.com/pradeep-pyro/tinynurbs https://github.com/jpcy/xatlas https://github.com/google/draco https://github.com/ARM-software/astc-encoder https://github.com/microsoft/DirectXTex https://github.com/AcademySoftwareFoundation/OpenPBR https://github.com/OpenAssetIO/OpenAssetIO
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic, native-cpu
License signal: mixed permissive and dependency-scale sources; inspect OpenNURBS custom terms, Draco/ASTC/OpenPBR/OpenAssetIO Apache-2.0, tinynurbs BSD-3-Clause, xatlas/DirectXTex MIT, and all bundled notices at the exact revisions used.

## Use First For

- `.3dm`/Rhino import/export, lightweight NURBS math, UV atlas generation, compressed geometry, ASTC/DDS
  tooling, material semantics, and production asset identity.
- Designing asset-pipeline stages before GPU upload: source import, mesh conditioning, material
  translation, texture conversion, compression, packaging, and runtime handoff.

## Integration Notes

- Use tinynurbs for compact native C++ NURBS tests; use OpenNURBS when Rhino interoperability matters.
- Keep xatlas/Draco/ASTC/DirectXTex in offline or content-pipeline stages unless runtime support is
  explicitly required.
- Treat OpenPBR as material semantics and OpenAssetIO as production asset-management infrastructure,
  not runtime renderer requirements.
- Keep source assets, material libraries, textures, DCC metadata, and generated caches as separate
  provenance surfaces.

## Validation Ideas

- Build tiny fixtures for one NURBS curve, one NURBS surface, one UV-atlased mesh, one Draco mesh, and
  one compressed texture conversion.
- Verify that material names, units, texture coordinates, and color-space metadata survive each handoff.
