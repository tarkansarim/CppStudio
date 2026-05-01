# Muscle, Flesh, Soft-Tissue, And Biomechanics Donors

Use these donors for musculoskeletal models, muscle activation, tendon/path wrapping, continuum soft
tissue, biomechanical solvers, flesh deformation, and realtime visual deformation references.

## Biomechanical Muscles And Multibody Dynamics

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenSim Core](https://github.com/opensim-org/opensim-core) | dependency-candidate | Apache-2.0; inspect bundled dependencies/model licenses | Musculoskeletal models, muscles/tendons, joint constraints, motion analysis, biomechanical validation. |
| [Simbody](https://github.com/simbody/simbody) | dependency-candidate | Apache-2.0 | Multibody dynamics, constraints, contacts, and OpenSim solver foundation. |
| [OpenSim Moco](https://github.com/opensim-org/opensim-moco) | dependency-candidate | Apache-2.0; moved into OpenSim core | Optimal control and muscle-driven motion formulation references. |
| [MuJoCo](https://github.com/google-deepmind/mujoco) | dependency-candidate | Apache-2.0 | Actuation, tendon paths, contacts, control/RL fixtures, and realtime-ish simulation references. |

## Soft Tissue, FEM, And Continuum Solvers

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [FEBio](https://github.com/febiosoftware/FEBio) | dependency-candidate | MIT-style signal; inspect exact license and modules | Biomechanics FEM, soft tissue constitutive models, muscles, contact, and validation benchmarks. |
| [SOFA](profiles/sofa.md) | dependency-candidate | LGPL-2.1/GPL/plugin mix; inspect modules | Medical/robotics deformables, scene graph simulation architecture, haptics/robotics references. |
| [MFEM](https://github.com/mfem/mfem) | dependency-candidate | BSD-3-Clause | Finite element methods, high-order FEM, GPU/HPC-capable discretization references. |

## Realtime Flesh And Reference-Only Models

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [PositionBasedDynamics](profiles/positionbaseddynamics.md) | safe-donor | MIT | Realtime PBD/XPBD constraints for visually plausible soft bodies and skin/flesh approximations. |
| [Project Chrono](profiles/project-chrono.md) | dependency-candidate | BSD-3-Clause | Multiphysics, FEA, vehicle/terrain, and coupled simulation references. |
| [ArtiSynth Core](https://github.com/artisynth/artisynth_core) | dependency-candidate | BSD-style core plus third-party caveats | Muscle/soft-tissue architecture and model behavior; Java/reference-only for native C++. |
| [ArtiSynth Models](https://github.com/artisynth/artisynth_models) | dependency-candidate | Dataset/model-specific caveats | Anatomical modeling fixtures and examples; model data requires separate review. |
| [MyoSuite](https://github.com/facebookresearch/myosuite) | dependency-candidate | Apache-2.0 signal | Muscle-control tasks and environments; Python/reference-only for native C++. |
| [MuscleMimic](https://github.com/MichiganCOG/MuscleMimic) | dependency-candidate | Verify exact license before use | Learned muscle-control behavior; Python/reference-only for native C++. |

## Selection Notes

- Use OpenSim/Simbody for biomechanically meaningful muscles and validation.
- Use FEBio/MFEM/SOFA for continuum soft tissue and FEM-style flesh.
- Use PBD/XPBD when the goal is realtime visual plausibility, not scientific muscle force validity.
- Keep anatomical model data, motion capture, trained policies, meshes, and medical datasets separate
  from code licensing.
- Ask the target requirements to distinguish scientific biomechanics from renderer-facing flesh
  deformation before selecting dependencies.

## Deep Profiles

- [Muscle, Flesh, Soft-Tissue, And Biomechanics](profiles/muscle-flesh-biomechanics.md): read before selecting OpenSim, FEBio, SOFA, MuJoCo, ArtiSynth, MyoSuite, or realtime flesh-deformation donors.
- [SOFA](profiles/sofa.md): read before using medical/robotics multiphysics architecture references.
- [PositionBasedDynamics](profiles/positionbaseddynamics.md): read before adapting C++ PBD/XPBD constraints.
- [Project Chrono](profiles/project-chrono.md): read before adopting multiphysics or vehicle/terrain simulation.
