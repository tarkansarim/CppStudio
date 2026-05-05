# Planning Choice Matrix

Use this matrix to choose what the agent should inspect before implementation. Load only the rows
that match the project.

## Target Bootstrap Before Questions

Before asking the user for choices, inspect what the local target already reveals. Ask only for facts
that cannot be discovered from the workspace or for explicit preferences/product decisions.

| Target Shape | Auto-Discover First | Ask User Only For |
| --- | --- | --- |
| Existing repo | `AGENTS.md`, enabled code-map state/index/manifest, README/build docs, presets, manifests, scripts, validation entrypoints, existing launch/control docs, app/library boundaries | Missing product constraints, permission to change structure, unresolved lane or dependency choices |
| Greenfield in current workspace | Requested name, directory collisions, nearby repo rules, available CppStudio templates, likely platform/toolchain assumptions | Product scope, target platforms not inferable locally, code-map acceptance, dependency/license preferences |
| Existing generated CppStudio project | Code-map state, generated template version clues, validation scripts, CMake presets, control-harness docs, local deviations from template shape | Whether to preserve deviations, update template-era conventions, or restructure before new work |

## Research-To-Plan Gates

For each major subsystem that shapes architecture, add a compact decision record before locking the
plan. Keep the gate lightweight: local facts, sources checked, selected default, rejected
alternatives, user decision if any, and milestone-1 validation.

| Subsystem | Minimum Evidence Before Recommendation | Decision Record Must Name |
| --- | --- | --- |
| Renderer or render path | Project archetype, Vulkan/CUDA lane, renderer donors, current upstream/vendor guidance when version-sensitive | Chosen render architecture, rejected render paths, validation capture or screenshot plan |
| Simulation or solver | Domain donor route, current papers/samples/vendor docs when ceiling matters, coupling to renderer and assets | Solver family, data ownership, rejected solvers, deterministic tests and visual proof |
| Authoring/source of truth | Current comparable tools from the same workflow domain and their common authoring practices | Graph/stack/timeline/scene/scripting/direct/hybrid choice, source-of-truth owner, rejected models |
| GUI/HUD/editor shell | GUI skill, native GUI donor category, visual inspection links, peer product-surface conventions | Toolkit/shell, layout rationale, command-surface expectations, UI smoke/screenshot validation |
| Asset or scene pipeline | File/interchange donors, source asset ownership, import/export or runtime handoff constraints | Formats, identity/versioning, generated caches, round-trip or validator fixtures |
| Input and interaction | Target users, devices, toolkit/windowing constraints, peer interaction patterns | Input devices, sampling/latency needs, undo/redo or replay tests |
| Agentic control harness | App interactivity, launch path, required command/readback/visual surfaces | Transport shape, discoverability docs, first scenario endpoints, state/log/visual proof |
| Persistence/serialization | Authoring model, stable IDs, migration/versioning, fixtures | Project file shape, migration policy, round-trip validation |
| Build/dependency policy | Existing presets/manifests, repo dependency policy, native infrastructure donors | Dependency source, license/deployment caveats, build/CTest validation |
| Validation/profiling | Project risk, target platform, available toolchain, required evidence threshold | First milestone acceptance tests, profiler/sanitizer/tool-gap notes |
| AI/runtime integration | AI/runtime donor category, model/data boundaries, CUDA/Vulkan lane constraints | Runtime/dependency choice, model artifact policy, numerical/performance tests |

## Template And Archetype Choices

