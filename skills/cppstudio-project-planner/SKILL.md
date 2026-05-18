---
name: cppstudio-project-planner
description: "Plan native C++ GPU/realtime projects before scaffolding or major architecture work: gather requirements, choose CppStudio project archetype/template, project authoring model/source-of-truth, Vulkan/CUDA/interop lane, GUI/HUD stack, agentic control harness, artist input such as Wacom/stylus pressure, donor categories, state-of-the-art web ceiling checks, code-map policy, validation lanes, and user decisions. Use for initial project planning, project intake, architecture blueprints, 'what stack should we use' questions, best-current-stack selection, or when a C++/Vulkan/CUDA/3D/AI/simulation/tool app has multiple unresolved choices."
---

# CppStudio Project Planner

Use this skill as the front door for major native C++ GPU project planning. It does not replace
`cpp-cuda-vulkan-studio`; it prepares a grounded project plan, records user choices, and then hands
implementation to the specific CppStudio, GUI, Vulkan, CUDA, CMake, and donor routes.

## Core Rule

Do not scaffold or make broad architecture commitments while major project-shaping choices are still
unresolved.

Hard rule: before touching code or locking a project-shaping recommendation, do not rely on training
data or intuition as the source of truth. Open the relevant local skills and the smallest matching
donor-library route/category/profile first. The pre-plan brief must name the skills, donor routes,
and current upstream sources that grounded the recommendation. If no donor route fits, state that
gap and do focused research before designing or scaffolding.

For a substantial initial project request, gather a pre-plan research brief before asking the user to
switch to Plan mode or presenting decision questions. Do not jump straight into question UI. After
the brief is written or presented, stop in normal chat with the Plan-mode handoff; do not ask the
decision questions inline unless the user explicitly says to continue without Plan mode or the
current turn is already in Plan mode.

Before asking the user for target facts, auto-discover what the local workspace can already answer.
For an existing repo, inspect repo instructions, enabled code maps, README/build docs, presets,
package manifests, scripts, validation entrypoints, existing launch/control docs, and obvious app or
library boundaries. For a greenfield target, inspect the requested name, current directory, nearby
repo constraints, source-control state, available templates, and likely toolchain assumptions. When
commits are expected for a greenfield target, initialize or require a usable Git repo before the first
source slice. If a Codex worker reports an empty read-only `.git` mountpoint or read-only `.git`
filesystem in a brand-new directory, classify it as worker sandbox/tooling state, not project state.
Do not unmount, chmod, delete, or write around that placeholder from inside the worker. Preferred
recovery is host/supervisor initialization: if the supervising agent has normal shell access to the
real project path, initialize Git there from outside the worker, then relaunch or retry the worker
from a clean Rewind checkpoint. Ask the user for Git initialization only when the supervising agent
cannot perform that host-side action. Ask the user only for preferences, missing constraints, or
decisions that cannot be discovered locally.

The pre-plan research brief must open the relevant local skill/donor references and run an extensive
state-of-the-art web ceiling check against upstream/primary sources for current GUI, SDK, simulation,
renderer, dependency, authoring-model, or hardware choices. Keep the user-facing brief concise, but
the research must be deep enough that the user is choosing between current, competitive options
rather than unsupported guesses.

Source-access failures must not lower the planning quality bar. If one searched source cannot be
opened through the normal web tool path, record the URL, source type, error, and affected decision.
Retry the same tool path once when the failure looks transient, but do not silently switch to curl,
browser CLI, mirrors, cached copies, or model memory unless the user explicitly approves that
alternate route. Continue the research only when the affected decision still has equivalent or
stronger coverage from other primary/upstream sources, local donor profiles, or current peer-tool
documentation. If the failed source is the only source for a critical decision, or a major subsystem
would be left with weak/secondary evidence, stop and report the blocker instead of producing a lower
confidence plan.

For substantial greenfield projects, ambitious artist/game/VFX/DCC tools, or any plan that could be
lost to context compaction, the research pass must be persisted before implementation. Create a
target-repo planning artifact such as `docs/planning/RESEARCH_BRIEF.md` before asking for Plan mode
or scaffolding source. The artifact is not a raw link dump: cherry-pick the strongest sources after
deduplicating stale, overlapping, weak, unclear-license, or non-primary material. Include local donor
routes and web/upstream sources together, with a short note for each link explaining what it is, why
it matters to this project, whether it is current/primary, and whether it is direct-donor,
dependency-candidate, or reference-only. For large projects, expect a broad curated source set across
the major subsystems, not a handful of links in chat. When a source was searched but not opened,
include it in an `Unavailable or unverified sources` note with the exact error, replacement evidence
used, and whether any decision remains blocked.

