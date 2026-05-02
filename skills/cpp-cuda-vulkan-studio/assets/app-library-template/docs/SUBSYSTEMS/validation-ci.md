# Validation And CI

CTest labels, smoke tests, GPU runner expectations, profiling evidence, formatting, and static
analysis.

## Canonical Docs

- `docs/VALIDATION_PIPELINE.md`
- `docs/GPU_RUNNER_CI.md`
- `docs/BENCHMARKS.md`

## Primary Paths

- `tests/`
- `benchmarks/`
- `scripts/`
- `.github/workflows/`

## Update When

- test labels, presets, CI runner labels, validation scripts, profiling artifacts, format/tidy policy,
  or benchmark recording requirements change
- a new subsystem requires a distinct validation lane
- CI starts requiring new host tools or environment variables
