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
- For Nsight Systems CLI stats, discover supported reports and formats from the installed tool before
  scripting readback. Prefer explicit report names, `--force-export=true`, and a supported format such
  as `column`; do not assume generic `summary` reports or `text` output exist across Nsight versions.
- For realtime Vulkan apps, classify present pacing separately from GPU pass cost. If present/acquire
  waits or FIFO/FIFO-RELAXED cadence dominate, require an uncapped, offscreen, or project-owned
  benchmark lane before recommending shader, shadow, ray tracing, or compute optimization.
- Do not make pass-level Vulkan claims from API summaries alone. Add or require debug labels, NVTX,
  GPU timestamp ranges, Nsight Graphics GPU Trace, or project-owned pass timers; if marker reports
  return no data, the correct finding is an observability gap.
- Separate startup and shutdown costs such as device/swapchain/pipeline creation and destruction from
  steady-state frame cost. Resource allocation or descriptor/command-buffer churn is actionable only
  after confirming whether it recurs inside the steady-state window.
- Do not commit profiler captures unless a repo explicitly stores small fixtures.

## Validation Ideas

- Run a tiny smoke capture only when the tool is installed and the target command is deterministic.
- Verify profiling scripts emit readable report paths.
- Check that artifacts are ignored by git unless intentionally stored.

## Caveats

- GUI/frame-debug tools may require display, Vulkan ICD, driver, or permission setup.
- Profiling can perturb timing; compare before/after under the same capture setup.
