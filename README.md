![CppStudio banner](assets/cppstudio-banner.png)

# CppStudio

[![Validate](https://github.com/tarkansarim/CppStudio/actions/workflows/validate.yml/badge.svg)](https://github.com/tarkansarim/CppStudio/actions/workflows/validate.yml)

CppStudio is an agentic native C++ GPU development harness for AI coding agents, delivered as a
reusable skill package. It gives agents a Vulkan-first C++/CUDA project backbone, lane discipline,
validation hooks, rollout scripts, optional code maps, and a curated donor-reference library for 3D,
rendering, simulation, AI runtimes, CUDA, and Vulkan work.

The goal is to make agents less dependent on broad model memory when they enter specialized native
GPU work. Instead of filling gaps from stale or incomplete training examples, agents get maintained
repo-local guidance, known-good project structure, donor references, caveats, and validation lanes so
their plans and code are more precise, reproducible, and easier to audit.

Use it when you want an AI coding agent to create, audit, or upgrade native C++ GPU projects without
turning every new repo into a one-off build-system and donor-research exercise.

As a harness, CppStudio focuses on:

- A Vulkan-first native C++ GPU project backbone with optional CUDA and combined CUDA/Vulkan lanes.
- A dedicated project-planning skill that researches current best approaches before large stack,
  GUI, input, agentic control, donor, and validation choices are locked in.
- A local agentic control-harness skill for interactive apps, so agents can launch, drive, inspect,
  screenshot, and troubleshoot generated tools before asking users for routine manual testing.
- A nested donor-reference library that routes agents to relevant 3D, AI, simulation, rendering,
  CUDA, Vulkan, and infrastructure references without loading the whole library into context.
- Persisted planning research that captures current-source evidence, donor candidates, and
  project-specific dos and don'ts before implementation starts.
- Validation, profiling, package integrity checks, rollout safety, and optional project-memory
  workflows that keep agent output auditable.

## Recent Commit Highlights

The durable change history lives in [CHANGELOG.md](CHANGELOG.md). This front-page list shows 10
selected recent highlights for people scanning the repo. The top `current` item summarizes the
latest unreleased/high-churn changes, while stable older entries use commit ids.

- `current` - Hardened rollout and trigger-regression safety with symlink-safe bundled auxiliary
  rollback handling, required code-map bootstrap/maintenance/sidecar/routing-smoke trigger cases with
  installed-path fresh-agent evidence, fresh-scaffold drift coverage before the first baseline
  commit, greenfield Git bootstrap handling for Codex worker read-only `.git` sandbox blockers,
  Vulkan-only default scaffolds that omit CUDA files/routes/presets unless a CUDA lane is explicitly
  selected, control-harness roadmap/readiness readback that advances after verified prerequisite
  slices, exact readiness invariants, route-inventory drift checks, GUI convention tables with
  icon/text affordance review, no-touch forbidden-path trigger probes, canonical bundled-skill
  rollout guidance, hardware-backed Vulkan readiness, donor-first web/upstream research for missing
  routes, durable greenfield research artifacts with mandatory project dos/don'ts, quality-preserving
  source-access failure handling, donor-candidate disposition, README planning guidance for those
  artifacts, SDL3 pen/tablet input routing for stroke-based artist tools, supervised-worker
  interrogation before inferring CppStudio gaps,
  stricter enabled-code-map drift/schema closeout, generated repo-local map wrappers,
  donor/provenance closeout, and a GPL-safe Blender curves groom-brush study donor.
  It also lets implementation task lists realign when new evidence invalidates stale assumptions,
  while preserving user-facing product and stack decisions, and forces midstream major feature
  requests back through planning artifacts instead of chat-only research. Missing-donor discoveries
  are now captured project-locally first and promoted into the CppStudio source donor library when
  reusable/global promotion is requested; installed user-level donor files stay generated rollout
  targets. Local candidate capture is required evidence even when reusable promotion happens
  immediately. The donor inventory also now includes a sculpting-brush/high-poly mesh route for
  ZBrush-like tools, with Blender sculpt brushes as GPL-safe study material and meshoptimizer,
  OpenSubdiv, and VMA as performance implementation donors. Project maintainer instructions now
  point normal publishing at `rollout_to_codex.sh`, checked-in fresh-agent trigger evidence covers
  the recent planning, donor-promotion, harness, grooming, and sculpting routes, and donor freshness
  auditing now parses plural or wrapped `Sources:` metadata with multiple URLs. Commit-origin
  guidance now rejects provider-name values and keeps verified-slice commits on the explicit
  `agent-slice`/`user-requested` taxonomy. GUI-heavy tools now require real interaction scenarios
  for visible control clicks, selection latency, viewport/canvas pointer mapping, device-pixel-ratio
  handling, committed hit/edit points, and fresh visual evidence instead of backend-only or nonblank
  screenshot proof. User-facing launch commands now also need proof that the exact command opens the
  intended visible app window, not a terminal-title false positive, stale window, hidden workspace
  window, or offscreen-only smoke. Donor route
  validation uses the same wrapped-source parsing, and trigger-result artifacts now fail
  matrix-anchored validation if a recorded `pass` omits expected opened paths, touches forbidden
  paths, self-edits the expected/forbidden path contract, downgrades checked-in installed evidence
  out of `portable-installed` mode, or drops claimed cases. User-reported bug fixes now also need
  exact before/after proof: agents must reproduce the reported behavior, save comparable before and
  after evidence, and refuse to present a fix when the evidence is identical, self-confirming,
  backend-only for a visible bug, or too narrow for the user's report. Visible GUI/windowed bug proof
  is explicitly wired to Sonar readback, OSTM-first automated proof when available, and Rewind
  rollback anchors. If an agent cannot see or capture the actual UI surface, it must say it is
  UI-blind on that bug and stop treating harness-only/JSON-only work as progress on the visible
  symptom. Stalled visible bugs and artist-tool interaction work now have a donor-realignment gate:
  after two focused attempts or about 20 minutes without direct symptom improvement, agents must
  reopen code-map and donor routes, record failed hypotheses plus keep/revert decisions, and stop
  relying on model memory before another patch. Sculpting brush bugs specifically route back through
  the Blender Sculpt Brushes study-only profile and must prove pointer/control-to-committed-result
  behavior, not just a generic mesh revision or nonblank screenshot. Enabled code-map projects now
  also have a bounded sidecar lane for long-running or high-churn map maintenance: sidecars work
  from isolated fixed snapshots and return map-only patches, while the original worker must
  reconcile, rerun drift/schema validation against the current tree, and keep the verified slice
  commit as the public history boundary. Drift and no-map-touch semantic review output now surfaces
  the guarded `agent-tmux codex-code-map-sidecar <repo> <anchor> [focus]` helper as a worker-owned
  action, and strict drift review now blocks source-slice closeout until the worker updates the map,
  self-launches the sidecar, or explicitly acknowledges a reviewed no-map-change case. Supervised
  workers now also have an
  artifact-audit gate: summaries are only evidence pointers, planning packets must be reconciled once
  source work lands, and queued/offscreen proof must finish with labeled artifacts before it can
  justify a plan or closeout judgment. GPU feature regressions now also require exact-lane proof on
  the target device before agents hide, disable, downgrade, or rewrite around capability failures;
  used-to-work reports keep historical comparison active, and stale engineering memory is treated as
  challengeable evidence rather than authority.
- `ee03b49` - Guarded code-map sidecar trigger evidence so checked-in installed-path validation
  proves the sidecar case stays covered instead of silently shrinking to older trigger lanes.
- `d0ea9a2` - Hardened sidecar isolation rules: sidecars must work from fixed snapshots, return
  map-only patch output, and leave current-tree reconciliation plus validation to the original
  worker.
- `b939b38` - Integrated the bounded code-map sidecar lane for enabled maps, including trigger
  coverage, generated-template guidance, and public docs for long-running map maintenance slices.
- `db8c823` - Added a code-map drift checker and pre-commit maintenance gate so enabled-map
  projects catch changed source paths that are not routed by the manifest.
- `c68ae77` - Hardened code-map and trigger validation, made manual managed-skill install
  transactional, and added report-only donor freshness auditing.
- `f072f2d` - Collapsed older README Recent Commit Highlights behind a GitHub details expander.
- `826a1f7` - Added a front-page highlight for maintained code-map routing-smoke requirements.
- `535d266` - Required maintained code-map setup to include read-only subagent or fresh-session
  routing smoke evidence when available, not only schema validation.
- `d9024a6` - Hardened code-map completion so validation is not treated as routing proof,
  fresh-agent smokes are graded pass/partial/fail, instruction-file drift is reported separately,
  and audit-backed presets/scripts are labeled as pre-map infrastructure.

<details>
<summary>Show older commit highlights</summary>

- `3195bb8` - Required existing-project code-map opt-in to run and summarize the non-destructive
  readiness audit before asking whether to restructure, preserve layout, or decline.
- `37f3fb7` - Adopted generic doctrine from a 22-skill Sortie assistant-pack audit: API discovery,
  constraint mapping, harness observation, planning research gates, GUI proof rules, and supervised
  agent monitoring without importing Sortie runtime mechanics.
- `e0a29f5` - Broadened shell-search quoting guidance so validation audits quote script fragments,
  regex text, `$`, embedded quotes, and other shell metacharacters safely.
- `3f78dc7` - Tightened GUI and control-harness verification so broad interaction rewrites build
  before more layers, mutation endpoints prove committed state, and snapped/clamped values are
  asserted after validation.
- `0b82acb` - Required hard-reset evidence ledgers and keep/revert decisions after repeated
  visual-capture or render-scheduling failures.
- `3aa60ff` - Tightened harness thread-boundary guidance so UI/renderer readback, toolkit action
  state, and visual capture run through the safe GUI/render thread.
- `40f1b08` - Added visual-capture timing audit guidance so agents distinguish capture APIs that
  render during grab from APIs that copy the last presented frame before adding waits or loops.
- `a18b91c` - Required settled visual-capture evidence so viewport, canvas, render-target, and
  screenshot checks prove they captured the requested rendered state instead of stale pixels.

- `709e8a6` - Tightened validation-audit shell guidance so agents quote
  markdown/code-span searches safely instead of letting backticks in docs run as
  shell command substitutions.
- `04a276f` - Tightened native C++ GPU validation guidance so agents use
  repo-declared CMake presets, validation docs, scripts, or code-map build routes
  instead of guessed build directories.
- `8d096c2` - Required GUI/editor harness verification to prove real menu,
  action, shortcut, and enabled-state evidence where practical instead of
  treating metadata claims as proof.
- `d4ffdb6` - Added `Commit-Origin` trailers so autonomous agent slice commits
  and explicit user-requested commits are distinguishable in git history.
- `b73aa55` - Tightened native GUI/editor guidance so structural graph and scene
  edits prefer editor actions, menus, shortcuts, or context surfaces before
  toolbar affordances.
- `36320ba` - Required agents to commit each verified implementation slice before
  continuing into the next production milestone.
- `46586d2` - Required exact desktop launch-command verification for user-facing
  GUI launch paths instead of relying on offscreen smoke alone.
- `5e5dbc1` - Tightens desktop launch verification so long-running GUI apps are checked through
  bounded non-blocking harness probes instead of foreground-blocking terminal runs.
- `8a64709` - Hardened offscreen GUI verification routing so manager-submitted
  smoke scripts use absolute paths or explicit working directories.
- `6633fc2` - Fixed the hosted ShellCheck directive for the Vulkan validation wrapper fixture.
- `f3a4284` - Hardened donor-first implementation gates, GUI/windowed verification, code-map hygiene,
  and Vulkan validation-layer environment setup.
- `ae711f6` - Made project planning prefer current best approaches, state-of-the-art web ceiling
  checks, and current-vs-legacy separation before stack choices.
- `57e7a2a` - Added README acknowledgements for the public reference repos that informed the GPU
  optimization and package-integrity workflows.
- `5f1902f` - Required donor-grounded native GPU brainstorming plus web ceiling checks for broad
  realtime simulation/graphics design prompts.
- `d8a9cdc` - Clarified optional code maps as section-level onboarding and map-first navigation
  before source inspection.
- `1096936` - Fixed hosted CI bytecode-cache handling so Python syntax checks do not contaminate
  strict skill-package validation.
- `3138a6c` - Fixed review hardening issues around optimization auto-reverts, macOS-safe rollout
  path resolution, code-map parity checks, and closed package-manifest schemas.
- `ccb6aeb` - Hardened GPU optimization loops with parser-failure auto-reverts, profiler tool-gap
  artifacts, target numeric validation, and stricter package-manifest hygiene checks.
- `ab3c176` - Added deterministic skill package integrity metadata, manifest validation,
  progressive-disclosure file roles, and sync/rollout audit logging.
- `e79974e` - Added AgentSys-style performance investigation gates with success criteria,
  hypotheses, breaking-point search, repeated validation, and consolidation reports.
- `ba8fa15` - Added the generated GPU optimization loop with AutoKernel-style baseline,
  keep/revert, report, and commit-highlight maintenance guidance.
- `13501a2` - Added `docs/BACKLOG.md` to collect future harness, donor, code-map, and tooling ideas.
- `e53a3b1` - Made README positioning agent-agnostic so Codex-specific wording stays in install and
  package sections.
- `c5a0f47` - Clarified that CppStudio is a native C++ GPU development harness delivered as a skill
  package.
- `fa8a289` - Hardened validator, sync, and code-map edge cases around quoted metadata, rollback,
  and local path validation.
- `02a5b29` - Tightened final review items across rollout rollback, donor validation, trigger-lane
  notes, and generated-project docs.
- `4a00635` - Fixed validation coverage so fresh-home checks prove the target Codex home instead of
  inheriting parent validator overrides.
- `d1f60c8` - Hardened rollout, manual install safety, code-map enablement, and donor/library
  validation behavior.
- `138d2fb` - Made hosted CI discover the installed Lavapipe Vulkan CPU ICD path before Vulkan
  runtime smoke tests.

</details>

Maintainers should add one concise line here for commits that change setup, routing, generated
projects, validation, donor-library behavior, public docs, install, release, or sync behavior.

## Sample Projects Built With This Workflow

These are examples of native GPU projects built with this kind of CppStudio agent workflow: scoped
skills, maintained project maps, donor-guided implementation, and validation-heavy iteration.

### CUDA Groom Tool

https://github.com/user-attachments/assets/5db98b21-8bee-4360-8d28-5bcdb64b0cb5

Local fallback: [sample gallery](samples/index.html), [MP4](assets/videos/cuda-groom-tool.mp4)

Realtime C++/CUDA hair grooming with CUDA strand editing kernels, a live 3D viewport, Maya-style
camera controls, and a production-shaped brush set for combing, screen-space grooming, puffing,
pinching, smoothing, length work, selection masking, parting, clumping, frizz, randomization, and
cutting. The project grew into a sophisticated realtime hair lab: shell-aware sparse voxel envelopes
for volume-aware grooming, soft selection-aware edits, deferred/asynchronous smooth guide rebuilds,
CUDA density-grid shadow tracing, scalp receiver shadows, persistent viewport UI settings, scripted
viewport smoke tests, and an RTX-oriented render track covering ray tracing, Chiang/Far-Field hair
shading, DLSS/RR-style reconstruction lanes, and lookdev/debug controls.

### Wetbrush Paint Simulation

https://github.com/user-attachments/assets/cb83fda1-098e-45bc-87d4-407df3974465

Local fallback: [sample gallery](samples/index.html), [MP4](assets/videos/wetbrush-paint-simulation.mp4)

A C++ GPU painting simulation based on the Wetbrush paper, with bristle-level brush dynamics,
grid-based liquid, particle-based liquid, bristle-particle transfer, grid-particle transfer, and a
late-frame rendering path for persistent paint and particle visualization. The project uses a
maintained code map and repo-local skills to keep the paper sections, CUDA kernels, brush/input
timing, particle carrier path, liquid grid, transfer lanes, persistent canvas, playback reports, and
performance evidence connected as the implementation evolves.

## Quick Start

Open this repo in ChatGPT Codex and ask:

```text
Install this CppStudio repo into my ChatGPT Codex home. Use the repo scripts, preserve my existing
AGENTS.md content, and report what changed.
```

Restart Codex after installation, then ask for native C++ GPU work:

```text
Create a Vulkan-first C++ application called RayLab.
```

Expected result: Codex loads `cpp-cuda-vulkan-studio`, keeps the project Vulkan-first unless CUDA is
explicitly needed, scaffolds or upgrades the native C++ project, and opens only the donor references
that match the task.

## Project Planning And Control Skills

CppStudio installs companion planning and control skills for substantial new apps or major
architecture decisions. When a request has unresolved choices such as template, authoring
model/source of truth, GUI/HUD, tablet or stylus input, agentic control harness, Vulkan/CUDA lane,
donor routes, dependencies, or validation strategy, `cppstudio-project-planner` should research
first, then ask for Plan mode before implementation.

The planner is meant to prevent agents from grabbing whatever is easiest or most familiar. It opens
the local donor library, checks current upstream sources and comparable current tools, looks for
state-of-the-art or actively used approaches, identifies common authoring practices such as graphs,
stacks, timelines, scene trees, scripting, or direct parameter workflows, separates current patterns
from legacy or low-effort options, and presents the best available route unless you explicitly ask
for something lightweight.

For substantial greenfield apps, planning should leave a durable research artifact before source
files are created. The expected default is `docs/planning/RESEARCH_BRIEF.md`, plus donor-candidate
notes when new references are found. That brief should include `Project Dos And Don'ts` with at
least `App / Domain` and `GUI / Product Surface` subsections. Each rule should point to source or
donor evidence, name the affected subsystem or UI surface, and define a milestone-1 validation
signal. This is where agents should capture practical lessons such as "use a real 3D viewport, not a
diagnostic panel" or "treat stylus pressure as replayable input data," grounded in current tools and
references rather than memory.

If one researched URL cannot be opened by the normal web tooling, the planner should not silently
work around it or lower the bar. It records the failed URL and error, continues only when equivalent
or stronger primary sources still cover the decision, and stops when a critical choice would be
based on missing or weak evidence.

If research finds a strong reusable donor that is missing from the library, agents should save it in
the target project's donor-candidate notes first. When you want that donor to become part of
CppStudio for future projects, the agent should patch the CppStudio source repo donor library and
run rollout. It should not edit the installed `~/.codex/skills` donor files directly, because those
are generated deployment copies.

Implementation plans are allowed to adapt when evidence changes. If research, API contracts,
toolchain behavior, validation, or a focused probe proves a task is stale or aimed at the wrong
subsystem, agents should revise the task list and validation gate instead of forcing the old list.
They should pause for you only when that shift changes product direction, selected stack, scope,
dependency/license posture, or an explicit constraint.

The same applies when you add a major requirement mid-project. A request such as adding realtime ray
tracing, a node editor, a new solver, or a different viewport backend should make the agent reopen
the research/planning gate, update the project planning artifacts, and record any new dos/don'ts or
decision records before coding or giving a final architecture recommendation.

For larger apps where template, GUI, input devices, donors, or validation choices matter, ask for
planning first:

```text
Plan a realtime Vulkan C++ artist tool before implementation. Include GUI options, donor references,
web checks, authoring-model options, stylus/input needs, and the questions I need to answer.
```

For interactive apps, the planner defaults to a local agentic control harness. The goal is not to
make users manually test every small fix; the generated app should expose local controls, readback,
logs/warnings, and visual or viewport evidence so agents can verify routine behavior themselves.

## Requirements

For installing CppStudio as a Codex skill:

- ChatGPT Codex with local skill support.
- Shell access for the installing agent.
- Git, Python 3.10 or newer, and `rsync` for the normal Linux/macOS/WSL rollout scripts.
- Windows users without Bash/`rsync` can use the manual PowerShell install reference.

The rollout and sync scripts prefer the target Codex system skill validator when it exists, then fall
back to this repo's bundled validator. A fresh Codex home does not need the system validator just to
install CppStudio.

CUDA, Vulkan, CMake, and a C++ compiler are not required just to install the skill. Install those
only on machines that should build or validate generated native GPU projects.

## Install

CppStudio is meant to be installed by your coding agent. If your agent has shell access to the
machine, ask it:

```text
Install this CppStudio repo into my ChatGPT Codex home. Use the repo scripts, preserve my existing
AGENTS.md content, and report what changed.
```

The normal agent command is:

```bash
cd /path/to/CppStudio
./scripts/rollout_to_codex.sh
```

That installs the main skill, donor-library links, and the tiny user-level `AGENTS.md` relay into
the Codex home on the machine where the command runs. The default Codex home is `${HOME}/.codex`.
Restart Codex after installation so changed skill metadata is discovered.

For a non-default Codex home, pass `SYNC_CODEX_HOME` to the rollout script:

```bash
cd /path/to/CppStudio
SYNC_CODEX_HOME=/path/to/.codex ./scripts/rollout_to_codex.sh
```

The rollout and sync scripts use `SYNC_CODEX_HOME`, not `CODEX_HOME`, so nested agent sessions do not
accidentally install into an isolated session home.

The install path is rollback-aware: the main skill is staged and validated before replacement, and
rollout restores the previous main skill, companion edits, and optional `AGENTS.md` relay target if a
later validation or install step fails.

The installed skill is also checked against a deterministic package manifest. Sync and rollout
validate file hashes, sizes, package hygiene, and lazy-loading groups before they report success.
They also append best-effort install audit records under the target Codex home.

You do not need CUDA, Vulkan, CMake, or a compiler just to install CppStudio into Codex. Install GPU
toolchains only when you want this machine to build or validate generated C++ GPU projects.

## What Gets Installed

- Main skill:
  `${HOME}/.codex/skills/cpp-cuda-vulkan-studio`
- Bundled auxiliary skills:
  `${HOME}/.codex/skills/cppstudio-project-planner`,
  `${HOME}/.codex/skills/native-cpp-gui-hud`, and
  `${HOME}/.codex/skills/agentic-control-harness`
- Optional companion donor links for installed companion skills such as `cuda-kernel-authoring`,
  `vulkan-compute-sync`, and `modern-cpp-cmake`
- Tiny user-level `AGENTS.md` relay that tells agents to load `cpp-cuda-vulkan-studio` for
  native C++ GPU, realtime rendering/visualization, C++ GPU code-map, Vulkan, CUDA, or mixed
  CUDA/Vulkan work. Set `SKIP_USER_AGENTS_RELAY=1` during rollout only if you explicitly do not want
  this relay installed or updated.

Existing user content is preserved. CppStudio scripts only replace content inside their own marked
blocks:

- `<!-- cppstudio-user-agents-relay:begin -->` through
  `<!-- cppstudio-user-agents-relay:end -->`
- `<!-- cppstudio-donor-library:begin -->` through
  `<!-- cppstudio-donor-library:end -->`

## Package Integrity

CppStudio includes `skills/cpp-cuda-vulkan-studio/package-manifest.json`, a deterministic inventory
of the shipped skill files. It records each file's role, progressive disclosure group, byte size, and
SHA-256 hash so agents can validate source, staged, and installed copies without fetching a remote
registry.

The disclosure groups are intentionally practical: entrypoints and donor routers stay small, while
category files, production overlays, deep donor profiles, scripts, and template assets remain
lazy-loaded until the task needs them.

## Use It

After installation and a Codex restart, you usually do not need to name the skill. Ask Codex for
native C++ GPU, Vulkan, CUDA, renderer, realtime 3D, simulation, or donor-reference work, and Codex
should load `cpp-cuda-vulkan-studio` automatically.

```text
Create a Vulkan-first C++ application called RayLab.
```

```text
Upgrade this C++ renderer repo with the CppStudio backbone; use Vulkan by default unless CUDA is explicitly needed.
```

```text
Find suitable donors for a real-time grooming and fur simulation tool, then wire the selected
patterns into this C++/Vulkan project.
```

Mention `$cpp-cuda-vulkan-studio` explicitly only when automatic skill routing is unavailable or did
not trigger.

## What The Skill Does

- Prefer Vulkan for unspecified native C++ GPU, rendering, realtime, XR, simulation-visualization, or
  cross-platform work.
- Keep CUDA explicit and separate unless the user chooses CUDA, requirements force CUDA, or a
  deliberate combined CUDA/Vulkan or real interop lane is needed.
- Scaffold or upgrade C++ app+library repos with CMake presets, CTest labels, shader tooling,
  optional CUDA lanes, validation scripts, and self-hosted GPU CI hooks.
- Guide CUDA kernel, Vulkan compute, render-pass, simulation, and frame-time optimization through
  evidence-gated success-criteria, baseline/profile/hypothesis/attempt/keep-or-revert loops with
  roofline/SOL diagnosis, breaking-point search, repeated validation passes, beam round planning,
  convergence stops, and consolidation reports.
- Route agents through nested donor references for graphics, glTF/runtime assets, WebGPU/WebGL,
  renderer backbones, path tracing, engine architecture, mesh pipelines, asset IO, NURBS, materials,
  CAD, BIM/IFC, terrain/geospatial data, AI runtimes, neural 3D, Gaussian splatting, grooming/fur,
  DCC scene pipelines, volumes, medical/scientific data, animation, muscle/flesh simulation, VFX,
  particles, simulation, XR, and native engineering infrastructure.
- Offer an optional code map for larger generated or upgraded C++ GPU projects that need durable
  architecture context across future agent sessions.
- Coordinate companion skills for CMake, Vulkan synchronization, CUDA kernels, and verification.

## Optional Code Maps

CppStudio can add a maintained code map to a target native C++ GPU project, but it is optional and
per project. The benefit is practical project memory and section-level onboarding: future agents can
find subsystem ownership, backend boundaries, build and test lanes, validation entrypoints, and donor
decisions without rereading the entire repo from scratch.

When a map is enabled, agents use it as the first navigation step before code changes, not as a
replacement for source inspection. The architecture index and manifest route them to the matching
subsystem doc and primary paths, then the subsystem doc gives concise context about what that section
of the code owns, how it behaves, and what validation expectations apply before editing.

There is no standalone CppStudio code-map skill. The workflow lives inside `cpp-cuda-vulkan-studio`
so the map follows the same Vulkan/CUDA lane policy, validation rules, and donor-routing context as
the project it describes.

For an existing project, ask for a maintained CppStudio code map in the same native C++ GPU context:

```text
Create a maintained CppStudio code map for this existing C++/Vulkan renderer repo.
```

The agent should audit the existing layout first without writing audit files by default. It should
then show concrete findings, evidence paths, nonstandard layout risks, estimated cleanup cost, and
what restructuring would actually be needed before asking whether to restructure first, preserve the
current layout and document it, or decline code-map enablement. Existing generated map files are not
replaced unless the user explicitly accepts that. If the audit leads to small setup work such as
CMake presets or canonical scripts, that should be reported as a separate audit-backed
infrastructure slice, not hidden inside the code-map step.

After a map is enabled, validation proves the map schema and links. A read-only subagent or
fresh-agent routing smoke is the stronger proof that the workflow actually works: a new agent should be able to load
`cpp-cuda-vulkan-studio`, read the architecture index and manifest, choose the right subsystem doc,
and only then trace the first exact files and tests for a read-only task. The smoke should stop after
that routing proof instead of becoming a full source audit; if it never reports, skips the manifest,
or starts implementing, the routing proof is partial or failed.

For a new project, an explicit code-map request counts as acceptance after scaffolding:

```text
Create a Vulkan-first C++ application called RayLab and make sure future agents have a code map.
```

Support files may exist before a map is enabled, but agents should maintain and load the map only
when `.cppstudio/code-map-state.json` says `enabled`.

For long-running or high-churn enabled-map slices, the main worker may use a bounded code-map
sidecar to reduce context bloat. Strict drift review is the closeout gate:
`scripts/check_code_map_drift.py --require-enabled --strict-review`. If it reports uncovered drift
or source changes with no map edit, the worker resolves that itself before staging by updating the
map, self-launching the sidecar, or acknowledging a reviewed no-map-change case after checking route
semantics. The sidecar should be code-map-only, read a named fixed snapshot
such as a Rewind checkpoint, temporary git anchor, commit, isolated worktree copy, or archive, and
report its map update plus snapshot assumptions. If the original keeps implementing, the sidecar must
return a patch/diff or map-file replacements instead of editing the original live worktree
concurrently; same-worktree edits require a serialized handoff with the original paused. The original
worker still owns the final gate: merge or apply the sidecar output, rerun drift and schema
validation against the current tree, and update the map again if later implementation work touched
additional routable ownership or data-flow areas. Normal git history should stay clean; Rewind
checkpoints and temporary anchors are not public verified-slice commits.

## Skills And Donors Included

### Bundled Skills

- `cpp-cuda-vulkan-studio`: installed user-level skill for Vulkan-first C++ GPU, CUDA, combined
  CUDA/Vulkan builds, explicit interop work, project scaffolding, validation lanes, and donor routing.
- `cppstudio-project-planner`: installed user-level skill for upfront project intake before
  scaffolding or major architecture work. It chooses the CppStudio archetype/template, GPU lane,
  GUI/HUD options, agentic control harness, donor routes, web checks, artist-input requirements such
  as Wacom/stylus pressure, code-map policy, and validation plan with the user.
- `native-cpp-gui-hud`: installed user-level skill for choosing native C++ GUI, HUD, editor UI,
  viewport overlay, gizmo, plotting, desktop UI, runtime/game UI, and embedded-web UI stacks. When it
  presents options, it includes links where users can inspect how each GUI looks.
- `agentic-control-harness`: installed user-level skill for local HTTP/curl controls, optional MCP
  facades, launch/control registries, state/log/visual observation, and autonomous test lanes for
  native C++ realtime apps.
- `cppstudio-repo-onboarding`: repo-local onboarding skill for agents editing this CppStudio repo.
  It is not the public user-level C++ GPU skill.

### Companion Skill Links

CppStudio can add donor-library links to these companion skills when they are already installed:

- `modern-cpp-cmake`: CMake, target layout, presets, tests, and native C++ project hygiene.
- `vulkan-compute-sync`: Vulkan compute/render setup, descriptors, barriers, synchronization, and
  frame lifetime.
- `cuda-kernel-authoring`: CUDA kernels, launch wrappers, numerical tests, and Compute Sanitizer
  planning.

### Donor Index Files

The donor library is a reference map, not a vendored source tree. Agents use it to choose
architecture patterns, APIs, tests, algorithms, and dependency candidates.

The routing is intentionally nested so the first loaded skill text stays small:

- The donor library entrypoint gives policy and category choices.
- Production overlays translate VFX studio, game studio, and native infrastructure vocabulary into
  technical donor categories.
- The agent lookup guide maps broad prompts to the right category files.
- Category files contain compact donor maps for one domain.
- Deep profiles are loaded only after a category is selected.

Start from these files:

- [Donor library entrypoint](skills/cpp-cuda-vulkan-studio/references/donor-library/README.md)
- [Selection policy](skills/cpp-cuda-vulkan-studio/references/donor-library/selection-policy.md)
- [Production overlays](skills/cpp-cuda-vulkan-studio/references/donor-library/production/README.md)
- [Agent lookup guide](skills/cpp-cuda-vulkan-studio/references/donor-library/agent-lookup.md)
- [Deep profile index](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/README.md)

### Production Routing Overlays

- [VFX studio](skills/cpp-cuda-vulkan-studio/references/donor-library/production/vfx-studio.md):
  modeling, texturing, rigging, creature FX, look development, lighting, and FX.
- [Games](skills/cpp-cuda-vulkan-studio/references/donor-library/production/games.md): character art,
  world art, technical art, gameplay animation, realtime VFX, rendering, tools, physics, and XR games.
- [Native engineering infrastructure](skills/cpp-cuda-vulkan-studio/references/donor-library/production/native-engineering-infrastructure.md):
  project templates, CMake/build layout, testing, validation, profiling, CI, dependency policy, and
  template update safety.

### Donor Category Files

3D, graphics, simulation, and XR category files:

- [Animation and rigging](skills/cpp-cuda-vulkan-studio/references/donor-library/animation-rigging.md)
- [Assets, meshes, materials, and NURBS](skills/cpp-cuda-vulkan-studio/references/donor-library/assets-meshes-materials.md)
- [BIM, AEC, and IFC](skills/cpp-cuda-vulkan-studio/references/donor-library/bim-aec-ifc.md)
- [CAD and precision geometry](skills/cpp-cuda-vulkan-studio/references/donor-library/cad-precision-geometry.md)
- [DCC scene pipelines](skills/cpp-cuda-vulkan-studio/references/donor-library/dcc-scene-pipeline.md)
- [Geometry and simulation](skills/cpp-cuda-vulkan-studio/references/donor-library/geometry-simulation.md)
- [glTF runtime assets](skills/cpp-cuda-vulkan-studio/references/donor-library/gltf-runtime-assets.md)
- [Graphics and rendering](skills/cpp-cuda-vulkan-studio/references/donor-library/graphics-rendering.md)
- [Hair, grooming, and fur](skills/cpp-cuda-vulkan-studio/references/donor-library/hair-grooming-fur.md)
- [Medical and scientific volumes](skills/cpp-cuda-vulkan-studio/references/donor-library/medical-scientific-volumes.md)
- [Muscle, flesh, and biomechanics](skills/cpp-cuda-vulkan-studio/references/donor-library/muscle-flesh-biomechanics.md)
- [Native GUI, HUD, and editor UI](skills/cpp-cuda-vulkan-studio/references/donor-library/native-gui-hud.md)
- [Neural 3D](skills/cpp-cuda-vulkan-studio/references/donor-library/neural-3d.md)
- [GPU simulation](skills/cpp-cuda-vulkan-studio/references/donor-library/simulation-gpu.md)
- [Sculpting brushes and high-poly mesh tools](skills/cpp-cuda-vulkan-studio/references/donor-library/sculpting-brushes.md)
- [Surfaces and subdivision](skills/cpp-cuda-vulkan-studio/references/donor-library/surfaces-subdivision.md)
- [Terrain, geospatial, and 3D Tiles](skills/cpp-cuda-vulkan-studio/references/donor-library/terrain-geospatial.md)
- [Texture, material, and color](skills/cpp-cuda-vulkan-studio/references/donor-library/texture-material-color.md)
- [Realtime VFX and particles](skills/cpp-cuda-vulkan-studio/references/donor-library/vfx-particles.md)
- [Volumes and voxels](skills/cpp-cuda-vulkan-studio/references/donor-library/volumes-voxels.md)
- [Vulkan foundation tooling](skills/cpp-cuda-vulkan-studio/references/donor-library/vulkan-foundation-tooling.md)
- [XR and spatial computing](skills/cpp-cuda-vulkan-studio/references/donor-library/xr-spatial.md)

Other GPU, AI, and ML category files:

- [AI runtimes and kernels](skills/cpp-cuda-vulkan-studio/references/donor-library/ai-runtimes-kernels.md)

Native project infrastructure category files:

- [Native engineering infrastructure](skills/cpp-cuda-vulkan-studio/references/donor-library/native-engineering-infrastructure.md)

### Donor Profile Caveats

Some donors are direct C/C++ implementation references, some are dependency-scale references, and
some are explicitly reference-only or study-only. Study-only donors are concept references, not code
donors. Browser, Python, notebook, DCC, service, JIT/DSL, or non-C++ donors can still guide
algorithms, behavior, tests, UX, and architecture, but agents should port the idea through the active
C++/Vulkan/CUDA lane instead of copying code directly unless the user explicitly chooses that runtime
and license shape.

Machine-readable donor tiers are `safe-donor`, `dependency-candidate`, and `study-only`. Inline
caveat identifiers add native-use context:

- `reference-only`: not a direct native C++ donor for this package. Use behavior, algorithms,
  architecture, tests, fixtures, or outputs as guidance, then port intentionally through the active
  C++/Vulkan/CUDA lane.
- `mixed-native`: contains useful native C/C++/CUDA pieces, but the surrounding repo is shaped by
  Python, PyTorch, service, web, generated-code, or other non-C++ runtime surfaces. Inspect and isolate
  native subtrees before using it as an implementation donor.
- `study-only`: concept or workflow reference only. Do not copy code into generated projects or reusable
  skills without explicit approval and license review.

Unmarked entries are still not automatic copy/paste sources; always read the linked profile first.

### Deep Donor Profiles

The full donor-profile inventory lives in the
[deep profile index](skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/README.md).
Those files are intentionally not first-load material. Agents should start from the category files
above, then open only the profile or bundle profile that matches the active task.

The deep profiles cover:

- Vulkan foundations, shader tooling, ray tracing, denoising, reconstruction, and frame/debug
  patterns.
- Rendering engines, path tracers, BVH libraries, WebGPU/WebGL references, and engine architecture.
- Native C++ GUI/HUD/tool UI stacks including Dear ImGui, ImGuizmo, ImPlot, Qt, wxWidgets, RmlUi,
  NoesisGUI, Nuklear, FLTK, libui-ng, and CEF.
- Asset, mesh, material, texture, NURBS, DCC, CAD, BIM/IFC, terrain, and geospatial pipelines.
- Neural 3D, Gaussian splatting, grooming/fur, volumes, medical/scientific visualization, animation,
  muscle/flesh simulation, physics, fluids, smoke, fire, VFX, particles, XR, and spatial input.
- CUDA kernels, AI runtimes, ML compilers, inference engines, and native GPU compute references.
- Native C++ project infrastructure, template update safety, CMake/build layout, testing, validation,
  profiling, CI, and dependency management.

Profile caveat identifiers such as `reference-only`, `mixed-native`, and `study-only` are repeated in
the profile index and individual profile files so agents know whether a donor is suitable for direct
C/C++ use or only as behavior, architecture, or algorithmic reference.

### Donor Maintenance

The donor library is curated guidance, not vendored source code. Refresh donor profiles when upstream
SDKs, toolchains, licenses, or major repo structures change, and update researched-date notes when a
meaningful review happens. Donor refreshes should keep the same classification discipline: direct
native donors, dependency candidates, mixed-native references, reference-only material, and study-only
concept sources must stay clearly separated.

## When To Install GPU Tools

Install extra host tools only for lanes you want to build or validate on the current machine:

| Need | Install |
|------|---------|
| Use CppStudio as a Codex skill | Nothing beyond the install command above |
| Validate generated C++ projects locally | CMake, Ninja or another build tool, and a C++ compiler |
| Work on Vulkan projects locally | Vulkan SDK tools such as `glslc`, `spirv-val`, `vulkaninfo`, and validation layers |
| Work on CUDA projects locally | NVIDIA driver, CUDA Toolkit, `nvcc`, and Compute Sanitizer |
| Run optional quality/profiling lanes | `clang-format`, `clang-tidy`, RenderDoc, Nsight tools, or platform-specific profilers |

Detailed setup commands live in [docs/host-toolchain-setup.md](docs/host-toolchain-setup.md).

## Repository Layout

- `skills/cpp-cuda-vulkan-studio/`: source of truth for the user-level Codex skill
- `skills/cppstudio-project-planner/`: bundled planning skill for project intake, option gathering,
  GUI links, agentic controls, donor routes, web checks, and implementation handoff
- `skills/native-cpp-gui-hud/`: bundled GUI/HUD skill for native C++ tool UI choices and visual
  inspection links
- `skills/agentic-control-harness/`: bundled control-harness skill for autonomous app launch,
  control, observation, visual/UI evidence, and troubleshooting
- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`: generated-project template
- `skills/cpp-cuda-vulkan-studio/references/`: project archetypes and donor-reference guidance
- `skills/*/package-manifest.json`: deterministic skill package inventories and integrity metadata
- `.cppstudio/` and `docs/CODEBASE_*`: maintained code map for this CppStudio repo
- `companion-skill-snippets/`: managed donor-link snippets for companion skills and user-level relay
- `research/`: source research and trigger-test notes
- `scripts/`: validation, sync, rollout, and watch helpers
- `.codex/skills/cppstudio-repo-onboarding/`: project-level onboarding skill for agents editing this
  repo

The installed copy at `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` is a deployment target, not the
source of truth. Edit this repo, then have an agent publish with the repo scripts.

## More Docs

- [Manual install reference](docs/manual-install.md): copy steps for agents that cannot run rollout
- [Host toolchain setup](docs/host-toolchain-setup.md): Linux, macOS, and Windows C++/Vulkan/CUDA
  setup notes
- [Package integrity](docs/package-integrity.md): manifest validation, progressive disclosure groups,
  sync/rollout audit records, and future distribution notes
- [Sortie assistant-pack adoption audit](research/sortie-assistant-pack-adoption.md): classification
  of 22 audited Sortie skills; CppStudio cherry-picks generic doctrine without importing Sortie
  runtime mechanics
- [Generated GPU optimization loop](skills/cpp-cuda-vulkan-studio/assets/app-library-template/docs/GPU_OPTIMIZATION_LOOP.md):
  success criteria, baseline, hardware profile, roofline/SOL diagnosis, hypothesis logs,
  breaking-point search, beam round planning, keep/revert, target orchestration, and consolidation
  reports for generated or upgraded projects
- [Optional code maps](#optional-code-maps): opt-in architecture context for larger generated or
  upgraded native C++ GPU projects
- [Maintainer guide](docs/maintainer-guide.md): validation, sync, rollout, generated-project, donor,
  and troubleshooting details for agents editing this repo
- [Contributing](CONTRIBUTING.md): public contribution, donor update, validation, and release notes
- [Backlog](docs/BACKLOG.md): candidate ideas for future harness, donor, code-map, and tooling work
- [Changelog](CHANGELOG.md): tracked change history for pushed repo changes
- [Codebase architecture index](docs/CODEBASE_ARCHITECTURE_INDEX.md): maintained map for agents
  editing CppStudio itself
- [Donor library](skills/cpp-cuda-vulkan-studio/references/donor-library/README.md): curated donor
  selection entrypoint

## Acknowledgements

CppStudio's GPU optimization and package-integrity workflows were informed by public reference repos,
adapted for native C++/CUDA/Vulkan agent work rather than copied wholesale. No source code from these
projects is vendored into this repo.

- [AutoKernel](https://github.com/RightNow-AI/autokernel): fixed-baseline, focused experiment,
  benchmark, keep/revert, and report-loop discipline.
- [KernelAgent](https://github.com/meta-pytorch/KernelAgent): NCU/SOL-style hardware metrics,
  bottleneck diagnosis, best-so-far tracking, and parallel optimization-worker ideas.
- [AgentSys](https://github.com/agent-sh/agentsys): performance investigation phases, hypothesis
  evidence, validation-pass discipline, breaking-point search, and consolidation reports.
- [agent-skills](https://github.com/tech-leads-club/agent-skills): skill/reference packaging hygiene,
  progressive disclosure, audit/update concepts, and integrity metadata ideas.

Detailed mapping notes live under [`research/`](research/).

## License

CppStudio is released under [The Unlicense](LICENSE) for unrestricted reuse.
