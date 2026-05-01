# Medical And Scientific Volume IO Profile

Sources: https://github.com/InsightSoftwareConsortium/ITK https://github.com/SimpleITK/SimpleITK https://github.com/DCMTK/dcmtk https://github.com/malaterre/GDCM https://github.com/rordenlab/dcm2niix https://github.com/NIFTI-Imaging/nifti_clib https://github.com/Kitware/MetaIO https://github.com/SCIInstitute/teem https://github.com/Slicer/Slicer https://github.com/MITK/MITK https://github.com/OpenChemistry/tomviz https://github.com/Kitware/ParaView https://github.com/inviwo/inviwo https://github.com/RenderKit/openvkl https://github.com/ospray/ospray_studio https://github.com/voreen-project/voreen https://github.com/Viskores/viskores https://github.com/HDFGroup/hdf5 https://github.com/Unidata/netcdf-c https://github.com/ornladios/ADIOS2 https://github.com/google/tensorstore https://github.com/zarr-developers/zarr-specs https://github.com/ome/ngff https://github.com/ome/ome-files-cpp
Tier: `safe-donor`, `dependency-candidate`, `study-only`
Backend signal: api-agnostic, native-cpu, native-opengl, mixed-backend
License signal: mixed Apache-2.0, BSD/MIT-style, public-domain, LGPL-with-exception, GPL-family, and
archived/spec-reference signals; inspect exact code, data, sample images, and third-party notices.

## Use First For

- DICOM/NIfTI/OME-style IO, medical image metadata, segmentation/registration, transfer functions,
  tomography workflows, chunked scientific arrays, and scientific volume visualization.

## Integration Notes

- Keep patient data, clinical fixtures, medical model data, and scientific datasets outside reusable
  donor packages unless provenance is explicit.
- Preserve physical metadata: spacing, origin, direction/orientation, units, modality, rescale
  slope/intercept, window/level, time/channel dimensions, labels, and missing-data policy.
- Use VTK/Inviwo/OSPRay/Open VKL as visualization architecture references; implement Vulkan/CUDA
  backend code through the selected lane.
- Treat Voreen as study-only, OSPRay Studio and OME Files C++ as archived/reference-only, and Bio-Formats
  as Java ecosystem context unless the target explicitly accepts that runtime.

## Validation Ideas

- Use de-identified synthetic fixtures for one scalar volume, one label map, one DICOM-like metadata case,
  one NIfTI orientation case, one transfer function, and one chunked-array round trip.
