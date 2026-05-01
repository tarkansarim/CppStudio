# Maintainer Guide

This document is for coding agents and maintainers editing CppStudio itself. It is not a daily task
list for people installing the skill.

## Validate Changes

For ordinary skill text, script, metadata, donor, or README changes:

```bash
./scripts/validate.sh
```

For template, scaffold, CMake, generated-project, or generated-project validation behavior changes:

```bash
./scripts/validate.sh --full
```

## Publish To Codex

Preview sync changes:

```bash
./scripts/sync_to_codex.sh --dry-run
```

Publish only the main `cpp-cuda-vulkan-studio` skill:

```bash
./scripts/sync_to_codex.sh
```

Publish the main skill and reinstall companion-skill donor-library links:

```bash
./scripts/rollout_to_codex.sh
```

Public installs do not need every companion skill installed. Rollout updates matching companion
skills that exist under `${SYNC_CODEX_HOME:-$HOME/.codex}/skills` and skips missing optional
companions. Maintainer checks can require the full companion set:

```bash
STRICT_COMPANION_SKILLS=1 ./scripts/rollout_to_codex.sh
```

Optionally merge the minimal user-level `AGENTS.md` relay during rollout:

```bash
INSTALL_USER_AGENTS_RELAY=1 ./scripts/rollout_to_codex.sh
```

## Watch Mode

Continuously validate and publish source-skill edits:

```bash
./scripts/watch_to_codex.sh
```

Continuously validate and publish source-skill edits plus companion snippets:

```bash
./scripts/watch_to_codex.sh --rollout
```

Use `--rollout` when editing `companion-skill-snippets/`; normal sync does not update companion
skills.

## Generated Projects

The bundled scaffold script creates a project from
`skills/cpp-cuda-vulkan-studio/assets/app-library-template/`.

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/scaffold_gpu_cpp_project.py \
  --name RayLab \
  --output /tmp/RayLab
```

Useful options:

- `--namespace ray_lab`: override the generated C++ namespace.
- `--description "Short project description"`: render a project description into the generated README.
- `--force`: overwrite files that already exist at the destination.

Validate the generated project:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/validate_studio_backbone.py \
  /tmp/RayLab \
  --strict-source-layout \
  --integration
```

The integration check configures the `dev` preset, builds it, and confirms the quick CTest lane has
registered labeled tests.

CUDA is available through explicit presets, not mixed into Vulkan-default projects:

```bash
cmake --preset cuda-debug
cmake --build --preset cuda-debug
ctest --preset cuda --output-on-failure
```

For deliberate CUDA plus Vulkan interop work:

```bash
cmake --preset cuda-vulkan-interop
cmake --build --preset cuda-vulkan-interop
```

## Existing Repos

For an existing C++ repo, apply the backbone to a temporary copy first unless the user explicitly
wants direct modification:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/apply_studio_backbone.py /path/to/repo
```

Useful options:

- `--dry-run`: report planned writes/copies without changing the target repo.
- `--force`: overwrite existing backbone files.

After applying, validate the target repo:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/validate_studio_backbone.py /path/to/repo
```

Existing-repo application installs support files, scripts, presets, docs, and shader fixtures. It
does not replace the root `CMakeLists.txt` or copy sample source files. Wire the CMake modules and
CTest labels into the real project build deliberately, then run `validate_studio_backbone.py
--integration` once the target repo can configure and build through its presets.

## Donor Library Checks

Validate donor-library link integrity:

```bash
python3 scripts/validate_donor_library.py \
  skills/cpp-cuda-vulkan-studio/references/donor-library \
  --reference-root skills/cpp-cuda-vulkan-studio/references
```

`./scripts/validate.sh` and `./scripts/rollout_to_codex.sh` run this donor validator automatically.
Trigger-matrix validation checks schema, controlled tags, and path integrity; use
`research/donor-library/trigger-regression-checklist.md` for manual or subagent trigger reruns.

Render a repeatable trigger-evaluation prompt pack for a fresh agent or reviewer:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --tag smoke
```

Useful tags include `positive`, `negative`, `smoke`, `lookup`, `cuda`, `vulkan`, `assets`,
`graphics`, `rendering`, `simulation`, `ai-runtime`, `neural-3d`, `webgpu`, `browser`, `xr`,
`cad`, `geometry`, `engine`, and `study-only`. Use installed-path mode after rollout when the
evaluator should inspect the user-level Codex install instead of repo-relative source paths:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --tag lookup \
  --installed-paths
```

The renderer only prepares prompts and report blanks. It does not call agents or prove trigger
behavior by itself.

## Sync And Rollout Details