| Project Shape | Start With | Required Routing |
| --- | --- | --- |
| Vulkan renderer or compute app | CppStudio app+library scaffold, Vulkan-only `dev` lane | `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, project archetypes, Vulkan foundation donors |
| CUDA library or kernel package | Existing CMake/CUDA layout or CppStudio CUDA preset | `cpp-cuda-vulkan-studio`, `modern-cpp-cmake`, `cuda-kernel-authoring`, AI/runtime/kernel donors |
| CUDA plus Vulkan interop app | Explicit combined/interoperability plan | CppStudio interop archetype, CUDA donors, Vulkan donors, device identity and sync planning |
| Realtime artist tool | Vulkan-first app+library plus GUI/HUD skill and researched authoring model | `native-cpp-gui-hud`, graphics/rendering donors, asset/input donors, peer-tool authoring-model scan, validation screenshots |
| Game technical-art tool | Games production overlay plus native GUI/HUD and researched authoring model | games overlay, native engineering infrastructure, rendering/assets/simulation donors, peer-tool authoring-model scan |
| VFX/DCC pipeline tool | VFX production overlay plus DCC/asset categories and researched authoring model | DCC, USD/Alembic/MaterialX/OpenVDB/assets donors, peer-tool authoring-model scan |
| Simulation visualizer | Vulkan-first renderer plus simulation category and researched authoring model when users author scenarios | simulation-gpu, fluids/smoke/fire, geometry, volumes, rendering donors, peer-tool authoring-model scan |
| AI runtime or neural 3D tool | AI runtime category plus graphics/runtime viewer categories | AI runtimes, neural 3D, CUDA or Vulkan lane depending on actual implementation |
| Existing project upgrade | Read repo map if present, then code-map readiness audit if requested | existing layout audit, dependency policy, validation gaps, staged backbone application |

## Software Orientation For Large Artist/Game/VFX Tools

For large artist, game technical-art, VFX, DCC, simulation-editor, or asset-pipeline tools, identify
the closest current software family before choosing architecture. Product shape should come from
current peer practice plus local donor routing, not from whichever panel or data structure is easiest
to scaffold.

| Orientation | Inspect Current Peer Practice For | Common Planning Risk |
| --- | --- | --- |
| DCC/editor-style tool | Scene hierarchy, graph/stack/timeline split, inspectors, command surfaces, asset packages, undo/redo | Mistaking a parameter panel for the source of truth |
| Game technical-art or runtime tool | Iteration loop, asset cooking, runtime/editor boundary, debug vs shipped UI, platform budgets | Shipping debug-tool shape as product UI |
| VFX or pipeline tool | USD/Alembic/MaterialX/OpenVDB or department handoff, review/editorial needs, cache ownership | Hiding interchange/source-of-truth choices inside importer code |
| Simulation workbench | Scenario authoring, solver settings, playback, baking/cache, visual diagnostics, reproducibility | Coupling solver state directly to UI widgets |
| Brush, sculpt, paint, groom, or terrain tool | Tablet/stylus behavior, stroke model, layers/masks, viewport feedback, replay and undo | Treating input as ordinary mouse events only |

## Authoring Model Choices

For tools with user-authored state, comparable current-tool research is mandatory before choosing.
This choice often controls data ownership, serialization, undo/redo, validation, agentic controls, UI
structure, and whether docks/panels inspect a model or own the model.

| Option | Use When Peer Research Supports | Required Planning |
| --- | --- | --- |
| Node/dataflow graph | Users compose operations, dependencies, materials, procedures, effects, simulations, or reusable compounds visually | Graph data model, stable IDs, sockets/types, validation, serialization, evaluation order, inspector sync, create/connect/set/evaluate harness commands |
| Layer/modifier stack | Users apply ordered non-destructive operations with local parameters | Stack ordering, enable/disable, parameter schema, invalidation, presets, undo/redo, stack test fixtures |
| Timeline/sequencer | Time, events, clips, triggers, or staged transitions are the main authoring surface | Timeline model, keyframes/events, preview/bake behavior, scrubbing tests, agentic playback controls |
| Scene tree/component model | Hierarchical objects, components, resources, or entities are the primary mental model | Node/entity IDs, transforms, component schema, resource ownership, selection/inspector sync |
| Parameter/inspector-driven scene | The project is small, fixed-shape, or intentionally direct-control oriented | Explicit reason for avoiding richer authoring models, parameter schema, saved state, undo/redo, agentic set/get commands |
| Scripting/API-first | Technical users need programmable generation or batch workflows more than visual authoring | Script API, examples, sandbox/safety, deterministic fixtures, CLI/harness commands |
| Hybrid | Peer tools split work across graph, stack, timeline, scene tree, scripting, or direct controls | Declare the source of truth for each domain and how the surfaces sync without conflicting ownership |

## Agentic Control Harness Choices

For interactive native apps, tools, viewers, renderers, simulations, and editor-like workflows,
default to a local agentic control harness from milestone 1. The harness should let agents test,
troubleshoot, inspect state/logs, and capture UI or viewport evidence before asking the user for
manual verification.

| Option | Use When | Required Routing |
| --- | --- | --- |
| Local HTTP plus curl | Default for realtime apps, tools, viewers, and simulators that need reproducible agent control | `agentic-control-harness`, launch/control registry, state/log/visual readback |
| CLI or script adapter | Headless tools, batch converters, libraries with executable smoke paths, or projects where a server is too much for milestone 1 | `agentic-control-harness`, deterministic command docs, structured stdout/stderr |
| Optional MCP facade | The HTTP/curl or CLI control API is stable enough to wrap for richer agent integration | `agentic-control-harness`, same underlying API, no MCP-only controls |
| Deferred or disabled | Headless library, security-sensitive product surface, or explicit user opt-out | Record why, keep validation lanes strong, and do not repeatedly ask again |

## GUI/HUD Choices

When these options are presented to the user, include the source/docs and visual inspection links so
they can click through before choosing. The authoritative detailed table is
`native-cpp-gui-hud/references/gui-options.md`.

Before asking the user to choose through interactive question UI, show this link table or a shorter
task-specific version of it in the visible conversation. Compact option descriptions are not a
substitute for clickable links.

| Option | Use When | Source/Docs | Visual Inspection |
| --- | --- | --- | --- |
| Dear ImGui | Internal realtime tools, debug HUDs, inspectors, quick artist panels | <https://github.com/ocornut/imgui> | <https://github.com/ocornut/imgui#gallery> |
| ImGuizmo | 3D transform/view gizmos on top of Dear ImGui | <https://github.com/CedricGuillemet/ImGuizmo> | <https://github.com/CedricGuillemet/ImGuizmo#guizmos> |
| ImPlot | Plots, profiler panels, telemetry, curves, heatmaps | <https://github.com/epezent/implot> | <https://github.com/epezent/implot> |
| Qt | Full desktop app shell, complex menus, docks, document workflows | <https://doc.qt.io/qt-6/> | <https://doc.qt.io/qt-6/examples-desktop.html> |
| wxWidgets | Native-widget desktop app with lighter traditional UI | <https://wxwidgets.org/> | <https://wxwidgets.org/about/screenshots/> |
| RmlUi | Styled runtime/game HUDs and menus with HTML/CSS-like authoring | <https://github.com/mikke89/RmlUi> | <https://mikke89.github.io/RmlUiDoc/> |
| NoesisGUI | Commercial high-polish runtime UI, XAML workflows, VR/3D UI | <https://www.noesisengine.com/noesisgui/> | <https://www.noesisengine.com/> |
| Nuklear | Tiny embeddable immediate-mode utility UI | <https://github.com/Immediate-Mode-UI/Nuklear> | <https://github.com/Immediate-Mode-UI/Nuklear#gallery> |
| FLTK | Lightweight desktop utilities | <https://www.fltk.org/> | <https://www.fltk.org/shots.php> |
| libui-ng | Minimal native-widget C/C++ utilities | <https://github.com/libui-ng/libui-ng> | <https://github.com/libui-ng/libui-ng/tree/master/examples> |
| CEF | HTML/CSS/JS-heavy embedded browser UI | <https://chromiumembedded.github.io/cef/> | <https://chromiumembedded.github.io/cef/general_usage.html#sample-application> |

## Donor And Web Checks

- For broad project planning, start with `cpp-cuda-vulkan-studio/references/project-archetypes.md`.
- For domain routing, open `cpp-cuda-vulkan-studio/references/donor-library/README.md` and then
  `agent-lookup.md` or the relevant production overlay.
- For VFX wording, open `production/vfx-studio.md`.
- For game/tooling wording, open `production/games.md`.
- For native engineering infrastructure, open `production/native-engineering-infrastructure.md`.
- For GUI/HUD choices, open `native-gui-hud.md` and the `native-cpp-gui-hud` skill.
- For current best-choice or ceiling claims, run an extensive state-of-the-art web scan before
  ranking options. Use upstream repositories, official SDK docs, standards docs, recent papers,
  vendor samples, release notes, active engine/tool samples, and adoption/freshness signals.
- For authoring-model choices, include comparable current tools from the same user/workflow domain
  and record their common authoring practices before recommending a source of truth.
- Rank the best available current approach first. Separate it from legacy, simpler, teaching, or
  low-effort approaches; present those only as tradeoffs unless the user asks for a lighter route.

## Validation Choices

| Project Risk | First Validation Plan |
| --- | --- |
| Vulkan renderer/compute | shader compile, SPIR-V validation, Vulkan validation, offscreen render/compute smoke, screenshot or capture |
| CUDA kernels | CPU reference tests, CTest GPU label, Compute Sanitizer, Nsight Compute only after a hot path exists |
| GUI/tool shell | input focus, DPI/resize, screenshot or offscreen frame, UI smoke test, validation labels |
| Artist brush/stylus | input event trace, pressure curve test, stroke replay, undo/redo recording, latency/frame-time measure |
| Asset pipeline | tiny fixture import/export, metadata tests, material/texture fixtures, round-trip or validator report |
| Simulation | deterministic tiny case, conservation or bounds checks, visual frame artifact, per-pass timing |
| Node/stack/timeline authoring | serialization round-trip, invalid graph/stack/timeline diagnostics, undo/redo, create/connect/set/evaluate harness commands, visual or textual graph readback |
| Performance work | representative target table, baseline, profiling, hypothesis log, keep/revert attempts, final report |
