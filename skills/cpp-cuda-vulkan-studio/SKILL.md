---
name: cpp-cuda-vulkan-studio
description: "Create, audit, or upgrade native C++ GPU project infrastructure and maintained code maps for Vulkan-first, CUDA, or explicit CUDA/Vulkan interop lanes: app+library layout, CMake presets, CTest labels, Vulkan/shader tooling, sanitizer/profile lanes, GPU optimization loops, GPU CI, validation scripts, agentic control harnesses, and donor routing. Use for C++ GPU/CUDA/Vulkan repos, initial project planning, code-map requests, build/test/profiling standardization, custom CUDA/Vulkan work, native C++ GUI/HUD/editor UI choices, local HTTP/curl/MCP app controls, or donor selection for graphics/renderers, assets, WebGPU/OpenXR, path tracing, AI runtimes, neural 3D, sculpting/brush tools, grooming/fur, DCC, volumes, animation, materials, CAD, simulation, CUDA, Vulkan, or cross-backend GPU code. For big initial planning or 'what stack should we use' questions, use cppstudio-project-planner first, research first, then ask for Plan mode."
---

# C++ CUDA Vulkan Studio

Use this skill when a native C++ GPU, C++/Vulkan, C++/CUDA, or mixed CUDA/Vulkan repo needs a repeatable professional development backbone or maintained code map, not a one-off local build. There is no separate CppStudio code-map skill; the code-map protocol lives here. This skill coordinates the more specific global skills instead of replacing them.

## Initial Planning Gate

For a substantial new project, brainstorm, or first big application plan with unresolved template,
GUI/HUD, agentic control harness, input-device, Vulkan/CUDA lane, donor, web-check, code-map,
dependency, or validation choices, do a pre-plan research pass before asking the user to switch to
Plan mode or asking decision questions.

Minimum pre-plan research pass:

- Open `cppstudio-project-planner` immediately when available; do not rely on this top-level skill
  body alone for substantial project intake. Also open `references/project-archetypes.md` and the
  smallest matching donor-router/category files.
- For GUI/HUD/editor choices, open `native-cpp-gui-hud` and its GUI option matrix, then verify
  current upstream official docs/repos or visual pages before ranking options.
- For interactive apps/tools/viewers/simulators, open `agentic-control-harness` and plan a local
  control surface so agents can launch, drive, inspect, screenshot, and troubleshoot the app before
  asking the user for routine manual testing.
- For simulation, renderer, SDK, hardware, or "best/current/ceiling" claims, web-check official
  upstream repos, standards docs, vendor docs, papers, or primary project docs.
- For substantial greenfield or architecture-setting work, persist the research in the target repo
  before implementation. Use `docs/planning/RESEARCH_BRIEF.md` for curated local-donor and web
  sources, with a short description and project benefit for each kept link. Use
  `docs/planning/DONOR_CANDIDATES.md` or a donor-candidates section when web research finds reusable
  donor material that is not already in the CppStudio donor library. Promote candidates into the
  CppStudio source donor library during explicit donor-library maintenance or when the user asks to
  extend the reusable/global donor library; user-level installed skills are rollout targets, not
  source files to edit by hand. If the CppStudio source repo is not the current repo and cannot be
  located through `CPPSTUDIO_SOURCE_ROOT` or a user-provided path, keep the target-project candidate
  and report that reusable promotion is pending. Do not treat the local candidate artifact as
  optional because source promotion is possible; source promotion should consume the candidate as
  its evidence trail.
- In that research brief, include `Project Dos And Don'ts`: app/domain rules and GUI/product-surface
  rules distilled from local donors, peer tools, and web/upstream sources. Each item needs evidence,
  the subsystem or UI surface it applies to, and the first validation signal. GUI rules must be based
  on peer-tool, UI-framework, or donor evidence for layout, control placement, icon/text affordance,
  viewport/timeline/inspector conventions, debug-vs-product boundaries, and visual proof.

The first visible response after that research should be a concise **Pre-Plan Research Brief**:

- choices discovered
- source/visual links for GUI options
- agentic control harness default and any real opt-out reason
- donor categories/profiles opened
- web/current sources checked
- durable research artifact path, when the project is substantial enough to require one
- donor candidates discovered outside the current library, if any
- project dos and don'ts artifact path and the most important app/domain and GUI/product-surface rules
- clear recommended default and alternatives

Then ask the user to switch to Plan mode before implementation:

```text
Please switch to Plan mode before implementation so I can ask the project-shaping questions. I need
to lock down the template, GUI/input stack, GPU lane, agentic control harness, donor routes, web
checks, code-map choice, and validation plan before files are created.
```

For greenfield target repos, the code-map choice is a hard pre-source gate, not a footnote in the
plan. Before the first implementation slice writes source, build, app, renderer, test, or docs
scaffold files, the agent must establish one of these states: maintained code map accepted and
bootstrapped, code map declined and recorded with the bootstrap script, or the user explicitly
instructed the agent to defer the code-map decision for this project. Merely mentioning "code-map
choice" in a plan is not acceptance. If the user gave an implementation command but the greenfield
code-map state is still missing, pause after the research brief and ask the code-map question before
coding.

This rule applies even if `cppstudio-project-planner` is not listed in the current session. If the
current turn explicitly says the session is already in Plan mode, still do the pre-plan research
brief before calling any question UI. If Plan mode is unavailable or the user says to continue without
it, ask no more than three blocking questions at a time and do not scaffold until the critical choices
are clear.

When asking the user to choose a GUI/HUD/tool UI stack, links must be visible at decision time. Before
calling any interactive question UI such as `request_user_input`, show a compact GUI option table with
source/docs and visual inspection links. Also put a compact URL in each option description when the
question UI allows it.

## Agent Mindset

When this skill is active, work like a native C++ GPU systems engineer:

- Hard rule: before touching code, do not rely on training data or intuition as the source of truth.
  First open the relevant local skills, the target repo's maintained code map when enabled, and the
  smallest matching donor-library route/category/profile. Then run a compact before-implementation
  gate: discover the actual project/toolkit APIs and command surfaces, map constraints such as state
  ownership, enabled states, selected object, snapping/clamping, coordinate spaces, socket/type
  compatibility, and validation affordances, and decide how the change will be verified before
  wiring it into production paths. State the skill and donor sources used before implementation. If
  no donor route fits, stop and do focused donor discovery with web/upstream research before
  designing the code. In that case, search current public upstream sources such as official repos,
  docs, samples, papers, standards docs, and vendor docs; record the links/evidence before any
  design or implementation. "Upstream research" is not model-memory reasoning.
- Hard realignment rule: if a visible bug, interaction bug, product-shape problem, renderer/sim
  behavior issue, or domain algorithm slice survives two focused attempts or roughly 20 minutes
  without direct symptom improvement, stop local patching immediately. Reopen the target code map,
  the matching donor route/profile, and current upstream or peer-tool sources; write a compact donor
  realignment note naming the donor facts, local mismatch, failed hypotheses, keep/revert decision
  for speculative patches, and the next smallest proof. Do not continue from training-data guesses,
  backend-only green checks, or newly expanded harness scripts. If the donor route was skipped,
  treat that as the root process bug before another code edit.
