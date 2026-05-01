# Bullet Physics Donor Profile

Source: https://github.com/bulletphysics/bullet3  
Tier: `dependency-candidate`  
Backend signal: native-cpu, native-opencl
License signal: zlib for repository files with exceptions; inspect `LICENSE.txt`, `Extras/`,
`examples/ThirdPartyLibs`, demos, assets, and optional OpenCL/GPU components at the exact revision used.

## Use First For

- Broad physics/collision ecosystem references, robotics/ML simulation adjacency, soft-body/rigid-body
  examples, and legacy integration patterns.
- Comparing mature physics SDK behavior against Jolt, PhysX, PositionBasedDynamics, or custom solvers.
- Studying experimental OpenCL/GPGPU paths as backend-specific concepts, not as automatic target runtime
  choices.

## First Upstream Areas To Inspect

- `src/` for collision, dynamics, soft body, and solver APIs.
- `examples/`, `test/`, and command-line demos for fixture behavior and integration patterns.
- PyBullet and robotics examples only when the target project actually involves Python/robotics/ML.
- `Extras/`, `examples/ThirdPartyLibs`, assets, and OpenCL code before reuse.

## Integration Notes

- Use Bullet when ecosystem breadth or existing compatibility matters more than modern C++ minimalism.
- Keep optional OpenCL/GPU paths separate from CPU physics dependency decisions.
- Do not route ordinary Bullet-backed projects into CUDA or Vulkan unless the target explicitly owns
  those GPU lanes.
- Document accepted physics features, timestep policy, units, and collision filtering before integration.

## Validation Ideas

- Test rigid body, soft body if used, raycast, constraint, collision filter, and serialization fixtures.
- Compare deterministic behavior only within chosen timestep and solver settings.
- Label robotics/PyBullet, OpenCL, GUI/demo, and core C++ tests separately.
- Add regression fixtures for imported collision meshes and scale/unit conversions.

## Caveats

- Bullet is broad and older; project shape can sprawl if examples are copied uncritically.
- `Extras`, third-party demo libraries, and assets have separate license surfaces.
- Experimental OpenCL paths are not a reason to add OpenCL to a Vulkan or CUDA project by default.
