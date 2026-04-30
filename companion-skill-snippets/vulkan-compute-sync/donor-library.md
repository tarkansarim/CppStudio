## Donor References

When selecting Vulkan, renderer, WebGPU, or 3D graphics donors, read:

- `{{DONOR_ROOT}}/selection-policy.md`
- `{{DONOR_ROOT}}/graphics-rendering.md`
- `{{DONOR_ROOT}}/profiles/khronos-vulkan-samples.md` for portable Vulkan correctness
- `{{DONOR_ROOT}}/profiles/nvidia-vk-mini-samples.md` for NVIDIA extension/tooling samples

For asset import, mesh processing, BVH, physics, point-cloud, or simulation context, also read
`{{DONOR_ROOT}}/geometry-simulation.md`. For OpenXR, VR, AR, MR, headset/controller, or spatial
interaction context, also read `{{DONOR_ROOT}}/xr-spatial.md` and
`{{DONOR_ROOT}}/profiles/openxr-sdk.md`. Use Khronos samples as the first correctness reference, then
vendor samples for vendor-specific extensions or tools. Keep study-only and non-commercial references
out of reusable Vulkan code.
