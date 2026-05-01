![CppStudio banner](assets/cppstudio-banner.png)

# CppStudio

CppStudio is an agentic skills package for GPU-native C++ engineering. It is the canonical source
for the reusable `cpp-cuda-vulkan-studio` Codex skill, its bundled Vulkan-first C++/CUDA project
backbone, research notes, donor-reference routing, companion-skill snippets, and rollout scripts.

This package is designed for ChatGPT Codex skill workflows. Use it when you want Codex agents to
create, audit, or upgrade C++/CUDA/Vulkan projects with consistent build structure, validation lanes,
profiling hooks, and curated external reference selection for Vulkan, CUDA, WebGPU, rendering, 3D,
and AI-runtime work.

## What This Repo Contains

- `skills/cpp-cuda-vulkan-studio/`: source of truth for the user-level Codex skill.
- `skills/cpp-cuda-vulkan-studio/assets/app-library-template/`: reusable generated-project
  template for Vulkan-first app+library C++ repos with explicit CUDA and mixed interop lanes.
- `skills/cpp-cuda-vulkan-studio/references/`: project archetypes and donor-reference guidance for
  Vulkan/CUDA lanes, WebGPU/WebGL, renderer backbones, path tracing, engine architecture, assets,
  simulation, XR, and AI-runtime work.
- `companion-skill-snippets/`: source-owned donor-library link blocks installed into companion
  skills such as `cuda-kernel-authoring`, `vulkan-compute-sync`, and `modern-cpp-cmake`.
- `research/`: web research and trigger-test notes that informed the reusable skill.
- `scripts/`: validation, sync, rollout, and watch helpers for publishing this package to Codex.
- `.codex/skills/cppstudio-repo-onboarding/`: project-level onboarding skill for agents working in
  this repo.

The installed copy at `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` is a deployment target, not the
source of truth. Edit this repo, then publish with the scripts below.

## Requirements

Default repo validation and rollout require:

- Bash
- Python 3.10 or newer
- `rsync`
- Codex skill validator at
  `${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py`

The shipped install, sync, rollout, and validation entrypoints are Bash/POSIX scripts for Linux,
macOS, or Windows through WSL. Windows users can use WSL for the scripted flow or the manual
PowerShell copy steps below.

You can ignore these until you ask Codex to build or validate generated C++ GPU projects locally:

- `inotifywait` from `inotify-tools` for watch mode
- CMake, CTest, Ninja, and a C++ compiler for full generated-project validation
- CUDA Toolkit and NVIDIA driver for CUDA lanes
- Vulkan SDK tools such as `glslc`, `spirv-val`, `vulkaninfo`, and validation layers for Vulkan lanes
- Nsight Systems for optional profiling smoke lanes
- Nsight Compute for explicit CUDA profiling lanes
- Nsight Graphics, RenderDoc, `clang-format`, and `clang-tidy` for optional graphics-debug and
  quality lanes

This is not a Python application repo. Do not install Python packages globally for this repo unless
a future script explicitly adds project-local Python dependencies.

## Quick Install

CppStudio is meant to be installed and used agentically. If your coding agent has shell access to
the machine, you can ask it to set this repo up for you:

```text
Install this CppStudio repo into my ChatGPT Codex home. Use the repo scripts, preserve my existing
AGENTS.md content, and report what changed.
```

For most users, that agent-run setup is enough. The agent installs the Codex skill package and donor
routing for you. You do not need CUDA, Vulkan, CMake, or a compiler just to install this repo into
Codex.

If your agent asks what command to use, this is the normal install/update path:

```bash
cd /path/to/CppStudio
./scripts/rollout_to_codex.sh
```

Then restart any Codex session that needs to discover newly installed or changed skill metadata.

For a smaller install that updates only the main `cpp-cuda-vulkan-studio` skill without companion
donor links:

```bash
cd /path/to/CppStudio
./scripts/sync_to_codex.sh
```

For a normal install, ask the agent to use rollout. That script validates the repo internally, syncs
the canonical skill, installs donor-library links into matching companion skills, validates affected
installed skills, and verifies source/target parity before the agent reports back.

## When To Install GPU Tools

Install extra host tools only when you need that lane on the machine you are using:

