# Dependency Management Donor Profile

Sources: https://github.com/microsoft/vcpkg https://github.com/conan-io/conan https://github.com/cpm-cmake/CPM.cmake https://cmake.org/cmake/help/latest/module/FetchContent.html
Tier: `dependency-candidate`
Backend signal: api-agnostic
License signal: Tool, registry, recipe, package, and generated-lockfile terms vary; inspect the exact
package manager, manifests, ports/recipes, third-party notices, and generated artifacts.

## Use First For

- Choosing vcpkg, Conan, CPM.cmake, FetchContent, vendoring, or submodules for native dependencies.
- Defining lockfile, registry, cache, and offline/reproducibility policy.
- Keeping third-party notices, optional SDKs, and dependency-scale donors explicit.

## First Upstream Areas To Inspect

- vcpkg manifest mode, registries, overlays, triplets, and binary cache behavior.
- Conan profiles, lockfiles, generators, and package ID model.
- CPM.cmake single-file behavior and version pinning.
- CMake FetchContent population timing, source override behavior, and dependency provider hooks.

## Integration Notes

- Preserve existing target-project dependency policy unless there is a concrete reason to change it.
- Prefer package-manager integration over copying large donor source trees.
- Keep binary SDKs, sample assets, model weights, generated engines, and third-party notices outside
  reusable templates unless the project explicitly accepts them.

## Validation Ideas

- Configure a temp project twice and confirm dependency resolution is repeatable.
- Verify optional dependencies can be disabled from presets.
- Check that dependency caches and downloaded sources are not committed accidentally.

## Caveats

- Package-manager choice affects every future contributor and CI lane.
- FetchContent can look simple but still downloads and builds third-party source during configure or
  build; keep that behavior visible.