For those substantial planning artifacts, include a `Project Dos And Don'ts` section. This is the
operational distillation of the research, not a style appendix. It must turn local donor routes,
web/upstream research, and peer-tool evidence into project-specific rules the implementation agent
can follow without re-reading every link. Cover both the app/domain shape and the GUI/product
surface. Each item should name the rule, source/evidence, affected subsystem or UI surface, and the
milestone-1 validation signal. GUI/interface items must include peer-tool or UI-framework evidence
for layout, control placement, icon/text affordance, viewport/timeline/inspector conventions,
debug-vs-product boundaries, and visual proof expectations. Do not let generic advice such as "make
the UI polished" satisfy this section.

For greenfield artist-tool planning, also name the intended product-surface quality target before
source files are created. This is a compact visual contract derived from peer tools: viewport
dominance, palette or shelf style, inspector placement, icon/text usage, spacing, typography scale,
color restraint, status/readback placement, and which debug controls are hidden, collapsed, or
clearly marked diagnostic. If the target is a serious sculpting, painting, grooming, VFX, DCC, or
game-dev tool, the first milestone cannot be accepted with a generic debug UI just because it has the
right buttons. The slice proof must include a screenshot or app-owned frame judged against that
visual contract.

When the requested tool names polished commercial peers or asks for high-quality standalone artist
software, do not classify the GUI stack as "fast Vulkan tooling" just because Vulkan is involved.
Classify the main shell as a product-like desktop artist application unless the user explicitly asks
for a fast prototype, debug HUD, or internal tool. For that class, compare Qt-style desktop shells
against immediate-mode UI and prefer the polished shell when available or acceptable; keep Dear ImGui
for overlays, diagnostics, or explicitly approved immediate-mode product surfaces. A plan that picks
Dear ImGui for a ZBrush/Maya/Mudbox/Houdini-like standalone product must include recorded user
approval plus a strict visual contract, otherwise revise the recommendation before source files are
created.

When web research finds a strong reusable source that is missing from the CppStudio donor library,
do not leave that discovery only in chat. First capture it in the target project's durable research,
normally `docs/planning/DONOR_CANDIDATES.md` or a "Donor candidates" section in the research brief,
with the source URL, category, likely tier, backend/language signal, license/freshness status when
known, direct-reuse versus reference-only caveat, and why it should be considered for CppStudio. This
candidate capture is required evidence even when the next step is immediate reusable promotion. If
the current task is explicitly maintaining the CppStudio source repo, or the user explicitly asks to
add the missing donor to the reusable/global CppStudio donor library, promote the vetted donor into
the CppStudio **source** donor library under
`skills/cpp-cuda-vulkan-studio/references/donor-library/` and then run the repo rollout. Do not
hand-edit the installed user-level donor library as the source of truth. If working from a target
project and the CppStudio source repo path is not known, use `CPPSTUDIO_SOURCE_ROOT` when set or ask
for the source repo path; otherwise keep the candidate project-local and state that reusable
promotion is pending. Never skip the target-project candidate artifact because the CppStudio source
repo is available; reusable promotion should be traceable back to the candidate evidence that
justified it.

For substantial greenfield planning artifacts, include an explicit donor-candidate disposition. If
the research found reusable sources not already covered by the local donor library, write a separate
`docs/planning/DONOR_CANDIDATES.md` unless the user explicitly requested one compact file. If no new
candidate exists, say that in the research brief. Do not make the user infer whether no donor file
means "none found" or "the agent forgot."

For each major subsystem that would shape architecture, run a lightweight research-to-plan gate
before locking the recommendation. Major subsystems include renderer, simulation/solver, asset or
scene pipeline, authoring/source-of-truth model, GUI/HUD/editor shell, input, agentic control
harness, persistence/serialization, build/dependency policy, validation/profiling, and AI/runtime
integration. Each gate needs only enough evidence to decide responsibly: local facts discovered,
skills/donor routes opened, current upstream or peer-tool sources checked when relevant, the chosen
default, rejected alternatives, and the validation evidence required for milestone 1.

