# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is (read first)

CppStudio is **not a C++ application or library** — it is the canonical source for a bundle of
agent skills (authored for Codex `~/.codex/skills`, usable by any coding agent) that turn a coding
agent into a native C++/CUDA/Vulkan GPU development harness. The buildable C++ you see lives only
inside `skills/cpp-cuda-vulkan-studio/assets/app-library-template/` — it is a *template that agents
scaffold into new projects*, not something this repo builds and ships.

Do not treat this repo as a sample C++ project. The product is the reusable agent instructions,
donor-reference library, validation scripts, and project templates under `skills/`.

`AGENTS.md` is the authoritative operating doctrine for working in this repo. This file summarizes
the parts that change how you should act; when they conflict, `AGENTS.md` wins.

## How an agent works here (two modes)

You typically act in two connected modes, often in the same session:

1. **Co-engineer skills/rules (in this repo).** Work *with the user* to build and harden the skills
   under `skills/` and the doctrine (`AGENTS.md`, the code map, donor library). This is normal
   source work in this repo — see the commands and conventions below.
2. **Supervise a worker (in another repo).** Act as supervisor for a worker agent (typically a
   tmux-managed Codex worker) that builds app features in a *separate* target repo: poll, guide,
   interrogate, review, and unblock it. Do **not** patch the target repo directly — route fixes to
   its owner worker. The full doctrine is `skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/GUIDE.md` (a Codex skill;
   read it as a file — it is not Claude-loadable via the Skill tool). Reach the worker through
   `agent-tmux`/`agent-contact` relays.

The two modes form a loop: when supervision exposes a gap — the worker does something the skills
don't cover, or a current rule/skill fails — capture it and engineer the fix back into `skills/` and
the doctrine here (the `self-improving` discipline). A worker mistake that points to a reusable
CppStudio gap is a skill/rule bug to harden, not a one-off worker error.

## Source of truth and deployment

- **Edit `skills/` in this repo.** The installed copy at `~/.codex/skills/cpp-cuda-vulkan-studio`
  is a *deployment target*, not the source. Never hand-edit the installed copy as a durable change.
- Publish with `./scripts/rollout_to_codex.sh` (validates and syncs the router package, removes known
  former top-level CppStudio skills, installs the marked user-level `AGENTS.md` relay block,
  re-validates the install, verifies parity, and logs to
  `~/.codex/cppstudio-install-audit.jsonl`).
- `./scripts/sync_to_codex.sh [--dry-run]` is for diagnostics or a scoped single-skill sync only.
  It uses `rsync --delete` by default. `./scripts/watch_to_codex.sh` revalidates+syncs on change.

## Commands

### Repo validation (this is the "build/lint/test" of this repo)

```bash
./scripts/validate.sh                               # skill metadata + Python/shell syntax + package/donor/trigger integrity; run before any commit
./scripts/validate.sh --full                        # also scaffolds template projects and runs CMake/CTest CPU/CUDA/Vulkan/sanitizer lanes; run after template/CMake/scaffold/validation-behavior changes
python3 scripts/validate_code_map.py . --require-enabled   # validate this repo's own code map (subsystem manifest, routing, state parity)
```

Other targeted validators (all Python 3.10+): `quick_validate_skill.py <skill-dir>`,
`validate_skill_package.py <skill-dir>` (`--write-manifest` to regenerate),
`validate_skill_load_hygiene.py`, `validate_donor_library.py`, `validate_trigger_matrix.py`,
`validate_trigger_results.py`, `check_code_map_drift.py <repo-root> --require-enabled`,
`audit_donor_freshness.py` (report-only), `test_important_instruction_ledger.py`.

CI (`.github/workflows/validate.yml`) runs shell/Python syntax checks, ShellCheck, donor-library
and trigger-matrix validation, then `./scripts/validate.sh --full` with
`CPPSTUDIO_FULL_CUDA_ARCHITECTURES=75` and `CPPSTUDIO_SKIP_CUDA_RUNTIME_TESTS=1` (CI has no GPU).
Failures block merge.

### Generated-project template (when editing `assets/app-library-template/`)

