# Jolt Physics Donor Profile

Source: https://github.com/jrouwe/JoltPhysics  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: MIT; inspect `LICENSE`, `Assets/`, samples, TestFramework, optional bindings, and
platform-specific files at the exact revision used.

## Use First For

- Modern C++ rigid-body physics, collision detection, broadphase/narrowphase queries, constraints,
  characters, vehicles, and deterministic simulation architecture.
- Job/threaded physics integration and runtime/editor debug visualization patterns.
- Comparing compact C++ physics dependency shape against Bullet or heavier multiphysics SDKs.

## First Upstream Areas To Inspect

- `Jolt/` for core physics API and ownership boundaries.
- `HelloWorld/`, `Samples/`, and `UnitTests/` for minimal integration and behavior fixtures.
- `PerformanceTest/` for scaling and benchmark methodology.
- `Assets/`, `TestFramework/`, bindings, and platform-specific files before copying examples.

## Integration Notes

- Keep physics world ownership, timestep/substep policy, collision filtering, unit scale, and debug draw
  separate from renderer ownership.
- Prefer Jolt for modern native C++ rigid-body/collision work when the target accepts a physics SDK.
- Use simulation-gpu donors instead when the project owns cloth, fluid, differentiable, or custom GPU
  solver kernels.
- Treat optional features and bindings as separate dependency decisions.

## Validation Ideas

- Add tiny falling body, raycast, shape cast, trigger, collision filter, and fixed-timestep fixtures.
- Test determinism within documented limits before depending on replay/network behavior.
- Keep renderer/debug-draw tests separate from numeric physics tests.
- Run performance smoke tests only after correctness fixtures are stable.

## Caveats

- Assets and visual samples have their own license and dependency surfaces.
- CPU physics does not automatically answer GPU simulation or Vulkan synchronization questions.
- Platform-specific or console-related files can have extra availability constraints.
