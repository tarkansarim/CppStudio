# XR Interaction And Spatial Input Profile

Sources: https://github.com/KhronosGroup/OpenXR-Tutorials https://github.com/StereoKit/StereoKit https://github.com/microsoft/OpenXR-MixedReality https://github.com/meta-quest/Meta-OpenXR-SDK https://github.com/GodotVR/godot_openxr_vendors https://gitlab.freedesktop.org/monado/monado https://github.com/ILLIXR/ILLIXR https://github.com/nvpro-samples/xr_multi_gpu https://github.com/mbucchia/OpenXR-Vk-D3D12 https://github.com/mbucchia/OpenXR-Toolkit https://github.com/ultraleap/OpenXRHandTracking https://github.com/ValveSoftware/openvr
Tier: `safe-donor`, `dependency-candidate`, `study-only`
Backend signal: api-agnostic, native-vulkan, native-directx, mixed-backend
License signal: mixed Apache-2.0, MIT, NCSA, Oculus SDK, archived/evaluation-only, and legacy SDK
signals; inspect vendor SDKs, sample assets, controller/hand meshes, and runtime restrictions.

## Use First For

- OpenXR actions, hands, eye gaze, body/face tracking, passthrough, scene understanding, spatial anchors,
  colocation, runtime diagnostics, API layers, Vulkan/OpenXR performance, and multi-GPU XR.

## Integration Notes

- Start portable OpenXR app behavior from OpenXR-SDK-Source and tutorials before vendor samples.
- Keep vendor extensions optional and feature-gated unless the user explicitly targets that hardware.
- Use NVIDIA xr_multi_gpu only for Vulkan/OpenXR performance or multi-GPU work.
- Treat Meta SDK and Ultraleap archived samples as reference/study surfaces unless the target accepts
  those licenses and devices.

## Validation Ideas

- Distinguish missing runtime, missing device, unsupported extension, missing form factor, and actual app
  bugs in diagnostics.
- Test action bindings, swapchain formats, frame timing, pose prediction, and graphics validation separately.
