# Control Contract

## Discovery Before Protocol

Before designing endpoints, inspect:

- current app APIs and state model
- command/action registries, menus, shortcuts, scenario systems, launch flags, schemas, and help
  output
- existing scripts, tests, smoke harnesses, routes, sockets, or CLI commands
- GUI toolkit action objects and enabled/focus/selection rules
- logs, warnings, error channels, and existing state readback

If the app has no semantic command surface, create a minimal typed command dispatcher plus readback.
Keep the first slice narrow.

## Command Contract

Each mutation command should define:

- id, transport path, method, and version
- parameters, required/optional fields, enums, ranges, units, and coordinate spaces
- snap/clamp/quantization behavior
- valid modes, selection/focus requirements, and preconditions
- side effects and affected state
- committed-state readback endpoint
- controlled rejection reasons
- whether no-op is allowed and how it is reported

Mutation success means the committed state satisfies the invariant. If a command is rejected or does
not change the claimed state, do not return broad `ok=true` unless the response explicitly reports a
deliberate no-op.

## Reported GUI Bug Proof Contract

For a user-reported GUI, viewport, canvas, or interactive tool bug, the harness proof must be shaped
like the report instead of a nearby automation success.

Before changing code, record:

- the closest user-equivalent path available: launch command, scenario id, menu/action dispatch,
  button click, shortcut, palette selection, pointer drag, stylus event, or approved window-event
  bridge
- the exact input sequence and target surface
- app state, UI state, logs/warnings/errors, and capture path or visual artifact that demonstrate
  the symptom
- the failing assertion, metric, or observation stated in the user's terms

After changing code, rerun the same path or document why the replacement path is equivalent. Record
the same evidence fields and compare before and after against the reported symptom. A fix is not
ready to present when the proof is identical before and after, self-confirming, backend-only for a
visible UI bug, or limited to one convenient variant while the report describes a broader family.

For visible selection, hit target, click, drag, brush, stroke, focus, or latency bugs, include
independent event-to-state/readback evidence: input timestamp, dispatch path, event-loop turn or
frame/revision before and after, committed UI/tool/document state, latency when relevant, and fresh
visual/UI evidence or a text-readable surrogate. A scenario that only proves execution or an
internally predicted coordinate path is diagnostic evidence, not proof that the user's GUI bug is
fixed.

For pointer, viewport, and canvas bugs, compare the requested pointer target with the committed edit
or hit result. Include widget geometry, viewport-local point, device-pixel ratio, framebuffer or
render-target point, ray/canvas transform or hit-test result when available, committed world or
document-space point, and a fresh visible result or marker overlay when practical.

## Transport Contract

Use one semantic command layer behind any transport.

Transports own:

- local-only binding and dev/test gating
- request framing and schema validation
- request ids and response envelopes
- startup readiness and health checks
- timeouts, cancellation, disconnect handling, and retry-safe errors
- clear distinction between malformed request, transport failure, and app-side rejection

The app command layer owns:

- main/render/UI-thread handoff
- state mutation and invariant checks
- committed-state readback
- scenario orchestration and cleanup

## Control Registry

Maintain `docs/AGENTIC_CONTROL.md` and optionally `docs/AGENTIC_CONTROL.json`.

Include:

- launch modes and environment variables
- port or transport discovery
- local-only safety policy
- endpoint or command table
- discovered APIs/actions/scripts each command wraps
- constraints and rejection reasons
- curl/CLI examples
- state/log/UI/visual readback
- scenario tests
- unsupported or intentionally hidden controls

Before committing route changes, reconcile registered routes with the registry. A documented endpoint
that is not registered, or a registered endpoint absent from the registry, is a harness drift bug
unless it is explicitly internal.
