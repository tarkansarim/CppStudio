# Realtime VFX, Particles, And GPU-Driven Effects Profile

Sources: https://github.com/effekseer/Effekseer https://github.com/ConfettiFX/The-Forge https://github.com/turanszkij/WickedEngine https://github.com/SaschaWillems/Vulkan https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK https://github.com/NVIDIAGameWorks/Blast https://github.com/NVIDIAGameWorks/FleX
Tier: `safe-donor`, `dependency-candidate`, `study-only`
Backend signal: native-vulkan, native-cuda, native-directx, native-opengl, mixed-backend
License signal: mixed MIT, Apache-2.0, NVIDIA/GameWorks, Unity, and sample-license signals; inspect
component directories and SDK notices before use.

## Use First For

- Particle/effect runtimes, authoring data, GPU-driven indirect drawing, particle sorting, smoke
  particle samples, and renderer integration patterns.
- Deciding whether a request needs a VFX runtime, a low-level GPU particle system, or a physics/simulation
  solver.

## Integration Notes

- Use Effekseer when authoring/runtime effect assets matter.
- Use Khronos/SaschaWillems samples for compact Vulkan particle, compute, and indirect rendering patterns.
- Use CUDA Samples only as CUDA kernel/interoperability references for CUDA or explicitly mixed lanes.
- Keep study-only GameWorks and Unity sources conceptual.

## Validation Ideas

- Test zero particles, emitter bursts, sort stability, indirect draw counts, GPU/CPU sync points, and
  deterministic seed behavior.
- Capture frame time and visible output for realtime VFX work.
