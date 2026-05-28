---
name: gpu-profiling-workstation
description: "Profile and frame-debug CUDA, Vulkan/OpenGL, and CPU workloads on Tarkan's Ubuntu workstation with Nsight, RenderDoc, perf, and Compute Sanitizer."
---

# GPU Profiling Workstation

Use the installed-tool order below. Choose the tool by question type first: frame-debugging/correctness vs performance.

## Installed tools on this machine

- `nsys` at `/usr/local/cuda/bin/nsys`
- `ncu` at `/usr/local/cuda/bin/ncu`
- `compute-sanitizer` at `/usr/local/cuda/bin/compute-sanitizer`
- `cuda-gdb` at `/usr/local/cuda/bin/cuda-gdb`
- `ngfx-ui-for-linux` at `/usr/bin/ngfx-ui-for-linux`
- `ngfx-capture` at `/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-capture`
- `ngfx-replay` at `/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay`
- `renderdoccmd` at `${HOME}/.local/bin/renderdoccmd`
- `qrenderdoc` at `${HOME}/.local/bin/qrenderdoc`
- `nvidia-smi` at `/usr/bin/nvidia-smi`
- `perf` at `/usr/bin/perf`
- `glxinfo` at `/usr/bin/glxinfo`

## Not currently available

- `nsight-cu` GUI launcher
- `nvprof`
- `vulkaninfo`

Load exact versions from [references/TOOL_INVENTORY.md](references/TOOL_INVENTORY.md) when version details matter.
Current `nsys` resolves through the CUDA Toolkit launcher to Nsight Systems 2025.3.2.

## Default tool order

### For graphics correctness / frame-debugging

1. Use `ngfx-capture` / `ngfx-replay` first for Vulkan frame captures on this workstation, especially RT preview, ray tracing, and shader/event inspection.
2. Use `qrenderdoc` / `renderdoccmd` for quick graphics inspection when you specifically want RenderDoc, or for non-RT/simple capture paths.
3. If the question becomes "where is the frame time going?" switch to `nsys`.

### For performance profiling

1. Use `nsys` first for any performance issue.
2. Use `ncu` only after `nsys` identifies the hot CUDA kernel.
3. Use `perf` when the hotspot is CPU-side and outside CUDA/OpenGL.
4. Use `compute-sanitizer` or `cuda-gdb` when profiling suggests a correctness or memory bug instead of a pure speed issue.

## Project Command Rules

- Replace `<app-command> [args...]` with the exact launch or smoke command from the target repo.
- Do not assume a synthetic smoke command represents the full interactive path. If the user reports
  live interaction latency, profile the real event path or a project-owned interaction audit mode.
- Avoid running profiling and benchmark commands concurrently; timings become meaningless.
- For before/after performance comparisons, clone the accepted baseline launch shape before changing
  anything except artifact paths and the intended treatment. Copy workload-defining flags exactly:
  replay/recording paths, `--play-recording-exit`, scene/groom/asset path, backend/upscaler/quality
  mode, GPU id, no-NGX or feature toggles, window/maximized options, debug/profile view, warmup,
  frame budget, and any interaction/scripted-input flags. If those flags are missing from the fresh
  run, discard that run as non-representative before comparing metrics.
- When reading profiling or OSTM artifacts, prefer the project-owned report/readback helper when one
  exists. If a one-off parser is necessary, inspect the current artifact schema first and make the
  parser tolerate known key variants instead of assuming stale names such as `timing_summaries`
  versus `metric_summaries`. Treat parser failures as evidence-readback failures to fix before
  drawing conclusions; do not keep retrying fragile ad hoc summaries or compare metrics from partial
  output.
- Prefer temporary config homes for reproducible profiling runs:
  - `HOME=/tmp/... XDG_CONFIG_HOME=/tmp/...`
- If frame times cluster around display cadence, check vsync/present pacing and app internal GPU
  timers before concluding the renderer or CUDA kernels are the bottleneck.
- For Vulkan/realtime app performance audits, classify present pacing separately from shader,
  dispatch, BLAS/TLAS, resolve, upload, and CPU-submit cost. If `vkQueuePresentKHR`,
  swapchain acquire, FIFO/FIFO-RELAXED present mode, or app readbacks such as
  `present_live_cpu_total`/`acquire_slot_wait` dominate the sample, do not recommend shader or
  renderer-pass optimization until a non-present-paced, uncapped, offscreen, or project-owned
  benchmark lane shows the pass itself is expensive.
- Treat startup, shutdown, pipeline creation, device creation, swapchain creation, and destruction
  as separate phases from steady-state frame cost. If a profile window includes both, report them
  separately before naming a bottleneck.
- Validate app-owned timing readbacks before trusting them. If a project state JSON reports zero,
  missing, or stale timing fields while another lane or profiler reports real timing, classify that
  as an instrumentation gap and use the reliable lane for findings.
