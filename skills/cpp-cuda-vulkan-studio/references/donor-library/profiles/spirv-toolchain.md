# SPIR-V Toolchain Donor Profile

Sources: https://github.com/KhronosGroup/SPIRV-Reflect, https://github.com/KhronosGroup/SPIRV-Tools,
https://github.com/KhronosGroup/glslang, https://github.com/google/shaderc, and
https://github.com/KhronosGroup/SPIRV-Cross  
Tier: `safe-donor` for narrow SPIRV-Reflect and SPIRV-Cross patterns, `dependency-candidate` for full
toolchain integrations  
Backend signal: native-vulkan, api-agnostic
License signal: SPIRV-Reflect, SPIRV-Tools, SPIRV-Cross, and shaderc have Apache-2.0 signals; glslang
has mixed permissive license files. Inspect `LICENSE`, `LICENSES/`, `third_party/`, `DEPS`, and
package metadata at the exact revision used.

## Use First For

- Shader compilation, SPIR-V validation, assembly/disassembly, reflection, and cross-compilation.
- Build-system shader lanes that keep compile and validation steps visible.
- Detecting descriptor, push-constant, and shader-interface drift between shader code and C++ code.

## First Upstream Areas To Inspect

- SPIRV-Reflect public C API and tests for descriptor and push-constant reflection.
- SPIRV-Tools validator, optimizer, reducer, disassembler, and tests.
- shaderc `glslc` and libshaderc examples for command-line and embedded compiler workflows.
- glslang migration notes before relying on HLSL-front-end behavior.
- SPIRV-Cross reflection and GLSL/MSL/HLSL backend tests for cross-target shader policy.

## Integration Notes

- Keep shader compilation, SPIR-V validation, reflection, and runtime pipeline creation as separate
  build/test steps.
- Prefer `glslc` plus `spirv-val` for simple GLSL-first Vulkan templates.
- Use reflection to verify layouts; do not silently generate C++ binding code unless the target project
  explicitly accepts generated-code policy.
- Treat cross-compilation output as a testable artifact with backend-specific fixtures.

## Validation Ideas

- Compile tiny vertex, fragment, and compute shaders and run `spirv-val`.
- Reflect descriptor sets and push constants from SPIR-V and compare against C++ expectations.
- Add negative shader fixtures for invalid layout, missing binding, or unsupported capability.
- Round-trip cross-compiled shader output only when the target backend requires it.

## Caveats

- Shader compiler behavior changes with Vulkan SDK versions.
- HLSL, GLSL, MSL, and Slang source languages have different binding and memory-layout assumptions.
- Full toolchain integrations can pull third-party dependencies; inspect exact packages before vendoring.
