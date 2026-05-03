# Project Intake Protocol

Use this protocol when a user wants to start, brainstorm, or substantially reshape a native C++
GPU/realtime project. The output is a planning packet, not code.

## Plan Mode Gate

If the project has unresolved choices across template, GUI, GPU lane, dependencies, input devices, or
donor strategy, ask the user to switch to Plan mode before implementation. Explain that the benefit
is fewer wrong dependencies, cleaner Vulkan/CUDA lane boundaries, better donor grounding, and a
validation plan before files are created.

If Plan mode is unavailable, ask no more than three questions at a time. Do not scaffold until the
critical choices are resolved.

## Intake Checklist

Collect these facts before committing to architecture:

- Project type: renderer, simulation, artist tool, game technical-art tool, DCC tool, asset pipeline,
  AI runtime, CUDA library, Vulkan app, explicit interop app, XR app, or existing-repo upgrade.
- Target users: artist, technical artist, gameplay/tools programmer, graphics engineer, VFX pipeline
  TD, researcher, or product user.
- Platforms: Linux, Windows, macOS, WSL, Steam Deck, studio workstation, or CI-only headless lane.
- GPU lane: Vulkan-first, CUDA, or explicit CUDA/Vulkan interop. If unspecified, recommend Vulkan
  first for cross-vendor realtime work.
- Template/archetype: greenfield scaffold, existing-repo backbone upgrade, library-only, app+library,
  renderer, simulation visualizer, tool shell, or headless compute package.
- GUI/HUD/editor stack: debug HUD, internal artist tool, polished desktop app, runtime game UI,
  embedded web UI, or mixed.
- Input devices: mouse/keyboard, Wacom/stylus, multi-touch, SpaceMouse, gamepad, MIDI/control
  surface, VR controllers, hand tracking, or custom hardware.
- Asset/data surfaces: glTF/GLB, USD, Alembic, OpenVDB/NanoVDB, textures/materials, CAD/NURBS,
  animation clips, groom curves, volume data, AI models, or custom binary formats.
- Donor grounding: matching production overlay, donor categories, deep profiles, and any reference
  material that is study-only or non-C++ reference-only.
- Web ceiling check: upstream repos/docs, official SDK docs, papers, samples, or vendor pages that
  could change the recommendation.
- Dependency policy: system packages, vcpkg, Conan, FetchContent, submodules, vendored source,
  commercial SDKs, license constraints, and offline/air-gapped requirements.
- Code map: ask whether the project should maintain a CppStudio code map for future agents. For
  existing repos, require the code-map readiness audit before enabling it.
- Validation: build presets, CTest labels, shader compilation, Vulkan validation, Compute Sanitizer,
  offscreen screenshots, profiler lanes, CI, and first milestone acceptance tests.

## Artist Tool Input Checklist

For artist-facing tools, explicitly plan the input model:

- stylus pressure, tilt, rotation, eraser, hover, barrel buttons, tablet mapping, and pressure curves
- stroke sampling rate, interpolation, stabilization, latency budget, smoothing, and undo/redo
  recording
- viewport picking, brush radius/depth behavior, symmetry, masks, falloffs, cursor overlays, and
  brush preview rendering
- left/right hand workflows, modifier keys, focus capture, DPI scaling, and multi-monitor/tablet
  coordinate mapping
- whether input is captured through the windowing layer, GUI toolkit, native tablet APIs, or a
  project-specific input abstraction

## Planning Packet Template

Use this shape for the response:

```text
Project intent:
Recommended archetype/template:
GPU lane:
GUI/HUD options:
Artist/input requirements:
Skills opened:
Donors opened:
Web sources checked:
Recommended default:
Questions before implementation:
Code-map choice:
Validation plan:
Implementation handoff:
```

Keep the packet compact. Put links next to the option they support.