| Need | Install |
|------|---------|
| Use CppStudio as a Codex skill | Nothing beyond the quick install requirements |
| Validate generated C++ projects locally | CMake, Ninja or another build tool, and a C++ compiler |
| Work on Vulkan projects locally | Vulkan SDK tools such as `glslc`, `spirv-val`, `vulkaninfo`, and validation layers |
| Work on CUDA projects locally | NVIDIA driver, CUDA Toolkit, `nvcc`, and Compute Sanitizer |
| Run optional quality/profiling lanes | `clang-format`, `clang-tidy`, RenderDoc, Nsight tools, or platform-specific profilers |

Detailed Linux, macOS, and Windows commands live in
[docs/host-toolchain-setup.md](docs/host-toolchain-setup.md). They are intentionally kept out of
the main install path because many users only need the skill installed, not a full GPU development
workstation prepared on day one.

## Manual Installation By Platform

Use manual installation when the agent cannot run the Bash rollout scripts or when you want to review
each copied path directly. Manual install touches only the managed `cpp-cuda-vulkan-studio` skill
folder and, if requested, the marked relay block in user-level `AGENTS.md`. User-created sibling
skills under `${HOME}/.codex/skills` are not part of this package and should be left alone.

Linux:

```bash
cd /path/to/CppStudio
mkdir -p "${HOME}/.codex/skills"
rm -rf "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
cp -a skills/cpp-cuda-vulkan-studio "${HOME}/.codex/skills/"
python3 "${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
  "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
```

macOS:

```bash
cd /path/to/CppStudio
mkdir -p "${HOME}/.codex/skills"
rm -rf "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
cp -a skills/cpp-cuda-vulkan-studio "${HOME}/.codex/skills/"
python3 "${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
  "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
```

Windows PowerShell:

```powershell
Set-Location C:\path\to\CppStudio
$CodexHome = Join-Path $HOME ".codex"
$SkillsRoot = Join-Path $CodexHome "skills"
$SkillTarget = Join-Path $SkillsRoot "cpp-cuda-vulkan-studio"
New-Item -ItemType Directory -Force $SkillsRoot | Out-Null
if (Test-Path $SkillTarget) { Remove-Item -Recurse -Force $SkillTarget }
Copy-Item -Recurse -Force ".\skills\cpp-cuda-vulkan-studio" $SkillTarget
python (Join-Path $HOME ".codex\skills\.system\skill-creator\scripts\quick_validate.py") $SkillTarget
```

Optional relay install for any platform with Python:

```bash
python3 scripts/install_user_agents_relay.py \
  --install \
  --target "${HOME}/.codex/AGENTS.md" \
  --expected-target "${HOME}/.codex/AGENTS.md" \
  --snippet companion-skill-snippets/user-agents/cppstudio-relay.md
```

Windows PowerShell equivalent:

```powershell
$AgentsPath = Join-Path $CodexHome "AGENTS.md"
python .\scripts\install_user_agents_relay.py `
  --install `
  --target $AgentsPath `
  --expected-target $AgentsPath `
  --snippet ".\companion-skill-snippets\user-agents\cppstudio-relay.md"
```

Optional companion donor-link install for any platform with Python:

```bash
python3 scripts/install_companion_donor_links.py \
  --install \
  --codex-home "${HOME}/.codex" \
  --donor-root "${HOME}/.codex/skills/cpp-cuda-vulkan-studio/references/donor-library" \
  --source-skill-dir skills/cpp-cuda-vulkan-studio \
  --snippet-root companion-skill-snippets
```

Windows PowerShell equivalent:

```powershell
$DonorRoot = Join-Path $SkillTarget "references\donor-library"
python .\scripts\install_companion_donor_links.py `
  --install `
  --codex-home $CodexHome `
  --donor-root $DonorRoot `
  --source-skill-dir ".\skills\cpp-cuda-vulkan-studio" `
  --snippet-root ".\companion-skill-snippets"
