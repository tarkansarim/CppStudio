# Validation Sync And Rollout

Owns CppStudio repo validation, CI-safe validation, syncing to user-level Codex, rollout to companion
skills, and watch-mode publishing behavior.

## Canonical Docs

- `docs/maintainer-guide.md`
- `docs/manual-install.md`
- `docs/package-integrity.md`

## Primary Paths

- `scripts/validate.sh`
- `scripts/sync_to_codex.sh`
- `scripts/rollout_to_codex.sh`
- `scripts/watch_to_codex.sh`
- `scripts/quick_validate_skill.py`
- `scripts/validate_skill_package.py`
- `scripts/validate_skill_load_hygiene.py`
- `scripts/test_important_instruction_ledger.py`
- `scripts/validate_trigger_results.py`
- `scripts/managed_skills.sh`
- `scripts/bootstrap_code_map.py`
- `scripts/validate_code_map.py`
- `scripts/check_code_map_drift.py`
- `skills/cpp-cuda-vulkan-studio/package-manifest.json`
- `skills/native-cpp-gui-hud/package-manifest.json`
- `skills/cppstudio-project-planner/package-manifest.json`
- `skills/agentic-control-harness/package-manifest.json`
- `skills/viewport-session-testing/package-manifest.json`
- `skills/important-instruction-ledger/package-manifest.json`
- `skills/cppstudio-supervisor/package-manifest.json`
- `skills/cppstudio-supervisor/scripts/slice_phase_report.py`
- `skills/vulkan-compute-sync/package-manifest.json`
- `skills/modern-cpp-cmake/package-manifest.json`
- `skills/cuda-kernel-authoring/package-manifest.json`
- `skills/gpu-profiling-workstation/package-manifest.json`
- `skills/cpp-cuda-vulkan-studio/scripts/run_gpu_optimization_loop.py`

## Update When

- validation coverage, required package files, CI-safe validator behavior, trigger-result evidence
  validation, or full validation changes
- skill package manifest, package integrity validation, or sync/rollout audit metadata changes
- auxiliary user-level skill installation or validation behavior changes
- CppStudio code-map validation or bootstrap wrapper behavior changes
- CppStudio code-map drift wrapper behavior changes
- sync or rollout target safety rules change
- project-level agent instructions for normal rollout versus single-skill sync change
- installed skill parity, auxiliary bundled skill rollout, or companion validation behavior changes
- public install/manual install commands change

## Current Rollout Posture

- Validation, sync, and rollout prefer an explicit `VALIDATOR`, then the target Codex system
  validator, then the repo-local `scripts/quick_validate_skill.py` fallback. The fallback validates
  frontmatter, `agents/openai.yaml`, and bundled local references.
- Package validation uses `scripts/validate_skill_package.py` plus the main and auxiliary skill
  `package-manifest.json` files to verify shipped file hashes, sizes,
  disclosure groups, package layout, and package hygiene. Manifest writes reject unsupported
  top-level files plus VCS, editor, cache, env, secret-like, archive, log, swap, and temp artifacts.
- `scripts/managed_skills.sh` is the single source for bundled auxiliary skill names used by
  validation, rollout, and rollout watch mode. Do not reintroduce local auxiliary arrays in those
  scripts.
- Skill-load hygiene validation uses `scripts/validate_skill_load_hygiene.py` to scan the repo
  skill root as a hard gate, reject backup-looking files/directories that can bloat discovery, catch
  duplicate loaded skill names, and keep description metadata inside a compact startup budget. Keep
  frontmatter descriptions as short discovery triggers; move routing lists, matrices, examples, and
  operational policy into the skill body or lazily read references. The installed user-level Codex
  skill root is audited visibly but non-blocking by default because it may contain unrelated skills
  from other repos; set `CPPSTUDIO_STRICT_USER_SKILL_LOAD=1` to make that installed root a fatal
  maintainer gate.
- Source validation also treats the managed skill inventory as authoritative. Every top-level
  `skills/*/SKILL.md` package must be either the main `cpp-cuda-vulkan-studio` skill or listed in
  `scripts/managed_skills.sh`; otherwise `validate.sh` fails and asks the maintainer to add owner
  rationale or move the package out of `skills/`. This keeps the deliberate multi-skill layout
  explicit without collapsing distinct CppStudio concerns into one monolithic router.
- `validate.sh` compiles and exercises the `cppstudio-supervisor` slice phase telemetry helper so
  `CPPSTUDIO_PHASE` markers, verification classifications, OSTM job/artifact fields, and measured
  phase durations remain parseable before rollout.
- Non-dry-run sync stages and validates the skill before replacing the installed target, then restores
  the previous target if final validation fails. Staging and backups live outside the scanned
  `${SYNC_CODEX_HOME:-$HOME/.codex}/skills` root so interrupted syncs cannot expose duplicate or
  stale skill packages to a concurrent Codex startup scan.
- Sync validates the selected source skill, staged skill, and final installed skill against that
  package manifest. Rollout validates the installed main skill and auxiliary bundled skills before
  completion.
- Normal installed updates for bundled CppStudio skill changes use `rollout_to_codex.sh`, not a
  default `sync_to_codex.sh` run. `sync_to_codex.sh` publishes one selected skill only and is
  appropriate for dry runs, diagnostics, or an explicitly scoped single-skill sync.
- `AGENTS.md` mirrors that boundary: normal publishing reports `rollout_to_codex.sh`; single-skill
  `sync_to_codex.sh` runs must be named as scoped diagnostics or intentionally limited syncs.
- Sync and rollout append best-effort JSONL audit records to
  `${SYNC_CODEX_HOME:-$HOME/.codex}/cppstudio-install-audit.jsonl` unless `CPPSTUDIO_AUDIT_LOG`
  overrides the path.
