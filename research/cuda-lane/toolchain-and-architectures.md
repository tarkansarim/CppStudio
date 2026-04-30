# CUDA Toolchain And Architecture Notes

Last researched: 2026-04-30

## Toolkit And Driver Policy

- Check NVIDIA CUDA Toolkit release notes before installing, pinning, or upgrading a project. At this
  research date, the live release notes identify CUDA 13.2 Update 1 and list driver compatibility by
  toolkit row.
- Keep driver/toolkit facts in environment docs and CI runner docs. Do not bake a single CUDA version
  into reusable CMake template logic unless a concrete project requires it.
- CUDA 13.x release notes report dropped or deprecated legacy architecture support. If a target project
  must support Maxwell, Pascal, or Volta, keep that as a project-specific CUDA 12.x compatibility lane.
- Treat CUDA libraries as independently versioned components. cuBLAS/cuDNN/cuFFT/cuSPARSE behavior can
  change within the same toolkit line, and patch notes may matter for numerical correctness.

## CMake Architecture Policy

- Use `CMAKE_CUDA_ARCHITECTURES` or per-target `CUDA_ARCHITECTURES` instead of manual `-gencode`
  fragments when possible.
- Keep the template default at `native` for local developer builds because it is ergonomic and avoids
  pretending to know the user's GPU fleet.
- Set explicit architectures in CI and release builds through `PROJECT_CUDA_ARCHITECTURES`, for example
  a semicolon-separated fleet list.
- Avoid `all` and `all-major` in routine CI unless a project intentionally accepts the compile-time and
  binary-size cost.
- Confirm that the installed CMake and NVCC versions support any newer architecture ID or
  architecture-accelerated suffix before committing it.

## Architecture Notes

Use the official CUDA GPU compute capability table as the source of truth. Current important classes:

| Class | Common IDs | Notes |
| --- | --- | --- |
| Turing | 75 | Still common for older RTX/T4 machines; CUDA 13 supports Turing and newer. |
| Ampere | 80, 86, 87 | A100 uses 80; many RTX 30/A10 devices use 86; Jetson Orin is commonly 87. |
| Ada | 89 | RTX 40 and L4/L40-class devices. |
| Hopper | 90, 90a | `a` suffix is required for some architecture-accelerated instructions. |
| Blackwell data center | 100, 103 | B200/GB200 and B300/GB300 families are not the same as RTX Blackwell. |
| Jetson Thor | 110 | Separate Blackwell-class embedded lane. |
| Blackwell RTX/workstation | 120 | RTX 50 and RTX PRO Blackwell class. |
| DGX Spark | 121 | GB10/DGX Spark class. |

## Practical Defaults

- Developer preset: `PROJECT_CUDA_ARCHITECTURES=native`.
- Self-hosted CI: explicit list for the attached runner labels, documented in `docs/GPU_RUNNER_CI.md`.
- Release artifacts: explicit list of supported devices plus a PTX strategy reviewed against the toolkit
  and donor libraries.
- Donor experiments: follow the donor's own architecture guidance first, then translate it into the
  target project's CMake policy.
