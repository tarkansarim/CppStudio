---
name: agentic-control-harness
description: "Plan, build, or review local agentic control harnesses for native C++ GPU/realtime apps: localhost HTTP/curl controls, optional MCP facade, launch/control registries, main-thread command routing, state/log/visual observation, endpoint discovery, feature-control maintenance, and autonomous test/troubleshooting lanes. Use when project planning or implementation needs an AI agent to control, test, inspect, debug, or troubleshoot a C++/Vulkan/CUDA GUI, renderer, simulator, artist tool, game tool, or realtime app."
---

# Agentic Control Harness

Use this skill when a native C++ GPU app should be controllable by an AI agent during development,
testing, debugging, profiling, or future feature work. It complements `cppstudio-project-planner`,
`cpp-cuda-vulkan-studio`, and `native-cpp-gui-hud`.

## Default Posture

Hard rule: before touching harness, launcher, control API, UI observation, screenshot, or autonomous
test code, do not rely on training data or intuition as the source of truth. Open this skill's
reference, the relevant CppStudio skill routes, and the smallest matching donor-library categories
for the target app domain first. State which sources ground the control shape before implementation.

If a harness or GUI proof route stalls, do not keep adding scripts, waits, direct launches, or
nearby readback to make the result look green. After two focused attempts or roughly 20 minutes
without proving the actual user-visible symptom changed, stop and realign with the domain donors,
GUI donor route, OSTM/offscreen path, and target code map. Record failed hypotheses, donor facts,
local mismatch, keep/revert decisions for speculative harness patches, and the next smallest proof.
For artist-tool bugs such as brush selection or viewport hit offsets, the harness is insufficient
until it proves the real widget or pointer path the user complained about.

For interactive native apps, tools, viewers, renderers, simulations, and editor-like workflows,
plan an agentic control harness from the first milestone by default. Treat it as default-on unless
the target is a headless library, a security-sensitive product surface, or the user explicitly opts
out.

The harness is the agent's primary control and observation layer for the created app. Agents should
use it to launch, drive, inspect, screenshot, collect logs, and troubleshoot the app themselves
before bothering the user with "please test this" requests. Ask the user to verify only subjective
UX/art direction, hardware-specific feel, or issues that the harness cannot observe.

The main planning question is not whether a harness should exist. The useful questions are:

- Which app APIs, command registries, launch modes, GUI actions, schemas, help output, and existing
  scripts have been discovered before designing any new endpoint or control?
- Which constraints bind each command: enum values, numeric ranges, units, snap/quantization,
  clamp behavior, active modes, selection/focus requirements, command validity, and hidden UI state?
- Which local transport is appropriate: localhost HTTP plus curl, a CLI/script adapter, or both?
- Should an MCP facade wrap the same control API now, or be deferred until the HTTP/curl surface is
  stable?
- Which feature, state-readback, warning/log, visual capture, UI readback, text-queryable surrogate,
  and scenario endpoints are needed for the first milestone?

## What To Load

Read `references/control-harness.md` when the task involves designing, adding, or reviewing the
control harness itself.

## Non-Negotiables

- Do API and control discovery before endpoint design. Inspect the target app's existing public APIs,
  command/action registries, launch flags, schemas, help output, smoke scripts, GUI action objects,
  and runtime introspection first. New routes should wrap known capabilities or explicitly document
  the gap they fill, not invent plausible command names or values from memory.
- Maintain a constraint map for every mutation surface. Record accepted enum values, numeric ranges,
  units, coordinate spaces, snap/quantization rules, clamp behavior, valid modes, required selection
  or focus state, command preconditions, command rejection reasons, side effects, and hidden UI/toolkit
  constraints discovered through source or runtime evidence.
- Keep the first control surface local-only by default: bind to `127.0.0.1`, gate it to developer or
  test builds, and avoid remote exposure unless the user explicitly asks for it.
- Do not make MCP the only way to control the app. Keep curlable HTTP or a similarly simple local
  adapter available so agents and humans can reproduce commands outside a specific MCP runtime.
- Treat HTTP, TCP sockets, CLI adapters, and any higher-level facade as transports over one semantic
  app command layer. Transport code handles framing, schema validation, timeouts, request ids,
  structured errors, startup readiness, and connection failures; app-side command code enforces
  state invariants and reports committed state. Do not duplicate command semantics per transport.
