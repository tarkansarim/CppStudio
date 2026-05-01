# NVIDIA HairWorks Study-Only Donor Profile

Source: https://docs.nvidia.com/gameworks/content/artisttools/hairworks/  
Tier: `study-only`  
Backend signal: native-directx
License signal: NVIDIA GameWorks/HairWorks terms; inspect SDK license, sample code terms, DCC plugins,
assets, and documentation rights before any reuse.

## Use First For

- Hair authoring concepts, artist controls, asset parameters, frame-rate-independent hair behavior, and
  legacy GameWorks hair rendering/simulation expectations.
- Comparing HairWorks-style controls against TressFX, USD curves, Alembic curves, or Blender grooming UX.
- Study-only behavior references for strand rendering, LOD, collision, and material controls.

## First Upstream Areas To Inspect

- Artist-tool documentation, asset parameter docs, sample behavior notes, and DCC plugin workflows.
- SDK license and sample-code terms before considering any reuse.
- DirectX sample behavior only as a concept source unless the project explicitly accepts that lane.
- DCC asset/plugin docs for authoring workflow, not runtime code.

## Integration Notes

- Do not copy HairWorks code into reusable CppStudio outputs without explicit license approval.
- Use TressFX first for permissive realtime hair/fur implementation patterns.
- Convert HairWorks observations into independent UX controls, data-model requirements, or test cases.
- Keep DirectX-specific implementation details separate from Vulkan or CUDA target lanes.

## Validation Ideas

- Recreate tiny project-owned strand fixtures and controls instead of importing SDK assets.
- Compare behavior categories such as stiffness, LOD, width, collision, and material response.
- Document which concept was studied and which permissive donor or project code implements it.
- Confirm no GameWorks code or assets were copied.

## Caveats

- HairWorks is intentionally study-only in this donor library.
- GameWorks-era APIs and DirectX samples do not define Vulkan synchronization or project build policy.
- SDK samples, DCC plugins, and assets can have separate restrictive terms.
