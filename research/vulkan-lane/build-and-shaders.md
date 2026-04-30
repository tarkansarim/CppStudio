# Build And Shader Research

## SDK And Driver Discovery

The Vulkan SDK provides development assets: headers, loader libraries, validation layers, Vulkan
Configurator, shader toolchains, GFXReconstruct, Vulkan Capabilities Viewer, Volk, and VMA. It does
not install GPU drivers. A Vulkan backbone should separate these checks:

- SDK/tool check: `VULKAN_SDK`, headers, libraries, shader compilers, validation layer manifests,
  SPIR-V tools.
- Runtime check: ICD manifests, `vulkaninfo`, physical devices, queue families, selected device,
  API version, required features, and required extensions.
- Optional debugger/profiler check: RenderDoc, Nsight Graphics, Nsight Systems, GFXReconstruct.

Useful SDK-derived smoke checks:

- `vulkaninfo` confirms loader and ICD visibility.
- `vkcube` confirms basic presentation when a display path is available.
- Shader compiler invocations confirm the shader lane independently from device runtime.

## CMake `FindVulkan`

CMake's `FindVulkan` module has become a strong anchor for the Vulkan lane. Current docs list
imported targets for:

- `Vulkan::Vulkan`
- `Vulkan::Headers`
- `Vulkan::glslc`
- `Vulkan::glslangValidator`
- `Vulkan::glslang`
- `Vulkan::shaderc_combined`
- `Vulkan::SPIRV-Tools`
- `Vulkan::MoltenVK`
- `Vulkan::dxc_lib`
- `Vulkan::dxc_exe`
- `Vulkan::volk`

The current template already requires CMake 3.25, which is new enough for DXC and Volk support in
`FindVulkan`. Later planning can consider a reusable CMake module that:

- Calls concrete `find_package(Vulkan REQUIRED COMPONENTS glslc glslangValidator SPIRV-Tools)`
  variants, with component sets controlled by cache options.
- Exposes `PROJECT_ENABLE_VULKAN`, `PROJECT_ENABLE_VULKAN_VALIDATION`, and shader-language options.
- Defines a custom command/function for compiling shaders to SPIR-V.
- Adds a shader validation target that runs `spirv-val`.
- Emits clear configure-time messages distinguishing missing SDK tools from missing ICD/runtime.

## Shader Language Choices

### Slang

Khronos' current Vulkan tutorial uses Slang as the primary shading language, and the Slang project
states that Vulkan SDK releases include Slang since SDK 1.3.296.0. Slang targets Vulkan/SPIR-V and
also has CUDA output support, which makes it strategically relevant for a combined CUDA/Vulkan
studio backbone.

Research implication:

- Slang is a credible modern default candidate for new Vulkan graphics projects.
- It should not be forced on existing GLSL/HLSL repos.
- If adopted, the skill should include explicit `slangc` discovery and SPIR-V validation.

### GLSL With glslang Or shaderc

glslang is the Khronos reference frontend and SPIR-V generator. Shaderc provides `glslc`, which wraps
glslang and SPIRV-Tools with build-system-friendly command-line behavior.

Research implication:

- `glslc` is a practical default for simple GLSL shader compilation in CMake.
- `glslangValidator` remains useful as a direct validation/compiler path.
- The HLSL frontend status in glslang is changing, so HLSL projects should prefer DXC or Slang.

### HLSL With DXC

DXC supports HLSL-to-SPIR-V. CMake specifically notes that the Vulkan SDK's DXC is typically required
for Vulkan development because it has Vulkan capability enabled.

Research implication:

- HLSL/Vulkan support should use explicit DXC discovery from the Vulkan SDK or a verified equivalent.
- Shader compile options should be documented instead of copied from Direct3D examples.

## SPIR-V Toolchain

The minimum robust shader lane should include:

- Compile: `slangc`, `glslc`, `glslangValidator`, or `dxc`, depending on language policy.
- Validate: `spirv-val`.
- Inspect: `spirv-dis`.
- Optimize or normalize when appropriate: `spirv-opt`.
- Reflect when useful: SPIRV-Reflect for descriptor/push-constant/IO extraction.
- Cross-compile or inspect portability issues: SPIRV-Cross.

Later skill planning should decide whether reflection is:

- A verification tool only.
- A code-generation input for descriptor layouts.
- Out of scope for the base template but documented for larger engines.

## Shader Artifact Policy

A production-grade Vulkan template needs a clear artifact policy:

- Source shaders live under `shaders/` or a project-specific equivalent.
- Generated `.spv` files should normally be build outputs, not edited source.
- Build outputs should not be committed unless the project intentionally vendors binary assets.
- Runtime lookup should be deterministic: copied to a known output asset directory, embedded into C++
  objects, or installed beside the executable.
- Tests should fail when shader source and reflected/declared descriptor contracts diverge.

## Candidate Future CMake Surfaces

These are research-derived surfaces for later plan mode, not an implementation plan:

- `ProjectVulkan.cmake`
- `project_enable_vulkan_target(target)`
- `project_compile_vulkan_shader(NAME example_compute SOURCE shaders/example.comp OUTPUT example_compute.spv)`
- `project_add_spirv_validation_target(TARGET validate_shaders INPUTS example_compute.spv)`
- `PROJECT_VULKAN_SHADER_LANGUAGE`
- `PROJECT_ENABLE_VULKAN_VALIDATION`
- `PROJECT_ENABLE_VULKAN_SYNC_VALIDATION`
- `PROJECT_ENABLE_VULKAN_GPU_ASSISTED_VALIDATION`
- `PROJECT_VULKAN_REQUIRED_API_VERSION`
- `PROJECT_VULKAN_REQUIRED_EXTENSIONS`
