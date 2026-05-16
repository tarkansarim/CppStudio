# Project Intake Protocol

Use this protocol when a user wants to start, brainstorm, or substantially reshape a native C++
GPU/realtime project. The output is a planning packet, not code.

## Plan Mode Gate

If the project has unresolved choices across template, authoring model/source of truth, GUI, GPU
lane, agentic control harness, dependencies, input devices, or donor strategy, gather a pre-plan
research brief before asking the user to switch to Plan mode or presenting decision questions. The
brief should use local CppStudio skill/donor routing plus an extensive state-of-the-art web ceiling
check against upstream or primary sources, so the user is choosing from researched options.

Start with a target bootstrap pass. Auto-discover facts the workspace can answer before asking the
user: repo instructions, enabled code maps, README/build docs, presets, manifests, scripts, validation
entrypoints, app/library boundaries, existing launch or control docs, requested project name, nearby
repo constraints, available templates, and likely toolchain assumptions. Ask the user only for
preferences, missing constraints, or product decisions that cannot be discovered locally.

The pre-plan research brief should include:

- local target facts discovered before questions
- likely project archetype/template
- likely authoring model/source-of-truth options and comparable-tool evidence
- likely GPU lane and alternatives
- GUI/HUD candidates with source/docs and visual inspection links
- default agentic control harness shape for interactive apps
- relevant donor categories/profiles opened
- web/current sources checked, with freshness/adoption signals where available and a short
  description of how each source benefits this project
- project-specific dos and don'ts derived from the research, including GUI/product-surface best
  practices when the target has an interface
- current state-of-the-art or actively popular approaches, separated from legacy approaches
- software orientation and current peer-tool family for large artist/game/VFX/DCC tools
- planning depth contract: the current Level 0-5 planning state, the required depth before source,
  and why any lower depth is acceptable only for tiny scoped work
- shallow whole-product scaffold plan: all major software sections the product is expected to need,
  rough priority, dependencies, donor/reference route, and whether each section looks sequential,
  parallelizable, or blocked
- donor coverage matrix: high-salience donor and peer-tool expectations mapped to included,
  deferred, rejected, or blocked capabilities with reasons and validation signals
- primary user-visible loop for interactive tools: the first target user action, the state it changes,
  the visible result, how milestone 1 proves it, and which secondary features are blocked until it
  works
- shared tool substrate for tool families: common selection/input/validation/state behavior that must
  be factored before adding sibling tools
- capability priority ladder: how much to create first, what minimum completeness threshold unlocks
  the next capability, and which breadth stays delayed
- just-in-time slice readiness rule: shallow scaffold entries are not implementation-ready until the
  worker writes a focused donor-backed packet for that slice before touching code
- parallelization map: which sections could be split across workers later, what shared contracts must
  be frozen first, and which sections must stay sequential because of coupling
- recommended best-available default and why

For substantial greenfield projects or architecture-setting plans, persist the research before
implementation. Create `docs/planning/RESEARCH_BRIEF.md` in the target project before asking for
Plan mode or scaffolding source. The artifact should combine local donor-library routes and
web/upstream sources, not replace one with the other. Cherry-pick sources: keep primary, current,
domain-relevant, license-understandable, and implementation-useful links; reject duplicates, stale
tutorials, vague summaries, abandoned projects unless they are deliberately study-only, and sources
that do not change a decision.

The persisted research artifact must include a `Project Dos And Don'ts` section for substantial
projects. This section converts research into implementation rules:

```text
## Project Dos And Don'ts

### App / Domain
- Do:
  - Rule:
    Evidence:
    Applies to:
    Validation signal:
- Don't:
  - Rule:
    Evidence:
    Applies to:
    Validation signal:

### GUI / Product Surface
- Do:
  - Rule:
    Evidence:
    Applies to:
    Validation signal:
- Don't:
  - Rule:
    Evidence:
    Applies to:
    Validation signal:
```