The template ships CMake presets (CMake 3.25+, Ninja, C++20; CUDA device code C++17; Vulkan 1.3).
Run these from inside a scaffolded project (or the template dir during `--full` validation):

```bash
cmake --preset dev          && cmake --build --preset dev          # default: Vulkan on, CUDA off, debug
ctest  --preset quick --output-on-failure                          # host-only tests (excludes gpu/perf/nightly)
cmake --preset cuda-debug   && cmake --build --preset cuda-debug   # CUDA-only lane
ctest  --preset cuda  --output-on-failure
cmake --preset vulkan-debug && cmake --build --preset vulkan-debug
ctest  --preset vulkan --output-on-failure                         # also: vulkan-compute, vulkan-render, vulkan-shader, vulkan-validation
cmake --preset cuda-vulkan-combined                                # proves both lanes build together (not deep interop)
cmake --preset asan-ubsan   && ctest --preset asan-ubsan-quick     # host sanitizers
cmake --preset coverage     && ctest --preset coverage-quick
cmake --preset release      # warnings-as-errors;  also: profile, benchmark, vulkan-portability, ci-gpu
```

Toggle options at configure time: `PROJECT_CUDA_ARCHITECTURES=75;80;90` (default `native` via
nvidia-smi), `PROJECT_ENABLE_HOST_SANITIZERS`, `PROJECT_ENABLE_VULKAN_VALIDATION`,
`PROJECT_ENABLE_CLANG_TIDY`, `PROJECT_WARNINGS_AS_ERRORS`. Shaders compile GLSL → SPIR-V (`glslc`)
→ `spirv-val`; `.spv` is a build artifact, never committed. Style is `clang-format` (LLVM base,
4-space indent, 100 cols) and `clang-tidy`; report missing `clang-format`/`clang-tidy` at closeout
rather than skipping silently.

## Architecture

### Skill package

`cpp-cuda-vulkan-studio` is the **main coordinator** — load it first for any native C++/GPU/Vulkan/
CUDA work. It owns project scaffolding, the code-map protocol, donor routing, and validation lanes,
and it routes to internal specialist guides:

- `cppstudio-project-planner` — gates substantial greenfield work; research → Plan-mode decision →
  implementation handoff before any coding.
- `cppstudio-supervisor` — multi-slice supervision in *other* repos: review cadence, phase
  telemetry, evidence gates, parameter-surface closure, closeout.
- `native-cpp-gui-hud` — GUI/HUD/editor UI stack choice (ImGui/Qt/etc.).
- `agentic-control-harness` — local agent control surfaces (localhost HTTP/curl/CLI/MCP) so agents
  drive interactive apps; default from milestone 1 for interactive tools.
- `viewport-session-testing` — record/replay real UI/viewport sessions for before/after proof.
- `important-instruction-ledger` — active per-slice watchlist that survives compaction.
- `modern-cpp-cmake`, `cuda-kernel-authoring`, `vulkan-compute-sync`, `gpu-profiling-workstation` —
  domain-specific implementation/profiling lanes.

Skills are intentionally kept as separate packages (not one mega-router); validation rejects
unmanaged top-level `skills/*/SKILL.md` not in `managed_skills.sh`. Each skill carries a
`package-manifest.json` (per-file SHA-256, size, role, disclosure_group) used by sync/rollout to
detect tampering and unmanifested files — keep it current (`validate_skill_package.py --write-manifest`).

### Code map (this repo's navigation layer)

This repo has its own *enabled* code map. Before editing, read
`docs/CODEBASE_ARCHITECTURE_INDEX.md`, pick the matching subsystem doc, then inspect the primary
paths it names. The 7 subsystems (`docs/CODEBASE_SUBSYSTEM_MANIFEST.json` ↔ `docs/SUBSYSTEMS/*.md`):
`source-skill-routing`, `donor-library`, `generated-project-template`, `validation-sync-rollout`,
`companion-snippets-relay`, `research-notes`, `public-docs-ci`. If a change touches a subsystem's
behavior, update its `SUBSYSTEMS/*.md` doc and the manifest in the same work stream (drift is a
validation failure).

