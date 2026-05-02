# Validation Sync And Rollout

Owns CppStudio repo validation, CI-safe validation, syncing to user-level Codex, rollout to companion
skills, and watch-mode publishing behavior.

## Canonical Docs

- `docs/maintainer-guide.md`
- `docs/manual-install.md`

## Primary Paths

- `scripts/validate.sh`
- `scripts/sync_to_codex.sh`
- `scripts/rollout_to_codex.sh`
- `scripts/watch_to_codex.sh`
- `scripts/quick_validate_skill.py`
- `scripts/bootstrap_code_map.py`
- `scripts/validate_code_map.py`

## Update When

- validation coverage, required package files, CI-safe validator behavior, or full validation changes
- CppStudio code-map validation or bootstrap wrapper behavior changes
- sync or rollout target safety rules change
- installed skill parity or companion validation behavior changes
- public install/manual install commands change
