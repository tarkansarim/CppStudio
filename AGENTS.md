# CppStudio Agent Notes

This repo is the canonical working source for reusable Codex infrastructure around future
C++/CUDA/Vulkan development.

## Required Orientation

- This is not a generated sample project. Do not treat it as a C++ app/library repo.
- The main artifact is the user-level Codex skill source at `skills/cpp-cuda-vulkan-studio/`.
- If available in the session, use the project skill `cppstudio-repo-onboarding` when starting
  work in this repo.
- The installed user-level copy at `/home/tarkan/.codex/skills/cpp-cuda-vulkan-studio` is a
  deployment target, not the source of truth.

## Source Of Truth

- Edit `skills/cpp-cuda-vulkan-studio/` in this repo.
- Publish to user-level Codex with `./scripts/sync_to_codex.sh`.
- Do not hand-edit `/home/tarkan/.codex/skills/cpp-cuda-vulkan-studio` as the long-term source.
- Do not move CudaGroomTool, ComfyNative, or other project-specific skills back into user-level
  Codex from this repo.

## Validation

- Run `./scripts/validate.sh` after edits to skill text, scripts, metadata, or sync behavior.
- Run `./scripts/validate.sh --full` after edits to:
  - `assets/app-library-template/`
  - scaffolding or apply scripts
  - CMake presets/modules
  - generated-project validation behavior
- The sync script validates both the repo copy and the installed Codex copy.
- If validation fails because of a real script/template issue, fix the repo copy first, then sync.

## Sync Behavior

- `./scripts/sync_to_codex.sh` publishes this repo's skill copy to user-level Codex.
- It uses `rsync --delete` by default so the installed skill exactly matches this repo.
- Pass `--dry-run` to preview changes.
- Pass `--no-delete` only for diagnostics; normal publishing should keep delete enabled.
- `./scripts/watch_to_codex.sh` continuously validates and syncs after file changes.
- `./scripts/rollout_to_codex.sh` validates, syncs the canonical skill, installs donor-library links
  into companion user-level skills, validates affected installed skills, and verifies source/target
  parity.
- Companion-skill donor link snippets live in `companion-skill-snippets/`; update those snippets,
  not inline installed skill text or hardcoded markdown inside rollout scripts.

## Safe Editing Rules

- Keep reusable policy generic. Do not add CudaGroomTool-only, ComfyNative-only, or machine-only
  workflow rules to `skills/cpp-cuda-vulkan-studio/`; those belong in project-level skills.
- Preserve intentional template placeholders such as `{{PROJECT_NAME}}` and `{{CPP_NAMESPACE}}`.
- Do not commit generated temp projects, build directories, profiler traces, or Python
  `__pycache__` files.
- Prefer updating the reusable scripts over copying long command sequences into docs when behavior
  must stay deterministic.
- Keep research notes under `research/` and reusable skill instructions under
  `skills/cpp-cuda-vulkan-studio/`; do not mix process notes into installed user-level skill files.

## Close-Out

When finishing work here, report:

- files changed at the repo level
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether `./scripts/sync_to_codex.sh` was run
- any installed-tool gaps, such as missing `clang-format` or `clang-tidy`
