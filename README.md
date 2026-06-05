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
- A viewport-session testing lane for interactive tools, so agents can record and replay real
  UI/viewport sessions with reports, captures, and before/after evidence.
- A nested donor-reference library that routes agents to relevant 3D, AI, simulation, rendering,
  CUDA, Vulkan, and infrastructure references without loading the whole library into context.
- Persisted planning research that captures current-source evidence, donor candidates, and
  project-specific dos and don'ts before implementation starts.
- Validation, profiling, package integrity checks, rollout safety, and optional project-memory
  workflows that keep agent output auditable.

## Recent Commit Highlights

The durable change history lives in [CHANGELOG.md](CHANGELOG.md). This front-page list is kept
intentionally short: newest public-facing changes first, older highlights collapsed below. Entries
use commit identifiers so the ordering stays clear; only the changelog itself is authoritative.

- `cea8e41` - Hardened mode-specific UI/control closeout. Final top-level user-facing artifact fields
  for visible mode, active controls, runtime payload, and behavior/output now decide acceptance;
  nested mutation summaries cannot override contradictory final UI state.
- `4943046` - Hardened renderer/performance supervision. Donor-derived renderer fixes now need
  donor-semantics guardrails before implementation, nonzero OSTM lanes cannot be accepted from
  partial screenshots/state/per-frame artifacts, repeated same-shape failed smoke tests must stop
  instead of being shortened, and inactive capability telemetry such as DLSS-in-Raster must not be
  turned into product policy by accident.
- `61b7590` - Hardened supervisor closeout invalidation. A fresh user report that the same UI/render
  surface still fails, or an artifact contradicting the claimed scenario such as a light-on proof
  ending with that light disabled, now reopens the slice and forces exact user-path repro.
- `2cd056b` - Required chat-visible phase timing for telemetry-heavy supervised lanes. Workers now
  have to include a compact `Phase time:` line in every substantive reply after telemetry starts,
  backed by canonical `CPPSTUDIO_PHASE event=start/end` markers and a parseable closeout report.
- `a5455d1` - Hardened production-lane command freshness. CppStudio now documents exact job-id OSTM
  evidence flow as `submit`/`status` plus optional queue-wide `drain`, rejects stale wait aliases,
  clarifies that code-map drift helpers take the repo root as a positional argument, and requires
  downgraded local reviews to be named when a fresh adversarial reviewer is unavailable.
- `82c5da9` - Required fresh implementing-worker probes for reusable UI/control-surface hardening
  before claiming numeric control-contract behavior will serve future UI fixes.
- `ca87356` - Added numeric UI control-surface contracts for GUI-heavy native tools, covering
  control ids, labels, mode predicates, visibility/enabled reasons, handler bindings, model/runtime
  readbacks, mutation results, and stale-control classification.
- `37e47ff` - Hardened spatial parameter-surface closeout for transform-owned UI such as lights,
  cameras, gizmos, emitters, probes, volumes, and brush cursors; rotation, aim, position, size,
  mode gates, intensity, and quality now require separate proof.
- `f643dee` - Added a diminishing-returns gate on top of supervised-slice telemetry so repeated
  tool failures, stale evidence, or already-proven acceptance stop further verification escalation.
- `73befd0` - Added supervised-slice phase telemetry. Long-running or verification-heavy worker
  lanes can emit `CPPSTUDIO_PHASE` markers and use the bundled phase report helper to measure
  research, donor routing, edit, build/test, OSTM, profiling, review, code-map, and commit time.
- `b6b5eff` - Removed CppStudio-owned cross-repo work-routing tool instructions so ownership and
  dispatch behavior stay governed by user-level doctrine instead of this native GPU harness.
- `4bcaebc` - Hardened GUI/viewport profiling closeout so OSTM or per-frame timing claims must
  prove accepted full-size timing rows, rejected startup/resize rows, and the artifact/helper used
  for readback.
- `de714e1` - Split optional companion skill handling so supervisor references fail soft when
  optional verification skills are not installed instead of assuming absent skill names exist.

<details>
<summary>Show older commit highlights</summary>

- `ca36504` - Hardened supervisor closeout for late worker corrections and portability leaks. Busy
  `agent-contact` refusals now remain explicit closeout blockers until the transcript, diff, and
  commit are audited.
