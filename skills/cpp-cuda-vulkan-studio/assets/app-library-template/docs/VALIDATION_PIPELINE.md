# Validation Pipeline

Recommended local gate:

```bash
scripts/check_dev_tools.sh
cmake --preset dev
cmake --build --preset dev
ctest --preset quick --output-on-failure
```

Viewport-session smoke gate:

```bash
scripts/run_viewport_session_smoke.py --build-dir build/dev
```

For visible UI, viewport, brush, paint, sculpt, groom, timeline, node, camera, or gizmo bugs, record
or replay a user-equivalent viewport session and compare before/after `report.json`, state files,
semantic traces, and fresh captures before claiming the bug is fixed.
The proof must exercise the user-facing control and the actual interaction shape. For continuous
actions such as strokes, drags, scrubs, camera orbits, timeline drags, node wires, and gizmo moves,
assert held-button or stylus-contact move samples, pointer/hit/readback along the path, and a
visible or semantic delta; do not use a single click/dab smoke as proof. Once the app has a real
interactive surface, visible record/stop/replay or equivalent capture controls should create
replayable artifacts so users can hand agents a repro session without hidden CLI knowledge.
For tools that are expected to update live during contact, add a pre-release assertion: after a
held-contact move and before mouse/stylus release, document/render revision, dirty region, semantic
trace, or an app-owned capture must already show the edit. Release should finalize undo/replay, not
be the first visible edit.

For stroke-like visible bugs, create or replay a human-input UI session through the real
viewport/canvas/widget event path. The session must include press/contact, multiple held move
samples, and release/finalization. The report must compare requested pointer path against hit/edit
path or affected element coverage, and directly assert material/overlay/product-surface complaints
when those are the reported symptoms. Revision/checksum changes, nonblank screenshots,
product-surface scores, backend endpoints, and one-point dab smokes are supporting evidence only. If
the project lacks this scenario, add the smallest diagnostic route and run it as the before proof
without changing product behavior, then keep it as the regression route after the fix.

Keep visible concerns separate in every closeout. A semantic replay that proves edited vertices cover
the requested pointer path does not by itself prove that the live stroke reads correctly in the
viewport. A material readback proving "no debug overlay" does not by itself prove production-quality
shading or a donor-matched look. For every user-named visible concern, report `resolved`,
`unresolved`, or `not-tested`, the artifact path, and the next proof needed before moving to feature
breadth.

Report execution modes precisely: real OS pointer/stylus injection is `real-input`/intrusive unless
explicitly isolated; do not describe it as offscreen, background, or non-disruptive.

Self-hosted CI runner expectations and artifact paths are documented in
[GPU_RUNNER_CI.md](GPU_RUNNER_CI.md).

Host sanitizer gate:

```bash
cmake --preset asan-ubsan
cmake --build --preset asan-ubsan
ctest --preset asan-ubsan-quick --output-on-failure
```

The `asan-ubsan` preset uses ASan+UBSan on Clang/GCC-style toolchains. On MSVC it enables
AddressSanitizer only because MSVC does not provide the same UBSan lane.

GPU gate:

```bash
cmake --preset dev
cmake --build --preset dev
ctest --preset gpu --output-on-failure
```

GPU feature capability and regression proof:

- Treat feature capability failures as hypotheses until the exact requested path has been tested on
  the selected GPU/device.
- Before disabling, hiding, downgrading, redesigning, or rewriting around a Vulkan, CUDA,
  ray-tracing, interop, upscaler, denoiser, shader-model, profiler, or hardware-extension feature,
  run the exact forced-feature lane when the project exposes one.
- Nearby green lanes are supporting evidence only. For example, a non-RT renderer pass does not
  prove an RT regression is fixed, a non-interop test does not prove interop, and a profile file does
  not prove stats readback unless the exact stats command succeeds.
- Capability dumps, engineering memory, failed-probe ledgers, and old comments are evidence to
  challenge, not authority. Current target-device repros and known-good/known-bad comparisons
  override stale memory.
- If the user says a feature used to work, names a suspected commit or boundary, or asks for
  historical comparison, test or inspect that boundary before changing feature gates, UI policy, or
  tests.
- Preserve explicit user selection plus diagnostics until the exact feature lane is proven
  unavailable on the target device. Do not remove or disable a user-facing feature just because one
  capability readback reported false.

CUDA sanitizer gate:

```bash
cmake --preset cuda-debug
cmake --build --preset cuda-debug
scripts/run_compute_sanitizer.sh
```