- Prefer one stable, generic command/scenario surface plus typed readback endpoints over a large
  pile of narrow one-off routes.
- Route UI, renderer, scene, and GPU mutations onto the app's safe main/render thread or serialized
  command queue. Keep networking and request parsing off that thread. Treat visual capture and
  toolkit state readback as UI/renderer operations too: do not call window, widget, swapchain,
  `grab()`, `requestUpdate()`, or toolkit action APIs directly from an HTTP/server worker thread.
- Separate mutation from observation. Every meaningful command needs a way to read back state,
  recent output/warnings, and visual evidence when the result is visible.
- For mutation endpoints, define `ok` from the state invariant the endpoint claims to enforce.
  A drag, move, edit, connect, delete, timeline, or scene command that is rejected or does not
  actually change the claimed state must not return `ok=true` unless the endpoint explicitly
  reports a deliberate no-op. Include before/after readback for user-visible mutations.
- For user-reported bugs, use the harness to make "fixed" a before/after comparison, not a nearby
  pass. Reproduce the reported symptom first and store the before evidence under the closest
  user-equivalent path available: launch command, scenario id, exact input sequence, harness state,
  logs, capture path, Sonar readback, metric, or failing assertion. For visible GUI/windowed bugs,
  automated scenario, smoke, screenshot, and proof execution must use `ostm` when the
  offscreen-test-manager skill or CLI is available; otherwise use the target repo's approved
  nonblocking launcher/smoke manager and say OSTM evidence is unavailable. Sonar should verify the
  visible target window when available. Repeated direct foreground app launches are not an approved
  automated GUI proof loop. After changing code, rerun the same scenario or a documented
  equivalent and compare the after evidence against the before evidence in the symptom's own terms.
  If the evidence is identical, self-confirming, backend-only for a UI bug, or covers only one easy
  variant while the report names a broader interaction, the harness proof is insufficient and the
  agent must continue diagnosis instead of asking the user to confirm the fix. When repeated probes
  are needed, use an available Rewind pre-fix checkpoint as the rollback anchor or state that exact
  replay was unavailable before continuing. If the harness cannot currently see or drive the actual
  user-visible UI surface, report "I am UI-blind on this bug:" with the missing observation path
  before doing more implementation. Building another route, endpoint, or proof script is not a user
  bug fix by itself; after one blocked route-building attempt, either repair the specific blocked
  observation path, switch to a bounded app-side root-cause fix with the visual-proof caveat stated
  first, or ask for the smallest manual visible evidence needed.
- When automated GUI/windowed evidence goes through an offscreen/background manager, wait for the
  submitted job to finish and read the produced stdout/stderr, state, screenshots, or artifacts
  before using it as proof. Queued means pending. A script-not-found or relative-path failure in the
  manager context is an invocation failure; rerun once with an absolute script path or explicit
  working directory before treating it as an app failure. Separate what each artifact proves:
  external window screenshot, app-owned screenshot, render-target capture, structured UI state, or
  semantic readback. Do not let one green semantic field stand in for a missing user-visible surface
  when the bug is visual.
- Name readiness and success fields after the exact invariant they prove. Do not let a broad
  readiness boolean stand in for a weaker nearby condition. If the app has a widget, a backend, and a
  live composed capture as separate facts, expose separate fields such as `has_widget`,
  `backend_available`, and `live_capture_composed`; do not return the broad field as true until the
  documented broad invariant is actually satisfied.
- When the app snaps, quantizes, clamps, validates, or otherwise normalizes command input, smoke
  tests and docs must assert the post-validation state instead of raw input arithmetic. Report both
  requested input and committed state when that difference matters.
- Make visual/UI awareness first-class. For viewers, tools, editors, and sandboxes, the harness
  should expose screenshots, offscreen frames, render-target dumps, UI state, or another reliable
  surrogate for what the user is seeing. For visible bugs, the surrogate must be compared with the
  actual visual symptom; a JSON state change, route inventory, or internal revision number cannot
  stand in for a user-facing button, selection, viewport hit, stroke, or rendered result.
