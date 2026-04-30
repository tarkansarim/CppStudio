---
name: cppstudio-repo-onboarding
description: "Use when starting work in /home/tarkan/Dropbox/work/MyTools/CppStudio. Explains that this repo is the canonical source for the user-level cpp-cuda-vulkan-studio Codex skill, how to edit and validate it, how to sync it to ~/.codex/skills, and what project-specific content must not be added here."
---

# CppStudio Repo Onboarding

Use this skill before editing anything in `/home/tarkan/Dropbox/work/MyTools/CppStudio`.

## What This Repo Is

- Canonical working repo for the global reusable `cpp-cuda-vulkan-studio` Codex skill.
- Source skill path: `skills/cpp-cuda-vulkan-studio/`.
- Source companion-skill snippets: `companion-skill-snippets/`.
- Research notes: `research/`.
- Installed deployment target: `${HOME}/.codex/skills/cpp-cuda-vulkan-studio`.
- The installed target should be produced by sync, not hand-edited as the source of truth.

## First Read

1. `AGENTS.md`
2. `README.md`
3. `skills/cpp-cuda-vulkan-studio/SKILL.md`
4. The specific script/template file being changed.

## Standard Workflows

For skill text, metadata, or script changes:

```bash
./scripts/validate.sh
./scripts/sync_to_codex.sh
```

For template, scaffold, CMake, generated-project, or validation-behavior changes:

```bash
./scripts/validate.sh --full
./scripts/sync_to_codex.sh
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

For previewing installed changes:

```bash
./scripts/sync_to_codex.sh --dry-run
```

## Rules

- Keep `cpp-cuda-vulkan-studio` generic for future C++/CUDA/Vulkan repos.
- Do not add CudaGroomTool, ComfyNative, hair-rendering, or other project-specific instructions to
  this global skill.
- Keep reusable GPU-selection policy generic. If a target machine has only a subset of GPUs suitable
  for realtime CUDA, document that in the target project or local runner configuration through
  `GPU_ALLOWED_INDICES` or `CUDA_VISIBLE_DEVICES`, not in the global skill.
- If this repo rolls out user-level `AGENTS.md` content, merge or append only the tiny marked
  CppStudio relay block. It should only tell agents to load `cpp-cuda-vulkan-studio` for C++
  Vulkan/CUDA work; lane policy stays inside the skill.
- Companion donor rollout may replace only the marked `cppstudio-donor-library` block in matching
  installed companion skills. Preserve user-owned content outside those markers.
- Preserve template tokens such as `{{PROJECT_NAME}}`, `{{PROJECT_NAME_LOWER}}`, and
  `{{CPP_NAMESPACE}}`.
- Preserve companion snippet tokens such as `{{DONOR_ROOT}}` and `{{REFERENCE_ROOT}}`; rollout renders
  them for installed user-level skills.
- Do not add generated build outputs, temp scaffold projects, profiler traces, or `__pycache__`.
- If sync or validation fails, fix the repo copy first, then rerun sync.

## Close-Out Checklist

- State whether validation was default or full.
- State whether sync to `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` was run.
- State any tool gaps that affect optional lanes, such as missing `clang-format` or `clang-tidy`.
