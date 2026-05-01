# Fluids, Smoke, Fire, And Solver Donor Profile

Sources: https://github.com/InteractiveComputerGraphics/SPlisHSPlasH https://github.com/doyubkim/fluid-engine-dev https://github.com/Xiangyu-Hu/SPHinXsys https://github.com/DualSPHysics/DualSPHysics https://github.com/NVIDIA/cuda-samples https://github.com/mmaldacker/Vortex2D https://github.com/thunil/mantaflow https://github.com/NVIDIAGameWorks/Flow https://github.com/GPUSPH/gpusph https://github.com/ProjectPhysX/FluidX3D https://github.com/OpenFOAM/OpenFOAM-dev https://github.com/su2code/SU2
Tier: `safe-donor`, `dependency-candidate`, `study-only`
Backend signal: native-cpu, native-cuda, native-vulkan, native-opencl, mixed-backend
License signal: mixed MIT, Apache-2.0, LGPL/GPL, NVIDIA source-license, and non-commercial signals;
inspect exact solver/sample files before copying anything.

## Use First For

- Native C++ SPH/grid/fluid solver structure, CUDA SPH or particle kernels, Vulkan compute fluid steps,
  smoke/fire/pyro concepts, and engineering CFD/LBM references.
- Translating solver behavior across Vulkan, CUDA, CPU, OpenCL, and DSL donors while keeping the target
  implementation lane fixed.

## Integration Notes

- Use SPlisHSPlasH and fluid-engine-dev for compact C++ solver structure and deterministic CPU fixtures.
- Use Vortex2D when the target is explicitly Vulkan compute fluids.
- Use CUDA Samples as narrow kernel/interoperability examples, not as a default CUDA dependency.
- Treat NVIDIA Flow, GPUSPH, FluidX3D, and OpenFOAM as concept/study routes unless the target project
  explicitly accepts their license shape.
- Keep simulation state, cache formats, VDB volume rendering, particles, and renderer upload separate.

## Validation Ideas

- Start with tiny deterministic scenes: one particle splash, one grid advection step, one emitter, one
  boundary collision, and one empty-domain case.
- Compare mass/volume conservation, boundary behavior, stability, and visual output separately.
