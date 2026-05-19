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
- `skills/cpp-cuda-vulkan-studio/scripts/run_viewport_session_smoke.py`

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
  The strict closeout command is `scripts/check_code_map_drift.py --require-enabled --strict-review`.
  It fails when changed source/header/shader/script/docs paths are not covered by a manifest route,
  and it blocks unreviewed source changes that did not touch map files. The worker must resolve that
  signal itself before staging by updating `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` and the matching
  `docs/SUBSYSTEMS/*.md`, launching the code-map sidecar, or rerunning with
  `--reviewed-no-map-change` only after semantic review. Its drift and no-map-touch review output
  also prints the guarded sidecar helper shape,
  `agent-tmux codex-code-map-sidecar <repo> <anchor> [focus]`, when map maintenance may need a
  bounded sidecar instead of remaining prose or a user prompt.
- Generated README and architecture-index guidance describe the optional code-map sidecar lane for
  long-running or high-churn enabled-map work. The sidecar must be code-map-only, must read a fixed
  Rewind checkpoint, temporary git anchor, commit, isolated worktree copy, or archive snapshot, and
  must return patch output or map-file replacements instead of editing the original worker's live
  worktree while source work continues. The original worker remains responsible for merging the map
  update and rerunning drift and validation against the current tree before the verified slice commit.
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
- Generated GUI/windowed validation docs require OSTM-first automated scenario, smoke, screenshot,
  and proof execution when OSTM is available. If OSTM is unavailable, agents use project smoke
  scripts or launcher wrappers with offscreen/background managers and state that OSTM evidence is
  unavailable. Manager-submitted scripts should use absolute paths or explicit working directories so
  invocation-context failures are not confused with app regressions.
- Generated GUI/windowed validation docs now distinguish launch smoke from interaction proof:
  UI-heavy tools need scenarios for real control clicks, selection latency, viewport/canvas
  pointer-mapping, device-pixel-ratio handling, committed hit/edit points, and fresh visual evidence
  before agents claim GUI fixes work.
- Generated validation docs require user-reported bug fixes to start from a reproduced before state,
  capture comparable after evidence, route visible GUI/windowed scenarios through Sonar and
  OSTM/project launchers when available, use Rewind checkpoints as rollback anchors for speculative
  GUI probes, and reject fixed claims when before/after artifacts are identical, self-confirming,
  backend-only for a visible bug, or narrower than the reported symptom.
- Generated viewport-session docs now require stroke-like visible bugs to use a human-input UI
  session through the real viewport/canvas/widget event path. Reports must compare requested pointer
  path to committed hit/edit path or affected coverage and directly assert reported
  material/overlay/product-surface issues; generic revision/checksum deltas, nonblank screenshots,
  product scorecards, backend endpoints, and one-point dab smokes are only supporting evidence.
- Generated validation docs now require visible closeout dispositions for each user-named product
  concern. Semantic path coverage, changed vertices, or absence of a debug overlay cannot close
  broader concerns about live stroke direction, cursor-hit feel, viewport shading quality, or
  donor-matched material appearance without matching screenshots/readback and a resolved status.
- Generated validation docs now require agents to state when they are UI-blind on a visible bug and
  stop converting the report into harness-only work. After a blocked proof-route attempt, the next
  step must be a bounded app-side fix with a visible-proof caveat, one repaired observation route,
  minimal manual visible evidence, or an explicit stuck report.
- Generated validation docs now require donor realignment after two focused attempts or roughly 20
  minutes without direct symptom improvement on visible bugs, artist-tool interactions, viewport hit
  paths, renderer/sim behavior, or domain algorithms. Agents must reopen code-map and donor routes,
  record failed hypotheses and keep/revert decisions, and define the next smallest proof before
  another local patch.
- Generated app guidance requires agents to verify the exact user-facing launch command when they
  provide or change it; offscreen smoke alone is not enough launch evidence.
- Exact launch-command verification must prove the human-visible app window, not only a process or
  offscreen screenshot: agents must match the app window by process/class/title, reject terminal-title
  false positives, read mapped/focus/workspace/geometry state, poll the control harness, and cleanly
  stop the launched instance.
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
- Generated interactive projects include a viewport-session testing scaffold: runtime host adapter
  contracts, fake-host smoke coverage, `scripts/run_viewport_session_smoke.py`, ignored
  `artifacts/viewport-sessions/` outputs, and docs for replacing the fake host with app-owned
  record/replay of real UI and viewport interactions.
- Template docs tell agents to commit each coherent verified implementation slice before moving to
  the next milestone while keeping generated build outputs, screenshots, profiler captures, logs, and
  temporary verification artifacts out of git unless the project intentionally tracks them.
- Generated-project commit guidance allows only `Commit-Origin: agent-slice` and
  `Commit-Origin: user-requested` so autonomous agent slice commits and explicit user-requested
  commits stay distinguishable in git history without provider-name values such as `codex` or
  `claude`.
- New-project scaffolding is Vulkan-only by default. `scaffold_gpu_cpp_project.py --gpu-lane vulkan`
  omits CUDA files, CMake presets, validation docs, runtime helper scripts, and code-map routes.
  CUDA-capable scaffolds require the explicit `--gpu-lane cuda` or `--gpu-lane cuda-vulkan` choice so
  agents do not mix CUDA into a Vulkan project by accident.
- `validate_studio_backbone.py` is lane-aware. It auto-detects CUDA-capable scaffolds from CUDA
  files/options, accepts clean Vulkan-only scaffolds, and can be pinned with `--gpu-lane` in tests.
