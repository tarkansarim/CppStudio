# Donor Selection Policy

Use this policy to keep donor-code usage clean, reusable, and auditable.

## Default Decision

Prefer `safe-donor` projects for reusable skill/template code. Treat `dependency-candidate` projects as
versioned dependency decisions, not as default copy/paste sources. Keep `study-only` projects in
research notes or design discussion unless the user explicitly approves a license-specific path.

Donor selection is domain-first. Pick the best source for the algorithm, data model, file format,
test case, or architecture even if the donor's backend differs from the target project. The active
lane still controls implementation: Vulkan targets port donor ideas through Vulkan tooling and
synchronization, CUDA targets port donor ideas through CUDA tooling and kernel policy, and mixed
CUDA/Vulkan lanes require explicit user choice or a real interop need.

## Safe-Donor Checklist

Before adapting code or adding a dependency:

1. Confirm the repo license from the upstream `LICENSE`, `COPYING`, or official README.
2. Check for exceptions: `non_commercial/`, `third_party/`, assets, model weights, datasets, SDK EULAs, submodules.
3. Identify the exact donor scope: one algorithm, one API pattern, one test pattern, one build-module pattern, or a full dependency.
4. Preserve attribution and notices required by the donor license.
5. Prefer small, idiomatic reimplementation from the concept when the implementation is simple.
6. Avoid importing donor-specific architecture unless it fits the target repo's existing shape.
7. Translate backend-specific memory, synchronization, shader, kernel, packaging, and runtime details through
   the active lane skill instead of copying them across lanes.

## Backend Signals

Use `Backend signal:` in donor profiles to describe the donor's upstream implementation surface. These
signals are descriptive metadata, not routing locks.

Allowed values are `native-vulkan`, `native-cuda`, `native-opencl`, `native-directx`, `native-opengl`,
`native-webgpu`, `native-metal`, `native-cpu`, `dcc-interchange`, `api-agnostic`, and
`mixed-backend`. Multiple values may be comma-separated.

Examples:

- A Vulkan project may use a CUDA Gaussian-splatting donor for algorithm, data layout, numerical tests,
  and edge cases, then implement the target path with Vulkan compute/render guidance.
- A CUDA project may use a Vulkan, OpenCL, DirectX, or CPU simulation donor for solver organization and
  validation fixtures, then implement kernels with CUDA lane guidance.
- Backend mismatch should create a porting-risk note, not a silent lane switch or hidden dependency.

## Tier Meanings

| Tier | Allowed Use | Requirements |
| --- | --- | --- |
| `safe-donor` | Copy/adapt small code, tests, build ideas, examples, and dependency patterns. | Preserve notices; cite donor in docs when meaningful. |
| `dependency-candidate` | Add as a deliberate dependency or study architecture/API shape. Do not copy code by default. | Confirm exact version, build cost, transitive licenses, copyleft/exception terms, optional modules, and target repo dependency policy. |
| `study-only` | Learn concepts, compare algorithms, write independent implementations. | Do not copy code into project or skills without explicit approval and license review. |

## Red Flags

- Non-commercial, research-only, evaluation-only, or "NVIDIA Source Code License" terms.
- GPL/LGPL/AGPL source when the target project is meant to stay permissive or proprietary-compatible.
- Missing license files, license text that only applies to part of the repo, or contradictory README/license claims.
- Model checkpoints, datasets, pretrained weights, and assets bundled under different terms than code.
- CUDA samples that depend on proprietary SDK components not redistributable with the target repo.
- Backend-specific donor code that would introduce an unchosen runtime, driver, shader compiler, SDK, or
  build dependency into the target lane.

## Attribution Pattern

When adopting a donor pattern in a project doc, use a compact note:

```markdown
Donor reference: <project name> (<url>), <license>, consulted for <feature>.
No donor code copied / Adapted <small component>; notices retained in <path>.
```

## Study-Only Handling

Study-only projects are still valuable. Use them to understand papers, expected behavior,
performance envelopes, file formats, and test cases. Convert the learning into independent,
source-backed implementation notes instead of copying implementation text.
