# Vulkan Foundation And Tooling Donors

Use these donors for Vulkan memory allocation, loader/bootstrap setup, shader reflection, shader
compilation, SPIR-V validation, cross-compilation, and multi-target shader workflows.

## Runtime Infrastructure

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Vulkan Memory Allocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator) | safe-donor | MIT | Vulkan memory allocation, budgets, pools, mapping, dedicated allocations, aliasing, and allocation telemetry. |
| [volk](https://github.com/zeux/volk) | safe-donor | MIT | Vulkan function loading, device dispatch tables, extension entrypoint loading, and portability around loader behavior. |
| [vk-bootstrap](https://github.com/charles-lunarg/vk-bootstrap) | safe-donor | MIT | Vulkan instance, physical-device, logical-device, queue, surface, and swapchain bootstrap patterns. |

## Shader And SPIR-V Tooling

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [SPIRV-Reflect](https://github.com/KhronosGroup/SPIRV-Reflect) | safe-donor | Apache-2.0 | SPIR-V shader interface reflection, descriptor bindings, push constants, input/output variables, and layout checks. |
| [SPIRV-Tools](https://github.com/KhronosGroup/SPIRV-Tools) | dependency-candidate | Apache-2.0 with third-party deps | SPIR-V validation, assembly/disassembly, optimization, reduction, diffing, and shader CI tooling. |
| [glslang](https://github.com/KhronosGroup/glslang) | dependency-candidate | Mixed permissive license file; inspect exact revision | GLSL/ESSL to SPIR-V compilation, HLSL-front-end migration notes, and reference compiler behavior. |
| [shaderc](https://github.com/google/shaderc) | dependency-candidate | Apache-2.0 signals; inspect third_party | `glslc`, libshaderc integration, shader compile wrappers, and build-system shader compilation. |
| [SPIRV-Cross](https://github.com/KhronosGroup/SPIRV-Cross) | safe-donor | Apache-2.0 | Cross-compiling SPIR-V to GLSL, MSL, HLSL, reflection support, and shader portability tests. |
| [Slang](https://github.com/shader-slang/slang) | dependency-candidate | Apache-2.0 with LLVM exception; inspect bundled deps | Multi-target shader language/compiler workflows, generics, reflection, Vulkan/D3D shader sharing, and shader-module packaging. |

## Selection Notes

- For Vulkan resource ownership, read VMA before inventing custom memory suballocation.
- For loader and bootstrap decisions, prefer volk plus vk-bootstrap as references; do not hide them as
  template dependencies unless the target project accepts that dependency policy.
- For shader CI, use SPIRV-Tools and shaderc/glslang to keep compilation and validation separate.
- Use SPIRV-Reflect when descriptor layouts or push constants need to be verified against compiled
  SPIR-V instead of duplicated by hand.
- Use Slang only when multi-target shader authoring or shader generics solve a real project problem;
  keep GLSL-first `glslc` workflows for simple Vulkan-first templates.

## Deep Profiles

- [Vulkan Memory Allocator](profiles/vulkan-memory-allocator.md): read before adding Vulkan memory allocation or budget policy.
- [volk](profiles/volk.md): read before changing Vulkan loader or dispatch behavior.
- [vk-bootstrap](profiles/vk-bootstrap.md): read before adopting instance/device/swapchain bootstrap helpers.
- [GPU Shader Validation](profiles/gpu-shader-validation.md): read before changing shader CI, SPIR-V validation, Vulkan validation layers, or shader diagnostics infrastructure.
- [SPIR-V Toolchain](profiles/spirv-toolchain.md): read before changing shader compilation, reflection, validation, or cross-compilation.
- [Slang](profiles/slang.md): read before adopting Slang for multi-target shader authoring.
