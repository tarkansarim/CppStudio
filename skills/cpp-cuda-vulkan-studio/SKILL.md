---
name: cpp-cuda-vulkan-studio
description: "Create, audit, or upgrade native C++ GPU project infrastructure and maintained code maps for Vulkan-first, CUDA, or explicit CUDA/Vulkan interop lanes: app+library layout, CMake presets, CTest labels, Vulkan/shader tooling, sanitizer/profile lanes, GPU optimization loops, GPU CI, validation scripts, agentic control harnesses, and donor routing. Use for C++ GPU/CUDA/Vulkan repos, initial project planning, code-map requests, build/test/profiling standardization, custom CUDA/Vulkan work, native C++ GUI/HUD/editor UI choices, local HTTP/curl/MCP app controls, or donor selection for graphics/renderers, assets, WebGPU/OpenXR, path tracing, AI runtimes, neural 3D, grooming/fur, DCC, volumes, animation, materials, CAD, simulation, CUDA, Vulkan, or cross-backend GPU code. For big initial planning or 'what stack should we use' questions, use cppstudio-project-planner first, research first, then ask for Plan mode."
---

# C++ CUDA Vulkan Studio

Use this skill when a native C++ GPU, C++/Vulkan, C++/CUDA, or mixed CUDA/Vulkan repo needs a repeatable professional development backbone or maintained code map, not a one-off local build. There is no separate CppStudio code-map skill; the code-map protocol lives here. This skill coordinates the more specific global skills instead of replacing them.

## Initial Planning Gate

For a substantial new project, brainstorm, or first big application plan with unresolved template,
GUI/HUD, agentic control harness, input-device, Vulkan/CUDA lane, donor, web-check, code-map,
dependency, or validation choices, do a pre-plan research pass before asking the user to switch to
Plan mode or asking decision questions.

Minimum pre-plan research pass:

- Open `cppstudio-project-planner` immediately when available; do not rely on this top-level skill
  body alone for substantial project intake. Also open `references/project-archetypes.md` and the
  smallest matching donor-router/category files.
- For GUI/HUD/editor choices, open `native-cpp-gui-hud` and its GUI option matrix, then verify
  current upstream official docs/repos or visual pages before ranking options.
- For interactive apps/tools/viewers/simulators, open `agentic-control-harness` and plan a local
  control surface so agents can launch, drive, inspect, screenshot, and troubleshoot the app before
  asking the user for routine manual testing.
- For simulation, renderer, SDK, hardware, or "best/current/ceiling" claims, web-check official
  upstream repos, standards docs, vendor docs, papers, or primary project docs.

The first visible response after that research should be a concise **Pre-Plan Research Brief**:

- choices discovered
- source/visual links for GUI options
- agentic control harness default and any real opt-out reason
- donor categories/profiles opened
- web/current sources checked
- clear recommended default and alternatives

Then ask the user to switch to Plan mode before implementation:

```text
Please switch to Plan mode before implementation so I can ask the project-shaping questions. I need
to lock down the template, GUI/input stack, GPU lane, agentic control harness, donor routes, web
checks, code-map choice, and validation plan before files are created.
```

This rule applies even if `cppstudio-project-planner` is not listed in the current session. If the
current turn explicitly says the session is already in Plan mode, still do the pre-plan research
brief before calling any question UI. If Plan mode is unavailable or the user says to continue without
it, ask no more than three blocking questions at a time and do not scaffold until the critical choices
are clear.

When asking the user to choose a GUI/HUD/tool UI stack, links must be visible at decision time. Before
calling any interactive question UI such as `request_user_input`, show a compact GUI option table with
source/docs and visual inspection links. Also put a compact URL in each option description when the
question UI allows it.

## Agent Mindset

When this skill is active, work like a native C++ GPU systems engineer:

- Hard rule: before touching code, do not rely on training data or intuition as the source of truth.
  First open the relevant local skills, the target repo's maintained code map when enabled, and the
  smallest matching donor-library route/category/profile. State the skill and donor sources used
  before implementation. If no donor route fits, stop and do focused donor or upstream research
  before designing the code.
