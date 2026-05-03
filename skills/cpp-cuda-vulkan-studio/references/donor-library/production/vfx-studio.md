# VFX Studio Routing Overlay

Use this when the user describes a VFX, animation, film, virtual production, or shot/asset pipeline
department. Open the smallest matching department below, then continue into the linked technical donor
categories.

| Department | Includes | Open First |
| --- | --- | --- |
| Modeling | Mesh creation, topology, sculpt-to-runtime conversion, hard surface, organic forms, retopo, LODs, mesh cleanup, NURBS/CAD-to-render display handoff. | [assets-meshes-materials.md](../assets-meshes-materials.md), [surfaces-subdivision.md](../surfaces-subdivision.md), [cad-precision-geometry.md](../cad-precision-geometry.md) |
| Texturing | UVs, UDIM-style layout decisions, texture baking, PBR maps, image/texture IO, compression, procedural texture inputs, material input maps. | [texture-material-color.md](../texture-material-color.md), [assets-meshes-materials.md](../assets-meshes-materials.md), [gltf-runtime-assets.md](../gltf-runtime-assets.md) |
| Rigging | Skeletons, controls, skinning, deformation systems, blend shapes, facial rigs, animation-ready asset preparation. | [animation-rigging.md](../animation-rigging.md), [muscle-flesh-biomechanics.md](../muscle-flesh-biomechanics.md), [geometry-simulation.md](../geometry-simulation.md) |
| Creature FX | Hair, fur, feathers, cloth-on-creatures, skin sliding, muscles, flesh, secondary motion, creature simulation, groom workflows. | [hair-grooming-fur.md](../hair-grooming-fur.md), [muscle-flesh-biomechanics.md](../muscle-flesh-biomechanics.md), [simulation-gpu.md](../simulation-gpu.md) |
| Look Development | Shaders, material response, skin/hair/volume appearance, material tests, renderer comparisons, asset appearance under multiple lighting conditions. | [texture-material-color.md](../texture-material-color.md), [graphics-rendering.md](../graphics-rendering.md), [hair-grooming-fur.md](../hair-grooming-fur.md), [volumes-voxels.md](../volumes-voxels.md) |
| Lighting | Scene lighting, HDRI/IBL, physical lights, shadows, reflections, render passes, AOV-like debug views, shot integration, render optimization. | [graphics-rendering.md](../graphics-rendering.md), [vulkan-foundation-tooling.md](../vulkan-foundation-tooling.md), [volumes-voxels.md](../volumes-voxels.md) |
| FX | Fluids, smoke, fire, explosions, destruction, particles, debris, crowds, procedural effects, GPU-driven effects. | [simulation-gpu.md](../simulation-gpu.md), [vfx-particles.md](../vfx-particles.md), [volumes-voxels.md](../volumes-voxels.md), [animation-rigging.md](../animation-rigging.md) |

## Notes

- Creature FX is more specific than broad simulation when the prompt mentions creatures, muscles,
  flesh, skin, hair, fur, feathers, groom, or secondary creature motion.
- Look development owns appearance and material response. Lighting owns scene illumination,
  visibility, render passes, and shot/frame output.
- FX owns solver/effect work. Use [vfx-particles.md](../vfx-particles.md) for realtime visual effects
  and [simulation-gpu.md](../simulation-gpu.md) for solver physics.
- Use [dcc-scene-pipeline.md](../dcc-scene-pipeline.md) whenever USD, Alembic, MaterialX, OpenTimelineIO,
  DCC handoff, virtual production, or review/editorial context is part of the request.
- Use [native-gui-hud.md](../native-gui-hud.md) whenever the VFX request includes native tool panels,
  inspectors, brush controls, viewport overlays, debug HUDs, or artist-facing desktop UI.