Use the app/domain section for architecture, source of truth, data flow, simulation/solver, renderer,
assets, input, persistence, performance, validation, and dependency rules. Use the GUI/product
surface section for best practices around layout, viewport behavior, timeline/transport placement,
tool palettes, inspectors, node/layer/scene surfaces, icon-versus-text affordances, status/error
feedback, debug-vs-product boundaries, and visual proof. Each GUI rule needs peer-tool,
UI-framework, or donor evidence; generic aesthetic wording is not enough.

When a strong reusable source is not already covered by the CppStudio donor library, record it in
`docs/planning/DONOR_CANDIDATES.md` or a donor-candidates section of the research brief. Include the
source URL, proposed category, likely tier, backend/language signal, license/freshness status when
known, direct-donor versus reference-only caveat, and why it should be promoted later. If the agent is
working in the CppStudio source repo with explicit donor-maintenance scope, promote vetted sources to
the source donor library there and roll out to the installed user-level copy; do not hand-edit
user-level installed skills as the source of truth.

For substantial greenfield projects, make donor-candidate status explicit. Prefer a separate
`docs/planning/DONOR_CANDIDATES.md` when new reusable sources are discovered; otherwise include a
"Donor candidates: none beyond existing donor-library routes" line in the research brief. Missing
donor-candidate status is a planning artifact gap.

For major subsystems, add a lightweight research-to-plan gate before locking the plan. Major
subsystems include renderer, simulation/solver, asset or scene pipeline, authoring/source-of-truth
model, GUI/HUD/editor shell, input, agentic control harness, persistence/serialization,
build/dependency policy, validation/profiling, and AI/runtime integration. The gate should record
local facts, skills/donor routes, current upstream or peer-tool sources when relevant, selected
default, rejected alternatives, and milestone-1 validation evidence. Keep it compact and proportional
to project risk.

Do not default to the easiest route if a better current approach exists. Recommend simpler, older, or
lower-ceiling options only as tradeoffs when the user asks for a lightweight solution, conservative
dependencies, teaching/demo code, or a throwaway prototype.

For interactive tools, add a primary visible-loop gate before implementation. The gate is generic:
derive the loop from the target domain's peer tools and donors, then make the first implementation
slice prove that one end-to-end action before feature breadth. A fixture, hidden backend model,
nonblank screenshot, or extra set of modes is not enough. The gate needs:

```text
Primary visible loop:
User action:
State changed:
Visible result:
Milestone-1 proof:
Blocked breadth until proven:
Evidence sources:
```

For tool families with multiple sibling tools, add a shared-substrate gate before adding tool count:

```text
First solid tool:
Shared tool substrate:
Per-tool unique behavior:
Duplication risks:
Milestone-1 proof:
Blocked sibling tools until proven:
```

For substantial software, use this planning depth hierarchy:

```text
Planning depth contract:
Level 0 - Intake And Context:
Level 1 - Research And Ceiling:
Level 2 - Whole-Product Scaffold:
Level 3 - Donor Coverage And Quality Contract:
Level 4 - Slice Readiness:
Level 5 - Implementation And Closeout Proof:
Current depth:
Required depth before source:
Reason if lower depth is acceptable:
```

Level 0 records target context and constraints. Level 1 records local donors plus current
web/upstream/peer research. Level 2 maps the whole expected software surface. Level 3 converts donor
and peer-tool expectations into explicit include/defer/reject/block decisions. Level 4 prepares a
single implementation slice. Level 5 records source edits and closeout proof.

For serious native C++ GPU, artist, game, VFX, DCC, simulation-editor, or technical-art tools,
default to Level 3 before any source files are created. A Level 2 scaffold is useful coverage, but it
does not prove the plan caught the domain fundamentals.

The Level 3 donor coverage matrix should use this shape:

```text
Donor coverage matrix:
Capability or quality contract:
Evidence source:
Plan section or slice:
State: included | deferred | rejected | blocked
Reason:
Milestone validation signal:
```

Do not collapse multiple fundamentals into one broad row. If peer tools or donors imply separate
contracts, such as an authoring surface, first visible loop, shared tool substrate, input path,
selection state, renderer feedback, persistence, validation, or performance proof, map them
separately so omissions are visible.

