# Code Map Trigger Lane

Read-only subagent checks on 2026-05-02 used a Wetbrush target repo with an existing maintained map.
Wetbrush does not use the newer `.cppstudio/code-map-state.json` marker, but its `AGENTS.md`
declares map maintenance mandatory and its routing lives in:

- `docs/CODEBASE_ARCHITECTURE_INDEX.md`
- `docs/CODEBASE_SUBSYSTEM_MANIFEST.json`
- repo-local `skills/wetbrush-*/SKILL.md`

## Results

- Particle carrier / Eq.15 / G2P prompt loaded CppStudio, CUDA, profiling, Wetbrush onboarding, and
  Wetbrush particle/CUDA/replay skills. It used the Wetbrush map before choosing
  `particle_carrier_path` as the primary route and `cuda_kernel_ownership` plus
  `gui_playback_reporting` as secondary routes.
- Persistent canvas / late-frame particle visualization prompt used the Wetbrush map before choosing
  `phase4_persistent_canvas` with `rendering_pipeline` as a co-owner route.
- Brush feel / tablet fast-stroke prompt used Wetbrush `AGENTS.md`, the architecture index, manifest,
  repo-local onboarding skill, and subsystem docs before choosing `input_and_pen` with
  `brush_dynamics` as a secondary route.

## Follow-Up Applied

The CppStudio skill now states that, when working in a target repo other than CppStudio itself, the
target repo's `AGENTS.md`, codebase map, manifest, and repo-local skills are the subsystem routing
authority. CppStudio provides the native C++/GPU lane policy, backbone, validation, and donor routing
around that target map.

## Synced-Skill Confirmation

After syncing the updated `cpp-cuda-vulkan-studio` skill to user-level Codex, two additional
read-only subagents were run against Wetbrush:

- Eq.15/G2P and timing-attribution prompt used Wetbrush `AGENTS.md`, the architecture index, and the
  manifest before selecting `particle_carrier_path` as the primary route and
  `gui_playback_reporting`, `cuda_kernel_ownership`, and `app_orchestration` as secondary routes.
- Brush feel and tablet fast-stroke prompt used Wetbrush `AGENTS.md`, the architecture index, the
  manifest, and the matching subsystem docs before selecting `brush_dynamics` plus
  `input_and_pen`.

Both confirmations treated Wetbrush's project-local map as the target routing authority even though
the target repo does not have `.cppstudio/code-map-state.json`.
