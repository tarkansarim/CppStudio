# Neural Graphics Study-Only Donor Profile

Sources: https://github.com/graphdeco-inria/gaussian-splatting and https://github.com/NVlabs/instant-ngp and https://github.com/NVIDIAGameWorks/kaolin-wisp  
Tier: `study-only`  
Backend signal: native-cuda
License signal: GraphDeco Gaussian Splatting has non-commercial/research-style restrictions; instant-ngp
and Kaolin Wisp use NVIDIA source licenses with non-commercial or otherwise restricted terms. Inspect
each `LICENSE`, submodule, dataset, model, viewer, and asset notice before any reuse.

## Use First For

- Understanding original 3D Gaussian Splatting behavior, expected training/rendering pipeline shape,
  scene assets, camera conventions, and paper-reference outputs.
- Studying instant-ngp-style hash grids, NeRF UI/workflow expectations, and performance envelopes.
- Comparing neural-field workflows and UX against permissive donors such as gsplat, Nerfstudio,
  tiny-cuda-nn, PyTorch3D, Kaolin core, or Open3D.

## First Upstream Areas To Inspect

- Papers, READMEs, training scripts, viewer examples, command-line workflows, and documented datasets.
- License files and any submodule or external dependency notices before using even small code fragments.
- Expected input/output formats, camera transforms, metrics, and benchmark scenes.

## Integration Notes

- Do not copy code into reusable skills, templates, or project code without explicit user approval and
  exact license review.
- Convert observations into independent behavior specs, fixtures, metrics, or interface requirements.
- Prefer gsplat and tiny-cuda-nn for permissive implementation patterns where they cover the needed
  behavior.
- Keep CUDA-specific algorithms as donor concepts for Vulkan-first ports unless CUDA is explicitly chosen.

## Validation Ideas

- Use public paper metrics, screenshots, scene conventions, and documented commands as behavior checks.
- Recreate tiny independent fixtures instead of importing restricted assets or code.
- Document which restricted source informed a concept and confirm no code was copied.
- Compare implementation output against permissive donor references first.

## Caveats

- These donors are intentionally not safe implementation sources for reusable CppStudio outputs.
- Datasets, captures, pretrained models, screenshots, and viewers are separate license surfaces.
- Study-only status applies even if a concept is technically useful or widely cited.
