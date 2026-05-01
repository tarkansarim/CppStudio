# CI And GPU Runners Donor Profile

Sources: https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners https://github.com/actions/runner https://github.com/NVIDIA/nvidia-container-toolkit
Tier: `dependency-candidate`
Backend signal: mixed-backend
License signal: Hosted-service terms, runner software licenses, container/runtime terms, GPU driver
licenses, and cloud/VM terms all vary; inspect the target deployment path before encoding policy.

## Use First For

- GitHub Actions, self-hosted GPU runners, labels, artifact upload, capability gates, and
  driver/toolchain isolation.
- Deciding which validation lanes should run on hosted CPU runners versus self-hosted GPU runners.

## First Upstream Areas To Inspect

- GitHub self-hosted runner labels, runner groups, service installation, and security guidance.
- Larger runner documentation only when managed hosted hardware is considered.
- Actions runner repository for runner lifecycle and update behavior.
- NVIDIA container tooling only when containerized GPU CI is explicitly in scope.

## Integration Notes

- Keep GPU CI opt-in and label-gated so CPU-only contributors can still validate quick lanes.
- Upload shader logs, sanitizer logs, screenshots, and profiler summaries as artifacts.
- Avoid hardcoding machine-specific GPU indices or workstation paths in reusable workflows.

## Validation Ideas

- Validate workflow YAML syntax and labels without requiring a live GPU runner.
- On a real runner, run capability dumps before GPU tests.
- Confirm missing GPU/toolchain lanes fail or skip with clear messages.

## Caveats

- Self-hosted runners are security-sensitive. Do not use public pull request code on privileged GPU
  machines without explicit isolation policy.
- Driver/toolkit drift can invalidate old CI assumptions.
