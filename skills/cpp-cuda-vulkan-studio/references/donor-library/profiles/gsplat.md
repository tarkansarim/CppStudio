# gsplat Donor Profile

Source: https://github.com/nerfstudio-project/gsplat  
Tier: `safe-donor`  
Backend signal: native-cuda
License signal: Apache-2.0; inspect `LICENSE`, Python package metadata, dependencies, examples, and
data/model assets at the exact revision used.

## Use First For

- CUDA-accelerated Gaussian splatting rasterization with Python bindings.
- Neural 3D operator packaging, differentiable rasterizer APIs, and benchmark/evaluation patterns.
- A permissive alternative to the original GraphDeco Gaussian Splatting reference implementation.
- CUDA/C++/Python boundary design for 3D AI operators.

## First Upstream Areas To Inspect

- `gsplat/` for library and binding structure.
- `examples/` for training/rendering workflows.
- `tests/` for correctness coverage.
- `profiling/` for performance measurement patterns.
- `docs/` and docs.gsplat.studio for API, wheel, and platform guidance.

## Integration Notes

- Use gsplat before copying from non-commercial Gaussian Splatting references.
- Keep Python/PyTorch dependency scope explicit in a C++ project.
- Separate reusable CUDA/C++ operator ideas from training scripts, datasets, and model artifacts.
- Validate camera convention, coordinate system, precision, batching, and gradient expectations before
  adapting operator code.

## Validation Ideas

- Compare against known small scenes and CPU/debug reference projections where possible.
- Test batch, multi-view, empty-scene, very small/large Gaussian count, and extreme covariance cases.
- Track memory use, training/rendering time, and image metrics separately.
- For CUDA or mixed-lane project-owned CUDA adaptations, run reduced-shape Compute Sanitizer lanes. For
  Vulkan ports, use Vulkan validation, shader/SPIR-V checks, and offscreen image/metric fixtures instead.

## Caveats

- The repo is Python/PyTorch shaped even though it contains substantial CUDA/C++ code.
- Example datasets and trained outputs are separate license surfaces.
- The original GraphDeco implementation remains study-only for reusable CppStudio outputs; gsplat is
  the preferred permissive donor for implementation patterns.