When only a subset of physical GPUs is usable for realtime CUDA work, set `CUDA_VISIBLE_DEVICES`
directly or use the helper allowlist:

```bash
GPU_ALLOWED_INDICES=<physical-index> CUDA_VISIBLE_DEVICES="$(scripts/select_idle_gpu.sh)" ctest --preset cuda --output-on-failure
GPU_ALLOWED_INDICES=<physical-index> scripts/run_compute_sanitizer.sh
```

Vulkan shader gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan-shader --output-on-failure
```

Vulkan runtime gate:

```bash
cmake --preset vulkan-debug
cmake --build --preset vulkan-debug
ctest --preset vulkan --output-on-failure
```

Vulkan validation gate:

```bash
cmake --preset vulkan-validation
cmake --build --preset vulkan-validation
scripts/run_vulkan_validation.sh
```

Use `scripts/run_vulkan_validation.sh` as the entrypoint for validation-layer runs. When
`VULKAN_SDK` points at a LunarG SDK, the wrapper also exposes the SDK validation-layer manifest and
library directory to the wrapped command so a visible `VK_LAYER_KHRONOS_validation` manifest does
not fail later as an instance-creation `ErrorLayerNotPresent` load error. If validation still fails
before any project Vulkan code runs, classify SDK, loader, ICD, layer-manifest, layer-library, and
physical-device failures separately before changing renderer code.

Run `ctest --preset vulkan-compute` for compute dispatch coverage and
`ctest --preset vulkan-render` for the headless offscreen dynamic-rendering smoke test. These lanes
require a usable Vulkan ICD with a Vulkan 1.3 physical device, synchronization2, dynamic rendering,
and a graphics+compute queue.

For realtime viewport readiness, do not treat CPU/software Vulkan as a green hardware result.
llvmpipe, Lavapipe, virtual GPUs, and CPU physical devices are useful diagnostic paths, but default
viewport-readiness tests should prefer discrete GPUs, then integrated GPUs, and should fail or report
a blocker when only CPU/software Vulkan is visible. If a diagnostic-only CPU run is intentionally
allowed, make that option explicit and print the selected device name/type, ICD/driver evidence,
queue support, and missing hardware requirement so the result cannot be confused with a production
realtime backend.

Benchmark smoke gate:

```bash
cmake --preset benchmark
cmake --build --preset benchmark
ctest --preset benchmark --output-on-failure
```

GPU optimization loop:

```bash
scripts/run_gpu_optimization_loop.py init --session opt-session --targets docs/GPU_OPTIMIZATION_TARGETS.tsv
scripts/run_gpu_optimization_loop.py baseline --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py profile --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py breaking-point --session opt-session --target-id <target> --param-name <name> --min <n> --max <n> --threshold <metric-threshold> --direction lower --cmd '<benchmark using {value}>'
scripts/run_gpu_optimization_loop.py plan-round --session opt-session --target-id <target>
scripts/run_gpu_optimization_loop.py hypothesis --session opt-session --target-id <target> --hypothesis-id H1 --confidence medium --summary "<hypothesis>" --evidence "<profile or code evidence>" --expected-effect "<expected metric effect>"
scripts/run_gpu_optimization_loop.py attempt --session opt-session --target-id <target> --round-id <round> --worker-id <worker> --tag <tag> --hypothesis-id H1 --description "<focused change>" --auto-revert
scripts/run_gpu_optimization_loop.py report --session opt-session
```

The loop is for deliberate performance sessions, not the default CI gate. It writes ignored
artifacts under `artifacts/optimization/`; use [GPU_OPTIMIZATION_LOOP.md](GPU_OPTIMIZATION_LOOP.md)
for the target-table schema, success-criteria gate, hypothesis log, profiler/SOL contract,
breaking-point search, benchmark contract, repeated validation passes, beam-round planning, and
keep/revert rules.

Use `scripts/dump_vulkan_capabilities.sh` when a Vulkan runtime lane fails before changing code. The
failure class matters: missing SDK tools, missing loader, missing ICD, no physical devices,
unsupported API version, unavailable features, shader validation failure, and validation-layer
messages are different problems.

Profiling smoke gate:

```bash
scripts/run_nsys_smoke.sh
```

The profiler smoke defaults to the Vulkan app path and requires `nsys`. Use
`REQUIRE_CUDA_PROFILING=1 PROFILE_LANE=cuda BUILD_DIR=build/cuda-debug scripts/run_nsys_smoke.sh`
when CUDA profiling also requires Nsight Compute tooling. Use `GPU_ALLOWED_INDICES=<physical-index>`
when CUDA profiling must avoid display-bound GPUs.

`run_nsys_smoke.sh` treats the `.nsys-rep` file as the primary artifact, then queries the installed
Nsight Systems CLI for supported stats reports and output formats before reading stats. It uses a
single `nsys stats --force-export=true --format column --report <explicit-reports>` command when
`column` is supported. Do not assume legacy report names such as `summary` or unsupported formats
such as `text`; report names vary between Nsight Systems versions. Override the auto-selected
reports only after checking the local tool:

```bash
nsys stats --help-reports
nsys stats --help
PROFILE_LANE=vulkan NSYS_STATS_REPORTS=vulkan_api_sum,osrt_sum,nvtx_sum scripts/run_nsys_smoke.sh
PROFILE_LANE=cuda NSYS_STATS_REPORTS=cuda_api_gpu_sum,cuda_gpu_kern_sum,osrt_sum,nvtx_sum scripts/run_nsys_smoke.sh
```

Benchmark and profiling result records should follow [BENCHMARKS.md](BENCHMARKS.md). Do not add
timing thresholds to CI until baselines are recorded for the exact runner hardware.

Vulkan debugging order:

1. Run with validation first.
2. Fix or classify validation messages.
3. Capture with RenderDoc or Nsight Graphics when visible render output or event order needs
   inspection.
4. Use Nsight Systems only for whole-frame CPU/GPU scheduling and overlap questions.

GUI or windowed tests must go through `ostm` when the offscreen-test-manager skill or CLI is
available. If OSTM is unavailable, use the project-approved offscreen/background launcher when the
repo defines one and state that OSTM evidence is unavailable. Prefer the repo's smoke script or
launcher wrapper for these runs. If an ad hoc offscreen-manager command is necessary, run it from
the repo root or pass absolute script paths so a manager working-directory mismatch cannot be
mistaken for an application failure. Do not add foreground GUI automation to CI by default, and do
not use repeated direct foreground app launches as an automated proof loop.

When a user-facing launch command is documented or changed, verify that exact command separately
from offscreen smoke. Use a bounded nonblocking probe: start the exact command, capture stdout/stderr,
identify the intended app process and window by pid/class/title, reject terminal-title and stale-window
matches, record mapped/normal/iconic state, workspace/desktop, geometry, focus/raise result, control
harness responsiveness, and then stop only the started app instance. A process-alive check, offscreen
capture, or window object on a hidden/off-desktop workspace is not enough to claim the human launch
path works.

For interactive GUI tools, app-smoke and nonblank screenshots are only launch evidence. User-visible
GUI behavior needs scenario evidence that exercises the real event path when practical:

- palette, toolbar, menu, shortcut, timeline, inspector, or dock controls should report the clicked
  or triggered action, active UI state before and after, frame/revision or event-loop turn, and
  event-to-committed-state latency
- viewport, canvas, sculpt, paint, groom, pick, gizmo, or graph interactions should report widget
  geometry, viewport-local coordinates, device-pixel ratio, render-target coordinates, hit ray or
  canvas transform, committed hit/edit point, and resulting selection/edit state
- visual captures used for GUI proof should be fresh for the requested state and, when practical,
  include a test-only marker or overlay at the requested pointer and committed hit/edit point

Do not accept a backend command success, generic revision increment, or delayed state update as proof
that a visible button, palette item, or pointer-mapped viewport interaction works. A GUI proof route
is not a substitute for visible observation: if the agent cannot see or capture the target surface,
the status must say that the agent is UI-blind on the reported behavior before more code is changed.
If the visible capture shows a flat, depth-pass-like, placeholder, or debug-looking product surface,
state that the product-visual concern is still unresolved even if the backend and semantic assertions
pass.

Interactive artist, game, VFX, DCC, simulation-editor, and technical-art tools also need primary
visible-loop proof before feature breadth. The loop is project-specific and should come from the
planning donor/peer-tool research: user action, state changed, visible result, and proof route. The
first milestone should prove that loop end to end, or explicitly prove a prerequisite required for
that loop. Do not count extra modes, tools, panels, format breadth, fixture-only variants, nonblank
screenshots, or backend revisions as product progress while the core visible loop is still
unproven.

For related tool families, validate the first real tool and the shared substrate before adding
siblings. Active-tool state, selection, input mapping, pressure/falloff, masks, undo/replay, dirty
resource updates, serialization, harness readback, and scenario proof should be common paths unless
a donor-backed reason makes a feature unique. Duplicated common behavior across tools is a
validation smell.

For donor-backed slices, validate donor feature disposition before accepting source work. If a plan
uses a donor shader, brush, renderer, solver, UI pattern, importer, optimizer, or subsystem, the
important donor features must be listed as included, deferred, rejected, or blocked with reasons and
validation signals. For shader donors, the pre-plan breakdown should include stages/passes, entry
points, inputs/outputs, descriptor/uniform contracts, coordinate spaces and units, variants/macros,
render states, sampling/filtering, lighting/material terms, quality features, edge cases, and
validation signals. A green build or plausible visual result does not prove the donor was followed
when important features silently disappeared.

For user-reported bugs, add a before/after proof before presenting the fix:

1. Reproduce the reported behavior first through the closest user-equivalent command, scenario, or
   manual harness path.
2. Save the before evidence: exact command/steps, scenario id, input sequence, state/readback fields,
   logs, screenshots/video/captures, Sonar readback when available, metrics, or failing assertions
   that show the symptom.
3. After changing code, rerun the same scenario or document the equivalence of any replacement.
4. Save the after evidence with the same fields and compare it to the before evidence.
5. Claim the bug is fixed only when the comparison shows a material change in the reported behavior.

For visible GUI/windowed bugs, run automated scenario, smoke, screenshot, and proof execution through
`ostm` when available, or through the project-approved nonblocking launcher/smoke manager when OSTM
is unavailable. Verify the target window with Sonar text/visual readback when those tools are
available. When Rewind is available, identify a pre-fix checkpoint before speculative GUI probes so
failed attempts can roll back cleanly; if no pre-change checkpoint exists, report that exact replay
was missed. If one attempt to add or use a proof route still cannot drive the real widget/window or
produce a fresh visible capture, stop expanding harness infrastructure for that bug. Continue only
with a bounded app-side root-cause fix that is explicitly labeled not visually proven yet, a repaired
single observation path, or a request for minimal manual visible evidence.

If before and after are identical, if the proof is self-confirming, if it covers only a narrower path
than the user's report, or if it tests backend state for a visible GUI bug, keep debugging. After the
repo's repeated-attempt threshold, start the status with "I am stuck on this bug:" and name the
missing proof and next diagnostic path.

If a visible bug, artist-tool interaction, viewport hit path, renderer/sim behavior, or domain
algorithm slice survives two focused attempts or roughly 20 minutes without direct symptom
improvement, stop local patching and realign with donors before another edit. Reopen the target code
map, matching donor route/profile, GUI/product-surface evidence, and current upstream or peer-tool
sources; perform a substantive current-source pass on the exact stuck layer; record donor facts,
links or queries, stale/conflicting evidence, local mismatch, failed hypotheses, keep/revert
decisions for speculative patches, and the next smallest proof. Do not keep relying on model memory,
backend-only success, token web searches, local-source-only inventories, or additional harness
scripts to justify more patches.

For long visual, reference-render, calibration, viewport-capture, import/export, or semantic-wrapper
lanes, declare the top-level acceptance artifact before repeated probes. If that artifact remains red
after three scenario/wrapper/OSTM runs, two source probes, or roughly 45 minutes, stop source edits
and write an acceptance ledger before another local probe. The ledger separates new evidence from
previously established work, final acceptance from debug-only buffers/logs/intermediates, failed
hypotheses from kept patches, and continue/cutover options. Diagnostic narrowing, internal debug
buffers, route inventory, generated intermediates, or successful wrapper execution do not count as
progress unless the final artifact changes or a named failure branch is eliminated with evidence.
Before staying on the same lane, run a narrow read-only stuck probe and a current web/upstream
research pass for the failing layer; local source inspection alone is not enough after repeated red
final artifacts. The research must be substantive enough to explain the exact stuck question, using
multiple current primary or upstream sources when available. Record official docs, upstream repos,
samples, issue trackers, release notes, vendor/standards docs, papers, or peer-tool references
checked, what each source proves, stale/conflicting evidence, and how it changes the next proof. Then
explicitly compare continuing with cutting over to an alternate donor, tool, or
validation lane that still satisfies the objective. If the next focused attempt still leaves the
final artifact red, run a fresh scoped adversarial review of that lane and artifact before any more
patching. If the user named a required upstream, app, SDK, shader, renderer, file format, or port
target, cutover options must preserve that reference family and success contract; unrelated peer
tools may be diagnostic comparisons, not replacement targets. Filter cutover options before
presenting them: a stale-context or peer-tool lane that conflicts with the required reference target
must be recorded as `rejected` or `diagnostic-only` with the reason, not offered as a user decision.
