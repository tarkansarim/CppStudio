# Babylon.js Donor Profile

Source: https://github.com/BabylonJS/Babylon.js  
Tier: `safe-donor`  
Backend signal: mixed-backend, native-webgpu, native-opengl
License signal: Apache-2.0; inspect `license.md`, packages, loaders, tools, exporters, playground
assets, sample scenes, and third-party package notices at the exact revision used.

## Use First For

- Browser game/rendering engine architecture, WebGL/WebGPU/WebXR examples, scene tooling, PBR/material
  workflows, loaders, and editor/playground UX references.
- WebXR interaction, input, physics/plugin boundaries, and richer web-engine behavior than a lightweight
  three.js sample.
- Understanding TypeScript engine package organization before designing browser-facing 3D tooling.

## First Upstream Areas To Inspect

- `packages/`, engine/core packages, loaders, materials, WebXR, WebGPU, and tools packages.
- Playground examples and docs that match the target interaction.
- Exporter/tool packages only after checking their DCC/plugin dependency surfaces.
- Sample assets and packages before copying or bundling.

## Integration Notes

- Treat Babylon.js as a web-engine donor, not a native C++ renderer dependency.
- Keep engine package choice, loader selection, WebXR runtime, browser compatibility, and hosted assets
  separated.
- For native Vulkan/CUDA projects, use Babylon.js for UX, scene behavior, and WebXR ideas only.
- Prefer direct package use for web apps; avoid copying engine internals.

## Validation Ideas

- Smoke a tiny WebGL/WebGPU scene, glTF load, material/texture path, resize, and pointer/input path.
- Test WebXR runtime availability separately from ordinary browser rendering.
- Verify browser support and asset hosting paths before treating failures as renderer bugs.
- Keep playground-derived fixtures small and license-checked.

## Caveats

- Browser, package, exporter, and asset licenses are separate surfaces.
- WebXR and WebGPU availability depend on browser/device/runtime support.
- The engine's breadth can obscure which subsystem is actually relevant.
