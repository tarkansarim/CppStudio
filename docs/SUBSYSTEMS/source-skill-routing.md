# Source Skill And Agent Routing

Owns the user-level `cpp-cuda-vulkan-studio` skill source, CppStudio repo onboarding, Vulkan-first
lane policy, code-map trigger metadata, active-map navigation behavior, donor-router entrypoints, and
generated-project workflow instructions.

## Canonical Docs

- `AGENTS.md`
- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/cppstudio-project-planner/references/project-intake.md`
- `skills/cppstudio-project-planner/references/choice-matrix.md`
- `skills/agentic-control-harness/SKILL.md`
- `skills/agentic-control-harness/references/control-harness.md`
- `skills/viewport-session-testing/SKILL.md`
- `skills/viewport-session-testing/references/viewport-session-testing.md`
- `skills/important-instruction-ledger/SKILL.md`
- `skills/important-instruction-ledger/scripts/important_instruction_ledger.py`
- `skills/vulkan-compute-sync/SKILL.md`
- `skills/modern-cpp-cmake/SKILL.md`
- `skills/modern-cpp-cmake/agents/openai.yaml`
- `skills/cuda-kernel-authoring/SKILL.md`
- `skills/cuda-kernel-authoring/agents/openai.yaml`
- `skills/gpu-profiling-workstation/SKILL.md`
- `skills/gpu-profiling-workstation/references/TOOL_INVENTORY.md`
- `docs/agent-context/SLICE_WATCHLIST.md`
- `docs/agent-context/slice-watchlist.jsonl`
- `docs/agent-context/IMPORTANT_USER_INSTRUCTIONS.md`
- `skills/cpp-cuda-vulkan-studio/references/project-archetypes.md`

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/cppstudio-project-planner/references/project-intake.md`
- `skills/cppstudio-project-planner/references/choice-matrix.md`
- `skills/agentic-control-harness/SKILL.md`
- `skills/agentic-control-harness/references/control-harness.md`
- `skills/viewport-session-testing/SKILL.md`
- `skills/viewport-session-testing/references/viewport-session-testing.md`
- `skills/important-instruction-ledger/SKILL.md`
- `skills/important-instruction-ledger/scripts/important_instruction_ledger.py`
- `skills/vulkan-compute-sync/SKILL.md`
- `skills/modern-cpp-cmake/SKILL.md`
- `skills/modern-cpp-cmake/agents/openai.yaml`
- `skills/cuda-kernel-authoring/SKILL.md`
- `skills/cuda-kernel-authoring/agents/openai.yaml`
- `skills/gpu-profiling-workstation/SKILL.md`
- `skills/gpu-profiling-workstation/references/TOOL_INVENTORY.md`
- `docs/agent-context/SLICE_WATCHLIST.md`
- `docs/agent-context/slice-watchlist.jsonl`
- `docs/agent-context/IMPORTANT_USER_INSTRUCTIONS.md`
- `.codex/skills/cppstudio-repo-onboarding/SKILL.md`

## Current External Doctrine Posture

- Sortie assistant-pack adoption research is provenance only. CppStudio may cherry-pick generic
  doctrine into reusable skills, but must not import Sortie runtime mechanics such as Sortie MCP
  call sequences, L0/L1/L2 Harness roles, checkpoint/rewind/gauntlet machinery, workflow graph
  execution, agent resource defaults, or `.sortie` artifact contracts.

## Current Skill Discovery Posture

- Bundled CppStudio skill frontmatter descriptions are compact discovery triggers only. Detailed
  routing rules, trigger phrase lists, examples, matrices, lifecycle rules, and operational policy
  belong in the skill body or lazily read references so startup skill discovery stays within budget.
- When shortening frontmatter, preserve the moved discovery details in source skill bodies or
  references, then validate both description lengths and representative trigger/detail probes before
  rollout.

## Current Code-Map Bootstrap Posture

- Greenfield code-map choice is a hard pre-source gate. Before the first source/build/app/test/docs
  implementation slice, agents must get an accepted, declined, or explicitly deferred code-map
  decision and must not treat a plan bullet that says "code-map choice" as acceptance.
