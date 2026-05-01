# Native Engineering Infrastructure Donors

Use these donors for native C++/CUDA/Vulkan project scaffolding, build layout, dependency policy,
testing, validation, static analysis, profiling, CI, and template update safety. This category is for
coding infrastructure around projects, not for studio asset departments.

## Project Backbone And Update Safety

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [CMake Project Templates](profiles/cmake-project-templates.md) | dependency-candidate | Mixed permissive template signals; inspect exact repos | CMake project layout, presets, app/library separation, CI-ready starter structure, and reusable C++ template conventions. |
| [Template Update Systems](profiles/template-update-systems.md) | dependency-candidate | Mixed permissive project licenses; inspect exact tool versions | Updating generated projects, preserving local edits, answer files, diff previews, and non-overwrite template workflows. |

## Build, Dependencies, And Package Boundaries

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Dependency Management](profiles/dependency-management.md) | dependency-candidate | Tool and registry licenses vary; inspect manifests and generated files | vcpkg, Conan, CPM.cmake, FetchContent, vendoring, lockfiles, package boundaries, and third-party notice policy. |

## Test, Quality, And Validation Lanes

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Testing Infrastructure](profiles/testing-infrastructure.md) | dependency-candidate | Mixed permissive framework signals; inspect exact dependency versions | CTest labels, GoogleTest/Catch2/doctest, Google Benchmark, render/golden tests, and test discovery policy. |
| [Static Analysis And Formatting](profiles/static-analysis-formatting.md) | dependency-candidate | LLVM/Apache and permissive tool signals; inspect exact tools | clang-format, clang-tidy, include-what-you-use, cppcheck, compile database checks, and style enforcement. |
| [Sanitizer And Validation Lanes](profiles/sanitizer-validation-lanes.md) | dependency-candidate | LLVM/NVIDIA/toolchain licenses vary | ASan, UBSan, TSan, Compute Sanitizer, sanitizer presets, runtime options, and failure-artifact capture. |
| [GPU Shader Validation](profiles/gpu-shader-validation.md) | dependency-candidate | Khronos/Google permissive signals with third-party deps | SPIR-V validation, GLSL compilation, shader CI, reflection checks, Vulkan validation layers, and shader diagnostics. |

## Profiling, Observability, And CI

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Profiling And Observability](profiles/profiling-observability.md) | dependency-candidate | Tool licenses vary; inspect capture/tool redistribution terms | Tracy, Perfetto, RenderDoc, Nsight Systems, frame-time capture, GPU timestamps, and profiling artifacts. |
| [CI And GPU Runners](profiles/ci-gpu-runners.md) | dependency-candidate | Hosted service and runner licenses vary | GitHub Actions, self-hosted GPU runners, labels, artifact upload, capability gates, and driver/toolchain isolation. |

## Selection Notes

- Start here before writing project-specific scaffolding, CMake, validation scripts, CI, or profiling
  lanes.
- Use [project-archetypes.md](../project-archetypes.md) after this file to choose the generated
  project shape.
- For Vulkan runtime details, route to [vulkan-foundation-tooling.md](vulkan-foundation-tooling.md)
  after choosing the infrastructure lane.
- For CUDA kernel/runtime details, route to [ai-runtimes-kernels.md](ai-runtimes-kernels.md) or
  [simulation-gpu.md](simulation-gpu.md) only when the work is actually CUDA or compute-domain
  specific.
- Keep update safety explicit: preview diffs, preserve user content outside managed markers, and avoid
  hidden overwrites.

## Deep Profiles

- [CMake Project Templates](profiles/cmake-project-templates.md): read before changing project
  layout, CMake presets, app/library separation, or template conventions.
- [Template Update Systems](profiles/template-update-systems.md): read before designing update or
  apply workflows for generated projects.
- [Dependency Management](profiles/dependency-management.md): read before choosing vcpkg, Conan,
  CPM.cmake, FetchContent, vendoring, or third-party notice policy.
- [Testing Infrastructure](profiles/testing-infrastructure.md): read before changing CTest labels,
  test discovery, benchmark lanes, or render/golden test policy.
- [Static Analysis And Formatting](profiles/static-analysis-formatting.md): read before changing
  formatting, linting, static-analysis, or compile-database checks.
- [Sanitizer And Validation Lanes](profiles/sanitizer-validation-lanes.md): read before adding or
  changing ASan/UBSan/TSan, Compute Sanitizer, or validation presets.
- [GPU Shader Validation](profiles/gpu-shader-validation.md): read before changing shader
  compilation, SPIR-V validation, reflection, or validation-layer policy.
- [Profiling And Observability](profiles/profiling-observability.md): read before adding profiling,
  tracing, frame-time capture, or GPU timing infrastructure.
- [CI And GPU Runners](profiles/ci-gpu-runners.md): read before changing self-hosted GPU CI,
  runner labels, artifacts, or toolchain gates.
