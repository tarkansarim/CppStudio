# OSPRay Donor Profile

Source: https://github.com/RenderKit/ospray  
Tier: `dependency-candidate`  
Backend signal: native-cpu
License signal: Apache-2.0; inspect `LICENSE.txt`, third-party notices, ISPC/oneAPI/TBB dependencies,
modules, tutorials, sample assets, and RenderKit component notices at the exact revision used.

## Use First For

- CPU ray-tracing-based high-fidelity visualization, scientific visualization renderer architecture,
  C/C++ rendering APIs, volume/geometry rendering, and scalable CPU rendering patterns.
- Comparing CPU visualization paths against Embree, OpenVDB/NanoVDB, VTK, or native Vulkan volume
  visualization.
- Reference behavior for volumes, path tracing, distributed rendering, and visualization-oriented
  materials.

## First Upstream Areas To Inspect

- `include/`, `ospray/`, `modules/`, `apps/tutorials/`, tests, examples, and docs.
- Volume, geometry, material, device, and renderer modules that match the target.
- ISPC, Embree, OpenVKL, oneAPI/TBB, MPI, and module dependencies before integration.
- Sample scenes and tutorial data before fixture reuse.

## Integration Notes

- Treat OSPRay as a dependency-scale CPU visualization renderer or reference path.
- Keep renderer API integration, scene data, volume data, distributed rendering, and native GPU viewer
  handoff separate.
- For Vulkan projects, use OSPRay as a CPU reference/visualization donor rather than a reason to drop
  Vulkan render validation.
- Prefer Embree for lower-level CPU ray queries when full visualization renderer scope is unnecessary.

## Validation Ideas

- Render tiny geometry and volume fixtures through selected OSPRay modules.
- Compare CPU visualization output against target GPU output with tolerant image metrics.
- Test missing module, unsupported device, invalid volume metadata, and empty scene behavior.
- Label CPU visualization tests separately from Vulkan/CUDA render tests.

## Caveats

- OSPRay is RenderKit dependency-scale and CPU-oriented.
- ISPC/oneAPI/MPI/module choices change build and deployment cost.
- Sample data and scientific datasets are separate license/provenance surfaces.
