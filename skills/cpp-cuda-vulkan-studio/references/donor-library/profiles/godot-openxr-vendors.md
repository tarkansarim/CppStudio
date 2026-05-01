# Godot OpenXR Vendors Donor Profile

Source: https://github.com/GodotVR/godot_openxr_vendors  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: MIT for plugin code unless otherwise specified; inspect `LICENSE`, `thirdparty/`,
vendor SDK folders, Android Gradle files, generated bindings, samples, and per-vendor component terms.

## Use First For

- Vendor-specific OpenXR extension wrapping, Meta/Pico/HTC-style feature boundaries, Android XR export
  workflows, and Godot/GDExtension plugin structure.
- Studying how to keep vendor features optional and isolated from portable OpenXR app paths.
- XR UX and export configuration references when Godot-based workflows are relevant.

## First Upstream Areas To Inspect

- `plugin/`, `docs/`, `samples/`, `thirdparty/`, `validation_layers/`, and extension wrapper scripts.
- Vendor-specific folders and Android build files before adopting dependency or packaging ideas.
- Release notes and version compatibility with Godot versions.
- Sample assets and vendor SDK notices before reuse.

## Integration Notes

- Treat this as a vendor-extension and engine-plugin donor, not a portable OpenXR baseline.
- Keep vendor extension wrappers, Android packaging, runtime capability checks, and app feature gates
  separate.
- Use Khronos OpenXR SDK first for portable OpenXR behavior.
- For native C++ apps, translate vendor-extension policy without adding Godot/GDExtension dependencies.

## Validation Ideas

- Add extension-presence checks before enabling any vendor feature.
- Test each vendor path independently; do not enable multiple vendor export paths by default.
- Verify missing vendor runtime, missing Android build template, missing extension, and unavailable device
  behavior.
- Keep vendor SDK and sample asset provenance in docs.

## Caveats

- Vendor XR features reduce portability.
- Some vendor-specific components use separate terms.
- Godot/GDExtension and Android packaging constraints should not leak into ordinary native C++ XR apps.
