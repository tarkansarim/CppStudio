# Native Agentic Control Harness Reference

This reference adapts practical harness-building patterns for CppStudio native C++ GPU projects.
Use it as a design checklist, not as fixed endpoint names.

## Discovery Before Protocol

Before choosing concrete APIs, routes, enum values, launch modes, or command arguments, establish
them from evidence:

- current project code and existing app architecture
- official docs for libraries, SDKs, GUI frameworks, or host applications
- runtime introspection, help output, schemas, or tiny live probes
- existing working tools, smoke tests, or scripts in the target repo

Do not hardcode plausible values from memory when the app can expose the actual valid set. If a fact
is still uncertain, mark it as unverified and keep the first slice narrow.

## Recommended Shape

For most native C++ GPU apps, start with:

- a localhost-only HTTP server or local command adapter compiled only into dev/test builds
- curl examples for every endpoint or command
- a small optional MCP adapter that wraps the same stable control API
- a machine-readable registry for launch/control surfaces
- scenario commands that can run deterministic smoke flows
- observation endpoints for state, recent logs/warnings, frame captures, and timing counters

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

## Observation, Or Sonar

Agents need direct evidence instead of guessing from success strings. Plan these observation classes:

- current app/session state
- recent logs, warnings, validation-layer messages, and non-fatal errors
- visual state through screenshot, offscreen frame, render target dump, or deterministic image
  artifact
- performance/timing counters for important passes
- active modal/dialog/focus state for GUI tools

Prefer text-queryable observation where possible. If visual capture reveals an important state, add
a text-readable surrogate later so ordinary automation does not depend on manual image inspection.
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
- curl examples
- state/readback surfaces
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
      "readback": "/state/scene"
    }
  ]
}
```

## Feature Maintenance Rule

When adding a feature that affects app behavior, rendering, simulation, UI state, assets, or
profiling, update the harness in the same work stream:

- add or extend one control command or scenario path
- add state readback or a visual/performance observation surface
- add a curl example
- add a smoke or scenario test when practical
- update the control registry and code map if the target project has one enabled

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

- invalid values and bounded enum discovery
- repeated command sequences
- startup before the renderer/UI is ready
- resize/focus/device-loss-adjacent states when relevant
- warning-heavy scenarios
- partial failure and cleanup