- Sync rollback tracks whether the previous target existed and whether backup creation completed, so
  a failed backup move leaves the existing installed skill in place.
- Sync and rollout resolve safety-check paths through Python `Path.resolve(strict=False)` so the
  documented Linux, macOS, and WSL install path does not require GNU `realpath -m`.
- Rollout snapshots the main skill, auxiliary bundled skills, and the optional user-level
  `AGENTS.md` relay target before mutation, then restores them if a later step fails.
- Rollout rejects symlinked auxiliary skill targets and user
  `AGENTS.md` relay targets before rollback snapshots are created, so rollback never records a
  symlink-resolved path outside the intended install surface.
- Manual install fallback snippets stage and validate all bundled skills before mutating the target
  Codex home, then restore the full managed-skill set if any later copy or validation step fails.
- `rollout_to_codex.sh` installs bundled auxiliary skills such as `native-cpp-gui-hud`,
  `cppstudio-project-planner`, `agentic-control-harness`, `viewport-session-testing`,
  `important-instruction-ledger`, `cppstudio-supervisor`, `vulkan-compute-sync`, `modern-cpp-cmake`,
  `cuda-kernel-authoring`, and `gpu-profiling-workstation`,
  installs the minimal user-level `AGENTS.md` relay by default, and preserves user-owned content
  outside the marked CppStudio relay block.
- Set `SKIP_USER_AGENTS_RELAY=1` only for deliberate relay opt-out installs.
- `validate.sh` includes a synthetic GPU optimization fixture that exercises success-criteria
  enforcement, target numeric validation, baseline recording, hardware profile/SOL parsing,
  profiler tool-gap artifacts, hypothesis logging, breaking-point search, repeated validation
  passes, beam-style round planning, keep/revert attempts, malformed benchmark revert behavior, final
  reporting, and scaffold installation of `scripts/run_gpu_optimization_loop.py`.
- `validate.sh --full` builds generated projects through the host `asan-ubsan` and `coverage`
  presets, then runs `asan-ubsan-quick` and `coverage-quick` so sanitizer and focused coverage lanes
  remain registered and buildable in fresh scaffolds.
- `validate.sh` also fakes Nsight Systems report/format discovery so `run_nsys_smoke.sh` proves it
  avoids unsupported legacy stats options, uses `--force-export=true`, and selects
  lane-appropriate explicit Vulkan/CUDA report sets from the installed `nsys` surface.
- `validate.sh` includes donor source-parser fixtures so singular, plural, and wrapped `Sources:`
  metadata is parsed before both donor route validation and the report-only donor freshness audit
  run against the real library.
- Code-map validation checks that each subsystem router doc's `## Primary Paths` section matches the
  machine-readable manifest `primary_paths`, so future routing changes stay discoverable to agents.
- Code-map validation permits unmatched `primary_paths` globs while still validating that any matched
  paths remain inside the repo. This keeps optional ownership patterns valid without placeholder
  files.
- Trigger-matrix validation requires the dedicated code-map bootstrap, enabled-map maintenance,
  code-map sidecar, and routing-smoke proof cases to remain present. `validate.sh` renders each case
  by name so aggregate `code-map` coverage cannot hide missing scenarios.
- Trigger-matrix and static skill validation now guard visible-GUI bug proof language: UI-blind
  status, rejection of harness-only/JSON-only progress, and planning coverage for UI-blind reporting
  in UI-heavy slices.
- Static validation should continue guarding OSTM-first GUI proof language and donor-realignment
  language so future edits do not soften visible bug loops back to direct foreground launches,
  backend-only proof, or training-data patching after repeated failures.
- Static validation should continue guarding donor feature disposition language so future planner
  edits cannot regress to broad donor citation without inventorying included, deferred, rejected, or
  blocked donor features, including the pre-plan donor shader/code breakdown requirement.
- Trigger prompt rendering supports portable installed-path evidence so checked-in trigger result
  artifacts can use `${CODEX_HOME:-$HOME/.codex}` and `${CPPSTUDIO_SOURCE_ROOT:-<CppStudio source>}`
  instead of maintainer-local absolute paths.
- `validate_trigger_results.py --matrix research/donor-library/trigger-matrix.json` rejects
  checked-in trigger results that mark a case as `pass` without opening every matrix-rendered
  expected path, with any forbidden path opened, with self-edited expected/forbidden path lists, or
  without fresh-run metadata. `validate.sh` pins the checked-in installed-path evidence to
  `--expected-path-mode portable-installed` and requires the six claimed case names, including
  `code-map-sidecar-maintenance-lane`, so the artifact cannot downgrade path mode or silently shrink
  the result set.
- Existing-project code-map enablement can add missing repo-local validation/drift wrappers under
  `scripts/` so agents do not need to remember the installed skill path after a map is enabled.
  Existing target-owned scripts are preserved.
- The code-map drift checker prints the guarded sidecar helper command
  `agent-tmux codex-code-map-sidecar <repo> <anchor> [focus]` as a worker action when uncovered
  routable paths or the no-map-touch semantic review note indicate map maintenance may need a
  bounded sidecar. Strict review mode blocks source-slice closeout until the worker updates the map,
  uses `--launch-sidecar auto` to create a frozen snapshot and start the sidecar, or explicitly
  acknowledges a reviewed no-map-change case. Once `--reviewed-no-map-change` is supplied, the
  checker prints the acknowledgement without the unresolved sidecar/action wording.
- The bundled code-map bootstrap audit text tells agents to present actual findings and cleanup cost
  before asking restructure/preserve/decline questions, so existing-project opt-in cannot become a
  pre-audit choice prompt.
