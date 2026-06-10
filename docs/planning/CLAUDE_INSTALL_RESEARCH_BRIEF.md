# CppStudio → Claude Install — Pre-Plan Research Brief

Status: Level 1 (research) complete; Level 2+ blocked on an ownership/conflict decision (below).
Type: existing-repo upgrade (CppStudio). Not a greenfield artist tool — infra/install lane only.

## Level 0 — Intake & Context

- Goal: let Claude load CppStudio's validated skills/rules natively, the way Codex does, instead of
  re-discovering them (this session proved the rules correct but Claude could not load them).
- Existing Codex pipeline to mirror: `scripts/rollout_to_codex.sh` (+ `sync_to_codex.sh`,
  `managed_skills.sh`, `install_user_agents_relay.py`, `cppstudio-install-audit.jsonl`,
  `companion-skill-snippets/user-agents/cppstudio-relay.md`). It validates → syncs the main +10
  auxiliary skills to `~/.codex/skills/` → validates each → donor check → parity diff → merges a
  MARKED relay block (`<!-- cppstudio-user-agents-relay:begin/end -->`) into `~/.codex/AGENTS.md` →
  audit log. Symlink-rejection + transactional rollback throughout.

## Level 1 — Research Findings

GOOD NEWS (technically feasible):
- Claude Code already loads `~/.claude/skills/` (populated, ~29 skills). Install target exists + works.
- SKILL.md frontmatter (`name` + `description`) MATCHES Claude's format → CppStudio skills are
  Claude-loadable as-is; minimal/no format adaptation.

THE COMPLICATION (`~/.claude` is NOT a clean slate):
- `~/.claude` is an existing **locally-managed multi-provider ecosystem**. the local doctrine manager (a private multi-provider doctrine repo) has
  `source/claude`, `generated/{claude,codex}`, `inventory.json`, `manifest.json`, `modules` — it is
  THE pipeline that already generates+owns Claude skills AND owns `~/.claude/CLAUDE.md` (marked
  its own marked comment blocks; other installers like rewind-checkpoints add their
  own marked blocks).
- Overlap/divergence already in `~/.claude/skills/`:
  - NAME COLLISIONS, different content: `agentic-control-harness`, `native-cpp-gui-hud` (the
    `~/.claude` versions DIFFER from CppStudio source — separately maintained Claude variants).
  - COVERAGE OVERLAP, different names: `cpp-cuda-project-layout`, `cpp-cuda-research-to-plan`,
    `cuda-profiling-and-debugging`, `donor-library-system`, `code-map-project-memory` ≈ CppStudio's
    `cpp-cuda-vulkan-studio`, `cppstudio-project-planner`, `gpu-profiling-workstation`, donor lib,
    code map.
- CppStudio-UNIQUE skills NOT present in `~/.claude/skills/` (the ones whose absence bit us this
  session): `cpp-cuda-vulkan-studio` (coordinator), `cppstudio-supervisor`, `viewport-session-testing`,
  `vulkan-compute-sync`, `modern-cpp-cmake`, `cuda-kernel-authoring`, `important-instruction-ledger`.

## CONFLICT TO RESOLVE (flagged per doctrine)

The literal request — "make CppStudio install into `~/.claude` like `~/.codex`" — collides with:
- Provider-lane separation (global CLAUDE.md): "Keep provider lanes separate… installers… deployment
  target separate from Codex"; "Do not normalize Codex and Claude doctrine into one deployed file or
  one shared runtime folder."
- Ownership: the local doctrine manager already owns the `~/.claude` skill ecosystem + `~/.claude/CLAUDE.md`.
- Doctrine routing: durable `~/.claude/CLAUDE.md` changes must flow through the local doctrine manager's ticketed
  pipeline — so a CppStudio-direct relay write is not allowed.

So the decision is not "write `rollout_to_claude.sh`" — it is HOW CppStudio's Claude deployment
coexists with the local doctrine manager's ownership and lane separation.

## Key Decisions (Plan mode)

1. OWNERSHIP / PIPELINE:
   - (a) CppStudio-owned separate Claude lane: `rollout_to_claude.sh` → `~/.claude/skills/`, with a
     distinct managed list + audit, coordinating-not-clobbering, relay routed via the local doctrine manager.
   - (b) Route CppStudio skills THROUGH the local doctrine manager's Claude pipeline (the doctrine manager adopts/imports
     CppStudio skills as Claude source; single Claude owner).
   - (c) Hybrid.
2. COLLISION / RECONCILIATION for overlapping/diverged skills (agentic-control-harness,
   native-cpp-gui-hud; the cpp-cuda-* coverage): coexist (namespace), replace, merge, or
   selective-install only the 7 unique skills.
3. CLAUDE.md RELAY: route the Claude relay block through the local doctrine manager (owns `~/.claude/CLAUDE.md`),
   mirroring how other installers add marked blocks.
4. SCOPE: all 11, or the 7 unique first.

## Recommended Default (lean — pending user decision)

- Phase 1: install the **7 UNIQUE CppStudio skills** into `~/.claude/skills/` via a **separate
  CppStudio Claude lane** (`rollout_to_claude.sh` + own managed list + audit; format already
  compatible), **avoiding the collision skills**; route the CLAUDE.md relay through the local doctrine manager.
  Gets Claude the missing proven skills fast without clobbering the locally-managed set or
  breaking lane separation.
- Phase 2 (follow-up): reconcile the overlapping/diverged skills (single source-of-truth per skill),
  via the local doctrine manager where it owns the Claude variant.

## Plan-mode Handoff

Switch to Plan mode to lock: ownership/pipeline model, reconciliation strategy, relay routing, and
scope — before any installer code.
