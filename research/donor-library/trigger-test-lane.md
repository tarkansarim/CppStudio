# Donor Library Trigger Test Lane

Run date: 2026-04-30

This lane forward-tested whether fresh agents pick the intended skills and donor-reference files for
graphics, CUDA/AI kernels, geometry/simulation, neural 3D, and a negative non-GPU task.

The repeatable regression matrix for future reruns lives in `trigger-matrix.json`; repo validation
checks only that referenced skill and donor files still exist. Use
`trigger-regression-checklist.md` for fresh manual or subagent reruns.

## Test Matrix

| Case | Prompt Shape | Expected Result | Observed Result |
| --- | --- | --- | --- |
| A | C++ Vulkan renderer donors for dynamic rendering, synchronization, frame capture, renderer architecture | `cpp-cuda-vulkan-studio`; optionally `vulkan-compute-sync`, `gpu-profiling-workstation`; read graphics donors | Passed. Agent selected `cpp-cuda-vulkan-studio`, graphics donor files, Khronos Vulkan-Samples, NVIDIA vk_mini_samples, Filament, Diligent, Magnum, bgfx, Falcor. |
| B | Custom CUDA fused attention/MLP-like AI kernel donors before hand-rolling | `cuda-kernel-authoring` plus `cpp-cuda-vulkan-studio`; read AI runtime/kernel donors | Passed. Agent selected `cuda-kernel-authoring`, donor policy, `ai-runtimes-kernels.md`, FlashAttention, tiny-cuda-nn, CUTLASS, Triton, vLLM/TensorRT-LLM conditionally. |
| C | Modern C++/CMake graphics app donors for mesh import, optimization, BVH, physics | `cpp-cuda-vulkan-studio` plus `modern-cpp-cmake`; read geometry/simulation donors | Passed. Agent selected geometry/simulation and graphics donors, assimp, meshoptimizer, madmann91/bvh, Embree, Jolt, Bullet. |
| D | Neural 3D support with Gaussian splatting or NeRF-style pipelines | `cpp-cuda-vulkan-studio`; read neural 3D donors and policy | Passed. Agent selected `neural-3d.md`, gsplat, Nerfstudio, Open3D, PyTorch3D, Kaolin, tiny-cuda-nn, and classified GraphDeco/instant-ngp/Wisp as study-only. |
| E | Non-GPU Python virtualenv import failure | Do not trigger donor-library skill | Passed. Agent selected debugging/onboarding skills only and explicitly rejected donor-library trigger. |

## Focused Installed-Skill Rerun

After the first lane, the rollout script was found to be writing empty companion-skill marker blocks
for `cuda-kernel-authoring` and `vulkan-compute-sync`. The bug was in `scripts/rollout_to_codex.sh`:
legacy cleanup ran after marker replacement and removed the newly inserted block body. The script now
cleans legacy text first, then replaces or inserts the marked block.

Focused reruns used only installed paths under `/home/tarkan/.codex`:

| Case | Expected Installed Paths | Observed Result |
| --- | --- | --- |
| CUDA focused | `/home/tarkan/.codex/skills/cuda-kernel-authoring/SKILL.md`, installed donor policy, `ai-runtimes-kernels.md` | Passed. Agent read installed skill files and selected FlashAttention, CUTLASS, tiny-cuda-nn, Triton. |
| Vulkan focused | `/home/tarkan/.codex/skills/vulkan-compute-sync/SKILL.md`, installed donor policy, `graphics-rendering.md` | Passed. Agent read installed skill files and selected Khronos Vulkan-Samples first, NVIDIA vk_mini_samples second. |

## Findings

- The main `cpp-cuda-vulkan-studio` description is broad enough to trigger donor-reference selection
  for graphics, 3D, CUDA, Vulkan, rendering, and AI runtime tasks.
- The companion skills trigger correctly for subsystem work and now carry installed donor-library
  links in marked blocks.
- Negative control behaved correctly: non-GPU Python debugging did not trigger the donor library.
- Ambiguity was contextual rather than blocking:
  - "Frame capture" may also trigger `gpu-profiling-workstation`.
  - "Graphics app" may or may not need `vulkan-compute-sync` depending on whether synchronization or
    Vulkan lifetime work is actually in scope.
  - "Neural 3D support" can mean donor guidance or actual implementation; implementation should
    activate `cuda-kernel-authoring`, `vulkan-compute-sync`, or `modern-cpp-cmake` as needed.

## Decision

No skill description changes were required from this lane. The actionable defect was rollout-script
idempotency/content preservation, and that was fixed in `scripts/rollout_to_codex.sh`.

## All-Bliss Rerun

Run date: 2026-04-30

This lane re-tested the expanded CUDA/Vulkan/neural-3D donor profiles, source-owned companion snippets,
and project archetype reference after rollout.

