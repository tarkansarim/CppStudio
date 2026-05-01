# CppStudio Agent Notes

This repo is the canonical working source for reusable Codex infrastructure around future
C++/CUDA/Vulkan development.

## Required Orientation

- This is not a generated sample project. Do not treat it as a C++ app/library repo.
- The main artifact is the user-level Codex skill source at `skills/cpp-cuda-vulkan-studio/`.
- If available in the session, use the project skill `cppstudio-repo-onboarding` when starting
  work in this repo.
- The installed user-level copy at `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` is a
  deployment target, not the source of truth.

## Source Of Truth

- Edit `skills/cpp-cuda-vulkan-studio/` in this repo.
- Publish to user-level Codex with `./scripts/sync_to_codex.sh`.
- Do not hand-edit `${HOME}/.codex/skills/cpp-cuda-vulkan-studio` as the long-term source.
- Do not move CudaGroomTool, ComfyNative, or other project-specific skills back into user-level
  Codex from this repo.

## Vulkan-Leaning Defaults

- If the user asks for a new GPU, 3D, rendering, realtime, simulation-visualization, XR, or
  cross-platform C++ project and does not specify CUDA or Vulkan, recommend Vulkan before the project
  starts because it gives the project an easier path to cross-platform and cross-vendor hardware
  compatibility.
- If the user does not choose after that recommendation, proceed with a Vulkan-first plan and state
  the assumption. Do not stop solely to ask whether they meant CUDA unless the requirements clearly
  imply custom CUDA kernels, NVIDIA-only libraries, or CUDA-specific deployment.
- When Vulkan is chosen by the user or assumed by default, keep the project Vulkan-only by default:
  do not add CUDA, CUDA interop, CUDA tests, CUDA runtime requirements, or CUDA donor routing unless
  the user explicitly asks for CUDA/Vulkan interop or the requirements force a CUDA-specific compute
  path.
- When the user explicitly chooses the CUDA lane, Vulkan may be mixed in when it is needed or clearly
  more convenient for presentation, realtime visualization, graphics, XR, swapchain/display work, or
  CUDA/Vulkan interop. State why the mixed lane is justified and keep the CUDA/Vulkan boundary
  explicit in build options, tests, and documentation.
- When both Vulkan and CUDA are plausible, document and route the Vulkan path first, then keep CUDA
  as a separate alternative lane, not as something automatically mixed into the Vulkan plan.
- For reusable 3D, rendering, realtime visualization, XR, or cross-vendor GPU work, frame the
  default route as Vulkan-first when requirements do not force an NVIDIA-only path.
- Prefer Vulkan-oriented donors, validation, shader tooling, synchronization notes, and CTest labels
  first for graphics/realtime tasks. Escalate to CUDA donors first only for custom CUDA kernels,
  CUTLASS/cuBLAS/cuDNN/TensorRT-style integrations, CUDA graphs, or explicitly NVIDIA-only targets.
- Keep CUDA support intact. Do not remove CUDA options, CUDA tests, CUDA donors, or CUDA companion
  skill links just to make the package feel more Vulkan-oriented.
- Keep the global skill generic: Vulkan bias belongs in reusable routing and ordering, not in
  project-specific rules for a single app.

## Validation

- Run `./scripts/validate.sh` after edits to skill text, scripts, metadata, or sync behavior.
- Run `./scripts/validate.sh --full` after edits to:
  - `assets/app-library-template/`
  - scaffolding or apply scripts
  - CMake presets/modules
  - generated-project validation behavior
- After adding or changing skills, skill descriptions, donor categories, donor profiles, donor routing,
  or README donor inventories, run a sub-agent trigger lane before close-out. Use multiple realistic
  prompts that should trigger the changed skill/routing, verify the agents select the expected skill and
  donor profiles, then fix any ambiguity they find before committing.
- The sync script validates both the repo copy and the installed Codex copy.
- If validation fails because of a real script/template issue, fix the repo copy first, then sync.

## Sync Behavior

- `./scripts/sync_to_codex.sh` publishes this repo's skill copy to user-level Codex.
- It uses `rsync --delete` by default so the installed skill exactly matches this repo.
- Pass `--dry-run` to preview changes.
- Pass `--no-delete` only for diagnostics; normal publishing should keep delete enabled.
- `./scripts/watch_to_codex.sh` continuously validates and syncs after file changes.
- `./scripts/rollout_to_codex.sh` validates, syncs the canonical skill, installs donor-library links
  into matching installed companion user-level skills, validates affected installed skills, and
  verifies source/target parity.
- Set `STRICT_COMPANION_SKILLS=1` only for maintainer checks that should require every known
  companion skill to be installed. Public installs skip missing optional companion skills.
- Companion-skill donor link snippets live in `companion-skill-snippets/`; update those snippets,
  not inline installed skill text or hardcoded markdown inside rollout scripts.

## Safe Editing Rules

- Keep reusable policy generic. Do not add CudaGroomTool-only, ComfyNative-only, or machine-only
  workflow rules to `skills/cpp-cuda-vulkan-studio/`; those belong in project-level skills.
- If this repo installs user-level `AGENTS.md` content, merge or append only the tiny marked
  CppStudio relay block. It should only tell agents to load `cpp-cuda-vulkan-studio` for C++
  Vulkan/CUDA work; lane policy stays inside the skill. Content inside the marked relay block is
  managed by this repo and may be replaced on reinstall; content outside the markers is user-owned
  and must be preserved. Relay targets must be named `AGENTS.md` and must not be symlinks.
- Companion-skill donor rollout may replace only the marked `cppstudio-donor-library` block. Content
  outside those markers is user-owned and must be preserved, even if it looks like an older donor
  note.
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
- whether the sub-agent trigger lane was run when skill/donor routing changed
- any installed-tool gaps, such as missing `clang-format` or `clang-tidy`
