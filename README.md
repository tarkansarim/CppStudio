# CppStudio

CppStudio is an agentic skills package for GPU-native C++ engineering. It is the canonical source
for the reusable `cpp-cuda-vulkan-studio` Codex skill, its bundled C++/CUDA/Vulkan project
backbone, research notes, donor-reference routing, companion-skill snippets, and rollout scripts.

Use this repo when you want coding agents to create, audit, or upgrade C++/CUDA/Vulkan projects
with consistent build structure, validation lanes, profiling hooks, and curated external reference
selection.

## What This Repo Contains

- `skills/cpp-cuda-vulkan-studio/`: source of truth for the user-level Codex skill.
- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`: reusable generated-project
  template for app+library C++/CUDA/Vulkan repos.
- `skills/cpp-cuda-vulkan-studio/references/`: project archetypes and donor-reference guidance.
- `companion-skill-snippets/`: source-owned donor-library link blocks installed into companion
  skills such as `cuda-kernel-authoring`, `vulkan-compute-sync`, and `modern-cpp-cmake`.
- `research/`: web research and trigger-test notes that informed the reusable skill.
- `scripts/`: validation, sync, rollout, and watch helpers for publishing this package to Codex.
- `.codex/skills/cppstudio-repo-onboarding/`: project-level onboarding skill for agents working in
  this repo.

The installed copy at `/home/tarkan/.codex/skills/cpp-cuda-vulkan-studio` is a deployment target,
not the source of truth. Edit this repo, then publish with the scripts below.

## Requirements

Default repo validation and rollout require:

- Bash
- Python 3
- `rsync`
- Codex skill validator at
  `/home/tarkan/.codex/skills/.system/skill-creator/scripts/quick_validate.py`

Optional workflows require extra tools:

- `inotifywait` from `inotify-tools` for watch mode
- CMake, CTest, Ninja or Make, and a C++ compiler for full generated-project validation
- CUDA Toolkit and NVIDIA driver for CUDA lanes
- Vulkan SDK tools such as `glslc`, `spirv-val`, `vulkaninfo`, and validation layers for Vulkan lanes
- Nsight Systems, Nsight Compute, Nsight Graphics, RenderDoc, `clang-format`, and `clang-tidy` for
  optional profiling and quality lanes

This is not a Python application repo. Do not install Python packages globally for this repo unless
a future script explicitly adds project-local Python dependencies.

## Initial Setup

1. Clone or open this repository:

   ```bash
   cd /home/tarkan/Dropbox/work/MyTools/CppStudio
   ```

2. Confirm the source skill validates:

   ```bash
   ./scripts/validate.sh
   ```

3. Publish the source skill to user-level Codex:

   ```bash
   ./scripts/sync_to_codex.sh
   ```

4. For the complete package, including donor-library links in companion skills, run rollout:

   ```bash
   ./scripts/rollout_to_codex.sh
   ```

5. Restart any Codex session that needs to discover newly installed or changed skill metadata.

For normal setup, `rollout_to_codex.sh` is the best single command because it validates the repo,
syncs the canonical skill, installs companion-skill donor-library links, validates affected installed
skills, and verifies source/target parity.

## Daily Workflows

Validate repo changes:

```bash
./scripts/validate.sh
```

Run full generated-project validation after editing templates, scaffolding, CMake, or generated
project validation behavior:

```bash
./scripts/validate.sh --full
```

Preview skill sync changes:

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

## Using The Skill In Codex

After rollout and session restart, invoke the package by mentioning the skill or by asking for work
that matches its description:

```text
$cpp-cuda-vulkan-studio scaffold a new C++/CUDA/Vulkan app+library project called RayLab
```

```text
Upgrade this C++ renderer repo with the CppStudio backbone and keep CUDA/Vulkan optional.
```

```text
Find suitable donors for a real-time grooming and fur simulation tool, then wire the selected
patterns into this C++/Vulkan project.
```

The main skill coordinates companion skills:

- `modern-cpp-cmake` for CMake, target layout, tests, presets, and dependency wiring
- `cuda-kernel-authoring` for CUDA kernels, launch wrappers, and compute-sanitizer plans
- `vulkan-compute-sync` for Vulkan compute/render setup, descriptors, barriers, and frame lifetime
- `gpu-profiling-workstation` for local GPU profiling and frame debugging on this machine
- `verification-before-completion` before completion claims

## Creating A New C++/CUDA/Vulkan Project

The bundled scaffold script creates a project from
`skills/cpp-cuda-vulkan-studio/assets/app-library-template/`.

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/scaffold_gpu_cpp_project.py \
  --name RayLab \
  --output /tmp/RayLab
```