- Treat Vulkan as an explicit-lifetime API. Resource ownership, synchronization, image layouts, queue
  ownership, descriptor lifetime, command-buffer reuse, and frames-in-flight must be designed
  deliberately.
- Keep the active lane disciplined. Prefer Vulkan for unspecified reusable GPU/3D/realtime work, keep
  CUDA separate unless the user chooses it or the requirements force it, and document any deliberate
  CUDA/Vulkan interop boundary.
- Do not silently downgrade the work to get a green run. If CMake, CUDA, Vulkan SDK tools, shader
  compilation, validation layers, GPU selection, profilers, or tests fail, surface the failure and fix
  the root cause when it is in scope.
- Inspect before editing. Read the build graph, presets, target ownership, shader or kernel paths,
  dispatch/render loop, and direct callers before changing native GPU infrastructure.
- When building or validating an existing repo, use the repo-declared commands first: CMake presets,
  project scripts, maintained validation docs, or code-map build/preset routes. Do not invent build
  directories such as `build_linux` or `build/Release` unless the repo explicitly declares them. If a
  guessed command fails, treat that as a process miss, reopen the repo build docs/presets, and rerun
  the documented command before continuing.
- Before major C++/GPU edits, name the likely failure modes: synchronization or lifetime bugs, wrong
  device/backend lane, missing validation/profiling evidence, portability breaks, and
  dependency/license mistakes.
- Before risky GPU refactors, broad CMake/build-system changes, backend rewrites, synchronization
  changes, or target-project deployment/install script edits, create or confirm a recent git commit
  so rollback is exact and cheap. If the target repo has no suitable recent commit, ask before
  proceeding with high-risk edits.
- Treat git commits as part of the normal production workflow, not only as end-of-project cleanup.
  After each coherent implementation slice or milestone is verified, commit the source, docs,
  harness, test, and code-map updates before continuing into the next slice, unless the user or repo
  policy explicitly says not to commit. Before committing, inspect `git status`, keep user-owned
  unrelated changes out of the commit, exclude build outputs, profiler traces, screenshots, temp
  artifacts, and generated junk unless the repo intentionally tracks them, and run a whitespace or
  staged-diff hygiene check such as `git diff --check` or `git diff --cached --check`. If the repo
  has no git history, no git identity, ambiguous dirty state, or approval is required for the git
  write, surface that clearly instead of silently skipping the commit. Add a commit trailer that
  identifies why the commit happened: use `Commit-Origin: agent-slice` for commits the agent creates
  as part of the verified-slice workflow, and `Commit-Origin: user-requested` when the user
  explicitly asked for that commit.
- Use evidence before claims. Builds, CTest labels, shader compilation, Vulkan validation,
  Compute Sanitizer, RenderDoc/Nsight captures, screenshots, image comparisons, and profiler output
  matter more than plausible explanations.
- For realtime rendering, viewport, simulation, XR, or GPU-performance work, measure frame time/FPS
  or profiler timings while implementing and verify the actual visual output.
- When a target app has an agentic control harness, use it as the first route for routine launch,
  feature driving, state/log readback, screenshots, and visual/UI troubleshooting before asking the
  user to manually test. If the missing evidence is a harness gap and fixing it is in scope, repair
  the harness instead of repeatedly handing small verification chores to the user.
- When you give, change, or rely on a user-facing desktop launch command, verify that exact command
  path in addition to offscreen smoke tests. For long-running GUI apps, acceptable evidence is that
  the exact command starts the intended process, the control harness responds, and a desktop window
  or captured screenshot is visible. Do not treat an offscreen smoke run alone as proof that the
  user's launch command works.
- Verify long-running desktop launch commands without blocking the agent on a foreground GUI
  process. Use a bounded non-blocking verification shape: start the exact launcher while capturing
  stdout/stderr, keep that launch alive while polling the control harness, confirm process and
  window/screenshot evidence, test duplicate-launch behavior when the launcher owns a fixed control
  port, then stop the app through its harness. Avoid transient-shell artifacts where a backgrounded
  GUI receives SIGHUP when the verification shell exits before probes finish.
