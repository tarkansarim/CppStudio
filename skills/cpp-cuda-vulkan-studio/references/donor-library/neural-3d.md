# Neural 3D And 3D AI Donors

Use these donors for NeRFs, Gaussian splatting, differentiable rendering, 3D ML data structures,
training workflows, point-cloud/reconstruction workflows, and neural graphics pipelines.

## Safe Or Dependency Candidates

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Nerfstudio](https://github.com/nerfstudio-project/nerfstudio) | dependency-candidate | Apache-2.0 | NeRF/3DGS training pipelines, camera/data processing, experiment structure, viewer/export workflows. |
| [gsplat](https://github.com/nerfstudio-project/gsplat) | safe-donor | Apache-2.0 | CUDA-accelerated Gaussian splatting rasterization, Python bindings, differentiable rasterizer API. |
| [NVIDIA Kaolin](https://github.com/NVIDIAGameWorks/kaolin) | dependency-candidate | Mostly Apache-2.0; `kaolin/non_commercial` is restricted | 3D deep-learning ops, differentiable rendering, mesh/voxel/point-cloud conversions. Avoid non-commercial subpackage. |
| [PyTorch3D](https://github.com/facebookresearch/pytorch3d) | dependency-candidate | BSD-style | Differentiable rendering, mesh/point-cloud ops, camera transforms, 3D learning components. |
| [Open3D](https://github.com/isl-org/Open3D) | dependency-candidate | MIT | 3D data processing plus Open3D-ML integration for perception and reconstruction workflows. |

## Study-Only References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [graphdeco-inria/gaussian-splatting](https://github.com/graphdeco-inria/gaussian-splatting) | study-only | Non-commercial research/evaluation license | Original 3DGS behavior, paper reference implementation, expected training/rendering pipeline. Do not copy code into reusable projects. |
| [NVlabs/instant-ngp](https://github.com/NVlabs/instant-ngp) | study-only | NVIDIA Source Code License, non-commercial use limitation | Hash-grid NeRF concepts, UI/workflow expectations, performance targets. |
| [Kaolin Wisp](https://github.com/NVIDIAGameWorks/kaolin-wisp) | study-only | NVIDIA Source Code License, non-commercial use limitation | Neural fields, NeRF/NGLOD/instant-ngp-style pipeline concepts. |

## Selection Notes

- For Gaussian splatting implementation, prefer `gsplat` over the original GraphDeco code because `gsplat` is Apache-2.0 and actively library-shaped.
- For Vulkan-first Gaussian splatting or neural 3D, still use CUDA-heavy donors such as `gsplat` for
  rasterization behavior, data layout, numerical edge cases, and tests, then port the target path through
  Vulkan compute/render guidance instead of adding CUDA by default.
- For general neural 3D experiments, use Nerfstudio for workflow and PyTorch3D/Kaolin/Open3D for reusable operators.
- For fused MLPs, hash grids, or compact CUDA neural kernels, route through `ai-runtimes-kernels.md` and
  the tiny-cuda-nn profile.
- Keep GraphDeco Gaussian Splatting, instant-ngp, and Kaolin Wisp study-only unless the user explicitly
  approves a license-specific path.
- Treat pretrained models, datasets, camera captures, and generated assets as separate license surfaces even when code is permissive.

## Deep Profiles

- [Nerfstudio](profiles/nerfstudio.md): read before designing neural 3D training, camera/data processing, viewer, or export workflows.
- [gsplat](profiles/gsplat.md): read before adapting CUDA Gaussian splatting rasterization or neural 3D operator packaging.
- [NVIDIA Kaolin](profiles/kaolin.md): read before using 3D deep-learning ops, conversion utilities, or differentiable rendering references.
- [PyTorch3D](profiles/pytorch3d.md): read before using differentiable rendering, cameras, mesh/point-cloud ops, or reference outputs.
- [Open3D](profiles/open3d.md): read before 3D data processing, point-cloud/reconstruction, visualization, or Open3D-ML workflows.
- [Neural Graphics Study-Only References](profiles/neural-graphics-study-only.md): read before consulting GraphDeco Gaussian Splatting, instant-ngp, or Kaolin Wisp.
