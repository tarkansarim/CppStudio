# RTXCR Material Library Donor Profile

Source: https://github.com/NVIDIA-RTX/RTXCR-Material-Library  
Tier: `dependency-candidate`  
Backend signal: api-agnostic
License signal: NVIDIA RTX SDKs license; inspect `License.txt` and shader-file notices at the exact
revision used.

## Use First For

- RTXCR hair material contracts and shader-side parameter naming.
- Chiang and Far-Field hair BSDF implementations and expected inputs.
- Ray-traced subsurface-scattering material patterns when character rendering is in scope.
- Mapping artist-facing hair controls to renderer-facing material parameters.

## First Upstream Areas To Inspect

- `shaders/include/rtxcr/HairMaterial.hlsli` for material parameter layout and interaction boundary.
- `shaders/include/rtxcr/HairFarFieldBCSDF.hlsli` for realtime-friendly far-field hair behavior.
- `shaders/include/rtxcr/HairChiangBSDF.hlsli` for reference-style hair BSDF behavior.
- README guidance that points back to the RTXCR hair and SSS guides.

## Integration Notes

- Use this library to define material semantics before inventing target-project hair controls.
- Translate HLSL/Slang assumptions through the active shader lane; do not force a DirectX or CUDA lane
  just because the donor shader files are HLSL-flavored.
- Keep material adapter code thin and documented: source UI controls in one module, renderer material
  payloads in another.
- Treat this as a dependency or reference contract, not direct reusable template code, until the SDK
  license path is explicitly accepted.

## Validation Ideas

- Validate zero absorption, high roughness, low roughness, white hair, dark hair, and extreme color
  cases against small project-owned fixtures.
- Add image comparisons for Chiang versus Far-Field mode if both are exposed.
- Capture shader compile errors and missing material fields as explicit tests rather than fallback
  defaults.
- Keep raw/direct lighting captures around as controls before denoising or reconstruction is judged.

## Caveats

- The license is SDK-style and must be reviewed before source reuse or redistribution.
- Material equations are only one part of believable hair; geometry, shadows, visibility, and guide
  buffers still need their own donors and tests.
