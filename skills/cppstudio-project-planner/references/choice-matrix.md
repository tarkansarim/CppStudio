# Planning Choice Matrix

Use this matrix to choose what the agent should inspect before implementation. Load only the rows
that match the project.

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

## Authoring Model Choices

For tools with user-authored state, research comparable current tools before choosing. This choice
often controls data ownership, serialization, undo/redo, validation, agentic controls, UI structure,
and whether docks/panels inspect a model or own the model.

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
