# CppStudio Codebase Architecture Index

Start here when context is cold or when choosing the right CppStudio subsystem before editing.

This repo is a Codex skill package, not a generated C++ project. The map routes agents into the
canonical source skill, donor library, template, rollout scripts, companion snippets, and public docs
without loading every reference file at once.

## State

- State marker: `.cppstudio/code-map-state.json`
- Machine manifest: [CODEBASE_SUBSYSTEM_MANIFEST.json](./CODEBASE_SUBSYSTEM_MANIFEST.json)

## Subsystem Routes

- Source skill and agent routing: [SUBSYSTEMS/source-skill-routing.md](./SUBSYSTEMS/source-skill-routing.md)
- Donor library: [SUBSYSTEMS/donor-library.md](./SUBSYSTEMS/donor-library.md)
- Generated project template: [SUBSYSTEMS/generated-project-template.md](./SUBSYSTEMS/generated-project-template.md)
- Validation, sync, and rollout scripts: [SUBSYSTEMS/validation-sync-rollout.md](./SUBSYSTEMS/validation-sync-rollout.md)
- Companion snippets and user relay: [SUBSYSTEMS/companion-snippets-relay.md](./SUBSYSTEMS/companion-snippets-relay.md)
- Research notes: [SUBSYSTEMS/research-notes.md](./SUBSYSTEMS/research-notes.md)
- Public docs and CI: [SUBSYSTEMS/public-docs-ci.md](./SUBSYSTEMS/public-docs-ci.md)

## Navigation Rule

Use this index and the manifest as the first navigation step before changing repo files. Pick the
matching subsystem route, read that subsystem doc, then inspect the primary paths named by the route.

## Maintenance Rule

When a change affects source-of-truth routing, donor selection, generated project files, validation,
sync/rollout behavior, companion snippets, research provenance, public install docs, CI, or release
history, update the matching subsystem doc and manifest in the same work stream.

If this map and the repo disagree, inspect the repo and update the map. The installed Codex copy is a
deployment target, not the map source of truth.
