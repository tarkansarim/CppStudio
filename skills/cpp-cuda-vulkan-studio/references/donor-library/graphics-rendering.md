# Graphics And Rendering Donors

Use these donors for Vulkan renderer samples, renderer backbone selection, WebGPU/WebGL, PBR,
frame/debug tooling, render graphs, and ray/path tracing work.

## Primary Safe Donors

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Khronos Vulkan-Samples](https://github.com/KhronosGroup/Vulkan-Samples) | safe-donor | Apache-2.0 | Vulkan API samples, performance samples, validation-friendly examples, dynamic rendering, timeline semaphores, headless/offscreen patterns. |
| [NVIDIA vk_mini_samples](https://github.com/nvpro-samples/vk_mini_samples) | safe-donor | Apache-2.0 | Modern Vulkan samples for ray tracing, mesh/task shaders, descriptor heap, shader printf, crash/debug tooling, compute examples. |
| [nvpro Vulkan Ray Tracing Tutorial KHR](profiles/nvpro-vk-raytracing-tutorial-khr.md) | safe-donor | Apache-2.0 | Progressive Vulkan ray tracing, BLAS/TLAS, shader binding tables, raygen/miss/closest-hit stages, shadow rays, and swept-sphere concepts. |
| [NVIDIA NVRHI](profiles/nvrhi.md) | safe-donor | MIT | Cross-API render interface, resource state tracking, barrier placement, deferred destruction, and Vulkan/D3D ray-tracing abstraction patterns. |
| [NVIDIA NRI](profiles/nri.md) | safe-donor | MIT | Low-level Vulkan/D3D render-interface abstraction, capability detection, ray-tracing extension boundaries, and upscaler extension shape. |
| [Google Filament](https://github.com/google/filament) | dependency-candidate | Apache-2.0 | PBR renderer architecture, glTF viewer, material system, cross-platform rendering backend organization. |
| [Diligent Engine](https://github.com/DiligentGraphics/DiligentEngine) | dependency-candidate | Apache-2.0 | Cross-API abstraction over Vulkan/D3D/Metal/OpenGL/WebGPU, shader/resource binding, render-state packaging. |
| [bgfx](https://github.com/bkaradzic/bgfx) | dependency-candidate | BSD-2-Clause/CC0 signals in package metadata | Bring-your-own-engine renderer abstraction, shader toolchain concepts, multi-backend graphics API handling. |
| [Magnum](https://github.com/mosra/magnum) | safe-donor | MIT/Expat | Lightweight C++ graphics middleware, CMake-friendly modular graphics utilities, examples. |
| [Google Dawn](https://github.com/google/dawn) | dependency-candidate | BSD-3-Clause | Native WebGPU implementation, Tint/WGSL tooling, WebGPU C/C++ headers, Vulkan/D3D/Metal backend design. |
| [three.js](https://github.com/mrdoob/three.js) | safe-donor | MIT | Browser 3D scene patterns, WebGL/WebGPU examples, loaders, controls, interactive visualizations. Reference-only for native C++. |
| [Babylon.js](https://github.com/BabylonJS/Babylon.js/) | safe-donor | Apache-2.0 | Web 3D engine architecture, TypeScript/WebGPU/WebXR examples, scene/tooling patterns. Reference-only for native C++. |

## Ray And Path Tracing References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [pbrt-v4](https://github.com/mmp/pbrt-v4) | safe-donor | Apache-2.0 | Physically based rendering algorithms, materials, sampling, scene format, CPU/GPU renderer structure. |
| [Mitsuba 3](https://github.com/mitsuba-renderer/mitsuba3) | safe-donor | BSD-3-Clause style license | Differentiable/retargetable rendering design, plugin architecture, integrator/material ideas. |
| [NVIDIA Falcor](https://github.com/NVIDIAGameWorks/Falcor) | dependency-candidate | BSD-3-Clause core; separate NVIDIA component licenses | Realtime rendering framework, RTX/ray-tracing architecture, render graphs. Inspect component licenses before reuse. |
| [nvpro Vulkan glTF Renderer](profiles/nvpro-vk-gltf-renderer.md) | dependency-candidate | Apache-2.0 core signal; third-party and SDK notices vary | Production-scale Vulkan path tracer, glTF/PBR scene runtime, DLSS/OptiX denoising hooks, editor shell, and timeline pacing. |
| [nvpro vk_denoise_dlssrr](profiles/nvpro-vk-denoise-dlssrr.md) | dependency-candidate | Apache-2.0 sample plus NVIDIA DLSS/NGX SDK terms | Compact Vulkan DLSS Ray Reconstruction integration, NGX wrapper flow, guide-buffer semantics, and debug views. |
| [NVIDIA NRD](profiles/nrd.md) | dependency-candidate | NVIDIA RTX SDKs license | Real-time denoiser signal contracts, guide-buffer definitions, RELAX/REBLUR/SIGMA integration, and temporal validation. |
| [NVIDIA NRD Sample](profiles/nrd-sample.md) | dependency-candidate | Sample license and SDK notices require exact checkout review | End-to-end path tracing plus denoising best practices, NRD/DLSS-RR comparison, guide-buffer debugging, and reference accumulation. |
| [NVIDIA DLSS SDK](profiles/nvidia-dlss-sdk.md) | dependency-candidate | NVIDIA RTX SDKs license and release-package terms | Official NGX/DLSS/DLSS-RR feature contracts, Vulkan/DirectX headers, runtime capability checks, and guide-buffer requirements. |
| [NVIDIA Streamline](profiles/nvidia-streamline.md) | dependency-candidate | MIT-like core source plus plugin/binary/SDK terms | Cross-IHV upscaler/reconstruction integration, feature plugins, frame/resource tagging, and modern DLSS integration boundary. |
| [NVIDIA Streamline Sample](profiles/nvidia-streamline-sample.md) | dependency-candidate | NVIDIA RTX SDKs sample license plus Donut/third-party notices | App-side Streamline usage, feature wiring, resource/frame tagging, plugin packaging, and fallback lane behavior. |
| [THREE.js PathTracing Renderer](https://github.com/erichlof/THREE.js-PathTracing-Renderer) | safe-donor | CC0-1.0 | WebGL path tracing demos, shader-side path tracing patterns, BVH/glTF browser rendering ideas. Reference-only for native C++. |

## Selection Notes

- For Vulkan correctness, start with Khronos Vulkan-Samples before vendor-specific samples.
- For Vulkan memory allocation, loader/bootstrap, shader reflection, or SPIR-V tooling, route to
  [vulkan-foundation-tooling.md](vulkan-foundation-tooling.md) before choosing renderer-level donors.
- For NVIDIA-specific Vulkan extensions and tooling, use `vk_mini_samples` and keep extension fallbacks explicit.
- For Vulkan ray tracing fundamentals, use `vk_raytracing_tutorial_KHR` before renderer-scale frameworks.
- For renderer-scale Vulkan path tracing, glTF PBR runtime, scene ownership, timeline pacing, and optional
  denoising, use `vk_gltf_renderer` after deciding which dependency surfaces are acceptable.
- For compact DLSS Ray Reconstruction in Vulkan, use `vk_denoise_dlssrr`; for official SDK contracts use
  the DLSS SDK; for a broader plugin-based integration use Streamline and Streamline Sample. Keep all of
  these optional and license-reviewed.
- For denoising without automatically choosing DLSS, use NRD and NRD-Sample to define guide buffers,
  raw-vs-denoised comparison lanes, and temporal validation.
- Use NVRHI or NRI only when a renderer abstraction is deliberately in scope. For smaller direct-Vulkan
  projects, borrow resource-lifetime, capability, and extension-boundary patterns without adding the
  abstraction dependency.
- For a project that needs a renderer dependency, compare Filament, Diligent Engine, bgfx, Magnum, and
  Dawn against the target repo's language, backend, shader, asset, and build constraints.
- Use Dawn for native WebGPU, `webgpu.h`, WGSL/Tint, or WebGPU portability questions; do not replace a
  Vulkan-first lane with WebGPU unless the user explicitly chooses WebGPU.
- For runtime mesh import, conditioning, BVH, collision, or physics handoff, route to
  [geometry-simulation.md](geometry-simulation.md) after choosing the renderer boundary.
- For browser-facing 3D demos, use three.js first for lightweight scenes and Babylon.js when a fuller engine/editor stack is useful.
  For native C++ projects, translate behavior and fixtures; do not copy JavaScript/TypeScript runtime code.
- For physically based or differentiable rendering correctness, use pbrt-v4 and Mitsuba 3 as reference
  donors. Treat their CUDA/OptiX paths as backend-specific references, not automatic CUDA lane changes.
- For realtime ray tracing or render-graph architecture, use Falcor only when framework-scale or
  NVIDIA RTX-oriented decisions are truly in scope, and inspect component licenses first.
- For browser path-tracing behavior, use THREE.js PathTracing Renderer as a compact WebGL concept donor;
  use pbrt-v4 or Mitsuba 3 when offline physical correctness matters more than demo ergonomics.

## Deep Profiles

- [Khronos Vulkan-Samples](profiles/khronos-vulkan-samples.md): read first for portable Vulkan correctness, validation, offscreen/headless, and best-practice samples.
- [NVIDIA vk_mini_samples](profiles/nvidia-vk-mini-samples.md): read after Khronos samples when NVIDIA extensions, Nsight/Aftermath, Slang, ray tracing, mesh/task shaders, or descriptor-heap samples are relevant.
- [nvpro Vulkan Ray Tracing Tutorial KHR](profiles/nvpro-vk-raytracing-tutorial-khr.md): read before implementing Vulkan RT pipelines, BLAS/TLAS, SBT, shadow rays, or swept-sphere experiments.
- [NVIDIA NVRHI](profiles/nvrhi.md): read before adopting or borrowing cross-API renderer hardware-interface patterns.
- [NVIDIA NRI](profiles/nri.md): read before adopting or borrowing low-level render-interface, ray-tracing extension, or upscaler extension patterns.
- [Google Filament](profiles/filament.md): read before adopting a full PBR renderer, glTF viewer, or material/tool pipeline.
- [Diligent Engine](profiles/diligent-engine.md): read before adopting a cross-API renderer abstraction or DiligentFX-style high-level renderer.
- [bgfx](profiles/bgfx.md): read before choosing bring-your-own-engine multi-backend rendering or shader-toolchain abstraction.
- [Magnum](profiles/magnum.md): read before using lightweight C++ graphics middleware, modular utilities, or CMake-friendly graphics helpers.
- [Google Dawn](profiles/dawn.md): read before adopting native WebGPU, `webgpu.h`, WGSL/Tint tooling, or WebGPU backend portability references.
- [three.js](profiles/threejs.md): read before using browser 3D scene, controls, loader, WebGPU/WebGL, or WebXR behavior as a reference.
- [Babylon.js](profiles/babylonjs.md): read before using full browser 3D engine, WebGPU/WebXR, editor/playground, or TypeScript engine architecture references.
- [pbrt-v4](profiles/pbrt-v4.md): read before adapting physically based rendering algorithms, sampling, materials, scene formats, or CPU/GPU path-tracing references.
- [Mitsuba 3](profiles/mitsuba3.md): read before adapting differentiable, retargetable, spectral, or inverse-rendering concepts.
- [NVIDIA Falcor](profiles/falcor.md): read before borrowing realtime ray-tracing framework, render graph, or RTX/NVIDIA SDK integration patterns.
- [nvpro Vulkan glTF Renderer](profiles/nvpro-vk-gltf-renderer.md): read before borrowing production-scale Vulkan path-tracing, glTF/PBR scene runtime, DLSS/OptiX hooks, or renderer timeline patterns.
- [nvpro vk_denoise_dlssrr](profiles/nvpro-vk-denoise-dlssrr.md): read before wiring Vulkan DLSS Ray Reconstruction, NGX wrappers, or DLSS-RR guide buffers.
- [NVIDIA NRD](profiles/nrd.md): read before defining denoiser guide-buffer contracts or NRD integration.
- [NVIDIA NRD Sample](profiles/nrd-sample.md): read before using NRD/DLSS-RR comparison lanes, path-tracing denoiser debug views, or reference accumulation as a validation model.
- [NVIDIA DLSS SDK](profiles/nvidia-dlss-sdk.md): read before using NGX/DLSS/DLSS-RR feature contracts or runtime SDK headers.
- [NVIDIA Streamline](profiles/nvidia-streamline.md): read before choosing Streamline for super-resolution, reconstruction, frame-generation, or feature-plugin integration.
- [NVIDIA Streamline Sample](profiles/nvidia-streamline-sample.md): read after Streamline when app-side feature wiring, frame/resource tagging, or plugin packaging examples are needed.
- [THREE.js PathTracing Renderer](profiles/threejs-pathtracing.md): read before using browser/WebGL path-tracing demos, progressive accumulation, or shader-side path-tracing UX references.
