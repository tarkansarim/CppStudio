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

Use OSTM/background execution when available for automated windowed proof. If the lane cannot
observe the visible surface yet, report that gap before continuing.
