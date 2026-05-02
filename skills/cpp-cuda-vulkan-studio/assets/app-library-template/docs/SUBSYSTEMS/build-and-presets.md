# Build And Presets

CMake targets, presets, compiler options, warning policy, sanitizer wiring, and dependency switches.

## Canonical Docs

- `docs/DEVELOPMENT_ENVIRONMENT.md`
- `docs/VALIDATION_PIPELINE.md`

## Primary Paths

- `CMakeLists.txt`
- `CMakePresets.json`
- `cmake/`

## Update When

- target ownership, preset names, feature options, warning policy, sanitizer behavior, or dependency
  wiring changes
- Vulkan/CUDA enablement moves between presets or cache options
- a validation lane starts depending on a new build artifact
