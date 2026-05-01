# GPU Shader Validation Donor Profile

Sources: https://github.com/KhronosGroup/SPIRV-Tools https://github.com/google/shaderc https://github.com/KhronosGroup/glslang https://github.com/KhronosGroup/Vulkan-ValidationLayers
Tier: `dependency-candidate`
Backend signal: native-vulkan, api-agnostic
License signal: Khronos/Google permissive signals with third-party dependencies; inspect exact
checkout, bundled deps, generated files, and SDK packaging terms.

## Use First For

- SPIR-V validation, GLSL compilation, shader CI, descriptor reflection checks, Vulkan validation
  layers, GPU-assisted validation, and shader diagnostics.
- Separating shader compilation, validation, reflection, and runtime pipeline creation.

## First Upstream Areas To Inspect

- SPIRV-Tools validator, optimizer, disassembler, and reducer.
- shaderc `glslc` command behavior and CMake integration examples.
- glslang front-end behavior for GLSL/HLSL-to-SPIR-V compilation.
- Vulkan ValidationLayers documentation for synchronization and GPU-assisted validation.

## Integration Notes

- Treat shader compilation as a build or asset-cook step with explicit outputs.
- Run `spirv-val` on generated SPIR-V before runtime pipeline tests.
- Keep validation-layer environment variables in scripts, not hidden shell assumptions.

## Validation Ideas

- Compile a small shader fixture and run SPIR-V validation.
- Intentionally break a shader in a temp copy to confirm the validation script fails.
- Run a Vulkan smoke test with validation layers enabled when the host supports Vulkan.

## Caveats

- Validation-layer behavior depends on Vulkan SDK/driver versions.
- Shader-language choice should stay project-specific; do not force Slang or HLSL unless the project
  needs multi-target shader authoring.
