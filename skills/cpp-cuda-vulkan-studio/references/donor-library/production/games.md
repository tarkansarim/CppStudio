# Games Routing Overlay

Use this when the user describes a game, realtime engine, gameplay-facing tool, game asset pipeline,
or platform/performance-budgeted interactive experience. Open the smallest matching discipline below,
then continue into the linked technical donor categories.

| Discipline | Includes | Open First |
| --- | --- | --- |
| Character Art | Characters, creatures, gear, weapons, hair cards/grooms, runtime LODs, mesh/material budgets. | [assets-meshes-materials.md](../assets-meshes-materials.md), [hair-grooming-fur.md](../hair-grooming-fur.md), [animation-rigging.md](../animation-rigging.md), [texture-material-color.md](../texture-material-color.md) |
| Environment/World Art | Modular kits, props, terrain, biomes, set dressing, world streaming, readable spaces, optimization. | [assets-meshes-materials.md](../assets-meshes-materials.md), [terrain-geospatial.md](../terrain-geospatial.md), [gltf-runtime-assets.md](../gltf-runtime-assets.md), [graphics-rendering.md](../graphics-rendering.md) |
| Texturing/Materials | PBR maps, tileables, trimsheets, decals, texture compression, material graphs, shader input data. | [texture-material-color.md](../texture-material-color.md), [assets-meshes-materials.md](../assets-meshes-materials.md), [gltf-runtime-assets.md](../gltf-runtime-assets.md) |
| Rigging/Technical Animation | Skeletons, skinning, retargeting, control rigs, deformation tooling, runtime animation constraints. | [animation-rigging.md](../animation-rigging.md), [muscle-flesh-biomechanics.md](../muscle-flesh-biomechanics.md) |
| Gameplay Animation | Player/enemy movement, animation graphs, blending, IK, root motion, compression, crowds, navigation agents. | [animation-rigging.md](../animation-rigging.md), [geometry-simulation.md](../geometry-simulation.md) |
| Technical Art | Artist tooling, shader/material tooling, procedural pipelines, export validation, build/cook workflows, performance fixes, editor panels, and debug HUDs. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [native-gui-hud.md](../native-gui-hud.md), [assets-meshes-materials.md](../assets-meshes-materials.md), [graphics-rendering.md](../graphics-rendering.md) |
| Realtime VFX | Particles, impacts, magic, explosions, decals, weather, GPU sorting, indirect effects, frame-budgeted visual effects. | [vfx-particles.md](../vfx-particles.md), [simulation-gpu.md](../simulation-gpu.md), [volumes-voxels.md](../volumes-voxels.md) |
| Lighting/Post | Realtime lighting, baked/probe concepts, GI references, exposure, tone mapping, fog, bloom, post effects. | [graphics-rendering.md](../graphics-rendering.md), [vulkan-foundation-tooling.md](../vulkan-foundation-tooling.md), [volumes-voxels.md](../volumes-voxels.md) |
| Rendering/Graphics Programming | Vulkan renderer, frame graph, shaders, materials, GPU culling, ray tracing, memory lifetime, GPU performance. | [graphics-rendering.md](../graphics-rendering.md), [vulkan-foundation-tooling.md](../vulkan-foundation-tooling.md), [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) |
| Tools/Pipeline Engineering | Importers, asset cooking, DCC bridges, validation, editor/runtime handoff, generated asset formats, and native tool shells. | [native-engineering-infrastructure.md](../native-engineering-infrastructure.md), [native-gui-hud.md](../native-gui-hud.md), [assets-meshes-materials.md](../assets-meshes-materials.md), [gltf-runtime-assets.md](../gltf-runtime-assets.md), [dcc-scene-pipeline.md](../dcc-scene-pipeline.md) |
| Physics/Simulation | Rigid bodies, vehicles, cloth, fluids, destruction, gameplay physics, solver integration. | [simulation-gpu.md](../simulation-gpu.md), [geometry-simulation.md](../geometry-simulation.md), [vfx-particles.md](../vfx-particles.md) |
| XR/Spatial Games | OpenXR, controllers, hand tracking, passthrough, spatial anchors, stereo frame timing, headset performance. | [xr-spatial.md](../xr-spatial.md), [graphics-rendering.md](../graphics-rendering.md), [vulkan-foundation-tooling.md](../vulkan-foundation-tooling.md) |

## Notes

- Games routing should consider runtime budgets, platform constraints, asset cooking, and repeated
  iteration before choosing dependency-heavy donors.
- Technical Art and Tools/Pipeline Engineering often start with
  [native-engineering-infrastructure.md](../native-engineering-infrastructure.md) and
  [native-gui-hud.md](../native-gui-hud.md) before art-domain donors when a native tool UI, editor
  shell, debug HUD, inspector, or viewport overlay is involved.
- Realtime VFX owns visual effects; solver-heavy fluids, cloth, deformables, and destruction still need
  [simulation-gpu.md](../simulation-gpu.md).