```

Restart any Codex session after manual installation so changed skill metadata is rediscovered.

## What The Agent Installs

When you ask a coding agent to install CppStudio, it should use the repo scripts whenever possible:

```bash
./scripts/rollout_to_codex.sh
```

That command installs the main skill and donor-library links into the Codex home on the machine where
the command runs. The default Codex home is `${HOME}/.codex`; agents can use `SYNC_CODEX_HOME` when
they need to install into a different Codex home on the same machine.

If the agent cannot use the script and needs to install manually, it should preserve the same
ownership rules:

1. Copy or sync `skills/cpp-cuda-vulkan-studio/` to
   `${SYNC_CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio`.
2. Merge only `companion-skill-snippets/user-agents/cppstudio-relay.md` into the user-level
   `AGENTS.md` if you want global routing.
3. Preserve any existing `AGENTS.md` content outside the CppStudio markers.
4. Replace only the marked CppStudio relay block if it already exists.
5. Add companion donor-library blocks only to matching installed companion skills.
6. Validate the result before reporting that the install is complete.

The managed marker blocks are the only script-owned regions:

- `<!-- cppstudio-user-agents-relay:begin -->` through
  `<!-- cppstudio-user-agents-relay:end -->`
- `<!-- cppstudio-donor-library:begin -->` through
  `<!-- cppstudio-donor-library:end -->`

Content inside those markers may be replaced by reinstall. Content outside those markers is
user-owned and must be preserved. Duplicate or mismatched markers should be treated as a manual
cleanup problem before reinstalling.

The user-level `AGENTS.md` relay is intentionally not a full engineering policy. It only loads
`cpp-cuda-vulkan-studio` for C++ Vulkan, C++ CUDA, and mixed CUDA/Vulkan work. The C++ GPU mindset,
including Vulkan lifetime discipline, lane separation, donor-first design, visual/performance
evidence, and git-commit rollback expectations, lives inside the skill so it is active only for
relevant work and does not overwrite a user's personal global agent rules.

## Command Reference For Agents And Maintainers

This section is for coding agents and maintainers editing CppStudio itself. It is not a list of
daily tasks for users installing the skill, and users are not expected to run these commands by hand.

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

That relay is intentionally tiny: it only tells agents to load `cpp-cuda-vulkan-studio` for C++
Vulkan/CUDA work. The script preserves existing `AGENTS.md` content and replaces only the marked
CppStudio relay block if one already exists. The relay target must be named `AGENTS.md`; a custom
relay target requires `ALLOW_USER_AGENTS_RELAY_TARGET_OVERRIDE=1` and must not be a symlink.

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
Upgrade this C++ renderer repo with the CppStudio backbone; use Vulkan by default unless CUDA is explicitly needed.
```

```text
Find suitable donors for a real-time grooming and fur simulation tool, then wire the selected
patterns into this C++/Vulkan project.
```

The main skill coordinates companion skills:

- `modern-cpp-cmake` for CMake, target layout, tests, presets, and dependency wiring
- `cuda-kernel-authoring` for CUDA kernels, launch wrappers, and compute-sanitizer plans
- `vulkan-compute-sync` for Vulkan compute/render setup, descriptors, barriers, and frame lifetime
- optional environment-specific profiling or frame-debugging skills/tools when the active session
  exposes them and performance or capture evidence is needed
- `verification-before-completion` before completion claims

## Creating A New Vulkan-First C++ Project

Normal use is agentic: ask Codex to scaffold, validate, and adapt the generated project for you.

```text
Use $cpp-cuda-vulkan-studio to create a Vulkan-first C++ project named RayLab and validate the quick
CTest lane.
```

The script below is the reproducible command the agent can use. It creates a project from
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
registered labeled tests. You can also run the commands directly from the generated project:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

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

## Upgrading An Existing Repo

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

Category files route agents toward appropriate donors for Vulkan foundation tooling, glTF/runtime
assets, renderer backbones, runtime mesh pipelines, graphics, CUDA kernels, AI runtimes, ML compilers,
neural 3D, Gaussian splatting, grooming/fur, DCC scene pipelines, volumes, animation, materials, CAD
geometry, 3D/physics/GPU simulation, XR, and related infrastructure.

Validate donor-library link integrity with:

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

## License

CppStudio is released under [The Unlicense](LICENSE) for unrestricted reuse.

## Troubleshooting

Missing or old Python:

```text
Python 3.10+ is required
```

Install Python 3.10 or newer and rerun validation.

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

## Close-Out Checklist For Agents

When finishing changes in this repo, report:

- repo-level files changed
- whether `./scripts/validate.sh` or `./scripts/validate.sh --full` passed
- whether `./scripts/sync_to_codex.sh` or `./scripts/rollout_to_codex.sh` was run
- any installed-tool gaps, such as missing `clang-format`, `clang-tidy`, CUDA tools, or Vulkan tools
