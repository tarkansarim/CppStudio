---
name: cppstudio-project-planner
description: "Plan native C++ GPU/realtime projects before scaffolding or major architecture work: gather requirements, choose CppStudio project archetype/template, Vulkan/CUDA/interop lane, GUI/HUD stack, artist input such as Wacom/stylus pressure, donor categories, web ceiling checks, code-map policy, validation lanes, and user decisions. Use for initial project planning, project intake, architecture blueprints, or when a C++/Vulkan/CUDA/3D/AI/simulation/tool app has multiple unresolved choices."
---

# CppStudio Project Planner

Use this skill as the front door for major native C++ GPU project planning. It does not replace
`cpp-cuda-vulkan-studio`; it prepares a grounded project plan, records user choices, and then hands
implementation to the specific CppStudio, GUI, Vulkan, CUDA, CMake, and donor routes.

## Core Rule

Do not scaffold or make broad architecture commitments while major project-shaping choices are still
unresolved.

For a substantial initial project request, gather a pre-plan research brief before asking the user to
switch to Plan mode or presenting decision questions. Do not jump straight into question UI.

The pre-plan research brief must open the relevant local skill/donor references and run targeted web
checks against upstream/primary sources for current GUI, SDK, simulation, renderer, dependency, or
hardware choices. Keep it concise, but it must be enough that the user is choosing between researched
options rather than unsupported guesses.

Then ask for Plan mode with this handoff:

```text
Please switch to Plan mode before implementation so I can ask the project-shaping questions. I need
to lock down the template, GUI/input stack, GPU lane, donor routes, web checks, code-map choice, and
validation plan before files are created.
```

If the current turn explicitly says the session is already in Plan mode, still do the pre-plan
research brief before calling any question UI. If Plan mode tooling is unavailable or the user
explicitly says to continue without it, keep the planning conversation to no more than three
questions at a time and do not scaffold until the critical choices are clear.

For GUI/HUD/tool UI choices, links must be visible at decision time. Before using interactive
question UI such as `request_user_input`, present a compact option table with source/docs and visual
inspection links; also include a compact URL in each option description when the question UI allows
it.

## What To Load

1. Read `references/project-intake.md` for the planning protocol and project packet.
2. Read `references/choice-matrix.md` for template, lane, GUI, donor, input, and validation choices.
3. Use `cpp-cuda-vulkan-studio` for project archetypes, Vulkan-first lane policy, code-map policy,
   donor routing, and implementation handoff.
4. Use `native-cpp-gui-hud` for GUI/HUD/editor UI decisions. When presenting GUI options, include
   source/docs links and visual inspection links from `native-cpp-gui-hud/references/gui-options.md`.
5. Use `modern-cpp-cmake`, `vulkan-compute-sync`, and `cuda-kernel-authoring` only when their lane is
   selected or needed for a concrete planning decision.

## Planning Workflow

1. Classify the project: renderer, simulation, artist tool, game technical-art tool, DCC/asset
   pipeline, AI runtime, CUDA library, Vulkan app, explicit CUDA/Vulkan interop app, XR app, or
   existing-repo upgrade.
2. Run a pre-plan research pass before asking for choices: target platform implications, likely
   template/archetype, GPU lane, GUI/HUD stack, input devices, donor categories, dependency policy,
   validation budget, and code-map preference.
3. Run a targeted web ceiling check for current dependencies, SDKs, GUI/toolkit choices, papers,
   samples, or vendor guidance that could affect architecture. Prefer upstream docs, official repos,
   standards bodies, papers, and vendor documentation.
4. Open the smallest matching donor categories and profiles before recommending solvers, renderer
   backbones, GUI stacks, asset/runtime formats, AI runtimes, or simulation architecture.
5. Present a compact pre-plan research brief with choices, recommended defaults, links, donor
   routes, and web sources checked, then ask for Plan mode and only then ask decision questions.

## Planning Packet

Every substantial plan should include:

- project intent and target users
- recommended CppStudio archetype/template
- GPU lane: Vulkan-first, CUDA, or explicit interop, with why
- GUI/HUD/editor UI options with clickable source/docs and visual inspection links
- artist-input needs such as Wacom/stylus pressure, tilt, eraser, hover, smoothing, sampling,
  undo/redo stroke recording, multi-touch, SpaceMouse, XR controllers, or viewport picking
- skill routes opened and donor categories/profiles selected
- web sources checked and what changed because of them
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
- For brush, sculpt, paint, grooming, terrain, rigging, animation, or other artist-facing tools,
  treat tablet/stylus input as a first-class planning decision.