- Existing-project code-map opt-in is evidence-first: agents must run the non-destructive readiness
  audit, present concrete findings and cleanup cost, and only then ask whether to restructure,
  preserve the current layout with documented exceptions, or decline the map.
- Code-map completion is evidence-gated: validation proves schema/state only. After enablement or
  major map edits, agents must run a read-only subagent or fresh-session routing smoke when that
  testing route is available before saying future agents can use the map reliably. The smoke should
  stop after the first confident subsystem route and exact source/test paths, not expand into a full
  source audit. A smoke that skips manifest/state reads, over-reads broadly, edits files, or never
  produces a final routing report is partial or failed evidence.
- Trigger-regression coverage includes dedicated code-map cases for existing-project bootstrap,
  enabled-map maintenance closeout, sidecar maintenance, and routing-smoke proof. Keep those cases
  aligned with the code-map bootstrap scripts and source-skill rules whenever the protocol changes.
- Enabled code maps have an ordinary pre-commit maintenance gate. Agents must run
  `scripts/check_code_map_drift.py --require-enabled --strict-review` when available before
  committing a verified source slice, then update the manifest and matching subsystem doc for any
  changed routable path that is not covered. The checker catches path coverage; semantic
  ownership/data-flow changes still require agent judgment even when the path is already routed. If
  strict review reports covered source changes with no map-file edit, the worker must resolve that
  signal before staging by updating the map, launching the sidecar itself, or rerunning with
  `--reviewed-no-map-change` only after a real semantic review.
- Code-map sidecars are bounded maintenance lanes, not parallel source workers. Use one when a drift
  hook/check reports map work, a long-running slice hits a planned maintenance interval, ownership or
  data-flow changes make subsystem docs stale, new or moved routable files appear, or the main worker
  needs to reduce context bloat. When `agent-tmux` is available, the preferred guarded helper is
  `agent-tmux codex-code-map-sidecar <repo> <anchor> [focus]`; the drift checker prints that command
  as a worker action, not a user prompt, for uncovered drift and no-map-touch semantic review output. The sidecar
  reads a named fixed snapshot such as a Rewind checkpoint, temporary git anchor, commit, isolated
  worktree copy, or archive, returns code-map-only patch output or map-file replacements, and records
  its snapshot assumptions. It must not edit the original worker's live worktree while source work
  continues; same-worktree edits require a serialized handoff with the original paused. The original
  worker owns the final reconcile: apply or merge the sidecar result, rerun drift and validation on
  the current tree, and update or relaunch the sidecar if later source changes touched more routable
  areas.
- Target-repo instruction files are sensitive. `AGENTS.md`, `CLAUDE.md`, repo-local skills, and
  agent metadata must be named separately in status reports when dirty or changed; they must not be
  hidden under generic "unrelated dirty files" wording.

## Current Donor-First Research Posture

- Substantial greenfield project intake has a hard Plan-mode handoff after the pre-plan research
  artifact. Research briefs may include recommended defaults and alternatives, but unresolved
  template, GUI/input stack, code-map, authoring-model, GPU lane, dependency, donor, or validation
  decisions must not become inline normal-chat questions unless Plan mode is unavailable or the user
  explicitly waives it. Supervisor, replay, or test prompts asking a worker to write a plan or report
  a chosen stack do not override that gate.
- Donor-first means local donor-library routes are opened before code or product-shape decisions.
  If no suitable donor exists, or the local donor route is stale or too generic for a new subsystem,
  agents must run web/upstream research against current primary sources before designing the
  implementation. "Upstream research" means public current-source research such as official repos,
  docs, samples, standards docs, vendor docs, papers, release notes, and peer-tool references; it is
  not permission to fill gaps from model memory.
- Donor realignment is now an explicit stall gate. If a visible bug, interaction bug, product-shape
  problem, renderer/sim behavior issue, or domain algorithm slice survives two focused attempts or
  about 20 minutes without direct symptom improvement, agents must stop local patching and reopen the
  code map, matching donor route/profile, GUI/product route when applicable, and current upstream or
  peer-tool sources before another code edit. The current-source pass must be substantive enough to
  answer the exact stuck layer, using multiple current primary or upstream sources when available and
  recording links or queries, proven facts, stale/conflicting evidence, and next-attempt impact. The
  realignment note must name donor facts, local mismatch, failed hypotheses, keep/revert decisions
  for speculative patches, and the next smallest proof.
