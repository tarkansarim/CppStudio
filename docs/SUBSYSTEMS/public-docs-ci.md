# Public Docs And CI

Owns the public README, contribution guidance, changelog, host setup docs, root GitHub validation
workflow, and repo banner/sample assets.

## Canonical Docs

- `README.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `docs/BACKLOG.md`
- `docs/host-toolchain-setup.md`
- `docs/package-integrity.md`

## Primary Paths

- `README.md`
- `CONTRIBUTING.md`
- `CHANGELOG.md`
- `docs/BACKLOG.md`
- `.github/workflows/validate.yml`
- `.nojekyll`
- `assets/cppstudio-banner.png`
- `assets/videos/`
- `samples/`

## Update When

- public install/use instructions change
- public package integrity, audit log, or progressive disclosure docs change
- public backlog or future roadmap notes change
- public code-map positioning, readiness protocol, or user-facing workflow changes
- contribution, release, or change-history policy changes
- README Recent Commit Highlights policy or entries change
- host setup commands or GPU toolchain notes change
- root CI behavior, badge targets, or public assets change

## Current CI Posture

- The public validation badge runs `./scripts/validate.sh --full` so generated-project scaffold,
  CMake, Vulkan, CUDA compile, benchmark, and sanitizer lanes stay covered.
- Hosted CPU CI compiles CUDA with an explicit architecture and skips only CUDA runtime CTest when no
  CUDA device is available.
- Hosted CPU CI selects the available Lavapipe ICD path before running Vulkan runtime smoke tests;
  Ubuntu packages may install either `lvp_icd.json` or an architecture-suffixed filename.
- Hosted CI redirects Python bytecode from syntax checks into the runner temp directory so generated
  `__pycache__` trees never contaminate the skill package before manifest validation.
