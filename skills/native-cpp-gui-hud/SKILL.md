---
name: native-cpp-gui-hud
description: "Choose and integrate native C++ GUI, HUD, editor UI, viewport overlay, tool panel, docking, inspector, gizmo, plotting, telemetry, or runtime/game UI options for C++/Vulkan/CUDA/realtime applications. Use when comparing Dear ImGui, ImGuizmo, ImPlot, Qt, wxWidgets, RmlUi, NoesisGUI, Nuklear, FLTK, libui-ng, CEF, or similar native GUI stacks. When presenting options, include web links where the user can inspect how each GUI looks."
---

# Native C++ GUI And HUD

Use this skill when a native C++ project needs GUI/HUD/tool UI selection or integration. It is
especially relevant for Vulkan/CUDA/realtime artist tools, editor panels, debug overlays, performance
HUDs, gizmos, timeline controls, graph/plot panels, and runtime game UI.

## Core Rule

Hard rule: before touching GUI, HUD, editor, timeline, viewport, inspector, gizmo, or tool-surface
code, do not rely on training data or intuition as the source of truth. Open this skill, the
CppStudio donor category `cpp-cuda-vulkan-studio/references/donor-library/native-gui-hud.md`, and any
domain donor routes for the target tool first. State the donors or peer-tool references that ground
the layout before implementation.

When comparing GUI options for the user, always include links where they can inspect the visual style
or example output. Do not present a GUI choice as abstract library trivia; show what it looks like and
state what kind of app it fits.

If using interactive question UI such as `request_user_input`, do not ask the GUI/HUD choice question
until a visible link table has been shown in the conversation immediately before the question. Also
include compact source or visual URLs in the option descriptions when the question UI allows it. The
choice UI alone is not enough if it only shows short labels and prose.

For native GPU artist tools, DCC-style tools, game tools, simulation editors, and viewport-heavy
applications, product-surface conventions are not optional. Verify viewport dimensionality,
transport/timeline placement, editor shell layout, inspector location, graph/layer/scene-tree
expectations, and debug-vs-product UI boundaries against donors or peer tools before writing code.
Do not present a 2D diagnostic projection as the main viewport for a 3D tool unless the user
explicitly accepts it as a temporary diagnostic milestone.

For editor and DCC-style command surfaces, choose the interaction surface that matches the command's
domain. Destructive or structural graph/scene edits should be owned by editor actions, menus,
context/shortcut paths, or graph-local interaction patterns before adding extra toolbar buttons. If a
toolbar affordance is useful, it must not crowd labels, selection readouts, timeline controls, or
other primary authoring controls. Screenshot inspection must reject crowded, clipped, or debug-looking
controls even when functional tests pass.

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
2. Open the relevant GUI/HUD donor category and any domain donor categories before layout or
   dependency decisions. Training data is not enough for product-surface shape.
3. Keep renderer/simulation logic separate from UI logic. The UI layer may inspect and command the
   engine, but should not own GPU resource lifetime, simulation state, or asset truth.
4. For Vulkan targets, define the UI render pass or dynamic-rendering hook, descriptor lifetime, font
   atlas upload, input routing, DPI scaling, and swapchain resize behavior explicitly.
5. For CUDA targets, keep the GUI thread and CUDA work queue boundaries explicit; avoid hiding CUDA
   synchronization in widget callbacks.
6. For editor commands, map structural edits to action/menu/shortcut/context surfaces first, then
   decide whether a toolbar button is still necessary after checking the resulting screenshot.
7. Present a compact option table with:
   - recommended use
   - source/docs link
   - visual/gallery/examples link
   - license/dependency caveat
8. Only after that link table is visible, ask the user to choose among the researched options.
9. Before adding a dependency, check the target repo's package policy and exact upstream license.
10. If CppStudio is available, read its donor category first:
   `cpp-cuda-vulkan-studio/references/donor-library/native-gui-hud.md`.
11. For current best-choice or version-sensitive questions, web-check official project docs/repos before
   ranking options.

## Bundled Reference

Read [references/gui-options.md](references/gui-options.md) for the option matrix and inspection
links.