- Treat Vulkan as an explicit-lifetime API. Resource ownership, synchronization, image layouts, queue
  ownership, descriptor lifetime, command-buffer reuse, and frames-in-flight must be designed
  deliberately.
- For realtime Vulkan viewports, distinguish Vulkan-loader availability from hardware-backed
  viewport readiness. CPU or software Vulkan implementations such as llvmpipe/Lavapipe may be valid
  diagnostics for CI or headless tool checks, but they are not a successful default realtime viewport
  backend. Preflight and readiness tests must prefer discrete GPUs, then integrated GPUs, and treat
  CPU/virtual devices as explicit opt-in diagnostic modes with visible readback of device name/type,
  ICD/driver evidence, queue support, and missing hardware requirements.
- Keep the active lane disciplined. Prefer Vulkan for unspecified reusable GPU/3D/realtime work, keep
  CUDA separate unless the user chooses it or the requirements force it, and document any deliberate
  CUDA/Vulkan interop boundary.
- Do not silently downgrade the work to get a green run. If CMake, CUDA, Vulkan SDK tools, shader
  compilation, validation layers, GPU selection, profilers, or tests fail, surface the failure and fix
  the root cause when it is in scope.
- Inspect before editing. Read the build graph, presets, target ownership, shader or kernel paths,
  dispatch/render loop, and direct callers before changing native GPU infrastructure.
- When building or validating an existing repo, use the repo-declared commands first: CMake presets,
  project scripts, maintained validation docs, or code-map build/preset routes. Do not invent build
  directories such as `build_linux` or `build/Release` unless the repo explicitly declares them. If a
  guessed command fails, treat that as a process miss, reopen the repo build docs/presets, and rerun
  the documented command before continuing.
- When auditing docs, validation logs, scripts, or markdown with shell search tools, quote patterns
  so the shell cannot reinterpret documentation or regex syntax. Do not put markdown backticks,
  embedded double quotes, `$`/`${...}`, command substitutions, or other shell metacharacters inside
  double-quoted `rg`/`grep` patterns. Use single quotes, `rg -e`, fixed-string searches, or separate
  pattern arguments so code spans such as `` `4320` `` and script fragments are matched as text. If
  a search/audit command fails because shell syntax from documentation was executed or reinterpreted,
  treat that as a process miss: acknowledge the failure, rerun the audit with safe quoting, and do
  not continue the slice from the partial command output.
- Before major C++/GPU edits, name the likely failure modes: synchronization or lifetime bugs, wrong
  device/backend lane, missing validation/profiling evidence, portability breaks, and
  dependency/license mistakes.
- Before risky GPU refactors, broad CMake/build-system changes, backend rewrites, synchronization
  changes, or target-project deployment/install script edits, create or confirm a recent git commit
  so rollback is exact and cheap. If the target repo has no suitable recent commit, ask before
  proceeding with high-risk edits.
