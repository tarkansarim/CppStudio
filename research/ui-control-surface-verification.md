# UI Control Surface Verification

Date: 2026-05-31

## Ceiling Research Pass

Decision being researched: how CppStudio-backed native C++/Qt/Vulkan/CUDA GUI tools should prove
product-facing controls are wired, fresh, and reachable without relying on slow screenshot-only
inspection.

Local constraints discovered:

- CppStudio already requires visible user-facing proof, live mutation through real handlers, and
  before/after evidence for viewport/session bugs.
- Production failures showed screenshot-heavy review still missed stale controls, hidden/raw fields,
  unmutated rotation controls, and mode mismatches.
- The replacement must stay generic for native GPU tools and not hard-code a single project.

Upstream/current sources checked:

- Qt Test supports Qt/C++ tests, QTest mouse/key simulation, CTest integration, and offscreen widget
  runs for some X11 cases: https://doc.qt.io/qt-6/qtest-overview.html and
  https://doc.qt.io/qt-6/qtest.html
- Qt Squish object maps identify GUI objects through property sets, and property verification points
  compare object properties against expected values:
  https://doc.qt.io/squish/object-map-view.html and
  https://doc.qt.io/squish/how-to-create-and-use-verification-points.html
- Microsoft UI Automation models controls with automation properties, control patterns, and control
  types, making name/state/action capabilities inspectable:
  https://learn.microsoft.com/en-us/windows/win32/winauto/ui-automation-specification
- W3C WebDriver exposes element attributes/properties, enabled state, interactions, and a documented
  displayedness model; its visibility note is useful because it treats perceptual display as more
  than a raw style flag: https://www.w3.org/TR/webdriver/
- Dear ImGui Test Engine describes automation for GUI testing, smoke/integration testing, headless
  operation, and controlling app/engine-exposed surfaces:
  https://github.com/ocornut/imgui_test_engine

Current leading approach:

- Use an app-owned numeric control-surface contract as the primary proof for control wiring and
  freshness. Screenshots are secondary proof for layout, occlusion, polish, and appearance.
- For each relevant mode/state, enumerate every visible, hidden, disabled, and expected product
  control with stable id/object name, label, widget/control type, section/dock path, visibility and
  enabled state plus reason, mode predicate, value/range/options, source handler/action, committed
  model/state field, runtime/readback field, and last mutation result when applicable.
- Drive critical controls through the same handler path a user exercises, then compare visible value,
  committed model state, and runtime payload/readback.
- Fail stale controls mechanically: visible but unbound, disabled without reason, hidden with no
  reachable mode/scroll/path, duplicate owners for one runtime field, raw/internal payload fields in
  product UI, and mutations that affect only the widget or only backend state.

Legacy/lower-ceiling approaches:

- Screenshot-only proof: too slow for agents to inspect reliably and weak at finding stale wiring.
- Model-only setters or backend HTTP controls: useful diagnostics, but they bypass widget focus,
  mode predicates, signal/action handlers, and visibility.
- Object counts or static signal-slot inspection: useful coverage hints, but they do not prove the
  user-facing path or runtime payload changed.
- Startup-only screenshots: weak for modeful panels because the active state may be wrong-sized,
  wrong-mode, stale-binary, or not the panel the user reported.

Project Dos And Don'ts:

- Do require a control contract for GUI-heavy panels before accepting UI wiring closeout.
- Do require per-mode contract snapshots for modeful surfaces such as light type, shader type,
  brush tool, renderer mode, timeline state, node context, or selected object.
- Do mutate newly added, changed, or user-reported critical controls through real UI handlers and
  compare widget, model, and runtime/readback values.
- Do keep screenshots/captures for product appearance, layout, and occlusion claims.
- Do not use screenshots as primary proof that controls are wired, enabled, fresh, or reachable.
- Do not accept raw/internal payload controls leaking into product UI unless they are deliberately
  exposed as an advanced/debug surface and labeled that way.

Recommended route:

CppStudio should call this pattern a UI control-surface contract and require it in the main native GPU
skill, supervisor skill, control-harness skill, viewport-session skill, and generated validation docs.
