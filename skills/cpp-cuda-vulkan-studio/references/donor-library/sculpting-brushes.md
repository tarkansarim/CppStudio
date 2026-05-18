# Sculpting Brush And High-Poly Mesh Tool Donors

Use these donors for ZBrush-like or Mudbox-like sculpting tools, high-poly surface editing, brush
families, stylus-driven mesh deformation, multiresolution sculpting, dynamic topology, mask/face-set
workflows, and realtime viewport performance around dense editable meshes.

## Brush-First Routing

When the request mentions sculpting brushes, ZBrush-like tools, high-poly mesh editing, clay/smooth/
grab/pinch/flatten/mask brushes, Wacom/stylus sculpting, dynamic topology, multiresolution sculpting,
voxel remesh, or brush performance on dense meshes, start with
[Blender Sculpt Brushes](profiles/blender-sculpt-brushes-study-only.md) before generic geometry,
renderer, or GUI donors.

Blender remains study-only: extract brush behavior contracts, acceleration-shape ideas, fixtures, and
validation targets, then implement independently in the selected C++/Vulkan/CUDA lane.

For mesh sculpting, do not collapse Blender-style stroke behavior into "collect samples, apply once
on release" unless the user explicitly asked for an offline apply tool. A normal interactive sculpt
brush updates while the button or stylus contact is held: each accepted move sample extends the stroke
runtime, evaluates the brush against the hit surface, dirties the affected sculpt chunks or mesh
region, and advances the visible document/render state before release. Release finalizes the single
undoable stroke transaction; it is not the first time deformation appears. A Level 4 slice for a
Standard/Sculpt/Draw-style brush is not ready until it states this live-contact contract and defines
a mid-stroke proof before mouse/stylus release.

If a sculpting or brush bug stalls after two focused attempts, stop generic local patching and return
to this route before another code edit. The next slice must map the reported symptom to Blender or
peer-tool behavior, the local mismatch, and a before/after proof. This is mandatory for brush
palette selection, delayed active-tool changes, mouse/stylus hit offsets, stroke sampling, pressure,
falloff, masks, smooth/clay/grab behavior, high-poly dirty uploads, or viewport picking.

