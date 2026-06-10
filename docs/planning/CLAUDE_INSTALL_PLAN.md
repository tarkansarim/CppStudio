# CppStudio → Claude Install — Implementation Plan

Decisions (locked): (1) CppStudio-owned **separate Claude lane**; (2) **all 11 skills, reconcile
overlaps now**; (3) `~/.claude/CLAUDE.md` relay routed through **the local doctrine manager**. Format is already
Claude-compatible (SKILL.md frontmatter matches).

## Architecture — separate Claude lane (mirrors Codex lane, kept fully separate per doctrine)

New CppStudio files (Claude lane; never shares runtime folders/files with the Codex lane):
- `scripts/managed_claude_skills.sh` — the Claude managed list (11 skills) + per-skill reconciliation
  disposition (own | replace-AD | coexist).
- `scripts/sync_to_claude.sh` — sync one skill → `~/.claude/skills/<name>` (mirror `sync_to_codex.sh`:
  symlink-reject, rsync --delete, parity diff).
- `scripts/rollout_to_claude.sh` — validate → sync all managed → validate each → donor/parity diff →
  audit (`~/.claude/cppstudio-claude-install-audit.jsonl`) → relay step (delegated to the local doctrine manager).
- `companion-skill-snippets/user-claude/cppstudio-relay.md` — the Claude relay snippet ("load
  cpp-cuda-vulkan-studio first").
- Reuse existing validators (`quick_validate_skill.py`, `validate_skill_package.py`) — provider-neutral.

## Reconciliation (all 11, now) — three classes

- UNIQUE (7) — clean install, no conflict: `cpp-cuda-vulkan-studio`, `cppstudio-supervisor`,
  `viewport-session-testing`, `vulkan-compute-sync`, `modern-cpp-cmake`, `cuda-kernel-authoring`,
  `important-instruction-ledger`.
- NAME-COLLISION, diverged (owned by the local doctrine manager): `agentic-control-harness`, `native-cpp-gui-hud`.
  → per-skill source-of-truth decision (compare content; replace / merge / keep-AD). Needs
  doctrine-manager coordination since AD currently owns those Claude variants.
- COVERAGE-OVERLAP, different names (owned by the local doctrine manager): `cpp-cuda-project-layout`,
  `cpp-cuda-research-to-plan`, `cuda-profiling-and-debugging` ≈ CppStudio coordinator/planner/profiling.
  → decide supersede vs coexist; coordinate with the local doctrine manager.

## CLAUDE.md relay — via the local doctrine manager

`~/.claude/CLAUDE.md` is owned by the local doctrine manager (marked blocks; e.g. rewind-checkpoints adds one).
The CppStudio relay block routes through the local doctrine manager's Claude source/generation (a marked block),
NOT a CppStudio-direct write. `rollout_to_claude.sh` calls/defers to that, or emits the snippet for an
local doctrine-manager worker to install.

## Slices (sequenced; low-risk foundation first)

1. **Lane + unique 7**: build `managed_claude_skills.sh`, `sync_to_claude.sh`, `rollout_to_claude.sh`,
   audit, relay snippet; install the 7 UNIQUE skills; prove a Claude worker can load each via the Skill
   tool. Immediate value (the skills that bit us), zero clobbering.
2. **Format/provider-neutrality pass**: scan all 11 SKILL.md for Codex-only assumptions (`~/.codex`
   paths, Codex CLI refs, "read as a file, not Skill-loadable" notes) and make them provider-neutral
   or Claude-correct (e.g. `cppstudio-supervisor`'s "not Claude-loadable" note becomes obsolete once
   installed).
3. **Reconciliation + doctrine-manager coordination**: compare each colliding/overlapping skill, present
   per-skill source-of-truth recommendation for your approval, coordinate the AD-owned ones via an
   local doctrine-manager worker, implement the decisions.
4. **CLAUDE.md relay** via the local doctrine manager (coordinated worker).
5. **Validation + docs + rollout**: extend `validate.sh` (or add `validate_claude_install`) for the
   Claude lane; parity checks; CHANGELOG + README highlight + maintainer-guide update; run
   `rollout_to_claude.sh`.

## Validation per slice

- Each installed skill: `quick_validate_skill.py` + `validate_skill_package.py` + parity diff vs source.
- Claude-load proof: a Claude worker loads each installed skill via the Skill tool (the real
  acceptance surface — "installed" ≠ "loadable").
- Lane separation check: Codex lane untouched; no shared files.

## Coordination / risk

- Slices 3–4 touch owned by the local doctrine manager territory (the colliding/overlapping skills + CLAUDE.md) →
  coordinate via a local doctrine-manager worker (same pattern as the ticket worker), with your per-skill
  source-of-truth approval before replacing any working Claude skill.
- Slice 1 is self-contained + low-risk; it delivers the missing-skill value immediately.
