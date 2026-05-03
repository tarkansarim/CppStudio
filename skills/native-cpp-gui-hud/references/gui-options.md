# Native C++ GUI/HUD Options

Use this matrix when presenting options to a user. Always include the inspection links so the user can
judge the look and interaction style before approving a dependency.

| Option | Best Fit | Source Or Docs | Visual Inspection Link | Caveat |
| --- | --- | --- | --- | --- |
| Dear ImGui | Default debug HUD, internal editor panels, realtime tool controls, inspectors, quick artist tools. | <https://github.com/ocornut/imgui> | <https://github.com/ocornut/imgui#gallery> | Programmer/tooling UI first; not a polished end-user desktop framework by default. |
| ImGuizmo | 3D transform gizmos, view gizmos, simple sequencer/curve/editor widgets on top of Dear ImGui. | <https://github.com/CedricGuillemet/ImGuizmo> | <https://github.com/CedricGuillemet/ImGuizmo#guizmos> | Extension stack; inherits Dear ImGui integration and input constraints. |
| ImPlot | Realtime plots, profiler panels, telemetry, curves, heatmaps, debug graphs. | <https://github.com/epezent/implot> | <https://github.com/epezent/implot> | Pair with Dear ImGui; watch vertex/index limits for dense plots. |
| Qt | Full cross-platform desktop applications, complex widgets, menus, dockable tools, QML/front-end split, long-lived product UI. | <https://doc.qt.io/qt-6/> | <https://doc.qt.io/qt-6/examples-desktop.html> | Heavy dependency and license review required; check exact module licenses. |
| wxWidgets | Native-looking cross-platform desktop apps using platform widgets. | <https://wxwidgets.org/> | <https://wxwidgets.org/about/screenshots/> | Traditional desktop style; less common in custom Vulkan editor shells than ImGui/Qt. |
| RmlUi | Styled runtime/game HUDs, menus, overlays, and tool/editor interfaces with HTML/CSS-like authoring. | <https://github.com/mikke89/RmlUi> | <https://mikke89.github.io/RmlUiDoc/> | Bring your own renderer/input integration; validate Vulkan path and styling needs. |
| NoesisGUI | Commercial/pro runtime UI middleware for high-polish game/realtime UI, XAML workflows, VR/3D UI. | <https://www.noesisengine.com/noesisgui/> | <https://www.noesisengine.com/> | Commercial dependency; license, SDK, and build integration must be explicit. |
| Nuklear | Very small embeddable immediate-mode UI, C/C++ utility panels, low-dependency tools. | <https://github.com/Immediate-Mode-UI/Nuklear> | <https://github.com/Immediate-Mode-UI/Nuklear#gallery> | Minimal toolkit; you own rendering/backend polish and larger editor affordances. |
| FLTK | Lightweight desktop utilities and simple cross-platform C++ GUI apps. | <https://www.fltk.org/> | <https://www.fltk.org/shots.php> | Older/lightweight look; useful for utilities, not usually the default for GPU artist tools. |
| libui-ng | Small native-widget utilities from C/C++ with minimal surface area. | <https://github.com/libui-ng/libui-ng> | <https://github.com/libui-ng/libui-ng/tree/master/examples> | Mid-alpha signal; evaluate before relying on it for serious tools. |
| CEF | HTML/CSS/JS-heavy desktop UI, embedded browser panels, web-based inspectors, docs, stores, or complex web UI reuse. | <https://chromiumembedded.github.io/cef/> | <https://chromiumembedded.github.io/cef/general_usage.html#sample-application> | Heavy embedded Chromium runtime; security, packaging, process, and GPU-compositing cost. |

## Recommended Defaults

- **Vulkan/CUDA artist tool**: Dear ImGui, plus ImGuizmo for viewport manipulation and ImPlot for
  frame-time/profiler panels.
- **DCC-like standalone desktop product**: Qt first; wxWidgets if native widgets and lighter desktop
  framework tradeoffs fit better.
- **Shipped game/runtime HUD**: RmlUi for open-source styled UI; NoesisGUI for commercial XAML-style
  middleware.
- **Small utility**: FLTK, Nuklear, or libui-ng after checking the desired visual style.
- **Web UI reuse**: CEF only when HTML/CSS/JS is the product requirement, not as a default shortcut.
