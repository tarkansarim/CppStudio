# Package Integrity And Progressive Disclosure

CppStudio ships as a local Codex skill package. It is not a public registry or marketplace, but the
package now carries enough deterministic metadata to support safe sync, audit, and future public
distribution work.

## Package Manifest

The canonical skill directory contains:

```text
skills/cpp-cuda-vulkan-studio/package-manifest.json
```

This manifest records every shipped skill file except the manifest itself. Each entry includes:

- repo-relative package path
- package role: `main`, `metadata`, `script`, `asset`, or `reference`
- progressive disclosure group
- byte size
- SHA-256 content hash

The manifest is deterministic and has no timestamp field. Regenerate it only when package contents
change:

```bash
python3 scripts/validate_skill_package.py skills/cpp-cuda-vulkan-studio --write-manifest
```

Validate it without rewriting:

```bash
python3 scripts/validate_skill_package.py skills/cpp-cuda-vulkan-studio
```

## Progressive Disclosure Groups

The manifest is also a lightweight map of what should be loaded first and what should stay lazy:

- `entrypoint`: `SKILL.md`, agent metadata, and project archetype routing.
- `donor-router`: donor policy and broad lookup files.
- `production-overlay`: VFX, games, and native engineering vocabulary routers.
- `donor-category`: compact category files for one domain.
- `donor-profile`: deep donor profiles opened only after routing selects them.
- `generated-project-template`: scaffolded project assets.
- `script`: executable skill helpers.

Agents should keep using the skill and donor router rules first. The manifest is supporting
metadata, not a replacement for the routing text.

## Validation And Sync

`./scripts/validate.sh` checks the package manifest as part of normal validation. `sync_to_codex.sh`
validates the source skill, the staged copy, and the final installed copy before reporting success.
`rollout_to_codex.sh` validates the installed main skill after sync and before companion-link
rollout is considered complete.

The validator rejects:

- missing manifested files
- unmanifested package files
- hash or size mismatches
- unknown top-level manifest fields or unknown per-file entry fields
- symlinks inside the package
- unsupported top-level package entries outside the known skill layout
- absolute paths, escaping paths, and NUL bytes
- VCS, editor, cache, virtualenv, and dependency directories such as `.git`, `.vscode`,
  `__pycache__`, `.pytest_cache`, `.venv`, and `node_modules`
- local env files, secret-like key/certificate files, bytecode, archives, logs, swap files, and temp
  artifacts such as `.env`, `*.pem`, `*.key`, `*.zip`, `*.log`, `*.swp`, and `.DS_Store`

## Audit Log

Sync and rollout append best-effort JSONL records to:

```text
${SYNC_CODEX_HOME:-$HOME/.codex}/cppstudio-install-audit.jsonl
```

Set `CPPSTUDIO_AUDIT_LOG` to override the audit log path for staging. Audit records include action,
skill name, success flag, target path, source commit when available, package manifest hash, and a UTC
timestamp. Audit logging never masks the real validation or sync result.

## Future Distribution

If CppStudio later gains a remote update or cache layer, use this manifest as the integrity anchor:

- fetch registry metadata first
- compare package/version/hash metadata before replacing local files
- cache downloaded packages outside the installed skill directory
- validate the package manifest before install
- append an audit record for update, install, and rollback outcomes

Do not add a remote cache or registry path until there is a real public distribution workflow to
support it.
