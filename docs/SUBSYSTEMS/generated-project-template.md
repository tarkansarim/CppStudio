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
- `skills/cpp-cuda-vulkan-studio/scripts/check_code_map_drift.py`

## Update When

- template files, CMake presets, docs, shader fixtures, runtime scripts, or CI files change
- scaffold or existing-repo apply behavior changes
- generated-project validation expectations change
- code-map template files, readiness audit behavior, or generated-project code-map behavior changes
- generated-project development rhythm changes, including verified-slice commit expectations or
  artifact exclusion guidance
- generated-project code-map drift-check behavior changes

## Current Portability Notes

- Vulkan template code should use Vulkan-Hpp forms that compile against Ubuntu packaged Vulkan-Hpp
  as well as newer SDK headers.
- Code-map enablement refuses existing generated map files without `--force` and writes the enabled
  state only after generated map files are replaced.
- Existing-project code-map audits print to stdout by default. Use `--write-audit` only when the user
  wants `docs/CODEMAP_BOOTSTRAP_AUDIT.md` saved.
- Existing-project code-map opt-in must be audit-evidence-first: agents run the non-destructive audit
  before asking restructure/preserve/decline questions, and they present concrete findings and cleanup
  cost before any route choice.
- Audit-backed CMake presets, canonical scripts, validation wrappers, or CI additions are pre-map
  infrastructure slices, not the code map itself. Agents should label them that way, verify them, and
  avoid bundling them into a code-map completion claim.
- After code-map enablement or major routing edits, agents need a read-only fresh-agent routing smoke
  when such testing is available; otherwise routing proof remains pending even if the validator
  passes.
- Enabled-map generated projects include `scripts/check_code_map_drift.py` as a pre-commit helper.
  It fails when changed source/header/shader/script/docs paths are not covered by a manifest route,
  forcing new routable files to be added to `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` and the matching
  `docs/SUBSYSTEMS/*.md` route before the verified slice is committed.
- Generated and bootstrapped code maps route GPU optimization docs through validation/CI canonical
  docs so a brand-new git repo can pass the drift checker before the first baseline commit.
- Existing-project code-map enablement installs missing repo-local `scripts/validate_code_map.py`
  and `scripts/check_code_map_drift.py` wrappers that forward to the installed CppStudio skill. It
  does not overwrite target-owned scripts with the same names; older maps without wrappers should
  use the installed skill script path and record the wrapper gap.
- Generated app-core routes include flat `src/*.cpp`, `src/*.h`, and `src/*.hpp` ownership in
  addition to `src/app`, `src/core`, and `include` so app-owned panel/controller/helper files at the
  source root are discoverable without one-file manifest entries.
- Code-map validation accepts repo-relative files and globs only; absolute paths, `..` segments,
  escaping links, and glob matches that resolve outside the repo are rejected.
- Code-map validation permits unmatched `primary_paths` globs so a route can declare ownership of
  optional future files such as flat UI panel headers without forcing placeholder files into a fresh
  scaffold.
- Code-map validation also treats manifest root `state` and `router_doc` as strict routing API fields:
  they must point to `.cppstudio/code-map-state.json` and `docs/CODEBASE_ARCHITECTURE_INDEX.md`.
- The generated GPU optimization loop is command-driven rather than Triton/PyTorch-specific. Hardware
  profiling should emit greppable NCU/SOL or project counter lines that `profile` can parse, while
  `hypothesis`, `breaking-point`, and `plan-round` record evidence-backed investigation state and
  per-round worker artifacts for agents, branches, or worktrees.
- Optimization attempts treat malformed benchmark evidence as a measured failure: with
  `--auto-revert`, missing or invalid primary metrics are recorded in `results.tsv` and the captured
  patch is reversed. Intent-to-add new files are reset from the index after reversal so the next
  attempt starts clean. Profiler/counter gaps should be recorded with `profile --tool-gap`.
- The generated Nsight Systems smoke script treats `.nsys-rep` as the primary profiling artifact and
  probes the installed `nsys stats` reports/formats before reading stats with explicit reports,
  `--format column` when supported, and `--force-export=true`, so generated projects do not rely on
  stale report names such as `summary` or unsupported formats such as `text`.
- The generated Vulkan validation wrapper owns validation-layer environment setup. When `VULKAN_SDK`
  is set, it exposes the SDK manifest and layer-library directories before running the wrapped
  command so a discovered layer manifest cannot later fail as an instance-creation layer-load error.
- Generated GUI/windowed validation docs tell agents to prefer project smoke scripts or launcher
  wrappers with offscreen/background managers, and to use absolute script paths or explicit working
  directories for manager-submitted scripts so invocation-context failures are not confused with app
  regressions.
- Generated app guidance requires agents to verify the exact user-facing launch command when they
  provide or change it; offscreen smoke alone is not enough launch evidence.
- Generated Vulkan validation docs distinguish loader/SDK availability from hardware-backed
  realtime viewport readiness. CPU/software Vulkan implementations such as llvmpipe or Lavapipe are
  diagnostic-only by default; realtime viewport preflights should prefer discrete then integrated
  GPUs and report a blocker when only CPU/software devices are visible.
- Long-running desktop launch verification should keep the app alive only for a bounded probe window:
  capture launcher logs, poll the control harness, confirm process/window evidence, test duplicate
  launch behavior for fixed control ports, and cleanly stop through the harness instead of blocking a
  terminal agent on a foreground GUI or letting a transient shell kill the app before probes complete.
- Generated app harnesses should make viewport/canvas/render-target captures settle on requested
  state before screenshot comparison. Prefer frame, revision, sequence, or fence readback evidence in
  capture responses so agents can distinguish fresh visible output from stale pixels.
- Generated app guidance should make agents inspect capture API timing before adding render waits:
  some captures render a fresh offscreen frame during the grab, while others copy the last presented
  frame and require pre-capture scheduling.
- Template docs tell agents to commit each coherent verified implementation slice before moving to
  the next milestone while keeping generated build outputs, screenshots, profiler captures, logs, and
  temporary verification artifacts out of git unless the project intentionally tracks them.
- Generated-project commit guidance uses `Commit-Origin` trailers so autonomous agent slice commits
  and explicit user-requested commits stay distinguishable in git history.
- New-project scaffolding is Vulkan-only by default. `scaffold_gpu_cpp_project.py --gpu-lane vulkan`
  omits CUDA files, CMake presets, validation docs, runtime helper scripts, and code-map routes.
  CUDA-capable scaffolds require the explicit `--gpu-lane cuda` or `--gpu-lane cuda-vulkan` choice so
  agents do not mix CUDA into a Vulkan project by accident.
- `validate_studio_backbone.py` is lane-aware. It auto-detects CUDA-capable scaffolds from CUDA
  files/options, accepts clean Vulkan-only scaffolds, and can be pinned with `--gpu-lane` in tests.
