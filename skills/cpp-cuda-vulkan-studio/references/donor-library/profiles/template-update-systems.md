# Template Update Systems Donor Profile

Sources: https://github.com/copier-org/copier https://github.com/cruft/cruft https://github.com/cookiecutter/cookiecutter https://github.com/yeoman/yo
Tier: `dependency-candidate`
Backend signal: api-agnostic
License signal: Mixed permissive project licenses; inspect tool licenses, generated-file behavior,
answer files, and transitive dependencies before adopting any workflow.

## Use First For

- Updating generated projects while preserving user edits.
- Designing answer files, replayable configuration, diff previews, and non-overwrite apply behavior.
- Separating managed marker blocks from user-owned content.

## First Upstream Areas To Inspect

- Copier update/replay workflows and answers file behavior.
- Cruft's Cookiecutter update/diff model.
- Cookiecutter template variables and generated-project conventions.
- Yeoman generator lifecycle only as a broad scaffolding reference.

## Integration Notes

- CppStudio should keep update safety explicit: dry runs, diffs, marker blocks, and preserved user
  content.
- Avoid hidden regeneration over user-owned project files.
- Store template metadata only when it materially improves safe updates.

## Validation Ideas

- Apply a template to a temp project, modify a user-owned file, then verify the update path preserves
  that edit.
- Check that marker-managed blocks can be replaced idempotently without duplication.
- Verify dry-run output is useful enough for an agent to report before mutating a target repo.

## Caveats

- These are workflow donors, not direct C++ code donors.
- Template update tools can become project policy; do not introduce them into target projects unless
  the user accepts that maintenance model.