- Long visual/reference/calibration lanes now have an acceptance-artifact cutover gate. Agents must
  define the final artifact up front and stop after repeated red wrapper/OSTM/scenario runs, repeated
  source probes, or an extended unchanged artifact window. Internal diagnostics, debug buffers,
  generated intermediates, route inventory, or wrapper success are not progress unless the final
  artifact improves. The required ledger separates new evidence, prior work, still-red acceptance,
  debug-only evidence, failed hypotheses, keep/revert decisions, and continue/cutover options backed
  by a narrow `codex exec` stuck probe plus current web/upstream research into the failing layer.
  Local source-only analysis is not enough after this stall gate, and a token web search is not
  sufficient. The research pass must inspect enough current primary/upstream sources to explain the
  stuck layer, then record links or queries, source facts, stale/conflicting evidence, and decision
  impact. Cutover must still preserve any user-named upstream, SDK, shader, renderer, file-format, or
  port target; unrelated peer tools are diagnostic references, not replacement targets. Stale-context
  or peer-tool lanes that conflict with the required reference target must be filtered out as rejected
  or diagnostic-only before options are shown to the user. A fresh scoped adversarial review is
  required before further patching if the next attempt still leaves the artifact red.
- Substantial greenfield and architecture-setting research must be durable. Agents should write a
  target-project `docs/planning/RESEARCH_BRIEF.md` before implementation, combining local donor
  routes and curated web/upstream sources with short descriptions, project benefits, freshness or
  primary-source notes, and direct-donor/dependency/reference-only caveats. Chat-only research is not
  enough for these cases.
- Source-access failures are quality gates, not automatic aborts or workaround permission. If a web
  search finds a source but opening it fails, agents may continue only when equivalent or stronger
  primary/upstream sources, local donor profiles, or current peer-tool docs still cover the affected
  decision. The failed URL, exact error, substitute evidence, and blocked-or-not decision impact must
  be recorded in the research artifact. If the failed source is unique for a critical architecture,
  GUI/product, solver, dependency, input, license, or validation choice, agents must stop and report
  the blocker instead of producing a lower-confidence plan.
- Durable research briefs should include `Project Dos And Don'ts`, split into app/domain and
  GUI/product-surface rules. Each rule needs source evidence, affected subsystem or UI surface, and a
  validation signal. GUI rules must cite peer-tool, UI-framework, or donor evidence for layout,
  control placement, icon/text affordance, viewport/timeline/inspector conventions,
  debug-vs-product boundaries, and visual proof.
- High-quality standalone artist tools that name polished peers such as ZBrush, Mudbox, Maya,
  Houdini, Substance, Nuke, Unreal Editor, or Blender are product-like desktop applications for GUI
  stack selection before they are Vulkan/realtime utilities. Agents should compare Qt-style desktop
  shells against immediate-mode UI and prefer the polished shell when available or acceptable,
  keeping Dear ImGui for overlays, diagnostics, or explicitly approved immediate-mode product
  surfaces.
- Interactive artist, game, VFX, DCC, simulation-editor, technical-art, viewer/editor, brush, paint,
  grooming, terrain, material, rigging, animation, layout, lighting, and effects tools now require a
  primary visible-loop gate before implementation. The loop is derived from domain donors and peer
  tools, then records user action, state changed, visible result, proof route, and secondary breadth
  blocked until the loop is proven. This is generic product-slice discipline, not a project-specific
  sculpting rule.
- User-facing verification is the primary acceptance surface for interactive work. Backend/control
  routes, OSTM jobs, fake-host smokes, nonblank screenshots, and JSON state are supporting evidence
  until the real visible control, interaction shape, committed state, and visible result are proven.
  Hidden CLI-only record/replay lanes are insufficient for artist-facing tools once the app has an
  interactive surface; visible record/stop/replay or equivalent capture affordances, status, and
  latest-artifact readback are required unless explicitly opted out.
