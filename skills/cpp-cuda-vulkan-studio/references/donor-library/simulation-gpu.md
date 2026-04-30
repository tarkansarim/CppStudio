# Advanced Simulation And GPU Simulation Donors

Use these donors for differentiable simulation, cloth, fluids, particles, deformables, soft bodies,
granular media, multiphysics, robotics simulation, and CUDA/GPU simulation kernels.

## GPU And Differentiable Simulation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [NVIDIA Warp](https://github.com/NVIDIA/warp) | dependency-candidate | Apache-2.0 | Python-authored CUDA simulation kernels, differentiable simulation, robotics, physics, spatial computing. |
| [Taichi](https://github.com/taichi-dev/taichi) | dependency-candidate | Apache-2.0 | Portable GPU/CPU simulation DSL, differentiable physical simulation, rapid solver prototyping. |
| [PositionBasedDynamics](https://github.com/InteractiveComputerGraphics/PositionBasedDynamics) | safe-donor | MIT | C++ position-based rigid/deformable/fluid constraints, cloth/soft-body simulation concepts. |

## Multiphysics And Large Simulation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Project Chrono](https://projectchrono.org/) | dependency-candidate | BSD-3-Clause | Multibody dynamics, vehicle/terrain, granular media, FEA, fluid-solid interaction, robotics simulation. |
| [SOFA](https://github.com/sofa-framework/sofa) | dependency-candidate | LGPL-2.1/GPL/plugin mix; inspect modules | Medical/robotics simulation, deformables, scene graph simulation architecture. |
| [NVIDIA PhysX](https://github.com/NVIDIA-Omniverse/PhysX) | dependency-candidate | BSD-3-Clause signals; inspect SDK notices | Realtime physics, collision, constraints, engine integration, GPU-capable physics concepts. |

## Selection Notes

- Use Warp or Taichi for GPU/differentiable simulation exploration when Python/JIT tooling is acceptable.
- Use PositionBasedDynamics for small reusable C++ constraint/cloth/soft-body patterns.
- Use Chrono when multiphysics fidelity matters and a heavier dependency is acceptable.
- Use PhysX when engine-grade realtime rigid-body/collision/constraint behavior is central.
- Use SOFA as architecture/reference material for medical or robotics simulation unless the project
  explicitly accepts its LGPL/GPL/plugin license shape.
- Keep generated simulation datasets, trained policies, and benchmark scenes separate from code licenses.

## Deep Profiles

- [NVIDIA Warp](profiles/warp.md): read before adopting Python-authored CUDA simulation kernels.
- [Taichi](profiles/taichi.md): read before adopting portable GPU/CPU simulation DSL workflows.
- [PositionBasedDynamics](profiles/positionbaseddynamics.md): read before adapting C++ PBD/XPBD constraints.
- [Project Chrono](profiles/project-chrono.md): read before adopting multiphysics or vehicle/terrain simulation.
- [SOFA](profiles/sofa.md): read before using medical/robotics multiphysics architecture references.
- [NVIDIA PhysX](profiles/physx.md): read before adopting realtime physics SDK architecture or dependencies.
