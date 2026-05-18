# Viewport Session Testing Reference

This reference defines the reusable lane CppStudio projects should scaffold for interactive native
C++ GPU apps.

## Runtime Shape

Generated projects should provide a small app-owned adapter, usually named like
`ViewportSessionHost`, with these responsibilities:

- dispatch recorded events through the same code path as real UI/viewport input
- expose active tool, focus surface, viewport geometry, device-pixel ratio, camera state, document or
  scene revision, and render revision when available
- capture screenshots or render targets with freshness fields
- expose app-specific probes such as pointer hit point, selected object, brush edit center, gizmo
  transform, node link, timeline frame, particle count, or validation warning

The generic runtime owns serialization, replay order, reports, and fake-host smoke tests. The target
app owns meaning.

## Session Artifacts

Use ignored artifacts by default:

```text
artifacts/viewport-sessions/<scenario-id-or-timestamp>/
  metadata.json
  events.jsonl
  state_initial.json
  state_final.json
  report.json
  captures/
  traces/
```

Record enough data for another agent to replay the same user path after compaction:

- event time, type, input surface, cursor/screen point, viewport-local point, render-target point,
  device-pixel ratio, button/key/modifier state, stylus pressure/contact/tilt/twist, and notes
- active tool, mode, selection, layer, focus, camera, viewport size, and document/render revision
- semantic trace fields for the domain being edited
- command line, environment-relevant launch mode, app version/commit when available, and warnings

## Scenario Grammar

The first generic schema may stay small, but it must be explicit:

- `wait`
- `mouse_move`
- `mouse_press`
- `mouse_release`
- `key_press`
- `tool_change`
- `camera_state`
- `snapshot`
- `probe`
- `assert_state`

Projects can extend the event payload, but should not replace the generic fields. Extra fields go in
an app-specific `payload` or trace file.

## Replay Rules

- Replay events in timestamp order through the real app path.
- Keep a fixed scenario clock when possible.
- Separate transport errors from app-side command rejection.
- Record before and after state in the report.
- Save fresh visual captures when a visible result matters.
- If OSTM is available, route automated windowed/background proof through it.
- If live input may interfere, suppress it during replay or report that deterministic replay is not
  available.

## Before/After Bug Proof

For reported UI or viewport bugs, the lane must prove the symptom changed:

- selection bugs: exercise the visible control or palette entries the user named and measure
  input-to-committed-state latency
- pointer or stroke offsets: compare requested pointer, viewport-local point, hit ray, committed
  edit point, and fresh capture marker when practical
- delayed UI updates: record event timestamp, event-loop/render revision, and time to visible or
  queryable state
- launch bugs: prove the documented command owns the intended visible app window, not a terminal or
  stale window

If the before/after comparison is not comparable, the fix is not proven.

## Generated Template Expectations

CppStudio generated projects should include:

- runtime header/source for the host adapter and recorder/replayer helpers
- fake-host smoke coverage so CI can validate the lane without a real GUI
- CLI or script entrypoint to run the smoke lane and write `report.json`
- docs explaining how to replace the fake host with the real app adapter
- code-map routing for runtime, docs, tests, scripts, and artifacts policy