- Interactive slices now require an interaction-shape contract. A click, click-drag, continuous
  stroke, scrub, lasso, gizmo move, camera orbit, timeline drag, node connection, stylus stroke, or
  palette selection must be tested as that shape. Continuous actions need held-button or
  stylus-contact move samples, path or sample assertions, pointer/hit/readback along the path, and
  visible or semantic before/after evidence; a single press/release smoke cannot prove a continuous
  gesture.
- Stroke-like visible bugs now require a human-input UI session through the real viewport, canvas, or
  widget event path. Agents must compare requested pointer path to committed hit/edit path or
  affected element coverage, and directly assert reported material/overlay/product-surface
  appearance issues. Generic revision/checksum deltas, nonblank screenshots, backend endpoints,
  product scorecards, and one-point dab smokes are only supporting evidence. If the scenario does not
  exist, agents add the smallest diagnostic route and run it as before proof before changing product
  behavior.
- Visible closeout must keep functional and product-quality proof separate. A path-coverage pass,
  revision advance, changed-vertex count, or "no debug overlay" assertion cannot close broader
  user-named concerns such as live stroke direction, cursor-hit feel, viewport shading quality, or
  donor-matched material appearance. Agents must classify each user-named visible concern as
  resolved, unresolved, or not-tested with artifact paths and next proof before moving to feature
  breadth.
- Live-contact artist tools have a stricter pre-release proof gate. For sculpting, painting,
  grooming, terrain, drawing, or transform behavior that should update while contact is held, agents
  must prove document/render revision, dirty region, semantic trace, or fresh capture changes after a
  held-contact move and before release. Release-only deformation is a batched diagnostic behavior
  unless explicitly requested; it is not acceptable proof for live sculpting or similar tools.
- Visible/domain slices now also require a concrete first proof object or state. Agents must name the
  actual primitive, scene, generated asset, graph, dataset, or interaction target that makes the loop
  visible, justify it from donor or peer-tool evidence, and keep tiny numeric fixtures separate from
  the user-facing proof object. Vague "generated target" or "sample object" language is not enough.
- Tool families now require shared substrate ownership before tool proliferation. Common selection,
  active-tool state, input sampling, coordinate mapping, pressure/falloff, masks, undo/replay, cursor
  overlays, dirty-resource updates, serialization, harness readback, and validation scenarios should
  be factored once before sibling tools are added.
- Substantial software plans now use a six-level planning depth contract. Level 0 is intake/context,
  Level 1 is research/ceiling, Level 2 is whole-product scaffold, Level 3 is donor coverage and
  quality contract, Level 4 is slice readiness, and Level 5 is implementation/closeout proof. Serious
  native C++ GPU, artist, game, VFX, DCC, simulation-editor, and technical-art tools default to
  Level 3 before source files are created. The Level 3 donor coverage matrix maps high-salience donor
  and peer-tool expectations to included, deferred, rejected, or blocked capabilities with reasons
  and validation signals, so a plausible scaffold cannot hide missing fundamentals. Each scaffolded
  implementation slice still requires a Level 4 packet naming donors, source/API contracts, shared
  and unique behavior, expected files, blocked scope, validation evidence, rollback/checkpoint state,
  and parallel safety before code begins.
- Donor coverage now means explicit donor feature disposition, not citation. If a worker uses a
  donor shader, brush, renderer, solver, UI pattern, importer, optimizer, or subsystem, the plan must
  inventory important donor features and mark each one included, deferred, rejected, or blocked with
  reasons, owner/return condition, and validation signal. For shader donors, agents break down
  stages/passes, entry points, inputs/outputs, descriptor/uniform contracts, spaces/units,
  variants/macros, render states, sampling/filtering, lighting/material terms, quality features, edge
  cases, and validation signals before planning. Silent omissions from donors are source planning
  failures.
- Parallelization planning is a map, not an automatic worker launch. Plans should identify candidate
  independent lanes, frozen shared contracts, file/subsystem ownership, and integration/validation
  handoffs, while keeping tightly coupled C++/GPU/UI/resource-lifetime work sequential until the
  contracts are stable or the supervisor/user explicitly chooses a parallel split.
