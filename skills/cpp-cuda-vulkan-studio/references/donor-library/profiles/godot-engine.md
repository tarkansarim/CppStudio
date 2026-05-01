# Godot Engine Donor Profile

Source: https://github.com/godotengine/godot  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: MIT for engine code; inspect `LICENSE.txt`, `COPYRIGHT.txt`, `thirdparty/`, modules,
export templates, demos, assets, platform code, and optional third-party notices at the exact revision used.

## Use First For

- Engine/editor architecture, scene trees, node/component ownership, resource import, rendering/physics
  integration, input, scripting, tools UX, and cross-platform packaging ideas.
- Studying how a large C++ engine organizes runtime/editor split, servers, modules, platforms, and tests.
- Reference workflows for game/editor tooling when a lightweight donor is insufficient.

## First Upstream Areas To Inspect

- `core/`, `scene/`, `servers/`, `modules/`, `editor/`, `drivers/`, `platform/`, `tests/`, and docs.
- Import pipeline, rendering server, physics server, node/resource model, and editor plugin systems.
- `thirdparty/`, export templates, demos, and platform-specific code before copying anything.

## Integration Notes

- Treat Godot as an engine architecture donor, not a dependency for ordinary C++ GPU tools.
- Borrow concepts such as scene/resource ownership, editor/runtime separation, and tool UX boundaries.
- Keep project-native renderer, build system, asset import, scripting, and editor decisions explicit.
- Use small focused donors first when the task does not need engine-scale architecture.

## Validation Ideas

- Convert engine concepts into tiny project-native fixtures: scene hierarchy, resource import, editor
  command, renderer handoff, or physics/debug-draw handoff.
- Test asset import and hot-reload behavior separately from runtime rendering.
- Verify that no GPL/plugin/asset assumptions leak into reusable outputs.
- Document which architecture concept was borrowed and whether code was copied.

## Caveats

- Godot is large and not a snippet library.
- Third-party code, export templates, demos, and assets are separate license surfaces.
- Engine architecture can be overkill for narrow renderer, CUDA, or Vulkan tooling tasks.
