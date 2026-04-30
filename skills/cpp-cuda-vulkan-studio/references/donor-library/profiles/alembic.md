# Alembic Donor Profile

Source: https://github.com/alembic/alembic  
Tier: `dependency-candidate`  
License signal: BSD-3-Clause for original code; inspect `LICENSE.txt`, `THIRD-PARTY.txt`, optional
HDF5/Python/DCC plugin dependencies, and sample data at the exact revision used.

## Use First For

- Baked animated geometry, curves, points, cameras, transforms, and simulation caches.
- DCC interchange when scene composition, variants, and live asset layering are not required.
- Groom cache and simulation cache workflows between tools such as Maya, Houdini, and renderers.
- Stable file IO boundaries for offline converters and runtime asset baking.

## First Upstream Areas To Inspect

- `lib/` for C++ archive, object hierarchy, schema, and property APIs.
- `bin/` and examples for inspection/conversion tool behavior.
- `maya/`, `houdini/`, `prman/`, and `arnold/` only as DCC/plugin references with separate dependency
  checks.
- Build options for shared/static libraries, HDF5, Python bindings, and DCC plugins.
- `THIRD-PARTY.txt` and optional dependency docs before vendoring or packaging.

## Integration Notes

- Use Alembic for baked cache interchange; use OpenUSD when composition, payloads, variants, references,
  or collaborative scene assembly matter.
- Keep archive IO, schema mapping, time sampling, coordinate/unit conversion, and runtime asset baking as
  separate layers.
- Preserve topology-varying versus constant-topology assumptions in tests.
- Do not make proprietary DCC SDKs or renderer plugins implicit dependencies of a reusable converter.

## Validation Ideas

- Read and write a tiny animated mesh, animated transform, and curve fixture, then compare sample times,
  bounds, topology, and selected attributes.
- Test missing optional properties, multiple time samplings, topology changes, and large-frame caches.
- Validate coordinate system, units, shutter/time-sample interpretation, and path naming conventions.
- Run converter tests without DCC plugin dependencies unless the target explicitly supports those plugins.

## Caveats

- Alembic carries baked data well but does not model full modern scene composition.
- Optional HDF5, Python, Maya, Houdini, Arnold, and RenderMan paths change dependency and license
  surfaces.
- Cache files can be large and asset-owned; keep sample caches small and provenance-tracked.
