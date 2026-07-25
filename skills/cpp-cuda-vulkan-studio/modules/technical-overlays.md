# Technical Overlay Router

Technical overlays are independent of process state. Load only those whose
contracts are touched.

| Trigger | Overlay |
| --- | --- |
| CMake targets, presets, dependencies, CTest, build ownership | `modules/modern-cpp-cmake/GUIDE.md` |
| CUDA kernels, launch geometry, memory, numerical behavior | `modules/cuda-kernel-authoring/GUIDE.md` |
| Vulkan synchronization, descriptors, layouts, queues, lifetime | `modules/vulkan-compute-sync/GUIDE.md` |
| Profiling, hardware utilization, capability, frame or kernel cost | `modules/gpu-profiling-workstation/GUIDE.md` |
| Native GUI, HUD, editor controls, layout, product surface | `modules/native-cpp-gui-hud/GUIDE.md` |
| App launch/control/readback API or automation surface | `modules/agentic-control-harness/GUIDE.md` |
| Real viewport, stylus, drag, stroke, gesture, or replay proof | `modules/viewport-session-testing/GUIDE.md` |
| Active supervised worker lane | `modules/cppstudio-supervisor/GUIDE.md` |
| Governed project or architecture planning | `modules/cppstudio-project-planner/GUIDE.md` |
| Existing enabled code map | `.cppstudio/code-map-state.json`, architecture index, manifest, and matching subsystem document |
| Standardized format, protocol, or SDK schema | Official specification/API plus the matching donor/reference route |

## Activation Rules

- A technical overlay activates from the contract being changed, not task size.
- Several overlays may be active when the implementation genuinely crosses
  their contracts. Do not load an overlay because it is merely adjacent.
- An enabled code map remains the first routing source for affected code, but
  map maintenance and sidecars run only when ownership, data flow, public
  behavior, validation routing, or routable paths actually change.
- If the user says a path previously worked, compare the known-good path before
  replacing it.
- Before hiding, disabling, or downgrading requested GPU functionality, prove
  the exact capability path on the target device.
- User-facing settings require proof through the visible control path and the
  committed runtime state they own.
- Performance claims require matched workload and hardware evidence. Preserve
  the user's requested quality unless they approve a tradeoff.
- Standardized contracts require official semantics before the first relevant
  edit; do not wait for Recovery.

Process state controls coordination. Technical overlays control engineering
correctness. Neither replaces the other.