- Design observation as sonar, not as decoration. At minimum, expose text-queryable state, recent
  logs, warnings/non-fatal errors, command availability, active mode/focus/selection, and visual or
  UI readback for user-visible changes. When a screenshot or render target is the only evidence for
  a behavior, add a text-readable surrogate as soon as the state can be represented structurally.
- Visual capture must be fresh, not just available. For viewport, canvas, render-target, or
  screenshot endpoints, add frame/revision/sequence/fence readback when practical and make capture
  wait until the requested UI or renderer state has been rendered. If the capture cannot settle on
  the requested state, return a harness error instead of stale pixels. Save and assert capture
  responses in smoke scripts so leftover files cannot masquerade as current visual evidence.
- Audit capture timing before stacking fixes. Some toolkit capture APIs render during the capture
  call rather than before it, while others only grab the last presented frame. Verify the toolkit
  contract, then place freshness checks on the correct side of the capture call. After repeated
  stale-capture failures, stop patching and classify the cause as render scheduling, capture timing,
  or smoke-script order before making the next edit.
- After two failed visual-capture, render-scheduling, or command-routing fixes in the same slice,
  require a hard-reset evidence ledger before more edits: failing scenario ids, exact response fields
  or assertions, frame/revision/fence progress, artifact freshness, validation/profiler errors, and
  a keep/revert decision for each recent speculative patch. Continue only with a smaller targeted
  repro/probe or a source-level root cause in the app/toolkit/render flow.
- For GUI/editor command surfaces, do not rely only on capability metadata that says an action
  exists. When practical, expose readback for the actual UI action/menu/shortcut/context objects,
  enabled state, attachment point, and command target. Claim a menu, shortcut, context action, or
  toolbar path was tested only when it was exercised or introspected by the harness.
- For UI-heavy apps, expose an action/affordance inventory when practical. Include action id, visible
  text, icon presence/name, tooltip, shortcut, surface location, enabled state, command target,
  selected-object requirement, and proof status. Use it to verify that tool controls follow peer-tool
  conventions, especially transport, timeline, viewport, selection, transform, visibility, and
  destructive actions.
- For interactive GUI tools, add real GUI interaction scenarios, not only backend commands. A
  scenario should drive the same input path a user exercises when practical: toolkit action trigger,
  menu/shortcut dispatch, tool-button click, palette selection, timeline drag, viewport mouse/stylus
  press/drag/release, or window-system event injection through the app's approved test path. Backend
  HTTP commands are useful control surfaces, but they do not prove that the visible widget, focus,
  hit target, event routing, or input coordinate transform works.
- For desktop GUI apps, include a human-launch scenario for the documented launch command. It should
  start the exact command nonblocking, capture stdout/stderr, prove the intended app process owns a
  mapped normal window, reject terminal-title or stale-window matches, focus or raise the window when
  that is the launch contract, read back geometry/workspace/visibility, poll the control harness, and
  cleanly stop the specific process or app instance it started. Offscreen smoke and nonblank captures
  are not enough when the user needs the app window to actually appear.
- GUI interaction scenarios need latency and committed-state readback for user-visible controls. For
  tool palette, brush, mode, layer, timeline, selection, and inspector controls, record input
  timestamp, dispatch path, event-loop turn or frame/revision before and after, active UI/tool state,
  and elapsed time. Multi-second delayed selection, delayed visible labels, or state changes that
  only appear after unrelated input are failing GUI behavior even if the backend command eventually
  succeeds.
- User-reported GUI bugs need coverage shaped like the report. If the report says multiple brush
  entries cannot be selected, the scenario must exercise repeated selection across all relevant
  enabled entries or explain why a narrower subset is the only available repro. If the report says a
  pointer or stroke is offset, the scenario must compare requested pointer, committed edit point, and
  visual marker/capture before and after. A single internally chosen click that passes because the
  app clicked the point it predicted for itself is useful diagnostic evidence, but it is not enough
  to claim the user's bug is fixed.
