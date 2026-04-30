# Slang Donor Profile

Source: https://github.com/shader-slang/slang  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Apache-2.0 with LLVM exception for Slang code; releases and builds can include LLVM
and other third-party components. Inspect `LICENSE`, bundled binaries, examples, and dependency
notices at the exact revision used.

## Use First For

- Multi-target shader authoring across Vulkan, Direct3D, CUDA, and other backend targets.
- Shader generics, interfaces, specialization, reflection, and larger shader-codebase organization.
- Projects that need HLSL-like syntax while still producing SPIR-V for Vulkan.

## First Upstream Areas To Inspect

- User guide and command-line `slangc` documentation.
- C API/C++ API examples for compiler and reflection integration.
- Vulkan examples and RenderDoc/debugging notes.
- Release package contents and third-party notices before redistribution.

## Integration Notes

- Keep the default Vulkan template GLSL-first unless Slang solves a concrete multi-target or shader
  architecture problem.
- Treat generated SPIR-V as the artifact to validate with `spirv-val` and target-project shader tests.
- Keep Slang module layout, specialization parameters, reflection data, and generated outputs explicit
  in build docs.

## Validation Ideas

- Compile one minimal graphics shader and one compute shader to SPIR-V.
- Validate generated SPIR-V and compare reflected resources against C++ descriptor expectations.
- Test specialization/generic paths with tiny fixtures before converting a larger shader tree.

## Caveats

- Slang is broader than Vulkan; do not adopt it just to avoid writing GLSL.
- Release packages may include third-party compiler/runtime components with separate notices.
- Multi-target shader support does not remove backend-specific synchronization and resource-binding policy.
