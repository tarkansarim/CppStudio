# nvpro Vulkan Ray Tracing Tutorial KHR Donor Profile

Source: https://github.com/nvpro-samples/vk_raytracing_tutorial_KHR  
Tier: `safe-donor`  
Backend signal: native-vulkan
License signal: Apache-2.0; inspect `LICENSE`, nvpro_core2 dependencies, media/resources, and third-party
notices at the exact revision used.

## Use First For

- Direct Vulkan ray-tracing pipeline setup using `VK_KHR_ray_tracing_pipeline`.
- BLAS/TLAS construction, shader binding table layout, raygen/miss/closest-hit stages, and shadow rays.
- Progressive, compilable ray-tracing tutorial phases that can become project-owned smoke tests.
- Swept-sphere and procedural geometry references for strand-like or implicit geometry experiments.

## First Upstream Areas To Inspect

- `docs/acceleration_structures.md` for BLAS/TLAS concepts and helper boundaries.
- `docs/shader_binding_table.md` for SBT alignment, records, and group organization.
- `raytrace_tutorial/02_basic/` for the smallest direct RT pipeline.
- `raytrace_tutorial/05_shadow_miss/` for shadow rays and miss group setup.
- `raytrace_tutorial/07_multi_closest_hit/` for multiple hit groups and shader-record data.
- `raytrace_tutorial/18_swept_spheres/` for swept-sphere references.

## Integration Notes

- Use this before larger renderer frameworks when the target project needs to learn or implement Vulkan RT
  fundamentals.
- Keep helper-framework code separate from direct Vulkan concepts so the target can choose its dependency
  policy deliberately.
- Translate tutorial steps into project-owned tests instead of copying a whole sample shell.
- Pair with the Vulkan synchronization skill before changing image layouts, acceleration-structure barriers,
  queue usage, or frames-in-flight behavior.

## Validation Ideas

- Add a tiny triangle scene, shadow-ray scene, and procedural/swept-sphere scene as separate CTest labels.
- Run Vulkan validation with acceleration-structure and synchronization diagnostics enabled.
- Verify SBT record sizes, alignment, and shader-group indexing.
- Capture raw RT output before adding denoising, reconstruction, or material complexity.

## Caveats

- The tutorial may depend on nvpro_core2; decide whether to use it or port the concepts to local helpers.
- Tutorial code is educational; production code still needs target-specific lifetime, error, and test policy.
