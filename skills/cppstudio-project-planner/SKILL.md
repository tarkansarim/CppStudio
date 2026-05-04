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
switch to Plan mode or presenting decision questions. Do not jump straight into question UI.

The pre-plan research brief must open the relevant local skill/donor references and run an extensive
state-of-the-art web ceiling check against upstream/primary sources for current GUI, SDK, simulation,
renderer, dependency, authoring-model, or hardware choices. Keep the user-facing brief concise, but
the research must be deep enough that the user is choosing between current, competitive options
rather than unsupported guesses.

For any project with an interactive tool, editor, procedural workflow, scene/content pipeline,
simulation setup, material/shader workflow, timeline, graph, layer stack, scripting surface, or other
nontrivial user-authored state, the research brief must include a peer-practice scan for the
project's authoring model and source of truth. Look at how comparable current tools let users build,
connect, edit, serialize, evaluate, reuse, and package work. Surface the likely choices, such as node
or dataflow graph, layer/stack, timeline/sequencer, scene tree/component model, direct parameter
inspector, scripting API, or hybrids. Do not assume a dock-panel or direct-parameter workflow just
because it is easier to scaffold; recommend the authoring model that peer research supports and ask
the user to confirm or choose an alternative before files are created.

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

## What To Load

1. Read `references/project-intake.md` for the planning protocol and project packet.
2. Read `references/choice-matrix.md` for template, lane, GUI, donor, input, and validation choices.
3. Use `cpp-cuda-vulkan-studio` for project archetypes, Vulkan-first lane policy, code-map policy,
   donor routing, and implementation handoff.
4. Use `native-cpp-gui-hud` for GUI/HUD/editor UI decisions. When presenting GUI options, include
   source/docs links and visual inspection links from `native-cpp-gui-hud/references/gui-options.md`.
5. Use `agentic-control-harness` for local HTTP/curl controls, optional MCP facade, launch/control
   registry, main-thread routing, app observation, and feature-control maintenance.
6. Use `modern-cpp-cmake`, `vulkan-compute-sync`, and `cuda-kernel-authoring` only when their lane is
   selected or needed for a concrete planning decision.

## Planning Workflow

1. Classify the project: renderer, simulation, artist tool, game technical-art tool, DCC/asset
   pipeline, AI runtime, CUDA library, Vulkan app, explicit CUDA/Vulkan interop app, XR app, or
   existing-repo upgrade.
2. Run a pre-plan research pass before asking for choices: target platform implications, likely
   template/archetype, authoring model/source of truth, GPU lane, GUI/HUD stack, agentic control
   harness, input devices, donor categories, dependency policy, validation budget, and code-map
   preference.
3. Run an extensive state-of-the-art web ceiling check for current dependencies, SDKs, GUI/toolkit
   choices, authoring workflows, papers, samples, engines, or vendor guidance that could affect
   architecture. Prefer upstream docs, official repos, standards bodies, recent papers, vendor
   documentation, active samples, release notes, and adoption signals. Include current comparable
   tools from the same user/workflow domain, and extract their common authoring practices before
   proposing a source-of-truth model.
4. Open the smallest matching donor categories and profiles before recommending solvers, renderer
   backbones, GUI stacks, asset/runtime formats, AI runtimes, or simulation architecture.
5. Treat product-surface choices as donor-gated decisions, not implementation conveniences. Before
   recommending or scaffolding viewport dimensionality, timeline/transport placement, editor layout,
   node graph/layer stack/source of truth, solver architecture, or render path, cite the donor or
   peer-tool evidence that supports it.
6. Separate current leading approaches from legacy/outdated approaches, state the freshness evidence,
   and call out when a local donor is still useful only as reference because the current best approach
   has moved on.
7. Present a compact pre-plan research brief with choices, recommended defaults, links, donor
   routes, peer-tool authoring-model findings, web sources checked, current-vs-legacy notes, and the
   reasoning for the best available option, then ask for Plan mode and only then ask decision
   questions.

## Planning Packet

Every substantial plan should include:

- project intent and target users
- recommended CppStudio archetype/template
- authoring model/source of truth options and recommendation, with peer-practice evidence
- GPU lane: Vulkan-first, CUDA, or explicit interop, with why
- GUI/HUD/editor UI options with clickable source/docs and visual inspection links
- agentic control harness plan: local transport, MCP facade timing, command/readback surfaces,
  curl examples, safety policy, and feature-maintenance rule
- artist-input needs such as Wacom/stylus pressure, tilt, eraser, hover, smoothing, sampling,
  undo/redo stroke recording, multi-touch, SpaceMouse, XR controllers, or viewport picking
- skill routes opened and donor categories/profiles selected
- web sources checked and what changed because of them
- current state-of-the-art or actively popular approaches, separated from legacy approaches
- comparable current tools checked and what their common authoring practices imply
- unresolved user decisions, grouped into no more than three questions at a time
- code-map recommendation and whether it is accepted, declined, or pending
- validation/profiling plan for the first implementation milestone
- implementation handoff checklist for the next agent step

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
- For tools with user-authored state, derive the authoring model from peer research. If comparable
  current tools cluster around a graph, stack, timeline, scene tree, scripting surface, or hybrid,
  present that as the leading option and ask the user to confirm or choose another model before
  implementation.
- Prefer the highest-quality current approach that fits the target project. Offer simpler legacy or
  low-effort approaches only as explicit tradeoffs, not as the default, unless the user asks for that.
