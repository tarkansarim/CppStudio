# Planning Choice Matrix

Use this matrix to choose what the agent should inspect before implementation. Load only the rows
that match the project.

## Template And Archetype Choices

| Project Shape | Start With | Required Routing |
| --- | --- | --- |
| Vulkan renderer or compute app | CppStudio app+library scaffold, Vulkan-only `dev` lane | `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, project archetypes, Vulkan foundation donors |
| CUDA library or kernel package | Existing CMake/CUDA layout or CppStudio CUDA preset | `cpp-cuda-vulkan-studio`, `modern-cpp-cmake`, `cuda-kernel-authoring`, AI/runtime/kernel donors |
| CUDA plus Vulkan interop app | Explicit combined/interoperability plan | CppStudio interop archetype, CUDA donors, Vulkan donors, device identity and sync planning |
| Realtime artist tool | Vulkan-first app+library plus GUI/HUD skill | `native-cpp-gui-hud`, graphics/rendering donors, asset/input donors, validation screenshots |
| Game technical-art tool | Games production overlay plus native GUI/HUD | games overlay, native engineering infrastructure, rendering/assets/simulation donors |
| VFX/DCC pipeline tool | VFX production overlay plus DCC/asset categories | DCC, USD/Alembic/MaterialX/OpenVDB/assets donors |
| Simulation visualizer | Vulkan-first renderer plus simulation category | simulation-gpu, fluids/smoke/fire, geometry, volumes, rendering donors |
| AI runtime or neural 3D tool | AI runtime category plus graphics/runtime viewer categories | AI runtimes, neural 3D, CUDA or Vulkan lane depending on actual implementation |
| Existing project upgrade | Read repo map if present, then code-map readiness audit if requested | existing layout audit, dependency policy, validation gaps, staged backbone application |

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
| Performance work | representative target table, baseline, profiling, hypothesis log, keep/revert attempts, final report |