- For pass-level Vulkan claims, require GPU timestamp ranges, Vulkan debug labels/markers, Nsight
  Graphics GPU Trace, or equivalent project-owned pass timers. If Nsight marker reports return no
  data, report a pass-attribution gap; API summaries alone can identify CPU/API/present behavior but
  cannot prove which shader pass is slow.
- For Vulkan frame-debugging, a live/presenting path is often easier to capture than offscreen-only
  modes because frame-capture tools frequently key off present/frame delimiters.
- If a frame debugger hooks the process but never produces a capture artifact, check delimiter
  assumptions before blaming the renderer.

## Recommended commands

### Vulkan frame capture with Nsight Graphics

Use this first for Vulkan RT correctness and frame-debug issues.

```bash
/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-capture \
  --exe <app-command> \
  --working-dir "$PWD" \
  --output-dir build/ngfx \
  --output-file rt_debug.nsgfx \
  --capture-frame 2 \
  -n 1 \
  --terminate-after-capture \
  --no-hud \
  --diagnostic-mode \
  --args "<all app arguments as one shell-quoted string>"
```

For this installed `ngfx-capture`, app arguments must be passed as one string after `--args`. Do
not pass leading app options such as `--foo` as separate tokens after `--args`; the launcher may
parse them as `ngfx-capture` options before the target app starts. Prove the exact argv shape with a
tiny passthrough app or by inspecting the target app's captured command line before blaming the app.

If the capture blocks on a Vulkan compatibility dialog such as
`VK_KHR_external_memory (external revisions ignored)`, do not use dialog-closing, focus, or
environment hacks. First retry through the documented capture options:

```bash
/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-capture \
  --exe <app-command> \
  --working-dir "$PWD" \
  --output-dir build/ngfx \
  --output-file rt_debug.nsgfx \
  --capture-frame 2 \
  -n 1 \
  --terminate-after-capture \
  --no-hud \
  --diagnostic-mode \
  --ignore-incompatible \
  --no-block-on-first-incompatibility \
  --args "<all app arguments as one shell-quoted string>"
```

Treat the capture as accepted only after replay succeeds. Compatibility warnings may remain in the
metadata; record them as warnings, not as a blocker, when replay proof is usable.

Before writing replay commands on this workstation, inspect the installed replay surface:

```bash
/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay --help
```

Capture and replay use different incompatibility flags in the installed 2026.1 CLI:
`ngfx-capture` uses `--no-block-on-first-incompatibility`, while `ngfx-replay` uses
`--no-block-on-incompatibility`. If capture metadata or stdout/stderr contains Vulkan compatibility
warnings such as `VK_KHR_external_memory` / `VK_KHR_external_memory_fd`, include
`--no-block-on-incompatibility` in any replay command that could execute the capture. Do not wait for
a `zenity` compatibility dialog or OSTM timeout to discover the replay-side flag.

Then inspect metadata or export the final screenshot:

```bash
/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay \
  --metadata build/ngfx/rt_debug.nsgfx.ngfx-capture

/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay \
  --metadata-screenshot build/ngfx/rt_debug.png \
  build/ngfx/rt_debug.nsgfx.ngfx-capture

/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay \
  --metadata-functions build/ngfx/rt_debug_functions.txt \
  build/ngfx/rt_debug.nsgfx.ngfx-capture
```

For performance report replay on a capture with known compatibility warnings:

```bash
/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay \
  --no-block-on-incompatibility \
  --perf-report-dir build/ngfx/perf_report \
  build/ngfx/rt_debug.nsgfx.ngfx-capture
```

If `--perf-report-dir` still times out or fails after the documented nonblocking replay flag, stop
and classify the result as an Nsight Graphics replay/perf-report evidence gap for that capture. Do
not start shader optimization from API/object metadata alone; require shader-level evidence such as
instruction/register/spill/function-cost data, GPU timestamps, or project-owned pass/subroute
timers before planning the next source optimization.

### RenderDoc quick launch

Use this when you want manual UI inspection:

```bash
qrenderdoc
```

Or capture a launched app:

```bash
renderdoccmd capture \
  -d "$PWD" \
  -c build/renderdoc/rt_debug \
  <app-command> [args...]
```

### Whole-frame timeline

Use this first.

```bash
nsys profile \
  --trace=cuda,opengl,nvtx,osrt \
  --sample=none \
  --force-overwrite=true \
  --output build/nsys_profile \
  <app-command> [args...]
```

Then read supported stats reports. This is the canonical stats shape for this workstation:

```bash
nsys stats \
  --force-export=true \
  --report cuda_api_gpu_sum,cuda_gpu_kern_sum,opengl_khr_gpu_range_sum,osrt_sum,nvtx_sum \
  --format column \
  build/nsys_profile.nsys-rep
```

