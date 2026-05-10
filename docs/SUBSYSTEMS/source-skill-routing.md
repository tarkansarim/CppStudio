# Source Skill And Agent Routing

Owns the user-level `cpp-cuda-vulkan-studio` skill source, CppStudio repo onboarding, Vulkan-first
lane policy, code-map trigger metadata, active-map navigation behavior, donor-router entrypoints, and
generated-project workflow instructions.

## Canonical Docs

- `AGENTS.md`
- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/agentic-control-harness/SKILL.md`
- `skills/cpp-cuda-vulkan-studio/references/project-archetypes.md`

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/agentic-control-harness/SKILL.md`
- `.codex/skills/cppstudio-repo-onboarding/SKILL.md`

## Current External Doctrine Posture

- Sortie assistant-pack adoption research is provenance only. CppStudio may cherry-pick generic
  doctrine into reusable skills, but must not import Sortie runtime mechanics such as Sortie MCP
  call sequences, L0/L1/L2 Harness roles, checkpoint/rewind/gauntlet machinery, workflow graph
  execution, agent resource defaults, or `.sortie` artifact contracts.

## Current Code-Map Bootstrap Posture

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
  enabled-map maintenance closeout, and routing-smoke proof. Keep those cases aligned with the
  code-map bootstrap scripts and source-skill rules whenever the protocol changes.
- Enabled code maps have an ordinary pre-commit maintenance gate. Agents must run
  `scripts/check_code_map_drift.py --require-enabled` when available before committing a verified
  source slice, then update the manifest and matching subsystem doc for any changed routable path
  that is not covered. The checker catches path coverage; semantic ownership/data-flow changes still
  require agent judgment even when the path is already routed.
- Target-repo instruction files are sensitive. `AGENTS.md`, `CLAUDE.md`, repo-local skills, and
  agent metadata must be named separately in status reports when dirty or changed; they must not be
  hidden under generic "unrelated dirty files" wording.

## Current Donor-First Research Posture

- Donor-first means local donor-library routes are opened before code or product-shape decisions.
  If no suitable donor exists, or the local donor route is stale or too generic for a new subsystem,
  agents must run web/upstream research against current primary sources before designing the
  implementation. "Upstream research" means public current-source research such as official repos,
  docs, samples, standards docs, vendor docs, papers, release notes, and peer-tool references; it is
  not permission to fill gaps from model memory.
- Substantial greenfield and architecture-setting research must be durable. Agents should write a
  target-project `docs/planning/RESEARCH_BRIEF.md` before implementation, combining local donor
  routes and curated web/upstream sources with short descriptions, project benefits, freshness or
  primary-source notes, and direct-donor/dependency/reference-only caveats. Chat-only research is not
  enough for these cases.
- New reusable references discovered during web research are first saved as target-project donor
  candidates, normally `docs/planning/DONOR_CANDIDATES.md` or a donor-candidates section in the
  research brief. They are promoted into CppStudio's source donor library only during explicit
  donor-library maintenance and then rolled out to user-level; installed user-level skills are not
  hand-edited as donor-library source.
- Risky backend, renderer, GUI/editor, solver, harness, or authoring-model migration slices must
  close out donor provenance. If a target repo owns a source/provenance doc, agents update it with the
  local donor routes, current upstream links, study-only/license caveats, and any inferred decisions;
  otherwise they record that evidence in the validation or status docs for the slice.

## Current Supervised Worker Posture

- When a supervised tmux worker, subagent, or terminal agent makes, skips, or rejects a decision and
  the cause is unclear, the supervising agent interrogates the worker before claiming the cause or
  changing CppStudio rules.
- The interrogation asks for skill routes, donor routes, web/upstream sources, decision criteria,
  discovered gaps, and verification commands, then the supervising agent checks that answer against
  the transcript and files.
- Worker answers are evidence, not authority. If the worker is unreachable, supervisors inspect the
  available transcript and project files and state the uncertainty instead of inventing intent.

## Current Native UI Product-Fit Posture

- Native tool UI labels must expose critical semantic scope in visible text, not only in tooltips,
  docs, or harness readback. Preview, baked, destructive, local/published, approximate/final, and
  diagnostic/product distinctions need visible wording that screenshots and harness assertions can
  prove.
- GUI/editor/timeline/viewport/tool-surface work must create a compact UI convention table before
  changing layout or command widgets. The table records donor or peer-tool evidence, expected control
  location, icon/text convention, tooltip/accessibility text, enabled states, and proof method for the
  affected surfaces.
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

## Current Target-Slice Execution Posture

- After agents name a bounded target-project slice with code-map route, donor/reference grounding,
  expected files, and verification gates, they must move to the smallest implementation/probe action
  or report a concrete blocker. Broad re-orientation after that point is a process miss.
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

## Update When

- skill trigger description, workflow, acceptance, or bundled script list changes
- Vulkan/CUDA lane policy changes
- project archetype routing changes
- the repo-local onboarding skill changes
- code-map readiness, bootstrap, or maintenance behavior changes for agents
- target-repo code-map authority or map-first navigation behavior changes
- donor-grounding or web-ceiling-check expectations for native GPU brainstorming/design proposals
  change
- durable project-local research artifact or donor-candidate capture requirements change
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
- user-facing desktop launch-command verification requirements change, including non-blocking
  long-running GUI launch verification, launcher probe behavior, and duplicate-launch contracts
- Vulkan runtime/readiness policy changes, including how realtime viewport preflights classify
  CPU/software Vulkan, hardware ICD/device visibility, queue/swapchain support, and surface/present
  support
- target-project commit rhythm changes, including when verified implementation slices should be
  committed before agents continue into the next milestone
- greenfield target-project Git initialization and Codex worker read-only `.git` sandbox blocker
  handling changes
- target-project commit-origin marker policy changes, including how autonomous agent commits are
  distinguished from user-requested commits
- target-project slice-execution discipline changes, including when agents must stop broad
  orientation after route selection or clean interrupted partial edits
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
- control-harness mutation-success semantics change, including when endpoint `ok` must prove actual
  committed state and post-snap/post-clamp values instead of raw command input
- GUI/editor event-handler rewrite discipline changes, including source-structure inspection before
  stacking harness routes, docs, or screenshots on broad interaction rewrites