For substantial software, add a Level 2 shallow whole-product scaffold and a Level 4 slice-readiness
rule. The scaffold prevents missing major systems, but it should stay shallow enough to avoid fake
precision for distant features:

Use these headings explicitly in user-facing plans: `Planning Depth Contract`, `Whole-Product
Scaffold`, `Donor Coverage Matrix`, `Capability Priority Ladder`, `Parallelization Map`, and
`Slice Readiness Packet`. The capability ladder is not a generic priority list; it must state the
minimum complete first capability, the threshold that unlocks the next capability, and the feature
breadth that stays blocked.

```text
Whole-product scaffold:
Section:
Purpose:
Priority:
Depends on:
Donor/reference route:
Implementation detail level: scaffold-only | ready packet required | ready now
Parallelization: independent | parallel after contract | sequential
Blocked until:
```

Before any scaffolded section becomes code, write a just-in-time readiness packet for that slice:

```text
Slice readiness packet:
Slice:
Objective:
Current repo/code-map state:
Donors and peer links to open:
Source/API contracts to inspect:
Shared infrastructure reused:
Unique behavior owned by this slice:
Expected files/subsystems:
Blocked scope:
Validation evidence:
Rollback/checkpoint state:
Parallel safety:
```

If multiple workers might help later, add a compact parallelization map:

```text
Parallelization map:
Lane:
Can run in parallel with:
Frozen shared contracts required first:
Owned files/subsystems:
Integration handoff:
Validation handoff:
Sequential risks:
```

If the plan cannot fill these in, or if the next slice would add secondary tools, modes, panels,
format options, duplicated tool code, or fixture-only breadth before the primary loop is visible and
testable, stop and repair the plan.

Then ask the user to switch to Plan mode before implementation, unless the current turn explicitly
says the session is already in Plan mode.

Use a direct handoff:

```text
Please switch to Plan mode before implementation so I can ask the project-shaping questions. I need
to lock down the template, authoring model/source of truth, GUI/input stack, GPU lane, agentic
control harness, donor routes, web checks, code-map choice, and validation plan before files are
created.
```

The benefit is fewer wrong dependencies, cleaner Vulkan/CUDA lane boundaries, better donor
grounding, and a validation plan before files are created.

If the session is already in Plan mode, still show the pre-plan research brief before calling any
question UI. If Plan mode is unavailable, ask no more than three questions at a time. Do not scaffold
until the critical choices are resolved.

For GUI/HUD/tool UI choices, links must be visible when the user is asked to choose. Before calling
interactive question UI such as `request_user_input`, show a compact link table. Include compact URLs
inside option descriptions when the question UI allows it; if the UI truncates them, the preceding
link table is mandatory.

## Intake Checklist

Collect these facts before committing to architecture:

- Target bootstrap: repo instructions, code-map state, README/build docs, presets, manifests, scripts,
  validation entrypoints, app/library boundaries, existing launch/control docs, requested name,
  workspace collisions, and visible template/toolchain constraints.
- Project type: renderer, simulation, artist tool, game technical-art tool, DCC tool, asset pipeline,
  AI runtime, CUDA library, Vulkan app, explicit interop app, XR app, or existing-repo upgrade.
- Target users: artist, technical artist, gameplay/tools programmer, graphics engineer, VFX pipeline
  TD, researcher, or product user.
- Software orientation for large tools: closest current peer-tool family, primary workflow, editor vs
  runtime split, asset handoff, command surfaces, validation style, and where current peer practice
  differs from simpler scaffold-friendly approaches.
- Planning depth: current Level 0-5 state, required depth before source, and whether a lower-depth
  plan is valid only because the task is tiny, scoped, or explicitly lightweight.
- Whole-product scaffold: major sections, rough priority order, dependencies, donor/reference routes,
  and sequential/parallel/blocker classification.
- Donor coverage matrix: high-salience donor and peer expectations, evidence source, include/defer/
  reject/block disposition, reason, and validation signal.
