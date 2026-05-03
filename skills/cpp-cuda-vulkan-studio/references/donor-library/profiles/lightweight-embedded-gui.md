# Lightweight And Embedded-Web GUI Donor Profile

Sources: https://github.com/Immediate-Mode-UI/Nuklear https://www.fltk.org/ https://www.fltk.org/shots.php https://github.com/libui-ng/libui-ng https://chromiumembedded.github.io/cef/ https://chromiumembedded.github.io/cef/general_usage.html
Tier: `safe-donor`, `dependency-candidate`
Backend signal: native-cpu, mixed-backend
License signal: Nuklear is MIT or public domain; FLTK uses LGPL with exception; libui-ng is MIT but
mid-alpha; CEF is BSD-style plus Chromium dependency/notice surface. Inspect exact versions and
third-party notices before reuse.

## Use First For

- Small utilities, compact native-widget tools, tiny embeddable panels, or explicit web UI embedding.
- Projects where Qt/wxWidgets/RmlUi/NoesisGUI would be too large for the target surface.
- HTML/CSS/JS reuse through CEF only when embedded browser behavior is a real requirement.

## First Upstream Areas To Inspect

- Nuklear single-header configuration, backend examples, and gallery.
- FLTK widgets, examples, screenshots, and license exception.
- libui-ng examples and issue/activity status before depending on it.
- CEF docs, `cefclient`/`cefsimple`, process model, JavaScript/C++ integration, and binary packaging
  requirements.

## Integration Notes

- Use Nuklear for tiny immediate-mode UI when Dear ImGui is too large or too featureful.
- Use FLTK for simple desktop utilities with a lightweight C++ widget toolkit.
- Use libui-ng only after maturity risk is accepted.
- Use CEF for embedded web UI, not as the default C++ GUI answer. Record runtime size, process,
  sandbox/security, GPU-compositing, update, and packaging implications.

## Validation Ideas

- Build the smallest utility window with input, file/dialog behavior when relevant, and renderer handoff
  if the UI is embedded in a realtime app.
- For CEF, validate process startup/shutdown, local asset loading, JS/C++ messaging, and package size.
- For Nuklear/FLTK/libui-ng, verify high-DPI, font, clipboard, keyboard navigation, and platform build
  behavior.

## Caveats

- Lightweight toolkits trade away advanced editor/product features.
- CEF is powerful but heavy and has a different security/deployment model from native widgets.
- libui-ng's maturity signal requires extra evaluation before serious production use.
