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

Review the audit output, then ask whether to restructure first, preserve the current layout with
documented exceptions, or decline the map. If the user wants the audit saved, rerun with
`--write-audit` to write `docs/CODEMAP_BOOTSTRAP_AUDIT.md`.

Record a decline so agents stop prompting:

```bash
scripts/bootstrap_code_map.py --decline
```

## Validate

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

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
baselines, hardware profile and roofline/SOL diagnosis, beam-style round plans for parallel agents,
per-attempt `run.log` files, `results.tsv`, keep/revert decisions, target move-on state, convergence
or near-roofline stops, and a final report under `artifacts/optimization/<session>/`.
