# Changelog

All notable CppStudio changes should be recorded here before pushing to remote.

## Unreleased

- Hardened viewport-session proof for stroke-like visible bugs. Agents must now create or replay a
  human-input UI session through the real viewport/canvas/widget path, with press/contact, multiple
  held move samples, release/finalization, pointer-path-to-hit/edit coverage assertions, and direct
  material/overlay/product-surface checks when those are reported symptoms. Generic revision,
  checksum, nonblank screenshot, product-score, backend endpoint, or one-point dab evidence is
  explicitly supporting-only, and real OS input must not be mislabeled as offscreen/non-disruptive.
- Fixed the hosted validation failure in `scripts/rollout_to_codex.sh` by replacing a single-item
  quoted `for` loop with a direct user-AGENTS relay snippet existence check. The CI ShellCheck lane
  now reproduces locally with the same `shellcheck scripts/*.sh` and
  `shellcheck skills/cpp-cuda-vulkan-studio/scripts/*.sh` commands.
- Claimed `modern-cpp-cmake`, `cuda-kernel-authoring`, and `gpu-profiling-workstation` as
  CppStudio-owned source skills. Rollout now installs them as exact bundled snapshots with
  `.skill-source` provenance and compact discovery descriptions instead of patching installed-only
  companion copies.
- Deferred bundled skill discovery detail out of frontmatter descriptions and into source skill
  bodies. Skill-load hygiene now enforces compact CppStudio startup descriptions, while rollout
  preserves full trigger/routing detail for C++ GPU, planning, control-harness, watchlist, GUI,
  viewport-session, and Vulkan synchronization skills.
- Claimed `vulkan-compute-sync` as a bundled CppStudio-owned skill instead of an external companion
  donor-link target. Rollout, watch, validation, manual install docs, package-integrity docs, and the
  code map now include it as a managed auxiliary skill installed from this repo.
- Hardened substantial greenfield planning handoff: after donor/web research and the pre-plan
  research brief, workers must stop with an explicit Plan-mode request instead of asking unresolved
  template, GUI/input stack, authoring-model, GPU-lane, code-map, dependency, donor, or validation
  decisions inline in normal chat. Supervisor, replay, or test prompts to "write the plan" or "use
  recommended defaults" no longer waive that gate.
- Hardened sculpt/artist-tool interaction gates after a live-stroke miss. The sculpting-brush donor
  route and Blender study-only profile now explicitly require live-contact stroke semantics:
  deformation or semantic state must change during held mouse/stylus contact before release, while
  release finalizes the undo/replay transaction. Viewport-session docs, generated validation docs,
  project planning, and GUI/HUD guidance now require mid-gesture proof for live artist tools and a
  peer-tool visual quality contract so debug-looking greenfield UIs cannot pass as product surfaces.
- Tightened GUI stack selection for product-like artist tools. High-quality standalone tools that
  name polished peers such as ZBrush, Mudbox, Maya, Houdini, Substance, Nuke, Unreal Editor, or
  Blender now route as polished desktop artist applications before generic realtime utilities, so
  Qt-style shells are preferred when available and Dear ImGui is kept to overlays, diagnostics, or
  explicitly approved immediate-mode product surfaces.
- Made user-facing verification a first-class acceptance gate for interactive features. Planning,
  GUI/HUD, control-harness, and viewport-session skills now require the real visible control,
  interaction shape, committed state, and visible result before a feature or bug fix can be claimed;
  hidden CLI recorders, backend commands, fake-host smokes, OSTM jobs, JSON state, or nonblank
  screenshots are supporting evidence only. Generated viewport-session scaffolds now record button
  state and validate held-button move samples so continuous gestures cannot be represented by a
  press/release-only smoke.
- Added a bundled `viewport-session-testing` skill plus generated-project runtime scaffold for
  app-owned UI/viewport session recording and replay. New scaffolds include a host-adapter contract,
  fake-host smoke test, copied `run_viewport_session_smoke.py` helper, viewport-session docs, CTest
  labels, code-map routing, and before/after visible bug proof guidance so agents do not rebuild the
  same record/replay lane per project.