### Donor library

`skills/cpp-cuda-vulkan-studio/references/donor-library/` is a nested, lazily-loaded reference set
(entrypoint → selection policy → category files → deep profiles) so agents route to relevant 3D/
rendering/simulation/AI/CUDA/Vulkan/infra references without loading the whole library. Profiles
carry license tiers (`safe-donor`, `dependency-candidate`, `study-only`) and caveats
(`reference-only`, `mixed-native`). `research/` (cuda-lane, vulkan-lane, donor-library) holds the
source-provenance research that *feeds* skill/template/donor updates — it is not part of generated
projects.

### Generated-project template architecture

`assets/app-library-template/` is lane-disciplined: a mandatory host-only `core` library, an
optional `cuda` library (`PROJECT_ENABLE_CUDA`, `PROJECT_HAS_CUDA` guard), an optional `render`
Vulkan library (`PROJECT_ENABLE_VULKAN`, `PROJECT_HAS_VULKAN` guard), one executable linking the
enabled lanes, plus an always-built viewport-session test target. CTest labels (`quick`, `gpu`,
`cuda`, `vulkan`, `shader`, `compute`, `render`, `validation`, `benchmark`, `nightly`) enforce lane
isolation. Generated projects get their own code-map bootstrap and pre-commit drift checks.

## Conventions that override default behavior

- **Donor-first:** before touching skill/planning/GUI/template/donor code, read the relevant skill,
  the code-map route, and the smallest matching donor route; state which sources ground the change.
  No matching donor → record the gap and research before designing; do not fill from memory.
- **Vulkan-first default:** for unspecified GPU/3D/realtime/XR/cross-platform work, recommend and
  route Vulkan; keep Vulkan projects Vulkan-only unless CUDA/interop is explicitly requested or
  requirements force NVIDIA-only. Keep existing CUDA support intact; keep the global skill generic.
- **Keep reusable policy generic:** no machine-specific paths, private app names, or app-only rules
  in `skills/`. Validation blocks private provenance (codenames, `/home/...` paths, private markers)
  from shipping.
- **Marked relay block:** when installing user-level files, only the marked CppStudio user-agents
  relay is managed and may be replaced on reinstall; content outside it is user-owned and must be
  preserved. Relay targets must be real `AGENTS.md` files, not symlinks.
- **Template placeholders:** preserve `{{PROJECT_NAME}}`, `{{CPP_NAMESPACE}}`, etc. Never commit
  generated temp projects, build dirs, profiler traces, or `__pycache__`.
- **Trigger lane:** after changing skills, descriptions, donor categories/profiles/routing, or
  README donor inventories, run a sub-agent trigger lane with realistic prompts and confirm the
  expected skill/donor is selected before committing.
- **Change history before push:** update `CHANGELOG.md` (durable) and the README *Recent Commit
  Highlights* (front-page, commit-ID-keyed) for any change to setup, routing, generated projects,
  validation, donor behavior, public docs, install, or sync. Before committing/pushing, inspect the
  staged diff and confirm both are included and readable.
- **Supervised-worker interrogation:** when a supervised worker makes/skips/rejects a decision for
  unclear reasons, interrogate it (exact skill routes, donor routes, sources, decision criteria,
  verification commands) and audit the answer against transcript/files before claiming a root cause
  or patching a skill.
- **Closeout report** (per `AGENTS.md`): files changed, whether `validate.sh`/`--full` passed,
  which rollout/sync was run and why, trigger-lane status when routing changed, CHANGELOG + README
  highlight status (or why non-qualifying), and any tool gaps.

## Key references

- `AGENTS.md` — full operating doctrine (authoritative).
- `docs/CODEBASE_ARCHITECTURE_INDEX.md` + `docs/SUBSYSTEMS/*.md` — navigate before editing.
- `docs/maintainer-guide.md` — validate/publish/code-map procedures.
- `docs/agent-context/SLICE_WATCHLIST.md` — active supervision gates (revisit before nudges/closeout).
- `CONTRIBUTING.md` — contribution flow.
