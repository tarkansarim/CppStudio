# Realtime VFX, Particles, And GPU-Driven Effects Donors

Use these donors for realtime particle effects, GPU-driven draw/dispatch, indirect rendering,
particle sorting, effect authoring runtimes, and smoke/fire-adjacent visual effects.

## Effects Middleware And Engine References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Effekseer](https://github.com/effekseer/Effekseer) | dependency-candidate | MIT | Cross-platform particle/effect runtime, authoring concepts, renderer backends, effect asset pipeline. |
| [The Forge ParticleSystem](https://github.com/ConfettiFX/The-Forge) | dependency-candidate | Apache-2.0; inspect third-party folders | GPU particle sample architecture, renderer integration, cross-API particle patterns. |
| [Wicked Engine](https://github.com/turanszkij/WickedEngine) | dependency-candidate | MIT | Engine particle/effect paths, GPU-driven rendering, async compute, renderer integration concepts. |

## Vulkan And CUDA Particle Samples

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md) | safe-donor | Apache-2.0 | `compute_nbody`, multi-draw indirect, mesh shader culling, and portable Vulkan sample structure. |
| [SaschaWillems Vulkan Samples](https://github.com/SaschaWillems/Vulkan) | safe-donor | MIT | Compact Vulkan compute, particles, indirect draw, descriptor, and synchronization examples. |
| [NVIDIA CUDA Samples](https://github.com/NVIDIA/cuda-samples) | dependency-candidate | NVIDIA CUDA samples license; inspect exact files | CUDA particles, smoke particles, volume rendering/filtering, and CUDA/Vulkan interop samples. |

## Sorting And GPU Utility References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [AMD FidelityFX SDK](https://github.com/GPUOpen-LibrariesAndSDKs/FidelityFX-SDK) | dependency-candidate | MIT; inspect SDK component notices | Parallel sort, GPU particle utility patterns, shader-library organization, and integration caveats. |

## Deferred Or Study-Only

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [NVIDIA Blast](https://github.com/NVIDIAGameWorks/Blast) | study-only | NVIDIA/GameWorks license signal | Destruction/VFX concepts only unless target explicitly accepts the license path. |
| [NVIDIA FleX](https://github.com/NVIDIAGameWorks/FleX) | study-only | NVIDIA/GameWorks license signal | Legacy particle-based simulation/VFX concepts only. |
| [Unity Graphics / VFX Graph](https://github.com/Unity-Technologies/Graphics) | study-only | Unity package/license caveats | VFX Graph UX and behavior reference only; not native C++ donor code. |

## Selection Notes

- Use Effekseer for effect authoring/runtime questions; use Vulkan/CUDA samples for low-level dispatch,
  indirect rendering, and memory/synchronization patterns.
- Keep simulation solvers in [simulation-gpu.md](simulation-gpu.md); this file is for realtime visual
  effects and GPU-driven presentation.
- Use CUDA-heavy donors as algorithm and test references for Vulkan targets without adding CUDA
  runtime dependencies unless the user explicitly chooses interop.

## Deep Profiles

- [Realtime VFX, Particles, And GPU-Driven Effects](profiles/vfx-particles-gpu-driven.md): read before choosing effect runtimes, GPU particle samples, indirect rendering, particle sorting, or study-only VFX donors.
- [Fluids, Smoke, Fire, And Solver References](profiles/fluids-smoke-fire.md): read when particle/smoke/volume VFX overlaps CUDA fluid, smoke, or CUDA/Vulkan interop samples.
- [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md): read before adapting portable Vulkan particle, compute, or indirect-rendering examples.
- [Unity HDRP Hair Study-Only](profiles/unity-hdrp-hair-study-only.md): read only for VFX Graph or Unity package behavior references; do not copy into native C++ projects.
