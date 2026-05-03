# AgentSys Mapping For CppStudio GPU Optimization Loops

This note records how CppStudio adapts AgentSys `/perf` investigation discipline for native
C++/CUDA/Vulkan projects. AgentSys is used as a reference design only; no source code is copied.

## Upstream References

- Repository: <https://github.com/agent-sh/agentsys>
- Reviewed revision: `00ea8a4a08ae23e3179f301b667a4ffcbbb43021`
- Methodology docs: `docs/perf-research-methodology.md` and `docs/perf-requirements.md`
- Performance skills: `.kiro/skills/perf-benchmarker`, `perf-theory-gatherer`,
  `perf-theory-tester`, `perf-investigation-logger`, and `perf-analyzer`
- Runtime references: `lib/perf/investigation-state.js`, `lib/perf/breaking-point-finder.js`,
  `lib/perf/breaking-point-runner.js`, and `lib/perf/consolidation.js`

## What CppStudio Adopts

- Performance investigations start by declaring scenario, representative command, and success
  criteria before benchmarking.
- Breaking-point discovery uses sequential binary search over a numeric workload parameter and
  records trial evidence.
- Hypotheses are logged before edits with evidence and confidence.
- Optimization attempts are tied to one logged hypothesis and one focused edit.
- Attempts run two or more validation passes before benchmarking.
- Final reporting consolidates success criteria, hypotheses, breaking-point evidence, accepted
  attempts, rejected attempts, and final recommendation.

## What CppStudio Changes

- AgentSys is web/runtime-agent shaped and explicitly scopes its default profiler support to
  languages such as JavaScript, Python, Go, Rust, and Java. CppStudio keeps the loop command-driven
  for native C++ projects, CUDA kernels, Vulkan compute shaders, render passes, simulations, and
  realtime tools.
- AgentSys uses `{state-dir}/perf`. CppStudio stores generated-project optimization artifacts under
  ignored `artifacts/optimization/<session>/` so source repos stay clean.
- AgentSys benchmark output centers on `PERF_METRICS` markers. CppStudio keeps compact greppable
  metric lines such as `elapsed_us=...`, `frame_ms=...`, and `correctness=PASS` because they fit
  CTest, shell benchmarks, profiler summaries, and GPU smoke tools.
- AgentSys mandates checkpoint commits after every phase. CppStudio records patch snapshots, supports
  optional commits for kept attempts, and relies on normal project git policy for rollback anchors.

## What CppStudio Skips For Now

- CPU and memory constraint testing as a first-class command.
- AgentSys platform state-directory selection.
- JavaScript runtime modules, hooks, and Kiro-specific skill structure.
- Forced 60-second benchmark duration policy for all targets, because realtime tools, GPU tests, and
  CTest benchmark fixtures often need project-specific warmup and iteration policy.
