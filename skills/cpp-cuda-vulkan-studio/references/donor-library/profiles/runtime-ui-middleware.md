# Runtime UI Middleware Donor Profile

Sources: https://github.com/mikke89/RmlUi https://mikke89.github.io/RmlUiDoc/ https://www.noesisengine.com/noesisgui/ https://www.noesisengine.com/docs/
Tier: `safe-donor`, `dependency-candidate`
Backend signal: mixed-backend
License signal: RmlUi is MIT; NoesisGUI is commercial middleware. Inspect exact SDK, engine plugin,
renderer backend, sample, and third-party terms before adding either dependency.

## Use First For

- Styled retained UI for game HUDs, menus, in-game overlays, editor-like runtime UI, and VR/3D UI.
- Projects where UI designers/artists need markup/styling workflows instead of code-only immediate
  mode panels.
- Separating debug/editor UI from shipped runtime UI.

## First Upstream Areas To Inspect

- RmlUi docs for RML/RCSS, data binding, localization, and renderer interface expectations.
- RmlUi examples and renderer integration notes for the selected backend.
- NoesisGUI technology/docs for XAML workflow, C++ SDK, renderer integration, and engine plugin shape.
- Licensing/deployment terms before selecting NoesisGUI.

## Integration Notes

- Keep runtime UI data binding, localization, styling, asset references, and render submission as
  separate subsystems.
- For Vulkan, treat UI as its own render path with explicit texture/font/atlas lifetimes and input
  routing.
- Use RmlUi when open-source styled UI is enough and the project can own renderer integration.
- Use NoesisGUI only as an explicit commercial dependency decision.

## Validation Ideas

- Load one menu, one HUD overlay, and one data-bound panel from packaged UI assets.
- Validate keyboard/mouse/gamepad input, focus, scaling, localization, and missing asset behavior.
- Render UI over a simple Vulkan frame and check validation output.

## Caveats

- Styled runtime UI solves different problems from debug/editor panels.
- Middleware asset pipelines can become their own build surface.
- Commercial middleware belongs in target-project dependency docs, not reusable public templates.