For Vulkan-heavy captures, use explicit Vulkan reports:

```bash
nsys stats \
  --force-export=true \
  --report vulkan_api_sum,osrt_sum,nvtx_sum \
  --format column \
  build/nsys_profile.nsys-rep
```

This workstation's Nsight Systems does not support `--format text` or a generic `--report summary`.
Treat `nsys stats --report summary --format text ...` as an invalid legacy command, not as a path to
repair. Do not add aliases, wrappers, shell functions, or PATH shims to make that old command pass.
If old conversation context, old notes, or a resumed agent suggests `summary/text`, replace it with
the explicit supported commands above.

When verifying that Nsight friction is gone, success means the supported explicit-report command
passes on the fresh `.nsys-rep`. Do not retest the legacy command unless the user explicitly asks to
prove that invalid old command still fails.

Before writing a new stats command on this machine, check the active tool surface:

```bash
hash -r
type -a nsys
nsys stats --help
nsys stats --help-reports
```

### Confirmed CUDA kernel hotspot

Replace the kernel regex only after `nsys` proves the kernel matters.

```bash
ncu \
  --set full \
  --target-processes all \
  --kernel-name-base demangled \
  --kernel-name "regex:<hotKernelName>" \
  <app-command> [args...]
```

### CPU-only hotspot

Use when `nsys` shows the stall is mostly host-side:

```bash
perf record -g -- <app-command> [args...]
perf report
```

### Correctness/debug follow-up

```bash
compute-sanitizer <app-command> [args...]
```

## Interpretation rules

- If the question is "why does this highlight/lobe/shader output look wrong?" use a frame debugger first, not `nsys`/`ncu`.
- If a graphics capture log shows Vulkan object lifetime and capture statistics, the frame debugger is successfully hooked even before you inspect the capture in a UI.
- If an Nsight Graphics offscreen capture doesn't emit a file but a live capture does, suspect missing present/frame delimiters rather than a dead Vulkan hook.
- If `ngfx-capture` rejects app flags after `--args`, switch to one quoted `--args "<full app arg
  string>"`; do not patch wrapper aliases around the tool.
- If `--no-block-on-first-incompatibility` alone still leaves a blocking Vulkan compatibility
  dialog during capture, retry capture with `--ignore-incompatible` plus replay metadata proof
  before planning source changes. If replay of a compatibility-warning capture blocks or times out,
  retry replay only with the installed replay-side `--no-block-on-incompatibility` flag. Stop after
  that supported attempt if capture/replay still fails.
- If RenderDoc target control only reports `Noop`/`Disconnected`, verify Vulkan layer registration and prefer Nsight Graphics for that session instead of repeatedly patching the capture script.
- If `nsys` shows `vkQueuePresentKHR`, swapchain acquire, or app present/acquire waits dominating
  a frame, classify the result as present-paced. Do not infer that ray tracing, shaders, lighting,
  shadows, CUDA, or compute kernels are slow until an uncapped/non-present-paced lane proves it.
- If Vulkan marker or NVTX reports are empty, say exactly that pass-level attribution is missing and
  recommend adding labels/timestamp ranges before optimizing a specific pass.
- If allocation, descriptor, command-buffer, command-pool, pipeline, or device/swapchain creation
  calls appear during a steady-state window, classify them as resource churn candidates; distinguish
  one-time startup/destruction churn from recurring per-frame churn before patching.
- If `nsys` shows long gaps before `cudaGraphicsMapResources` or `cudaGraphicsUnmapResources`, investigate CUDA/GL interop synchronization.
- If `nsys` shows host thread blocked near swap/present, do not chase CUDA kernels first.
- If `ncu` shows low occupancy but the kernel is not dominant in `nsys`, do not optimize it yet.
- If internal app GPU timers stay low but frame time is high, suspect CPU sync, driver wait, or present pacing.
- If `opengl_khr_gpu_range_sum` is skipped, the app is not emitting KHR debug GPU ranges; use CUDA reports plus the app's internal timers instead of treating that as a profiler failure.
- If interaction lag is the complaint, separate input handling, simulation/update work,
  resource/upload work, draw cost, and present/vsync cost.

## Current machine-specific guidance

- `nsys` and `ncu` are modern CUDA 2025 builds and should be the default tools here.
- `compute-sanitizer` is available and current enough to use before deeper CUDA debugging.
- Nsight Graphics 2026.1.0.0 is installed and should be the first frame-debugger choice here for Vulkan RT captures.
- RenderDoc 1.43 is installed and usable, but on this workstation its target-control scripting path can be less reliable than Nsight Graphics for Vulkan RT preview captures.
- `nvprof` is not available; do not plan workflows around it.