Treat task lists as living control documents, not contracts against stale assumptions. If local
inspection, donor research, upstream docs, toolchain behavior, validation results, or a failed probe
shows that the original trajectory is wrong or incomplete, update the task list before continuing:
record the new fact, why the old task no longer fits, the revised bounded slice, changed validation
gates, and any assumptions that now need evidence. Do not ask the user for permission to make small
internal realignments that preserve the project intent and quality bar. Pause and ask only when the
realignment changes a user-facing product decision, selected stack, scope, schedule, data ownership,
license/dependency posture, or an explicitly agreed constraint.

For substantial software, use `important-instruction-ledger` as the active slice watchlist before
major planning decisions, worker nudges, slice readiness approval, source edits, commits, and status
summaries. Record what the supervising or direct agent must actively watch for the next slice:
quality risks, donor facts, plan gates, code-map state, blocked scope, visible-loop expectations,
verification evidence, review findings, and user hard rules or prerequisites. The planning packet
and validators are not substitutes for checking active watch items against primary artifacts.

Midstream feature requests are planning inputs, not shortcuts around planning. If the user asks to
add, include, swap, or "already support" a major subsystem after planning or implementation has
started, reopen the same research-to-plan gate for that subsystem before coding or giving a final
go/no-go recommendation. Read the enabled code map and current planning artifacts, open the smallest
matching donor routes, check current upstream/primary sources and local capability facts, then update
`docs/planning/RESEARCH_BRIEF.md`, `docs/planning/IMPLEMENTATION_SLICE_PLAN.md`, donor-candidate
notes when relevant, and the applicable `Project Dos And Don'ts` or decision-record section. If the
answer is "not yet" or "only after an architecture choice," record the rejected direct path, the
required decision or prerequisite slice, and the validation gate that would make it safe later.

For any project with an interactive tool, editor, procedural workflow, scene/content pipeline,
simulation setup, material/shader workflow, timeline, graph, layer stack, scripting surface, or other
nontrivial user-authored state, the research brief must include a peer-practice scan for the
project's authoring model and source of truth. Look at how comparable current tools let users build,
connect, edit, serialize, evaluate, reuse, and package work. Surface the likely choices, such as node
or dataflow graph, layer/stack, timeline/sequencer, scene tree/component model, direct parameter
inspector, scripting API, or hybrids. Do not assume a dock-panel or direct-parameter workflow just
because it is easier to scaffold; recommend the authoring model that peer research supports and ask
the user to confirm or choose an alternative before files are created.

For ambitious artist, game, VFX, DCC, simulation-editor, or technical-art tools, first identify the
software orientation: the closest current peer-tool family, target user workflow, primary authoring
surface, runtime/editor split, asset handoff, and validation style. Use current peer practice from
official docs, active tools, engines, SDKs, samples, papers, or vendor guidance before recommending
viewport shape, timeline/transport placement, editor layout, command surfaces, authoring model,
solver architecture, or source-of-truth ownership. The plan must separate peer-backed decisions from
local donor guidance and inference.

For any interactive artist, game, VFX, DCC, simulation-editor, technical-art, viewer/editor, brush,
paint, grooming, terrain, material, rigging, animation, layout, lighting, or effects tool, lock the
primary user-visible loop before implementation. Derive that loop from peer-tool and donor research;
do not hardcode it from a generic template. The loop must name the target user action, the authored
or runtime state it changes, the visible result, the proof method, and the first slice that proves it
end to end. The first implementation milestone must make that loop visible and testable unless a
documented prerequisite is strictly required to prove it. Secondary breadth such as extra tools,
brushes, panels, modes, format options, polish controls, or fixture-only variants is blocked until
the primary loop has comparable before/after or input-to-result evidence. If a plan adds breadth
while the primary loop is still invisible, fixture-only, or unverified, repair the plan before source
files are created.

The visible loop must also classify the user interaction shape before implementation. A visible
button click, click-and-drag, continuous stroke, scrub, lasso, gizmo drag, camera orbit, timeline
drag, node connection, stylus stroke, or palette selection has different acceptance evidence. The
slice cannot prove a continuous or compound interaction with a single click/dab smoke. The plan must
name the expected gesture, the sample/readback fields that prove it happened through the real UI
path, the visible control or affordance used to initiate it, and the before/after artifact that lets
another agent or user inspect the result.