- `840896c` - Hardened profiling artifact readback so agents prefer project-owned report helpers,
  inspect the current OSTM/profiling schema before writing one-off parsers, and fix stale key or
  parser failures as evidence-readback failures before comparing metrics.
- `bea365f` - Tightened enabled-code-map closeout command resolution. Agents must prove repo-local
  code-map validator/drift wrappers exist before invoking them; older existing projects without
  wrappers use the installed CppStudio scripts directly.
- `512fbcf` - Hardened before/after profiling comparisons so agents preserve the accepted baseline
  workload shape exactly, including replay recording, assets, GPU/backend toggles, window state,
  warmup/frame budget, and scripted-input flags.
- `2cea6c9` - Added Agent-Planning-Harness escalation gates to the project planner, supervisor, and
  main native GPU skill for long-running, multi-slice, repeated-failure, and review-heavy lanes.
- `701bd17` - Split Nsight Graphics capture and replay incompatibility handling for Vulkan RT
  profiling. Capture keeps the installed `--no-block-on-first-incompatibility` flag, while replay
  now requires `--no-block-on-incompatibility` for captures with external-memory compatibility
  warnings.
- `c598c21` - Hardened Nsight Graphics capture guidance for Vulkan RT profiling: app arguments must
  be passed as one quoted `--args "<full app argument string>"`, external-memory compatibility
  warnings route through supported `--ignore-incompatible` capture proof instead of dialog hacks, and
  replay metadata/screenshot/function output is required before a capture path is accepted.
- `5aabe31` - Fixed the hosted ShellCheck failure in the bundled-skill package guard so the GitHub
  `Validate` workflow accepts the unmanaged top-level skill package diagnostic.
- `3f9f82b` - Hardened Vulkan/realtime performance audits so agents classify present/vsync pacing,
  startup/shutdown, CPU/API churn, GPU pass cost, resource churn, and instrumentation gaps before
  proposing shader, shadow, ray tracing, CUDA, or compute optimization. Empty Vulkan/NVTX marker
  reports and zero/stale app timing readbacks now have to be reported as observability gaps, not
  pass-level findings.
- `f7d58da` - Added a donor-parameter inventory gate for shader/material/light UI closeout. A worker
  now has to list donor-exposed artist/runtime parameters and classify each one against target
  UI/CLI/model/runtime exposure before widget-wiring proof can count as complete.
- `45012ee` - Hardened supervisor closeout for user-reported UI/control-surface bugs. Worker proof
  now has to match the user's visible report with before/after artifacts, cannot count hidden or
  mode-gated widget mutations as default-panel proof, and must classify stale runtime capability
  buttons.
- `3f342c0` - Added `--launch-sidecar auto` to the enabled-code-map drift checker. Strict closeout can
  now create a frozen tracked/untracked snapshot and start the guarded `agent-tmux
  codex-code-map-sidecar` lane automatically when map maintenance is unresolved.
- `b613ea6` - Required live mutation proof for product-facing UI controls. Parameter-surface closeout
  must now drive the real widget/control handler or equivalent app-owned UI action and compare
  before/after visible control values, committed model/state, and runtime/readback deltas.
- `357dfb1` - Required visible UI proof to run through the exact user-facing launcher, or prove the
  tested executable is the same fresh binary selected by that launcher.
- `93ea957` - Tightened parameter-surface closure so product UI exposure now requires visible
  reachability proof, not only model or JSON inventory.
- `61ea33a` - Added a parameter-surface closure gate so new shader, material, light, renderer,
  simulation, brush, import/export, cache, performance, and runtime settings must be planned and
  closed across backend/runtime ownership, defaults, persistence/state, CLI/config/API, product UI,
  harness/readback, and validation.
- `19dd5eb` - Made `cppstudio-supervisor` report the explicit review-cadence ordinal in every
  supervised worker status, nudge summary, and closeout.
- `58a834e` - Added a focused host coverage lane to generated CppStudio projects beside ASan/UBSan,
  including `coverage` and `coverage-quick` presets.
- `19923bc` - Made `cppstudio-supervisor` launch substantive Codex worker lanes at
  `model_reasoning_effort="xhigh"` by default.
- `e6a6ce5` - Hardened `cppstudio-supervisor` review cadence from a reminder into a mechanical
  pre-nudge and closeout gate.