- Tightened donor-backed planning so Level 3 coverage now requires explicit donor feature
  disposition. Agents must inventory important features from donor shaders, brushes, renderers,
  solvers, UI patterns, importers, optimizers, or subsystems and mark each included, deferred,
  rejected, or blocked with reasons, owners/return conditions, and validation signals before source
  work; silent donor omissions are plan failures. Shader and donor-code use now requires a pre-plan
  breakdown of stages, passes, IO, descriptors/uniforms, spaces, variants, states, quality features,
  edge cases, and validation signals so agents cannot skim donor code and then plan from memory.
- Reframed `important-instruction-ledger` as an active per-slice watchlist instead of passive
  user-note capture. New entries now target `docs/agent-context/SLICE_WATCHLIST.md` / JSONL and
  describe what supervising or direct agents must watch, verify, block, or reject during each slice;
  legacy `IMPORTANT_USER_INSTRUCTIONS.md` files remain compatibility pointers.
- Added the original bundled `important-instruction-ledger` skill and script for durable supervision
  constraints; the active path is now the slice-watchlist behavior above.
- Hardened slice supervision so substantial implementation slices require a matching Level 4
  readiness packet as a primary artifact; a worker reading the plan, passing the planning guard, or
  reporting green validation no longer substitutes for detailed per-slice planning.
- Refreshed README Recent Commit Highlights so the main page now lists the latest CppStudio hardening
  commits as stable entries instead of leaving them only inside the aggregate `current` summary.
- Added Codex skill-load hygiene validation so repo skill roots reject backup-looking
  files/directories, duplicate loaded skill names, and oversized description metadata before rollout
  or validation can claim a clean source package; installed user-level roots are audited visibly by
  default and become fatal with `CPPSTUDIO_STRICT_USER_SKILL_LOAD=1`.
- Added a six-level planning depth contract for substantial software: intake/context,
  research/ceiling, whole-product scaffold, donor coverage and quality contract, slice readiness,
  and implementation/closeout proof. Serious native C++ GPU, artist, game, VFX, DCC,
  simulation-editor, and technical-art tools now default to donor-coverage depth before source files
  are created, so high-salience donor and peer-tool expectations must be mapped as included,
  deferred, rejected, or blocked with reasons and validation signals before implementation.
- Added capability-priority and parallelization planning requirements so agents decide how much to
  build first, what completeness threshold unlocks the next capability, which shared contracts must
  be frozen, and which C++/GPU/UI slices should remain sequential.
- Added a generic primary-visible-loop planning gate for interactive artist/game/VFX/DCC tools:
  agents must derive the core user action from donors and peer tools, prove that visible loop before
  secondary feature breadth, and treat fixture-only scaffolding or extra modes as blocked until the
  loop has input-to-result evidence.
- Added a concrete-proof-object gate for visible/domain slices: Level 4 readiness now has to name
  the actual primitive, scene, generated asset, graph, dataset, or interaction target that proves the
  loop, instead of hiding behind vague "sample object" or "generated target" wording.
- Added a shared-tool-substrate gate for related tool families so the first real tool must be solid
  and common behavior such as selection, input mapping, pressure/falloff, undo/replay, harness
  readback, and validation is factored once before sibling tools are added.
- Clarified the sculpt-brush donor profile so agents study Blender brush behavior without blindly
  exposing Blender-specific brush names when another peer family defines the target UI vocabulary.
- Added a generic GPU feature regression protocol: agents must prove the exact requested feature lane
  on the target device before hiding, disabling, downgrading, or changing UI/tests around a reported
  capability failure, use historical comparison when the user says a feature used to work, and treat
  stale engineering memory as challengeable evidence rather than authority.
- Made enabled-code-map maintenance a strict worker-owned closeout gate: source slices should run
  `check_code_map_drift.py --require-enabled --strict-review`, then update the map, launch the
  code-map sidecar, or explicitly acknowledge a reviewed no-map-change case before staging.
- Cleaned up the enabled-code-map drift checker so the guarded sidecar/action instruction is printed
  only for unresolved map-maintenance cases, not after an explicit reviewed no-map-change
  acknowledgement.
- Routed enabled-code-map drift and no-map-touch semantic review output toward the guarded
  `agent-tmux codex-code-map-sidecar <repo> <anchor> [focus]` helper, with validation coverage and
  generated-project docs so sidecar maintenance is surfaced as an actionable command instead of only
  prose.