When the expected behavior is live feedback during the gesture, the plan must require proof before
release or final commit. Sculpt, paint, groom, terrain, drawing, and live transform tools need a
mid-gesture readback after a held-contact move sample and before release showing the visible or
semantic state has already changed. A final after-release diff is insufficient for those tools.

For that primary loop, vague nouns are not enough. The plan must name the concrete first proof
object, authored item, scene state, dataset, primitive, fixture, graph, asset, or interaction target
that makes the loop visible in the target domain, and it must justify that choice from donor or
peer-tool evidence. Do not accept generic wording such as "sample object", "generated target",
"test scene", "demo asset", "default graph", or "placeholder content" when a domain-appropriate
first proof object can be inferred. Examples: a sculpting loop should name a high-enough-resolution
sphere-like target plus a tiny numeric fixture; a fluid tool should name the first emitter/container
state; a material tool should name the first shader/material ball or asset; a node editor should
name the minimal graph that evaluates and displays a result. If the exact proof object is genuinely
uncertain, record the viable options and make it a user decision before source files are created.

When a tool family has multiple sibling tools, solve the shared tool substrate before proliferating
tool entries. The first real tool must be solid, selectable, applied through the real event path, and
visibly proven before adding more siblings. Shared behavior such as selection state, input sampling,
coordinate mapping, pressure/falloff, masks, undo/replay, cursor overlays, dirty-resource updates,
serialization, harness readback, and validation scenarios belongs in common tool infrastructure.
Only behavior that is genuinely unique to one tool should live in that tool's code. A plan that
duplicates shared behavior across early tools, or adds several tools before the first one works, is
not implementation-ready.

For substantial software, use a six-level planning depth contract. Each durable planning artifact
must state which depth it has reached and which depth is still required before implementation:

- `Level 0 - Intake And Context`: target user, product intent, platform, repo state, local
  constraints, Git/Rewind/code-map readiness, and missing facts.
- `Level 1 - Research And Ceiling`: local skills and donor routes opened, web/upstream sources,
  peer-tool scan, current best practices, source links, donor candidates, and source-access gaps.
- `Level 2 - Whole-Product Scaffold`: major systems for the full expected product, rough priority,
  dependencies, blocked areas, donor/reference routes, and parallelizable lanes. This prevents blind
  spots, but is not implementation-ready.
- `Level 3 - Donor Coverage And Quality Contract`: donor/peer expectations are converted into an
  explicit coverage matrix of included, deferred, rejected, or blocked capabilities with reasons and
  validation signals. For serious native C++ GPU, artist, game, VFX, DCC, simulation-editor, or
  technical-art tools, Level 3 is the default pre-source gate unless the user explicitly requests a
  lightweight prototype or tiny scoped change.
- `Level 4 - Slice Readiness`: the next slice has a just-in-time donor-backed packet naming the
  exact objective, current repo/code-map state, donors to reopen, APIs/contracts to inspect, shared
  infrastructure, concrete first proof object or state, unique behavior, expected files/subsystems,
  blocked scope, validation evidence, rollback/checkpoint state, and parallel safety.
- `Level 5 - Implementation And Closeout Proof`: source edits, exact validation, launch/UI/profiling
  or before/after evidence when relevant, code-map drift review, planning artifact reconciliation,
  and commit/changelog closeout when required.

For substantial software, produce the Level 2 whole-product scaffold before the first source slice.
The scaffold is not a speculative implementation design for every future feature; it is a coverage
map that names the major sections the product is expected to need, their rough priority, their
dependencies, their donor/reference route, and whether they look sequential, parallelizable, or
blocked by an earlier proof. Use it to prevent blind spots. Do not treat a Level 2 scaffold entry as
implementation-ready.

Before accepting a substantial scaffold as ready to feed implementation, produce the Level 3 donor
coverage and quality contract. It must map high-salience donor and peer-tool expectations to the
plan:

```text
Donor feature disposition matrix:
Donor or peer source:
Feature or quality contract:
Evidence source:
Plan section or slice:
State: included | deferred | rejected | blocked
Reason:
If deferred/rejected/blocked, return condition or owner:
Milestone validation signal:
```

