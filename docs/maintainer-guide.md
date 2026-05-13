# Maintainer Guide

This document is for coding agents and maintainers editing CppStudio itself. It is not a daily task
list for people installing the skill.

## Validate Changes

For ordinary skill text, script, metadata, donor, or README changes:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh
```

For template, scaffold, CMake, generated-project, or generated-project validation behavior changes:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh --full
```

Public CI uses the repo-local metadata validator because clean GitHub runners do not have Codex's
system `skill-creator` validator installed:

```bash
VALIDATOR="${PWD}/scripts/quick_validate_skill.py" ./scripts/validate.sh
```

Use the Codex system validator for normal local maintainer validation when it is available.

## Code Map Maintenance

CppStudio itself has an enabled code map:

```bash
docs/CODEBASE_ARCHITECTURE_INDEX.md
docs/CODEBASE_SUBSYSTEM_MANIFEST.json
```

Update the matching `docs/SUBSYSTEMS/*.md` file and manifest whenever subsystem ownership, routing,
generated-template behavior, validation/sync/rollout behavior, companion snippets, donor-library
structure, public docs, CI, or change-history policy changes.

Validate the map:

```bash
python3 scripts/validate_code_map.py . --require-enabled
```

Generated or upgraded C++ projects use the same scripts, but their map is opt-in. Agents should check
only `.cppstudio/code-map-state.json` first and ask once when the state is missing. For greenfield
scaffolds, enable with `scripts/bootstrap_code_map.py --enable --force` after acceptance because the
template includes starter generated map files, or record declined state with
`scripts/bootstrap_code_map.py --decline`.

When a map is enabled, use `docs/CODEBASE_ARCHITECTURE_INDEX.md` and
`docs/CODEBASE_SUBSYSTEM_MANIFEST.json` as the first navigation step before code changes. Select the
matching subsystem doc and primary paths from the map before editing.

For greenfield scaffolds, an explicit user request for a code map, architecture map, or future-agent
map during project creation counts as acceptance; run `scripts/bootstrap_code_map.py --enable --force`
after scaffolding.

For existing projects, enabling the map has a readiness protocol. Run
`scripts/bootstrap_code_map.py --audit-existing` first, review its stdout, summarize nonstandard
layout findings and estimated cleanup cost, then ask whether to restructure first, preserve the
current layout with documented exceptions, or decline the map. Save the audit with `--write-audit`
only when the user wants `docs/CODEMAP_BOOTSTRAP_AUDIT.md` recorded. If generated map files already
exist, `--enable` refuses to replace them unless `--force` is explicit after user acceptance.

## Publish To Codex

Normal publishing for this repo uses rollout. Rollout validates the repo, syncs the main
`cpp-cuda-vulkan-studio` skill, syncs bundled auxiliary skills, installs companion donor links, and
updates the minimal user-level `AGENTS.md` relay:

```bash
./scripts/rollout_to_codex.sh
```

Public installs do not need every companion skill installed. Rollout updates matching companion
skills that exist under `${SYNC_CODEX_HOME:-$HOME/.codex}/skills` and skips missing optional
companions. Maintainer checks can require the full companion set:

```bash
STRICT_COMPANION_SKILLS=1 ./scripts/rollout_to_codex.sh
```

The minimal user-level `AGENTS.md` relay is installed by default during rollout. To opt out for a
deliberate staging or docs-only install, run:

```bash
SKIP_USER_AGENTS_RELAY=1 ./scripts/rollout_to_codex.sh
```

Use `sync_to_codex.sh` only for dry runs, diagnostics, or an intentionally scoped single-skill sync.
Preview a selected sync with:

```bash
./scripts/sync_to_codex.sh --dry-run
```

Sync only one selected skill, defaulting to the main `cpp-cuda-vulkan-studio` skill:

```bash
./scripts/sync_to_codex.sh
```

For a bundled auxiliary single-skill diagnostic sync, set `SKILL_NAME` explicitly:

```bash
SKILL_NAME=native-cpp-gui-hud ./scripts/sync_to_codex.sh
SKILL_NAME=cppstudio-project-planner ./scripts/sync_to_codex.sh
SKILL_NAME=agentic-control-harness ./scripts/sync_to_codex.sh
```

Before pushing CppStudio to remote, update `CHANGELOG.md` with a concise entry for the tracked
change. Also update the README Recent Commit Highlights list when a commit affects setup, routing,
generated projects, validation, donor-library behavior, public docs, install, release, or sync
behavior. The final response should mention the pushed commit(s), but the changelog remains the
durable history.

## Watch Mode

Continuously validate and publish source-skill edits:

```bash
./scripts/watch_to_codex.sh
```

Continuously validate and publish source-skill edits plus bundled auxiliary skills and companion
snippets:

```bash
./scripts/watch_to_codex.sh --rollout
```

Use `--rollout` when editing bundled auxiliary skills or `companion-skill-snippets/`; normal sync
publishes only the selected `SKILL_NAME`.

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

The scaffold includes code-map support scripts and starter docs. After the user accepts maintained
code-map behavior for the generated project, run:

```bash
cd /tmp/RayLab
scripts/bootstrap_code_map.py --enable --force
scripts/validate_code_map.py --require-enabled
scripts/check_code_map_drift.py --require-enabled
```

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

For deliberate combined CUDA plus Vulkan work:

```bash
cmake --preset cuda-vulkan-combined
cmake --build --preset cuda-vulkan-combined
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
- `--with-code-map`: copy code-map support docs and scripts without enabling the map. Use this only
  when the user has asked to bootstrap or evaluate code-map support for the existing repo. Run
  `scripts/bootstrap_code_map.py --audit-existing` first, summarize the stdout audit, ask whether to
  restructure or preserve the layout, then run `scripts/bootstrap_code_map.py --enable` only after
  the user accepts maintained map behavior. Use `--write-audit` only when the user wants the audit
  saved. Use `--enable --force` only when replacing existing generated map files was explicitly
  accepted. After source changes in an enabled-map target repo, run
  `scripts/check_code_map_drift.py --require-enabled` before committing so new routable files are
  added to the manifest and subsystem docs instead of becoming invisible to future agents.

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
Trigger-matrix validation checks schema, controlled tags, and path integrity; trigger-result
validation checks that recorded `pass` probes opened every expected path and no forbidden paths. Use
`research/donor-library/trigger-regression-checklist.md` for manual or subagent trigger reruns.
Optional donor freshness audits are report-only by default so validation does not depend on network
or upstream availability:

```bash
python3 scripts/audit_donor_freshness.py \
  skills/cpp-cuda-vulkan-studio/references/donor-library \
  --summary-only
```

Render a repeatable trigger-evaluation prompt pack for a fresh agent or reviewer:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --tag smoke
```

Useful tags include `positive`, `negative`, `smoke`, `lookup`, `code-map`, `cuda`, `vulkan`, `assets`,
`graphics`, `rendering`, `simulation`, `ai-runtime`, `neural-3d`, `webgpu`, `browser`, `xr`,
`gui`, `hud`, `cad`, `geometry`, `engine`, and `study-only`. Use installed-path mode after rollout when the
evaluator should inspect the user-level Codex install instead of repo-relative source paths:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --tag lookup \
  --installed-paths
```

The renderer only prepares prompts and report blanks. It does not call agents or prove trigger
behavior by itself. Add `--write-result-template trigger-results.json` when you want a structured
machine-readable report skeleton for the selected cases. Rendered packs define forbidden paths as
no-touch paths: evaluators must not open, read, search, stat, list, or existence-check them.
After filling a result artifact, validate it:

```bash
python3 scripts/validate_trigger_results.py trigger-results.json \
  --matrix research/donor-library/trigger-matrix.json \
  --repo-root . \
  --expected-path-mode portable-installed \
  --require-case realtime-raytracing-framework-donors \
  --require-case missing-donor-promotion-boundary \
  --require-case agentic-control-harness-default \
  --require-case grooming-brush-authoring-donors \
  --require-case sculpting-brush-high-poly-donors \
  --require-case code-map-sidecar-maintenance-lane
