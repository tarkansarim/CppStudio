# Profiling And Observability Donor Profile

Sources: https://github.com/wolfpld/tracy https://perfetto.dev/docs/ https://renderdoc.org/docs/ https://docs.nvidia.com/nsight-systems/UserGuide/index.html
Tier: `dependency-candidate`
Backend signal: mixed-backend
License signal: Tool and capture licenses vary; inspect exact tool versions, SDK/header terms,
capture redistribution rules, and CI artifact policy.

## Use First For

- Tracy, Perfetto, RenderDoc, Nsight Systems, frame-time capture, GPU timestamps, and profiling
  artifact policy.
- Choosing between CPU tracing, frame debugging, GPU timing, and system-wide profiling evidence.

## First Upstream Areas To Inspect

- Tracy client/server integration, zones, plots, and GPU context support.
- Perfetto SDK and trace processor workflows.
- RenderDoc capture APIs, Vulkan debug labels, and capture replay constraints.
- Nsight Systems command-line capture, stats export, and report handling.

## Integration Notes

- Pick the profiler based on the question: frame correctness, CPU stalls, GPU kernels, present stalls,
  memory bandwidth, or system scheduling.
- Keep profiling scripts opt-in and artifact-producing.
- Do not commit profiler captures unless a repo explicitly stores small fixtures.

## Validation Ideas

- Run a tiny smoke capture only when the tool is installed and the target command is deterministic.
- Verify profiling scripts emit readable report paths.
- Check that artifacts are ignored by git unless intentionally stored.

## Caveats

- GUI/frame-debug tools may require display, Vulkan ICD, driver, or permission setup.
- Profiling can perturb timing; compare before/after under the same capture setup.
