# Unity HDRP Hair Study-Only Donor Profile

Source: https://github.com/Unity-Technologies/Graphics  
Tier: `study-only`  
Backend signal: mixed-backend
License signal: Unity Graphics package license and package-specific terms; inspect local package, samples,
docs, and any additional hair package requirements before reuse.

## Use First For

- HDRP hair material and Shader Graph UX references.
- Kajiya-Kay, Marschner, cinematic hair options, and multiple-scattering LUT concepts.
- Strand/card material parameter organization and editor-facing controls.
- Analytic line-rendering and transparent strand/card visual references.

## First Upstream Areas To Inspect

- `Runtime/Material/Hair/` for HDRP hair material and shader behavior.
- `Runtime/Material/Hair/MultipleScattering/` for multiple-scattering LUT generation concepts.
- `Runtime/Material/Hair/Reference/` for reference shader behavior.
- `Editor/Material/Hair/ShaderGraph/` for authoring UX and exposed parameters.
- HDRP documentation for hair/fur and high-quality line rendering.

## Integration Notes

- Use Unity mostly for material/shading and UX comparison, not a full groom runtime architecture.
- Keep Shader Graph and package concepts as study references for native C++ UI and shader parameter design.
- Prefer Unreal or RTXCR for full groom runtime, voxelization, and ray-traced hair architecture.
- Recreate test fixtures and material knobs in project-owned code instead of copying Unity package code.

## Validation Ideas

- Compare small material cases across approximate, physical, and cinematic-style controls when the target
  supports them.
- Add LUT generation tests for expected ranges and edge cases if a target implements multiple scattering.
- Validate cards, strands, and line-like geometry as separate rendering assumptions.
- Keep shader-parameter UI tests separate from runtime groom tests.

## Caveats

- The local Unity package is not a complete groom runtime equivalent to Unreal HairStrands.
- Some cinematic hair paths depend on additional Unity packages or package gates.
