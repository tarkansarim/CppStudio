# Native Agentic Control Harness Reference

This reference adapts practical harness-building patterns for CppStudio native C++ GPU projects.
Use it as a design checklist, not as fixed endpoint names.

## Discovery Before Protocol

Before choosing concrete APIs, routes, enum values, launch modes, or command arguments, establish
them from evidence. The first harness design step is discovery, not endpoint naming.

Inventory these sources before designing controls:

- current project code and existing app architecture
- official docs for libraries, SDKs, GUI frameworks, or host applications
- runtime introspection, help output, schemas, or tiny live probes
- existing working tools, smoke tests, or scripts in the target repo
- command/action registries, menu/shortcut/tool definitions, launch flags, config schemas, and
  scenario systems already present in the app
- GUI toolkit objects that define enabled state, focus requirements, attachment points, action
  targets, or modal/dialog constraints

Do not hardcode plausible values from memory when the app can expose the actual valid set. If a fact
is still uncertain, mark it as unverified and keep the first slice narrow.

Discovery should produce a small control inventory before implementation:

- launch modes and readiness signals
- existing transport surfaces, ports, sockets, scripts, or command adapters
- commands/actions that can be wrapped directly
- state/readback APIs that already exist
- missing readback needed before mutation success can be claimed
- constraints, modes, hidden UI prerequisites, and unsupported controls

If the project has no discoverable command surface, make the first slice a minimal, typed command
dispatcher plus readback path. Keep the endpoint names generic and derive parameter values from the
app's real model, not from guessed UI labels.

## Constraint Mapping

Every mutation surface needs a constraint map. Keep it in the control registry, generated schema, or
endpoint documentation so agents can discover valid commands without reverse-engineering source.

Map these fields when they apply:

- parameter type and required/optional status
- accepted enum values and aliases
- numeric ranges, units, coordinate spaces, and precision
- snap, quantization, rounding, and clamp behavior
- valid app modes, edit modes, selection state, focus state, active tool, and active document/scene
- preconditions such as loaded asset, initialized renderer, available device, or unlocked timeline
- command validity rules, rejection reasons, and whether the command can be a deliberate no-op
- side effects and affected state/readback endpoints
- hidden UI/toolkit constraints such as disabled actions, modal dialogs, focus capture, invisible
  panels, menu attachment, or command target ambiguity

Mutation responses should report both requested input and committed state when validation changes
the result. Tests should assert the committed state after snap/clamp/quantization, not raw input
arithmetic. Invalid commands should return controlled app-side errors with machine-readable reason
codes; transport errors should remain visibly separate from command rejection.

## Transport Bridge Principles

Keep transport behavior boring and reproducible. HTTP, TCP sockets, CLI wrappers, and any higher-level
facade should bridge into the same semantic app command layer instead of each implementing its own
version of a command.

Transport adapters own:

- local-only binding and developer/test gating
- request framing, schema validation, request ids, response envelopes, and version fields
- startup readiness and health checks
- timeouts, cancellation, disconnect handling, and retry-safe error reporting
- clear distinction between malformed requests, transport failures, and app-side command rejection
- structured stdout/stderr or JSON output for scripts and CLI adapters

The app command layer owns:

- main/render thread routing or serialized command queue handoff
- command preconditions and constraint enforcement
- state mutation and invariant checks
- committed-state readback
- scenario orchestration and cleanup

Do not use transport convenience as a reason to expose shell execution, arbitrary file access,
dynamic code execution, or remote network control. If a TCP or socket bridge is used, it should keep
the same local-only safety posture, schema discipline, and app-side invariant checks as the HTTP
surface.

## Recommended Shape

For most native C++ GPU apps, start with:

