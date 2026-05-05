# Changelog

All notable CppStudio changes should be recorded here before pushing to remote.

## Unreleased

- Broadened validation-audit shell guidance so agents quote script-fragment and regex searches with
  embedded quotes, `$`, or other shell metacharacters, not only markdown backticks.
- Tightened agentic control-harness thread-boundary guidance so UI/renderer readback, toolkit action
  state, and visual capture run through the safe GUI/render thread instead of direct server-thread
  calls.
- Tightened agentic control-harness guidance so viewport, canvas, render-target, and screenshot
  capture endpoints must settle on the requested rendered state and expose frame/revision evidence
  when practical, preventing stale pixels from passing visual checks.
- Added capture-timing audit guidance so agents distinguish capture APIs that render during the grab
  from APIs that copy the last presented frame before adding waits or continuous render scheduling.
- Tightened validation-audit shell guidance so agents quote markdown/code-span search patterns safely
  and do not let backticks in docs become shell command substitutions during `rg`/`grep` checks.
- Tightened native C++ GPU validation guidance so agents must use repo-declared CMake presets,
  validation docs, scripts, or code-map build routes before guessing build directories.
- Required GUI/editor harness verification to prove real action/menu/shortcut state where practical,
  instead of treating advertised metadata as proof that a command surface works.
- Tightened native GUI/editor guidance so structural DCC graph/scene edits use editor actions,
  menus, shortcuts, or context surfaces before toolbar affordances, with screenshot review rejecting
  crowded or clipped controls.
- Added commit-origin trailer guidance so autonomous verified-slice commits and explicit
  user-requested commits are distinguishable in target project history.
- Added verified-slice git commit discipline to the CppStudio workflow so agents commit clean
  source/docs/harness/code-map updates before continuing into the next implementation milestone.
- Fixed the validation script's ShellCheck directive for the Vulkan validation wrapper fixture so
  hosted CI accepts the intentionally single-quoted child-shell capture command.
- Hardened the generated Vulkan validation wrapper so SDK validation-layer manifests and layer
  library paths are exported together, preventing `ErrorLayerNotPresent` load failures from being
  mistaken for renderer regressions.
- Tightened GUI/windowed verification guidance so agents stop after sufficient evidence, prefer
  project smoke scripts/launch wrappers, and use explicit working directories or absolute script
  paths for offscreen-manager invocations.
- Required exact desktop launch-command verification when agents provide or change user-facing GUI
  launch commands, so offscreen smoke alone is not treated as launch proof.
- Tightened desktop launch verification guidance so agents use bounded non-blocking GUI launch
  probes, avoid transient-shell SIGHUP artifacts, classify localhost control-port probe failures
  under `set -e`, and verify duplicate-launch/focus behavior when a fixed control port is used.
- Tightened target-repo hygiene rules so agents use the bundled code-map bootstrap/validator instead
  of hand-writing `.cppstudio` schema, and remove top-level CMake probe artifacts before validation,
  review, or commit status.
- Added a hard donor-first implementation gate across CppStudio skills: before touching native GPU,
  GUI/editor, planning, or control-harness code, agents must open the relevant local skills,
  maintained map routes, and smallest matching donor-library references instead of relying on
  training data or intuition.
- Strengthened project-planner research gates so agents must investigate comparable current tools and
  common authoring models/source-of-truth patterns before asking Plan mode questions or scaffolding.
- Hardened Nsight Systems profiling guidance so agents use explicit supported reports/formats and do
  not fall back to stale `nsys stats --report summary --format text` commands.
- Tightened `run_nsys_smoke.sh` stats readback to use one explicit `nsys stats --force-export=true`
  command with lane-specific column reports such as `vulkan_api_sum,osrt_sum,nvtx_sum`, avoiding
  stale SQLite reuse warnings and marker-report defaults on Nsight versions without `summary`/`text`.
- Added a bundled `agentic-control-harness` skill and planner routing so interactive native C++
  apps default to local HTTP/curl or CLI controls, optional MCP facades, state/log/visual
  observation, and autonomous agent test/troubleshooting lanes before routine user manual testing.
