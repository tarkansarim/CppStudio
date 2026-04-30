# Trigger Regression Checklist

Use this checklist when rerunning the donor-library trigger lane with a fresh subagent or reviewer.
The static validator only proves that paths in `trigger-matrix.json` still exist.

## Required Evidence

- Record the run date, agent type, and whether the test used source paths or installed skill paths.
- For each case in `trigger-matrix.json`, record the prompt shape, selected skills, opened donor or
  reference files, and whether any forbidden path/category was used.
- For negative controls, record that `cpp-cuda-vulkan-studio` and donor-library files were not used.
- Treat ambiguous triggers as findings only when they would route an implementation to the wrong
  lane or donor category.

## Expected Routing

- Unspecified C++ realtime, 3D, rendering, XR, or cross-platform GPU work should route to
  `cpp-cuda-vulkan-studio`, recommend Vulkan first, and avoid CUDA donors unless requirements force
  CUDA.
- Explicit CUDA kernel, CUTLASS, FlashAttention, CUDA graph, or NVIDIA-only runtime work should route
  to CUDA-specific donors and skills first.
- Explicit CUDA/Vulkan interop should use the mixed lane and keep the CUDA/Vulkan boundary visible.
- Backend-mismatched donors should remain available as domain references. A Vulkan target may use CUDA,
  OpenCL, DirectX, CPU, or DCC donors without adding those runtimes; a CUDA target may use Vulkan,
  OpenCL, DirectX, CPU, or DCC donors without switching lanes.
- Mixed CUDA/Vulkan routing should happen only when the user explicitly requests interop/mixing or when
  the technical requirements force actual cross-backend resource sharing.
- Non-GPU Python, CLI, parser, virtualenv, or business-simulation work should not trigger CppStudio
  donor routing.
