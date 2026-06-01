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
- `.gitignore`
- `.github/workflows/validate.yml`
- `.nojekyll`
- `assets/cppstudio-banner.png`
- `assets/videos/`
- `samples/`

## Update When

- public install/use instructions change
- project-level maintainer instructions for normal rollout versus single-skill sync change
- public package integrity, audit log, or progressive disclosure docs change
- public backlog or future roadmap notes change
- public code-map positioning, readiness protocol, or user-facing workflow changes
- contribution, release, or change-history policy changes
- README Recent Commit Highlights policy or entries change
- host setup commands or GPU toolchain notes change
- root ignore policy for local/generated tool metadata changes
- root CI behavior, badge targets, or public assets change

## Current Public Docs Posture

- README Recent Commit Highlights shows selected recent highlight entries with stable commit-id
  labels, not moving `latest` or `current` aggregate badges, and keeps older stable commit-id entries
  under a GitHub `<details>` expander so the front page remains scannable.
- README sample project embeds keep GitHub attachment links for inline playback and local fallback
  links to `samples/index.html` plus tracked MP4 files under `assets/videos/`.
- The README positions optional code maps as practical project memory plus section-level onboarding:
  enabled maps route agents to the relevant subsystem doc and source paths, then explain what that
  code section owns before edits.
- The README documents substantial greenfield planning as a persisted research gate: agents should
  write `docs/planning/RESEARCH_BRIEF.md`, record donor candidates when found, and include
  project-specific App/Domain and GUI/Product-Surface dos and don'ts with evidence and validation
  signals before implementation starts.
- Code maps are described as the first navigation step before code changes, not a replacement for
  source inspection or a hard gate around normal engineering work.
- Public code-map docs now describe a bounded sidecar lane for large or long-running enabled-map
  slices. The sidecar reads an isolated fixed snapshot and prepares map-only patch output, while the
  original worker remains responsible for final reconcile, current-tree drift/schema validation, and
  the verified slice commit. The strict drift checker can now use `--launch-sidecar auto` to create a
  frozen snapshot and start the guarded sidecar directly for uncovered drift and no-map-touch semantic
  review moments instead of leaving sidecar routing to prose, memory, or a user prompt.
- Public supervisor docs describe slice phase telemetry for expensive supervised lanes so agents can
  measure research, donor routing, editing, build/test, OSTM, profiling, review, code-map, and commit
  time instead of guessing where verification is slowing the process down. Telemetry-required worker
  replies are expected to show a compact `Phase time:` line in chat, backed by canonical phase
  markers, instead of requiring the user to ask for timing after the fact.
- Public supervisor docs also describe the diminishing-returns policy attached to telemetry:
  repeated non-decisive checks, same-route tool failures, stale/wrong-workload evidence, or already
  proven acceptance should stop escalation and produce a verification-cost note.
- Existing-project code-map setup is described as audit-first: agents should show concrete findings,
  evidence paths, cleanup cost, and actual restructuring needs before asking the user to choose a
  route.
- Code-map validation is described as structural evidence, not proof that a cold future agent will
  follow the intended route. A read-only subagent or fresh-agent routing smoke is the expected proof
  when available.

## Current CI Posture

- The public validation badge runs `./scripts/validate.sh --full` so generated-project scaffold,
  CMake, Vulkan, CUDA compile, benchmark, and sanitizer lanes stay covered.
- Hosted CPU CI compiles CUDA with an explicit architecture and skips only CUDA runtime CTest when no
  CUDA device is available.
- Hosted CPU CI selects the available Lavapipe ICD path before running Vulkan runtime smoke tests;
  Ubuntu packages may install either `lvp_icd.json` or an architecture-suffixed filename.
- Hosted CI redirects Python bytecode from syntax checks into the runner temp directory so generated
  `__pycache__` trees never contaminate the skill package before manifest validation.