- In shell launch wrappers that probe localhost control ports under `set -e`, explicitly capture and
  classify failed probe statuses. A normal connection-refused result for "no existing instance yet"
  must not terminate the launcher before it reaches the app binary, while a healthy existing instance
  should focus/reuse the window when that is the intended duplicate-launch contract.
- For GUI/windowed verification through offscreen or background managers, prefer the target repo's
  canonical smoke script or launch wrapper over ad hoc commands. Invoke manager-submitted scripts
  with absolute paths, or an explicit working directory when the manager supports it, even when the
  script is the canonical smoke; offscreen managers may not preserve the caller shell's current
  directory. Classify "script not found" manager-context failures as invocation issues rather than
  app failures.
- Stop verification once the agreed evidence threshold is met. Do not keep adding optional probes
  after build/test/map/harness/screenshot evidence already answers the user-facing question, unless a
  new failure or unresolved risk justifies the extra run.
- Be donor-first. Use the donor library for architecture, edge cases, tests, algorithms, and
  dependency choices before inventing a new subsystem; when no suitable donor exists, add donor
  research before designing the implementation.
- Do not treat "MVP", "scaffold", or "prototype" as permission to skip donor grounding for product
  shape. For native GPU tools, viewport type, editor layout, timeline/transport placement, graph or
  scene source of truth, solver architecture, render path, and validation surface must be checked
  against the relevant skills and donor/peer-tool references before code is written.
- Treat native C++ GPU brainstorming and architecture proposals as donor-grounded work, not just
  conceptual chat. Before making concrete solver, renderer, dependency, subsystem, or MVP-order
  recommendations, open the smallest relevant donor categories/profiles and state which guidance is
  donor-backed versus inference. If the prompt asks for current best choices, state-of-the-art,
  "ceiling", or rapidly moving GPU/tooling options, run an extensive web ceiling check against
  upstream or primary sources before ranking choices. Separate current leading approaches from
  legacy, teaching, or low-effort approaches, and prefer the best available option unless the user
  asks for a lighter route.
- For ambitious realtime simulation/graphics brainstorms, including fluid, fire, smoke, water,
  destruction, shatter, neural 3D, upscaling/reconstruction, XR, or renderer architecture that is
  likely to depend on current engines, SDKs, papers, samples, or hardware capabilities, run a real
  state-of-the-art web ceiling check even when the user only says "brainstorm." Use official upstream
  repos, vendor docs, recent papers, project docs, active samples, release notes, and adoption signals;
  then separate current-source evidence from local donor guidance and inference.
- Never copy study-only, incompatible-license, non-C++ reference-only, or backend-mismatched donor
  code into generated projects. Use those donors for concepts, then translate through the active
  Vulkan, CUDA, or explicit interop lane.
- Preserve user and project state. Managed markers may be replaced by this package, but project files,
  local rules, custom skills, and content outside managed marker blocks are user-owned.
- Produce usable infrastructure. Avoid stubs, toy-only scaffolds, disabled tests, placeholder kernels,
  or sample-only shortcuts unless the user explicitly asks for a throwaway prototype.
- Keep code maps lazy before activation and decisive after activation. Check
  `.cppstudio/code-map-state.json` first when present. When it says `enabled`, or when target
  repo instructions declare a maintained codebase map required, use the architecture index and
  manifest as the first navigation step before code changes: choose the subsystem route, read the
  matching subsystem doc, then inspect the files named by that route. Do not keep prompting when
  state says `declined`.
- Do not hand-author CppStudio code-map state or manifest schema in target repos. Use the bundled
  `scripts/bootstrap_code_map.py` flow to enable, decline, or audit maps, then run
  `scripts/validate_code_map.py --require-enabled .` when the map is expected to be active.