- Primary visible loop for interactive tools: the target user's first meaningful action, the state it
  changes, the visible result, the first proof, and the secondary breadth that must wait.
- Shared tool substrate for sibling tools: common state, event, input, validation, resource-update,
  serialization, and harness behavior that must not be duplicated per tool.
- Slice readiness packets: which future sections are scaffold-only and what donor-backed packet must
  be written immediately before code starts on each one.
- Parallelization map: candidate independent lanes, shared contracts to freeze, ownership boundaries,
  and validation handoffs before multi-agent work is used.
- Platforms: Linux, Windows, macOS, WSL, Steam Deck, studio workstation, or CI-only headless lane.
- GPU lane: Vulkan-first, CUDA, or explicit CUDA/Vulkan interop. If unspecified, recommend Vulkan
  first for cross-vendor realtime work.
- Template/archetype: greenfield scaffold, existing-repo backbone upgrade, library-only, app+library,
  renderer, simulation visualizer, tool shell, or headless compute package.
- Authoring model/source of truth: node/dataflow graph, layer or modifier stack,
  timeline/sequencer, scene tree/component model, parameter/inspector-driven scene, scripting API, or
  hybrid. Research comparable current tools first, then ask before implementation when the choice
  changes architecture, serialization, evaluation, undo/redo, validation, or agentic controls.
- GUI/HUD/editor stack: debug HUD, internal artist tool, polished desktop app, runtime game UI,
  embedded web UI, or mixed.
- Agentic control harness: default local-only HTTP/curl for interactive apps, optional MCP facade,
  command/scenario surfaces, readback endpoints, warning/log capture, visual/frame capture, and
  whether the target has a reason to opt out.
- Input devices: mouse/keyboard, Wacom/stylus, multi-touch, SpaceMouse, gamepad, MIDI/control
  surface, VR controllers, hand tracking, or custom hardware.
- Asset/data surfaces: glTF/GLB, USD, Alembic, OpenVDB/NanoVDB, textures/materials, CAD/NURBS,
  animation clips, groom curves, volume data, AI models, or custom binary formats.
- Donor grounding: matching production overlay, donor categories, deep profiles, and any reference
  material that is study-only or non-C++ reference-only.
- Web ceiling check: upstream repos/docs, official SDK docs, recent papers, active samples, release
  notes, vendor pages, standards docs, and adoption/freshness signals that could change the
  recommendation. Include comparable current tools from the same user/workflow domain and identify
  their common authoring practices, not only their rendering, solver, or dependency choices.
- Durable research artifact: for substantial projects, write `docs/planning/RESEARCH_BRIEF.md`
  before implementation with curated links, descriptions, benefits, donor routes, current-vs-legacy
  notes, rejected sources, project-specific dos and don'ts, GUI/product-surface best practices when
  applicable, and donor candidates that should be promoted to CppStudio later.
- Dependency policy: system packages, vcpkg, Conan, FetchContent, submodules, vendored source,
  commercial SDKs, license constraints, and offline/air-gapped requirements.
- Code map: ask whether the project should maintain a CppStudio code map for future agents. For
  greenfield repos, this is a hard pre-source gate: before the first implementation slice writes
  source, build, app, renderer, test, or docs scaffold files, the answer must be accepted, declined,
  or explicitly deferred by the user. A merely pending code-map choice blocks implementation. For
  existing repos, require the code-map readiness audit before enabling it.
- Validation: build presets, CTest labels, shader compilation, Vulkan validation, Compute Sanitizer,
  offscreen screenshots, profiler lanes, CI, and first milestone acceptance tests.

## Artist Tool Input Checklist

For artist-facing tools, explicitly plan the input model:

- stylus pressure, tilt, rotation, eraser, hover, barrel buttons, tablet mapping, and pressure curves
- stroke sampling rate, interpolation, stabilization, latency budget, smoothing, and undo/redo
  recording
- viewport picking, brush radius/depth behavior, symmetry, masks, falloffs, cursor overlays, and
  brush preview rendering