- Added a supervised-worker artifact audit and planning-packet lifecycle gate: worker summaries are
  now only pointers, supervisors must inspect primary planning/code-map/diff/validation/OSTM/UI
  artifacts before judging a plan or slice, stale "planning only" packets must be reconciled after
  source work lands, and offscreen jobs must reach a terminal state with clearly labeled proof
  surfaces before they count as evidence.
- Added a quality-preserving research failure gate: when a searched source cannot be opened, agents
  must record the URL/error and may continue only when equivalent primary or donor evidence still
  covers the decision; critical missing sources now block planning instead of causing silent
  workarounds or weaker research artifacts.
- Surfaced the latest code-map sidecar commits as explicit README Recent Commit Highlights before
  remote push, so the main page shows those changes as stable commit entries instead of hiding them
  only inside the aggregate `current` item.
- Added a bounded code-map sidecar lane for enabled-map repos: agents may offload map-only updates
  from a fixed Rewind checkpoint, temporary git anchor, commit, worktree copy, or archive when drift,
  long-running slices, ownership/data-flow changes, moved routable files, or stale subsystem docs
  justify it, while the original worker must reconcile the sidecar output and rerun drift/schema
  validation on the current tree before the verified slice commit.
- Pinned checked-in installed-path trigger evidence to include the code-map sidecar case so validation
  cannot silently regress to the earlier planning/harness/grooming/sculpting evidence set.
- Hardened stalled visible-bug and artist-tool debugging: after two focused attempts or about
  20 minutes without direct symptom improvement, agents must stop local patching, reopen the target
  code map and donor routes, record a donor realignment note with failed hypotheses and keep/revert
  decisions, and only then continue with the next smallest proof.
- Made automated GUI/windowed proof OSTM-first when the offscreen-test-manager skill or CLI is
  available, with direct foreground launches limited to explicit manual inspection or bounded
  launch-command proof instead of repeated automated debugging loops.
- Strengthened the sculpting-brush route so stalled brush selection, viewport hit offsets, stroke
  behavior, pressure/falloff, masks, high-poly dirty uploads, and palette bugs must realign with the
  Blender Sculpt Brushes study-only profile and prove pointer/control-to-committed-result behavior.
- Hardened visible GUI bug proof so agents must state when they are UI-blind, require actual
  visible-surface evidence for UI fixes, and stop presenting harness-only/JSON-only work as progress
  on a user-visible symptom after a blocked proof-route attempt.
- Added a user-reported bug before/after proof gate: agents must reproduce the exact reported
  behavior first, save before evidence, rerun the same or equivalent scenario after the fix, compare
  the reported symptom directly, and refuse to present a fixed claim when the evidence is identical,
  self-confirming, backend-only for a visible bug, or too narrow for the report. Visible GUI/windowed
  bug proof now explicitly routes through Sonar readback, OSTM/project launchers, and Rewind rollback
  anchors when those tools are available.
- Tightened desktop GUI launch verification so agents must prove the exact documented command opens
  the intended visible, focusable app window, reject terminal-title or stale-window matches, read back
  workspace/geometry/window state, and confirm harness responsiveness before claiming launch success.
- Added explicit GUI interaction scenario requirements so UI-heavy tools test real visible control
  clicks, event-to-state latency, viewport/canvas pointer mapping, device-pixel-ratio handling,
  committed hit/edit points, and fresh visual proof instead of relying on backend commands or
  nonblank launch screenshots.
- Hardened target-project commit-origin guidance so verified-slice commits use only
  `Commit-Origin: agent-slice` or `Commit-Origin: user-requested`, not provider-name values.
- Added adaptive task-list realignment guidance so agents can revise stale implementation plans when
  evidence changes the trajectory, while still pausing for product, stack, scope, dependency/license,
  or explicit user-constraint changes.
- Updated project-level maintainer instructions so normal user-level publishing uses
  `rollout_to_codex.sh`, while `sync_to_codex.sh` is limited to dry-run, diagnostic, or explicitly
  single-skill sync cases.
- Added checked-in installed-path trigger evidence for recent planning, missing-donor promotion,
  agentic-control-harness, grooming, and sculpting routes.
- Fixed donor validation and freshness auditing so plural or wrapped `Sources:` metadata with
  multiple URLs is parsed for both route/profile matching and freshness reports, added fixtures for
  wrapped source-route mismatches, added portable installed-path trigger result templates, and marked
  the new Blender sculpt profile with `Last checked` metadata.