- Treat generated tool-probe artifacts as cleanup debt, not just ignore-file entries. If CMake
  probing or package discovery creates top-level `CMakeFiles/`, `CMakeCache.txt`,
  `cmake_install.cmake`, or similar generated files outside the chosen build directory, remove them
  before validation, review, or commit status. Build and artifact directories may be ignored, but
  probe junk should not sit in the source root.
- When working in a target repo other than CppStudio itself, treat that repo's `AGENTS.md`,
  codebase map, manifest, and repo-local skills as the subsystem routing authority. CppStudio supplies
  the native C++/GPU lane policy, backbone, validation, and donor routing around the target repo's map.

## Coordination

- Use `cppstudio-project-planner` before scaffolding or major architecture work when the project has
  unresolved template, authoring-model/source-of-truth, GUI/HUD, agentic control harness, GPU lane,
  donor, input-device, code-map, dependency, or validation decisions. For substantial project intake,
  do the pre-plan research pass first, show links and sources, then ask the user to switch to Plan
  mode before implementation and hand implementation back to this skill after choices are clear.
- Use `modern-cpp-cmake` for CMake target structure, source ownership, presets, CTest, and dependency wiring.
- Use `cuda-kernel-authoring` when adding or reviewing custom CUDA kernels or launch wrappers.
- Use `vulkan-compute-sync` when the project contains Vulkan compute, render, synchronization, descriptor, or frame-lifetime work.
- Use `native-cpp-gui-hud` when choosing, comparing, or integrating native C++ GUI/HUD/editor UI,
  viewport overlays, docking panels, transform gizmos, plotting, desktop app UI, runtime/game UI, or
  embedded web UI. When presenting GUI options, include links where the user can inspect how each GUI
  looks.
- Use `agentic-control-harness` when planning or implementing local controls that let agents launch,
  drive, inspect, screenshot, and troubleshoot native apps through HTTP/curl, CLI, or MCP-backed
  surfaces. For interactive apps, make this default-on unless the user opts out or the target is a
  headless library or security-sensitive product surface.
- Use available profiling or frame-debugging skills and local profiler tools only when the active environment exposes them and the user needs performance or capture evidence.
- Use `verification-before-completion` before claiming the generated or upgraded backbone is valid.

## Workflow

1. Before touching code, open the relevant skills and donor routes. Training data is not authority
   for CppStudio implementation decisions. Use `references/donor-library/agent-lookup.md` for broad
   or overlapping prompts, production overlays for VFX/game/native-infrastructure vocabulary, and
   category/profile files for the smallest concrete donor set. Record the sources used.
