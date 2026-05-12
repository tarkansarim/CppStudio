# Blender Sculpt Brushes Study-Only Donor Profile

Sources: https://docs.blender.org/manual/en/latest/sculpt_paint/sculpting/brushes/index.html https://docs.blender.org/manual/en/latest/sculpt_paint/sculpting/introduction/adaptive.html https://developer.blender.org/docs/features/sculpt_paint/mesh_paint/ https://developer.blender.org/docs/release_notes/4.4/sculpt/ https://projects.blender.org/blender/blender/src/branch/main/source/blender/editors/sculpt_paint/brushes
Last checked: 2026-05-12
Tier: `study-only`
Backend signal: native-cpu, dcc-interchange, mixed-backend
License signal: Blender source is GPL-family. This profile is for behavior extraction, UX contracts,
data-flow notes, performance architecture, and tests only. Do not copy Blender source, brush assets,
icons, or bundled data into permissive CppStudio templates or target projects unless that project
explicitly accepts GPL-compatible reuse.

## Use First For

- ZBrush-like or Mudbox-like mesh sculpting tools that need real brush families instead of one generic
  test stroke.
- Brush behavior contracts for Draw/Standard, Smooth/Relax, Clay/Clay Build, Inflate/Deflate,
  Grab/Move, Pinch/Crease, Flatten/Scrape, Mask, Clay Strips, Layer, Snake Hook, Nudge/Thumb, Relax
  Slide, Draw Face Sets, Density, Pose, Boundary, Cloth, and multires displacement brushes.
- High-poly sculpt-engine planning: Mesh/BMesh/Grid storage, Paint BVH-style raycasts/coarse
  filtering/selective GPU updates, stroke caches, dirty-node updates, and topology-mode boundaries.
- Planning validation around pressure, radius/strength curves, falloff, masks, face sets, symmetry,
  undo/replay, backface or visibility filters, and degenerate geometry.

## First Upstream Areas To Inspect

- Official Blender sculpt brush manual for the current brush catalog and user-facing behavior names.
- Blender adaptive sculpting documentation for dynamic topology, multiresolution, and topology-mode
  caveats.
- Blender mesh painting/sculpting developer docs for storage backends, Paint BVH, stroke runtime
  structures, and selective GPU update concepts.
- Focused source files under `source/blender/editors/sculpt_paint/brushes/` only for behavior study,
  not copying.
- Nearby current source or docs found through upstream search for `brush_stroke`, `paint_stroke`,
  `sculpt.brush_stroke`, `PBVH`, and brush-specific operators. Do not guess file names from memory;
  inspect the current Blender tree or official developer docs before citing a path.
- Blender 4.4 sculpt notes mention `sculpt.brush_stroke` location override behavior for mouse-event
  derived stroke positions. Treat that as a source-backed reminder that viewport brush bugs need a
  tested screen-to-surface coordinate pipeline, not just a generic mesh edit.

## Extracted Brush Contracts

- **Common stroke substrate**: stroke sampling, radius, strength, pressure modulation, falloff,
  direction mode, active surface plane, symmetry, masks/face sets, accumulation, and undo/replay must
  be shared by all brush families.
- **Pointer-to-stroke contract**: a brush dab starts from the user event, maps through widget/window
  geometry and device-pixel ratio into the viewport render target, constructs a camera ray, queries
  the sculpt acceleration structure, and commits the brush center on the hit surface. Tests should
  compare requested pointer, local/render-target point, hit primitive, committed world point, and
  visible marker/result.
- **Active-brush contract**: palette or hotkey selection must update the active brush promptly through
  the same command path a user exercises. Tests should cover repeated selection across enabled brush
  entries and measure event-to-active-brush latency.
- **Draw versus Inflate**: Draw/Standard moves affected vertices along a sampled stroke/surface
  direction; Inflate/Deflate moves each vertex along its own normal. Tests should distinguish them.
- **Smooth/Relax**: smoothing must respect masks, boundaries, visibility/backface policy, and
  topology mode. It should not destroy intended silhouettes or masked regions.
- **Grab/Move**: the affected set should be captured at stroke start and moved by stroke delta, not
  reselected as a continuous displacement stamp.
- **Clay and Clay Build**: volume-building brushes need plane/normal control and smoothing/flattening
  bias, not just raw normal displacement.
