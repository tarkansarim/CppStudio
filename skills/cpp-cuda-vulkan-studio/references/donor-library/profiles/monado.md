# Monado Donor Profile

Source: https://monado.dev/  
Tier: `dependency-candidate`  
Backend signal: mixed-backend
License signal: Permissive open-source project licensing with component-level notices; inspect Monado
repository licenses, device drivers, compositor code, dependencies, firmware/assets, and platform
integration files at the exact revision used.

## Use First For

- OpenXR runtime architecture, Linux XR runtime behavior, compositor/device integration, driver paths,
  tracking pipelines, and runtime diagnostics.
- Understanding runtime-side failure modes that app-level OpenXR samples do not expose.
- Comparing app-layer OpenXR behavior against open runtime implementation details.

## First Upstream Areas To Inspect

- Runtime, compositor, driver, IPC, tracking, and platform integration docs/code.
- Device-specific code and dependencies before borrowing behavior.
- Build/deployment docs for Linux runtime setup and diagnostics.
- License files for drivers, firmware references, and third-party dependencies.

## Integration Notes

- Treat Monado as runtime architecture/reference material unless the project explicitly targets runtime
  development or packages Monado.
- Keep app-level OpenXR tests separate from runtime implementation assumptions.
- For Vulkan/OpenXR apps, use Monado diagnostics to understand runtime behavior without coding against
  Monado-specific internals by default.
- Document any runtime-specific extensions or expectations.

## Validation Ideas

- Record runtime name, version, extensions, form factor, graphics requirements, and connected device state.
- Test missing runtime, wrong runtime, missing device, unsupported extension, and compositor startup
  failures as separate cases.
- Compare app failures against runtime logs before blaming Vulkan resources.
- Keep runtime setup notes out of reusable templates unless the project targets runtime development.

## Caveats

- XR runtime behavior depends on hardware, drivers, compositor setup, and platform services.
- Runtime internals are not portable app APIs.
- Device and firmware references can carry separate license and distribution surfaces.