- New reusable references discovered during web research are first saved as target-project donor
  candidates, normally `docs/planning/DONOR_CANDIDATES.md` or a donor-candidates section in the
  research brief. That candidate capture is required evidence even when global promotion happens
  immediately afterward. They are promoted into CppStudio's source donor library only during explicit
  donor-library maintenance or when the user explicitly asks to extend the reusable/global donor
  library, and then rolled out to user-level; installed user-level skills are not hand-edited as
  donor-library source. If the source repo path is unavailable from a target project, agents keep the
  project-local candidate and ask for the CppStudio source path instead of patching `~/.codex/skills`.
- Risky backend, renderer, GUI/editor, solver, harness, or authoring-model migration slices must
  close out donor provenance. If a target repo owns a source/provenance doc, agents update it with the
  local donor routes, current upstream links, study-only/license caveats, and any inferred decisions;
  otherwise they record that evidence in the validation or status docs for the slice.

## Current Supervised Worker Posture

- Slice watchlists are active supervision state, not passive chat notes. For substantial slices,
  worker nudges, direct source edits, slice approval, commits, and closeout, agents use
  `important-instruction-ledger` to write or review `docs/agent-context/SLICE_WATCHLIST.md` in the
  target or owning source repo. User constraints are one input; donor facts, plan gates, code-map
  state, visible-loop expectations, blocked scope, verification risks, review findings, and prior
  misses are also watch items.
- Implementation slice approval requires the relevant Level 4 readiness packet as a primary
  artifact. Reading an old plan, passing the planning guard, or receiving a worker summary is not
  enough; the supervisor rejects source work when the detailed packet for that slice is missing.
- When a supervised tmux worker, subagent, or terminal agent makes, skips, or rejects a decision and
  the cause is unclear, the supervising agent interrogates the worker before claiming the cause or
  changing CppStudio rules.
- The interrogation asks for skill routes, donor routes, web/upstream sources, decision criteria,
  discovered gaps, and verification commands, then the supervising agent checks that answer against
  the transcript and files.
- Worker answers are evidence, not authority. If the worker is unreachable, supervisors inspect the
  available transcript and project files and state the uncertainty instead of inventing intent.
- Worker summaries are never enough to judge plan quality, implementation quality, or closeout.
  Supervisors must inspect the primary artifacts before saying a worker plan or slice is good:
  planning packets, research briefs, code-map state/index/manifest/subsystem docs, changed files or
  diff, validation logs, OSTM/control-harness artifacts, screenshots or semantic readbacks for
  visible work, ticket comments, and the relevant transcript tail.
- Planning packets and research briefs are live handoff artifacts. After source slices, commits,
  resolved blockers, or architecture choices land, agents must reconcile stale "planning only",
  "no source exists", or obsolete blocker language before the next major slice.
- Offscreen/background-manager evidence is terminal-state evidence only. Queued jobs are pending,
  manager-context script path failures should be rerun with absolute paths or explicit working
  directories, and external screenshots, app-owned screenshots, render-target captures, and semantic
  readback must be labeled by what they actually prove.

## Current Native UI Product-Fit Posture

- Native tool UI labels must expose critical semantic scope in visible text, not only in tooltips,
  docs, or harness readback. Preview, baked, destructive, local/published, approximate/final, and
  diagnostic/product distinctions need visible wording that screenshots and harness assertions can
  prove.
- GUI/editor/timeline/viewport/tool-surface work must create a compact UI convention table before
  changing layout or command widgets. The table records donor or peer-tool evidence, expected control
  location, icon/text convention, tooltip/accessibility text, enabled states, and proof method for the
  affected surfaces.
- GUI/tool-surface plans must preserve the primary visible interaction loop for the affected product
  surface before adding secondary controls or advertised modes. A palette, toolbar, graph, inspector,
  or timeline with extra entries is not product progress if the primary user action cannot be
  selected, applied, and observed through the real event path.
- Greenfield artist tools need a product-surface visual contract before source UI work: target
  peer-tool family, viewport prominence, palette density, icon/text balance, spacing, typography
  scale, color restraint, status/readback placement, and debug-control demotion. A default
  debug-looking UI is infrastructure, not a product milestone, unless the user explicitly requested a
  debug HUD.
