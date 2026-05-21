---
name: cppstudio-repo-onboarding
description: "Use when starting work in the CppStudio repo. Explains that this repo is the canonical source for the user-level cpp-cuda-vulkan-studio Codex skill, how to edit and validate it, how to sync it to ~/.codex/skills, and what project-specific content must not be added here."
---

# CppStudio Repo Onboarding

Use this skill before editing anything in the CppStudio repo.

## What This Repo Is

- Canonical working repo for the global reusable `cpp-cuda-vulkan-studio` Codex skill.
- Source skill path: `skills/cpp-cuda-vulkan-studio/`.
- Source companion-skill snippets: `companion-skill-snippets/`.
- Maintained code map: `docs/CODEBASE_ARCHITECTURE_INDEX.md` and
  `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`.
- Research notes: `research/`.
- Installed deployment target: `${HOME}/.codex/skills/cpp-cuda-vulkan-studio`.
- The installed target should be produced by sync, not hand-edited as the source of truth.

## First Read

1. `AGENTS.md`
2. `docs/CODEBASE_ARCHITECTURE_INDEX.md`
3. `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`
4. `README.md`
5. `skills/cpp-cuda-vulkan-studio/SKILL.md`
6. The specific subsystem doc, script, template, or reference file being changed.

## Standard Workflows

For bundled skill text, metadata, trigger routing, validation, sync, rollout, or script changes:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh
./scripts/rollout_to_codex.sh
```

For template, scaffold, CMake, generated-project, or validation-behavior changes:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh --full
./scripts/rollout_to_codex.sh
```

For live editing with automatic publishing:

```bash
./scripts/watch_to_codex.sh
```

For live donor-library or companion-skill snippet work:

```bash
./scripts/watch_to_codex.sh --rollout
```

For donor-library or companion-skill link rollouts:

```bash
./scripts/rollout_to_codex.sh
```

By default this updates matching installed companion skills and skips missing optional companions.
Use `STRICT_COMPANION_SKILLS=1 ./scripts/rollout_to_codex.sh` only for maintainer checks that should
require every known companion skill.

For previewing or diagnosing a single selected skill sync:

```bash
./scripts/sync_to_codex.sh --dry-run
```

`sync_to_codex.sh` syncs only one selected skill, defaulting to `cpp-cuda-vulkan-studio`. Use it for
diagnostics or an intentionally single-skill sync. Use `rollout_to_codex.sh` for normal public
installs and for any change that must update bundled auxiliary skills such as `native-cpp-gui-hud`,
`cppstudio-project-planner`, or `agentic-control-harness`.

## Rules

- Keep `cpp-cuda-vulkan-studio` generic for future C++/CUDA/Vulkan repos.
- Before changing CppStudio repo files, use `docs/CODEBASE_ARCHITECTURE_INDEX.md` and
  `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` to choose the matching subsystem doc and primary paths for
  the work.
- Keep `docs/CODEBASE_ARCHITECTURE_INDEX.md`, `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`, and the
  matching `docs/SUBSYSTEMS/*.md` file updated when subsystem ownership or routing changes.
- Do not add private-app-only, local-workstation-only, or other project-specific instructions to this
  global skill.
- Keep reusable GPU-selection policy generic. If a target machine has only a subset of GPUs suitable
  for realtime CUDA, document that in the target project or local runner configuration through
  `GPU_ALLOWED_INDICES` or `CUDA_VISIBLE_DEVICES`, not in the global skill.
- If this repo rolls out user-level `AGENTS.md` content, merge or append only the tiny marked
  CppStudio relay block. It should only tell agents to load `cpp-cuda-vulkan-studio` for native
  C++ GPU/realtime/code-map/Vulkan/CUDA work; lane policy stays inside the skill.
- Companion donor rollout may replace only the marked `cppstudio-donor-library` block in matching
  installed companion skills. Preserve user-owned content outside those markers.
- Preserve template tokens such as `{{PROJECT_NAME}}`, `{{PROJECT_NAME_LOWER}}`, and
  `{{CPP_NAMESPACE}}`.
- Preserve companion snippet tokens such as `{{DONOR_ROOT}}` and `{{REFERENCE_ROOT}}`; rollout renders
  them for installed user-level skills.
- Do not add generated build outputs, temp scaffold projects, profiler traces, or `__pycache__`.
- If sync or validation fails, fix the repo copy first, then rerun sync.
- Before pushing to remote, add a concise `CHANGELOG.md` entry for the tracked change.
- Also update README Recent Commit Highlights when the pushed commit changes setup, routing,
  generated projects, validation, donor-library behavior, public docs, install, release, or sync
  behavior.
- The README Recent Commit Highlights section is the front-page changelog. It must stay readable:
  newest qualifying commits should be short bullets, not a giant aggregate paragraph. Before any
  CppStudio commit or push, inspect the staged diff and report whether the front-page changelog and
  `CHANGELOG.md` were updated or why the change is non-qualifying.

## Close-Out Checklist

- State whether validation was default or full.
- State whether `python3 scripts/validate_code_map.py . --require-enabled` passed.
- State whether `./scripts/rollout_to_codex.sh` was run for bundled installed skills. If only
  `sync_to_codex.sh` was run, state the selected skill and why a single-skill sync was sufficient.
- State whether `CHANGELOG.md` was updated before any push to remote.
- State whether README Recent Commit Highlights was updated as a readable front-page changelog before
  any qualifying push.
- If skills, skill descriptions, donor profiles, donor categories, donor routing, or README donor
  inventory changed, run a sub-agent trigger lane first and report whether the expected skill and donor
  profiles were selected.
- State any tool gaps that affect optional lanes, such as missing `clang-format` or `clang-tidy`.
