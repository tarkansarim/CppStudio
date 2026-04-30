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

## Selection Notes

- Use Khronos `hello_xr` before vendor samples for portable OpenXR app structure.
- Keep runtime selection, action bindings, graphics API binding, swapchain format, frame timing, and
  controller input as explicit test surfaces.
- Treat vendor SDKs, controller models, hand models, and runtime assets as separate license surfaces.
- XR lanes should normally also read `graphics-rendering.md` and the Vulkan profiles when Vulkan is the
  graphics backend.

## Deep Profiles

- [OpenXR SDK](profiles/openxr-sdk.md): read before adding OpenXR/Vulkan app scaffolding or tests.