- `0c04410` - Fixed hosted ShellCheck validation for the shared bundled-skill inventory and recorded
  the CI repair in both the changelog and this front-page highlight list.
- `a4be459` - Added the bundled `cppstudio-supervisor` skill for supervision-only worker routing,
  polling, interrogation, adversarial-review fix routing, Rewind/plan evidence gates, and closeout
  checks. Centralized managed skill inventories and moved sync staging/backups outside the scanned
  Codex skills root.
- `0f260fa` - Fixed the hosted validation failure in `rollout_to_codex.sh` and documented the CI
  repair in the changelog.
- `efd8375` - Claimed `modern-cpp-cmake`, `cuda-kernel-authoring`, and
  `gpu-profiling-workstation` as CppStudio-owned bundled skills with source provenance, compact
  discovery metadata, rollout/watch validation, and installed-path parity checks.
- `fa6f957` - Added skill-load hygiene validation so repo and installed skill roots reject backup
  artifacts, duplicate loaded skill names, and oversized startup descriptions before rollout.
- `9dc4ae3` - Required concrete proof objects in planning so visible/domain slices name the actual
  primitive, scene, generated asset, graph, dataset, or interaction target that proves the loop.
- `1156eb0` - Added the six-level planning depth contract for substantial native GPU, artist, game,
  VFX, DCC, simulation-editor, and technical-art tools.
- `7e06b57` - Added scaffold-first and just-in-time slice planning gates so future product sections
  are mapped without pretending they are implementation-ready.
- `9978dd0` - Hardened interactive tool planning around primary visible loops and shared substrates,
  blocking secondary feature breadth until the first core user action is proven.
- `df60c3a` - Added exact GPU feature regression protocol so agents prove the requested feature lane
  on the target device before hiding, disabling, downgrading, or rewriting around capability
  failures.
- `d4d7976` - Made enabled-code-map maintenance a strict worker-owned closeout gate before staging
  source/build/docs slices.
- `a34a08b` - Routed code-map drift and no-map-touch semantic review output toward the guarded
  code-map sidecar helper as an actionable worker-owned path.
- `8488e6c` - Hardened supervised-worker evidence gates so summaries remain pointers and supervisors
  inspect primary planning, code-map, diff, validation, OSTM, and UI artifacts before judging quality.
- `8d6d94e` - Hardened planner source-access failures so missing or inaccessible sources are
  recorded and critical evidence gaps block planning instead of silently weakening research.
- `01959fa` - Surfaced code-map sidecar commits as explicit README Recent Commit Highlights before
  remote push.
- `ee03b49` - Guarded code-map sidecar trigger evidence so checked-in installed-path validation
  proves the sidecar case stays covered.
- `d0ea9a2` - Hardened sidecar isolation rules: sidecars work from fixed snapshots, return map-only
  patches, and leave reconciliation plus validation to the original worker.
- `b939b38` - Integrated the bounded code-map sidecar lane for enabled maps.
- `5aabe31` - Documented CppStudio's intentional bundled multi-skill layout and added validation that
  rejects accidental unmanaged top-level `skills/*/SKILL.md` packages unless they are the main skill
  or listed in `scripts/managed_skills.sh`, keeping routing explicit without collapsing distinct
  CMake, CUDA, Vulkan, profiling, GUI, planning, supervisor, viewport, and harness concerns into one
  overloaded router.

</details>

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

## Supervisor Workflow

CppStudio also ships a dedicated `cppstudio-supervisor` skill for the case where one agent is not
the implementation worker. Use it when a lead agent is coordinating tmux-managed Codex or Claude
workers, reviewing their plans, routing fixes, polling progress, or deciding whether a worker failure
means CppStudio itself needs hardening.

The supervisor skill is intentionally separate from ordinary implementation skills. A normal worker
building a C++/Vulkan/CUDA app should load `cpp-cuda-vulkan-studio` and the relevant planning,
donor, GUI, control-harness, profiling, or validation skills. A supervisor should load
`cppstudio-supervisor` only when it is managing other agents.

What the supervisor is responsible for:

