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
domain donor routes for the target tool first. Then run a compact before-implementation gate:
discover the actual toolkit APIs, action registries, menu/shortcut/context/timeline/viewport
surfaces, map constraints such as enabled states, selected object, snapping/clamping, coordinate
spaces, socket/type compatibility, focus/modal state, and validation affordances, and decide how the
change will be verified before wiring commands into production UI. State the donors or peer-tool
references that ground the layout before implementation.

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

For user-facing tool surfaces, build a compact UI convention table before changing layout or command
widgets. Cover the affected surfaces such as viewport, timeline, transport, toolbar, menu, context
menu, node graph, inspector, status bar, and overlay. For each surface, record the donor or peer-tool
evidence, expected control location, icon/text convention, tooltip/accessibility text, enabled or
disabled states, and the harness or screenshot proof that will verify it. Do not start from convenient
widgets and then judge after the fact; the convention table is the implementation constraint.

Use familiar icon affordances for universal tool commands when the chosen toolkit supports them:
play, pause, stop, step, loop, record, save, load, undo, redo, select, move, rotate, scale, pan, zoom,
lock, visibility, frame, pin, search, delete, add, and remove. Put the human-readable name in tooltip,
accessibility text, menu text, shortcut labels, or harness metadata. Text buttons are acceptable for
commands whose meaning is not represented by a common symbol, for confirmation dialogs, for primary
workflow actions where the peer tools use text, or when accessibility/localization constraints require
visible text. If a common transport or viewport command is implemented as a prominent text button,
state the donor evidence or constraint that justified it before claiming the UI is product-ready.

Before closeout, run a visual product-fit review against the convention table. The minimum review is a
fresh screenshot or captured frame plus a short scorecard for control placement, icon/text fit,
visual hierarchy, clipping/overlap, debug-vs-product feel, viewport/timeline/inspector conventions,
and whether the visible state would make sense to a target artist or tool user. A screenshot that is
nonblank is not enough evidence.

For editor and DCC-style command surfaces, choose the interaction surface that matches the command's
domain. Destructive or structural graph/scene edits should be owned by editor actions, menus,
context/shortcut paths, or graph-local interaction patterns before adding extra toolbar buttons. If a
toolbar affordance is useful, it must not crowd labels, selection readouts, timeline controls, or
other primary authoring controls. Screenshot inspection must judge the result against donor or
peer-tool product conventions and reject crowded, clipped, debug-looking, or convention-breaking
controls even when functional tests pass.

Critical state labels must be semantically clear in the visible UI text itself. Do not rely on a
tooltip, hidden readback, docs, or internal endpoint metadata as the only distinction between states
that affect user trust, such as preview versus baked output, local versus published state, destructive
versus non-destructive actions, approximate versus final results, or diagnostic versus product
surfaces. If the visible wording could mislead an artist or developer about what has actually
happened, change the visible label and update harness assertions to check that wording.

For GUI/editor action work, verification must prove the real command surface, not only an advertised
metadata string. Use verify-before-wiring for menus, shortcuts, context actions, timelines, and
viewports: discover or introspect the actual action/menu/shortcut/context objects, timeline or
viewport command APIs, enabled-state rules, attachment point, command target, selected-object
requirements, snapped or committed coordinates, and socket/type compatibility before connecting
production paths. Do not claim a menu, context action, shortcut, timeline, viewport, or toolbar path
was tested unless it was actually exercised or introspected; otherwise report it as screenshot-checked
or metadata-only evidence.

For user-facing interactive tools, verification must include real GUI interaction evidence for the
affected surface. Palette clicks, tool buttons, timeline controls, viewport strokes, picks, gizmo
drags, and graph-canvas edits need scenario coverage or equivalent toolkit-level probes that drive
the same event path as the user. Record event-to-state latency for click/selection changes, and
record widget geometry, device-pixel ratio, viewport-local/render-target coordinates, hit rays or
canvas transforms, committed hit/edit points, and fresh visual evidence for pointer-mapped edits.
Backend command success or a generic model revision is not enough when the user-visible question is
"did the click hit the right control or mesh point?"

For desktop GUI apps, verify the documented human launch command opens the actual app window before
claiming the app launches. The proof must identify the app window by class/process/title rather than
matching a terminal title, show that it is mapped, normal, focusable or deliberately raised/reused,
and visible on the user's desktop or intentionally moved there. Offscreen smoke and hidden window
objects do not prove the launch experience.

When the target app has or should have an agentic control harness, expose an action or affordance
inventory for UI-heavy slices when practical. A useful inventory includes action id, visible text,
icon presence/name, tooltip, shortcut, surface location, enabled state, command target, selected-object
requirement, and whether the action was exercised or only introspected. Use that inventory to catch
debug-looking or convention-breaking command placement, such as transport controls living in a top
debug toolbar when peer tools put them in the timeline strip.

When changing broad GUI interaction code such as mouse/keyboard event handlers, node graph widgets,
timeline widgets, viewport controls, docking shells, or command dispatch, add a source-structure
checkpoint before layering more behavior. Inspect the edited file for stale control-flow fragments,
duplicate helper functions, mismatched braces/namespaces, unreachable paths, and old interaction
branches that survived the rewrite. Build that checkpoint before updating docs, screenshots, or
additional harness routes.

When GUI work is delegated to a worker, subagent, reviewer, or background validation lane, monitor it
until it reports done, idle, or blocked. Do not give final status while delegated work is still
running; report the active worker state and remaining blocker instead.

When delegation is explicitly authorized and GUI behavior remains uncertain, use parallel lenses
before another broad patch. Assign separate hypotheses such as action routing, selection/constraint
state, timeline/viewport state, screenshot freshness, and peer-tool convention fit, then synthesize
the evidence before wiring or closing.

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
6. Before layout or command-widget edits, write the UI convention table for the affected surfaces and
   lock down which controls should be icons, text, menus, context actions, timeline controls, or
   viewport overlays.
7. For editor commands, map structural edits to action/menu/shortcut/context surfaces first, verify
   those surfaces before production wiring, then decide whether a toolbar button is still necessary
   after checking the resulting screenshot against peer-tool/product conventions.
8. For implemented GUI commands, add harness readback or scenario coverage that proves the real UI
   actions, enabled states, selected-object requirements, attachment points, timeline/viewport
   command state, and socket/type compatibility when practical. Keep advertised capability metadata
   separate from proof.
9. For drag/move/resize/graph-coordinate interactions, verify the committed UI/model state after any
   snapping, clamping, or validation and make the screenshot match that committed state.
10. For click, palette, viewport, brush/stylus, and canvas interactions, add or run a GUI scenario
   that proves the real event path, event-to-committed-state latency, pointer coordinate mapping,
   and fresh visual/result state. Explicitly check device-pixel ratio and widget/viewport offsets
   before accepting a pointer-hit fix.
11. Present a compact option table with:
   - recommended use
   - source/docs link
   - visual/gallery/examples link
   - license/dependency caveat
12. Only after that link table is visible, ask the user to choose among the researched options.
13. Before adding a dependency, check the target repo's package policy and exact upstream license.
14. If CppStudio is available, read its donor category first:
   `cpp-cuda-vulkan-studio/references/donor-library/native-gui-hud.md`.
15. For current best-choice or version-sensitive questions, web-check official project docs/repos before
   ranking options.

## Bundled Reference

Read [references/gui-options.md](references/gui-options.md) for the option matrix and inspection
links.