| Case | Prompt Shape | Observed Result |
| --- | --- | --- |
| CUDA donor profiles | Custom CUDA C++ attention or GEMM kernel, donor references before implementation | Passed. Agent selected `cuda-kernel-authoring` as primary and `cpp-cuda-vulkan-studio` as secondary. It read installed donor policy, `ai-runtimes-kernels.md`, and the CUTLASS, FlashAttention, and Triton deep profiles. |
| Vulkan donor profiles | Vulkan compute pipeline with descriptor sets, push constants, barriers, and sample donors | Passed. Agent selected `vulkan-compute-sync` and `cpp-cuda-vulkan-studio`. It read installed donor policy, `graphics-rendering.md`, and the Khronos Vulkan-Samples and NVIDIA vk_mini_samples profiles. |
| Neural 3D archetype | Greenfield C++/CUDA/Vulkan neural 3D Gaussian splat viewer/runtime | Passed. Agent selected `cpp-cuda-vulkan-studio`, then conditional `modern-cpp-cmake`, `vulkan-compute-sync`, and `cuda-kernel-authoring`. It read `project-archetypes.md`, `neural-3d.md`, `graphics-rendering.md`, and the `gsplat` and Khronos Vulkan-Samples profiles. |
| Python negative control | Small Python CLI parser with unit tests and no C++/GPU/Vulkan/CUDA/rendering/3D/AI-runtime scope | Passed. Agent rejected the CppStudio/GPU donor lane. |

## Rerun Findings

- Deep donor profiles were discoverable from installed paths through the donor README, category files,
  and companion-skill donor blocks.
- Pure Vulkan compute should not be nudged toward `geometry-simulation.md`; the Vulkan companion snippet
  now makes geometry/simulation conditional on asset, mesh, BVH, physics, point-cloud, or simulation
  context.
- A shorter "splat viewer" request may need trigger-facing wording. The main CppStudio skill
  description now explicitly includes neural 3D and Gaussian splatting.
- Broad "AI" wording was narrowed to AI-runtime/ML-kernel language in donor-library and companion
  snippets to reduce false triggers for ordinary Python tasks performed by an AI assistant.

## Expanded 3D Donor Lane Rerun

Run date: 2026-04-30

This lane re-tested the added 3D donor categories, deep profiles, rollout guards, and companion links
from installed paths under `/home/tarkan/.codex/skills`.

| Case | Prompt Shape | Observed Result |
| --- | --- | --- |
| Hair/grooming/fur | C++/Vulkan donors for realtime hair, grooming, fur strand simulation, and a groom viewer | Passed. Agent selected `cpp-cuda-vulkan-studio`, `hair-grooming-fur.md`, TressFX first, OpenUSD BasisCurves/Alembic for interchange, and kept HairWorks/Blender study-only. |
| DCC scene pipeline | USD/Alembic import, material translation, runtime asset preparation for a C++ viewer | Passed. Agent selected `dcc-scene-pipeline.md`, OpenUSD and MaterialX profiles, Alembic as cache donor, and conditional texture/color profiles. It correctly left `vulkan-compute-sync` out until Vulkan rendering is explicit. |
| Volumes/voxels | Sparse volume and voxel renderer using VDB/NanoVDB with Vulkan compute visualization | Passed. Agent selected `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, `volumes-voxels.md`, OpenVDB/NanoVDB, Khronos Vulkan-Samples, and kept fVDB conditional on ML/PyTorch needs. |
| Animation/rigging | Native C++ skeletal animation runtime with sampling, blending, skinning, and optional compression | Passed. Agent selected `animation-rigging.md`, ozz-animation first, ACL for compression, Assimp/OpenUSD UsdSkel for import/interchange, and engine donors as references only. |
| Texture/material/color | KTX2/Basis delivery, OpenImageIO conversion, OpenColorIO management, MaterialX graphs | Passed. Agent selected `texture-material-color.md`, KTX/Basis, OpenColorIO/OpenImageIO, and MaterialX profiles. It treated DCC scene pipeline as adjacent, not primary. |
| CAD/precision geometry | STEP/IGES, B-reps/NURBS, display tessellation, robust geometry | Passed. Agent selected `cad-precision-geometry.md`, Open CASCADE first, CGAL/libigl as secondary, and FreeCAD study-only. |
| XR/spatial | Vulkan/OpenXR headset app with stereo swapchains, action bindings, frame timing, controller input | Passed. Agent selected `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, `xr-spatial.md`, OpenXR SDK profile, and Khronos Vulkan-Samples. NVIDIA samples stayed secondary. |
| Python negative control | Small Python argparse CLI/unit tests with no C++/GPU/rendering/3D/CUDA/Vulkan/AI-runtime scope | Passed. Agent inspected only CppStudio skill metadata and did not open donor-library files. |

## Expanded Lane Findings

- Trigger descriptions are specific enough for the new 3D lanes and did not cause the Python negative
  control to trigger.
- Two missing deep-profile gaps were found during the lane and fixed before final rollout:
  - Alembic now has `profiles/alembic.md` and is linked from DCC and grooming categories.
  - Animation Compression Library now has `profiles/acl.md` and is linked from animation/rigging.
