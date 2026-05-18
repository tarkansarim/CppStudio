---
name: viewport-session-testing
description: "Design, implement, or use app-owned viewport/UI session recording and replay lanes for native C++ GPU tools: record real viewport, stylus, mouse, keyboard, camera, tool, timeline, gizmo, node, and GUI interactions; replay them deterministically; produce before/after reports, screenshots, semantic traces, probes, and OSTM/background proof for visible UI bugs."
---

# Viewport Session Testing

Use this skill when a native C++ GPU app, artist tool, viewer, simulator, editor, or realtime GUI
needs user-equivalent viewport/UI proof instead of backend-only control checks.

This skill complements `agentic-control-harness`. The control harness exposes commands and readback;
viewport session testing records and replays the actual interaction path a user exercises.

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

Backend HTTP/curl commands alone do not satisfy this lane for visible UI bugs. They are useful
supporting evidence, but they do not prove widget focus, visible control clicks, DPI mapping, mouse
or stylus routing, viewport hit tests, or screenshot freshness.

The recorded scenario must match the interaction shape. A click, click-drag, continuous stroke,
scrub, lasso, gizmo drag, camera orbit, timeline drag, node connection, stylus stroke, or palette
selection must be captured and asserted as that shape. For continuous actions, require held-button
or stylus-contact move samples, timestamps, pointer/hit/readback along the path, and a visible or
semantic delta; a single press/release at one point does not prove a stroke or drag.

## User-Reported Visible Bugs

For visible bugs, use before/after evidence shaped like the report.

- Reproduce the bug through the closest user-equivalent path available.
- Save the before session, report, screenshot/render capture, semantic trace, and state readback.
- Apply the fix.
- Replay the same session or a documented equivalent.
- Compare the reported symptom directly.

Do not claim the bug is fixed if before/after artifacts are identical, backend-only, self-confirming,
or narrower than the report. If the lane cannot observe the reported surface, say `I am UI-blind on
this bug` and name the missing recorder, replay, screenshot, hit-test, or UI-state readback.

## What To Load

Read `references/viewport-session-testing.md` before adding or reviewing the lane itself.
