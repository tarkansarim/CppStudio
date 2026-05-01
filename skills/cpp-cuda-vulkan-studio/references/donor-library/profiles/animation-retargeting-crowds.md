# Advanced Animation, Retargeting, And Crowds Profile

Sources: https://github.com/electronicarts/dem-bones https://github.com/recastnavigation/recastnavigation https://github.com/snape/RVO2 https://github.com/MengeCrowdSim/Menge https://github.com/meshula/OpenSteer https://github.com/codeplaysoftware/sycl-crowd-simulation https://github.com/KhronosGroup/glTF-Sample-Assets https://github.com/facebookresearch/fairmotion
Tier: `safe-donor`, `dependency-candidate`
Backend signal: api-agnostic, native-cpu, native-vulkan, mixed-backend
License signal: mixed BSD/MIT/zlib/Apache-2.0 and sample-asset licenses; inspect exact code and asset
licenses before reuse.

## Use First For

- Skinning decomposition, retargeting behavior, glTF skinning samples, crowds, local avoidance, steering,
  and navigation-agent validation fixtures.

## Integration Notes

- Use Dem Bones for skinning decomposition and small native C++ tests.
- Use Recast/DetourCrowd, RVO2, Menge, and OpenSteer for navigation/crowd behavior; keep animation
  playback and rendering separate.
- Treat fairmotion as Python/reference-only and Khronos glTF Sample Assets as fixture-only.

## Validation Ideas

- Test one skeleton/mesh retargeting case, one skinned glTF sample, one two-agent avoidance case, one
  dense crowd scenario, and one unreachable navigation target.
