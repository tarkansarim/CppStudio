# CppStudio Backlog

This backlog collects ideas for future CppStudio work. Items here are candidates, not commitments.
Before implementation, turn an item into a focused plan with scope, validation, and rollout notes.

## Backlog Rules

- Keep entries reusable. Do not add machine-specific or private-project-only work here.
- Prefer agent-facing workflows, scripts, references, and validation over vague wishes.
- Keep first-load skill context small. New domains should use nested docs, references, or scripts
  instead of expanding the main skill text.
- Record donor/source inspiration when an idea comes from another project or research pass.
- Add a validation idea for every implementation-sized item.

## Near-Term Candidates

### Agentic GPU Optimization Loops

Source inspiration: AutoKernel, KernelAgent, CUDA-Agent.

- Add a keep/revert optimization loop for CUDA kernels, Vulkan compute shaders, and render passes.
- Start from a fixed benchmark or CTest label, let agents try bounded improvements, keep only faster
  correct variants, and log every attempt.
- Track correctness, performance, command line, hardware, driver/toolchain, and final diff.
- Validation idea: temporary generated project with one CUDA or Vulkan compute target, fake and real
  benchmark modes, and regression tests that reject incorrect or slower results.

### Native Artist-Tool Recipe Layer

Source inspiration: CppStudio sample projects and the current donor library.

- Add compact recipe docs for common realtime artist-tool subsystems:
  viewport camera, brush engine, gizmos, selection/masking, stroke recording, undo/redo, timeline or
  playback, asset browser, material preview, simulation controls, and capture/reporting.
- Keep recipes backend-agnostic where possible, then route GPU-specific parts through Vulkan/CUDA
  skills.
- Validation idea: trigger-lane prompts for character modeling, material painting, VFX authoring,
  grooming, paint/fluid simulation, and viewport tools.

### Engine And DCC Bridge Guidance

Source inspiration: Unreal/Unity agent assistants, DCC pipelines, USD/glTF donors.

- Add optional bridge guidance for Unreal, Unity, Godot, Blender, USD, and glTF workflows.
- Focus on how a native C++ GPU tool should exchange assets, previews, captures, and validation
  evidence with those environments.
- Keep this as documentation first; avoid committing to a full engine plugin until a specific bridge
  is planned.
- Validation idea: docs-only lint plus trigger-lane prompts that ensure agents choose bridge guidance
  only when the user asks for engine/DCC integration.

### Asset And Project Introspection

Source inspiration: Unreal assistant asset introspection and CppStudio code maps.

- Add guidance and scripts for producing project summaries beyond source layout: assets, materials,
  shaders, kernels, scenes, generated files, runtime captures, and validation artifacts.
- Keep source-code routing in the code map; use separate project/profile docs for asset and runtime
  state.
- Validation idea: fixture repo with fake assets/shaders/kernels and generated summary output checked
  for stable relative paths.

### Project Profile Memory

Source inspiration: CppStudio code maps and project-memory features in adjacent tools.

- Add an optional project profile file separate from the code map.
- Capture style conventions, recurring decisions, performance baselines, toolchain constraints,
  donor decisions, known pitfalls, and user preferences.
- Code maps answer where code lives and what subsystems do; project profiles answer how the project
  prefers to work.
- Validation idea: profile validator that rejects absolute private paths, stale benchmark claims
  without date/toolchain, and oversized first-load content.

## Larger Candidates

### Cross-Agent Packaging And Export

Source inspiration: agent skill registries and multi-agent installers.

- Add export guidance or scripts for adapting CppStudio to other agent skill/rules systems.
- Keep the canonical source layout stable, then generate or document target-specific install shapes.
- Validation idea: dry-run export into temporary Claude/Cursor/OpenCode-style folders without
  touching user config.

### Skill Package Security And Integrity

Source inspiration: managed agent-skill registries.

- Add optional integrity metadata for shipped skill files, snippets, and donor docs.
- Consider hash manifests, lockfiles, symlink/path checks, and static scan hooks for public release
  packaging.
- Validation idea: tamper a temp copied file and confirm the integrity check fails with a useful
  diagnostic.

### Donor Freshness And License Refresh

Source inspiration: donor maintenance reviews.

- Add a repeatable donor refresh protocol for upstream status, license, language/runtime caveats,
  and direct-versus-reference-only classification.
- Keep refresh notes small and date-stamped; avoid vendoring source.
- Validation idea: donor profile schema check that requires refreshed date, license signal, tier,
  backend signal, and caveats for non-C++ or study-only references.

### Live Validation Captures

Source inspiration: realtime viewport/sample projects.

- Add optional conventions for screenshots, short videos, profiler captures, and render/compute
  reports as evidence for generated artist tools.
- Tie captures to CTest labels or scripts so agents can prove visual/runtime behavior instead of only
  claiming it.
- Validation idea: generated fixture that writes a tiny artifact manifest and validates relative
  artifact paths and expected labels.

## Parking Lot

- Explore whether recipe docs should become nested skills or stay as references.
- Decide whether engine/DCC bridge work should start with Unreal, Blender, Godot, Unity, USD, or glTF.
- Consider a public examples index for projects built with the harness, separate from the README.
- Consider a donor-request template so future research additions stay deduplicated and categorized.
