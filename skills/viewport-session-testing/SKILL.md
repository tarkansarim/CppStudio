---
name: viewport-session-testing
description: "Design or use app-owned viewport/UI session replay for native C++ tools: real gestures, screenshots, traces, and visible bug proof."
---

# Viewport Session Testing

Use this skill when a native C++ GPU app, artist tool, viewer, simulator, editor, or realtime GUI
needs user-equivalent viewport/UI proof instead of backend-only control checks.

This skill complements `agentic-control-harness`. The control harness exposes commands and readback;
viewport session testing records and replays the actual interaction path a user exercises.

## Discovery Details

Load this skill to design, implement, or use app-owned viewport/UI session recording and replay lanes
for native C++ GPU tools: record real viewport, stylus, mouse, keyboard, camera, tool, timeline,
gizmo, node, and GUI interactions; replay them deterministically; produce before/after reports,
screenshots, semantic traces, probes, and OSTM/background proof for visible UI bugs.
Use gui_run_scenario-style proof when the project already has that scenario lane.

## Grounding Donors

Use these proven local donor patterns before designing a new lane:

- A realtime grooming-style session recording/replay lane: timestamped session folders, metadata,
  UI/camera/scene snapshots, input events, stylus fields, semantic brush traces, playback state
  restore, final frame output, and replay diagnostics.
- A paint/simulation-style GUI scenario lane: scenario grammar, step inserts, inherited scenarios,
  probes/assertions, baseline comparison, reports, timing ledgers, Linux/Windows wrappers, and
  background/offscreen presentation modes.

Do not copy app-specific donor code into reusable templates. Extract the pattern:
generic host adapter, typed event schema, app-owned dispatch, fresh visual capture, semantic traces,
and machine-readable reports.

## Mandatory For Interactive Projects

For interactive viewport or GUI projects, plan this lane from the first milestone unless the target
is a headless library or the user explicitly opts out.

Minimum lane:

- session record command
- session replay command
- visible record/stop/replay or equivalent capture affordance in the app, with status and artifact
  path once the first user-facing interactive surface exists, unless the target is headless or the
  user explicitly accepts a CLI-only tool surface
- app-owned host adapter that routes events through the real UI/viewport path
- state snapshots for tool, focus, viewport geometry, camera, scene/document revision, and render
  revision when available
- screenshots or render-target captures with freshness fields
- semantic trace for the edited domain, such as brush strokes, hit points, gizmo moves, node links,
  timeline edits, selected objects, or simulation probes
- `report.json` with scenario id, command line, pass/fail, before/after state, artifacts, assertions,
  warnings, and failure reason

User-facing verification is the acceptance surface for this lane. Fake-host smokes, hidden CLI
recorders, backend commands, JSON state changes, and nonblank captures prove infrastructure only.
They do not prove that a user can find the control, start a recording, perform the intended gesture,
stop/replay the session, and see the result in the product surface.

Do not collapse separate visible concerns into one narrower proof. If a user reports or asks about
stroke direction, hit location, selection response, material appearance, viewport shading, overlay
state, or product-surface quality, each concern must be listed in closeout as `resolved`,
`unresolved`, or `not-tested` with its own matching evidence. Semantic path coverage, revision
advance, changed vertices, or "no debug overlay" readback can prove a functional subclaim, but it
does not prove that the visible result reads correctly to a human or that the material/shader quality
matches the product target. If the screenshots still look wrong, flat, debug-like, depth-pass-like,
or too crude for the requested tool, report that as an unresolved product-quality issue instead of
moving to the next feature slice.

Backend HTTP/curl commands alone do not satisfy this lane for visible UI bugs. They are useful
supporting evidence, but they do not prove widget focus, visible control clicks, DPI mapping, mouse
or stylus routing, viewport hit tests, or screenshot freshness.

For product-facing parameter controls, the session or equivalent toolkit probe must prove the
control is wired, not only present. Mutate the visible slider, button, menu, choice, color picker, or
inspector row through the same UI handler a user exercises, then compare before/after visible
control value, committed model/state, and runtime/readback field. Model-only setters, static
signal-slot inspection, UI JSON inventories, control counts, or screenshots without a changed value
are not enough. For large inspector surfaces, pair a complete inventory with mutation proof for all
newly added or changed critical controls and representative proof for repeated control classes; mark
unmutated controls as deferred, blocked, not-tested, or intentionally hidden.