- Treat git commits as part of the normal production workflow, not only as end-of-project cleanup.
  For a greenfield project that is expected to use git commits, establish usable source control
  before the first source slice whenever the session can do so safely. If a Codex worker in a
  brand-new directory sees `.git` as an empty read-only mountpoint or `git init` fails with a
  read-only filesystem inside `.git`, treat that as a worker sandbox/mount-namespace blocker, not as
  ordinary project state. Do not `chmod`, delete, unmount, or otherwise bypass that `.git` placeholder
  from inside the worker. The preferred recovery is to initialize Git on the real target path from the
  host/supervisor shell, then relaunch or retry the worker from a clean Rewind checkpoint. If the
  supervising agent has that host access, do the host-side initialization directly instead of asking
  the user to do it. Ask only when host-side initialization is unavailable or risky. If documenting
  the blocker, say "inside this Codex worker" rather than recording it as a stable fact about the
  project directory.
  When supervising a greenfield tmux/Codex worker and commits are part of the test or workflow,
  create the empty project directory and initialize Git from the host/supervisor shell before
  launching the worker, unless the user explicitly wants to test non-git startup behavior.
  Once Git is usable, continue with the normal verified-slice workflow.
  After each coherent implementation slice or milestone is verified, commit the source, docs,
  harness, test, and code-map updates before continuing into the next slice, unless the user or repo
  policy explicitly says not to commit. Before committing, inspect `git status`, keep user-owned
  unrelated changes out of the commit, exclude build outputs, profiler traces, screenshots, temp
  artifacts, and generated junk unless the repo intentionally tracks them, and run a whitespace or
  staged-diff hygiene check such as `git diff --check` or `git diff --cached --check`. If a
  CppStudio code map is enabled, run the target repo's `scripts/check_code_map_drift.py
  --require-enabled` before committing when that script exists; otherwise manually compare the
  changed source/header/shader/script/docs paths against `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` and
  the matching `docs/SUBSYSTEMS/*.md` route. Do not commit a new or moved routable path that is not
  covered by a subsystem route; update the manifest and subsystem doc in the same slice or explain
  why the map update is intentionally deferred. If the repo has no git history, no git identity,
  ambiguous dirty state, or approval is required for the git write, surface that clearly instead of
  silently skipping the commit. Add exactly one `Commit-Origin` trailer that identifies why the
  commit happened, using only these values: `Commit-Origin: agent-slice` for commits the agent
  creates as part of the verified-slice workflow, and `Commit-Origin: user-requested` when the user
  explicitly asked for that commit. Do not use provider names such as `codex`, `claude`, or model
  names as commit-origin values; the trailer describes the reason for the commit, not which agent
  wrote it.
- Use evidence before claims. Builds, CTest labels, shader compilation, Vulkan validation,
  Compute Sanitizer, RenderDoc/Nsight captures, screenshots, image comparisons, and profiler output
  matter more than plausible explanations.
- For user-reported bugs, fixes require a before/after proof gate. First reproduce the exact
  reported behavior through the closest user-equivalent path available and record "before" evidence:
  command, steps or scenario id, harness/readback fields, logs, screenshot/video/capture, metric, or
  failing test that demonstrates the symptom. After the fix, run the same scenario or an explicitly
  equivalent one and record the "after" evidence. Do not present the work as fixed unless the
  before/after comparison shows a material change in the reported behavior. For visible GUI or
  windowed bugs, include Sonar text/visual readback when available and run automated windowed
  scenario, smoke, screenshot, and proof commands through `ostm` when the offscreen-test-manager
  skill or CLI is available. If OSTM is unavailable, use the target repo's approved nonblocking
  launch/smoke manager and say that OSTM evidence is unavailable. Direct foreground app launches are
  only for explicit user/manual inspection or bounded launch-command proof, not for repeated
  automated GUI debugging loops. Backend state alone is not user-visible proof. A visible GUI bug
  also needs an actual visible-surface observation: screenshot, video,
  Sonar visual readback, OSTM/window capture, or explicit user-provided visual evidence. If the
  agent cannot currently see or drive that surface, start the status with "I am UI-blind on this
  bug:" and name the missing observation route; do not keep presenting harness-only or JSON-only
  work as progress on the visible fix. If a proof lane fails once because it cannot reach the real
  window/event path, stop expanding proof infrastructure and switch to a bounded app-side fix
  hypothesis, a visible/manual repro path, or a clear blocker report. If the before and after
  evidence are identical, nearby, self-confirming, backend-only, or unrelated to the user's symptom,
  keep debugging instead of handing it back. When Rewind is
  available, use the pre-fix checkpoint as the rollback anchor before stacking another focused GUI
  probe; if no pre-change checkpoint exists, say exact replay was missed. After repeated focused
  attempts or the repo's hard-reset threshold, start the status with "I am stuck on this bug:" and
  name the missing proof, failed hypotheses, and next diagnostic path.
- Treat code-map completion claims as routing claims, not just schema claims. After enabling or
  materially changing a maintained code map, run the validator and a read-only subagent or
  fresh-session routing smoke before saying future agents can use it or that setup is done, whenever
  that testing route is available. This is part of code-map setup verification, not optional polish.
  The smoke should be task-shaped, for example "find where <feature> should be changed, do not edit,"
  and the expected evidence is that the fresh agent loads `cpp-cuda-vulkan-studio`, reads the
  code-map state, architecture index, and manifest, selects the relevant subsystem doc, and then
  traces exact files/tests. Keep this smoke bounded: once the first confident subsystem route plus
  exact source/test paths are found, report and stop; do not turn it into a full source audit or
  implementation analysis. Grade the smoke explicitly: pass only when the fresh agent names the
  skill, reads the state/index/manifest, chooses a subsystem doc, reports exact source and
  test/validation paths, and makes no edits. Treat it as failed or partial if the agent skips the
  manifest, starts implementation, expands into broad unrelated source reading, fails to produce a
  final routing report in the bounded probe, or leaves any file changes. If subagent or fresh-session
  testing is not available, report that as pending evidence, not as a passed trigger lane.
- Treat code-map maintenance as an ordinary source-edit closeout gate, not only a setup task. When
  an enabled-map repo changes source ownership, data flow, backend boundaries, validation lanes,
  public runtime behavior, or adds/moves files under routable source areas, update the matching
  subsystem doc and manifest before commit. The drift checker catches unmapped paths; the agent still
  must make the semantic call on whether an already-covered route needs clearer notes.
- Use a bounded code-map sidecar lane when map maintenance would otherwise bloat or destabilize the
  main worker context: a drift check reports work, a long-running implementation slice reaches a
  planned map-maintenance interval, changed source ownership/data flow/backend boundaries affect
  subsystem docs, new or moved routable files appear, or local evidence suggests subsystem docs are
  stale. The sidecar is code-map-only: it may inspect the frozen source snapshot, architecture index,
  manifest, and subsystem docs, then return a patch/diff, map-file replacements, and rationale; it
  must not implement product/source changes or assume live access to the original worker's evolving
  tree.
- Code-map sidecars need snapshot semantics. The original worker must name the fixed checkpoint,
  Rewind checkpoint, temporary git anchor, commit, worktree copy, or archive snapshot that the
  sidecar is reading. The original may continue implementation only if it plans a final reconcile
  before staging or committing. A temporary anchor or Rewind checkpoint is not a public slice commit,
  and CppStudio must not require noisy public commits for every sidecar. The final history boundary
  remains the verified slice commit after build/test/map validation, with the normal
  `Commit-Origin` trailer.
- Code-map sidecars must not edit the original worker's live worktree while the original continues
  source work. Use an isolated worktree, archive/snapshot copy, read-only snapshot plus patch output,
  or a serialized same-worktree handoff where the original worker pauses and resumes only after
  sidecar output is reviewed. If a sidecar returns a patch, the original applies it deliberately in
  the live worktree during the final reconcile; unreviewed concurrent same-worktree map edits are not
  a valid sidecar lane.
- Before the original worker commits an enabled-map slice that used a sidecar, it must apply or merge
  the sidecar map update, rerun the drift checker and code-map validator against the current tree,
  and compare the sidecar's fixed snapshot with current changed routable areas. If the original
  changed additional routable files, ownership, data flow, validation lanes, or public behavior after
  the sidecar snapshot, the original must either update the map itself or launch a fresh sidecar from
  a new fixed snapshot before committing.
- For realtime rendering, viewport, simulation, XR, or GPU-performance work, measure frame time/FPS
  or profiler timings while implementing and verify the actual visual output.
- When a target app has an agentic control harness, use it as the first route for routine launch,
  feature driving, state/log readback, screenshots, and visual/UI troubleshooting before asking the
  user to manually test. If the missing evidence is a harness gap and fixing it is in scope, repair
  the harness instead of repeatedly handing small verification chores to the user.
- For GUI interaction bugs or user-visible interaction slices, require a real GUI scenario or
  equivalent toolkit-level probe for the affected path. Brush palette clicks, tool buttons, timeline
  controls, menu/shortcut/context actions, viewport strokes, picks, gizmo drags, graph edits, and
  canvas interactions must prove the same event path a user exercises when practical. The evidence
  should include event-to-committed-state latency for selection/control changes and explicit pointer
  mapping for viewport/canvas edits: widget geometry, local point, device-pixel ratio,
  render-target point, ray/canvas transform, hit object or primitive, committed hit/edit point, and a
  fresh visual marker/capture when practical. The scenario must exercise enough variants to cover the
  user's complaint, such as every affected enabled tool or repeated selection changes when the bug is
  "other tools cannot be selected." Do not call these fixed from backend command success, a generic
  model revision, a one-item self-confirming scenario, or a nonblank screenshot alone. Harness,
  scenario, or control-route construction is only a means to observe or drive the bug; it is not a
  completed fix for the user-visible symptom unless it produces before/after visible evidence and the
  app behavior actually changes.
- For sculpting, brush, paint, groom, stroke, or high-poly mesh editing work, donor realignment has
  an extra gate. Before changing brush behavior, viewport hit tests, palette selection, stroke
  sampling, falloff, pressure, mask, high-poly storage, or dirty upload code, open the sculpt or
  grooming donor route first. For mesh sculpting, read `sculpting-brushes.md` and the Blender Sculpt
  Brushes study-only profile before generic geometry, renderer, or GUI donors. The slice plan must
  include a donor mapping: upstream/source or manual concept, extracted behavior contract, local
  architecture translation, exact files/tests to change, and before/after proof. A generic mesh
  displacement test, nonblank screenshot, or mesh revision increment is never enough for brush-hit
  or brush-selection bugs; the proof must compare requested pointer/control, committed hit or active
  brush, latency, and visible result.
- Keep harness roadmap/readiness readback current. If a target app exposes machine-readable fields
  such as `next_required_slice`, `blockers`, `prerequisites`, readiness booleans, or backend/feature
  eligibility, a verified slice that satisfies one prerequisite must update that readback before
  commit. Do not leave a completed prerequisite listed as the next missing item unless the field is
  intentionally naming a broader gate; in that case expose completed-versus-remaining prerequisites
  and document why the broad gate name still applies.
- Name harness readiness and success fields after the exact invariant they prove. Do not set a broad
  field true from a weaker nearby condition, such as reporting a live composed capture as ready when
  only a widget exists or a backend initialized. If weaker facts are useful, expose them as separate
  readback fields and keep the broad gate false until its documented invariant is satisfied.
- When worker, subagent, reviewer, or background validation work is gated by the current task, keep
  supervision active until it reports done, idle, or blocked. Do not give final status while delegated
  work is still running; report the active worker state and remaining blocker instead.
- When delegation is explicitly authorized and a bug, product-shape decision, or broad subsystem
  audit resists one perspective, escalate to parallel lenses. Assign independent hypotheses such as
  state flow, command/API routing, rendering/capture timing, build/toolchain contracts, or UI/product
  convention fit, then synthesize the evidence before implementing or closing.
- Treat bad product-shape decisions, skipped skill/donor routing, weak harness semantics, and
  evidence-free success claims as blockers, not merely style issues. Stop the target slice, repair
  the process miss, and update reusable project skills when the failure is generic.
- After a bounded target-project slice has been named with its code-map route, donor/reference
  grounding, expected files, and verification plan, stop broad orientation. The next step must be
  the smallest coherent source/probe action, or a concrete blocker report explaining what evidence is
  still missing. Do not spend several more minutes re-reading broadly after the route is already
  sufficient; if the route still feels insufficient, say which missing source, donor, or API contract
  blocks implementation.
- Treat the slice task list as a live alignment tool. If real evidence during implementation shows
  that a planned task is stale, impossible, too broad, missing a prerequisite, or aimed at the wrong
  subsystem, update the task list immediately: name the new fact, the invalidated assumption, the
  revised bounded task, and the changed validation gate. Continue without asking when the change is
  an internal correction that preserves the user's intent, chosen stack, and quality bar. Pause for
  user alignment when the change affects product direction, selected GUI/backend/authoring model,
  scope, dependency/license posture, or any explicit user constraint.
- Treat midstream major feature requests as new planning evidence. A vague request such as "can we
  also include realtime ray tracing" or "add a node editor" is not permission to code from memory or
  to answer from chat-only research. Before implementation or a final recommendation, reopen the
  bounded planning gate for that subsystem: read the target code map and current planning docs, open
  local donor routes, check current upstream/primary sources and local capability facts, update the
  research brief, implementation slice plan, donor-candidate notes when relevant, and the applicable
  dos/don'ts or decision record. If the feature is blocked by architecture, toolkit, hardware,
  dependency, license, or validation constraints, record the prerequisite slice and ask the user only
  when choosing a different stack, backend, product scope, or explicit constraint is required.
- If a target-project slice is interrupted, stopped, or rejected after partial unverified edits, do
  not leave the repo in an ambiguous dirty state. Either revert only the incomplete edits for that
  slice, or explicitly report the exact dirty files and ask whether to preserve them. Do not commit,
  continue, or claim readiness from an interrupted partial edit.
- In an enabled-code-map repo, the code-map closeout has two distinct gates before staging or
  committing: run `scripts/check_code_map_drift.py --require-enabled` to catch changed routable paths
  that the map does not cover, and run `scripts/validate_code_map.py --require-enabled` to validate
  schema/state. If repo-local wrappers are absent, use the installed CppStudio scripts. Do not treat
  `validate_code_map.py` as a substitute for the drift check, and do not commit first and drift-check
  afterward unless the user explicitly asked for that emergency ordering.
- Harness endpoints that touch UI, renderer, swapchain, toolkit action state, screenshot/grab APIs,
  or visual-capture state must run on the app's safe GUI/render thread or an app-owned command queue.
  Do not call `requestUpdate()`, `grab()`, widget/window APIs, or action mutations directly from an
  HTTP/server worker thread.
- Harness mutation endpoints must define success by the committed state they claim to change. A
  move, drag, edit, connect, delete, timeline, scene, or viewport command must read back the affected
  state and return `ok=true` only when the invariant is satisfied, or explicitly report a deliberate
  no-op. If the command snaps, clamps, quantizes, or validates input, tests and docs assert the
  post-validation committed values, not raw deltas.
- When adding, removing, or renaming harness routes, reconcile the runtime route-registration table
  against `docs/AGENTIC_CONTROL.md` and any machine-readable control inventory before commit. The top
  discovery list, detailed endpoint docs, examples, and optional JSON must match registered public
  routes. A registered route missing from docs, or a documented route absent from code, is harness
  drift unless intentionally hidden as an internal-only route.
- For GUI/editor command wiring, use verify-before-wiring for menus, shortcuts, context actions,
  timelines, and viewports. Discover or introspect the real toolkit/API objects, enabled-state rules,
  selected-object requirements, snapped or committed coordinates, and socket/type compatibility
  before connecting production commands; metadata or planned wiring is not proof.
- For pointer-driven GUI fixes, treat coordinate transforms as a first-class contract. Audit
  widget/framebuffer bounds, dock/sidebar/menu/status offsets, scroll positions, device-pixel ratio,
  viewport origin, camera matrices, ray construction, hit-test space, and snap/brush falloff space
  before editing. Tests should assert the full screen-to-world or screen-to-document path, not only
  that an edit occurred.
- For viewport, canvas, render-target, or screenshot capture endpoints, do not assume "set state,
  request update, grab immediately" proves the visible result. The harness should expose enough
  frame/revision/sequence/fence evidence to show the requested UI or renderer state was rendered
  before capture, and the capture response should include that evidence when practical. If the
  capture cannot settle on the requested state, report a harness failure instead of accepting stale
  pixels. Run visual-difference or screenshot checks only against settled frames.
- Judge screenshots against donor or peer-tool product conventions, not just non-empty pixels. Reject
  captures that prove a command fired but show crowded, clipped, debug-looking, dimensionally wrong,
  or convention-breaking UI for the target product class.
- For GUI/HUD/editor/timeline/viewport/tool-surface slices, use `native-cpp-gui-hud` to create a
  compact UI convention table before code changes. Record the peer-tool or donor evidence, expected
  surface placement, icon/text convention, tooltip/accessibility text, enabled-state rules, and proof
  method for affected controls. Universal actions such as play, stop, step, save, undo, redo, select,
  transform, visibility, lock, zoom, and delete should use recognizable icon affordances when the
  toolkit supports them, with readable names in tooltip/menu/accessibility/harness metadata, unless
  donor evidence or accessibility/localization constraints justify prominent text controls.
- For native tool UI, visible labels must carry critical semantic scope themselves. Do not rely on
  tooltips, hidden harness readback, or docs as the only distinction between states that affect user
  trust, such as preview versus baked output, destructive versus non-destructive actions, local versus
  published state, approximate versus final results, or diagnostic versus product surfaces. If the
  visible text could mislead the user about what actually happened, revise the label and make the
  harness/screenshot checks assert that wording.
- When visual freshness checks fail repeatedly, pause code edits and audit the capture API timing.
  Some toolkit grabs render during the capture call, so the correct proof is a post-capture rendered
  revision; others copy the last presented frame and need pre-capture scheduling. Classify the issue
  as render scheduling, capture timing, or test-script order before applying the next fix.
- If two focused visual-capture, render-scheduling, or harness-command fixes fail, stop
  micro-patching. Write a short evidence ledger with the failing job/scenario ids, exact failed
  assertion or response fields, frame/revision/fence progress, whether artifacts are current or stale
  leftovers, validation-layer/profiler errors, and which recent patches are proven versus
  speculative. Revert or quarantine unproven speculative patches before the next attempt unless the
  evidence clearly shows they are still required. The next attempt needs either a smaller targeted
  repro/probe or a source-level root cause in the app/toolkit/render flow.
- When you give, change, or rely on a user-facing desktop launch command, verify that exact command
  path in addition to offscreen smoke tests. For long-running GUI apps, acceptable evidence is that
  the exact command starts the intended process, the control harness responds, and a desktop window
  or captured screenshot is visible to the user. Do not treat an offscreen smoke run alone as proof
  that the user's launch command works.
- Desktop launch evidence must prove the intended app window, not a coincidental terminal or stale
  previous window. Match by process id, exact executable/app id, `WM_CLASS` or toolkit class, and
  title when available; reject matches that only come from a terminal title containing the repo name.
  Record mapped/normal/iconic state, workspace/desktop id, geometry, focus/raise result, and whether
  the window is on the user's current visible desktop. A window object on another workspace, an
  iconic/hidden window, a device-lost surface, or an unresponsive control harness is not a completed
  human-launch proof even if the process is still alive.
- Verify long-running desktop launch commands without blocking the agent on a foreground GUI
  process. Use a bounded non-blocking verification shape: start the exact launcher while capturing
  stdout/stderr, keep that launch alive while polling the control harness, confirm process and
  window/screenshot evidence, test duplicate-launch behavior when the launcher owns a fixed control
  port, then stop the app through its harness. Avoid transient-shell artifacts where a backgrounded
  GUI receives SIGHUP when the verification shell exits before probes finish.
- In shell launch wrappers that probe localhost control ports under `set -e`, explicitly capture and
  classify failed probe statuses. A normal connection-refused result for "no existing instance yet"
  must not terminate the launcher before it reaches the app binary, while a healthy existing instance
  should focus/reuse the window when that is the intended duplicate-launch contract.
- For GUI/windowed verification through offscreen or background managers, prefer the target repo's
  canonical smoke script or launch wrapper over ad hoc commands. Invoke manager-submitted scripts
  with absolute paths, or an explicit working directory when the manager supports it, even when the
  script is the canonical smoke; offscreen managers may not preserve the caller shell's current
  directory. Classify "script not found" manager-context failures as invocation issues rather than
  app failures.
- After broad GUI/editor event-handler rewrites, inspect the edited source for stale control-flow
  fragments, duplicate helpers, mismatched braces/namespaces, and surviving obsolete paths, then
  build before adding more harness routes or documentation. Do not stack docs on top of a malformed
  interaction patch.
- Stop verification once the agreed evidence threshold is met. Do not keep adding optional probes
  after build/test/map/harness/screenshot evidence already answers the user-facing question, unless a
  new failure or unresolved risk justifies the extra run.
- Be donor-first. Use the donor library for architecture, edge cases, tests, algorithms, and
  dependency choices before inventing a new subsystem. For a new component/subsystem, broad
  product-shape decision, or major architecture choice, first open the local donor routes; when no
  suitable donor exists or the available donors are too stale/generic for the decision, run
  web/upstream donor research against current primary sources before designing the implementation.
  Do not substitute training data for missing donors. When that research finds reusable donors that
  should help future projects, record them as target-project donor candidates immediately before
  promotion, including URL, tier, backend/language signal, license/freshness notes, reuse caveat, and
  promotion rationale. Promote them into the CppStudio source donor library when the user requested
  reusable/global promotion or the current task is CppStudio donor-library maintenance. Never patch
  the installed
  `~/.codex/skills/cpp-cuda-vulkan-studio/references/donor-library` copy directly; update source and
  roll out.
- For risky backend, renderer, GUI/editor, solver, harness, or authoring-model migration slices,
  close out donor provenance as part of the slice, not as optional documentation. Update the target
  repo's provenance/source notes when present, such as `docs/DONORS_AND_SOURCES.md`, or record the
  slice-specific sources in the validation/status docs when no provenance file exists. Include the
  local donor categories/profiles used, current upstream links checked, study-only or license caveats,
  and which decisions came from inference rather than donor evidence.
- Do not treat "MVP", "scaffold", or "prototype" as permission to skip donor grounding for product
  shape. For native GPU tools, viewport type, editor layout, timeline/transport placement, graph or
  scene source of truth, solver architecture, render path, and validation surface must be checked
  against the relevant skills and donor/peer-tool references before code is written.
- Treat native C++ GPU brainstorming and architecture proposals as donor-grounded work, not just
  conceptual chat. Before making concrete solver, renderer, dependency, subsystem, or MVP-order
  recommendations, open the smallest relevant donor categories/profiles and state which guidance is
  donor-backed versus inference. If the prompt asks for current best choices, state-of-the-art,
  "ceiling", or rapidly moving GPU/tooling options, run an extensive web ceiling check against
  upstream or primary sources before ranking choices. Separate current leading approaches from
  legacy, teaching, or low-effort approaches, and prefer the best available option unless the user
  asks for a lighter route.
- For ambitious realtime simulation/graphics brainstorms, including fluid, fire, smoke, water,
  destruction, shatter, neural 3D, upscaling/reconstruction, XR, or renderer architecture that is
  likely to depend on current engines, SDKs, papers, samples, or hardware capabilities, run a real
  state-of-the-art web ceiling check even when the user only says "brainstorm." Use official upstream
  repos, vendor docs, recent papers, project docs, active samples, release notes, and adoption signals;
  then separate current-source evidence from local donor guidance and inference.
- Never copy study-only, incompatible-license, non-C++ reference-only, or backend-mismatched donor
  code into generated projects. Use those donors for concepts, then translate through the active
  Vulkan, CUDA, or explicit interop lane.
- Preserve user and project state. Managed markers may be replaced by this package, but project files,
  local rules, custom skills, and content outside managed marker blocks are user-owned.
- Produce usable infrastructure. Avoid stubs, toy-only scaffolds, disabled tests, placeholder kernels,
  or sample-only shortcuts unless the user explicitly asks for a throwaway prototype.
- Keep code maps lazy before activation and decisive after activation. Check
  `.cppstudio/code-map-state.json` first when present. When it says `enabled`, or when target
  repo instructions declare a maintained codebase map required, use the architecture index and
  manifest as the first navigation step before code changes: choose the subsystem route, read the
  matching subsystem doc, then inspect the files named by that route. Do not keep prompting when
  state says `declined`.
- Do not hand-author CppStudio code-map state or manifest schema in target repos. Use the bundled
  `scripts/bootstrap_code_map.py` flow to enable, decline, or audit maps, then run
  `scripts/validate_code_map.py --require-enabled .` when the map is expected to be active.
- Treat generated tool-probe artifacts as cleanup debt, not just ignore-file entries. If CMake
  probing or package discovery creates top-level `CMakeFiles/`, `CMakeCache.txt`,
  `cmake_install.cmake`, or similar generated files outside the chosen build directory, remove them
  before validation, review, or commit status. Build and artifact directories may be ignored, but
  probe junk should not sit in the source root.
- When working in a target repo other than CppStudio itself, treat that repo's `AGENTS.md`,
  codebase map, manifest, and repo-local skills as the subsystem routing authority. CppStudio supplies
  the native C++/GPU lane policy, backbone, validation, and donor routing around the target repo's map.
- Treat target-repo instruction files as sensitive status items. `AGENTS.md`, `CLAUDE.md`,
  `.codex/skills/`, repo-local skill metadata, and similar agent-policy files must be reported
  separately from ordinary source dirt, whether or not they are part of the current commit. Do not
  call them "unrelated dirty files" without naming them and explaining why they were left unstaged.
  Do not create or modify `CLAUDE.md` from a Codex CppStudio code-map/backbone workflow unless the
  user explicitly asks for Claude-facing instructions or the target repo already owns that surface
  and the change is deliberately scoped.

## Coordination

- Use `cppstudio-project-planner` before scaffolding or major architecture work when the project has
  unresolved template, authoring-model/source-of-truth, GUI/HUD, agentic control harness, GPU lane,
  donor, input-device, code-map, dependency, or validation decisions. For substantial project intake,
  do the pre-plan research pass first, show links and sources, then ask the user to switch to Plan
  mode before implementation and hand implementation back to this skill after choices are clear.
- Use `modern-cpp-cmake` for CMake target structure, source ownership, presets, CTest, and dependency wiring.
- Use `cuda-kernel-authoring` when adding or reviewing custom CUDA kernels or launch wrappers.
- Use `vulkan-compute-sync` when the project contains Vulkan compute, render, synchronization, descriptor, or frame-lifetime work.
- Use `native-cpp-gui-hud` when choosing, comparing, or integrating native C++ GUI/HUD/editor UI,
  viewport overlays, docking panels, transform gizmos, plotting, desktop app UI, runtime/game UI, or
  embedded web UI. When presenting GUI options, include links where the user can inspect how each GUI
  looks.
- Use `agentic-control-harness` when planning or implementing local controls that let agents launch,
  drive, inspect, screenshot, and troubleshoot native apps through HTTP/curl, CLI, or MCP-backed
  surfaces. For interactive apps, make this default-on unless the user opts out or the target is a
  headless library or security-sensitive product surface.
- Use available profiling or frame-debugging skills and local profiler tools only when the active environment exposes them and the user needs performance or capture evidence.
- Use `verification-before-completion` before claiming the generated or upgraded backbone is valid.

## Workflow

1. Before touching code, open the relevant skills and donor routes. Training data is not authority
   for CppStudio implementation decisions. Use `references/donor-library/agent-lookup.md` for broad
   or overlapping prompts, production overlays for VFX/game/native-infrastructure vocabulary, and
   category/profile files for the smallest concrete donor set. Record the sources used.
2. Inspect the target repo: `AGENTS.md`, `CMakeLists.txt`, `CMakePresets.json`, package manifests, `.github/workflows`, `cmake/`, `tests/`, `scripts/`, docs, `docs/CODEBASE_ARCHITECTURE_INDEX.md`, `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`, and `.cppstudio/code-map-state.json` when present.
3. For a greenfield repo, run `scripts/scaffold_gpu_cpp_project.py` from this skill and then adapt only project names and required dependency switches.
4. For an existing repo, run `scripts/apply_studio_backbone.py` against a temporary copy first unless the user explicitly wants direct modification.
5. For a greenfield scaffold with no `.cppstudio/code-map-state.json`, treat the code-map decision as
   a hard pre-source gate. Ask once whether to create a maintained codebase architecture map before
   the first implementation slice writes source, build, app, renderer, test, or docs scaffold files.
   State the benefits: faster cold starts, cleaner multi-agent routing, explicit subsystem ownership,
   and less repeated code reading. If the user already explicitly asked for a code map, architecture
   map, or future-agent map during project creation, treat that as acceptance and run
   `scripts/bootstrap_code_map.py --enable --force` after scaffold/template material exists because
   the template includes starter generated map files. If they decline, run
   `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked. If the user
   explicitly says to defer the code-map choice, record that as a deliberate pending decision in the
   planning notes before coding and ask again only when the user reopens code-map setup. Do not
   proceed with greenfield implementation while `.cppstudio/code-map-state.json` is missing and the
   code-map choice is merely "pending." Do not create `.cppstudio/code-map-state.json`,
   `docs/CODEBASE_ARCHITECTURE_INDEX.md`, or `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` by guessing the
   schema; use the bootstrap script and validator.
6. For an existing project with no `.cppstudio/code-map-state.json`, treat code-map enablement as a readiness protocol, not as an immediate choice prompt. If the user says they want to opt in to a code map, first say that you will run a non-destructive audit and that no restructure decision is needed yet. Then run `scripts/bootstrap_code_map.py --audit-existing` before asking any restructure/preserve/decline question. Summarize the actual stdout with concrete findings, evidence paths, nonstandard layout risks, estimated cleanup cost, and any specific restructuring that would be needed. If the audit did not run or you have not read its output, do not claim an audit happened and do not ask the user to choose a restructuring route. Do not write `docs/CODEMAP_BOOTSTRAP_AUDIT.md` unless the user wants a saved audit; then rerun with `--write-audit`. Only after presenting audit evidence ask whether the user wants to restructure first, preserve the current layout and document exceptions, or decline the map. Do not run `--enable` until the user chooses either restructure-complete or preserve-as-is. If generated map files already exist, use `--enable --force` only after the user accepts replacing those generated map files.
7. When `.cppstudio/code-map-state.json` says `enabled`, or when repo-local instructions declare a maintained codebase map required, read the target repo's `docs/CODEBASE_ARCHITECTURE_INDEX.md` and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` before code changes. Use that map to select the subsystem doc and primary paths for the change, then keep the map updated when ownership, data flow, GPU backend boundaries, build/test lanes, validation, CI, public runtime behavior, or routable file ownership changes. Before every verified-slice commit in an enabled-map repo, run `scripts/check_code_map_drift.py --require-enabled` when present plus `scripts/validate_code_map.py --require-enabled`; if repo-local wrappers are absent in an older existing-project map, run the installed skill scripts from `${CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio/scripts/` and report the wrapper gap instead of treating it as a target project failure. If the drift check reports an unmapped path, update the manifest and matching subsystem doc before committing. Prefer adding the owning directory or glob route for related app-owned files, such as flat `src/*.h`, `src/*.cpp`, or `src/ui_panel_*.h`, instead of adding a one-off route for each controller/panel/helper file. If the user asks about a code map mid-project, explain it, run the existing-project readiness protocol, and wait for acceptance before running `scripts/bootstrap_code_map.py --enable`; if generated map files already exist, use `--force` only after the user accepts replacing them. For large existing repos, use parallel-lens subsystem audits only when delegation is explicitly authorized.
8. For enabled-map repos, prefer a code-map sidecar only when it is bounded and useful: drift output,
   long-running slice interval, ownership/data-flow/backend-boundary changes, new or moved routable
   files, or stale subsystem docs justify offloading map maintenance. Launch or instruct the sidecar
   from a fixed snapshot, Rewind checkpoint, temporary git anchor, commit, worktree copy, or archive;
   document that anchor in the sidecar prompt and response. The sidecar may only produce map-file
   changes (`docs/CODEBASE_*`, `docs/SUBSYSTEMS/*`, and project-local map notes) plus rationale, and
   it reports its snapshot assumptions. If the original worker keeps implementing, the sidecar must
   work in an isolated worktree, archive/snapshot copy, or read-only snapshot and return a patch/diff
   or map-file replacements; same-worktree map edits are allowed only as a serialized handoff with
   the original paused. Before staging or committing, the original must apply or merge the sidecar
   output, rerun drift and validation on the current tree, and update or relaunch the sidecar if
   later source changes touched more routable ownership/data-flow areas. Do not create public commits
   solely to feed sidecars; use Rewind checkpoints or temporary anchors for that proof boundary, then
   keep the normal verified slice commit as the public history unit.
9. If the readiness audit leads to pre-map infrastructure work such as `CMakePresets.json`,
   canonical `scripts/`, validation wrappers, CI files, or build-entrypoint cleanup, label that work
   as an audit-backed infrastructure slice before map enablement. Get the user's route acceptance
   first, verify and commit or clearly stage that slice separately where practical, and do not
   present it as "just the code map." After map enablement or major map edits, run the fresh-agent
   routing smoke described above before calling the setup complete. If it is skipped, say exactly why
   and list it as remaining work.
10. Preserve any existing package manager or project-specific dependency policy. Do not introduce vcpkg, Conan, containers, FetchContent, or submodules unless there is a concrete reason.
11. Keep CUDA and Vulkan optional through CMake cache options. For unspecified new GPU/3D/realtime/XR/cross-platform C++ projects, recommend and scaffold Vulkan-first: the normal `dev` preset is Vulkan-only, CUDA stays off unless the user explicitly chooses the CUDA lane or the requirements force CUDA.
12. Do not mix CUDA into a Vulkan-chosen or Vulkan-assumed project by default. Use CUDA only for explicit CUDA/Vulkan interop, CUDA-specific compute, NVIDIA-only libraries, CUDA graphs, or custom CUDA kernels. When the user explicitly chooses CUDA, Vulkan may be added for presentation, realtime visualization, XR, swapchain/display work, or interop if the boundary is documented.
13. For new Vulkan template work, target Vulkan 1.3 with Vulkan-Hpp RAII, synchronization2, dynamic rendering, GLSL compiled by `glslc`, SPIR-V validation by `spirv-val`, and optional portability-enumeration support for MoltenVK-style platforms.
14. For realtime Vulkan apps or generated viewport preflights, keep CPU/software Vulkan lanes
    diagnostic-only unless the project explicitly opts into them. A default runtime/readiness test
    that selects llvmpipe/Lavapipe, a virtual GPU, or any CPU physical device must report a hardware
    backend blocker instead of producing a green realtime-viewport claim. Use capability dumps,
    loader/ICD environment inspection, and project-owned readback to classify whether the failure is
    SDK/tooling, loader, ICD visibility, physical-device selection, queue/swapchain support, or
    surface/present support before changing renderer code.
15. Register tests with CTest labels so quick, GPU, GUI, Vulkan, CUDA, shader, compute, render, validation, perf, and nightly lanes can be selected independently.
16. For GPU performance work, use the generated optimization loop when available. Start from
    the target project's `docs/GPU_OPTIMIZATION_LOOP.md`; when working in this source package before
    that doc has been copied, use the bundled template copy at
    `assets/app-library-template/docs/GPU_OPTIMIZATION_LOOP.md`. Create a representative target table
    with explicit success criteria so agents do not chase isolated microbenchmarks, record a fixed
    baseline, run hardware profiling such as Nsight Compute/NCU, Nsight Graphics GPU Trace, vendor
    tools, timestamp-query summaries, or project counters before edits when counters are available,
    record the tool gap when they are not, use roofline/SOL diagnosis when metrics are available, log
    evidence-backed hypotheses before edits, optionally run breaking-point search for workload
    limits, test one focused hypothesis at a time, run two or more validation passes before
    benchmarking an attempt, keep only correct improvements, revert rejected or divergent attempts,
    use `plan-round` for beam-style parallel worker slots when exploring multiple bottlenecks, use
    `next` for move-on decisions, and generate a consolidation report before claiming speedups.
17. Treat profiling as evidence only when the report is readable and the command matches the workload being claimed.
    For Nsight Systems stats readback, prefer the bundled `scripts/run_nsys_smoke.sh` because it
    probes the installed report and format surface. If writing a manual `nsys stats` command, inspect
    `nsys stats --help-reports` and `nsys stats --help` first, use explicit reports such as
    `vulkan_api_sum,osrt_sum,nvtx_sum` or `cuda_api_gpu_sum,cuda_gpu_kern_sum,osrt_sum,nvtx_sum`,
    include `--force-export=true`, and do not use legacy `--report summary` or unsupported
    `--format text` assumptions.
18. Before greenfield scaffolding, major backbone edits, or native GPU architecture brainstorming,
    read `references/project-archetypes.md` and pick the closest lane: Vulkan app, CUDA library,
    CUDA+Vulkan combined/interop app, native GUI/HUD/editor UI, AI runtime, neural 3D viewer,
    sculpting/brush tool, grooming/brush/fur tool, glTF/runtime asset viewer, renderer backbone/runtime mesh pipeline,
    DCC scene pipeline,
    volume/voxel renderer, animation runtime, material pipeline, CAD geometry tool,
    3D/physics/GPU simulation tool, or XR app.
19. When borrowing patterns, APIs, examples, or dependency ideas from external 3D/AI/GPU projects,
    or when brainstorming native GPU architecture that will recommend solvers, rendering paths,
    dependencies, subsystem boundaries, or MVP order, use the nested donor router before giving the
    recommendation. Read `references/donor-library/README.md` for policy; when the prompt uses VFX
    studio, game studio, or native engineering infrastructure vocabulary, use the production overlays
    under `references/donor-library/production/`; use `references/donor-library/agent-lookup.md`
    when the prompt is broad, overlapping, or exploratory; then open the smallest matching category
    set, choosing one primary category first when possible, and only the donor profiles those
    categories name. Treat donors as domain references first: a CUDA, Vulkan, OpenCL, DirectX, CPU,
    or DCC donor can still guide another target backend. Keep the selected implementation lane fixed,
    translate backend-specific details through the active lane skill, and keep permissive donor code,
    dependency candidates, and study-only references separated. If the prompt asks for the best
    current choices, state of the art, ceiling, or recently moving GPU/tooling options, web-check
    upstream or primary sources before ranking options. For broad realtime simulation/graphics
    brainstorms that mention fluid, fire, smoke, water, destruction, shatter, neural 3D,
    upscaling/reconstruction, XR, or renderer architecture, do the web ceiling check even if the user
    did not use "current" or "best."
20. Do not route design-only, frontend-only, storyboarding, generic image/video, generic product-AI UI, plain text rendering, or ordinary data import requests through this skill unless the user explicitly asks for native C++ GPU implementation, C++/CUDA/Vulkan infrastructure, or donor-reference selection.

For long-running target-project implementation, repeat this rhythm between slices:

1. Ground the slice in skills, code map, donors, and any needed current-source research.
2. Name the expected files and verification gates, then either make the smallest coherent
   implementation/probe step or stop with a concrete blocker; do not reopen broad orientation after
   the route is already sufficient.
3. Implement the smallest coherent production slice.
4. Verify with the target repo's build, tests, harness, screenshot, or profile evidence appropriate
   to the change.
5. Update code-map, control-harness registry, and donor/provenance docs when the slice changed their
   routed behavior, route inventory, product-shape evidence, or risky backend/UI/solver decisions.
   If a code-map sidecar supplied map changes, apply or merge its patch/output only after checking
   the sidecar's fixed snapshot against the current tree.
6. Clean generated probe junk from the source root, review `git status`, keep unrelated user changes
   out, run both `scripts/check_code_map_drift.py --require-enabled` and
   `scripts/validate_code_map.py --require-enabled` before staging/committing when the map is
   enabled, relaunch the sidecar or update the map yourself if current changes outgrew the sidecar
   snapshot, check diff hygiene, and commit the verified slice with exactly one allowed
   `Commit-Origin` trailer: `agent-slice` or `user-requested`.
7. Continue to the next slice only after the commit is in place, or after clearly reporting why a
   commit was intentionally skipped.

## Existing Project Code Map Readiness Protocol

Before enabling a maintained code map for an existing repo, confirm the repo can support durable map maintenance:

1. Treat an explicit user opt-in as permission to audit, not as permission to enable or restructure. First tell the user that the next step is a non-destructive audit and that choices come after evidence.
2. Run `scripts/bootstrap_code_map.py --audit-existing` and review its stdout. Save it with `--write-audit` only if the user wants `docs/CODEMAP_BOOTSTRAP_AUDIT.md` recorded.
3. Review build entrypoints, source/include ownership, tests, validation scripts, CI, docs, shader/CUDA/Vulkan ownership, generated build artifacts, and dependency/vendor boundaries.
4. Present audit evidence before choices: list concrete findings, evidence paths, what restructuring would actually be needed, and the cleanup cost. If the audit has no concrete restructuring findings, say that clearly and do not manufacture a restructure recommendation.
5. Classify cleanup cost as none, small, medium, or large. Tie the estimate to concrete findings, not general taste.
6. Only after the evidence summary, present the user with three choices: restructure first, keep the current layout and document exceptions in the map, or decline the map for now.
7. If the user chooses restructure first, create or confirm a recent git commit, propose a focused restructuring plan, validate the project after the restructure, and only then enable the map.
8. If the user chooses an audit-backed small infrastructure slice first, keep it scoped, call it out
   as pre-map infrastructure, verify it, and avoid burying it in the code-map completion claim.
9. If the user chooses preserve-as-is, enable the map and record the nonstandard layout explicitly in the relevant subsystem docs. If generated map files already exist, rerun enablement with `--force` only after the user accepts replacing them.
10. After enabling or materially changing the map, run a read-only subagent or fresh-agent routing smoke when possible. If the smoke is unavailable or not run, say the map is structurally valid but routing evidence is pending.
11. If the user declines, run `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked.

## Bundled Assets

- `assets/app-library-template/`: full app+library C++/Vulkan-first/CUDA-optional starter layout with CMake presets, CTest, sample C++ library/app, Vulkan default targets, explicit CUDA and combined CUDA+Vulkan build lanes, docs, clang tooling, and GitHub self-hosted GPU CI. Real CUDA/Vulkan external-memory or semaphore interop requires project-specific additions beyond the combined build preset.

## Bundled References

- `references/donor-library/`: curated donor-source library for Vulkan foundation tooling, glTF/runtime assets, WebGPU/WebGL, native GUI/HUD/editor UI, renderer backbones, path tracing, engine architecture, runtime mesh pipelines, graphics, rendering, geometry, 3D/physics/GPU simulation, AI runtimes, ML compilers, CUDA kernels, neural 3D, sculpting/brush tools, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, XR, and native engineering infrastructure. Donor backend signals describe the upstream implementation, not a restriction on target lanes. Start with `references/donor-library/README.md`; for VFX studio, games, or native infrastructure vocabulary use `references/donor-library/production/`; for broad or ambiguous donor requests use `references/donor-library/agent-lookup.md`, then load the smallest category set needed for the active task.
- `references/project-archetypes.md`: lane-selection guide for CUDA-only, Vulkan-only, CUDA+Vulkan interop, native GUI/HUD/editor UI, AI runtime, neural 3D, grooming, glTF/runtime assets, renderer backbone/runtime mesh pipeline, DCC, volume, animation, material, CAD, 3D/physics/GPU simulation, and XR projects.

## Bundled Scripts

- `scripts/scaffold_gpu_cpp_project.py`: create a new project from the template.
- `scripts/apply_studio_backbone.py`: copy backbone files into an existing repo without overwriting by default.
- `scripts/validate_studio_backbone.py`: check that required backbone files are present and, with `--integration`, that CMake/CTest register expected labeled tests.
- `scripts/check_dev_tools.sh`: verify compilers, CUDA, Vulkan, shader, and optional profiler tools.
- `scripts/select_idle_gpu.sh`: choose an idle NVIDIA GPU, optionally constrained by `GPU_ALLOWED_INDICES`, using utilization and display-server subtraction.
- `scripts/run_compute_sanitizer.sh`: run a command or GPU CTest preset under Compute Sanitizer.
- `scripts/run_vulkan_validation.sh`: run a Vulkan command or validation CTest preset with Khronos validation enabled.
- `scripts/dump_vulkan_capabilities.sh`: capture `vulkaninfo` summary and text reports for loader/ICD diagnostics.
- `scripts/run_nsys_smoke.sh`: run an app/probe under Nsight Systems, discover supported stats
  reports/formats from the installed `nsys`, and read back lane-appropriate explicit reports with
  forced SQLite export.
- `scripts/run_gpu_optimization_loop.py`: initialize, baseline, hardware profile, log hypotheses, search breaking points, plan beam-style rounds, attempt, keep/revert, orchestrate, and report evidence-gated GPU optimization sessions.
- `scripts/format_check.sh`: run clang-format in check-only mode.
- `scripts/tidy_check.sh`: run clang-tidy against a compile database in check-only mode.
- `scripts/bootstrap_code_map.py`: audit existing repo readiness, enable, or decline the opt-in CppStudio codebase map for a target repo; on enable it also installs missing repo-local validator/drift wrapper scripts that forward to the installed CppStudio skill.
- `scripts/validate_code_map.py`: validate enabled or declined CppStudio code-map state and manifest links.
- `scripts/check_code_map_drift.py`: pre-commit helper that checks changed routable paths against an enabled code-map manifest.

## Acceptance

For a new scaffold, verify:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

For an existing target repo, prefer the repo's own documented validation path and preset names over
the scaffold defaults above. Check `CMakePresets.json`, validation docs, target scripts, and the
maintained code-map build subsystem before choosing commands.

For this skill itself, verify:

```bash
${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py ${HOME}/.codex/skills/cpp-cuda-vulkan-studio
```
