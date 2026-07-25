# CppStudio Agent Notes

This repo is the canonical working source for reusable Codex infrastructure around future
C++/CUDA/Vulkan development.

## Required Orientation

- This is not a generated sample project. Do not treat it as a C++ app/library repo.
- The main artifact is the user-level Codex skill source at `skills/cpp-cuda-vulkan-studio/`.
- If available in the session, use the project skill `cppstudio-repo-onboarding` when starting
  work in this repo.
- The installed user-level copy at `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` is a
  deployment target, not the source of truth.

## Source Of Truth

- Edit `skills/cpp-cuda-vulkan-studio/` in this repo.
- For important user rules, prerequisites, corrections, and supervision constraints that must
  survive compaction, use the bundled `important-instruction-ledger` source skill and keep
  `docs/agent-context/IMPORTANT_USER_INSTRUCTIONS.md` current before continuing related work.
- Use `docs/CODEBASE_ARCHITECTURE_INDEX.md` and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` as the
  maintained code map for this repo.
- Before changing repo files, use the maintained code map to choose the matching subsystem doc and
  primary paths for the work.
- Publish normal user-level Codex installs with `./scripts/rollout_to_codex.sh`.
- Use `./scripts/sync_to_codex.sh` only for dry runs, diagnostics, or an explicitly scoped
  single-skill sync.
- Do not hand-edit `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` as the long-term source.
- Do not move private app, local workstation, or other project-specific skills back into user-level
  Codex from this repo.

## Donor-First Code Rule

- For CppStudio skill, planning, GUI/HUD, project-template, or donor-routing work, training data is
  never enough before touching code. First read the relevant repo skill, maintained code map route,
  and the smallest matching donor-library route/category/profile. Then state which sources are
  grounding the change.
- If no matching donor route exists, record that gap and do focused research before designing or
  implementing the missing behavior. Do not fill the gap from memory and proceed as if it were
  donor-backed.
- Product-shape decisions for native GPU tools, especially viewport type, timeline/transport
  placement, editor layout, authoring model, solver architecture, and GUI stack, require donor or
  peer-tool evidence before implementation.

## Supervised Worker Interrogation

- When supervising a tmux, subagent, or other worker and the worker makes, skips, or rejects a
  decision for unclear reasons, interrogate that worker before claiming the cause, patching skills, or
  deciding no CppStudio fix is needed.
- Ask for the exact skill routes, donor routes, web/upstream sources, decision criteria, gaps, and
  verification commands that led to the behavior. Treat the answer as evidence to check against the
  transcript and files, not as authority.
- If the worker is unreachable, state that directly and inspect the transcript, project files, and
  CppStudio rules before drawing conclusions. Do not infer motives or root causes from memory.
- During supervised production lanes, continuously watch for worker behavior that points to a
  reusable CppStudio gap: skipped donor/profile routing, weak or mismatched verification, stale
  binaries, bad OSTM/session evidence, ignored code-map maintenance, unsupported helper commands,
  premature closeout, or drift from the approved slice. When such a signal appears, preserve the
  evidence, interrogate the worker if needed, and fix CppStudio or follow user-level cross-repo
  routing instead of treating it as a one-off worker mistake.

## Vulkan-Leaning Defaults

- If the user asks for a new GPU, 3D, rendering, realtime, simulation-visualization, XR, or
  cross-platform C++ project and does not specify CUDA or Vulkan, recommend Vulkan before the project
  starts because it gives the project an easier path to cross-platform and cross-vendor hardware
  compatibility.
- If the user does not choose after that recommendation, proceed with a Vulkan-first plan and state
  the assumption. Do not stop solely to ask whether they meant CUDA unless the requirements clearly
  imply custom CUDA kernels, NVIDIA-only libraries, or CUDA-specific deployment.
- When Vulkan is chosen by the user or assumed by default, keep the project Vulkan-only by default:
  do not add CUDA, CUDA interop, CUDA tests, CUDA runtime requirements, or CUDA donor routing unless
  the user explicitly asks for CUDA/Vulkan interop or the requirements force a CUDA-specific compute
  path.
- When the user explicitly chooses the CUDA lane, Vulkan may be mixed in when it is needed or clearly
  more convenient for presentation, realtime visualization, graphics, XR, swapchain/display work, or
  CUDA/Vulkan interop. State why the mixed lane is justified and keep the CUDA/Vulkan boundary
  explicit in build options, tests, and documentation.
- When both Vulkan and CUDA are plausible, document and route the Vulkan path first, then keep CUDA
  as a separate alternative lane, not as something automatically mixed into the Vulkan plan.
- For reusable 3D, rendering, realtime visualization, XR, or cross-vendor GPU work, frame the
  default route as Vulkan-first when requirements do not force an NVIDIA-only path.
- Prefer Vulkan-oriented donors, validation, shader tooling, synchronization notes, and CTest labels
  first for graphics/realtime tasks. Escalate to CUDA donors first only for custom CUDA kernels,
  CUTLASS/cuBLAS/cuDNN/TensorRT-style integrations, CUDA graphs, or explicitly NVIDIA-only targets.
- Keep CUDA support intact. Do not remove CUDA options, CUDA tests, CUDA donors, or CUDA companion
  skill links just to make the package feel more Vulkan-oriented.
- Keep the global skill generic: Vulkan bias belongs in reusable routing and ordering, not in
  project-specific rules for a single app.

## Validation

- Run `python3 scripts/validate_code_map.py . --require-enabled` after edits that affect CppStudio
  subsystem ownership, routing, generated template behavior, validation, rollout, public docs, CI, or
  changelog policy.
- Run `./scripts/validate.sh` after edits to skill text, scripts, metadata, or sync behavior.
- Run `./scripts/validate.sh --full` after edits to:
  - `assets/app-library-template/`
  - scaffolding or apply scripts
  - CMake presets/modules
  - generated-project validation behavior
- Before pushing validation-affecting changes, run the GitHub workflow-equivalent local gate, not
  only `validate.sh` or rollout:
  `bash -n scripts/*.sh skills/cpp-cuda-vulkan-studio/scripts/*.sh && shellcheck scripts/*.sh skills/cpp-cuda-vulkan-studio/scripts/*.sh && PYTHONPYCACHEPREFIX=/tmp/cppstudio-pycache python3 -m py_compile scripts/*.py skills/cpp-cuda-vulkan-studio/scripts/*.py && python3 scripts/validate_donor_library.py skills/cpp-cuda-vulkan-studio/references/donor-library --reference-root skills/cpp-cuda-vulkan-studio/references && python3 scripts/validate_trigger_matrix.py research/donor-library/trigger-matrix.json --repo-root . && VALIDATOR=$PWD/scripts/quick_validate_skill.py CPPSTUDIO_FULL_CUDA_ARCHITECTURES=75 CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS=1 ./scripts/validate.sh --full`.
  This gate is required after edits to shell scripts, Python validators, CI/workflow files,
  generated templates, CMake/toolchain behavior, package manifests, donor validation, trigger
  validation, or any previous push that failed GitHub validation. Rollout validation is an install
  proof; it is not a substitute for this CI gate.
- After adding or changing skills, skill descriptions, donor categories, donor profiles, donor routing,
  or README donor inventories, run a sub-agent trigger lane before close-out. Use multiple realistic
  prompts that should trigger the changed skill/routing, verify the agents select the expected skill and
  donor profiles, then fix any ambiguity they find before committing.
- The rollout script validates the router package, removes known former top-level CppStudio skills,
  and updates the user-level relay. The sync script validates only the router package.
- If validation fails because of a real script/template issue, fix the repo copy first, then rerun
  rollout or the explicitly selected sync.

## Sync Behavior

- `./scripts/sync_to_codex.sh` publishes this repo's skill copy to user-level Codex.
- It uses `rsync --delete` by default so the installed skill exactly matches this repo.
- Pass `--dry-run` to preview changes.
- Pass `--no-delete` only for diagnostics; normal publishing should keep delete enabled.
- `./scripts/watch_to_codex.sh` continuously validates and syncs after file changes.
- `./scripts/rollout_to_codex.sh` validates and syncs the one canonical router package, removes known
  former top-level CppStudio skills, and verifies source/target parity.

## Safe Editing Rules

- Keep reusable policy generic. Do not add private-app-only, local-workstation-only, or machine-only
  workflow rules to `skills/cpp-cuda-vulkan-studio/`; those belong in project-level skills.
- Keep the maintained code map in sync. If a change affects source skill routing, donor-library
  routing, generated-project template behavior, validation/sync/rollout scripts, companion snippets,
  research provenance, public docs, CI, or change-history policy, update the matching
  `docs/SUBSYSTEMS/*.md` doc and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` in the same work stream.
- If this repo installs user-level `AGENTS.md` content, merge or append only the tiny marked
  CppStudio relay block. It should only tell agents to load `cpp-cuda-vulkan-studio` for native
  C++ GPU/realtime/code-map/Vulkan/CUDA work; lane policy stays inside the skill. Content inside the
  marked relay block is managed by this repo and may be replaced on reinstall; content outside the
  markers is user-owned and must be preserved. Relay targets must be named `AGENTS.md` and must not
  be symlinks.
- Preserve intentional template placeholders such as `{{PROJECT_NAME}}` and `{{CPP_NAMESPACE}}`.
- Do not commit generated temp projects, build directories, profiler traces, or Python
  `__pycache__` files.
- Prefer updating the reusable scripts over copying long command sequences into docs when behavior
  must stay deterministic.
- Keep research notes under `research/` and reusable skill instructions under
  `skills/cpp-cuda-vulkan-studio/`; do not mix process notes into installed user-level skill files.
- Before pushing to remote, update `CHANGELOG.md` with a concise entry for tracked user-visible
  changes, validation/CI changes, generated-template changes, donor-library changes, or install/sync
  behavior changes.
- Also update README Recent Commit Highlights as the front-page changelog when a pushed commit
  changes setup, routing, generated projects, validation, donor-library behavior, public docs,
  install, release, or sync behavior.
- Do not rely on a chat promise that future pushes will remember these docs. Before committing or
  pushing from this repo, explicitly inspect the staged diff and report whether `CHANGELOG.md` and
  README Recent Commit Highlights are included and readable, or why the change is non-qualifying. If
  either qualifying change-history surface is missing or the front-page changelog is unreadable,
  update it before the commit instead of promising to do better later.

## Close-Out

When finishing work here, report:

- files changed at the repo level
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether the GitHub workflow-equivalent gate passed before push when the change touched validation,
  CI, scripts, generated templates, package manifests, donor validation, or trigger validation
- whether `./scripts/rollout_to_codex.sh` was run for normal bundled installs, or which explicit
  single-skill `./scripts/sync_to_codex.sh` run was used and why
- whether the sub-agent trigger lane was run when skill/donor routing changed
- whether `CHANGELOG.md` was updated before any push to remote
- whether README Recent Commit Highlights was updated as a readable front-page changelog before any
  qualifying push to remote
- the exact reason if either change-history surface was not updated
- any installed-tool gaps, such as missing `clang-format` or `clang-tidy`

<!-- agent-self-improvement-doctrine:begin -->
## Accepted Self-Improvement Doctrine

- 2026-05-25T03:49:05Z [global] For donor-derived shader, material, or light parameter surfaces, CppStudio supervisor closeout must require a donor parameter inventory with source anchors and classify every artist-facing or runtime-significant donor parameter across UI, CLI/config, model/state, runtime payload, and validation readback; visible widget wiring proof alone is not parameter-surface closure. (source: self-improvement:user_correction:acad59bb360d5e49)
- 2026-05-31T20:42:44Z [global] CppStudio supervised parameter-surface closeout must treat transform/orientation controls as separate critical surfaces for lights, cameras, gizmos, emitters, colliders, probes, volumes, brush cursors, and other transform-owned UI; position, size, or intensity mutation does not prove rotation, aim, basis-vector, or orientation wiring, and reported rotate/aim/move/scale failures require direct before/after proof through the real UI/control handler into committed state and runtime/readback payload or explicit absent/hidden/deferred/blocked classification. (source: self-improvement:user_correction:00999cdab0138518)
- 2026-06-01T05:20:02Z [global] CppStudio control-surface closeout for transform-owned lights, cameras, renderers, shaders, and materials must prove user-facing behavior/output invariants such as aim, pivot stability, distance, enabled light set, shader/shadow payload, and receiver/hair luminance; state-vector equality alone cannot close user-reported lighting or viewport behavior bugs. (source: self-improvement:user_correction:ecd187f2ce9aa635)
- 2026-06-01T06:30:25Z [global] CppStudio supervisor closeout must treat a fresh user live report that the same UI/render/control surface still fails as proof invalidation. Reopen the slice and reconcile the exact user path; contradictory artifacts such as a light-on proof whose final readback has that light disabled are failed proof paths, not supporting evidence. (source: self-improvement:user_correction:0eb8ae93fa837dec)
- 2026-06-18T08:57:54Z [global] For CppStudio donor routing, standardized file formats, interchange formats, protocols, SDK schemas, and conformance suites are contract-level donor surfaces: official specs, API headers, source, examples, and tests define semantics even when code reuse is reference-only or dependency-bounded; Groom-discovered reusable gaps must be patched in CppStudio source and rolled out before resuming target implementation. (source: self-improvement:user_correction:4d5a7be8f0e9bf04)
- 2026-06-20T17:43:32Z [global] For CppStudio visual interaction proof on native GPU tools, before/held/in-flight/after evidence must prove untouched background, canvas, viewport, layer, and UI regions remain stable outside the acted-on region; route counters, changed-pixel counts, nonblank screenshots, FPS, or final-state stability cannot close a visible fix when captures show unrelated corruption such as black clears or alpha/composite failure. (source: self-improvement:user_correction:e98c856c6b0de402)
- 2026-06-20T21:16:54Z [global] CppStudio/Groom live interaction proof must use exact user-path recording or OSTM real-input held mouse behavior; synthetic helpers are diagnostics only unless they are the user path. (source: self-improvement:user_correction:b1ef7e77c9b73708)
- 2026-06-21T00:29:02Z [global] CppStudio native GPU renderer/viewport/grooming performance fixes must preserve the full-quality target by default: the first optimization phase is a full-fidelity stress baseline, with the entire target asset loaded/rendered as-is at full density and full quality while deliberately avoiding reduced-work tricks; LOD, decimation, lower samples/resolution, disabled lighting/shadows/scattering, cheaper primitives, proxy/cache/impostor paths, chunking/streaming, and idle/final-only updates are diagnostics or later explicit scalability choices, not the first optimization fix; diagnostic isolation must profile the full workload first, rank bottlenecks, temporarily disable unrelated expensive systems only to optimize the current top bottleneck, restore the full workload, and re-profile before moving to the next bottleneck; when high-FPS peers or cutting-edge expectations are named, require current peer/donor architecture research before source changes and close only with same-quality visual proof plus timing/profiler improvement on the full-groom target. (source: self-improvement:user_correction:f99b833b96bd0280)
<!-- agent-self-improvement-doctrine:end -->
