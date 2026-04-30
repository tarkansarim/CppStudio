# NVIDIA PhysX Donor Profile

Source: https://github.com/NVIDIA-Omniverse/PhysX  
Tier: `dependency-candidate`  
License signal: BSD-3-Clause signals for the repository, with subfolder license files and Omniverse,
Blast, Flow, Python, and USD-related components to inspect at the exact revision used.

## Use First For

- Realtime rigid-body physics, collision, constraints, joints, character/engine integration, and scene
  query architecture.
- Engine-grade physics SDK boundaries and C API/Python/USD interop examples.
- Destruction/fracture and fluid/fire concepts through adjacent Blast and Flow SDK lanes when explicitly
  in scope.
- Comparing physics SDK integration patterns against smaller native donors such as Jolt or Bullet.

## First Upstream Areas To Inspect

- `physx/` for the core PhysX SDK.
- `ovphysx/` when USD physics simulation or DLPack/Python tensor interop matters.
- `blast/` and `flow/` only for destruction/fracture or fluid/fire-specific work.
- Root and subfolder license files before adopting any component.
- Samples/docs for scene setup, collision filtering, constraints, and stepping policy.

## Integration Notes

- Treat PhysX as an SDK dependency. Do not copy large SDK internals into target repos.
- Keep physics scene ownership, collision filtering, unit scale, timestep/substep policy, and renderer
  handoff explicit.
- Decide whether USD physics or Omniverse components are in scope before pulling adjacent directories into
  the dependency surface.
- Use small fixtures before enabling broad engine integration.

## Validation Ideas

- Simulate a falling rigid body, a joint constraint, and a simple collision scene with expected bounds.
- Test fixed timestep, substep, and contact-filter behavior explicitly.
- Add integration tests for renderer/debug draw handoff only after numeric physics fixtures pass.
- Verify component licenses separately for PhysX, ovphysx, Blast, and Flow.

## Caveats

- Repository subdirectories have different roles and may have separate licenses/notices.
- SDK-style integration can impose allocator, threading, data ownership, and binary distribution
  constraints.
- Vendor extension paths can reduce portability; document them when required.
