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
  surrogate for what the user is seeing.
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
- failures distinguish transport errors from app-side command errors

After first proof, add stress lanes for partial failures, invalid values, out-of-range values,
unknown enums, snap/clamp boundaries, mode/focus/selection mismatches, repeated commands, rapid
command sequences, startup race conditions, transport disconnects/timeouts, cleanup after rejected
commands, and feature interactions.

## Agent Autonomy Contract

When the target project has an agentic control harness, use it before asking the user to test routine
changes:

1. Launch the app through the documented harness path.
2. Drive the changed feature through curl, CLI, MCP, or scenario controls.
3. Read back state/logs/warnings and capture the relevant visual/UI evidence.
4. Fix harness gaps before treating manual user testing as the only option, when the gap is in scope.
5. Report what the harness proved and what still needs human judgment.