- Category overlap behaved correctly:
  - MaterialX can be DCC or texture/material/color, and agents chose the primary category based on the
    prompt.
  - Vulkan profiles join volume/XR work only when Vulkan compute, swapchains, or frame lifetime are in
    scope.
  - CAD robust geometry keeps Open CASCADE primary for CAD semantics and CGAL secondary for exact
    computational geometry.

## Adversarial-Gap Rerun

Run date: 2026-04-30

This lane re-tested gaps found during adversarial review: subdivision/surface routing, advanced
simulation routing, and a negative non-3D business simulation prompt. Tests used installed paths under
`/home/tarkan/.codex/skills` after rollout.

| Case | Prompt Shape | Observed Result |
| --- | --- | --- |
| Surfaces/subdivision | C++ donor guidance for subdivision surfaces, creases, face-varying UVs, and CPU/GPU OpenSubdiv comparison | Passed. Agent selected `cpp-cuda-vulkan-studio`, `surfaces-subdivision.md`, and `profiles/opensubdiv.md`. It did not trigger `vulkan-compute-sync` because GPU OpenSubdiv evaluation alone does not imply Vulkan barriers/descriptors/swapchains. |
| 3D/physics/GPU simulation | Donors for cloth, deformables, particles, differentiable CUDA prototypes, and realtime rigid-body integration | Passed. Agent selected `cpp-cuda-vulkan-studio`, `simulation-gpu.md`, and the Warp, Taichi, PositionBasedDynamics, Project Chrono, and PhysX profiles. It kept `cuda-kernel-authoring` conditional until native CUDA kernels are actually written or reviewed. |
| Business simulation negative control | Python Monte Carlo revenue forecast CLI/tests with no C++/GPU/rendering/3D/physics/CUDA/Vulkan/AI-runtime scope | Passed. Agent did not trigger `cpp-cuda-vulkan-studio` or donor-library files. It noted only a naive keyword matcher would misfire on negated terms. |

## Adversarial-Gap Findings

- Narrowing the skill trigger from generic "simulation" to `3D/physics/GPU simulation` reduced the false
  positive risk without weakening intended simulation routing.
- The subdivision lane correctly stays independent from Vulkan synchronization until Vulkan integration
  is explicit.
- The simulation lane now has enough deep-profile guidance for agents to distinguish prototype donors
  from native C++ donors and SDK dependencies.

## Domain-First Backend-Mismatch Rerun

Run date: 2026-04-30

This lane re-tested the donor-library change that makes donors domain references first instead of
CUDA/Vulkan lane locks. Tests used installed paths under `/home/tarkan/.codex/skills` after rollout.

| Case | Prompt Shape | Observed Result |
| --- | --- | --- |
| Vulkan neural 3D with CUDA-heavy donor | Vulkan-first C++ Gaussian splatting/neural 3D viewer where the strongest donor implementation is CUDA-heavy | Passed. Agent selected `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, and `modern-cpp-cmake`; used `gsplat` as a CUDA donor for algorithm/data-layout/test reference; kept CUDA runtime, CUDA tests, and CUDA/Vulkan interop out by default. |
| Vulkan grooming with mixed-backend references | Vulkan C++ grooming/fur tool with possible DirectX, CUDA, DCC, or older vendor references | Passed. Agent selected `cpp-cuda-vulkan-studio`, `vulkan-compute-sync`, and `modern-cpp-cmake`; used TressFX, OpenUSD, and Khronos Vulkan-Samples; kept HairWorks/Blender study-only and did not add CUDA or interop. |
| CUDA simulation with non-CUDA donors | Explicit CUDA C++ cloth/particle simulation kernel using solver/layout/test ideas from Vulkan, OpenCL, DirectX, CPU, or DCC donors | Passed. Agent selected `cpp-cuda-vulkan-studio` and `cuda-kernel-authoring`; used `simulation-gpu.md`, Warp, Taichi, PositionBasedDynamics, and PhysX; did not add Vulkan runtime or interop. |
| Python negative control | Python argparse CLI/unit tests with no C++/GPU/rendering/3D/AI-runtime/CUDA/Vulkan scope | Passed. Agent did not trigger CppStudio or donor-library routing. |

## Domain-First Findings

- Backend mismatch now behaves as intended: donors remain available for algorithms, layouts, tests,
  and architecture, while lane-specific implementation stays with the chosen CUDA or Vulkan skill.
- Two wording issues were found and fixed after the rerun:
  - Neural 3D verification now limits CUDA sanitizer to explicit CUDA or mixed-lane project-owned CUDA
    kernels.
  - Grooming archetype wording now enables CUDA only when the user chooses CUDA or the project explicitly
    requires project-owned CUDA kernels.
- The CUDA companion donor snippet now points simulation CUDA work to `simulation-gpu.md` and neural 3D
  CUDA work to `neural-3d.md`, instead of implying that every CUDA donor search starts with AI kernels.