Do not hide multiple important donor expectations inside one broad row such as "brush substrate",
"renderer", "GUI", or "tooling". Split the expectations until a reviewer can tell whether important
fundamentals were included, consciously deferred, rejected with reason, or blocked by an earlier
proof. If a high-salience peer-tool or donor contract is missing from the matrix, the plan is not
ready to implement. Donor citation by itself is invalid: when a plan says it is using a donor
shader, brush, renderer, solver, UI pattern, importer, optimizer, or subsystem, it must inventory the
important donor features before the plan is written, not retroactively after coding starts. Do not
skim donor code. Break the donor down into the elements that would make an implementation materially
different if they were omitted: for shaders, stages/passes, entry points, inputs/outputs,
descriptor/uniform contracts, coordinate spaces and units, variants/macros, render states,
sampling/filtering, lighting/material terms, quality features, edge cases, and validation signals;
for tools and subsystems, the equivalent state, data-flow, input, ownership, lifecycle, performance,
and UI contracts. Silent omissions are not allowed. If the current slice implements only a subset,
the omitted features must still appear as deferred, rejected, or blocked with reasons, owner/slice,
and validation signals so the omission is visible and reviewable.

Use explicit section headings when presenting this planning structure: `Planning Depth Contract`,
`Whole-Product Scaffold`, `Donor Feature Disposition Matrix`, `Capability Priority Ladder`,
`Parallelization Map`, and `Slice Readiness Packet`. Do not hide the priority ladder inside generic
"next steps" or "priority rules"; it must say what gets made first, how complete it must be before
the next capability unlocks, and what breadth remains blocked.

Before implementing any scaffolded section or slice, create a just-in-time slice readiness packet
for that slice. The packet must name the exact objective, current repo/code-map state, donor and
peer-tool links to open, source/API contracts to inspect, shared infrastructure it reuses, unique
behavior it owns, the concrete first proof object/state when the slice has visible or domain
behavior, expected files/subsystems, blocked scope, validation evidence, rollback/checkpoint state,
and whether parallel work is safe. Large renderer, GUI, input, brush/tool, solver, asset, authoring,
persistence, harness, or performance slices need real donor-backed readiness packets. Tiny
documentation or config slices may use a compact version, but code must not start from a
scaffold-level bullet alone.

If the next source slice has no matching Level 4 readiness packet, it is not ready to implement even
if the Level 2 scaffold, Level 3 matrix, build, OSTM, code-map checks, and planning guard pass.
Reading the plan in chat or summarizing the next slice is not a detailed planning artifact.

When the scaffold identifies possible parallel lanes, also record a parallelization map. It should
state which sections can proceed independently, which shared contracts must be frozen first, which
files or subsystems each lane would own, what validation handoff proves compatibility, and which
lanes must stay sequential because C++ ownership, renderer state, GPU resource lifetime, UI event
routing, or source-of-truth coupling makes parallel edits risky. Multi-agent execution remains a
supervisor/user decision; the plan prepares the split, it does not automatically spawn workers.

Default to the best available approach for the target project, not the easiest implementation. Do not
recommend a simpler, older, or lower-ceiling route just because it is quick to scaffold unless the
user explicitly asks for a lighter solution, throwaway prototype, conservative dependency set, or
teaching/demo path.

Then ask for Plan mode with this handoff:

```text
Please switch to Plan mode before implementation so I can ask the project-shaping questions. I need
to lock down the template, authoring model/source of truth, GUI/input stack, GPU lane, agentic
control harness, donor routes, web checks, code-map choice, and validation plan before files are
created.
```

This handoff is mandatory for substantial greenfield projects with unresolved choices. A supervisor,
test, or replay prompt that asks the worker to "write the plan", "report the chosen stack", "continue
planning", "use recommended defaults", or similar is not permission to bypass the handoff or lock
choices in normal chat. The research artifact may include recommended defaults and alternatives, but
the worker must not ask or answer the actual choice questions until Plan mode is active or the user
explicitly waives Plan mode.

For greenfield target repos, code-map choice is a hard pre-source gate. Before the first
implementation slice writes source, build, app, renderer, test, or docs scaffold files, the plan must
end with one of these states: maintained code map accepted and ready to bootstrap, code map declined
and ready to record through the bootstrap script, or explicit user instruction to defer the decision.
"Pending" is not an implementation-ready state. Do not treat a plan bullet that says "code-map
choice" as user acceptance.