```

Passing cases must list all expected paths in `result.opened_files`, keep forbidden paths untouched,
include selected skills, carry fresh-run metadata, and match expected/forbidden paths rendered from
`trigger-matrix.json`. For checked-in installed evidence, also pin `--expected-path-mode
portable-installed` and require the claimed case names so the artifact cannot silently downgrade to
repo-relative evidence or shrink the result set.

`validate_trigger_matrix.py` requires the dedicated code-map cases
`code-map-existing-project-bootstrap`, `enabled-code-map-maintenance-closeout`,
`code-map-sidecar-maintenance-lane`, and `code-map-routing-smoke-proof` to remain present.
`validate.sh` also renders those cases by name so a single aggregate `code-map` case cannot
accidentally stand in for the whole workflow.

## Sync And Rollout Details

`rollout_to_codex.sh` is the normal installed update path for this repo. It validates and installs
the main `cpp-cuda-vulkan-studio` skill, bundled auxiliary skills, companion donor links, and the
managed user-level relay together. Use it after any change that must affect future Codex sessions:

```bash
./scripts/rollout_to_codex.sh
```

`sync_to_codex.sh` copies one selected skill only. By default this is:

```bash
skills/cpp-cuda-vulkan-studio/
```

to:

```bash
${SYNC_CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio
```

Set `SKILL_NAME=native-cpp-gui-hud`, `SKILL_NAME=cppstudio-project-planner`, or
`SKILL_NAME=agentic-control-harness` only for an intentional single-skill diagnostic sync. Do not use
the default sync command as proof that auxiliary skill edits were installed.

It intentionally ignores `CODEX_HOME` unless `SYNC_CODEX_HOME` or `TARGET_DIR` is provided, because
nested Codex sessions may set isolated homes.

Validation uses `VALIDATOR` when provided, otherwise the target Codex system validator when present,
and finally the repo-local `scripts/quick_validate_skill.py` fallback. The fallback checks the
package metadata, `agents/openai.yaml`, duplicate frontmatter fields, and bundled local references.
Fresh staging homes can use the scripts without preinstalling the system `skill-creator` validator.

Package integrity uses each packaged skill's `package-manifest.json` and
`scripts/validate_skill_package.py`. The manifest records every shipped skill file except itself,
with file role, progressive disclosure group, size, and SHA-256. Regenerate the matching manifest
only after package contents change:

```bash
python3 scripts/validate_skill_package.py skills/cpp-cuda-vulkan-studio --write-manifest
python3 scripts/validate_skill_package.py skills/native-cpp-gui-hud --write-manifest
python3 scripts/validate_skill_package.py skills/cppstudio-project-planner --write-manifest
python3 scripts/validate_skill_package.py skills/agentic-control-harness --write-manifest
```

Then validate normally:

```bash
python3 scripts/validate_skill_package.py skills/cpp-cuda-vulkan-studio
python3 scripts/validate_skill_package.py skills/native-cpp-gui-hud
python3 scripts/validate_skill_package.py skills/cppstudio-project-planner
python3 scripts/validate_skill_package.py skills/agentic-control-harness
```

Use a custom Codex home:

```bash
SYNC_CODEX_HOME=/path/to/.codex ./scripts/rollout_to_codex.sh
```

For a single-skill diagnostic sync to a custom home, use `SYNC_CODEX_HOME=/path/to/.codex
./scripts/sync_to_codex.sh`.

Use an exact target directory for diagnostics:

```bash
ALLOW_SYNC_TARGET_OVERRIDE=1 TARGET_DIR=/path/to/.codex/skills/cpp-cuda-vulkan-studio ./scripts/sync_to_codex.sh
```

The target must be an exact skill directory ending in `skills/cpp-cuda-vulkan-studio`. The script
refuses broad directories such as home, `/tmp`, a repo root, or a generic `skills/` directory even
when override mode is enabled.

Non-dry-run sync is transactional: the script copies into a staged directory, validates the staged
skill, validates its package manifest, swaps it into place, validates the final target and package,
and restores the previous installed skill on failure.

Sync and rollout append best-effort JSONL audit records to
`${SYNC_CODEX_HOME:-$HOME/.codex}/cppstudio-install-audit.jsonl`. Set `CPPSTUDIO_AUDIT_LOG` for a
staging path. Audit entries include action, skill name, success flag, target path, source commit when
available, package manifest hash, and timestamp. Audit logging should never be treated as the source
of truth; validation output is authoritative.

`rollout_to_codex.sh` rejects non-standard `TARGET_DIR` values unless explicitly allowed, because it
renders absolute donor-library links into companion skills:

```bash
ALLOW_ROLLOUT_TARGET_OVERRIDE=1 TARGET_DIR=/path/to/staging/skills/cpp-cuda-vulkan-studio ./scripts/rollout_to_codex.sh
```

Use that override only for deliberate staging.

By default, companion donor-link rollout skips absent optional companion skills. Set
`STRICT_COMPANION_SKILLS=1` when validating a full local release environment where
`cuda-kernel-authoring`, `vulkan-compute-sync`, and `modern-cpp-cmake` must all be installed.

Rollout snapshots the main skill, bundled auxiliary skills, matching companion `SKILL.md` files, and
the optional user-level `AGENTS.md` relay target before mutation, then restores those paths if any
post-sync validation or install step fails.

Before taking those snapshots, rollout refuses symlinked installed auxiliary skill targets,
companion skill directories/files, and user `AGENTS.md` relay targets. This keeps rollback pointed at
the intended Codex install paths instead of symlink-resolved outside locations.

Rollout also verifies installed packaged skills against their package manifests before reporting
success.

`rollout_to_codex.sh` installs the tiny user-level `AGENTS.md` relay by default. It merges only
`companion-skill-snippets/user-agents/cppstudio-relay.md` into
`${SYNC_CODEX_HOME:-$HOME/.codex}/AGENTS.md` or `USER_AGENTS_RELAY_TARGET`. Set
`SKIP_USER_AGENTS_RELAY=1` only when the relay should not be installed or updated. Custom relay
targets require `ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1`, must be named `AGENTS.md`, and must not
be symlinks.

## Editing Rules

- Edit `skills/cpp-cuda-vulkan-studio/` or bundled auxiliary skills under `skills/` in this repo,
  not the installed user-level copies.
- Edit companion donor-link text in `companion-skill-snippets/`, not directly in installed companion
  skills.
- Keep the reusable skill generic. Do not add private-app-only, local-workstation-only, or other
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

Missing skill validator after an explicit override:

```text
Missing skill validator: /path/to/validator
```

Unset the bad `VALIDATOR` override or point it at `scripts/quick_validate_skill.py`. On hosted CPU CI,
set `CPPSTUDIO_FULL_CUDA_ARCHITECTURES` to a concrete architecture and
`CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS=1` so the generated CUDA lane is compiled without requiring a CUDA
device for runtime tests.

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
  Bundled auxiliary skills are installed next to that target during rollout.

Relay install refuses a custom `AGENTS.md` target:

- Use the default `${SYNC_CODEX_HOME:-$HOME/.codex}/AGENTS.md` target for normal installs.
- Use `ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1` only for deliberate staging.
- The target must be named `AGENTS.md` and must not be a symlink.

## Close-Out Checklist

When finishing changes in this repo, report:

- repo-level files changed
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether `./scripts/rollout_to_codex.sh` was run for normal bundled installs, or which explicit
  single-skill `./scripts/sync_to_codex.sh` run was used and why
- any installed-tool gaps, such as missing `clang-format`, `clang-tidy`, CUDA tools, or Vulkan tools