- left/right hand workflows, modifier keys, focus capture, DPI scaling, and multi-monitor/tablet
  coordinate mapping
- whether input is captured through the windowing layer, GUI toolkit, native tablet APIs, or a
  project-specific input abstraction

For active brush, sculpt, paint, groom, terrain, texture, and stroke-based tools, a mouse-only input
stack is not the quality default. Compare pressure-capable options such as SDL3 pen events,
Qt/tablet events, or native tablet APIs before choosing GLFW or another mouse/keyboard-first layer.
If a simpler stack is selected anyway, record the missing tablet behavior and ask the user to accept
that limitation before implementation.

## Authoring Model Checklist

For tools with user-authored state, peer-tool/source-of-truth checks are mandatory. Do not treat
panels, sliders, direct structs, or the fastest scaffold path as the default source of truth until
current comparable-tool research supports that choice. Identify:

- primary authoring surface: node/dataflow graph, stack/layers, timeline, scene tree, parameter
  inspector, scripting, or hybrid
- graph or object model: DAG, cyclic graph with solvers, ordered stack, event/timeline system,
  scene/component hierarchy, or command script
- serialization: project file shape, stable node/object IDs, versioning, presets/assets, imports,
  exports, and migration path
- evaluation: dependency tracking, invalidation, caching, baking, live preview, partial updates, and
  background work
- UX requirements: node search, grouping, comments, exposed controls, reusable compounds/assets,
  undo/redo, copy/paste, selection sync, and inspector behavior
- agentic control surface: create/edit/connect authoring objects, set parameters, evaluate, inspect
  errors, capture visual output, and serialize test fixtures

If comparable current tools converge on one authoring model, present that as the recommended default
with evidence and ask the user to confirm or pick an alternative before creating files.

## Subsystem Decision Records

For each major subsystem that changes architecture, add a compact decision record to the plan:

```text
Subsystem:
Local facts discovered:
Peer/upstream/donor evidence:
Selected default:
Rejected alternatives:
User decision needed:
Milestone-1 validation:
```

Use this for renderer, solver/simulation, authoring/source of truth, GUI/editor shell, asset or scene
pipeline, input, agentic controls, persistence, build/dependency policy, validation/profiling, and
AI/runtime decisions when they are in scope. Keep records brief; their purpose is to prevent hidden
architecture commitments, not to write a design document before the user chooses.

## Agentic Control Harness Checklist

For interactive native apps, tools, viewers, renderers, simulations, and editor-like workflows,
include a control harness from the first milestone by default. Ask about scope and transport, not
whether it should exist, unless the user explicitly opts out or the target is a headless library or
security-sensitive product surface.

The purpose is agent autonomy. The harness should let agents launch the app, drive features, inspect
state, collect warnings/logs, and capture what the user would see in the UI or viewport before
asking the user to test routine changes manually.

Plan:

- local-only transport: HTTP plus curl, CLI/script adapter, or both
- optional MCP facade timing over the same stable API
- launch mode and how agents discover it
- command or scenario surface for milestone features
- state readback for every meaningful mutation
- recent log/warning/error readback
- screenshot, offscreen frame, render-target dump, or text-readable viewport/UI state for visual apps
- main-thread or render-thread routing for app/GPU mutations
- docs/registry updates such as `docs/AGENTIC_CONTROL.md` and optional JSON control registry
- smoke/stress lanes for invalid commands, repeated commands, startup races, and feature interactions

## Planning Packet Template

Use this shape for the response:

```text
Project intent:
Target bootstrap facts:
Software orientation/current peer practice:
Recommended archetype/template:
Authoring model/source of truth:
GPU lane:
GUI/HUD options:
Agentic control harness:
Artist/input requirements:
Skills opened:
Donors opened:
Web sources checked:
Research artifact:
Donor candidates:
Current vs legacy:
Recommended default:
Subsystem decision records:
Questions before implementation:
Code-map choice:
Validation plan:
Implementation handoff:
```

Keep the packet compact. Put links next to the option they support.
