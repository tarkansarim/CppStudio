# Generated Project Template

Owns the Vulkan-first C++ app/library template, optional CUDA and combined lanes, template docs,
scaffold/apply behavior, generated-project code-map navigation behavior, and generated-project
validation.

## Canonical Docs

- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/README.md`
- `docs/maintainer-guide.md`

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`
- `skills/cpp-cuda-vulkan-studio/scripts/scaffold_gpu_cpp_project.py`
- `skills/cpp-cuda-vulkan-studio/scripts/apply_studio_backbone.py`
- `skills/cpp-cuda-vulkan-studio/scripts/validate_studio_backbone.py`
- `skills/cpp-cuda-vulkan-studio/scripts/run_gpu_optimization_loop.py`
- `skills/cpp-cuda-vulkan-studio/scripts/bootstrap_code_map.py`
- `skills/cpp-cuda-vulkan-studio/scripts/validate_code_map.py`

## Update When

- template files, CMake presets, docs, shader fixtures, runtime scripts, or CI files change
- scaffold or existing-repo apply behavior changes
- generated-project validation expectations change
- code-map template files, readiness audit behavior, or generated-project code-map behavior changes

## Current Portability Notes

- Vulkan template code should use Vulkan-Hpp forms that compile against Ubuntu packaged Vulkan-Hpp
  as well as newer SDK headers.
- Code-map enablement refuses existing generated map files without `--force` and writes the enabled
  state only after generated map files are replaced.
- Existing-project code-map audits print to stdout by default. Use `--write-audit` only when the user
  wants `docs/CODEMAP_BOOTSTRAP_AUDIT.md` saved.
- Code-map validation accepts repo-relative files and globs only; absolute paths, `..` segments,
  escaping links, and glob matches that resolve outside the repo are rejected.
- The generated GPU optimization loop is command-driven rather than Triton/PyTorch-specific. Hardware
  profiling should emit greppable NCU/SOL or project counter lines that `profile` can parse, while
  `hypothesis`, `breaking-point`, and `plan-round` record evidence-backed investigation state and
  per-round worker artifacts for agents, branches, or worktrees.
- Optimization attempts treat malformed benchmark evidence as a measured failure: with
  `--auto-revert`, missing or invalid primary metrics are recorded in `results.tsv` and the captured
  patch is reversed. Intent-to-add new files are reset from the index after reversal so the next
  attempt starts clean. Profiler/counter gaps should be recorded with `profile --tool-gap`.
- The generated Nsight Systems smoke script treats `.nsys-rep` as the primary profiling artifact and
  probes the installed `nsys stats` reports/formats before reading summaries, so generated projects do
  not rely on stale report names such as `summary` or unsupported formats such as `text`.
