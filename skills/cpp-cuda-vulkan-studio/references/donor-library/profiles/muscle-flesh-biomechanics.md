# Muscle, Flesh, Soft-Tissue, And Biomechanics Profile

Sources: https://github.com/opensim-org/opensim-core https://github.com/simbody/simbody https://github.com/opensim-org/opensim-moco https://github.com/google-deepmind/mujoco https://github.com/febiosoftware/FEBio https://github.com/mfem/mfem https://github.com/artisynth/artisynth_core https://github.com/artisynth/artisynth_models https://github.com/facebookresearch/myosuite https://github.com/MichiganCOG/MuscleMimic
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic, native-cpu, mixed-backend
License signal: mixed Apache-2.0, BSD/MIT-style, LGPL/GPL/plugin, model-data, and Python-reference
signals; inspect code, model, mesh, motion, and dataset licenses separately.

## Use First For

- Musculoskeletal models, tendon/muscle paths, activation/control, continuum tissue, FEM, realtime flesh
  deformation, and anatomical/model validation references.

## Integration Notes

- Use OpenSim/Simbody for scientific muscle and motion questions.
- Use FEBio/MFEM/SOFA for continuum tissue and FEM-style soft bodies.
- Use PBD/XPBD for realtime visual deformation when biomechanical force validity is not required.
- Treat ArtiSynth, MyoSuite, and MuscleMimic as reference/model behavior unless their runtime/data
  surfaces are explicitly accepted.

## Validation Ideas

- Use tiny fixtures: one muscle actuator, one tendon path/wrap case, one tetrahedral block, one skin patch,
  and one activation/rest-length behavior check.
- Record whether the target is scientific biomechanics or visually plausible flesh before dependency choice.
