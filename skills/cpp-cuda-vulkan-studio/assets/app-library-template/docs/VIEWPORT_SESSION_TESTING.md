# Viewport Session Testing

This project includes a reusable viewport-session testing lane for interactive GUI and viewport
features. It is mandatory for visible UI, brush, paint, sculpt, groom, timeline, node, gizmo, camera,
or viewport hit-test behavior once the app has those surfaces.

The generated scaffold starts with a fake-host smoke lane so CI can prove the recorder/replayer,
artifact layout, and reports before a real GUI exists. Replace or wrap the fake host with the app's
real `ViewportSessionHost` adapter when the first user-visible interaction lands.

## Runtime Shape

The reusable runtime lives in the core library:

- `include/*/viewport_session.hpp`
- `src/testing/viewport_session.cpp`

The target app owns the concrete host adapter. It should route recorded events through the same code
path as real UI/viewport input and read back committed state such as active tool, focus surface,
viewport geometry, device-pixel ratio, camera state, document revision, render revision, hit point,
and selection when available.

When the app has a real interactive surface, add visible record/stop/replay or equivalent capture
controls in the app, with status text/readback and the latest artifact path. Hidden CLI-only
recording is acceptable for the generated fake-host smoke, but it is not enough for an artist-facing
tool where the user needs to record a repro for the agent.

For GUI-heavy panels, add a numeric control-surface contract beside screenshots. The app or test
host should be able to report each relevant mode's visible, hidden, disabled, and expected controls
with stable id/object name, label, widget/control type, section/dock path, mode predicate,
visible/enabled state and reason, value/range/options, source handler/action, committed model/state
field, runtime/readback field, and last mutation result. Treat visible unbound controls, raw/internal
runtime fields exposed as product UI, duplicate owners, hidden controls with no reachable path,
disabled controls without a reason, and UI-only/backend-only mutations as failing evidence.

## Smoke Lane

After building the app, run:

```bash
scripts/run_viewport_session_smoke.py --build-dir build/dev
```

or call the executable directly:

```bash
build/dev/*_app --viewport-session-smoke --viewport-session-dir artifacts/viewport-sessions/smoke
```

Expected artifacts:

```text
artifacts/viewport-sessions/smoke/
  metadata.json
  events.jsonl
  state_initial.json
  state_final.json
  report.json
  captures/final.ppm
```

## User-Reported Visible Bugs

When the user reports a visible UI or viewport bug, create a before session first. After the fix,
replay the same session or a documented equivalent and compare the reported symptom directly. A
backend-only route, stale screenshot, or self-confirming state field is not enough proof for visible
widget clicks, brush selection, delayed state changes, pointer offsets, viewport hits, or rendered
results.

For user-reported control bugs, compare the before and after control contract in addition to any
captures. The report should prove the same user-facing launcher and mode, list stale controls found
or rejected, and show changed values through the real UI handler into committed state and runtime
readback. Screenshots remain useful for layout and appearance, but they are not the primary proof
that controls are wired, enabled, fresh, or reachable.

Use OSTM/background execution when available for automated windowed proof. If the lane cannot
observe the visible surface yet, report that gap before continuing.

Label execution modes honestly. App-owned replay or OSTM/background runs can be non-disruptive only
when isolated from the user's desktop interaction. Real OS pointer or stylus injection is
`real-input`/intrusive and must not be summarized as offscreen, background, or non-disruptive.

For continuous interactions, record the continuous part of the gesture. A drag, stroke, scrub,
camera orbit, timeline drag, node wire, or gizmo move needs held-button or stylus-contact move
samples, timestamps, pointer/hit/readback along the path, and a visible or semantic delta. A
press/release-only session proves a click or dab, not a continuous tool.

For stroke-like visible bugs, create or replay a human-input UI session through the real
viewport/canvas/widget event path before claiming the behavior works. The session should include
press/contact, multiple held move samples, and release/finalization. The report should compare the
requested pointer path against hit/edit/path coverage or affected elements, and should assert any
reported material, overlay, or product-appearance problem directly. Generic revision changes,
checksums, nonblank screenshots, product-surface scores, backend endpoints, or one-point dab smokes
are supporting evidence only.

Do not collapse product-quality questions into narrower semantic checks. If the user reports stroke
direction and viewport shading, the report needs separate status for stroke direction, hit/edit
coverage, material overlay state, and shading quality. Passing `stroke_tracks_pointer_path` or
`product_material_has_no_debug_overlay` is not enough to claim the visible product result is
acceptable when screenshots still look wrong, flat, depth-like, or placeholder-grade.

If no current scenario can emulate the user's input shape, add the smallest diagnostic route first
and run it as the before proof without changing product behavior. Keep that route as the regression
proof after the fix when the symptom is important enough to prevent recurrence.

If the tool should update while the user is still holding contact, prove that specifically. Sculpt,
paint, groom, terrain, drawing, and live transform tools need a mid-gesture checkpoint after a move
sample and before release where document/render revision, dirty region, semantic trace, or a fresh
capture has already changed. A final after-release capture proves only batched application.