2. Inspect the target repo: `AGENTS.md`, `CMakeLists.txt`, `CMakePresets.json`, package manifests, `.github/workflows`, `cmake/`, `tests/`, `scripts/`, docs, `docs/CODEBASE_ARCHITECTURE_INDEX.md`, `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`, and `.cppstudio/code-map-state.json` when present.
3. For a greenfield repo, run `scripts/scaffold_gpu_cpp_project.py` from this skill and then adapt only project names and required dependency switches.
4. For an existing repo, run `scripts/apply_studio_backbone.py` against a temporary copy first unless the user explicitly wants direct modification.
5. For a greenfield scaffold with no `.cppstudio/code-map-state.json`, ask once whether to create a maintained codebase architecture map. State the benefits: faster cold starts, cleaner multi-agent routing, explicit subsystem ownership, and less repeated code reading. If the user already explicitly asked for a code map, architecture map, or future-agent map during project creation, treat that as acceptance and run `scripts/bootstrap_code_map.py --enable --force` after scaffolding because the template includes starter generated map files. If they decline, run `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked. Do not create `.cppstudio/code-map-state.json`, `docs/CODEBASE_ARCHITECTURE_INDEX.md`, or `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` by guessing the schema; use the bootstrap script and validator.
6. For an existing project with no `.cppstudio/code-map-state.json`, treat code-map enablement as a readiness protocol. Run `scripts/bootstrap_code_map.py --audit-existing` first and summarize its stdout: structure findings, nonstandard layout risks, and the estimated cleanup cost. Do not write `docs/CODEMAP_BOOTSTRAP_AUDIT.md` unless the user wants a saved audit; then rerun with `--write-audit`. Ask whether the user wants to restructure first, preserve the current layout and document exceptions, or decline the map. Do not run `--enable` until the user chooses either restructure-complete or preserve-as-is. If generated map files already exist, use `--enable --force` only after the user accepts replacing those generated map files.
7. When `.cppstudio/code-map-state.json` says `enabled`, or when repo-local instructions declare a maintained codebase map required, read the target repo's `docs/CODEBASE_ARCHITECTURE_INDEX.md` and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` before code changes. Use that map to select the subsystem doc and primary paths for the change, then keep the map updated when ownership, data flow, GPU backend boundaries, build/test lanes, validation, CI, or public runtime behavior changes. If the user asks about a code map mid-project, explain it, run the existing-project readiness protocol, and wait for acceptance before running `scripts/bootstrap_code_map.py --enable`; if generated map files already exist, use `--force` only after the user accepts replacing them. For large existing repos, use parallel subsystem audits when delegation is explicitly available.
8. Preserve any existing package manager or project-specific dependency policy. Do not introduce vcpkg, Conan, containers, FetchContent, or submodules unless there is a concrete reason.
9. Keep CUDA and Vulkan optional through CMake cache options. For unspecified new GPU/3D/realtime/XR/cross-platform C++ projects, recommend and scaffold Vulkan-first: the normal `dev` preset is Vulkan-only, CUDA stays off unless the user explicitly chooses the CUDA lane or the requirements force CUDA.
10. Do not mix CUDA into a Vulkan-chosen or Vulkan-assumed project by default. Use CUDA only for explicit CUDA/Vulkan interop, CUDA-specific compute, NVIDIA-only libraries, CUDA graphs, or custom CUDA kernels. When the user explicitly chooses CUDA, Vulkan may be added for presentation, realtime visualization, XR, swapchain/display work, or interop if the boundary is documented.
11. For new Vulkan template work, target Vulkan 1.3 with Vulkan-Hpp RAII, synchronization2, dynamic rendering, GLSL compiled by `glslc`, SPIR-V validation by `spirv-val`, and optional portability-enumeration support for MoltenVK-style platforms.
12. Register tests with CTest labels so quick, GPU, GUI, Vulkan, CUDA, shader, compute, render, validation, perf, and nightly lanes can be selected independently.
13. For GPU performance work, use the generated optimization loop when available. Start from
    the target project's `docs/GPU_OPTIMIZATION_LOOP.md`; when working in this source package before
    that doc has been copied, use the bundled template copy at
    `assets/app-library-template/docs/GPU_OPTIMIZATION_LOOP.md`. Create a representative target table
    with explicit success criteria so agents do not chase isolated microbenchmarks, record a fixed
    baseline, run hardware profiling such as Nsight Compute/NCU, Nsight Graphics GPU Trace, vendor
    tools, timestamp-query summaries, or project counters before edits when counters are available,
    record the tool gap when they are not, use roofline/SOL diagnosis when metrics are available, log
    evidence-backed hypotheses before edits, optionally run breaking-point search for workload
    limits, test one focused hypothesis at a time, run two or more validation passes before
    benchmarking an attempt, keep only correct improvements, revert rejected or divergent attempts,
    use `plan-round` for beam-style parallel worker slots when exploring multiple bottlenecks, use
    `next` for move-on decisions, and generate a consolidation report before claiming speedups.
14. Treat profiling as evidence only when the report is readable and the command matches the workload being claimed.
    For Nsight Systems stats readback, prefer the bundled `scripts/run_nsys_smoke.sh` because it
    probes the installed report and format surface. If writing a manual `nsys stats` command, inspect
    `nsys stats --help-reports` and `nsys stats --help` first, use explicit reports such as
    `vulkan_api_sum,osrt_sum,nvtx_sum` or `cuda_api_gpu_sum,cuda_gpu_kern_sum,osrt_sum,nvtx_sum`,
    include `--force-export=true`, and do not use legacy `--report summary` or unsupported
    `--format text` assumptions.
