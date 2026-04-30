# Validation, Debugging, And Profiling Research

## Validation Layer Strategy

Vulkan does little runtime error checking by default. The Khronos Validation Layer is therefore a
development dependency, not an optional nicety.

Validation modes to keep distinct:

- Core validation: general valid-usage and object checks.
- Synchronization validation: resource access conflicts caused by missing or incorrect sync.
- GPU-assisted validation: shader instrumentation for runtime checks.
- Debug printf: shader-side diagnostic output.
- Best-practices validation: warnings for common misuse and performance-sensitive patterns.

Research implication:

- Later template work should expose named validation modes, not one overloaded "debug" path.
- Expensive modes should be opt-in and documented.
- CI can run a small validation smoke test, while deep sync/GPU-assisted runs may belong to targeted
  lanes.
- Remaining validation messages should be treated as bugs unless explicitly explained.

## Debug Utils

`VK_EXT_debug_utils` should be part of the Vulkan lane's normal development infrastructure:

- Create a debug messenger in debug/validation builds.
- Route validation messages to structured logs.
- Name important objects with `vkSetDebugUtilsObjectNameEXT`.
- Wrap major command regions with `vkCmdBeginDebugUtilsLabelEXT` and
  `vkCmdEndDebugUtilsLabelEXT`.
- Label queue submissions where useful.

These names and labels make validation output, RenderDoc captures, and Nsight captures navigable.
Without them, Vulkan frame debugging becomes a pile of anonymous handles.

## RenderDoc

RenderDoc's own Vulkan notes say it is a graphics debugging tool, not an API correctness validator.
The right order is:

1. Reproduce the issue with validation enabled.
2. Fix or classify validation errors.
3. Capture a frame in RenderDoc.
4. Inspect event order, pipeline state, descriptor bindings, image contents, and buffer contents.

Research implications for later skill/template work:

- Add debug labels before expecting high-quality captures.
- Include a short capture checklist in docs.
- Treat RenderDoc captures as evidence for visible rendering correctness.
- Headless/compute-only capture workflows may need explicit capture boundaries or different tooling;
  do not assume a swapchain frame exists.

## Nsight Graphics

Nsight Graphics is the NVIDIA-side Vulkan frame debugger and GPU profiling tool. Its frame debugger
supports inspection of rendering calls, GPU pipeline state, resources, pixel history, and shader
performance. Its CLI can generate capture files through `ngfx-capture`.

Research implications:

- Nsight Graphics is the right NVIDIA tool for frame-level Vulkan rendering issues.
- GPU Trace is appropriate for frame-level timing, queue/event analysis, and shader cost.
- Command-line capture support makes it possible to add optional scripted capture lanes later.
- Debug labels should be emitted because they make GPU timelines and event lists readable.

## Nsight Systems

The existing repo already has an Nsight Systems smoke script. For Vulkan, Nsight Systems remains the
right tool when the question is whole-system behavior:

- CPU/GPU overlap.
- Frame pacing.
- Queue submission timing.
- Threading and scheduling.
- Presentation stalls.

It is not the first tool for "why is this pixel wrong" or "which descriptor is bound here"; use
RenderDoc or Nsight Graphics Frame Debugger for that.

## Evidence Matrix

| Question | Best First Evidence |
| --- | --- |
| Does the app have a usable Vulkan driver? | `vulkaninfo` or startup capability dump. |
| Did the shader compile correctly? | Shader compiler log plus `spirv-val`. |
| Is the shader/API descriptor contract correct? | Reflection output or explicit layout comparison plus validation. |
| Is synchronization wrong? | Synchronization validation plus minimal producer/consumer trace. |
| Is a frame visually wrong? | Screenshot plus RenderDoc/Nsight frame capture. |
| Is the GPU idle or queue-bound? | Nsight Graphics GPU Trace or Nsight Systems timeline. |
| Is memory over budget? | VMA budget stats or `VK_EXT_memory_budget` data. |
| Is swapchain recreation correct? | Resize/out-of-date test with validation logs. |

## Candidate Future Scripts

These are research-derived script ideas for later plan mode:

- `scripts/run_vulkan_validation.sh`
- `scripts/run_vulkan_sync_validation.sh`
- `scripts/run_vulkan_shader_printf.sh`
- `scripts/run_renderdoc_capture.sh`
- `scripts/run_ngfx_capture.sh`
- `scripts/check_vulkan_tools.sh`
- `scripts/dump_vulkan_capabilities.sh`

The important design point is that each script should state what evidence it collects and what it
does not prove.

