# Geometry, Assets, And Simulation Donors

Use these donors for asset loading, mesh optimization, point-cloud processing, BVH construction,
CPU ray tracing, and physics/collision infrastructure.

## Asset And Mesh Pipeline

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [assimp](https://github.com/assimp/assimp) | dependency-candidate | BSD-3-Clause based | Import/export of many 3D formats, asset conversion tools, mesh post-processing ideas. |
| [meshoptimizer](https://github.com/zeux/meshoptimizer) | safe-donor | MIT | Vertex/index optimization, simplification, overdraw optimization, mesh compression, glTF pipeline work. |
| [Open3D](https://github.com/isl-org/Open3D) | dependency-candidate | MIT | Point clouds, registration, reconstruction, mesh processing, 3D visualization, C++/Python API patterns. |
| [Embree](https://github.com/RenderKit/embree) | dependency-candidate | Apache-2.0 | High-performance CPU ray tracing kernels and BVH traversal. |
| [OSPRay](https://github.com/RenderKit/ospray) | dependency-candidate | Apache-2.0 | Scalable CPU rendering engine patterns, visualization renderer architecture. |
| [madmann91/bvh](https://github.com/madmann91/bvh) | safe-donor | MIT | Standalone C++20 BVH builders/traversal, simple ray tracing acceleration structures. |

## Physics And Simulation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Jolt Physics](https://github.com/jrouwe/JoltPhysics) | dependency-candidate | MIT | Modern rigid-body physics, collision detection, job/thread architecture, samples. |
| [Bullet Physics](https://github.com/bulletphysics/bullet3) | dependency-candidate | zlib | Collision, rigid body, robotics/ML simulation, broad ecosystem references. |
| [Godot Engine](https://github.com/godotengine/godot) | dependency-candidate | MIT | Engine/editor architecture, scene trees, rendering/physics integration. Prefer dependency/API ideas over code copying due scale. |
| [Open 3D Engine](https://github.com/o3de/o3de) | dependency-candidate | Apache-2.0/MIT dual-license default; third-party components vary | Large-scale engine architecture, asset processor, component systems, editor/runtime split. |

## Selection Notes

- For runtime asset import, assimp is a dependency candidate; for build-time mesh conditioning,
  meshoptimizer is usually a smaller donor.
- For point-cloud and reconstruction workflows, Open3D is the strongest general-purpose donor.
- For custom lightweight ray queries, use `madmann91/bvh` before pulling in a full rendering toolkit.
- For physics in C++ apps, prefer Jolt for modern C++ and Bullet for ecosystem breadth.
