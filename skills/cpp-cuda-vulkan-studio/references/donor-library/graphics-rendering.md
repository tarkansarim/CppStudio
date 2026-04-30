# Graphics And Rendering Donors

Use these donors for Vulkan, renderer architecture, WebGPU/WebGL, PBR, frame/debug tooling, and
ray/path tracing work.

## Primary Safe Donors

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Khronos Vulkan-Samples](https://github.com/KhronosGroup/Vulkan-Samples) | safe-donor | Apache-2.0 | Vulkan API samples, performance samples, validation-friendly examples, dynamic rendering, timeline semaphores, headless/offscreen patterns. |
| [NVIDIA vk_mini_samples](https://github.com/nvpro-samples/vk_mini_samples) | safe-donor | Apache-2.0 | Modern Vulkan samples for ray tracing, mesh/task shaders, descriptor heap, shader printf, crash/debug tooling, compute examples. |
| [Google Filament](https://github.com/google/filament) | dependency-candidate | Apache-2.0 | PBR renderer architecture, glTF viewer, material system, cross-platform rendering backend organization. |
| [Diligent Engine](https://github.com/DiligentGraphics/DiligentEngine) | dependency-candidate | Apache-2.0 | Cross-API abstraction over Vulkan/D3D/Metal/OpenGL/WebGPU, shader/resource binding, render-state packaging. |
| [bgfx](https://github.com/bkaradzic/bgfx) | dependency-candidate | BSD-2-Clause/CC0 signals in package metadata | Bring-your-own-engine renderer abstraction, shader toolchain concepts, multi-backend graphics API handling. |
| [Magnum](https://github.com/mosra/magnum) | safe-donor | MIT/Expat | Lightweight C++ graphics middleware, CMake-friendly modular graphics utilities, examples. |
| [Google Dawn](https://github.com/google/dawn) | dependency-candidate | BSD-3-Clause | Native WebGPU implementation, Tint/WGSL tooling, WebGPU C/C++ headers, Vulkan/D3D/Metal backend design. |
| [three.js](https://github.com/mrdoob/three.js) | safe-donor | MIT | Browser 3D scene patterns, WebGL/WebGPU examples, loaders, controls, interactive visualizations. |
| [Babylon.js](https://github.com/BabylonJS/Babylon.js/) | safe-donor | Apache-2.0 | Web 3D engine architecture, TypeScript/WebGPU/WebXR examples, scene/tooling patterns. |

## Ray And Path Tracing References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [pbrt-v4](https://github.com/mmp/pbrt-v4) | safe-donor | Apache-2.0 | Physically based rendering algorithms, materials, sampling, scene format, CPU/GPU renderer structure. |
| [Mitsuba 3](https://github.com/mitsuba-renderer/mitsuba3) | safe-donor | BSD-3-Clause style license | Differentiable/retargetable rendering design, plugin architecture, integrator/material ideas. |
| [NVIDIA Falcor](https://github.com/NVIDIAGameWorks/Falcor) | dependency-candidate | BSD-3-Clause core; separate NVIDIA component licenses | Realtime rendering framework, RTX/ray-tracing architecture, render graphs. Inspect component licenses before reuse. |
| [THREE.js PathTracing Renderer](https://github.com/erichlof/THREE.js-PathTracing-Renderer) | safe-donor | CC0-1.0 | WebGL path tracing demos, shader-side path tracing patterns, BVH/glTF browser rendering ideas. |

## Selection Notes

- For Vulkan correctness, start with Khronos Vulkan-Samples before vendor-specific samples.
- For NVIDIA-specific Vulkan extensions and tooling, use `vk_mini_samples` and keep extension fallbacks explicit.
- For a project that needs a renderer dependency, compare Filament, Diligent Engine, bgfx, Magnum, and Dawn against the target repo's language, backend, shader, and build constraints.
- For browser-facing 3D demos, use three.js first for lightweight scenes and Babylon.js when a fuller engine/editor stack is useful.

## Deep Profiles

- [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md): read first for portable Vulkan correctness, validation, offscreen/headless, and best-practice samples.
- [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md): read after Khronos samples when NVIDIA extensions, Nsight/Aftermath, Slang, ray tracing, mesh/task shaders, or descriptor-heap samples are relevant.
