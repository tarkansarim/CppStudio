# VTK Donor Profile

Source: https://docs.vtk.org/en/latest/about.html  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: BSD-style VTK license; inspect source repository license files, third-party modules,
optional IO/rendering dependencies, examples, datasets, and wrapped-language components at the exact
revision used.

## Use First For

- Scientific visualization architecture, data arrays, structured/unstructured grids, volume rendering,
  image processing, filters, and C++/Python visualization pipelines.
- Reference behavior for medical, engineering, simulation, or scientific data visualization workflows.
- Comparing a full visualization toolkit against narrower OSPRay, OpenVDB, Open3D, or renderer-native
  visualization paths.

## First Upstream Areas To Inspect

- Dataset/data-object model docs before designing project-native scientific data structures.
- Filters, readers/writers, volume rendering, and rendering examples that match the target domain.
- Module/dependency configuration before recommending VTK as a package dependency.
- Example data and regression-image assets before using fixtures.

## Integration Notes

- Treat VTK as dependency-scale visualization infrastructure, not a small graphics helper.
- Keep data model, file IO, filter pipeline, rendering backend, Python wrapping, and UI toolkit choices
  separated.
- For Vulkan projects, use VTK as a scientific visualization donor or CPU/reference pipeline unless the
  target intentionally embeds VTK.
- Prefer narrower donors when the task only needs VDB IO, BVH queries, or simple image/mesh filters.

## Validation Ideas

- Add tiny structured grid, unstructured mesh, image, and volume fixtures.
- Test missing reader module, unsupported dataset type, empty arrays, invalid scalar ranges, and headless
  rendering behavior.
- Compare rendered outputs with tolerant image metrics only after data/filter assertions pass.
- Label visualization toolkit tests separately from Vulkan/CUDA lane tests.

## Caveats

- VTK's module graph can add substantial build and deployment cost.
- Wrapped-language and UI dependencies are separate integration decisions.
- Scientific datasets and regression images need separate provenance checks.
