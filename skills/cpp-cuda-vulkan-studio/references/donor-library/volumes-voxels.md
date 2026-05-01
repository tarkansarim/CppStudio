# Volumes And Voxels Donors

Use these donors for sparse volumes, VDB/NanoVDB, fog/smoke/fire, voxel grids, scientific
visualization, GPU volume rendering, collision fields, and neural sparse-volume experiments.

## Sparse Volumes And GPU VDB

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenVDB](https://github.com/AcademySoftwareFoundation/openvdb) | dependency-candidate | Apache-2.0 in current releases; older releases were MPL-2.0 | Sparse volume data structures, VDB IO, level sets, fog volumes, production VFX volume workflows. |
| [NanoVDB](https://developer.nvidia.com/nanovdb) | safe-donor | Part of OpenVDB; verify exact version license | GPU-friendly VDB layout, CUDA/OptiX/Vulkan-style volume traversal and rendering concepts. |
| [fVDB](https://openvdb.github.io/fvdb-core/) | dependency-candidate | Apache-2.0 | PyTorch/GPU sparse-volume tensors, neural fields, large-domain spatial ML, GPU volume algorithms. |
| [VTK](https://docs.vtk.org/en/latest/about.html) | dependency-candidate | BSD-style | Scientific visualization, volume rendering, image processing, C++/Python visualization pipelines. |

## Selection Notes

- Use OpenVDB when file interoperability and production sparse-volume tooling matter.
- Use NanoVDB when runtime GPU traversal or compact static volume representation matters.
- Use fVDB for ML/PyTorch sparse-volume research and neural 3D experiments, not as a C++ engine
  dependency by default.
- Use VTK for scientific visualization architecture, not as a lightweight game/rendering dependency.
- Keep volume datasets, trained models, medical/scientific data, and simulation caches as separate
  license and provenance surfaces.

## Deep Profiles

- [OpenVDB And NanoVDB](profiles/openvdb-nanovdb.md): read before adopting VDB volume IO or GPU VDB traversal.
- [fVDB](profiles/fvdb.md): read before using sparse-volume tensors, PyTorch/CUDA sparse-grid ML, or neural-volume references.
- [VTK](profiles/vtk.md): read before adopting scientific visualization, volume-rendering toolkit architecture, or VTK data/filter pipelines.
