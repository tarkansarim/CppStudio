# OpenXR SDK Donor Profile

Source: https://github.com/KhronosGroup/OpenXR-SDK-Source  
Tier: `safe-donor`  
License signal: Apache-2.0 plus generated-file and `COPYING.adoc` notices; inspect `LICENSE`,
`COPYING.adoc`, generated headers, samples, and third-party files at the exact revision used.

## Use First For

- Portable OpenXR loader, validation layer, and sample app structure.
- `hello_xr`-style frame loop, action setup, swapchain creation, graphics binding, and runtime discovery.
- Vulkan/OpenXR integration before vendor-specific extension samples.
- XR CI smoke tests that need capability and runtime diagnostics.

## First Upstream Areas To Inspect

- `src/loader/` for loader behavior and runtime discovery boundaries.
- `src/api_layers/` for validation and API-layer behavior.
- `src/tests/hello_xr/` for graphics API binding, swapchain, frame loop, and action examples.
- Generated headers and registry inputs when API version or extension coverage matters.
- Build docs for loader, samples, validation layers, and platform-specific behavior.

## Integration Notes

- Keep OpenXR runtime selection, system discovery, session lifecycle, reference spaces, actions,
  swapchains, frame timing, and graphics binding as separate test surfaces.
- Use Khronos samples before vendor samples for baseline behavior; add vendor references only for a
  specific extension or device feature.
- In Vulkan projects, coordinate device/queue selection, swapchain image format, synchronization, and
  frame pacing with the Vulkan lane.
- Treat controller models, hand meshes, vendor SDKs, runtime assets, and store metadata as separate
  license surfaces.

## Validation Ideas

- Add a runtime discovery command that reports loader version, runtime name, supported extensions, and
  system form factors.
- Exercise a headless or minimal `hello_xr`-style smoke test where the local runtime supports it.
- Validate action bindings and swapchain format selection with explicit failure messages.
- Capture frame timing and graphics validation separately so runtime failures are not mistaken for Vulkan
  resource bugs.

## Caveats

- OpenXR availability depends on the installed runtime and connected device. CI must distinguish missing
  runtime, missing hardware, missing extension, and app bugs.
- Vendor extensions can narrow portability quickly; document every extension that becomes required.
- XR tests can be timing-sensitive, so record runtime, headset, driver, and refresh-rate context in
  failure reports.
