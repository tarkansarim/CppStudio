# OpenXR-Hpp Donor Profile

Source: https://github.com/KhronosGroup/OpenXR-Hpp  
Tier: `safe-donor`  
Backend signal: api-agnostic
License signal: Apache-2.0; inspect `LICENSE`, generated wrapper headers, registry inputs, examples,
and generated-file notices at the exact revision used.

## Use First For

- Type-safe C++ OpenXR bindings, RAII-style API ergonomics, enum/result handling, and generated wrapper
  policy.
- C++ projects that need a cleaner OpenXR API surface while still following Khronos OpenXR SDK behavior.
- Comparing C API and C++ wrapper boundaries before designing project-local XR abstractions.

## First Upstream Areas To Inspect

- Generated OpenXR-Hpp headers and generator inputs.
- Examples or integration notes that match the target compiler and OpenXR SDK version.
- License and generated-file notices before copying wrapper patterns.
- OpenXR SDK `hello_xr` samples for runtime behavior, because OpenXR-Hpp is not the runtime sample set.

## Integration Notes

- Pair OpenXR-Hpp with Khronos OpenXR SDK guidance for loader/runtime behavior.
- Keep wrapper ergonomics separate from runtime discovery, action setup, swapchains, frame timing, and
  graphics binding tests.
- In Vulkan targets, route synchronization and image handling through the Vulkan lane.
- Avoid hiding OpenXR result/error handling behind overly broad project abstractions.

## Validation Ideas

- Compile a tiny wrapper smoke fixture that creates/destroys instance-level objects where a runtime is
  available.
- Test no-runtime, unsupported-extension, failed-result, and missing-system paths explicitly.
- Keep wrapper compile tests separate from hardware/runtime smoke tests.
- Record OpenXR SDK and OpenXR-Hpp versions together.

## Caveats

- OpenXR-Hpp improves C++ ergonomics but does not remove OpenXR runtime complexity.
- Generated API surfaces can move with registry changes.
- Hardware/runtime availability remains an external test constraint.
