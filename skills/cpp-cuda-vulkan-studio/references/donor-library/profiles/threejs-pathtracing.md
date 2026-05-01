# THREE.js PathTracing Renderer Donor Profile

Source: https://github.com/erichlof/THREE.js-PathTracing-Renderer  
Tier: `safe-donor`  
Backend signal: native-opengl
License signal: CC0-1.0; inspect `LICENSE`, demos, textures, models, HDRIs, and third-party example
assets before reuse.

## Use First For

- Browser/WebGL path tracing demos, progressive accumulation, shader-side path tracing, simple BVH/glTF
  path-tracing behavior, and interactive path-tracing UX ideas.
- Lightweight web reference scenes for global illumination, caustics, volumetrics, procedural primitives,
  and material controls.
- Comparing browser path-tracing concepts against native Vulkan/CUDA implementations.

## First Upstream Areas To Inspect

- Demo HTML/JS files matching the target material, camera, or rendering behavior.
- Shader code, accumulation logic, controls, and loader/BVH helpers.
- Textures, models, HDRIs, and screenshots before using any asset as a fixture.

## Integration Notes

- Use as a concept/reference donor; translate WebGL shader and browser state into the target lane.
- Keep accumulation, sampling, scene controls, BVH loading, and asset hosting separate.
- For native Vulkan projects, use it for expected behavior and small fixture design, not runtime code.
- Prefer pbrt or Mitsuba when physically based correctness needs a stronger offline reference.

## Validation Ideas

- Recreate a tiny Cornell-box, sphere, material, or volume fixture in the target renderer.
- Compare progressive accumulation behavior, camera controls, and image metrics on small scenes.
- Test reset-on-camera-change and reset-on-material-change behavior.
- Check asset provenance before using demo resources.

## Caveats

- WebGL shader code does not define Vulkan synchronization, descriptor, or precision policy.
- Browser performance and GPU constraints differ from native renderer constraints.
- CC0 code does not automatically cover external assets.
