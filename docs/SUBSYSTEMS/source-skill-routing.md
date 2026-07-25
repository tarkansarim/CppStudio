# Source Skill And Agent Routing

Owns the installed `cpp-cuda-vulkan-studio` router, progressive process states,
technical overlay routing, and the specialist guides packaged below it.

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/cpp-cuda-vulkan-studio/modules/studio-core.md`
- `skills/cpp-cuda-vulkan-studio/modules/technical-overlays.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/standard.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/investigative.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/governed.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/recovery.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/strict-doctrine-index.md`
- `skills/cpp-cuda-vulkan-studio/modules/process/strict-doctrine-reference.md`
- `skills/cpp-cuda-vulkan-studio/modules/cppstudio-project-planner/GUIDE.md`
- `skills/cpp-cuda-vulkan-studio/modules/cppstudio-supervisor/GUIDE.md`
- `scripts/validate.sh`
- `scripts/rollout_to_codex.sh`
- `scripts/rollout_to_claude.sh`

The former detailed subsystem document is preserved at
`docs/SUBSYSTEMS/source-skill-routing-strict-reference.md`. It records the old
strict posture but is not current routing authority.

## Runtime Contract

CppStudio loads one small router. The router reads `studio-core.md`, selects one
process state, and adds only technical overlays whose contracts are touched:

`base invariants + one process state + relevant technical overlays`

`Standard` is the default. `Investigative` handles a named uncertainty.
`Governed` handles connected work through Planning Harness. `Recovery` is a
temporary incident state for contradictory evidence, speculative patch
accumulation, scope drift, or repeated tool workarounds.

Process escalation does not expand user scope or authority. Recovery ends when
the incident is reconciled.

## Planning Boundary

Planning Harness is the sole durable owner of roadmaps, milestones, work
packages, work items, approvals, continuation, and completion state. CppStudio
adds C++ GPU engineering facts and proof requirements to that plan. It does not
create a parallel Level 0-5 plan, mandatory per-slice packet, or universal
watchlist.

## Review And Telemetry

Reviews are triggered by a changed protected contract, a materially changed risk
boundary, unresolved contradictory evidence, uncertain integration ownership, or
an explicit user request. There is no fixed two-slice or three-slice cadence.

Phase telemetry and the legacy instruction ledger remain available as selective
Recovery diagnostics. They are not active in every worker reply or ordinary
closeout.

## Technical Routing

`modules/technical-overlays.md` maps affected contracts to the smallest
specialist guide. Task size selects process state; touched engineering contracts
select overlays. Several overlays may be active, but adjacency alone does not
activate one.

## Validation

`scripts/validate.sh` enforces:

- one top-level relay and no nested discoverable `SKILL.md`;
- presence and size limits for the active progressive-enforcement files;
- exact phrases defining state, planning, review, and telemetry ownership;
- preservation of the former strict doctrine as non-default references;
- package-manifest integrity and source/install parity;
- trigger, donor, syntax, and generated-template contracts already owned by the
  repository.

Regenerate `skills/cpp-cuda-vulkan-studio/package-manifest.json` after changing
package files. Normal release installs both provider snapshots through their
source-owned rollout scripts.