- Verify the target repo, provider, tmux session, and chat identity before sending work.
- Route implementation to the repo's owner worker instead of patching another repo directly.
- Read the worker's actual plan artifact before approving or rejecting it.
- Maintain a mechanical adversarial-review cadence in the worker watchlist or status before every
  implementation nudge and after every verified slice. If the last reviewed slice or
  `slices_since_review` state is missing, stale, or unknown, the review is due before the next slice.
- Poll until the worker has stopped, hit a blocker, or produced closeout evidence.
- Interrogate unclear worker decisions before guessing why they happened.
- Send actionable adversarial-review or `codex exec` findings back to the owning worker.
- Check Rewind, code-map, OSTM/viewport-session, and validation evidence before calling a lane done.
- Follow user-level cross-repo routing doctrine when the fix belongs to another repo or reusable
  agent tool.
- For long-running, verification-heavy, OSTM/profiling-heavy, or repeated-failure lanes, collect
  `CPPSTUDIO_PHASE` markers and generate a phase report so slowdowns are visible by phase instead of
  inferred from chat history.

Codex worker model defaults are explicit. For substantive supervised CppStudio-backed native GPU
work, launch or resume Codex workers with `model_reasoning_effort="xhigh"` and verify the footer or
process args. Do not enable fast/priority service by default; use `service_tier="priority"` only when
the user specifically asks for fast or priority execution.

Slice phase telemetry is deliberately small. Workers can mark phases such as `research`,
`donor_route`, `edit`, `build_test`, `ostm_ui`, `ostm_profile`, `review`, `code_map`, and `commit`,
then the bundled `skills/cppstudio-supervisor/scripts/slice_phase_report.py` helper summarizes
duration, OSTM job ids, artifacts, and whether verification was required, supporting, redundant,
stale/rejected, or failed tooling. This makes it easier to see when validation is earning its cost
and when a lane is thrashing.

For lanes where telemetry is required, timing is expected in the worker chat as the work happens,
not only in a file at the end. Substantive worker replies should include a compact `Phase time:`
line, such as `research 4m done; edit 8m active; OSTM 0m; blockers none`, backed by canonical
`CPPSTUDIO_PHASE event=start/end phase=... ts=...` markers. If the supervisor has to keep asking
how long each part took, that is treated as a harness-rule gap to correct, not as a normal worker
style preference.

The supervisor also applies a diminishing-returns gate to that report. If the smallest real
user-facing proof already establishes acceptance, extra checks are redundant unless they target a
different risk. If two attempts at the same review, OSTM, profiler, or parser route fail for the same
tooling reason, the lane stops and reports a tooling blocker instead of trying more fallback routes.
Stale, wrong-binary, wrong-size, or wrong-workload runs are rejected before metric comparison.

Review cadence is not a chat-memory promise. After every verified implementation slice, the
supervisor records the commit, whether the slice counts toward cadence, the last post-implementation
reviewed commit, the current `slices_since_review` count, and whether the next nudge is blocked.
Normal cadence is review after three verified implementation slices; when four or fewer approved
slices remain, review after two. Risky shader/runtime, UI interaction, GPU synchronization, generated
project infrastructure, persistence, or visible/rendered-path slices can require an immediate
post-implementation review even before the numeric cadence. A plan review does not satisfy that
post-implementation gate.

Every supervisor status, nudge summary, and closeout should expose that cadence in plain sight:
`0 slices since last adversarial review`, `1st slice since last adversarial review`, `2nd slice since
last adversarial review`, or `3rd slice since last adversarial review; review is due before another
implementation nudge`. If the cadence is unknown, the supervisor should say so and treat review as
due before approving more implementation.

Typical use:

```text
Supervise the native GPU app worker through the next rendering slice. Verify its plan, poll until it
stops, route any review findings back to it, and report whether any CppStudio rule needs hardening.
```

Required companion infrastructure:

- `agent-tmux-control` for launching, resuming, contacting, and polling terminal workers.
- `important-instruction-ledger` when slice watchpoints or user constraints must survive compaction.
- `rewind-checkpoints` when behavior probes, failed-fix rollback, or causal replay matter.
- The supervisor closeout evidence rules, plus `verification-before-completion` only when that
  separate skill is installed.

