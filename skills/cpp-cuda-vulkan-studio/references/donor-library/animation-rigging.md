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

## Selection Notes

- Use ozz-animation first for reusable native C++ animation runtime patterns.
- Use ACL when clip compression, decompression cost, and accuracy metrics are central.
- Use UsdSkel for interchange decisions, not as the default runtime representation.
- Keep FBX SDK, DCC exporter plugins, and sample animation assets license-separated.

## Deep Profiles

- [ozz-animation](profiles/ozz-animation.md): read before adding skeletal runtime or sampling/blending design.
- [Animation Compression Library](profiles/acl.md): read before adding clip compression or accuracy/size tradeoffs.