- Viewport and canvas interactions need a pointer-mapping oracle. For click, drag, stroke, pick,
  sculpt, paint, groom, transform, gizmo, node-canvas, or graph-coordinate work, read back the target
  widget geometry, viewport-local point, device-pixel ratio, framebuffer/render-target point,
  camera/ray or canvas transform, hit object/primitive, committed world or document-space point, and
  resulting edit center/selection. If practical, capture a fresh screenshot with a marker or overlay
  at the requested pointer and committed hit/edit position. A stroke that is visibly offset from the
  pointer is not verified by a generic mesh-revision change.
- Maintain a control registry such as `docs/AGENTIC_CONTROL.md` plus optional
  `docs/AGENTIC_CONTROL.json` or `TARGET_CONTROL.json` so future agents can discover controls
  without reverse-engineering the app. Include discovered commands, transports, constraints,
  observation surfaces, state invariants, and known unsupported or intentionally hidden controls.
- Reconcile the control registry with the registered runtime routes before committing route changes.
  When adding, removing, or renaming endpoints, compare the code's route registration table or router
  setup against the top discovery list, detailed endpoint docs, examples, and optional JSON inventory.
  A documented endpoint that is not registered, or a registered endpoint that is absent from the
  registry, is a harness drift bug unless it is explicitly internal and hidden by policy.
- Keep machine-readable roadmap and readiness fields honest. When a control endpoint or registry
  exposes `next_required_slice`, `blockers`, `prerequisites`, readiness flags, feature eligibility,
  or backend-selection gates, every verified slice that satisfies one item must update the readback
  before commit. If a broad gate name remains, also expose completed and remaining prerequisites so
  future agents do not rework an already-proven slice.
- Every new user-visible feature should update the control surface, curl examples, scenario tests,
  and code-map docs when the project has an enabled code map.

## Proof Before Claiming It Works

A first harness slice is only provisionally successful when these are verified:

- the app launches through the documented dev/test path
- the control surface is reachable
- a trivial round-trip works
- one real feature command mutates the app and has state readback
- mutation success requires readback of the committed state, including snapped/clamped values when
  applicable, not only a boolean response field
- the command's discovered constraint map is documented or queryable, and tests assert at least one
  representative valid path plus one controlled rejection when practical
- readiness/success fields are named and tested against their exact documented invariants, not weaker
  nearby conditions
- registered routes match the documented control registry or any intentional internal-only routes are
  explicitly named as hidden
- recent logs or warnings are queryable
- visual state can be captured or otherwise inspected for viewport/UI-heavy apps, with settled-state
  evidence for mutable viewport/canvas/render output when practical
- UI-heavy state has text-queryable readback or a documented surrogate for active mode, focus,
  selection, action availability, and relevant panel/dialog state
- UI-heavy command surfaces expose action/affordance inventory when practical, including icon/text,
  tooltip, shortcut, location, enabled-state, and proof status
- user-visible GUI actions added in the slice have either scenario coverage or action/readback
  evidence from the real toolkit objects; metadata-only assertions are labeled as such
- user-visible GUI fixes for clicks, selections, drags, or viewport strokes include an interaction
  scenario that exercises the real GUI event path, records event-to-committed-state latency, and
  proves the visible widget/action state changed without relying on unrelated later input
- user-reported bug fixes include matching before/after evidence for the exact reported symptom; a
  fix is not ready to present when the after scenario is identical to the before scenario or covers a
  narrower, self-confirming path
- viewport/canvas hit or stroke fixes include a pointer-mapping readback with widget geometry,
  device-pixel ratio, local/render-target coordinates, picked ray or canvas transform, committed
  hit/edit point, and fresh visual evidence when practical
- failures distinguish transport errors from app-side command errors

After first proof, add stress lanes for partial failures, invalid values, out-of-range values,
unknown enums, snap/clamp boundaries, mode/focus/selection mismatches, repeated commands, rapid
command sequences, rapid GUI clicks/drags, startup race conditions, transport disconnects/timeouts,
cleanup after rejected commands, and feature interactions.

## Agent Autonomy Contract

When the target project has an agentic control harness, use it before asking the user to test routine
changes:

1. Launch the app through the documented harness path.
2. Drive the changed feature through curl, CLI, MCP, or scenario controls.
3. Read back state/logs/warnings and capture the relevant visual/UI evidence.
4. Fix harness gaps before treating manual user testing as the only option, when the gap is in scope.
5. Report what the harness proved and what still needs human judgment.