- Universal tool commands such as play, stop, step, save, undo, redo, select, transform, visibility,
  lock, zoom, and delete should use recognizable icon affordances when the toolkit supports them.
  Prominent text controls for those commands require donor evidence or an explicit accessibility,
  localization, or toolkit constraint.
- GUI closeout needs a visual product-fit review against the convention table, not just a nonblank
  screenshot. The review checks placement, icon/text fit, visual hierarchy, clipping/overlap,
  debug-vs-product feel, and domain conventions such as timeline, viewport, inspector, and node graph
  placement.

## Current Vulkan Runtime Readiness Posture

- Realtime Vulkan viewport readiness is hardware-backed by default. CPU/software Vulkan paths such as
  llvmpipe or Lavapipe are diagnostic-only unless explicitly opted into by the target project.
  Agents must not convert a CPU-selected Vulkan preflight into a green realtime viewport claim; they
  should classify SDK/tooling, loader, ICD visibility, physical-device selection, queue/swapchain,
  and surface/present support separately before changing renderer code.

## Current GPU Feature Regression Posture

- GPU capability failures are hypotheses until the exact requested feature lane is tested on the
  target device. Before agents hide, disable, downgrade, rewrite, or change tests around a Vulkan,
  CUDA, ray-tracing, interop, upscaler, denoiser, shader-model, profiler, or hardware-extension
  feature, they must exercise the exact forced-feature path when one exists.
- Nearby success is supporting evidence only. A different renderer primitive, fallback backend,
  non-interop path, or generated profile file must not be accepted as proof for the feature being
  changed.
- Project engineering memory, failed-probe ledgers, old docs, and capability readbacks are evidence
  to challenge with current target-device repros and known-good/known-bad comparisons. If fresh
  evidence contradicts durable memory, the target repo's memory or failed-probe ledger should be
  updated with the new boundary.
- If the user says a feature used to work, names a suspected commit or boundary, or asks for
  historical comparison, that comparison stays active until completed or explicitly cleared before
  capability gates, UI policy, or tests are changed.

## Current Target-Slice Execution Posture

- After agents name a bounded target-project slice with code-map route, donor/reference grounding,
  expected files, and verification gates, they must move to the smallest implementation/probe action
  or report a concrete blocker. Broad re-orientation after that point is a process miss.
- Slice task lists are living alignment tools. When local facts, donor/upstream evidence,
  validation, or probes invalidate a task-list assumption, agents should revise the task list in
  place with the new fact, invalidated assumption, bounded replacement task, and validation change.
  They should continue on internal realignments that preserve intent and pause only for user-facing
  product, stack, scope, dependency/license, or explicit-constraint changes.
- Midstream major feature requests reopen the planning gate. Agents should update the target
  research brief, implementation slice plan, donor-candidate notes when relevant, and dos/don'ts or
  decision records after checking code-map routes, donor routes, current upstream sources, and local
  capability facts. A chat-only answer is not enough when the feature affects renderer, GUI,
  authoring model, solver, dependency, hardware, or validation architecture.
- Greenfield target projects that are expected to use verified-slice commits need usable Git before
  the first source slice. A Codex worker that sees `.git` as an empty read-only mountpoint in a
  brand-new directory is reporting sandbox/mount-namespace state, not an ordinary project fact.
  Agents must not chmod, delete, or unmount that placeholder. If the supervising agent has normal
  host shell access to the real target path, it should initialize Git there from outside the worker,
  then relaunch or retry the worker from a clean checkpoint. Ask the user only when that host-side
  initialization is unavailable or risky.
- If a target-project slice is interrupted, stopped, or rejected after partial unverified edits,
  agents must either revert only the incomplete slice edits or explicitly report the dirty files and
  ask whether to preserve them. They must not leave ambiguous partial state while claiming the slice
  is ready.
- In enabled-code-map repos, agents must run both the drift checker and the validator before staging
  or committing a verified source slice. `validate_code_map.py` proves schema/state only; it is not a
  substitute for `check_code_map_drift.py`.
- Agentic control harness roadmap/readiness fields are part of the verified slice contract. If a
  slice proves one prerequisite named by `next_required_slice`, `blockers`, `prerequisites`,
  readiness booleans, feature eligibility, or backend-selection gates, agents must update the
  machine-readable readback before commit or expose completed-versus-remaining prerequisite fields
  when a broad gate name intentionally remains.