If the current turn explicitly says the session is already in Plan mode, still do the pre-plan
research brief before calling any question UI. If Plan mode tooling is unavailable or the user
explicitly says to continue without it, keep the planning conversation to no more than three
questions at a time and do not scaffold until the critical choices are clear.

For GUI/HUD/tool UI choices, links must be visible at decision time. Before using interactive
question UI such as `request_user_input`, present a compact option table with source/docs and visual
inspection links; also include a compact URL in each option description when the question UI allows
it.

For interactive native apps, include an agentic control harness in the initial plan by default. Do
not frame it as an optional nice-to-have unless the target is a headless library, a
security-sensitive product surface, or the user explicitly opts out. The decision to ask the user is
which local control shape to use first: localhost HTTP plus curl, CLI/script adapter, optional MCP
facade over the same API, and which state/log/visual observation surfaces are needed for milestone 1.

For interactive viewport or GUI tools, also include an app-owned viewport-session testing lane by
default. This is the real user-path recorder/replayer for viewport clicks, stylus strokes, tool
buttons, timelines, node graphs, gizmos, camera controls, screenshots, semantic traces, and
before/after bug proof. It does not replace the control harness; it complements it. For user-facing
tools, the lane needs visible record/stop/replay or equivalent capture controls in the app once the
first interactive surface exists, not only a hidden CLI smoke path. If a project is headless or the
user opts out, record why the lane is not applicable.

## What To Load

1. Read `references/project-intake.md` for the planning protocol and project packet.
2. Read `references/choice-matrix.md` for template, lane, GUI, donor, input, and validation choices.
3. Use `cpp-cuda-vulkan-studio` for project archetypes, Vulkan-first lane policy, code-map policy,
   donor routing, and implementation handoff.
4. Use `native-cpp-gui-hud` for GUI/HUD/editor UI decisions. When presenting GUI options, include
   source/docs links and visual inspection links from `native-cpp-gui-hud/references/gui-options.md`.
5. Use `agentic-control-harness` for local HTTP/curl controls, optional MCP facade, launch/control
   registry, main-thread routing, app observation, and feature-control maintenance.
6. Use `viewport-session-testing` for app-owned recording/replay of real viewport and GUI
   interactions, session reports, screenshot/capture proof, and user-reported visible bug repros.
7. Use `modern-cpp-cmake`, `vulkan-compute-sync`, and `cuda-kernel-authoring` only when their lane is
   selected or needed for a concrete planning decision.

## Planning Workflow

1. Classify the project: renderer, simulation, artist tool, game technical-art tool, DCC/asset
   pipeline, AI runtime, CUDA library, Vulkan app, explicit CUDA/Vulkan interop app, XR app, or
   existing-repo upgrade.
2. Auto-discover local target facts before asking the user for choices: repo instructions, code-map
   state, build docs, presets, manifests, scripts, validation entrypoints, existing control or launch
   surfaces, app/library boundaries, name collisions, and template/toolchain constraints.
3. Run a pre-plan research pass before asking for choices: target platform implications, likely
   template/archetype, authoring model/source of truth, GPU lane, GUI/HUD stack, agentic control
   harness, input devices, donor categories, dependency policy, validation budget, and code-map
   preference.
4. Run an extensive state-of-the-art web ceiling check for current dependencies, SDKs, GUI/toolkit
   choices, authoring workflows, papers, samples, engines, or vendor guidance that could affect
   architecture. Prefer upstream docs, official repos, standards bodies, recent papers, vendor
   documentation, active samples, release notes, and adoption signals. Include current comparable
   tools from the same user/workflow domain, and extract their common authoring practices before
   proposing a source-of-truth model.
5. Apply the source-access quality gate: document any failed opens, continue only with equivalent
   primary-source coverage, and block the plan when a critical decision would otherwise depend on
   missing or secondary evidence.
6. For large artist, game, VFX, DCC, simulation-editor, or technical-art tools, state the software
   orientation and current peer-tool family before ranking product-shape decisions.
7. Open the smallest matching donor categories and profiles before recommending solvers, renderer
   backbones, GUI stacks, asset/runtime formats, AI runtimes, or simulation architecture.
8. Treat product-surface choices as donor-gated decisions, not implementation conveniences. Before
   recommending or scaffolding viewport dimensionality, timeline/transport placement, editor layout,
   node graph/layer stack/source of truth, solver architecture, or render path, cite the donor or
   peer-tool evidence that supports it.
