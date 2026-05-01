# three.js Donor Profile

Source: https://github.com/mrdoob/three.js  
Tier: `safe-donor`  
Backend signal: mixed-backend, native-webgpu, native-opengl
License signal: MIT; inspect `LICENSE`, `examples/`, loaders, addons, assets, textures, models, and
third-party package notices at the exact revision used.

## Use First For

- Browser 3D scene structure, controls, loaders, materials, cameras, animation loops, interactive demos,
  WebGL/WebGPU examples, and WebXR/WebAR UX references.
- Lightweight viewer behavior, glTF/browser asset handling, orbit/first-person controls, and debug UI
  patterns.
- Rapid visual prototype ideas before translating runtime behavior into C++/Vulkan or another native lane.

## First Upstream Areas To Inspect

- `src/`, `examples/jsm/`, loaders, controls, materials, renderer examples, and WebGPU examples.
- `manual/`, docs, and examples that match the target interaction pattern.
- Example assets, HDRIs, textures, and model files before reuse.
- Package metadata and addon dependencies for browser deployment.

## Integration Notes

- Use three.js as a web behavior and scene-UX donor; do not copy browser-specific architecture into
  native C++ runtime code without translation.
- Keep loaders, controls, scene graph, renderer backend, and asset hosting as separate concerns.
- For Vulkan/CUDA targets, port behavior and test fixtures through the active lane rather than adding a
  browser runtime.
- Prefer three.js for compact browser demos; use Babylon.js when a fuller web engine stack is useful.

## Validation Ideas

- Test a tiny scene with camera controls, glTF loading, texture loading, resize behavior, and WebXR only
  when in scope.
- Verify browser support for WebGL/WebGPU features before promising a path.
- Check asset CORS, relative paths, and per-asset licenses separately.
- Compare native viewer behavior against a small web reference scene when porting.

## Caveats

- Examples and assets have separate provenance from core library code.
- WebGPU support and browser behavior can change independently of native Vulkan targets.
- Browser demo patterns do not define native memory, synchronization, or build policy.
