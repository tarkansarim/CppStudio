# Advanced Simulation And GPU Simulation Donors

Use these donors for differentiable simulation, cloth, fluids, particles, deformables, soft bodies,
granular media, multiphysics, robotics simulation, and CUDA/GPU simulation kernels.

## GPU And Differentiable Simulation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [NVIDIA Warp](https://github.com/NVIDIA/warp) | dependency-candidate | Apache-2.0 | Python-authored CUDA simulation kernels, differentiable simulation, robotics, physics, spatial computing. Prototype/reference-only for native C++ unless Python/JIT is explicit. |
| [Taichi](https://github.com/taichi-dev/taichi) | dependency-candidate | Apache-2.0 | Portable Python DSL for GPU/CPU simulation, differentiable physical simulation, and rapid solver prototyping. Reference-only for native C++. |
| [PositionBasedDynamics](https://github.com/InteractiveComputerGraphics/PositionBasedDynamics) | safe-donor | MIT | C++ position-based rigid/deformable/fluid constraints, cloth/soft-body simulation concepts. |

## Multiphysics And Large Simulation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Project Chrono](https://projectchrono.org/) | dependency-candidate | BSD-3-Clause | Multibody dynamics, vehicle/terrain, granular media, FEA, fluid-solid interaction, robotics simulation. |
| [SOFA](https://github.com/sofa-framework/sofa) | dependency-candidate | LGPL-2.1/GPL/plugin mix; inspect modules | Medical/robotics simulation, deformables, scene graph simulation architecture. |
| [NVIDIA PhysX](https://github.com/NVIDIA-Omniverse/PhysX) | dependency-candidate | BSD-3-Clause signals; inspect SDK notices | Realtime physics, collision, constraints, engine integration, GPU-capable physics concepts. |

## Fluids, Smoke, Fire, And Solver References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [SPlisHSPlasH](https://github.com/InteractiveComputerGraphics/SPlisHSPlasH) | safe-donor | MIT | Native C++ SPH fluids, boundary handling, neighborhood search, interactive fluid simulation. |
| [fluid-engine-dev](https://github.com/doyubkim/fluid-engine-dev) | safe-donor | MIT | Educational C++ grid/particle fluid solvers, CPU references, FLIP/PIC-style fixtures. |
| [SPHinXsys](https://github.com/Xiangyu-Hu/SPHinXsys) | dependency-candidate | Apache-2.0 | SPH multiphysics, fluid-structure interaction, engineering simulation, optimization. |
| [DualSPHysics](https://github.com/DualSPHysics/DualSPHysics) | dependency-candidate | LGPL-2.1 signal | C++/CUDA/OpenMP SPH architecture and engineering wave/free-surface examples. |
| [NVIDIA CUDA Samples](https://github.com/NVIDIA/cuda-samples) | dependency-candidate | NVIDIA CUDA samples license; inspect exact files | CUDA fluids, particles/smoke, volume rendering/filtering, and CUDA/Vulkan interop samples. |
| [Vortex2D](https://github.com/mmaldacker/Vortex2D) | safe-donor | MIT | Vulkan compute 2D realtime fluid simulation and simulation-step descriptor/command layout. |
| [MantaFlow](https://github.com/thunil/mantaflow) | dependency-candidate | Apache-2.0 | Smoke/fire/liquid solver concepts, grid solvers, FLIP/liquids, simulation scene scripting. |
| [NVIDIA Flow](https://github.com/NVIDIAGameWorks/Flow) | study-only | NVIDIA Source Code License signal | Sparse-grid realtime smoke/fire concepts, emitter/combustion design, renderer handoff. |

## Engineering CFD And LBM Study Routes

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [GPUSPH](https://github.com/GPUSPH/gpusph) | study-only | GPLv3 signal | CUDA weakly-compressible SPH concepts only. |
| [FluidX3D](https://github.com/ProjectPhysX/FluidX3D) | study-only | Non-commercial restriction signal | OpenCL LBM CFD concepts and performance structure only. |
| [OpenFOAM](https://github.com/OpenFOAM/OpenFOAM-dev) | study-only | GPL-family signal | Engineering CFD architecture and solver concepts only. |
| [SU2](https://github.com/su2code/SU2) | dependency-candidate | LGPL-2.1 signal | Engineering CFD/optimization route when realtime graphics is not the primary target. |

## Selection Notes

- Use Warp or Taichi for GPU/differentiable simulation exploration when Python/JIT tooling is acceptable.
  For native C++/CUDA/Vulkan deliverables, port the learned solver behavior independently and keep these
  donors out of the direct code path.
- Use PositionBasedDynamics for small reusable C++ constraint/cloth/soft-body patterns.
- Use SPlisHSPlasH or fluid-engine-dev for native C++ fluid solver structure; use Vortex2D when the
  target is specifically Vulkan compute fluids.
- Use CUDA sample donors as narrow examples and tests, not as a reason to switch a Vulkan target to
  CUDA unless interop or CUDA kernels are explicitly required.
- Use MantaFlow and NVIDIA Flow for smoke/fire/pyro design; keep VDB cache/rendering choices in
  [volumes-voxels.md](volumes-voxels.md).
- Use CUDA, Vulkan, CPU, or DSL simulation donors as solver and validation references across lanes. Keep
  the target lane fixed and translate execution, memory, and synchronization details through the active
  CUDA or Vulkan skill.
- Use Chrono when multiphysics fidelity matters and a heavier dependency is acceptable.
- Use PhysX when engine-grade realtime rigid-body/collision/constraint behavior is central.
- Use SOFA as architecture/reference material for medical or robotics simulation unless the project
  explicitly accepts its LGPL/GPL/plugin license shape.
- Keep generated simulation datasets, trained policies, and benchmark scenes separate from code licenses.

## Deep Profiles

- [Fluids, Smoke, Fire, And Solver References](profiles/fluids-smoke-fire.md): read before selecting C++/CUDA/Vulkan/OpenCL fluid, smoke, fire, pyro, or CFD/LBM donors.
- [NVIDIA Warp](profiles/warp.md): read before using Python-authored CUDA simulation kernels as prototype/reference material.
- [Taichi](profiles/taichi.md): read before using portable Python DSL simulation workflows as prototype/reference material.
- [PositionBasedDynamics](profiles/positionbaseddynamics.md): read before adapting C++ PBD/XPBD constraints.
- [Project Chrono](profiles/project-chrono.md): read before adopting multiphysics or vehicle/terrain simulation.
- [SOFA](profiles/sofa.md): read before using medical/robotics multiphysics architecture references.
- [NVIDIA PhysX](profiles/physx.md): read before adopting realtime physics SDK architecture or dependencies.
