# XR And Spatial Interaction Donors

Use these donors for OpenXR, VR/AR/MR app structure, XR runtimes, headset/controller input, stereo
swapchains, frame timing, spatial interaction, and Vulkan/OpenXR integration.

## OpenXR Foundations

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Khronos OpenXR-SDK-Source](https://github.com/KhronosGroup/OpenXR-SDK-Source) | safe-donor | Apache-2.0 plus generated-file notices; inspect `COPYING.adoc` | OpenXR loader, API layers, `hello_xr` samples, Vulkan/OpenXR app structure. |
| [OpenXR-Hpp](https://github.com/KhronosGroup/OpenXR-Hpp) | safe-donor | Apache-2.0 | C++ OpenXR bindings and type-safe wrapper patterns. |
| [Monado](https://monado.dev/) | dependency-candidate | Permissive open-source licensing; inspect GitLab notices | Open-source OpenXR runtime architecture, Linux runtime behavior, device/runtime integration. |

## Engine And Vendor References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Godot OpenXR](https://docs.godotengine.org/en/stable/tutorials/xr/index.html) | dependency-candidate | Godot MIT; plugin/vendor assets vary | OpenXR app UX, controller/action setup, engine integration, vendor extension handling. |
| [Godot OpenXR Vendors](https://github.com/GodotVR/godot_openxr_vendors) | dependency-candidate | MIT for plugin code; vendor SDK/assets vary | Vendor extension handling for Meta/Pico/HTC-style runtimes. |

## Interaction, Vendor Extensions, And System References

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [OpenXR Tutorials](https://github.com/KhronosGroup/OpenXR-Tutorials) | safe-donor | Apache-2.0 | Guided setup, graphics, interactions, and extension learning paths. |
| [StereoKit](https://github.com/StereoKit/StereoKit) | dependency-candidate | MIT | Hands, eyes, UI, input abstractions, asset loading, and mixed-reality app ergonomics. |
| [Microsoft OpenXR-MixedReality](https://github.com/microsoft/OpenXR-MixedReality) | safe-donor | MIT plus NOTICE | Hand tracking, eye gaze, controller models, spaces/anchors, and HoloLens/WMR samples; D3D patterns must be translated for Vulkan targets. |
| [Meta OpenXR SDK](https://github.com/meta-quest/Meta-OpenXR-SDK) | study-only | Oculus SDK License Agreement plus third-party notices | Quest body/face/eye tracking, hand mesh/capsules, passthrough, scene model, spatial anchors, colocation, foveation, and SpaceWarp references only. |
| [ILLIXR](https://github.com/ILLIXR/ILLIXR) | dependency-candidate | NCSA plus third-party plugin/component licenses | XR system architecture, perception, VIO/head tracking, timewarp, telemetry, benchmarking, and offload research. |
| [NVIDIA xr_multi_gpu](https://github.com/nvpro-samples/xr_multi_gpu) | safe-donor | Apache-2.0 | Vulkan/OpenXR stereo multi-GPU, device-to-device transfer, synchronization, tracing, and frame-time logging. |
| [OpenXR Vk/D3D12 API layer](https://github.com/mbucchia/OpenXR-Vk-D3D12) | safe-donor | MIT | API-layer design, Vulkan/OpenXR support on D3D12-only runtimes, swapchain import, fence synchronization. |
| [OpenXR Toolkit](https://github.com/mbucchia/OpenXR-Toolkit) | safe-donor | MIT | API-layer diagnostics, foveated rendering/upscaling-style utility patterns, and user-facing XR settings. |

## Deferred Or Study-Only

| Donor | Tier | License Signal | Best Use |
| --- | --- | --- | --- |
| [Ultraleap OpenXRHandTracking](https://github.com/ultraleap/OpenXRHandTracking) | study-only | Archived; internal evaluation/demonstration license signal | Historical hand-tracking reference only. |
| [Valve OpenVR](https://github.com/ValveSoftware/openvr) | dependency-candidate | BSD-style signal | Legacy migration or SteamVR compatibility context; do not route new cross-platform work here first. |

## Selection Notes

- Use Khronos `hello_xr` before vendor samples for portable OpenXR app structure.
- Use OpenXR-Hpp for C++ wrapper ergonomics after baseline OpenXR SDK behavior is understood.
- Use Monado for runtime architecture and Linux runtime diagnostics, not as a portable app API.
- Use Godot OpenXR Vendors only when vendor-specific extensions, Android export workflows, or
  Godot/GDExtension plugin boundaries are in scope.
- Use OpenXR Tutorials for learning-path clarity, then return to OpenXR-SDK-Source for baseline
  portable behavior.
- Keep vendor extensions optional and feature-gated unless the user explicitly targets that device.
- Use NVIDIA xr_multi_gpu only for Vulkan/OpenXR performance or multi-GPU cases; keep it out of
  ordinary portable XR scaffolds.
- Keep runtime selection, action bindings, graphics API binding, swapchain format, frame timing, and
  controller input as explicit test surfaces.
- Treat vendor SDKs, controller models, hand models, and runtime assets as separate license surfaces.
- XR lanes should normally also read `graphics-rendering.md` and the Vulkan profiles when Vulkan is the
  graphics backend.

## Deep Profiles

- [XR Interaction And Spatial Input](profiles/xr-interaction-spatial-input.md): read before selecting OpenXR interaction, vendor extension, system-testbed, API-layer, or multi-GPU XR donors.
- [OpenXR SDK](profiles/openxr-sdk.md): read before adding OpenXR/Vulkan app scaffolding or tests.
- [OpenXR-Hpp](profiles/openxr-hpp.md): read before adding C++ OpenXR wrapper bindings or RAII-style OpenXR API ergonomics.
- [Monado](profiles/monado.md): read before using open-source OpenXR runtime architecture, diagnostics, or Linux runtime behavior as a reference.
- [Godot OpenXR Vendors](profiles/godot-openxr-vendors.md): read before borrowing vendor-extension wrappers, Android XR export, or Godot XR plugin references.