- Added matrix-anchored trigger-result artifact validation so recorded fresh-agent `pass` evidence
  must include every matrix-rendered expected opened path, avoid forbidden paths, include selected
  skills, carry run metadata, cannot self-edit the expected/forbidden path contract, cannot
  downgrade checked-in installed evidence out of `portable-installed` mode, and cannot silently drop
  the claimed case set.
- Hardened midstream major feature requests so agents reopen the research/planning gate and update
  planning artifacts, donor notes, dos/don'ts, and decision records instead of answering from
  chat-only research or coding from memory.
- Clarified missing-donor promotion so agents must capture strong web-discovered donors locally, then
  promote them into the CppStudio source donor library when reusable/global promotion is requested;
  installed user-level donor files remain rollout targets, not hand-edited sources.
- Added a sculpting-brush donor route and Blender Sculpt Brushes study-only profile so ZBrush-like
  high-poly artist tools start from source-backed brush behavior, Paint BVH-style acceleration,
  topology-mode caveats, and performance donors before implementation.
- Documented the mandatory planning research artifact in the README, including project-specific
  app/domain and GUI/product-surface dos and don'ts before implementation starts.
- Added a mandatory `Project Dos And Don'ts` section for substantial greenfield planning artifacts,
  covering both app/domain rules and GUI/product-surface best practices with source evidence and
  validation signals.
- Hardened greenfield code-map startup so substantial new projects must accept, decline, or
  explicitly defer maintained code-map setup before the first source/build/app/test/docs slice.
- Added durable greenfield research guidance so substantial native GPU project planning writes
  `docs/planning/RESEARCH_BRIEF.md`, records donor candidates explicitly, and separates existing
  donor routes from new reusable donor material before implementation.
- Added an SDL3 platform/pen-input donor profile and hardened artist-tool planning so brush, sculpt,
  paint, groom, terrain, texture, and other stroke tools evaluate pressure-capable input routes
  before accepting mouse-first stacks.
- Added supervised-worker interrogation guidance so unclear tmux/subagent decisions are questioned
  and checked against transcripts/files before CppStudio rules or donor gaps are inferred.
- Hardened greenfield CppStudio project startup guidance so Codex workers initialize usable Git
  before verified-slice commits and treat read-only `.git` mountpoints as sandbox/tooling blockers
  rather than project state to chmod or unmount.
- Made generated-project scaffolding Vulkan-only by default: CUDA files, presets, docs, code-map
  routes, and helper scripts are omitted unless the agent explicitly asks
  `scaffold_gpu_cpp_project.py --gpu-lane cuda` or `--gpu-lane cuda-vulkan`; validation now checks
  both the default Vulkan-only lane and the explicit CUDA-capable lane.
- Fixed generated-project code-map bootstrap so GPU optimization docs are routed before the first
  baseline commit, and added validation coverage for drift-checking a fresh git-initialized scaffold.
- Required the three dedicated code-map trigger-regression cases by name and made validation render
  each case individually, preventing aggregate `code-map` checks from hiding deleted scenarios.
- Added checked-in installed-path fresh-agent evidence for the new code-map trigger cases.
- Hardened rollout rollback safety so bundled auxiliary skill targets, companion skill
  directories/files, and the user `AGENTS.md` relay target are rejected when symlinked before
  rollback snapshots are created.
- Added dedicated code-map trigger-regression cases for existing-project bootstrap,
  enabled-map maintenance closeout, and routing-smoke proof, plus static validation for the new
  `code-map` tag.
- Clarified README Recent Commit Highlights so the `current` entry is explicitly an aggregate
  high-churn summary while older entries use stable commit ids.
- Made rollout guidance unambiguous for bundled skill changes: normal installed updates now point to
  `rollout_to_codex.sh`, while `sync_to_codex.sh` is documented as a single-skill diagnostic path.
- Expanded GUI and harness trigger-regression expectations so static validation now guards UI
  convention tables, icon/text affordance checks, screenshot scorecards, exact readiness invariants,
  route inventory reconciliation, and action inventories.
- Clarified trigger-evaluation packs so forbidden paths are no-touch paths, including reads,
  searches, stats, listings, and existence checks.
