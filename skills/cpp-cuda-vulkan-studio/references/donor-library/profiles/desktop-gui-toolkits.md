# Desktop GUI Toolkits Donor Profile

Sources: https://doc.qt.io/qt-6/ https://doc.qt.io/qt-6/licensing.html https://doc.qt.io/qt-6/examples-desktop.html https://wxwidgets.org/ https://wxwidgets.org/about/screenshots/
Tier: `dependency-candidate`
Backend signal: native-cpu, mixed-backend
License signal: Qt uses commercial/GPL/LGPL module-specific terms; wxWidgets uses the wxWindows
Library License with exception. Inspect exact toolkit versions, modules, plugins, designer tools,
deployment terms, and third-party notices.

## Use First For

- Standalone desktop products, long-lived document-style tools, native menus, file dialogs, settings,
  dockable panels, asset browsers, complex model/view widgets, and platform app behavior.
- Projects where the GUI should feel like a desktop application rather than an in-renderer debug HUD.
- Qt/C++ backend plus QML or widgets where a richer application shell is more important than minimal
  render-loop integration.

## First Upstream Areas To Inspect

- Qt module docs and licensing pages before choosing widgets, QML, charts, web engine, 3D, or designer
  tooling.
- Qt desktop examples for expected widget/application style.
- wxWidgets docs, samples, and screenshots for native-widget behavior and platform support.
- The target repo's dependency manager and deployment/package policy before adding either toolkit.

## Integration Notes

- Keep renderer/simulation code behind an app-service boundary; do not leak Qt or wx types through core
  engine/library APIs unless the project intentionally adopts that framework as the app shell.
- For Vulkan embedding, define whether the GUI owns the top-level window and the renderer embeds into a
  widget, or the renderer owns the window and the GUI is an overlay.
- Treat Qt as a large dependency decision. Check module licenses and deployment requirements before
  recommending it for permissive/proprietary-compatible projects.
- Prefer wxWidgets when native widgets and lighter desktop scope matter more than Qt's broader
  ecosystem.

## Validation Ideas

- Build a minimal app shell with menu, file dialog, settings panel, and renderer placeholder.
- Verify Linux, Windows, and macOS package/deployment assumptions before promising cross-platform
  behavior.
- Test event-loop integration, high-DPI behavior, modal dialogs, and renderer resize.

## Caveats

- Desktop GUI frameworks can dominate project architecture; adopt them intentionally.
- Qt module licensing is not uniform across the whole ecosystem.
- Native-widget apps and in-renderer Vulkan tools have different UI expectations and test surfaces.