- **Pinch/Crease**: pinch-like behavior pulls toward a center or line while crease variants combine
  attraction with additive/subtractive depth.
- **Flatten/Scrape**: planar brushes need stable brush-plane locking and clear behavior on noisy or
  low-sample neighborhoods.
- **Mask**: mask painting is a first-class brush because every deformation brush must honor protected
  weights.
- **Topology modes**: dynamic topology, multiresolution grids, voxel remesh, and decimation must be
  separate workflows with explicit data invalidation and user-visible blockers when a brush cannot
  preserve a mode.

## High-Poly Architecture Notes

- **Chunked sculpt storage**: store positions, normals, masks, face sets, materials, and auxiliary
  brush data in cache-friendly chunks with bounds, dirty flags, GPU buffer ranges, and revisions.
- **Paint BVH-style query layer**: use a spatial hierarchy over chunks/nodes for picking, brush-radius
  queries, visibility/backface filtering, coarse culling, and selective redraw/upload.
- **Stroke caches**: per-stroke runtime data should live only for a stroke, while longer-lived session
  state such as undo, current active vertex, preview data, and topology caches is separated.
- **Dirty-region GPU upload**: update only changed chunks through staging/ring buffers to
  device-local buffers. Whole-mesh reupload per stroke is a first-slice shortcut, not a high-poly
  architecture.
- **Numeric gates**: define polygon tiers, frame-time budget, stroke latency budget, dirty upload
  bytes, chunk counts, memory budget, and selected hardware before claiming high-poly performance.

## Routing Keywords

Use this profile for: sculpt brush, sculpting brush, ZBrush-like sculpting, Mudbox-like sculpting,
Blender sculpt, high-poly sculpt, dense mesh sculpt, Draw brush, Standard brush, Clay brush, Clay
Strips, Smooth brush, Relax brush, Inflate brush, Deflate brush, Grab brush, Move brush, Pinch brush,
Crease brush, Flatten brush, Scrape brush, Mask brush, face set brush, dynamic topology, Dyntopo,
multires sculpt, voxel remesh, Paint BVH, PBVH, brush falloff, pressure sculpting, Wacom sculpting,
stylus sculpting, dirty chunk upload.

## Integration Notes

- Treat Blender as the primary behavior and product-shape donor, not as direct implementation source.
- Write independent C++ tests that describe expected behavior instead of porting Blender internals.
- Pair this profile with [meshoptimizer](meshoptimizer.md), [OpenSubdiv](opensubdiv.md), and
  [Vulkan Memory Allocator](vulkan-memory-allocator.md) when high-poly runtime performance is in
  scope.
- Pair with [Native GUI, HUD, And Editor UI](../native-gui-hud.md) when designing a visible brush
  palette, viewport controls, tablet input, icon/text affordances, or product UI around sculpting.

## Validation Ideas

- Tiny mesh fixtures for each milestone brush: Draw, Smooth, Clay, Inflate, Grab, Pinch/Crease,
  Flatten/Scrape, and Mask.
- GUI interaction fixtures for brush palette selection: repeated selection across every enabled V1
  brush, active-brush text/icon state before and after, latency, and visible viewport cursor/falloff
  update.
- Pointer-mapping fixtures for viewport sculpt strokes: requested screen point, viewport-local point,
  device-pixel ratio, render-target point, camera ray, hit primitive, committed edit center, and
  fresh capture with a test-only marker at requested and committed positions.
- Per-brush tests for pressure, falloff, mask protection, symmetry where applicable, undo/replay,
  bounds, degenerate triangles, and backface or visibility behavior.
- Performance fixtures that report polygon count, chunk count, dirty chunks, dirty upload bytes,
  stroke latency, frame time, memory budget, and selected GPU.
- Visual captures for brush palette availability, active brush state, mask visibility, and high-poly
  performance readback.
- GPL boundary check: assert that no Blender source, brush assets, icons, bundled data, or generated
  copies were imported.

## Caveats

- This is not a permissive code donor. It is a GPL-safe study route.
- Blender's DCC scene context is broader than a standalone sculpt tool; translate only the behavior
  and data-flow contracts that fit the target architecture.
- Brush behavior changes across Blender releases. For major sculpt-tool planning, also run current
  upstream/web research before locking the brush roadmap.
