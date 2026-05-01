# Open 3D Engine Donor Profile

Source: https://github.com/o3de/o3de  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0/MIT plus additional root license files and third-party notices; inspect
`LICENSE*.TXT`, `Gems/`, `Code/`, Asset Processor, bundled SDKs, sample projects, LFS assets, and
component notices at the exact revision used.

## Use First For

- Large-scale engine architecture, Atom renderer integration, component/entity systems, asset processor,
  editor/runtime split, gems/modules, tooling, and AAA-scale build/asset workflows.
- Studying asset pipeline, component ownership, plugin/module boundaries, and simulation/visualization
  engine organization.
- Comparing engine-scale decisions against smaller renderer or middleware donors.

## First Upstream Areas To Inspect

- `Code/`, `Gems/`, `Templates/`, `AutomatedTesting/`, `cmake/`, `scripts/`, and Asset Processor paths.
- Atom renderer, asset pipeline, component/entity systems, editor tools, and sample projects matching the
  target concept.
- Git LFS assets, SDK dependencies, retired code notes, and license files before reuse.

## Integration Notes

- Treat O3DE as architecture/reference-scale unless the target intentionally adopts the engine.
- Keep engine/editor concepts separate from project-native CMake, renderer, asset import, and runtime
  module boundaries.
- Use O3DE for large-tooling patterns such as asset processors or component systems, not simple viewers.
- Document dependency and asset implications before recommending engine integration.

## Validation Ideas

- Translate concepts into tiny project-native tests: asset processor command, component lifecycle,
  resource cache, editor/runtime boundary, or renderer handoff.
- Keep engine-scale integration tests separate from reusable C++/Vulkan/CUDA unit tests.
- Verify LFS/sample assets and gem/component licenses before using fixtures.
- Check generated project/build artifacts are excluded from reusable templates.

## Caveats

- O3DE is very large and asset-heavy.
- License notices vary across components, gems, SDKs, and sample assets.
- It can impose engine architecture where a focused donor would be cleaner.
