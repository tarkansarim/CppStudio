# CUDA Lane Research

Last researched: 2026-04-30

This folder captures CUDA-side research for the reusable C++/CUDA/Vulkan studio skill. It is
research input for skill and template updates, not a generated project scaffold.

## Files

- [source-map.md](source-map.md): official docs, vendor docs, and donor repositories consulted.
- [lane-findings.md](lane-findings.md): high-level implications for the CppStudio CUDA lane.
- [toolchain-and-architectures.md](toolchain-and-architectures.md): toolkit, driver, CMake, and GPU
  architecture guidance.
- [kernels-libraries-and-graphs.md](kernels-libraries-and-graphs.md): kernel, library, stream, graph,
  and CUDA/Vulkan interop guidance.
- [debugging-profiling-testing.md](debugging-profiling-testing.md): Compute Sanitizer, Nsight, and
  benchmark baseline guidance.

## Use Rules

- Treat current-version facts as dated. Re-check NVIDIA release notes before pinning a CUDA Toolkit,
  driver, or library version in a real project.
- Prefer official NVIDIA/CMake docs for policy decisions, then use donor repositories for examples and
  architecture patterns.
- Keep CUDA architecture choices explicit in CI and release builds. `native` is acceptable for local
  developer builds, but it is not a portable artifact policy.
- Separate donor code from donor concepts. The skill donor library classifies which projects are safe
  to adapt and which should remain study-only.
