# PyTorch3D Donor Profile

Source: https://github.com/facebookresearch/pytorch3d  
Tier: `dependency-candidate`  
Backend signal: native-cuda
License signal: BSD-style; inspect `LICENSE`, `INSTALL.md`, examples, datasets, third-party notices,
and package dependencies at the exact revision used.

## Use First For

- Differentiable rendering, mesh/point-cloud operators, cameras, transforms, rasterization, losses, and
  3D learning components.
- PyTorch-native reference behavior for custom neural 3D or renderer-adjacent operations.
- Comparing camera/data conventions against Nerfstudio, Kaolin, Open3D, and project-native renderers.

## First Upstream Areas To Inspect

- `pytorch3d/`, `tests/`, tutorials, docs, and examples matching the target primitive.
- Camera, rasterizer, mesh, point-cloud, loss, and IO modules before porting behavior.
- Package/build requirements and CUDA extension boundaries.
- Example datasets, images, and model assets before using fixtures.

## Integration Notes

- Treat PyTorch3D as a dependency or reference-output donor, not a C++ renderer dependency.
- Keep tensor reference tests separate from target Vulkan/CUDA implementation.
- Use it to clarify camera, rasterization, and mesh semantics before writing project-owned GPU code.
- Prefer project-native C++/Vulkan code for runtime viewers unless PyTorch is explicitly in scope.

## Validation Ideas

- Compare camera projections, rasterization, depth, barycentrics, mesh sampling, and point-cloud metrics
  on tiny deterministic fixtures.
- Test empty geometry, batched scenes, non-contiguous tensors, dtype/device handling, and coordinate
  convention errors.
- Use PyTorch3D outputs as references for CUDA/Vulkan ports when the Python test lane is acceptable.
- Record PyTorch/PyTorch3D/CUDA versions with numerical tolerances.

## Caveats

- It is Python/PyTorch shaped and dependency-scale.
- Some examples depend on external datasets or assets.
- Do not copy implementation into reusable C++ code without exact license and dependency review.
