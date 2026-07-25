# Native App Harness Patterns

Use this for desktop apps, native GUI tools, renderers, games, realtime simulations, and viewport
applications.

## Recommended Shape

- local-only HTTP server, CLI adapter, or both in dev/test builds
- stable launch script with port/control discovery
- command queue drained on the app's safe main/UI/render thread
- scenario runner for deterministic smoke flows
- state endpoints for active mode, document/scene id, selected object, timeline frame, viewport
  camera, enabled actions, and last command result
- logs/warnings/errors endpoint
- screenshot/frame capture endpoint for visual apps
- optional MCP facade wrapping the same command layer

## Threading

Network/server threads should not directly mutate UI, renderer, GPU, scene, toolkit, or swapchain
state. Use:

- main-thread helper
- serialized command queue
- toolkit timer/event callback
- render-loop scenario queue

Readback must say whether it reports queued state, committed state, or last-rendered frame state.

## UI And Renderer Readback

For tool/editor apps, expose action or affordance inventory when practical:

- action id
- visible text
- icon presence/name
- tooltip
- shortcut
- surface location
- enabled state
- command target
- selected-object requirement
- proof status: exercised, introspected, screenshot-only, or metadata-only

For visual output, expose freshness fields such as `requested_revision`, `rendered_revision`,
`frame_index`, `capture_path`, or `rendered_in_sync`.

## GUI Bug Scenarios

Reported GUI bugs need interaction scenarios that exercise the same class of visible path the user
reported. Backend commands can support setup and cleanup, but they do not prove that visible
widgets, focus, hit targets, coordinate transforms, or event routing work.

For selection, palette, mode, toolbar, menu, shortcut, timeline, layer, brush, inspector, or focus
bugs, scenario evidence should include:

- the real toolkit action, button click, menu dispatch, shortcut, or approved window event used
- enabled/visible state and target surface before input
- input timestamp plus event-loop turn or frame/revision before and after
- active UI/tool/document state before and after
- latency from dispatch to committed visible state when relevant
- fresh screenshot/UI readback or a text-readable surrogate for the visible result

For viewport, canvas, stylus, stroke, pick, transform, or graph-coordinate bugs, scenario evidence
should include the pointer-mapping oracle:

- screen point, target widget geometry, viewport-local point, and device-pixel ratio
- framebuffer or render-target point when available
- camera ray, canvas transform, hit object, primitive, UV/barycentric, or graph coordinate when
  available
- committed world/document-space hit or edit point
- fresh visible result, marker overlay, or text-readable surrogate that compares requested pointer
  target with committed result

If the report names a family of interactions, such as multiple brush entries that cannot be
selected, exercise the relevant enabled entries or state why the available repro is narrower. Do not
present a fix from one convenient click, self-consistent pointer math, backend-only state, or an
after artifact that is identical to the before artifact.

## Smoke Scenario

The first smoke should:

1. launch the app
2. wait for readiness
3. run a harmless semantic mutation
4. read back committed state
5. read recent logs/warnings/errors
6. capture visual output if relevant
7. shut down or leave the app in a documented state

Do not ask the user to manually verify ordinary launch/mutation/readback paths until this smoke lane
has been attempted.