9. Distill the research into project-specific dos and don'ts before implementation. Include app/domain
   rules and GUI/product-surface rules. Each rule needs source evidence, affected subsystem/surface,
   and validation signal.
10. Add a short decision record for each major subsystem: local facts, peer/upstream/donor evidence,
   selected default, rejected alternatives, open user decision if any, and milestone-1 validation.
11. Separate current leading approaches from legacy/outdated approaches, state the freshness evidence,
   and call out when a local donor is still useful only as reference because the current best approach
   has moved on.
12. For substantial software, label the current planning depth and do not let a Level 1 research
   brief or Level 2 scaffold masquerade as implementation-ready. If the project is an ambitious
   artist/game/VFX/DCC/simulation-editor/technical-art tool, build the Level 3 donor coverage matrix
   before accepting the scaffold for implementation.
13. Present a compact pre-plan research brief with unresolved choices, recommended defaults, links,
   donor routes, peer-tool authoring-model findings, web sources checked, current-vs-legacy notes,
   and the reasoning for the best available option. Then stop with the Plan-mode handoff. Ask the
   decision questions only after Plan mode is active, or after the user explicitly waives Plan mode.
14. Persist the research brief for substantial projects before implementation. Prefer
   `docs/planning/RESEARCH_BRIEF.md`; include `docs/planning/DONOR_CANDIDATES.md` when strong
   reusable sources were found that are not already covered by the donor library. If the user only
   asked for a tiny exploratory answer and no project repo exists, state that no durable artifact was
   written.

## Planning Packet

Every substantial plan should include:

- project intent and target users
- local target facts discovered before asking the user
- software orientation and current peer-tool family for large artist/game/VFX/DCC tools
- planning depth contract: current Level 0-5 state, required depth before source, and why any lower
  depth is sufficient only for tiny scoped work
- shallow whole-product scaffold map: major product sections, rough priority, dependencies, donor
  routes, and sequential/parallel/blocker classification
- donor coverage matrix: high-salience donor/peer expectations mapped to included, deferred,
  rejected, or blocked plan sections with reasons and validation signals
- donor feature disposition: for each donor shader, brush, renderer, solver, UI pattern, importer,
  optimizer, or subsystem that materially shapes the plan, the important donor features are
  inventoried and marked included, deferred, rejected, or blocked; silent omissions from donors are
  plan failures
- pre-plan donor-code breakdown: when donor code or official behavior docs are used, break down the
  donor's important elements before writing the plan so the matrix is derived from observed donor
  contracts rather than an eyeballed summary
- primary user-visible loop: user action, state change, visible result, proof method, and first slice
  that proves it before secondary feature breadth
- interaction-shape contract: click, click-drag, continuous stroke, scrub, lasso, gizmo drag,
  camera orbit, timeline drag, node connection, stylus stroke, palette selection, or other shape,
  with the real UI affordance, event samples/readback, and before/after evidence needed to prove it
- concrete first proof object/state: the domain object, scene, asset, graph, primitive, dataset, or
  interaction target that makes the visible loop real, with donor/peer justification and separate
  tiny fixtures when numeric unit tests need them
- shared tool substrate for tool families: common state/input/validation/features factored before
  adding sibling tools, with only unique behavior isolated per tool
- capability priority ladder: what must be created first, how complete it must be before moving on,
  what adjacent capability proves the shared substrate next, and what stays delayed breadth
- slice readiness packet rule: scaffolded future slices are not implementation-ready until a
  just-in-time donor-backed packet names objective, donors, contracts, shared/unique behavior,
  concrete proof object/state, expected files, blocked scope, validation, and rollback/checkpoint
  state
- parallelization map: candidate independent lanes, required frozen shared contracts, ownership
  boundaries, handoff validations, and lanes that must remain sequential
- recommended CppStudio archetype/template
- authoring model/source of truth options and recommendation, with peer-practice evidence
- GPU lane: Vulkan-first, CUDA, or explicit interop, with why
- GUI/HUD/editor UI options with clickable source/docs and visual inspection links
- agentic control harness plan: local transport, MCP facade timing, command/readback surfaces,
  curl examples, safety policy, and feature-maintenance rule
