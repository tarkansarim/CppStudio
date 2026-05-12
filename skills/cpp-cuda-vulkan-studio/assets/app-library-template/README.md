# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION}}

This project is scaffolded as a Vulkan-first C++ app and library with optional CUDA and combined
CUDA plus Vulkan lanes. Real CUDA/Vulkan external-memory or semaphore interop should be added only
when the project defines that contract deliberately.

## Code Map

This template includes CppStudio code-map support files. The maintained map is opt-in: agents load
and maintain it only after `.cppstudio/code-map-state.json` says `enabled`.

When enabled, the code map is the first navigation step before code changes. Agents should use
`docs/CODEBASE_ARCHITECTURE_INDEX.md` and `docs/CODEBASE_SUBSYSTEM_MANIFEST.json` to pick the
matching subsystem route, then read that subsystem doc before editing.

Enable it after the user accepts. If the user explicitly requested a code map during project
creation, that counts as acceptance for a greenfield scaffold:

```bash
scripts/bootstrap_code_map.py --enable --force
scripts/validate_code_map.py --require-enabled
```

For an existing project, run the readiness audit before enabling:

```bash
scripts/bootstrap_code_map.py --audit-existing
```

Review the audit output before asking the user to choose. Present concrete findings, evidence paths,
nonstandard layout risks, and the estimated cleanup cost first; do not ask whether to restructure
until the audit has actually run and its output has been summarized. If no concrete restructuring
need is found, say so. If the user wants the audit saved, rerun with `--write-audit` to write
`docs/CODEMAP_BOOTSTRAP_AUDIT.md`.

Record a decline so agents stop prompting:

```bash
scripts/bootstrap_code_map.py --decline
```

Before committing a verified source slice with the map enabled, run:

```bash
scripts/check_code_map_drift.py --require-enabled
scripts/validate_code_map.py --require-enabled
```

If the drift check reports a changed path that is not routed by the manifest, update
`docs/CODEBASE_SUBSYSTEM_MANIFEST.json` and the matching `docs/SUBSYSTEMS/*.md` file in the same
slice before committing.

### Code-Map Sidecar Lane

For long-running implementation or high-churn slices, the main worker may offload only map
maintenance to a bounded code-map sidecar when drift output, new or moved routable files, changed
ownership/data flow/backend boundaries, a planned interval, or stale subsystem docs justify the
extra lane. The sidecar must read a fixed snapshot such as a Rewind checkpoint, temporary git anchor,
commit, worktree copy, or archive, and its prompt/response must name that anchor.

The main worker may continue source work, but before staging or committing it must apply or merge the
sidecar's map update, rerun `scripts/check_code_map_drift.py --require-enabled` and
`scripts/validate_code_map.py --require-enabled` against the current tree, and update the map again
or relaunch the sidecar if later source changes touched additional routable ownership or data-flow
areas. Do not create public commits only to feed sidecars; use Rewind checkpoints or temporary
anchors for that boundary, then keep the verified slice commit as the public history unit.

## Validate

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

## Development Rhythm

For agent-led implementation, treat git commits as part of the workflow. After each coherent
verified slice, commit the source, docs, tests, harness, and code-map updates before moving to the
next slice unless the user or repo policy says not to commit. Keep generated build outputs,
screenshots, profiler captures, logs, and temporary verification artifacts out of commits unless the
project intentionally tracks them. Add exactly one `Commit-Origin` trailer so later readers can
distinguish workflow commits from explicit user-requested commits:

```text
Commit-Origin: agent-slice
Commit-Origin: user-requested
```

Use only those two values. Do not use provider names such as `codex`, `claude`, or model names; the
trailer records why the commit happened, not which agent wrote it.

Optional CUDA lane:

```bash
cmake --preset cuda-debug
cmake --build --preset cuda-debug
ctest --preset cuda --output-on-failure
```

Optional combined CUDA plus Vulkan lane:

```bash
cmake --preset cuda-vulkan-combined
cmake --build --preset cuda-vulkan-combined
```

## Optimize GPU Work

For CUDA kernels, Vulkan compute shaders, render passes, simulations, or frame-time work, use the
evidence-gated loop in [GPU_OPTIMIZATION_LOOP.md](docs/GPU_OPTIMIZATION_LOOP.md). It records fixed
baselines, success criteria, hardware profile and roofline/SOL diagnosis, hypothesis records,
breaking-point searches, beam-style round plans for parallel agents, repeated validation-pass logs,
per-attempt `run.log` files, `results.tsv`, keep/revert decisions, target move-on state, convergence
or near-roofline stops, and a consolidation report under `artifacts/optimization/<session>/`.