15. Before greenfield scaffolding, major backbone edits, or native GPU architecture brainstorming,
    read `references/project-archetypes.md` and pick the closest lane: Vulkan app, CUDA library,
    CUDA+Vulkan combined/interop app, native GUI/HUD/editor UI, AI runtime, neural 3D viewer, grooming/fur tool,
    glTF/runtime asset viewer, renderer backbone/runtime mesh pipeline, DCC scene pipeline,
    volume/voxel renderer, animation runtime, material pipeline, CAD geometry tool,
    3D/physics/GPU simulation tool, or XR app.
16. When borrowing patterns, APIs, examples, or dependency ideas from external 3D/AI/GPU projects,
    or when brainstorming native GPU architecture that will recommend solvers, rendering paths,
    dependencies, subsystem boundaries, or MVP order, use the nested donor router before giving the
    recommendation. Read `references/donor-library/README.md` for policy; when the prompt uses VFX
    studio, game studio, or native engineering infrastructure vocabulary, use the production overlays
    under `references/donor-library/production/`; use `references/donor-library/agent-lookup.md`
    when the prompt is broad, overlapping, or exploratory; then open the smallest matching category
    set, choosing one primary category first when possible, and only the donor profiles those
    categories name. Treat donors as domain references first: a CUDA, Vulkan, OpenCL, DirectX, CPU,
    or DCC donor can still guide another target backend. Keep the selected implementation lane fixed,
    translate backend-specific details through the active lane skill, and keep permissive donor code,
    dependency candidates, and study-only references separated. If the prompt asks for the best
    current choices, state of the art, ceiling, or recently moving GPU/tooling options, web-check
    upstream or primary sources before ranking options. For broad realtime simulation/graphics
    brainstorms that mention fluid, fire, smoke, water, destruction, shatter, neural 3D,
    upscaling/reconstruction, XR, or renderer architecture, do the web ceiling check even if the user
    did not use "current" or "best."
17. Do not route design-only, frontend-only, storyboarding, generic image/video, generic product-AI UI, plain text rendering, or ordinary data import requests through this skill unless the user explicitly asks for native C++ GPU implementation, C++/CUDA/Vulkan infrastructure, or donor-reference selection.

For long-running target-project implementation, repeat this rhythm between slices:

1. Ground the slice in skills, code map, donors, and any needed current-source research.
2. Implement the smallest coherent production slice.
3. Verify with the target repo's build, tests, harness, screenshot, or profile evidence appropriate
   to the change.
4. Clean generated probe junk from the source root, review `git status`, keep unrelated user changes
   out, check diff hygiene, and commit the verified slice with the appropriate `Commit-Origin`
   trailer.
5. Continue to the next slice only after the commit is in place, or after clearly reporting why a
   commit was intentionally skipped.

## Existing Project Code Map Readiness Protocol

Before enabling a maintained code map for an existing repo, confirm the repo can support durable map maintenance:

1. Run `scripts/bootstrap_code_map.py --audit-existing` and review its stdout. Save it with `--write-audit` only if the user wants `docs/CODEMAP_BOOTSTRAP_AUDIT.md` recorded.
2. Review build entrypoints, source/include ownership, tests, validation scripts, CI, docs, shader/CUDA/Vulkan ownership, generated build artifacts, and dependency/vendor boundaries.
3. Classify cleanup cost as small, medium, or large. Tie the estimate to concrete findings, not general taste.
4. Present the user with three choices: restructure first, keep the current layout and document exceptions in the map, or decline the map for now.
5. If the user chooses restructure first, create or confirm a recent git commit, propose a focused restructuring plan, validate the project after the restructure, and only then enable the map.
6. If the user chooses preserve-as-is, enable the map and record the nonstandard layout explicitly in the relevant subsystem docs. If generated map files already exist, rerun enablement with `--force` only after the user accepts replacing them.
7. If the user declines, run `scripts/bootstrap_code_map.py --decline` and do not prompt again unless asked.