- Made `run_nsys_smoke.sh` query installed Nsight Systems stats reports/formats and select
  lane-appropriate summaries, avoiding stale `summary`/`text` assumptions across Nsight versions.
- Documented the bundled `cppstudio-project-planner` skill in the README, including its role in
  researching current best approaches before major project choices.
- Changed initial CppStudio planning flow so agents gather a pre-plan research brief first, including
  local donor routing and targeted upstream web checks, then ask the user to switch to Plan mode for
  decisions.
- Strengthened the project planner's web ceiling check so initial planning looks for current
  state-of-the-art or actively popular approaches, separates them from legacy options, and avoids
  defaulting to easy lower-ceiling choices unless the user asks for a lightweight route.
- Hardened GUI/HUD selection behavior so interactive choice prompts must be preceded by visible
  source/docs and visual-inspection links, with compact URLs included in option descriptions when the
  question UI allows it.
- Added a bundled `cppstudio-project-planner` skill for initial native C++ GPU project intake before
  scaffolding, including Plan mode handoff, template/archetype choice, GPU lane choice, GUI/HUD
  links, donor routing, web ceiling checks, code-map policy, validation planning, and artist-input
  requirements such as Wacom/stylus pressure.
- Updated rollout, validation, package-integrity docs, manual install docs, and trigger-matrix
  coverage so the project planner installs and validates as a bundled auxiliary skill.
- Added a bundled `native-cpp-gui-hud` skill and native GUI/HUD donor route covering Dear ImGui,
  ImGuizmo, ImPlot, Qt, wxWidgets, RmlUi, NoesisGUI, Nuklear, FLTK, libui-ng, and CEF, with visual
  inspection links required when agents present options.
- Updated rollout, watch mode, validation, package manifests, companion snippets, and manual install
  docs so bundled auxiliary skills are validated and installed with the CppStudio harness.
- Tightened native GPU brainstorming behavior so concrete architecture recommendations must be
  donor-grounded, with targeted upstream web checks for current best-choice or ceiling questions.
- Required a web ceiling check for broad realtime simulation/graphics brainstorms such as Vulkan
  fluids/fire/smoke/water/destruction, even when the prompt only asks to brainstorm.
- Clarified README code-map wording so enabled maps are described as section-level onboarding and
  map-first navigation, not a replacement for source inspection.
- Fixed hosted CI Python syntax checks so generated bytecode is written outside the checkout before
  strict skill-package validation runs.
- Added README acknowledgements for the public reference repos that informed the GPU optimization
  and package-integrity workflows, with a clear no-vendored-source note.
- Fixed fresh-review hardening issues around GPU optimization new-file auto-reverts, portable
  sync/rollout path resolution, code-map doc/manifest parity, and closed package-manifest schemas.
- Hardened generated GPU optimization loops so benchmark parse/evaluation failures auto-revert when
  requested, profiler tool gaps are recorded as artifacts, target-table numerics fail cleanly, and
  package-manifest writes reject local/secrets/temp artifacts.
- Added deterministic skill package integrity metadata, validation, and sync/rollout audit logging:
  `package-manifest.json`, `validate_skill_package.py`, staged/installed package checks, and
  progressive-disclosure file roles.
- Added AgentSys-inspired performance investigation discipline to generated GPU optimization loops:
  success criteria, hypothesis logs, breaking-point search, repeated validation passes, and
  consolidation reports.
- Extended the generated GPU optimization loop with KernelAgent-inspired NCU/SOL profiling,
  roofline classification, bottleneck-first round planning, beam-style worker artifacts,
  convergence stops, and divergence-aware reject/revert handling.
- Added a front-page README commit highlights section and maintainer guidance so important pushed
  commit changes stay visible without replacing the full changelog.
- Added an AutoKernel-adapted generated-project GPU optimization loop with target tables, baselines,
  `run.log`, `results.tsv`, keep/revert attempts, move-on state, and final reports.
- Added `docs/BACKLOG.md` for future CppStudio ideas, including optimization loops, artist-tool
  recipes, engine/DCC bridge guidance, project profiles, packaging, and donor refresh work.