- a localhost-only HTTP server or local command adapter compiled only into dev/test builds
- curl examples for every endpoint or command
- a small optional MCP adapter that wraps the same stable control API
- a machine-readable registry for launch/control surfaces
- scenario commands that can run deterministic smoke flows
- observation endpoints for state, recent logs/warnings, frame captures, and timing counters
- constraint-schema endpoints or registry entries for command parameters, enums, ranges, modes,
  snap/clamp behavior, and command validity rules

The control layer should stay thin. It should expose app capabilities and state readback, not
hardcode every workflow as separate bespoke code.

The point is agent autonomy. The harness should let agents reproduce, test, inspect, and debug the
running app themselves so the user is not asked to manually verify every small fix. Design the first
milestone around the actions an agent needs to answer: did the app launch, did the feature respond,
what state changed, what warnings appeared, and what is visible in the UI or viewport?

## Safety Defaults

- Bind to `127.0.0.1` by default.
- Avoid shell execution, arbitrary file access, and dynamic code execution.
- Keep release/shipping builds disabled unless the product has a deliberate secure remote-control
  design.
- If network exposure is explicitly requested, require authentication, clear threat modeling, and
  user approval before implementation.
- Log control commands and errors enough for debugging, but do not log secrets or large binary data.

## Threading And App Integration

Network or socket request handling should not run UI, renderer, scene, GPU mutations, visual
capture, or toolkit state readback directly.
Use one of these patterns:

- direct main-thread helper when the app already provides one
- serialized command queue drained from the main loop
- timer/event callback on the GUI thread for toolkits that require it
- explicit command buffer or scenario queue for deterministic frame-step tests

Readback should be clear about whether it returns committed state, queued state, or last completed
frame state. For visual capture endpoints, prefer explicit frame, revision, sequence, or fence
fields that let agents prove a screenshot or render-target dump reflects the requested state. A
capture endpoint that cannot wait for the requested rendered state should return an error with the
target and observed revisions instead of silently returning an older frame.
Before adding waits or render-loop changes, inspect the capture API's timing contract. Some GUI or
graphics capture calls render a fresh offscreen frame as part of the capture operation; in those
cases, the harness should mutate state, call capture, then assert the rendered revision advanced.
Other APIs only copy the last presented frame; those need pre-capture scheduling and settling. If a
capture freshness fix fails repeatedly, pause and classify whether the fault is render scheduling,
capture timing, or test-script order before applying another patch.
After two failed capture, render-scheduling, or command-routing fixes in the same slice, write an
evidence ledger before more edits: failed scenario ids, exact response fields or assertions,
frame/revision/fence progress, artifact freshness, validation/profiler errors, and which recent
patches are proven versus speculative. Revert or isolate speculative edits before the next attempt
unless the evidence shows they are necessary. Continue with either a smaller targeted probe or a
source-level root cause in the app/toolkit/render flow.

## Observation, Or Sonar

Agents need direct evidence instead of guessing from success strings. Plan these observation classes:

- current app/session state
- recent logs, warnings, validation-layer messages, and non-fatal errors
- visual state through screenshot, offscreen frame, render target dump, or deterministic image
  artifact
- UI readback for active mode, focus, selection, visible panels, active modal/dialog, enabled actions,
  menu/shortcut targets, command target, and active document/scene
- performance/timing counters for important passes
- command availability and constraint schemas for the active state

Prefer text-queryable observation where possible. If visual capture reveals an important state, add
a text-readable surrogate later so ordinary automation does not depend on manual image inspection.
Useful surrogates include selected object ids, tool mode, active panel id, timeline frame, viewport
camera state, render revision, last validation warning, last command rejection reason, and enabled
tool/action lists.
When visual output changes after a command, smoke scripts should save the capture response, assert
freshness fields such as `rendered_in_sync`, and then compare screenshots or render targets. A
leftover file or immediate grab after `requestUpdate()` is not enough evidence for realtime apps.

For UI-heavy tools, visual awareness is not optional. The harness should expose enough viewport,
panel, focus, modal, screenshot, and frame-output evidence that an agent can understand what the user
would see on screen for ordinary debugging and regression checks.