- artist-input needs such as Wacom/stylus pressure, tilt, eraser, hover, smoothing, sampling,
  undo/redo stroke recording, multi-touch, SpaceMouse, XR controllers, or viewport picking
- skill routes opened and donor categories/profiles selected
- web sources checked and what changed because of them, with durable project-local research artifact
  path when one was written
- unavailable or unverified source URLs, exact errors, substitute evidence if any, and whether the
  missing source blocks a decision
- donor candidates discovered outside the current library, with whether they were saved in the
  target project or promoted into the CppStudio source donor library; installed user-level donor
  files must be regenerated from source rollout, not patched directly
- project-specific dos and don'ts derived from donor, upstream, and peer-tool evidence, including
  GUI/product-surface rules and their validation signals
- current state-of-the-art or actively popular approaches, separated from legacy approaches
- comparable current tools checked and what their common authoring practices imply
- per-subsystem decision records for major renderer, solver, authoring, GUI, asset, control,
  persistence, build/dependency, validation, or runtime choices
- unresolved user decisions, grouped into no more than three questions at a time
- code-map recommendation and whether it is accepted, declined, or explicitly deferred. For
  greenfield implementation, `pending` blocks source work.
- validation/profiling plan for the first implementation milestone
- implementation handoff checklist for the next agent step

## Planning Packet Lifecycle

Planning packets, research briefs, donor-candidate files, and implementation slice plans are live
handoff artifacts. They are not allowed to freeze at the pre-source state once implementation starts.

Before a major next slice, a supervisor or worker must reconcile those artifacts against the current
repo state:

- source files, build files, harness routes, code-map docs, or commits that now exist
- completed slices and validation evidence
- user choices that were accepted, declined, or superseded
- blockers that were resolved, newly discovered, or still active
- current next task, expected files, donor routes, and verification gates

Do not rely on a worker's chat summary to decide whether a plan is legitimate. Inspect the actual
planning artifacts, code map, diff, validation artifacts, and relevant transcript tail before saying
the plan is good or ready to implement. If an artifact still says "planning only", "no source exists",
or points at a stale blocker after source work has landed, update or supersede it before the next
major implementation slice. The update can be a small `Current State` or `Superseded By` section when
rewriting the original packet would obscure useful history.

## Defaults

- When CUDA and Vulkan are both plausible but unspecified, recommend Vulkan first for reusable
  realtime, rendering, visualization, XR, simulation-viewer, and cross-vendor C++ tools.
- Keep Vulkan-only projects Vulkan-only unless CUDA is explicitly chosen or required.
- For realtime internal artist tools, default GUI comparison starts with Dear ImGui plus ImGuizmo
  and ImPlot, then compares Qt/wxWidgets or RmlUi/NoesisGUI when the product shape calls for them.
- For interactive native apps, default the agentic control harness to local-only HTTP plus curl with
  optional MCP layered over the same API after the basic command/readback surface is proven.
- For brush, sculpt, paint, grooming, terrain, rigging, animation, or other artist-facing tools,
  treat tablet/stylus input as a first-class planning decision.
- For active brush, sculpt, paint, groom, terrain, texture, or stroke-based artist tools, do not
  choose a mouse-first window/input stack only because it is locally installed or simpler. Evaluate a
  pressure-capable path such as SDL3 pen events, Qt/tablet events, or native tablet APIs. If the
  recommended stack cannot carry stylus pressure, tilt, hover, eraser, barrel buttons, and tablet
  mapping without a separate integration path, mark it as a lower-ceiling or mouse-only tradeoff and
  ask the user to accept that limitation before implementation.
- For tools with user-authored state, derive the authoring model from peer research. If comparable
  current tools cluster around a graph, stack, timeline, scene tree, scripting surface, or hybrid,
  present that as the leading option and ask the user to confirm or choose another model before
  implementation.
- For substantial tools, do not ask the user for facts the workspace can reveal. Bootstrap target
  facts first, then ask only for unavailable preferences or explicit product choices.
- For large artist, game, VFX, DCC, simulation-editor, or technical-art tools, orient the plan around
  current software practice before choosing product shape. Record when a recommendation is peer-backed
  versus donor-backed versus inference.
- Prefer the highest-quality current approach that fits the target project. Offer simpler legacy or
  low-effort approaches only as explicit tradeoffs, not as the default, unless the user asks for that.
