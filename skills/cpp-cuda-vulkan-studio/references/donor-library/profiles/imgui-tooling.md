# Dear ImGui Tooling Stack Donor Profile

Sources: https://github.com/ocornut/imgui https://github.com/ocornut/imgui/wiki/Getting-Started https://github.com/CedricGuillemet/ImGuizmo https://github.com/epezent/implot
Tier: `safe-donor`
Backend signal: mixed-backend
License signal: MIT for Dear ImGui, ImGuizmo, and ImPlot; inspect exact upstream license files and
third-party/example assets at the revision used.

## Use First For

- Internal realtime tool UI, debug HUDs, property inspectors, render/simulation controls, profiler
  panels, developer overlays, and short-iteration artist tools.
- Vulkan/CUDA applications that already own a render loop and need UI rendered inside the frame.
- Transform gizmos with ImGuizmo and telemetry/plotting with ImPlot.

## First Upstream Areas To Inspect

- Dear ImGui `backends/` and `examples/` for platform plus renderer integration, especially Vulkan.
- Dear ImGui docking branch/docs when the user wants dockable tool panels or multi-viewports.
- `imgui_demo.cpp` for widget behavior and testable UI examples.
- ImGuizmo README/images for transform/view gizmo behavior.
- ImPlot README/demo for plot types, realtime data, and dense widget caveats.

## Integration Notes

- Keep the UI integration module thin: input capture, frame begin/end, font atlas upload, descriptor
  ownership, and draw submission.
- Do not let widgets own renderer resources or simulation state directly; route changes through
  command/state interfaces.
- For Vulkan, define descriptor pools, image/font lifetime, dynamic rendering or render-pass hook,
  frames-in-flight ownership, swapchain resize, and DPI scaling explicitly.
- For tools, standardize debug panels: performance, validation/errors, resource browser, scene/entity
  inspector, material/brush controls, capture/reporting, and feature toggles.
- For public-facing UI, verify the user accepts the Dear ImGui visual style before treating it as
  product UI.

## Validation Ideas

- Launch a tiny window with one dockable panel, a property inspector, and a render-target overlay.
- Resize the swapchain, change DPI scale, and verify the font atlas/descriptors remain valid.
- Run Vulkan validation with UI enabled and disabled.
- Add an interaction smoke test for gizmo manipulation and plot panel updates when those extensions are
  selected.

## Caveats

- Dear ImGui is optimized for tools, debug UI, and fast iteration; it is not a full native desktop app
  framework.
- Docking and multi-viewport behavior need deliberate branch/version and platform backend decisions.
- Dense ImPlot widgets can stress index/vertex limits; test worst-case telemetry panels.
