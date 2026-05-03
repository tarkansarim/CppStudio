---
name: native-cpp-gui-hud
description: "Choose and integrate native C++ GUI, HUD, editor UI, viewport overlay, tool panel, docking, inspector, gizmo, plotting, telemetry, or runtime/game UI options for C++/Vulkan/CUDA/realtime applications. Use when comparing Dear ImGui, ImGuizmo, ImPlot, Qt, wxWidgets, RmlUi, NoesisGUI, Nuklear, FLTK, libui-ng, CEF, or similar native GUI stacks. When presenting options, include web links where the user can inspect how each GUI looks."
---

# Native C++ GUI And HUD

Use this skill when a native C++ project needs GUI/HUD/tool UI selection or integration. It is
especially relevant for Vulkan/CUDA/realtime artist tools, editor panels, debug overlays, performance
HUDs, gizmos, timeline controls, graph/plot panels, and runtime game UI.

## Core Rule

When comparing GUI options for the user, always include links where they can inspect the visual style
or example output. Do not present a GUI choice as abstract library trivia; show what it looks like and
state what kind of app it fits.

## Default Selection

- For Vulkan/CUDA/realtime tools, default to **Dear ImGui + ImGuizmo + ImPlot** unless the user wants
  a polished end-user desktop app or shipped game UI.
- For standalone desktop products with complex menus, docks, document workflows, settings, and native
  application behavior, compare **Qt** and **wxWidgets** before proposing an immediate-mode UI.
- For styled runtime/game HUDs and menus, compare **RmlUi** and **NoesisGUI** before using an internal
  debug UI stack as the shipped UI.
- For tiny utilities or very small embeddable tools, consider **Nuklear**, **FLTK**, or **libui-ng**.
- Use **CEF** only when the project explicitly benefits from HTML/CSS/JS UI or embedded browser
  content; record the runtime size, process, security, packaging, and GPU-compositing implications.

## Workflow

1. Identify the UI class: debug HUD, internal artist tool, editor shell, desktop product UI, runtime
   game UI, small utility, embedded web UI, or mixed.
2. Keep renderer/simulation logic separate from UI logic. The UI layer may inspect and command the
   engine, but should not own GPU resource lifetime, simulation state, or asset truth.
3. For Vulkan targets, define the UI render pass or dynamic-rendering hook, descriptor lifetime, font
   atlas upload, input routing, DPI scaling, and swapchain resize behavior explicitly.
4. For CUDA targets, keep the GUI thread and CUDA work queue boundaries explicit; avoid hiding CUDA
   synchronization in widget callbacks.
5. Present a compact option table with:
   - recommended use
   - source/docs link
   - visual/gallery/examples link
   - license/dependency caveat
6. Before adding a dependency, check the target repo's package policy and exact upstream license.
7. If CppStudio is available, read its donor category first:
   `cpp-cuda-vulkan-studio/references/donor-library/native-gui-hud.md`.
8. For current best-choice or version-sensitive questions, web-check official project docs/repos before
   ranking options.

## Bundled Reference

Read [references/gui-options.md](references/gui-options.md) for the option matrix and inspection
links.
