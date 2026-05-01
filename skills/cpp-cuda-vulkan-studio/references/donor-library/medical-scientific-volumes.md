# Medical And Scientific Volume IO Donors

Use these donors for medical image IO, DICOM/NIfTI/OME-style data, scientific volume rendering,
transfer functions, chunked multidimensional arrays, tomography, and large-scale scientific IO.
For sparse VDB-style volumes, use [volumes-voxels.md](volumes-voxels.md) first.

## Medical Image IO, Conversion, And Processing

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [ITK](https://github.com/InsightSoftwareConsortium/ITK) | dependency-candidate | Apache-2.0 | N-dimensional scientific image processing, segmentation, registration, metadata-aware image pipelines. |
| [SimpleITK](https://github.com/SimpleITK/SimpleITK) | dependency-candidate | Apache-2.0 | Simpler ITK API patterns and tests; API-design reference more than low-level donor. |
| [DCMTK](https://github.com/DCMTK/dcmtk) | dependency-candidate | BSD-style DCMTK copyright | DICOM parsing, transfer syntaxes, image modules, DICOM SEG/RT/tract objects, networking concepts. |
| [GDCM](https://github.com/malaterre/GDCM) | dependency-candidate | BSD-like copyright | Alternate DICOM parser/converter patterns, interoperability edge cases, ITK-style integration. |
| [dcm2niix](https://github.com/rordenlab/dcm2niix) | safe-donor | Mostly BSD; bundled parts public domain/MIT | DICOM-to-NIfTI conversion, vendor quirks, BIDS sidecars, compression/transfer-syntax handling. |
| [nifti_clib](https://github.com/NIFTI-Imaging/nifti_clib) | safe-donor | Public domain | NIfTI-1/NIfTI-2/CIFTI-ish IO, headers, orientation matrices, volume/timecourse data access. |
| [MetaIO](https://github.com/Kitware/MetaIO) | safe-donor | BSD-like Kitware license | MetaImage `.mha/.mhd` IO and tagged medical image metadata patterns. |
| [Teem](https://github.com/SCIInstitute/teem) | dependency-candidate | LGPL-2.1 with Simple Library Usage License exception | NRRD and scientific raster/volume conventions; license review required before direct adoption. |

## Medical, Tomography, And Scientific Visualization Applications

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [3D Slicer](https://github.com/Slicer/Slicer) | dependency-candidate | BSD-style Slicer license | Medical visualization workflows, segmentation UX, plugin/module structure, DICOM-volume conventions. |
| [MITK](https://github.com/MITK/MITK) | dependency-candidate | BSD-3-Clause | Interactive medical-image app architecture, data nodes, rendering/processing integration. |
| [Tomviz](https://github.com/OpenChemistry/tomviz) | dependency-candidate | BSD-3-Clause | Tomography pipeline UX, reconstruction/segmentation workflow, volume visualization controls. |
| [ParaView](https://github.com/Kitware/ParaView) | dependency-candidate | BSD-style Kitware license | Large scientific visualization pipelines, distributed/remote visualization concepts, filter-browser UX. |

## Volume Rendering, Transfer Functions, And Sampling Kernels

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [VTK](profiles/vtk.md) | dependency-candidate | BSD-style | Image data model, volume rendering, transfer-function plumbing, scientific visualization filters. |
| [Inviwo](https://github.com/inviwo/inviwo) | dependency-candidate | BSD | Node/pipeline-based volume visualization, transfer-function UI, DICOM/NIfTI/HDF5/RAW loaders. |
| [OSPRay](profiles/ospray.md) | dependency-candidate | Apache-2.0 | Scientific volume rendering, transfer-function object model, isosurfaces, slices, distributed rendering. |
| [Open VKL](https://github.com/RenderKit/openvkl) | dependency-candidate | Apache-2.0 | Volume traversal and sampling kernels, value ranges, structured/VDB/particle/unstructured volumes. |
| [OSPRay Studio](https://github.com/ospray/ospray_studio) | dependency-candidate | Apache-2.0; archived | Interactive scene graph and volume-rendering app patterns; archived reference-only. |
| [Voreen](https://github.com/voreen-project/voreen) | study-only | GPL-family signal; verify before use | Transfer-function editors and visual volume-workspace UX only. |
| [Viskores](https://github.com/Viskores/viskores) | dependency-candidate | BSD-3-Clause style | Parallel scientific visualization algorithms, filters, worklets, and accelerator portability. |

## Chunked Scientific Arrays, Cloud Volumes, And Large-Scale IO

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [HDF5](https://github.com/HDFGroup/hdf5) | dependency-candidate | BSD-style HDF Group license | Dense scientific arrays, hierarchical metadata, chunked/compressed datasets, HPC/parallel IO. |
| [netCDF-C](https://github.com/Unidata/netcdf-c) | dependency-candidate | BSD-style Unidata copyright | Self-describing scientific datasets, geoscience/climate conventions, portable array access. |
| [ADIOS2](https://github.com/ornladios/ADIOS2) | dependency-candidate | Apache-2.0 | Streaming/HPC scientific IO, staging, in situ workflows, large simulation-volume outputs. |
| [TensorStore](https://github.com/google/tensorstore) | dependency-candidate | Apache-2.0 | Chunked multidimensional arrays, Zarr/N5, cloud/local stores, async cache/transactions. |
| [Zarr Specs](https://github.com/zarr-developers/zarr-specs) | dependency-candidate | Spec/reference; verify exact license | N-dimensional typed-array storage model and metadata. |
| [OME NGFF](https://github.com/ome/ngff) | dependency-candidate | Spec/reference; verify exact license | Cloud bioimaging layout, multiscale pyramids, labels, coordinate transforms, OME-Zarr conventions. |
| [OME Files C++](https://github.com/ome/ome-files-cpp) | dependency-candidate | Verify exact license; archived | OME-TIFF metadata and microscopy IO reference; archived/reference-only. |

## Selection Notes

- Do not ship patient data, clinical scans, or ambiguous DICOM fixtures in this repo.
- Preserve voxel spacing, origin, direction/orientation matrices, units, modality, rescale
  slope/intercept, window/level presets, time/channel dimensions, and missing-data policy.
- Separate scalar volumes, label maps, segmentations, surfaces, annotations, tractography, and RT
  structures. Do not flatten all medical data into a raw 3D texture.
- For transfer functions, distinguish color map, opacity map, value range, CT window/level, label
  LUTs, segmentation overlays, log/linear scaling, and histogram-driven authoring.
- For Vulkan/CUDA targets, use VTK/Inviwo/OSPRay/Open VKL as architecture references, then implement
  active backend code through the selected lane.
- HDF5/netCDF/ADIOS2/TensorStore bring meaningful build and deployment weight; choose dependency
  integration only when narrow import/export is not enough.

## Deep Profiles

- [Medical And Scientific Volume IO](profiles/medical-scientific-volume-io.md): read before selecting medical IO, transfer-function, tomography, or large scientific array donors.
- [VTK](profiles/vtk.md): read before adopting scientific visualization, volume-rendering toolkit architecture, or VTK data/filter pipelines.
- [OSPRay](profiles/ospray.md): read before adopting scalable CPU visualization renderer architecture, volumes, or RenderKit-style rendering APIs.
