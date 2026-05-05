# Source Skill And Agent Routing

Owns the user-level `cpp-cuda-vulkan-studio` skill source, CppStudio repo onboarding, Vulkan-first
lane policy, code-map trigger metadata, active-map navigation behavior, donor-router entrypoints, and
generated-project workflow instructions.

## Canonical Docs

- `AGENTS.md`
- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/agentic-control-harness/SKILL.md`
- `skills/cpp-cuda-vulkan-studio/references/project-archetypes.md`

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/SKILL.md`
- `skills/native-cpp-gui-hud/SKILL.md`
- `skills/cppstudio-project-planner/SKILL.md`
- `skills/agentic-control-harness/SKILL.md`
- `.codex/skills/cppstudio-repo-onboarding/SKILL.md`

## Current External Doctrine Posture

- Sortie assistant-pack adoption research is provenance only. CppStudio may cherry-pick generic
  doctrine into reusable skills, but must not import Sortie runtime mechanics such as Sortie MCP
  call sequences, L0/L1/L2 Harness roles, checkpoint/rewind/gauntlet machinery, workflow graph
  execution, agent resource defaults, or `.sortie` artifact contracts.

## Current Code-Map Bootstrap Posture

- Existing-project code-map opt-in is evidence-first: agents must run the non-destructive readiness
  audit, present concrete findings and cleanup cost, and only then ask whether to restructure,
  preserve the current layout with documented exceptions, or decline the map.
- Code-map completion is evidence-gated: validation proves schema/state only. After enablement or
  major map edits, agents must run a read-only subagent or fresh-session routing smoke when that
  testing route is available before saying future agents can use the map reliably. The smoke should
  stop after the first confident subsystem route and exact source/test paths, not expand into a full
  source audit. A smoke that skips manifest/state reads, over-reads broadly, edits files, or never
  produces a final routing report is partial or failed evidence.
- Enabled code maps have an ordinary pre-commit maintenance gate. Agents must run
  `scripts/check_code_map_drift.py --require-enabled` when available before committing a verified
  source slice, then update the manifest and matching subsystem doc for any changed routable path
  that is not covered. The checker catches path coverage; semantic ownership/data-flow changes still
  require agent judgment even when the path is already routed.
- Target-repo instruction files are sensitive. `AGENTS.md`, `CLAUDE.md`, repo-local skills, and
  agent metadata must be named separately in status reports when dirty or changed; they must not be
  hidden under generic "unrelated dirty files" wording.

## Update When

- skill trigger description, workflow, acceptance, or bundled script list changes
- Vulkan/CUDA lane policy changes
- project archetype routing changes
- the repo-local onboarding skill changes
- code-map readiness, bootstrap, or maintenance behavior changes for agents
- target-repo code-map authority or map-first navigation behavior changes
- donor-grounding or web-ceiling-check expectations for native GPU brainstorming/design proposals
  change
- native C++ GUI/HUD/editor UI skill routing or option-presentation behavior changes
- initial native C++ GPU project planning, Plan mode handoff, template-choice, or artist-input
  planning behavior changes
- project authoring-model/source-of-truth research expectations or decision gates change
- agentic control harness routing, autonomous app testing expectations, launch/control registry, or
  visual/UI observation behavior changes
- hard gates that require agents to open local skills, maintained code-map routes, and donor-library
  categories before code changes or product-shape decisions
- code-map bootstrap script authority, code-map schema validation, or generated CMake probe cleanup
  requirements change
- code-map drift-check or pre-commit map-maintenance requirements change
- GUI/windowed verification routing changes, including when agents should use target smoke scripts,
  launch wrappers, absolute script paths, or explicit working directories with offscreen/background
  managers
- DCC/editor command-surface rules change, including when structural graph, scene, timeline, or
  layer edits should use editor actions, menus, shortcuts, context actions, or toolbar affordances
- GUI/action verification rules change, including when harnesses should introspect actual toolkit
  actions, menu entries, shortcuts, context surfaces, enabled states, or distinguish metadata claims
  from proof
- user-facing desktop launch-command verification requirements change, including non-blocking
  long-running GUI launch verification, launcher probe behavior, and duplicate-launch contracts
- target-project commit rhythm changes, including when verified implementation slices should be
  committed before agents continue into the next milestone
- target-project commit-origin marker policy changes, including how autonomous agent commits are
  distinguished from user-requested commits
- target-project build/validation command selection rules change, including when agents must use
  repo-declared CMake presets, validation docs, scripts, or code-map build routes instead of guessed
  build directories
- target-project shell-search discipline changes, including how agents must quote markdown/code-span,
  script-fragment, or regex patterns so documentation syntax and shell metacharacters are not
  executed or reinterpreted during validation audits
- control-harness screenshot or render-target capture rules change, including when agents must prove
  a capture reflects the requested rendered state instead of a stale frame
- visual-capture debugging rules change, including when agents should audit capture API timing,
  render scheduling, and smoke-script order after repeated stale-frame failures
- control-harness thread-boundary rules change, including when visual capture, toolkit readback, and
  UI/renderer state must run on the app GUI/render thread rather than an HTTP/server worker
- repeated visual-capture or render-scheduling failure policy changes, including hard-reset evidence
  ledgers and keep/revert decisions before additional patches
- control-harness mutation-success semantics change, including when endpoint `ok` must prove actual
  committed state and post-snap/post-clamp values instead of raw command input
- GUI/editor event-handler rewrite discipline changes, including source-structure inspection before
  stacking harness routes, docs, or screenshots on broad interaction rewrites
