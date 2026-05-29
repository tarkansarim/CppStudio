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

## Installed Code-Map Trigger Matrix Confirmation

Read-only fresh-agent trigger probe on 2026-05-08 used the installed Codex skill paths after
`./scripts/rollout_to_codex.sh` and evaluated the dedicated code-map trigger cases rendered from
`research/donor-library/trigger-matrix.json`:

```bash
python3 scripts/render_trigger_eval_prompt.py \
  research/donor-library/trigger-matrix.json \
  --repo-root . \
  --installed-paths \
  --tag code-map \
  --write-result-template /tmp/cppstudio-trigger-codemap.json \
  > /tmp/cppstudio-trigger-codemap.md
```

The fresh evaluator opened the installed `cpp-cuda-vulkan-studio` skill plus the installed
`bootstrap_code_map.py`, `validate_code_map.py`, and `check_code_map_drift.py` scripts. It also
opened the installed template map docs and this research note. No files were edited.

Results:

- `code-map-existing-project-bootstrap`: pass. The installed skill surfaced audit-first existing
  project setup, required `bootstrap_code_map.py --audit-existing` before restructure/preserve/decline
  choices, required concrete findings/evidence/cleanup cost, delayed `--enable` until user route
  acceptance, and exposed repo-local validation/drift wrapper installation.
- `enabled-code-map-maintenance-closeout`: pass. The installed skill required target architecture
  index and manifest reads before source changes, both `check_code_map_drift.py --require-enabled`
  and `validate_code_map.py --require-enabled` before staging or committing, manifest/subsystem doc
  updates for uncovered paths or semantic ownership/data-flow changes, and separate dirty reporting
  for `AGENTS.md`, `CLAUDE.md`, repo-local skills, and agent metadata.
- `code-map-routing-smoke-proof`: pass. The installed skill made schema validation insufficient by
  itself, required a read-only fresh-session or subagent routing smoke when available, and defined the
  smoke as reading state/index/manifest, picking the first confident subsystem route for a concrete
  task, naming exact source/test paths, avoiding edits, stopping without broad source auditing, and
  grading the result pass/partial/fail.

This confirmation covers the installed-path behavior for the earlier code-map trigger matrix. The
static validator now requires dedicated code-map case names and `validate.sh` renders each case by
name so the coverage cannot silently collapse back to one aggregate `code-map` case.

## Sidecar Maintenance Lane Contract

Issue #59 added a fourth dedicated code-map trigger case:
`code-map-sidecar-maintenance-lane`. The intended behavior is bounded and conservative:

- Use a code-map-only sidecar when drift output, a long-running slice interval, ownership/data-flow
  changes, new or moved routable files, or stale subsystem docs would otherwise force the main worker
  to keep too much map context loaded.
- Give the sidecar a fixed snapshot anchor such as a Rewind checkpoint, temporary git anchor, commit,
  isolated worktree copy, or archive. The sidecar records that anchor and returns a map-only patch or
  map-file replacements plus assumptions. It does not edit the original worker's live worktree while
  source work continues; same-worktree edits require a serialized handoff with the original paused.
- The original worker may continue implementation, but it owns the final reconcile before commit:
  apply or merge sidecar output, rerun drift and schema validation against the current tree, and
  update or relaunch the sidecar if later source changes touched additional routable areas.
- Rewind checkpoints and temporary anchors are proof/snapshot boundaries, not public verified-slice
  commits. The normal clean public history unit remains the verified slice commit.