- Harness readiness and success fields must prove their exact documented invariant. Weaker nearby
  conditions need separate field names instead of setting a broad readiness field true.
- Harness route changes require route-inventory reconciliation before commit: registered public
  routes, the top discovery list, detailed endpoint docs, examples, and optional JSON inventory must
  match unless a route is explicitly internal-only.
- UI-heavy harnesses should expose an action/affordance inventory when practical, including action id,
  visible text, icon presence/name, tooltip, shortcut, surface location, enabled state, command target,
  selected-object requirement, and proof status.
- GUI interaction bugs and pointer-driven tool slices now require scenario evidence that exercises
  the real widget/action or viewport/canvas event path, including click/selection latency and
  pointer-mapping readback such as widget geometry, device-pixel ratio, render-target coordinates,
  hit data, committed edit point, and fresh visual proof when practical.
- Sculpt, brush, paint, groom, stroke, and high-poly mesh slices now have a donor-specific gate:
  before changing brush behavior, palette selection, viewport hit tests, stroke sampling, pressure,
  falloff, masks, high-poly storage, or dirty uploads, agents must open the sculpt/grooming donor
  route. Mesh sculpting starts with the Blender Sculpt Brushes study-only profile before generic
  geometry, renderer, or GUI donors, and the slice plan needs a donor mapping plus user-equivalent
  before/after proof.
- User-reported bug fixes require a before/after proof gate before agents present the fix: reproduce
  the exact reported behavior first, capture before evidence, rerun the same or equivalent scenario
  after the fix, and compare in the symptom's own terms. Visible GUI/windowed bugs should route
  automated scenarios, smoke, screenshots, and proof through `ostm` when available; otherwise agents
  use the target repo's approved nonblocking launcher/smoke manager and state that OSTM evidence is
  unavailable. Direct foreground app launches are only for explicit manual/user inspection or bounded
  launch-command proof. Rewind is used as the rollback anchor before stacked GUI probes. Visible GUI
  bugs now have an explicit UI-blind failure mode: if the agent cannot observe the actual surface, it
  must say so before more edits and must not present harness-only/JSON-only progress as a visible
  fix. Identical, self-confirming, backend-only, or too-narrow evidence is not a fixed claim; after
  one blocked proof-route attempt, agents stop expanding harness infrastructure for that bug and
  choose a bounded app-side fix, repaired observation path, manual visible evidence request, or stuck
  report.
- User-facing desktop launch commands require human-visible launch proof: exact command, intended
  app process/window identity, terminal-title false-positive rejection, mapped/focusable visibility,
  workspace/desktop and geometry readback, control-harness responsiveness, and clean shutdown of the
  specific launched instance.

## Update When

- skill trigger description, workflow, acceptance, or bundled script list changes
- Vulkan/CUDA lane policy changes
- project archetype routing changes
- the repo-local onboarding skill changes
- code-map readiness, bootstrap, or maintenance behavior changes for agents
- code-map sidecar lane triggers, snapshot/anchor requirements, or final reconcile gates change
- target-repo code-map authority or map-first navigation behavior changes
- donor-grounding or web-ceiling-check expectations for native GPU brainstorming/design proposals
  change
- GPU feature capability, exact-lane proof, stale-memory challenge, or used-to-work regression
  comparison behavior changes
- durable project-local research artifact or donor-candidate capture requirements change
- research source-access failure handling or quality-floor behavior changes
- missing-donor promotion rules change, including when agents promote discovered web/upstream donors
  into the CppStudio source repo instead of leaving only target-project candidates
- project-specific dos and don'ts research-artifact requirements change, including GUI/product-surface
  best-practice capture
- primary visible-loop planning, shared-substrate, or slice-order rules change for interactive
  artist/game/VFX/DCC tools
- artist-input or tablet/stylus planning defaults change, including when mouse-first window/input
  stacks must be demoted for brush, sculpt, paint, groom, terrain, texture, or stroke tools
- native C++ GUI/HUD/editor UI skill routing or option-presentation behavior changes
- initial native C++ GPU project planning, Plan mode handoff, template-choice, or artist-input
  planning behavior changes