- Added a native GUI product-surface gate requiring UI convention tables, icon/text affordance checks,
  and screenshot scorecards against donor or peer-tool conventions before agents call artist-tool UI
  product-ready.
- Tightened agentic control-harness closeout so readiness booleans must prove their exact documented
  invariant, public route registrations must match control docs/inventories, and UI-heavy apps should
  expose action/affordance inventories when practical.
- Required donor/provenance closeout for risky backend, renderer, GUI/editor, solver, harness, or
  authoring-model migration slices.
- Routed root ignore policy through the public docs/CI code-map subsystem and ignored local Rewind
  metadata so generated checkpoint config does not pollute package commits.
- Required agentic control-harness roadmap/readiness readback to advance when verified slices
  satisfy prerequisites, so machine-readable `next_required_slice`, blocker, and eligibility fields
  do not keep sending future agents back to already-proven work.
- Clarified Vulkan runtime readiness so realtime viewport preflights reject CPU/software Vulkan such
  as llvmpipe/Lavapipe by default, keep those paths diagnostic-only unless explicitly opted in, and
  classify loader/ICD/device/queue/surface failures before renderer edits.
- Tightened target-slice execution discipline so agents stop broad orientation after a bounded
  code-map/donor-routed slice is named, and clean or explicitly report interrupted partial edits
  before continuing.
- Made enabled-code-map closeout more explicit: agents must run both drift and schema validation
  before staging or committing, and must not treat schema validation as a substitute for drift checks.
- Clarified donor-first routing so missing, stale, or too-generic donor coverage requires explicit
  web/upstream primary-source research before designing new components, subsystems, or broad
  product-shape changes.
- Hardened existing-project code-map enablement so it installs missing repo-local validation/drift
  wrappers, routes flat app-owned source files such as UI panel/controller headers through app-core
  globs, permits optional unmatched primary-path globs, and preserves leading-dot paths during drift
  checks.
- Added a GPL-safe Blender curves groom-brush study-only donor profile and routed grooming-brush
  prompts to it before runtime/rendering hair donors.
- Added a code-map drift checker and pre-commit maintenance gate so enabled-map projects surface
  changed source/header/shader/script/docs paths that are not covered by subsystem routes before an
  agent commits a verified slice.
- Hardened code-map validation so manifest root `state` and `router_doc` fields are enforced as
  strict repo-relative routing API fields.
- Cleaned up negative trigger-matrix controls so they use only forbidden paths, plus added
  structured trigger-eval result templates.
- Made manual managed-skill install snippets transactional across all bundled skills and added an
  optional report-only donor freshness audit.
- Updated README highlights and sample-project media links so the front page remains scannable and
  tracked local video fallbacks are visible.
- Collapsed older README Recent Commit Highlights behind a GitHub details expander so selected
  recent entries are visible by default.
- Clarified that maintained code-map setup verification includes a read-only subagent or
  fresh-session routing smoke when available, not only schema validation.
- Tightened code-map completion criteria so agents distinguish structural validation from fresh-agent
  routing proof, grade routing smokes as pass/partial/fail, report instruction-file drift separately,
  and label audit-backed presets/scripts as pre-map infrastructure rather than hiding them inside
  code-map setup.
- Tightened existing-project code-map opt-in so agents must run the non-destructive readiness audit,
  present concrete findings, evidence paths, actual restructuring needs, and cleanup cost, and only
  then ask the user whether to restructure, preserve layout, or decline.
- Added a Sortie assistant-pack adoption audit covering 22 audited skills, classifying direct
  doctrine, partial cherry-picks, and redundant Sortie-specific mechanics without importing Sortie
  runtime behavior.
- Tightened GUI and control-harness guidance so broad interaction rewrites require a source/build
  checkpoint, mutation endpoints must prove committed state before returning `ok=true`, and
  snapped/clamped command tests assert post-validation values.
- Broadened validation-audit shell guidance so agents quote script-fragment and regex searches with
  embedded quotes, `$`, or other shell metacharacters, not only markdown backticks.
- Tightened agentic control-harness thread-boundary guidance so UI/renderer readback, toolkit action
  state, and visual capture run through the safe GUI/render thread instead of direct server-thread
  calls.
- Added hard-reset guidance for repeated visual-capture/render-scheduling failures so agents must
  write an evidence ledger and keep/revert decision before stacking more patches.
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
