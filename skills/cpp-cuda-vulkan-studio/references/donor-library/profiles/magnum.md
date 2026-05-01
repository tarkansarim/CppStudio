# Magnum Donor Profile

Source: https://github.com/mosra/magnum  
Tier: `safe-donor`  
Backend signal: mixed-backend
License signal: MIT/Expat for Magnum; inspect `COPYING`, plugin repositories, third-party component
notes, examples, and optional dependency licenses at the exact revision used.

## Use First For

- Lightweight C++ graphics middleware, modular math/asset/platform utilities, examples, and testable
  graphics helper patterns.
- CMake-friendly graphics application structure where a full engine is too heavy.
- Studying extension points for asset loading, texture compression, windowing, UI, and renderer-facing
  utility modules.

## First Upstream Areas To Inspect

- `src/` and `modules/` for core library boundaries.
- Documentation and examples for platform, GL/WebGL, asset, math, shader, and test utilities.
- Related plugin repositories before choosing loaders, texture codecs, UI, or integration modules.
- Single-header utilities only when the target repo wants a narrow vendored helper.

## Integration Notes

- Use Magnum as a compact middleware donor for app structure and utility boundaries.
- Keep optional plugins and integrations explicit; do not imply the base library covers every asset or
  renderer need.
- For Vulkan-specific work, use CppStudio Vulkan tooling and samples for lane policy, then Magnum only
  where its utilities fit the target project.
- Prefer narrow utility adoption over wholesale middleware use unless the project benefits from Magnum's
  ecosystem.

## Validation Ideas

- Build a minimal sample with the selected platform/windowing and graphics backend.
- Test asset/plugin discovery failures, missing optional dependencies, and headless/offscreen cases.
- Add small math, asset, and render smoke tests before larger viewer work.
- Keep plugin-dependent tests labelled separately from core C++ tests.

## Caveats

- Magnum has multiple companion repositories and plugins with their own dependency surfaces.
- Its main renderer-facing history is OpenGL/WebGL-heavy; Vulkan work still needs explicit Vulkan lane
  guidance.
- Do not use plugin convenience to blur target-project asset ownership and license tracking.
