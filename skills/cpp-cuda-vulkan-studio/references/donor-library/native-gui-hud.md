# Native GUI, HUD, And Editor UI Donors

Use these donors when a native C++/Vulkan/CUDA/realtime project needs a GUI toolkit, debug HUD,
viewport overlay, editor panel, docking shell, transform gizmo, inspector, timeline, telemetry plot,
or runtime/game UI. When presenting options to the user, include the visual inspection links so they
can judge the look and interaction style before choosing.

## Immediate-Mode Tooling Defaults

| Donor | Tier | License Signal | Best Use | Inspect How It Looks |
| --- | --- | --- | --- | --- |
| [Dear ImGui](profiles/imgui-tooling.md) | safe-donor | MIT | Default internal C++ debug HUDs, editor panels, realtime tool controls, Vulkan/CUDA overlays, and fast artist-tool iteration. | [Gallery](https://github.com/ocornut/imgui#gallery) |
| [ImGuizmo](profiles/imgui-tooling.md) | safe-donor | MIT | 3D transform/view gizmos, simple sequencer, curve, graph, and viewport manipulation widgets on top of Dear ImGui. | [Guizmos](https://github.com/CedricGuillemet/ImGuizmo#guizmos) |
| [ImPlot](profiles/imgui-tooling.md) | safe-donor | MIT | Frame-time graphs, profiler panels, telemetry plots, curves, histograms, and dense debug visualizations. | [Screenshots/examples](https://github.com/epezent/implot) |

## Desktop Application Toolkits

| Donor | Tier | License Signal | Best Use | Inspect How It Looks |
| --- | --- | --- | --- | --- |
| [Qt](profiles/desktop-gui-toolkits.md) | dependency-candidate | Commercial/GPL/LGPL module mix; inspect exact Qt modules | Full desktop products, dockable tools, menus, native app services, model/view widgets, QML/C++ UI split, and complex document-style tooling. | [Desktop examples](https://doc.qt.io/qt-6/examples-desktop.html) |
| [wxWidgets](profiles/desktop-gui-toolkits.md) | dependency-candidate | wxWindows Library License with exception | Native-looking cross-platform desktop apps using platform widgets. | [Screenshots](https://wxwidgets.org/about/screenshots/) |

## Runtime And Game UI

| Donor | Tier | License Signal | Best Use | Inspect How It Looks |
| --- | --- | --- | --- | --- |
| [RmlUi](profiles/runtime-ui-middleware.md) | safe-donor | MIT | HTML/CSS-like styled UI for game HUDs, menus, overlays, and tool/editor interfaces. | [Docs/gallery entry](https://mikke89.github.io/RmlUiDoc/) |
| [NoesisGUI](profiles/runtime-ui-middleware.md) | dependency-candidate | Commercial SDK; inspect license terms | High-polish commercial runtime UI, XAML workflows, game HUDs, menus, VR/3D UI, and engine integrations. | [Portfolio/features](https://www.noesisengine.com/) |

## Lightweight And Embedded-Web Options

| Donor | Tier | License Signal | Best Use | Inspect How It Looks |
| --- | --- | --- | --- | --- |
| [Nuklear](profiles/lightweight-embedded-gui.md) | safe-donor | MIT or public domain | Very small C/C++ embeddable immediate-mode utility UIs with minimal dependencies. | [Gallery](https://github.com/Immediate-Mode-UI/Nuklear#gallery) |
| [FLTK](profiles/lightweight-embedded-gui.md) | dependency-candidate | LGPL with static-linking exception | Lightweight cross-platform C++ desktop utilities and simple tool windows. | [Screenshots](https://www.fltk.org/shots.php) |
| [libui-ng](profiles/lightweight-embedded-gui.md) | dependency-candidate | MIT | Small native-widget utilities from C/C++; evaluate maturity before serious tools. | [Examples](https://github.com/libui-ng/libui-ng/tree/master/examples) |
| [Chromium Embedded Framework](profiles/lightweight-embedded-gui.md) | dependency-candidate | BSD-style CEF plus Chromium dependency notices | HTML/CSS/JS-heavy native apps, embedded browser panes, web inspectors, docs, stores, or web UI reuse. | [CEF sample app docs](https://chromiumembedded.github.io/cef/general_usage.html#sample-application) |

## Selection Notes

- For Vulkan/CUDA realtime artist tools, choose Dear ImGui first, then add ImGuizmo and ImPlot only
  when transform controls or plotting are actually needed.
- For a polished standalone desktop product, compare Qt and wxWidgets before defaulting to an
  immediate-mode debug UI.
- For shipped game/runtime UI, compare RmlUi and NoesisGUI; do not ship a debug HUD as product UI
  unless the user explicitly wants that style.
- Keep UI, renderer, simulation, and asset truth separated. UI code should command or inspect engine
  state through narrow interfaces.
- For Vulkan UI integration, make font atlas upload, descriptor lifetime, render pass/dynamic
  rendering hooks, swapchain resize, input routing, DPI scaling, and multi-viewport/docking behavior
  explicit.
- For CUDA tools, do not hide CUDA synchronization in widget callbacks. Route long GPU work through
  explicit command queues, jobs, or frame tasks.
- CEF is powerful but heavy. Choose it for web UI reuse or embedded browser content, not because a
  native UI decision was avoided.

## Deep Profiles

- [Dear ImGui Tooling Stack](profiles/imgui-tooling.md): read before choosing Dear ImGui, ImGuizmo,
  ImPlot, docking, viewport overlays, or immediate-mode editor panels.
- [Desktop GUI Toolkits](profiles/desktop-gui-toolkits.md): read before choosing Qt or wxWidgets for
  desktop-product UI.
- [Runtime UI Middleware](profiles/runtime-ui-middleware.md): read before choosing RmlUi or NoesisGUI
  for game/runtime HUDs, menus, or styled retained UI.
- [Lightweight And Embedded-Web GUI](profiles/lightweight-embedded-gui.md): read before choosing
  Nuklear, FLTK, libui-ng, or CEF.
