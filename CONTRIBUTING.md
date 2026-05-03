# Contributing

CppStudio is a Codex skills package, not a generated C++ application. Contributions should preserve
that shape: reusable agent instructions, donor-reference routing, validation scripts, and generated
project templates.

## Working Rules

- Edit the repo source, not an installed copy under `~/.codex/skills`.
- Keep reusable policy generic. Do not add machine-specific paths, private project provenance, or
  app-only rules.
- Preserve managed marker blocks. CppStudio may replace content inside its markers, but user-owned
  content outside those markers must survive reinstall.
- Keep the maintained code map current when subsystem ownership, routing, validation, sync/rollout,
  template, donor-library, public docs, CI, or changelog policy changes.
- Add a concise `CHANGELOG.md` entry before pushing tracked changes to remote.
- Add a concise README Recent Commit Highlights line for pushed commits that affect setup, routing,
  generated projects, validation, donor-library behavior, public docs, install, release, or sync
  behavior.
- Classify donor entries with the validated tier values: `safe-donor`, `dependency-candidate`, or
  `study-only`.
- Use caveat wording such as `reference-only` or `mixed-native` in profile/native-use notes when a
  donor is useful as context but is not a direct native C++ implementation donor.
- Treat donor links as references, not vendored code. Check the exact upstream license and revision
  before copying, vendoring, or generating code from a donor.

## Validation

Run the normal validator before submitting changes:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh
```

For template, scaffold, CMake, generated-project, or validation-behavior changes, run:

```bash
python3 scripts/validate_code_map.py . --require-enabled
./scripts/validate.sh --full
```

The scripts prefer the target Codex system validator when it exists and otherwise use the repo-local
validator for public CI parity. You can still override explicitly:

```bash
VALIDATOR="${PWD}/scripts/quick_validate_skill.py" ./scripts/validate.sh
```

The GitHub workflow installs its CI-safe CMake, CUDA, and Vulkan toolchain. It does not require a GPU.

## Donor Updates

When adding or refreshing donors:

- Update the smallest matching category file first.
- Add or update a profile only when the category entry needs more caveats, routing, tests, or license
  notes than a table row can carry.
- Keep non-C++ or restricted-license donors clearly marked with an appropriate tier and caveat
  wording such as `reference-only` or `mixed-native`.
- Update researched-date notes when a meaningful donor refresh happens.

## Releases

Use Git tags or GitHub releases for public release points. Release notes should call out:

- skill behavior or trigger-description changes
- donor-library additions, removals, or refreshes
- install, rollout, sync, or managed-marker behavior changes
- generated-project template or validation changes

`CHANGELOG.md` is the tracked source of change history for normal remote pushes.

For maintainer workflows, see [docs/maintainer-guide.md](docs/maintainer-guide.md).