## Control Registry

Keep controls discoverable in project docs and, when useful, a small JSON registry.

Recommended `docs/AGENTIC_CONTROL.md` sections:

- launch modes and required environment variables
- transport, port selection, and local-only safety policy
- endpoint or command table
- discovered APIs/actions/scripts that each command wraps
- constraints for parameters, enums, ranges, modes, snap/clamp behavior, and hidden UI requirements
- curl examples
- state/readback surfaces
- UI readback and text-queryable visual surrogates
- scenario smoke tests
- warning/log readback
- known unsupported or intentionally disabled controls

Optional machine-readable fields for `docs/AGENTIC_CONTROL.json` or `TARGET_CONTROL.json`:

```json
{
  "schema_version": 1,
  "transports": [
    {
      "id": "control-http-dev",
      "type": "http",
      "bind": "127.0.0.1",
      "purpose": "local development control"
    }
  ],
  "commands": [
    {
      "id": "load-scene",
      "method": "POST",
      "path": "/control/load-scene",
      "purpose": "load a deterministic test scene",
      "readback": "/state/scene",
      "constraints": {
        "scene_id": {
          "type": "enum",
          "values_source": "/control/schema/load-scene"
        }
      },
      "valid_modes": ["idle", "editing"],
      "mutates": ["scene"],
      "observations": ["/state/scene", "/logs/recent", "/capture/frame"]
    }
  ],
  "observations": [
    {
      "id": "ui-state",
      "path": "/state/ui",
      "includes": ["active_mode", "focus", "selection", "enabled_actions"]
    }
  ]
}
```

## Feature Maintenance Rule

When adding a feature that affects app behavior, rendering, simulation, UI state, assets, or
profiling, update the harness in the same work stream:

- add or extend one control command or scenario path
- update discovery notes when the feature adds or changes app APIs, actions, launch flags, schemas,
  or existing scripts
- update constraints for enum values, numeric ranges, units, modes, snap/clamp behavior,
  preconditions, hidden UI requirements, and rejection reasons
- add state readback or a visual/performance observation surface
- add text-queryable UI/readback surrogates when visual evidence would otherwise be the only proof
- add a curl example
- add a smoke or scenario test when practical
- update the control registry and code map if the target project has one enabled
- update machine-readable roadmap/readiness fields when the slice satisfies a prerequisite. If
  `next_required_slice`, `blockers`, `prerequisites`, readiness booleans, feature eligibility, or
  backend-selection gates are exposed, remove or mark completed items and keep remaining work
  separate from proven work.

If the feature cannot be controlled yet, document the reason and the smallest follow-up needed.

Do not defer harness updates until after several features land. If controls drift behind the app,
agents lose autonomous visibility and will fall back to asking the user to test routine behavior.

## Proof Obligations

For the first harness slice:

- launch through the documented dev/test path
- health check returns a structured response
- one no-op or ping round-trip works
- one real command changes app state
- readback confirms that change
- a deliberate invalid command reports a controlled app-side error
- recent warning/log readback works

For visual or realtime tools, also prove one of:

- screenshot/offscreen frame capture
- render target dump
- deterministic frame artifact
- text-readable UI/viewport state surrogate

For durability after first proof, stress:

- invalid values, unknown enums, missing required fields, and bounded enum discovery
- numeric edge values just inside and outside allowed ranges
- snap, clamp, quantization, coordinate-space, and unit conversion boundaries
- invalid mode, focus, selection, disabled-action, modal-dialog, and hidden-UI-constraint states
- repeated command sequences
- rapid command sequences and cleanup after rejected commands
- startup before the renderer/UI is ready
- transport disconnects, request timeouts, malformed frames, and duplicate request ids
- resize/focus/device-loss-adjacent states when relevant
- warning-heavy scenarios
- partial failure and cleanup
