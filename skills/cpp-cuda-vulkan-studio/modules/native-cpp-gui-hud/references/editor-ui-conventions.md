# Editor UI Conventions

Use this before product-shape UI work for artist tools, DCC-like applications, game tools, realtime
simulation editors, and viewport-heavy utilities.

## Surface Checks

| Surface | Common Convention | What To Verify |
| --- | --- | --- |
| Viewport | Large central 3D surface with camera controls, overlays, grid/gizmos, selection feedback. | Real dimensionality, camera interaction, overlays not hiding content, no diagnostic view presented as product viewport. |
| Timeline / Transport | Timeline strip near the bottom; transport controls live with frame/time context. | Play/pause/stop/step/loop placement, icon affordances, frame readout, enabled states. |
| Toolbar | Compact tools/actions, usually icons with tooltips. | Avoid crowded text buttons; destructive/structural commands may belong in menus/context actions instead. |
| Inspector / Properties | Right-side or docked selected-object/property editing. | Selection requirements, grouped parameters, disabled states, precision controls. |
| Scene / Layer Tree | Left-side or docked hierarchy/layer/object list. | Selection state, visibility/lock affordances, context actions. |
| Node Graph | Dedicated graph surface for procedural authoring. | Socket types, compatibility, snapping, pan/zoom, selected node inspector, graph-local commands. |
| Menus / Context | Discoverable actions, destructive commands, import/export, settings. | Action ids, shortcuts, enablement rules, selected-object target. |
| Status / Diagnostics | Thin status bar or collapsible diagnostics, not primary product surface. | Do not let debug text dominate the first impression of an artist tool. |

## Product-Fit Rules

- Match the user workflow first, toolkit convenience second.
- Name the domain donors or peer tools that ground the layout before implementing broad visible UI.
  A generic "standard editor" claim is not sufficient evidence.
- Put high-frequency spatial controls in the viewport, timeline controls with the timeline, and
  selected-object parameters in the inspector.
- Use icons for familiar universal commands when possible; keep full text in tooltips/menu labels.
- If a familiar transport, viewport, transform, visibility, save/load, undo/redo, add/remove, or
  destructive command is shown as a prominent text button, record the peer-tool precedent or product
  constraint that justifies it.
- Avoid top-heavy debug toolbars for artist-facing tools unless the user explicitly asks for a debug
  utility.
- For 3D tools, a 2D projection can be an implementation milestone but must be labeled as diagnostic
  if shown to the user.
- For node-based or procedural tools, decide the source of truth before building parameter panels.
  Panels should inspect/edit selected nodes when the node graph owns authoring state.

## Peer Evidence

Before implementing broad layout, name the peer tools or donors that informed the surface placement.
Examples of peer categories:

- DCC tools: modeling, animation, FX, lighting, and lookdev applications
- game editors: level, material, animation, VFX, and profiling tools
- realtime middleware samples: runtime UI/HUD samples, debug overlays, graph editors

Do not claim "standard editor layout" without naming the evidence used.

## Product-Fit Closeout

Before closing a visible UI slice, compare the fresh screenshot or captured frame against the donor
evidence and affected convention table. Reject the slice when controls look unorthodox for the target
domain, text crowds or clips, debug controls dominate the first impression, or familiar commands are
hidden behind surprising labels without a donor-backed reason.
