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

- Which local transport is appropriate: localhost HTTP plus curl, a CLI/script adapter, or both?
- Should an MCP facade wrap the same control API now, or be deferred until the HTTP/curl surface is
  stable?
- Which feature, state-readback, warning/log, visual capture, and scenario endpoints are needed for
  the first milestone?

## What To Load

Read `references/control-harness.md` when the task involves designing, adding, or reviewing the
control harness itself.

## Non-Negotiables

- Keep the first control surface local-only by default: bind to `127.0.0.1`, gate it to developer or
  test builds, and avoid remote exposure unless the user explicitly asks for it.
- Do not make MCP the only way to control the app. Keep curlable HTTP or a similarly simple local
  adapter available so agents and humans can reproduce commands outside a specific MCP runtime.
- Prefer one stable, generic command/scenario surface plus typed readback endpoints over a large
  pile of narrow one-off routes.
- Route UI, renderer, scene, and GPU mutations onto the app's safe main/render thread or serialized
  command queue. Keep networking and request parsing off that thread. Treat visual capture and
  toolkit state readback as UI/renderer operations too: do not call window, widget, swapchain,
  `grab()`, `requestUpdate()`, or toolkit action APIs directly from an HTTP/server worker thread.
- Separate mutation from observation. Every meaningful command needs a way to read back state,
  recent output/warnings, and visual evidence when the result is visible.
- Make visual/UI awareness first-class. For viewers, tools, editors, and sandboxes, the harness
  should expose screenshots, offscreen frames, render-target dumps, UI state, or another reliable
  surrogate for what the user is seeing.
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
- For GUI/editor command surfaces, do not rely only on capability metadata that says an action
  exists. When practical, expose readback for the actual UI action/menu/shortcut/context objects,
  enabled state, attachment point, and command target. Claim a menu, shortcut, context action, or
  toolbar path was tested only when it was exercised or introspected by the harness.
- Maintain a control registry such as `docs/AGENTIC_CONTROL.md` plus optional
  `docs/AGENTIC_CONTROL.json` or `TARGET_CONTROL.json` so future agents can discover controls
  without reverse-engineering the app.
- Every new user-visible feature should update the control surface, curl examples, scenario tests,
  and code-map docs when the project has an enabled code map.

## Proof Before Claiming It Works

A first harness slice is only provisionally successful when these are verified:

- the app launches through the documented dev/test path
- the control surface is reachable
- a trivial round-trip works
- one real feature command mutates the app and has state readback
- recent logs or warnings are queryable
- visual state can be captured or otherwise inspected for viewport/UI-heavy apps, with settled-state
  evidence for mutable viewport/canvas/render output when practical
- user-visible GUI actions added in the slice have either scenario coverage or action/readback
  evidence from the real toolkit objects; metadata-only assertions are labeled as such
- failures distinguish transport errors from app-side command errors

After first proof, add stress lanes for partial failures, invalid values, repeated commands, startup
race conditions, and feature interactions.

## Agent Autonomy Contract

When the target project has an agentic control harness, use it before asking the user to test routine
changes:

1. Launch the app through the documented harness path.
2. Drive the changed feature through curl, CLI, MCP, or scenario controls.
3. Read back state/logs/warnings and capture the relevant visual/UI evidence.
4. Fix harness gaps before treating manual user testing as the only option, when the gap is in scope.
5. Report what the harness proved and what still needs human judgment.