For GUI-heavy tools, make that inventory a numeric control-surface contract. Each scenario or
toolkit probe should be able to report the relevant panel's controls as data: stable id/object name,
label, widget/control type, section/dock path, mode predicate, visible/enabled state and reason,
value/range/options, source handler/action, committed model/state field, runtime/readback field, and
last mutation result. The report must fail or flag stale controls: visible but unbound, disabled
without reason, hidden with no reachable path, duplicate/conflicting owner, raw/internal runtime
payload leaking into product UI, or mutation that changes only the UI widget or only backend state.
Screenshots remain useful for layout, occlusion, and product look, but they are secondary to the
control contract for proving control freshness and wiring.

Be precise about execution mode. OSTM/background window ownership, app-owned replay, and real OS
pointer/stylus injection are different proof modes. If a lane uses real input that can move focus or
the user's pointer, label it as `real-input`/intrusive and do not describe it as offscreen,
background, or non-disruptive. Offscreen/background claims are allowed only when the run is actually
isolated from the user's visible desktop interaction.

The recorded scenario must match the interaction shape. A click, click-drag, continuous stroke,
scrub, lasso, gizmo drag, camera orbit, timeline drag, node connection, stylus stroke, or palette
selection must be captured and asserted as that shape. For continuous actions, require held-button
or stylus-contact move samples, timestamps, pointer/hit/readback along the path, and a visible or
semantic delta; a single press/release at one point does not prove a stroke or drag.

For stroke-like visible bugs, the agent must create or replay a human-input UI session before
claiming the behavior works. The session must drive the real viewport/canvas/widget event path with
press/contact, multiple held move samples, and release/finalization. It must record the requested
pointer path, viewport-local/render-target coordinates, device-pixel ratio, ray or hit points when
applicable, committed edit points or affected element/path coverage, and fresh before/mid/after
captures. Assertions must name the reported symptom, such as `stroke_tracks_pointer_path`,
`brush_hit_matches_cursor`, `selection_changes_with_click`, `drag_updates_before_release`, or
`product_material_has_no_debug_overlay`. A generic state/revision/checksum change, nonblank
screenshot, product-surface score, or one-point dab smoke is infrastructure evidence only and must
be rejected as closeout proof for a stroke, drag, hit-test, selection, or material-appearance bug.
For material or shading complaints, `product_material_has_no_debug_overlay` only proves that a debug
overlay is absent; it does not prove production-quality shading. A shading closeout needs a
donor-backed target look, fresh captures, and readback/assertions tied to the actual appearance
standard being claimed.

For continuous tools whose visible result is expected to update while contact is held, such as
sculpting, painting, grooming, terrain editing, grease-pencil style drawing, or live gizmo drags, the
scenario must include a pre-release proof point. After one or more held-contact move samples and
before the release event, read back a changed document/render revision, dirty region, semantic trace,
or fresh capture. A final after-release before/after proves only batched application and must not be
accepted as proof of live interaction feedback.

## User-Reported Visible Bugs

For visible bugs, use before/after evidence shaped like the report.

- Reproduce the bug through the closest user-equivalent path available.
- Save the before session, report, screenshot/render capture, semantic trace, and state readback.
- Apply the fix.
- Replay the same session or a documented equivalent.
- Compare the reported symptom directly.

If the project does not yet have a scenario that emulates the user's input shape, add the smallest
diagnostic UI-session route first and run it as the before proof. That diagnostic route must not
change product behavior before the before run. It should become a reusable regression lane after the
fix when the symptom is important enough to prevent recurrence.

Do not claim the bug is fixed if before/after artifacts are identical, backend-only, self-confirming,
or narrower than the report. If the lane cannot observe the reported surface, say `I am UI-blind on
this bug` and name the missing recorder, replay, screenshot, hit-test, or UI-state readback.

## What To Load

Read `references/viewport-session-testing.md` before adding or reviewing the lane itself.
