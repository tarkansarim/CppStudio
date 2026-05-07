# Blender Curves Groom Brushes Study-Only Donor Profile

Sources: https://github.com/blender/blender/tree/main/source/blender/editors/sculpt_paint/curves https://docs.blender.org/manual/en/latest/sculpt_paint/curves_sculpting/index.html https://docs.blender.org/api/current/bpy_types_enum_items/brush_curves_sculpt_brush_type_items.html
Tier: `study-only`
Backend signal: native-cpu, dcc-interchange, mixed-backend
License signal: Blender source is GPL-family. This profile is for behavior extraction, UX contracts,
data-flow notes, and tests only. Do not copy Blender source into permissive CppStudio templates or
target projects unless that project explicitly accepts GPL-compatible reuse.

## Use First For

- Artist-facing groom brush design: add, delete, density, comb, snake hook, grow/shrink, pinch, puff,
  smooth, slide, and selection-paint style behavior.
- Translating DCC hair-curve sculpting into independent C++/Vulkan/CUDA tools without copying GPL
  implementation.
- Brush stroke contracts: pressure-modulated radius/strength, screen-space versus 3D falloff,
  symmetry, point/curve selection masks, root/surface binding, undoable stroke operations, and dirty
  geometry notification.
- Planning groom-tool validation: tiny curve fixtures, surface-bound roots, pressure/falloff tests,
  add/remove density tests, and visual regression frames for brush verbs.

## Source Files Studied

- `source/blender/editors/sculpt_paint/curves/sculpt_ops.cc`: brush-stroke operator dispatch, brush
  type selection, pressure/radius/strength plumbing, and sculpt-mode operators.
- `source/blender/editors/sculpt_paint/curves/sculpt_intern.hh`: shared stroke extension,
  `CurvesSculptStrokeOperation`, and factory declarations for each brush operation.
- `source/blender/editors/sculpt_paint/curves/sculpt_brush.cc`: shared sampling helpers for 2D/3D
  brush placement and remembered stroke position.
- `source/blender/editors/sculpt_paint/curves/sculpt_add.cc`: surface sampling, root placement,
  front-face filtering, UV sampling, and generated curve initialization.
- `source/blender/editors/sculpt_paint/curves/sculpt_delete.cc`: selected curve removal under a
  screen-space or 3D brush.
- `source/blender/editors/sculpt_paint/curves/sculpt_density.cc`: density add/remove mode choice,
  root-distance queries, KD-tree spacing checks, and deterministic density editing requirements.
- `source/blender/editors/sculpt_paint/curves/sculpt_comb.cc`: stroke-drag deformation, per-point
  radius falloff, curve-parameter falloff, length constraint solving, and screen/3D brush variants.
- `source/blender/editors/sculpt_paint/curves/sculpt_snake_hook.cc`: tip dragging with resampling of
  the rest of the curve.
- `source/blender/editors/sculpt_paint/curves/sculpt_grow_shrink.cc`: length editing through shrink,
  extrapolate, and uniform scale effects with a minimum-length guard.
- `source/blender/editors/sculpt_paint/curves/sculpt_pinch.cc`: attraction/repulsion around the brush
  with selection, radius falloff, and constraint solving.
- `source/blender/editors/sculpt_paint/curves/sculpt_puff.cc`: aligning curves toward the attached
  surface normal while preserving root anchoring and avoiding fold-up artifacts.
- `source/blender/editors/sculpt_paint/curves/sculpt_smooth.cc`: interior-point smoothing toward
  neighboring points with brush-weighted influence.
- `source/blender/editors/sculpt_paint/curves/sculpt_slide.cc`: sliding roots over the bound surface
  using surface UVs, evaluated/original surface data, and per-curve stroke state.
- `source/blender/editors/sculpt_paint/curves/sculpt_selection_paint.cc` and
  `sculpt_selection.cc`: soft selection and selection-paint behavior for brush masking.

## Extracted Brush Contracts

- **Common stroke model**: create one stroke operation at stroke start, extend it for each sampled
  mouse/tablet event, route pressure into brush size and strength, and keep `normal`, `invert`,
  `smooth`, and `erase` style stroke modes explicit.
- **Brush influence**: combine brush radius falloff, brush strength, per-point or per-curve selection
  factors, and optional curve-parameter falloff before mutating positions or curve sets.
- **Projected versus spherical brush**: support both screen/projected strokes and 3D brush placement.
  The target tool should record which mode each brush uses because it changes picking, tests, and
  visual expectations.
- **Root and guide ownership**: keep root placement, surface attachment, guide/follow interpolation,
  and render/simulation buffers separate. Brush code should mutate source groom curves, then mark
  derived buffers dirty.
- **Length preservation**: comb and related deformation brushes need a post-edit constraint solve or
  resampling strategy so strokes do not silently stretch/fold strands.
- **Surface binding**: add, density, slide, and puff are surface-aware. They need evaluated-surface
  reads, UV or barycentric data when available, nearest-surface queries, and clear behavior when no
  valid surface exists.
- **Density editing**: density should be a spacing-aware operation, not random curve add/delete. Track
  minimum distance, root KD-trees or equivalent spatial indices, and deterministic fixture behavior.
- **Undo and dirtiness**: each brush mutation must be undoable and must invalidate only the affected
  groom-derived data: viewport buffers, simulation guides, acceleration structures, density grids, and
  interchange/export caches.

## Routing Keywords

Use this profile for: groom brush, grooming brush, comb brush, strand brush, hair sculpt, curve
sculpt, guide sculpt, guide brush, clump brush, parting brush, cut brush, trim brush, length brush,
grow shrink, puff brush, smooth brush, slide brush, density brush, add/delete hair, soft selection,
mask/freeze groom, stylus pressure grooming, screen-space grooming, surface-bound groom editing,
undoable groom strokes.

## Integration Notes

- Treat Blender as a product-shape and behavior donor, not a direct code donor.
- Recreate behavior contracts independently in the selected target lane. For Vulkan-first tools, keep
  CPU brush authoring, GPU buffer upload, Vulkan rendering, and optional CUDA compute separate.
- Pair this profile with [AMD TressFX](tressfx.md) for permissive realtime strand simulation/rendering
  structure, [OpenUSD](openusd.md) or [Alembic](alembic.md) for interchange, and
  [Unreal HairStrands Study-Only](unreal-hairstrands-study-only.md) for runtime groom architecture.
- For UI widgets, timeline, inspector, stylus controls, or viewport overlays, also open
  [Dear ImGui Tooling Stack](imgui-tooling.md) or the native GUI/HUD category selected by the project.

## Validation Ideas

- Tiny groom fixture with a bound surface, a few guide curves, a soft selection mask, and deterministic
  stroke samples.
- Per-brush tests for affected curve count, root immobility when required, minimum length, minimum
  density spacing, and dirty-buffer propagation.
- Pressure tests proving radius and strength change independently.
- Visual regression frames for comb, grow/shrink, pinch, puff, smooth, density add/remove, and slide.
- GPL boundary check: assert that no Blender source, brush assets, icons, or bundled data were copied.

## Caveats

- This is not a permissive code donor. It is a GPL-safe study route.
- Blender's DCC scene/evaluation model is broader than a standalone groom tool. Translate only the
  behavior contracts that fit the target architecture.
- Some brushes depend on surface UVs, evaluated deformation, or editor-specific selection state. Make
  those dependencies explicit before implementation.
