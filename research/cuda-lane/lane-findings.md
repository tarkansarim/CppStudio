# CUDA Lane Findings

Last researched: 2026-04-30

## What Changes For The CppStudio Lane

- Keep the template version-flexible. The skill should validate that CUDA is discoverable and that
  CMake has a CUDA architecture policy, but it should not hardcode one global CUDA Toolkit version.
- Add current-version caveats to docs, not templates. CUDA 13.2 Update 1 is current in NVIDIA docs at
  this research date, but release-note patch caveats make exact pinning a project decision.
- Treat CUDA architecture as a first-class build input. `native` is fine for local dev, but release and
  self-hosted CI builds should set `PROJECT_CUDA_ARCHITECTURES` explicitly for the supported GPU fleet.
- Keep CUDA and Vulkan lanes mirrored but separate. CUDA owns kernel correctness, stream/graph launch
  policy, and Compute Sanitizer. Vulkan owns descriptor/pipeline/synchronization correctness and
  validation layers. CUDA/Vulkan interop is a named bridge, not a replacement for either lane.
- Use donor profiles for "what to inspect first." Agents should open CUTLASS, FlashAttention, Triton,
  and gsplat profiles before improvising CUDA kernel architecture.
- Require measured baselines before performance claims. Nsight Systems identifies scheduling and
  overlap issues; Nsight Compute follows only after a hot kernel is known.

## Skill Implications

- `cpp-cuda-vulkan-studio` should link a project archetype reference so agents choose the nearest lane
  before scaffolding or applying backbone files.
- Companion CUDA/Vulkan/CMake skills should receive source-owned donor-library links through rollout,
  avoiding hand edits to installed user-level skill files.
- Template docs should describe self-hosted GPU runner expectations, artifact paths, and benchmark
  records. They should avoid strict timing thresholds until a project records stable hardware-specific
  baselines.

## Risk Areas

- CUDA 13.x changed legacy architecture support and library behavior. Projects supporting Maxwell,
  Pascal, or Volta need an explicit CUDA 12.x lane or a separate compatibility decision.
- Blackwell IDs split across data-center, workstation/consumer, Jetson, and DGX Spark products. Using
  the wrong SM can produce slow code, missing features, or runtime failures for architecture-accelerated
  instructions.
- Donor code often carries hidden surfaces: submodules, assets, model weights, third-party notice
  files, proprietary SDKs, or PyTorch/Triton runtime assumptions.
- CUDA/Vulkan interop requires matching devices and explicit external memory/semaphore contracts. It
  should not be treated as ordinary CUDA buffer sharing.
