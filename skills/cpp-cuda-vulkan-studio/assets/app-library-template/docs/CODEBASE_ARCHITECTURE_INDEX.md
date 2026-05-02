# {{PROJECT_NAME}} Codebase Architecture Index

Start here when context is cold or when choosing the right subsystem lane before editing code.

This map is intentionally thin. It routes agents into maintained subsystem docs and the
machine-readable manifest instead of forcing every session to load all implementation notes.

## State

- State marker: `.cppstudio/code-map-state.json`
- Machine manifest: [CODEBASE_SUBSYSTEM_MANIFEST.json](./CODEBASE_SUBSYSTEM_MANIFEST.json)

The map is actively maintained only when `.cppstudio/code-map-state.json` says `enabled`. If the
state is missing, CppStudio agents should ask once whether to enable the maintained code map. If the
state says `declined`, do not prompt again unless the user asks.

## Navigation Rule

When code-map state is `enabled`, use this index and the manifest as the first navigation step before
code changes. Pick the matching subsystem route, read that subsystem doc, then inspect the primary
paths named by the route.

## Subsystem Routes

- Build and presets: [SUBSYSTEMS/build-and-presets.md](./SUBSYSTEMS/build-and-presets.md)
- App core: [SUBSYSTEMS/app-core.md](./SUBSYSTEMS/app-core.md)
- Vulkan lane: [SUBSYSTEMS/vulkan-lane.md](./SUBSYSTEMS/vulkan-lane.md)
- CUDA lane: [SUBSYSTEMS/cuda-lane.md](./SUBSYSTEMS/cuda-lane.md)
- Validation and CI: [SUBSYSTEMS/validation-ci.md](./SUBSYSTEMS/validation-ci.md)

## Maintenance Rule

When code-map state is `enabled`, update this map in the same work stream as changes that affect
subsystem ownership, GPU backend boundaries, build/test lanes, data flow, validation, CI, or public
runtime behavior. If the map and code disagree, inspect the code and update the map.