- project authoring-model/source-of-truth research expectations or decision gates change
- agentic control harness routing, autonomous app testing expectations, launch/control registry, or
  visual/UI observation behavior changes
- control-harness route inventory, readiness field exactness, or UI affordance inventory behavior
  changes
- hard gates that require agents to open local skills, maintained code-map routes, and donor-library
  categories before code changes or product-shape decisions
- supervised-worker interrogation rules change, including when agents must question a tmux worker or
  subagent before drawing conclusions from unclear behavior
- supervised-worker artifact-audit gates change, including when summaries are insufficient, planning
  packets need lifecycle reconciliation, or background/OSTM evidence must reach a terminal state
- code-map bootstrap script authority, code-map schema validation, or generated CMake probe cleanup
  requirements change
- code-map drift-check or pre-commit map-maintenance requirements change
- GUI/windowed verification routing changes, including when agents should use target smoke scripts,
  launch wrappers, absolute script paths, or explicit working directories with offscreen/background
  managers
- DCC/editor command-surface rules change, including when structural graph, scene, timeline, or
  layer edits should use editor actions, menus, shortcuts, context actions, or toolbar affordances
- GUI/action verification rules change, including when harnesses should introspect actual toolkit
  actions, menu entries, shortcuts, context surfaces, enabled states, or distinguish metadata claims
  from proof
- GUI interaction scenario rules change, including when agents must test visible control clicks,
  event-to-state latency, viewport/canvas pointer mapping, stylus strokes, or real user input paths
  instead of backend commands alone
- user-reported bug verification rules change, including reproduction-first requirements,
  before/after evidence, Sonar/OSTM/Rewind routing, identical-evidence rejection, or stuck-status
  wording after repeated failed attempts
- user-facing desktop launch-command verification requirements change, including non-blocking
  long-running GUI launch verification, launcher probe behavior, and duplicate-launch contracts
- Vulkan runtime/readiness policy changes, including how realtime viewport preflights classify
  CPU/software Vulkan, hardware ICD/device visibility, queue/swapchain support, and surface/present
  support
- target-project commit rhythm changes, including when verified implementation slices should be
  committed before agents continue into the next milestone
- greenfield target-project Git initialization and Codex worker read-only `.git` sandbox blocker
  handling changes
- target-project commit-origin marker policy changes, including the allowed `Commit-Origin` values
  and how autonomous agent commits are distinguished from user-requested commits
- target-project slice-execution discipline changes, including when agents must stop broad
  orientation after route selection, adapt stale task lists to new evidence, handle midstream major
  feature requests through planning artifacts, or clean interrupted partial edits
- target-project build/validation command selection rules change, including when agents must use
  repo-declared CMake presets, validation docs, scripts, or code-map build routes instead of guessed
  build directories
- target-project shell-search discipline changes, including how agents must quote markdown/code-span,
  script-fragment, or regex patterns so documentation syntax and shell metacharacters are not
  executed or reinterpreted during validation audits, and how agents must recover when an audit
  command proves the shell interpreted documentation text
- control-harness screenshot or render-target capture rules change, including when agents must prove
  a capture reflects the requested rendered state instead of a stale frame
- visual-capture debugging rules change, including when agents should audit capture API timing,
  render scheduling, and smoke-script order after repeated stale-frame failures
- control-harness thread-boundary rules change, including when visual capture, toolkit readback, and
  UI/renderer state must run on the app GUI/render thread rather than an HTTP/server worker
- repeated visual-capture or render-scheduling failure policy changes, including hard-reset evidence
  ledgers and keep/revert decisions before additional patches
- long visual/reference/calibration acceptance-artifact policy changes, including repeated red
  wrapper/OSTM/scenario cutover gates, acceptance ledgers, narrow `codex exec` stuck probes,
  mandatory current web/upstream research after stall, and rules separating debug-only evidence from
  final artifact progress
- control-harness mutation-success semantics change, including when endpoint `ok` must prove actual
  committed state and post-snap/post-clamp values instead of raw command input
- GUI/editor event-handler rewrite discipline changes, including source-structure inspection before
  stacking harness routes, docs, or screenshots on broad interaction rewrites
