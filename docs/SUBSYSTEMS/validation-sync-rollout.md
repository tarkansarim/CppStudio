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
- `scripts/bootstrap_code_map.py`
- `scripts/validate_code_map.py`
- `scripts/check_code_map_drift.py`
- `skills/cpp-cuda-vulkan-studio/package-manifest.json`
- `skills/native-cpp-gui-hud/package-manifest.json`
- `skills/cppstudio-project-planner/package-manifest.json`
- `skills/agentic-control-harness/package-manifest.json`
- `skills/cpp-cuda-vulkan-studio/scripts/run_gpu_optimization_loop.py`

## Update When

- validation coverage, required package files, CI-safe validator behavior, or full validation changes
- skill package manifest, package integrity validation, or sync/rollout audit metadata changes
- auxiliary user-level skill installation or validation behavior changes
- CppStudio code-map validation or bootstrap wrapper behavior changes
- CppStudio code-map drift wrapper behavior changes
- sync or rollout target safety rules change
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
- Non-dry-run sync stages and validates the skill before replacing the installed target, then restores
  the previous target if final validation fails.
- Sync validates the selected source skill, staged skill, and final installed skill against that
  package manifest. Rollout validates the installed main skill and auxiliary bundled skills before
  completion.
- Sync and rollout append best-effort JSONL audit records to
  `${SYNC_CODEX_HOME:-$HOME/.codex}/cppstudio-install-audit.jsonl` unless `CPPSTUDIO_AUDIT_LOG`
  overrides the path.
- Sync rollback tracks whether the previous target existed and whether backup creation completed, so
  a failed backup move leaves the existing installed skill in place.
- Sync and rollout resolve safety-check paths through Python `Path.resolve(strict=False)` so the
  documented Linux, macOS, and WSL install path does not require GNU `realpath -m`.
- Rollout snapshots the main skill, auxiliary bundled skills, matching companion skill files, and the optional user-level
  `AGENTS.md` relay target before mutation, then restores them if a later step fails.
- Manual install fallback snippets stage and validate all bundled skills before mutating the target
  Codex home, then restore the full managed-skill set if any later copy or validation step fails.
- `rollout_to_codex.sh` installs bundled auxiliary skills such as `native-cpp-gui-hud`,
  `cppstudio-project-planner`, and `agentic-control-harness`, installs the minimal user-level
  `AGENTS.md` relay by default, and preserves user-owned content outside the marked CppStudio relay
  block.
- Set `SKIP_USER_AGENTS_RELAY=1` only for deliberate relay opt-out installs.
- `validate.sh` includes a synthetic GPU optimization fixture that exercises success-criteria
  enforcement, target numeric validation, baseline recording, hardware profile/SOL parsing,
  profiler tool-gap artifacts, hypothesis logging, breaking-point search, repeated validation
  passes, beam-style round planning, keep/revert attempts, malformed benchmark revert behavior, final
  reporting, and scaffold installation of `scripts/run_gpu_optimization_loop.py`.
- `validate.sh` also fakes Nsight Systems report/format discovery so `run_nsys_smoke.sh` proves it
  avoids unsupported legacy stats options, uses `--force-export=true`, and selects
  lane-appropriate explicit Vulkan/CUDA report sets from the installed `nsys` surface.
- Code-map validation checks that each subsystem router doc's `## Primary Paths` section matches the
  machine-readable manifest `primary_paths`, so future routing changes stay discoverable to agents.
- The bundled code-map bootstrap audit text tells agents to present actual findings and cleanup cost
  before asking restructure/preserve/decline questions, so existing-project opt-in cannot become a
  pre-audit choice prompt.
