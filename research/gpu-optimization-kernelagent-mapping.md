# KernelAgent Mapping For CppStudio GPU Optimization Loops

This note records how CppStudio adapts KernelAgent's hardware-guided optimization patterns for
native C++/CUDA/Vulkan projects. KernelAgent is used as a reference design only; no source code is
copied.

## Upstream References

- Repository: <https://github.com/meta-pytorch/KernelAgent>
- Reviewed revision: `2d8ed0d518e2c5ec834a1acd1bc41607d7591a7f`
- Optimization manager: `triton_kernel_agent/opt_manager.py`
- Beam/greedy strategies:
  `triton_kernel_agent/opt_worker_component/searching/strategy/beam_search.py` and `greedy.py`
- NCU profiler:
  `kernel_perf_agent/kernel_opt/profiler/ncu_profiler.py` and
  `triton_kernel_agent/opt_worker_component/profiling/kernel_profiler.py`
- Roofline/SOL analyzer: `kernel_perf_agent/kernel_opt/roofline/ncu_roofline.py`
- Bottleneck analyzer:
  `triton_kernel_agent/opt_worker_component/prescribing/bottleneck_analyzer.py`
- Optimization orchestrator:
  `triton_kernel_agent/opt_worker_component/orchestrator/optimization_orchestrator.py`

## What CppStudio Adopts

- Hardware-counter-first optimization: profile the current target before editing when NCU, RenderDoc,
  Nsight Graphics, timestamp queries, or project counters are available.
- NCU/SOL naming compatibility for compute SOL, memory SOL, and tensor-core activity metrics.
- Roofline-style classification into `memory`, `compute`, `underutilized`, or `unknown`, with
  configurable near-roofline and convergence thresholds.
- Bottleneck diagnosis before edits: agents should use `profile` output and `profile_metrics.json`
  before choosing an experiment.
- Beam-style worker planning: top parent attempts multiplied by bottleneck directions, with
  per-round/per-worker artifacts that parallel agents can pick up.
- Best-so-far tracking with divergence-aware reject/revert behavior.
- Separate runtime and SOL evidence in reports so a high-SOL-but-slower attempt does not get mixed
  with the best runtime result.

## What CppStudio Changes

- KernelAgent is Triton/PyTorch shaped. CppStudio keeps the loop command-driven so it can target
  `.cu`, `.cuh`, GLSL/HLSL/SPIR-V shaders, render passes, simulation kernels, CMake options, or
  engine code.
- KernelAgent workers are Python processes. CppStudio emits round/worker artifacts for coding agents,
  branches, or git worktrees instead of spawning model workers itself.
- KernelAgent serializes NCU profiling through a semaphore. CppStudio records this as workflow
  policy: profile commands should be run one at a time unless the project proves the profiler is safe
  to parallelize.
- KernelAgent uses PyTorch correctness oracles. CppStudio keeps correctness in project-owned
  `verify_cmd` and final validation commands.
- KernelAgent writes Python kernels as per-round artifacts. CppStudio keeps patch snapshots and
  optional git commits for accepted native-project edits.

## What CppStudio Skips For Now

- Direct LLM prompt generation for optimization prescriptions.
- Built-in multiprocessing worker execution.
- PyTorch eager and `torch.compile` baselines.
- A KernelBench/Triton-specific problem format.

Those remain useful references for AI-runtime projects, but the reusable CppStudio layer must stay
backend-agnostic across CUDA, Vulkan, render, simulation, and realtime tool workloads.
