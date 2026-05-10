# SDL3 Platform And Pen Input Donor Profile

Source: https://github.com/libsdl-org/SDL  
Docs: https://wiki.libsdl.org/SDL3/  
Tier: `dependency-candidate`  
Backend signal: native-vulkan, native-opengl, native-metal, mixed-backend
License signal: zlib license; inspect the exact release license and bundled notices before locking
the dependency.

## Use When

- A native C++ Vulkan/OpenGL/Metal windowed tool needs a cross-platform platform layer.
- A brush, sculpt, paint, groom, terrain, texture, or stroke-based artist tool needs stylus pressure,
  pen axes, hover/proximity, eraser, barrel buttons, or tablet-aware input routing.
- The project needs Vulkan surface creation and input events without committing to a full desktop
  application toolkit.

## Open First

- SDL3 docs and release notes for the exact version being considered.
- `SDL_Vulkan_CreateSurface` and related Vulkan helpers.
- `SDL_PenMotionEvent`, `SDL_PenAxisEvent`, pen proximity/button docs, and examples for tablet input.
- Platform caveats for Linux/Wayland/X11, Windows, macOS, high-DPI, relative mouse, and event
  capture.

## Reuse Guidance

- Treat SDL3 as a dependency candidate, not a source-copy donor.
- Keep SDL window/input ownership separate from the renderer, GUI layer, and app document model.
- Route pen pressure and axes into an explicit input abstraction so tests can replay strokes without
  a physical tablet.
- For Dear ImGui-based tools, decide clearly which layer owns text input, pointer capture, docking,
  viewport focus, and tablet/stylus events.

## Validation

- Unit test pressure curves, stroke sampling, smoothing, and replay from synthetic input events.
- Add a harness endpoint or trace mode that exposes the last pointer/stylus event, pressure, tilt,
  active buttons, viewport ray, and command target.
- Run GUI/viewport smoke with mouse-only input and with synthetic stylus-pressure events.
- Verify high-DPI and multi-monitor coordinate mapping before claiming tablet-ready behavior.

## Caveats

- Hardware tablet behavior is OS, driver, compositor, and device dependent. Keep a synthetic input
  lane for deterministic CI and a manual/hardware lane for real tablets.
- SDL3 is a platform/input layer, not a DCC application framework. Pair it with Dear ImGui, Qt, or
  another UI layer depending on the product shell.
- Do not choose SDL3 only because it is available; choose it because its input and platform surface
  match the tool's requirements.
