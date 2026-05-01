# Native Engineering Infrastructure Routing Overlay

Use this when the user asks for coding infrastructure, project backbone, build/test/profiling lanes,
template rollout, CI, dependency policy, or validation harness work rather than a 3D production
department. Continue into [native-engineering-infrastructure.md](../native-engineering-infrastructure.md)
for the canonical donor category.

| Intent | Includes | Open First |
| --- | --- | --- |
| Project Templates | Greenfield app/library templates, Vulkan app, CUDA library, CUDA/Vulkan interop app, renderer backbone, asset tool, simulation tool. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [project-archetypes.md](../../project-archetypes.md) |
| Build Infrastructure | CMake presets, target layout, toolchain files, package config, install/export, compile database policy. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) |
| Dependency Policy | vcpkg, Conan, CPM.cmake, FetchContent, vendoring, submodules, third-party notices. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [selection-policy.md](../selection-policy.md) |
| Testing Infrastructure | CTest labels, unit tests, GPU tests, render tests, image/golden tests, benchmarks. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) |
| Validation Lanes | Vulkan validation, shader validation, Compute Sanitizer, ASan, UBSan, TSan, capability dumps. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [vulkan-foundation-tooling.md](../vulkan-foundation-tooling.md) |
| Profiling/Observability | Nsight, RenderDoc, Tracy, Perfetto, frame-time capture, GPU timestamps, artifact capture. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [graphics-rendering.md](../graphics-rendering.md) |
| CI/GPU Runners | GitHub Actions, self-hosted GPU runners, labels, artifacts, driver/toolchain gates. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) |
| Template Update Safety | Managed marker blocks, non-overwrite apply scripts, diff previews, update-aware template systems. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) |

## Notes

- This route is for infrastructure around native projects, not generic app planning or project
  management.
- Use this before domain donors when the request starts with "set up", "scaffold", "upgrade the
  backbone", "add validation lanes", "add profiling", "make CI", or "make this reusable for agents".
- Keep generated projects normal C++ repositories. Do not turn CppStudio into a mandatory runtime
  library or custom package manager.