- Made the README opening description agent-agnostic so Codex-specific wording is kept to install
  and packaging instructions instead of the main positioning copy.
- Clarified the README positioning: CppStudio is a native C++ GPU development harness delivered as a
  Codex skill package, not merely a loose skill pack.
- Hardened code-map glob path validation, sync rollback state tracking, and quoted `#` parsing in
  repo-local OpenAI agent metadata validation.
- Made sync/rollout rollback-aware, hardened local path validation for code maps and donor docs,
  strengthened the repo-local skill validator, made existing-project code-map audits stdout-first,
  and refreshed stale generated-project/readiness docs.
- Added repo-local validator fallback for validation, sync, and rollout scripts, including regression
  coverage for fresh Codex homes and non-default `SYNC_CODEX_HOME` rollout validation.
- Isolated those fresh-home validation regressions from inherited `VALIDATOR` overrides so CI proves
  the target-home validator path instead of accidentally reusing the parent harness setting.
- Hardened generated code-map enablement so stale existing map files require explicit `--force`, the
  enabled state is written last, and validation catches generated-map subsystem/index mismatches.
- Clarified donor tier versus caveat terminology in contributor and donor-library docs.
- Made public CI run `./scripts/validate.sh --full`, including generated-project scaffold/build
  validation with hosted-CI CUDA runtime tests skipped only when no CUDA device is available.
- Made public CI discover the installed Lavapipe Vulkan CPU ICD path before running Vulkan runtime
  tests on hosted Ubuntu runners.
- Made the tiny user-level `AGENTS.md` relay install by default during rollout, with
  `SKIP_USER_AGENTS_RELAY=1` as the explicit opt-out.
- Hardened manual install guidance with symlink checks and rollback-on-validation-failure behavior.
- Clarified private-provenance validation so public sample labels remain allowed while compact
  maintainer project codenames stay blocked.
- Fixed generated Vulkan template debug-utils code to compile against Ubuntu packaged Vulkan-Hpp
  headers as well as newer SDK headers.
- Replaced the sample-project poster/link fallback with GitHub uploaded attachment URLs so the
  CUDA Groom Tool and Wetbrush MP4 samples render as inline players on the README page.
- Added a GitHub Pages sample-player page as a fallback/supporting sample view with inline video
  controls and explicit fullscreen buttons.
- Re-encoded README sample MP4s as video-only 720p H.264 files under 10 MB for GitHub-friendly
  uploads and inline playback.
- Added README sample-project videos for CUDA Groom Tool and Wetbrush, with public assets moved under
  `assets/videos/`.
- Tightened active code-map behavior so agents use the architecture index and manifest as the first
  navigation step before code changes, including repos that declare their own maintained map.
- Clarified that target repos with their own maintained maps and repo-local skills are the subsystem
  routing authority, and recorded Wetbrush subagent trigger-lane evidence.
- Moved README code-map details into a dedicated optional section with benefits, invocation examples,
  and enablement behavior.
- Rebalanced README positioning so code maps are described as optional support for durable project
  context, not as a primary reason CppStudio exists.
- Clarified greenfield code-map opt-in: explicit project-creation requests for a code map or
  future-agent map count as acceptance after scaffolding.
- Clarified that code-map routing is part of `cpp-cuda-vulkan-studio`, not a separate skill, and
  added code-map wording to the skill metadata and user relay.
- Added an existing-project code-map readiness protocol and audit mode so agents inspect structure,
  estimate cleanup cost, and ask whether to restructure or preserve layout before enabling maps.
- Documented the code map in the README and explained its purpose for durable project architecture
  context, multi-agent routing, and reduced repeated cold reads.
- Clarified automatic skill relay wording for native C++ GPU/realtime prompts and the distinction
  between copied code-map support files and an enabled maintained code map.
- Added an opt-in CppStudio code-map system with bootstrap and validation scripts, generated-project
  starter map docs, and an enabled maintainer map for this repo.
- Added the requirement that future remote pushes include a concise changelog entry for tracked
  user-visible, validation, CI, generated-template, donor-library, install, or sync changes.
