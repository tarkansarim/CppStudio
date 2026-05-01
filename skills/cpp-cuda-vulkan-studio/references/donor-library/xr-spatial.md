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
- Use OpenXR-Hpp for C++ wrapper ergonomics after baseline OpenXR SDK behavior is understood.
- Use Monado for runtime architecture and Linux runtime diagnostics, not as a portable app API.
- Use Godot OpenXR Vendors only when vendor-specific extensions, Android export workflows, or
  Godot/GDExtension plugin boundaries are in scope.
- Keep runtime selection, action bindings, graphics API binding, swapchain format, frame timing, and
  controller input as explicit test surfaces.
- Treat vendor SDKs, controller models, hand models, and runtime assets as separate license surfaces.
- XR lanes should normally also read `graphics-rendering.md` and the Vulkan profiles when Vulkan is the
  graphics backend.

## Deep Profiles

- [OpenXR SDK](profiles/openxr-sdk.md): read before adding OpenXR/Vulkan app scaffolding or tests.
- [OpenXR-Hpp](profiles/openxr-hpp.md): read before adding C++ OpenXR wrapper bindings or RAII-style OpenXR API ergonomics.
- [Monado](profiles/monado.md): read before using open-source OpenXR runtime architecture, diagnostics, or Linux runtime behavior as a reference.
- [Godot OpenXR Vendors](profiles/godot-openxr-vendors.md): read before borrowing vendor-extension wrappers, Android XR export, or Godot XR plugin references.