## Sculpt Brush And Topology References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Blender Sculpt Brushes](profiles/blender-sculpt-brushes-study-only.md) | study-only | Blender source is GPL-family; do not copy code/assets | Primary behavior donor for standard sculpt displacement, Smooth/Relax, Clay, Inflate, Grab/Move, Pinch/Crease, Flatten/Scrape, Mask, pressure/falloff, Paint BVH-style queries, stroke caches, Mesh/BMesh/Grid storage, and selective GPU update concepts. Use target peer-tool vocabulary for visible brush names. |
| [ZBrush Sculpting Brushes](https://help.maxon.net/zbr/en-us/Content/html/user-guide/3d-modeling/sculpting/sculpting-brushes/sculpting-brushes.html) | study-only | Proprietary product docs; no code reuse | Peer-tool brush behavior and artist expectations for Standard, Smooth, Move, Inflate, Pinch, Flatten, Clay, and related sculpt verbs. |
| [Nomad Sculpt Topology](https://nomadsculpt.com/manual/topology) | study-only | Proprietary product docs; no code reuse | Compact high-poly product workflow reference for polygon stats, multiresolution, voxel remesh, dynamic topology, decimation, and topology warnings. |
| [Nomad Sculpt Tools](https://nomadsculpt.com/manual/tools) | study-only | Proprietary product docs; no code reuse | Brush grouping and tool-surface reference for brush, move, mask, flatten/planar, crease/pinch, trim, split, and transform style workflows. |
| [Mudbox BrushOperation](https://help.autodesk.com/view/MBXPRO/ENU/?guid=GUID_2D5459EC_E29C_4073_929D_17DF5664F9AD_htm) | study-only | Autodesk SDK/product docs; inspect plugin SDK terms before reuse | Brush operation contracts for size, strength, direction, falloff, stamps, pressure, and local mesh enumeration from a picked point. |

## Implementation And Performance Donors

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [meshoptimizer](profiles/meshoptimizer.md) | safe-donor | MIT | Mesh conditioning, simplification, vertex/index ordering, compression, future cluster/LOD pipelines, and imported/evaluated mesh preparation. |
| [OpenSubdiv](profiles/opensubdiv.md) | safe-donor | Apache-2.0-style; inspect optional deps | Production subdivision and multiresolution evaluation semantics, crease/boundary behavior, and CPU/GPU evaluator split. |
| [Vulkan Memory Allocator](profiles/vulkan-memory-allocator.md) | safe-donor | MIT | Device-local high-poly buffers, staging/ring allocation, memory budget readback, custom pools, mapping policy, and buffer-device-address-ready allocation plans. |
| [libigl](profiles/libigl.md) | dependency-candidate | MPL-2.0 with GPL/copyleft subfolder caveats | Mesh deformation, remeshing, parameterization, and geometry-processing references after exact module/license review. |
| [CGAL](profiles/cgal.md) | dependency-candidate | Mixed LGPL/GPL by package; commercial option exists | Robust remeshing, Booleans, exact geometry, and topology-processing references after package-level license review. |

## Selection Notes

- Use Blender Sculpt Brushes as the primary behavior donor for mesh-sculpt brush families. Do not use
  generic displacement tests as the product brush plan after this route triggers.
- For brush-selection and pointer-hit bugs, start with Blender's stroke/operator and Paint BVH
  concepts before renderer or generic mouse-event code. Recent Blender sculpt notes include explicit
  operator support for deriving stroke positions from mouse events; use that as a reminder to prove
  the screen-to-surface path, not only that a mesh revision changed.
- For live sculpt strokes, prove a pre-release state change: after a held-contact move and before the
  release event, read back a changed mesh/document/render revision, dirty region, semantic stroke
  trace, or fresh app-owned capture. A final before/after after release proves only batched stroke
  application, not live sculpting.
- Treat ZBrush, Nomad, and Mudbox as peer-tool/product references, not code donors. Use them to check
  expected brush families, topology warnings, pressure/falloff behavior, and UI vocabulary.
- Do not let study-donor naming leak into product UI by default. Pick visible brush/tool names from
  the selected peer-tool family, then map them to donor-backed behavior contracts.
- For high-poly performance, require chunked sculpt storage, Paint-BVH-style spatial queries,
  dirty-region GPU uploads, multiresolution/LOD, and numeric frame/stroke/memory gates before claiming
  the engine can handle dense production meshes.
- Keep dynamic topology, multiresolution, voxel remesh, decimation, and subdivision as separate
  workflows with explicit invalidation rules. Do not silently mix topology-changing tools with
  multiresolution detail preservation.
- Use Vulkan compute brush kernels only after profiling shows CPU brush evaluation or dirty upload is
  the bottleneck. Do not add CUDA to a Vulkan-first sculpt tool unless the user explicitly chooses a
  CUDA or interop lane.

## Deep Profiles

- [Blender Sculpt Brushes Study-Only](profiles/blender-sculpt-brushes-study-only.md): read before
  designing or implementing mesh sculpt brushes, stroke behavior, Paint BVH-style queries, high-poly
  dirty-region editing, pressure/falloff, masks, face sets, dynamic topology, or multires sculpting.
- [meshoptimizer](profiles/meshoptimizer.md): read before mesh conditioning, simplification,
  compression, or future cluster/LOD work.
- [OpenSubdiv](profiles/opensubdiv.md): read before adopting subdivision or multiresolution surface
  semantics.
- [Vulkan Memory Allocator](profiles/vulkan-memory-allocator.md): read before high-poly Vulkan buffer
  ownership, staging, or memory-budget work.
- [libigl](profiles/libigl.md): read before borrowing geometry-processing or remeshing references.
- [CGAL](profiles/cgal.md): read before robust exact geometry, Boolean, or remeshing decisions.