## Bundled Assets

- `assets/app-library-template/`: full app+library C++/Vulkan-first/CUDA-optional starter layout with CMake presets, CTest, sample C++ library/app, Vulkan default targets, explicit CUDA and combined CUDA+Vulkan build lanes, docs, clang tooling, and GitHub self-hosted GPU CI. Real CUDA/Vulkan external-memory or semaphore interop requires project-specific additions beyond the combined build preset.

## Bundled References

- `references/donor-library/`: curated donor-source library for Vulkan foundation tooling, glTF/runtime assets, WebGPU/WebGL, native GUI/HUD/editor UI, renderer backbones, path tracing, engine architecture, runtime mesh pipelines, graphics, rendering, geometry, 3D/physics/GPU simulation, AI runtimes, ML compilers, CUDA kernels, neural 3D, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD, XR, and native engineering infrastructure. Donor backend signals describe the upstream implementation, not a restriction on target lanes. Start with `references/donor-library/README.md`; for VFX studio, games, or native infrastructure vocabulary use `references/donor-library/production/`; for broad or ambiguous donor requests use `references/donor-library/agent-lookup.md`, then load the smallest category set needed for the active task.
- `references/project-archetypes.md`: lane-selection guide for CUDA-only, Vulkan-only, CUDA+Vulkan interop, native GUI/HUD/editor UI, AI runtime, neural 3D, grooming, glTF/runtime assets, renderer backbone/runtime mesh pipeline, DCC, volume, animation, material, CAD, 3D/physics/GPU simulation, and XR projects.

## Bundled Scripts

- `scripts/scaffold_gpu_cpp_project.py`: create a new project from the template.
- `scripts/apply_studio_backbone.py`: copy backbone files into an existing repo without overwriting by default.
- `scripts/validate_studio_backbone.py`: check that required backbone files are present and, with `--integration`, that CMake/CTest register expected labeled tests.
- `scripts/check_dev_tools.sh`: verify compilers, CUDA, Vulkan, shader, and optional profiler tools.
- `scripts/select_idle_gpu.sh`: choose an idle NVIDIA GPU, optionally constrained by `GPU_ALLOWED_INDICES`, using utilization and display-server subtraction.
- `scripts/run_compute_sanitizer.sh`: run a command or GPU CTest preset under Compute Sanitizer.
- `scripts/run_vulkan_validation.sh`: run a Vulkan command or validation CTest preset with Khronos validation enabled.
- `scripts/dump_vulkan_capabilities.sh`: capture `vulkaninfo` summary and text reports for loader/ICD diagnostics.
- `scripts/run_nsys_smoke.sh`: run an app/probe under Nsight Systems, discover supported stats
  reports/formats from the installed `nsys`, and read back lane-appropriate explicit reports with
  forced SQLite export.
- `scripts/run_gpu_optimization_loop.py`: initialize, baseline, hardware profile, log hypotheses, search breaking points, plan beam-style rounds, attempt, keep/revert, orchestrate, and report evidence-gated GPU optimization sessions.
- `scripts/format_check.sh`: run clang-format in check-only mode.
- `scripts/tidy_check.sh`: run clang-tidy against a compile database in check-only mode.
- `scripts/bootstrap_code_map.py`: audit existing repo readiness, enable, or decline the opt-in CppStudio codebase map for a target repo.
- `scripts/validate_code_map.py`: validate enabled or declined CppStudio code-map state and manifest links.

## Acceptance

For a new scaffold, verify:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

For an existing target repo, prefer the repo's own documented validation path and preset names over
the scaffold defaults above. Check `CMakePresets.json`, validation docs, target scripts, and the
maintained code-map build subsystem before choosing commands.

For this skill itself, verify:

```bash
${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py ${HOME}/.codex/skills/cpp-cuda-vulkan-studio
```