Useful options:

- `--namespace ray_lab`: override the generated C++ namespace.
- `--description "Short project description"`: render a project description into generated docs.
- `--force`: overwrite files that already exist at the destination.

Validate the generated project:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/validate_studio_backbone.py \
  /tmp/RayLab \
  --strict-source-layout
```

Then build and test from the generated project:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

## Upgrading An Existing Repo

For an existing C++ repo, apply the backbone to a temporary copy first unless the user explicitly
wants direct modification:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/apply_studio_backbone.py /path/to/repo
```

Useful options:

- `--project-name NAME`: override the rendered project name.
- `--namespace NAME`: override the rendered C++ namespace when replacing template sources.
- `--force`: overwrite existing backbone files.
- `--replace-cmake-lists`: replace the root `CMakeLists.txt`; use with care because this changes the
  existing build entrypoint.

After applying, validate the target repo:

```bash
python3 skills/cpp-cuda-vulkan-studio/scripts/validate_studio_backbone.py /path/to/repo
```

## Donor Library

The donor library lives at:

```bash
skills/cpp-cuda-vulkan-studio/references/donor-library
```

Start with:

```bash
skills/cpp-cuda-vulkan-studio/references/donor-library/README.md
skills/cpp-cuda-vulkan-studio/references/donor-library/selection-policy.md
```

Category files route agents toward appropriate donors for graphics, Vulkan, CUDA kernels, AI
runtimes, neural 3D, Gaussian splatting, grooming/fur, DCC scene pipelines, volumes, animation,
materials, CAD geometry, 3D/physics/GPU simulation, XR, and related infrastructure.

Validate donor-library link integrity with:

```bash
python3 scripts/validate_donor_library.py \
  skills/cpp-cuda-vulkan-studio/references/donor-library \
  --reference-root skills/cpp-cuda-vulkan-studio/references
```

`./scripts/validate.sh` and `./scripts/rollout_to_codex.sh` run this donor validator automatically.

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
TARGET_DIR=/path/to/skill ./scripts/sync_to_codex.sh
```

`rollout_to_codex.sh` rejects non-standard `TARGET_DIR` values unless explicitly allowed, because it
renders absolute donor-library links into companion skills:

```bash
ALLOW_ROLLOUT_TARGET_OVERRIDE=1 TARGET_DIR=/path/to/staging/skill ./scripts/rollout_to_codex.sh
```

Use that override only for deliberate staging.

## Editing Rules

- Edit `skills/cpp-cuda-vulkan-studio/` in this repo, not the installed user-level copy.
- Edit companion donor-link text in `companion-skill-snippets/`, not directly in installed companion
  skills.
- Keep the reusable skill generic. Do not add CudaGroomTool-only, ComfyNative-only, or other
  project-specific policy here.
- Preserve template placeholders such as `{{PROJECT_NAME}}`, `{{PROJECT_NAME_LOWER}}`,
  `{{CPP_NAMESPACE}}`, `{{DONOR_ROOT}}`, and `{{REFERENCE_ROOT}}`.
- Do not commit generated temp projects, build directories, profiler traces, `.pyc` files, or
  `__pycache__` directories.
- Prefer updating scripts when behavior needs to stay deterministic.

## Troubleshooting

Missing skill validator:

```text
Missing skill validator: /home/tarkan/.codex/skills/.system/skill-creator/scripts/quick_validate.py
```

Install or restore the system `skill-creator` skill in the target Codex home, then rerun validation.

Watch mode fails with `inotifywait is required for watch mode`:

```bash
sudo apt install inotify-tools
```

Full validation fails during CMake configure or build:

- Confirm CMake and a C++ compiler are installed.
- If CUDA or Vulkan-specific generated lanes are enabled, confirm the relevant SDK/tool paths.
- Fix template or validation behavior in the repo copy first, then rerun `./scripts/validate.sh --full`.

Rollout refuses a custom target:

- Use normal rollout for user-level installation.
- Use `ALLOW_ROLLOUT_TARGET_OVERRIDE=1` only when companion-skill links should intentionally point
  at the custom target.

## Close-Out Checklist For Agents

When finishing changes in this repo, report:

- repo-level files changed
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether `./scripts/sync_to_codex.sh` or `./scripts/rollout_to_codex.sh` was run
- any installed-tool gaps, such as missing `clang-format`, `clang-tidy`, CUDA tools, or Vulkan tools