The supervisor closeout should include the worker commit or explicit no-code-change status, dirty
tree state, validation commands and artifacts, unresolved concerns, and whether any reusable
CppStudio rule, donor route, code-map rule, or skill needs a follow-up hardening change.

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
  `${HOME}/.codex/skills/native-cpp-gui-hud`,
  `${HOME}/.codex/skills/agentic-control-harness`,
  `${HOME}/.codex/skills/viewport-session-testing`, and
  `${HOME}/.codex/skills/important-instruction-ledger`,
  `${HOME}/.codex/skills/cppstudio-supervisor`,
  `${HOME}/.codex/skills/vulkan-compute-sync`,
  `${HOME}/.codex/skills/modern-cpp-cmake`,
  `${HOME}/.codex/skills/cuda-kernel-authoring`, and
  `${HOME}/.codex/skills/gpu-profiling-workstation`
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

Each managed CppStudio skill includes `package-manifest.json`, a deterministic inventory of the
shipped skill files. It records each file's role, progressive disclosure group, byte size, and
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
- Coordinate bundled Vulkan synchronization, CMake, CUDA kernel, workstation profiling, and
  verification guidance.

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
- `viewport-session-testing`: installed user-level skill for app-owned UI/viewport session
  recording and replay, including mouse, keyboard, stylus, camera, tool, timeline, node, gizmo,
  screenshot/capture, semantic trace, and before/after report workflows.
- `important-instruction-ledger`: installed user-level skill that now acts as an active per-slice
  watchlist. It records what supervising or direct agents must watch, verify, block, or reject
  during planning, worker nudges, source edits, commits, and closeout; user hard rules are one input
  to that watchlist, not the whole mechanism.
- `cppstudio-supervisor`: installed user-level skill for supervision-only tmux/subagent worker
  orchestration, adversarial-review fix routing, polling, interrogation, and closeout evidence.
- `vulkan-compute-sync`: installed user-level skill for Vulkan compute/render setup, descriptors,
  barriers, synchronization, image layouts, frame lifetime, validation-layer triage, RenderDoc, and
  Nsight Graphics-oriented debugging.
- `modern-cpp-cmake`: installed user-level skill for C++/CUDA source layout, target-scoped CMake,
  presets, CTest, imported GPU targets, and build hygiene.
- `cuda-kernel-authoring`: installed user-level skill for CUDA kernel design, launch wrappers,
  correctness matrices, numerical stability, sanitizer plans, and profiling discipline.
- `gpu-profiling-workstation`: installed user-level skill for local Nsight, RenderDoc, perf, and
  Compute Sanitizer tool ordering on this workstation.
- `cppstudio-repo-onboarding`: repo-local onboarding skill for agents editing this CppStudio repo.
  It is not the public user-level C++ GPU skill.

### Bundled Companion Skills

CppStudio installs these companion skills from source alongside the main skill:

- `modern-cpp-cmake`: CMake, target layout, presets, tests, and native C++ project hygiene.
- `cuda-kernel-authoring`: CUDA kernels, launch wrappers, numerical tests, and Compute Sanitizer
  planning.
- `gpu-profiling-workstation`: local CUDA/Vulkan/OpenGL profiling and frame-debugging tool order.

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
- `skills/viewport-session-testing/`: bundled viewport-session skill for real UI/viewport
  recording, replay, reports, and before/after proof
- `skills/important-instruction-ledger/`: bundled active slice-watchlist skill for compaction-safe
  supervision and direct-work gates
- `skills/cppstudio-supervisor/`: bundled supervision-only skill for worker orchestration, review
  routing, polling, and closeout evidence
- `skills/vulkan-compute-sync/`: bundled Vulkan synchronization skill for compute/render barriers,
  descriptors, image layouts, frame lifetime, and validation/debug capture triage
- `skills/modern-cpp-cmake/`: bundled C++/CUDA CMake layout and build hygiene skill
- `skills/cuda-kernel-authoring/`: bundled CUDA kernel authoring and verification skill
- `skills/gpu-profiling-workstation/`: bundled local workstation profiling and frame-debugging skill
- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`: generated-project template
- `skills/cpp-cuda-vulkan-studio/references/`: project archetypes and donor-reference guidance
- `skills/*/package-manifest.json`: deterministic skill package inventories and integrity metadata
- `.cppstudio/` and `docs/CODEBASE_*`: maintained code map for this CppStudio repo
- `companion-skill-snippets/`: user-level relay snippet and legacy companion donor-link snippets
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
