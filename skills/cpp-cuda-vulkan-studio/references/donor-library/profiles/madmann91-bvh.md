# madmann91/bvh Donor Profile

Source: https://github.com/madmann91/bvh  
Tier: `safe-donor`  
Backend signal: native-cpu
License signal: MIT; inspect `LICENSE.txt`, examples, tests, benchmark images, and bundled scene
assets at the exact revision used.

## Use First For

- Compact standalone C++20 BVH construction and traversal patterns.
- Lightweight CPU ray queries, geometry acceleration tests, and simple path-tracing prototypes.
- Understanding SAH builders, traversal order, ray-triangle tests, serialization, and minimal dependency
  integration.

## First Upstream Areas To Inspect

- `src/bvh/v2/` for public interfaces, builders, traversal, geometry helpers, and serialization.
- `test/` for deterministic builder and traversal behavior.
- `cmake/` and top-level `CMakeLists.txt` for integration shape.
- Example images/assets only after checking their own licenses.

## Integration Notes

- Prefer this donor when a project needs an auditable BVH reference without Embree-scale dependency cost.
- Keep CPU BVH data separate from GPU acceleration structures, renderer meshes, and physics broadphase
  data unless the project intentionally shares them.
- For CUDA/Vulkan targets, use this as a correctness oracle or CPU fallback before porting traversal.
- Watch C++20 requirements against the target repo's standard.

## Validation Ideas

- Test tiny triangle, box, sphere, empty, degenerate, and nested-instance fixtures.
- Compare traversal hits against brute-force ray tests.
- Verify serialization/deserialization preserves bounds and primitive order where required.
- Add precision tests for large/small coordinate ranges.

## Caveats

- It is a focused BVH library, not a renderer, physics engine, or asset importer.
- GPU ports need fresh memory-layout and synchronization design.
- Benchmark images and demo assets are separate license surfaces.