`sync_to_codex.sh` copies:

```bash
skills/cpp-cuda-vulkan-studio/
```

to:

```bash
${SYNC_CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio
```

It intentionally ignores `CODEX_HOME` unless `SYNC_CODEX_HOME` or `TARGET_DIR` is provided, because
nested Codex sessions may set isolated homes.

Use a custom Codex home:

```bash
SYNC_CODEX_HOME=/path/to/.codex ./scripts/sync_to_codex.sh
```

Use an exact target directory for diagnostics:

```bash
ALLOW_SYNC_TARGET_OVERRIDE=1 TARGET_DIR=/path/to/.codex/skills/cpp-cuda-vulkan-studio ./scripts/sync_to_codex.sh
```

The target must be an exact skill directory ending in `skills/cpp-cuda-vulkan-studio`. The script
refuses broad directories such as home, `/tmp`, a repo root, or a generic `skills/` directory even
when override mode is enabled.

`rollout_to_codex.sh` rejects non-standard `TARGET_DIR` values unless explicitly allowed, because it
renders absolute donor-library links into companion skills:

```bash
ALLOW_ROLLOUT_TARGET_OVERRIDE=1 TARGET_DIR=/path/to/staging/skills/cpp-cuda-vulkan-studio ./scripts/rollout_to_codex.sh
```

Use that override only for deliberate staging.

By default, companion donor-link rollout skips absent optional companion skills. Set
`STRICT_COMPANION_SKILLS=1` when validating a full local release environment where
`cuda-kernel-authoring`, `vulkan-compute-sync`, and `modern-cpp-cmake` must all be installed.

`rollout_to_codex.sh` does not modify user-level `AGENTS.md` by default. With
`INSTALL_USER_AGENTS_RELAY=1`, it merges only
`companion-skill-snippets/user-agents/cppstudio-relay.md` into
`${SYNC_CODEX_HOME:-$HOME/.codex}/AGENTS.md` or `USER_AGENTS_RELAY_TARGET`. Custom relay targets
require `ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1`, must be named `AGENTS.md`, and must not be
symlinks.

## Editing Rules

- Edit `skills/cpp-cuda-vulkan-studio/` in this repo, not the installed user-level copy.
- Edit companion donor-link text in `companion-skill-snippets/`, not directly in installed companion
  skills.
- Keep the reusable skill generic. Do not add CudaGroomTool-only, ComfyNative-only, or other
  project-specific policy here.
- User-level `AGENTS.md` rollout is relay-only. Merge or append the marked CppStudio relay block and
  preserve existing user content; do not copy full skill policy into `AGENTS.md`.
- Preserve template placeholders such as `{{PROJECT_NAME}}`, `{{PROJECT_NAME_LOWER}}`,
  `{{CPP_NAMESPACE}}`, `{{DONOR_ROOT}}`, and `{{REFERENCE_ROOT}}`.
- Do not commit generated temp projects, build directories, profiler traces, `.pyc` files, or
  `__pycache__` directories.
- Prefer updating scripts when behavior needs to stay deterministic.

## Troubleshooting

Missing or old Python:

```text
Python 3.10+ is required
```

Install Python 3.10 or newer and rerun the agent's install or validation command.

Missing skill validator:

```text
Missing skill validator: ${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py
```

Install or restore the system `skill-creator` skill in the target Codex home, then rerun validation.

Watch mode fails with `inotifywait is required for watch mode`:

```bash
sudo apt install inotify-tools
```

Full validation fails during CMake configure or build:

- Confirm CMake, Ninja, and a C++ compiler are installed.
- If CUDA or Vulkan-specific generated lanes are enabled, confirm the relevant SDK/tool paths.
- Fix template or validation behavior in the repo copy first, then rerun `./scripts/validate.sh --full`.

Rollout refuses a custom target:

- Use normal rollout for user-level installation.
- Use `ALLOW_ROLLOUT_TARGET_OVERRIDE=1` only when companion-skill links should intentionally point
  at the custom target.
- The custom target must end in `skills/cpp-cuda-vulkan-studio`.

Relay install refuses a custom `AGENTS.md` target:

- Use the default `${SYNC_CODEX_HOME:-$HOME/.codex}/AGENTS.md` target for normal installs.
- Use `ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1` only for deliberate staging.
- The target must be named `AGENTS.md` and must not be a symlink.

## Close-Out Checklist

When finishing changes in this repo, report:

- repo-level files changed
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether `./scripts/sync_to_codex.sh` or `./scripts/rollout_to_codex.sh` was run
- any installed-tool gaps, such as missing `clang-format`, `clang-tidy`, CUDA tools, or Vulkan tools
