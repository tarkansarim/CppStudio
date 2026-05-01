# Animation And Rigging Donors

Use these donors for skeletal animation, skinning, animation clips, runtime sampling, animation
compression, retargeting, blend shapes, and DCC-to-runtime animation data.

## Runtime Animation

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [ozz-animation](https://github.com/guillaumeblanc/ozz-animation) | safe-donor | MIT | Data-oriented C++ skeletal animation runtime, sampling, blending, offline conversion, renderer-agnostic design. |
| [Animation Compression Library](https://github.com/nfrechette/acl) | safe-donor | MIT | Header-only animation compression, decompression benchmarks, clip accuracy and memory tradeoffs. |
| [Assimp animation import](https://github.com/assimp/assimp) | dependency-candidate | BSD-3-Clause based | Importing skeletal animation data from many DCC formats. |

## Interchange And Engine References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenUSD UsdSkel](https://openusd.org/dev/api/usd_skel_page_front.html) | dependency-candidate | OpenUSD license; inspect exact repo license | Skeletal animation interchange, skinned meshes, joint animations, blend shapes, DCC pipeline schemas. |
| [Godot Engine animation](https://github.com/godotengine/godot) | dependency-candidate | MIT | Engine/editor animation graph and runtime integration ideas. |
| [Open 3D Engine animation systems](https://github.com/o3de/o3de) | dependency-candidate | Apache-2.0/MIT default; third-party components vary | Large engine animation component architecture and asset pipeline references. |

## Retargeting, Skinning, And Crowds

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Dem Bones](https://github.com/electronicarts/dem-bones) | safe-donor | BSD-3-Clause | Skinning decomposition, blend-shape/skeleton fitting, and tiny mesh animation fixtures. |
| [Recast Navigation / DetourCrowd](https://github.com/recastnavigation/recastnavigation) | safe-donor | zlib | Navigation meshes, crowd agents, steering, avoidance, and path-following behavior. |
| [RVO2](https://github.com/snape/RVO2) | safe-donor | Apache-2.0 | Reciprocal velocity obstacle crowd avoidance and local-agent collision behavior. |
| [Menge](https://github.com/MengeCrowdSim/Menge) | dependency-candidate | Apache-2.0 signal; inspect repo notices | Crowd simulation architecture, behavior modules, and validation scenarios. |
| [OpenSteer](https://github.com/meshula/OpenSteer) | dependency-candidate | MIT-style signal; verify exact repo license | Classic steering behavior concepts and examples. |
| [Codeplay SYCL Crowd Simulation](https://github.com/codeplaysoftware/sycl-crowd-simulation) | safe-donor | Apache-2.0 | Accelerator-oriented crowd simulation concepts; SYCL reference-only for native Vulkan/CUDA targets. |
| [SaschaWillems Vulkan glTF skinning](https://github.com/SaschaWillems/Vulkan) | safe-donor | MIT | Compact Vulkan glTF skinning sample references. |
| [Khronos glTF Sample Assets](https://github.com/KhronosGroup/glTF-Sample-Assets) | dependency-candidate | Mixed sample-asset licenses | Animation/skinning fixtures only; assets are not code donors. |
| [fairmotion](https://github.com/facebookresearch/fairmotion) | dependency-candidate | BSD-style signal | Motion processing and retargeting concepts; Python/reference-only for native C++. |

## Selection Notes

- Use ozz-animation first for reusable native C++ animation runtime patterns.
- Use ACL when clip compression, decompression cost, and accuracy metrics are central.
- Use UsdSkel for interchange decisions, not as the default runtime representation.
- Use Dem Bones for skinning decomposition and Recast/RVO2/Menge/OpenSteer for crowd behavior; keep
  crowd AI, animation playback, and rendering as separate systems.
- Treat glTF sample assets as fixtures with independent licenses, not donor code.
- Keep FBX SDK, DCC exporter plugins, and sample animation assets license-separated.

## Deep Profiles

- [Advanced Animation, Retargeting, And Crowds](profiles/animation-retargeting-crowds.md): read before selecting skinning decomposition, retargeting, glTF skinning, crowd, steering, or navigation-agent donors.
- [Realtime VFX, Particles, And GPU-Driven Effects](profiles/vfx-particles-gpu-driven.md): read when Vulkan sample routing overlaps particle, indirect draw, or compute examples.
- [ozz-animation](profiles/ozz-animation.md): read before adding skeletal runtime or sampling/blending design.
- [Animation Compression Library](profiles/acl.md): read before adding clip compression or accuracy/size tradeoffs.
- [assimp](profiles/assimp.md): read when animation import requires broad DCC format coverage.
- [Godot Engine](profiles/godot-engine.md): read before borrowing engine/editor animation graph, scene tree, or runtime integration patterns.
- [Open 3D Engine](profiles/open-3d-engine.md): read before borrowing engine-scale animation component or asset-pipeline architecture.
