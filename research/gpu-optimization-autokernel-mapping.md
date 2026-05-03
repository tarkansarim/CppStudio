# AutoKernel Mapping For CppStudio GPU Optimization Loops

This note records how CppStudio adapts AutoKernel-style optimization discipline for native
C++/CUDA/Vulkan projects. AutoKernel is used as a reference design only; no source code is copied.

## Upstream References

- Repository: <https://github.com/RightNow-AI/autokernel>
- Agent protocol: `program.md`
- Fixed benchmark harness: `bench.py`
- Multi-kernel scheduler: `orchestrate.py`
- Session analysis/reporting: `analysis.py`

## What CppStudio Adopts

- Fixed benchmark contract with greppable `run.log` output.
- Correctness-first decisions: incorrect attempts are rejected before performance is considered.
- One focused hypothesis per experiment.
- Keep only faster correct variants; reject or revert slower and failed attempts.
- `results.tsv` attempt history with compact fields agents can grep.
- Per-target state with baseline, best result, keep/revert counts, and move-on decisions.
- Amdahl-style target prioritization so agents do not optimize isolated toy throughput while the
  representative workload is unaffected.
- Final report generation before making speedup claims.

## What CppStudio Changes

- AutoKernel edits a single `kernel.py`. CppStudio uses a focused change set under declared
  subsystem paths because native GPU work can involve `.cu`, `.hpp`, shaders, tests, CMake options,
  descriptors, or render/dispatch code.
- AutoKernel commits every experiment and reverts with `git reset --hard HEAD~1`. CppStudio records
  patch snapshots and can reverse only the measured attempt with `git apply -R`. Accepted attempts
  can still be committed between rounds to create a clean rollback anchor.
- AutoKernel is PyTorch-model shaped. CppStudio uses project-owned CTest labels, app commands,
  renderer/simulation benchmarks, CUDA benchmarks, or Vulkan compute benchmarks.
- AutoKernel loops indefinitely during autonomous phase B. CppStudio keeps long loops budgeted by
  time, consecutive reverts, speedup target, and near-peak utilization.

## What CppStudio Skips For Now

- PyTorch profiling and kernel extraction.
- Runtime replacement of PyTorch ops during final verification.
- A model-specific reference oracle.
- Auto-generated visual progress plots.

These can be revisited later for AI-runtime-specific projects, but the first CppStudio version stays
portable across CUDA kernels, Vulkan compute, render passes, simulations, and realtime tools.
