---
name: cppstudio-supervisor
description: Use when supervising tmux/subagent/repo workers for CppStudio-backed native C++ GPU work, reviews, polling, fix routing, or closeout.
---

# CppStudio Supervisor

Use this skill only when acting as a supervisor for other agents or workers. Do not load it for
ordinary solo implementation in a CppStudio-backed project.

## Scope

This skill covers:

- launching, resuming, nudging, polling, or interrogating tmux-managed Codex/Claude workers;
- supervising CppStudio-backed implementation slices in another repo;
- reviewing worker plans, checkpoints, Rewind probes, code-map sidecars, and closeout evidence;
- routing adversarial-review or `codex exec` findings back to the owning worker;
- deciding whether a worker mistake points to a CppStudio reusable-rule gap.

For normal direct source edits, use the relevant project, CppStudio, donor, GUI, profiling, or
validation skills instead.

## Required Companion Skills

- Use `agent-tmux-control` before contacting terminal workers. Prefer guarded `agent-contact` or
  `agent-tmux` helpers over raw PTY input.
- Use `important-instruction-ledger` when the supervised slice has active user constraints,
  watchpoints, or closeout gates that must survive compaction.
- Apply the closeout evidence and verification rules in this skill before saying a worker fix is
  complete. If a dedicated `verification-before-completion` skill is installed, load it as an extra
  gate; do not require that absent skill name to exist.

## Supervision Rules

1. Verify the target repo, provider, session, and chat identity before sending work.
2. Do not patch another repo directly when supervising it. Route implementation to that repo's owner
   worker unless the user explicitly assigns this agent as the owner.
3. Read the primary planning artifact before approving, rejecting, or judging plan quality. Acceptable
   artifacts include a plan packet, `PLAN.md`, user-level routing record, watchlist entry, or worker-written
   slice plan. If no artifact exists, report that evidence gap instead of inferring from chat.
4. Poll until the worker has actually stopped, reached a blocker, or produced closeout evidence. Do
   not summarize a moving worker as finished.
5. If the worker's decision is unclear, interrogate it before concluding why it acted that way. Ask
   for the exact skills, donor routes, web/upstream sources, plan artifacts, and verification commands
   it used.
6. If the worker drifts from the approved slice, stacks failed patches, skips donor realignment, skips
   visible proof, or claims unverified fixes, stop the lane and record a reusable CppStudio gap or
   follow the user-level cross-repo routing rules.
7. If a supervisor correction cannot be delivered because `agent-contact` refuses while the worker is
   busy, keep that correction as an explicit pending blocker. Do not treat the worker's later closeout
   or commit as acceptable until the transcript, diff, and committed files are audited against the
   pending correction. If the worker already committed before receiving the correction, route a
   follow-up fix to the owning worker before continuing the lane.
8. When a worker claims Rewind-backed causal proof, verify Rewind readiness, the exact pre-decision
   checkpoint or branch point, paired chat evidence when conversation matters, preserved-scope drift,
   and the replay delta. Do not accept a forward correction as rewind evidence.
9. Require Agent-Planning-Harness escalation when a supervised lane outgrows ordinary chat or
   watchlist control. Before the next implementation nudge, make the worker create or update a
   planning packet and validate it when the lane is long-running or multi-slice, an adversarial
   review finds four or more actionable issues, findings cross multiple subsystems, two focused
   attempts fail, a long-lane acceptance gate fires, or a midstream request changes architecture,
   product shape, validation strategy, or slice order. The packet must capture current repo state,
   accepted user decisions, review findings, donor/source anchors, open blockers, high-level slice
   scaffold, next slice readiness, acceptance gates, rollback/checkpoint state, and owner/supervisor
   responsibilities. Do not keep nudging implementation from transcript memory after this gate fires.
10. When a worker adds, ports, or changes shader, material, light, renderer, simulation, brush, cache,
   performance, import/export, or runtime parameters, require parameter-surface closure before
   approving the slice. The closure must account for backend/runtime storage, defaults/clamps,
   persistence/state, CLI/config/API, GUI or inspector controls for UI products, harness/readback,
   and tests. If the worker only proves backend, CLI, JSON, or harness state for a product-facing UI,
   treat closeout as incomplete and route a fix before reporting success. If the proof is a UI-state
   inventory, require a matching visible screenshot or toolkit readback showing the actual panel,
   section labels, control labels, enabled states, and current/default values as reachable by a user;
   explicitly classify controls that are below scroll, collapsed, clipped, hidden behind a mode, or
   absent. Do not accept a parameter-surface closeout when the visible screenshot still shows only old
   controls, even if JSON contains new ids.
   For donor-derived shader/material/light parameter surfaces, visible wiring proof is not enough.
   Require a donor parameter inventory before accepting closeout: list the donor source files and line
   anchors, enumerate each artist-facing or runtime-significant donor parameter/block/keyword/mode,
   and compare every item against the target UI, CLI/config, model/state, runtime payload, and
   validation readback. Each donor parameter must be classified as implemented+visible, implemented
   but hidden/mode-gated with a visible path, intentionally folded into a preset with donor-backed
   reasoning, intentionally out of scope with return conditions, or missing. If the donor exposes
   secondary lobes, tints, shifts, transmittance, absorption/melanin modes, roughness variants,
   visibility/scattering sources, or quality/sample controls, do not accept a closeout that only
   proves the primary/default sliders. A live widget oracle proves wiring for the controls it touches;
   it does not prove the donor parameter surface is complete.
   For user-reported UI/control-surface failures, the supervisor must personally compare the
   worker's before and after visible artifacts against the user's reported surface before accepting
   closeout. Hidden widgets, mode-gated controls, off-scroll controls, JSON-only ids, model-only
   state, or a startup oracle that changes controls programmatically after launch do not prove that
   the default user-facing panel is correct. If the user reports "I only see these controls/buttons",
   require an initial repro screenshot matching that visible set, then an after screenshot from the
   exact user-facing launcher that shows the corrected default surface or explicitly shows the
   required mode/scroll path. Runtime capability buttons such as DLSS, upscalers, denoisers,
   debug/fallback toggles, and unsupported GPU features must be classified in the visible artifact as
   enabled-working, disabled-with-reason, hidden-by-capability, or broken; do not accept a closeout
   that ignores stale visible buttons or proves only unrelated shader/model fields.
   Visible reachability is not wiring proof. For product-facing controls, require live mutation
   evidence through the real widget/control path or an app-owned UI action harness that invokes the
   same UI handler. The evidence must show before and after values for the visible control, committed
   model/state, and runtime/readback field such as a shader uniform, light payload, renderer config,
   selected tool, or scene value. Model-only setters, JSON inventories, screenshots, control counts,
   static signal-slot inspection, or harness routes that bypass the product UI are supporting
   evidence only. When a surface has many controls, require a complete control inventory plus
   mutation proof for every newly added or changed critical control and representative proof for each
   repeated control class; classify every unmutated control as deferred, blocked, not-tested, or
   intentionally hidden.
   The visible proof must be through the exact user-facing launcher/command handed to the user, or
   must prove that the tested executable is the same fresh executable selected by that launcher.
   Require the worker to report launcher path, selected executable/build tree, stdout/stderr or state
   evidence for that selection, and a freshness check against the edited UI/runtime source files. If
   stale build trees or unrebuildable preferred binaries remain, the closeout must name them as
   unresolved or show the launcher now refuses/falls back explicitly.

## Slice Phase Telemetry

Use phase telemetry for supervised lanes that are long-running, verification-heavy, performance/UI
or OSTM-heavy, repeated-failure-prone, or visibly thrashing. Do not require it for tiny one-command
checks. The goal is to expose where time is going and which evidence was decisive, not to create a
second project-management burden.

Ask the worker to emit compact marker lines into its normal transcript or a repo-local phase log:

```text
CPPSTUDIO_PHASE event=start phase=research ts=2026-05-30T01:00:00Z note="donor route"
CPPSTUDIO_PHASE event=end phase=research ts=2026-05-30T01:04:30Z status=ok
CPPSTUDIO_PHASE event=end phase=ostm_ui ts=2026-05-30T01:09:00Z classification=required_acceptance ostm_job=7578 artifact=/tmp/ui-proof
```

Recommended phase names are `research`, `donor_route`, `plan`, `edit`, `build_test`, `ostm_ui`,
`ostm_profile`, `viewport_session`, `profile`, `review`, `code_map`, `commit`, and `closeout`.
Verification phases should include one of these classifications:

- `required_acceptance`: evidence needed to accept the user-facing or correctness claim.
- `supporting`: useful corroboration, but not the deciding proof.
- `redundant`: repeated evidence that could likely be trimmed next time.
- `stale_rejected`: a run discarded because the binary, workload shape, viewport size, route, or
  artifact was wrong.
- `failed_tooling`: time spent on broken tooling, parser drift, wrapper failure, or inaccessible
  readback before the actual claim could be tested.
- `not_applicable`: non-verification phase or bookkeeping where classification is only present for
  completeness.

Use `scripts/slice_phase_report.py` from this skill to turn the transcript or phase log into a cost
report:

```bash
python3 ${CODEX_HOME:-$HOME/.codex}/skills/cppstudio-supervisor/scripts/slice_phase_report.py \
  --input /path/to/worker-phase.log \
  --output /path/to/slice-phase-report.md \
  --require-markers
```

When no marker log exists for an already-moving lane, estimate from the transcript only as a
one-time diagnostic and label it approximate. For new verification-heavy lanes, require real markers
before the next implementation nudge so the next closeout can say which phases consumed time, which
validation was decisive, and which checks should be shortened, merged, or rejected earlier.

## Codex Worker Model Defaults

When launching or relaunching a supervised Codex worker for CppStudio-backed native C++ GPU work,
default the worker to extra-high reasoning:

```bash
codex -m gpt-5.5 -c 'model_reasoning_effort="xhigh"' ...
```

Do not enable the fast/priority service tier by default. Add `-c 'service_tier="priority"'` only
when the user explicitly asks for fast, priority, or equivalent faster service on that worker. If an
existing worker is already running at a lower effort level and the next slice is substantive,
relaunch or resume the same thread with `model_reasoning_effort="xhigh"` before nudging it. Verify
the footer or process args after launch; a silent config typo is not acceptable evidence.

## Reviews And Fix Routing

Fresh adversarial reviews and `codex exec` probes are review evidence, not user handoff artifacts.

Reviewers must be fresh-context reviewers. Do not reuse a prior reviewer or fork the implementation
conversation for an unbiased adversarial review unless the user explicitly scopes it as an inherited
context review.

For supervised multi-slice implementation, keep an explicit adversarial-review cadence instead of
waiting for the user to ask. This is a mechanical gate, not a memory reminder.

Before every worker nudge for a new implementation slice:

1. Review the target repo's active watchlist or worker status.
2. Identify the last verified implementation slice, the last post-implementation adversarial review,
   and how many verified implementation slices have landed since that review.
3. If the count is unknown, stale, or absent after any completed implementation slice, treat review
   cadence as due and run a fresh scoped post-implementation adversarial review before approving the
   next slice.
4. If the cadence is due, do not nudge implementation. Send a review/fix packet first and poll
   through closeout.
5. If the cadence is not due, include the current counter in the nudge or supervision notes so the
   next supervisor can see the debt.

Every user-facing supervisor status, worker nudge summary, and worker closeout summary must name the
review-cadence ordinal explicitly, for example `0 slices since last adversarial review`, `1st slice
since last adversarial review`, `2nd slice since last adversarial review`, or `3rd slice since last
adversarial review; review is due before another implementation nudge`. Do not leave the count only
inside a watchlist, hidden transcript, or implied by a commit hash. If the count is unknown, say
`review cadence unknown; review due before next implementation nudge` and run or route the review
before approving more implementation.

After every verified implementation slice closeout:

1. Increment or record the cadence state in the worker status or active watchlist before reporting
   closeout.
2. Record the slice commit, whether it counts as an implementation slice, the last reviewed commit,
   the current `slices_since_review` count, and whether the next nudge is blocked by review cadence.
3. If a post-implementation review was run, reset `slices_since_review` to zero only after concrete
   findings are fixed or explicitly classified as non-actionable.

After every three completed implementation slices, run a fresh scoped adversarial review before
approving the next slice. If the remaining approved plan has four or fewer slices left, tighten the
cadence to every two completed implementation slices. Count only verified implementation slices, not
planning-only packets, plan reviews, pure review fixes, or rollback/checkpoint housekeeping. Reset or
recalculate the cadence when the plan materially changes, and record the last reviewed slice in the
worker status or active watchlist so compaction does not erase the review debt.

Run an immediate post-implementation adversarial review even before the numeric cadence when a slice
touches risky shader/runtime behavior, GPU synchronization, UI interaction, persistence, generated
project infrastructure, or any visible/rendered path where the validation claim could be too narrow.
Plan reviews do not satisfy this post-implementation review gate; they only challenge the intended
slice before code exists.

When a fresh review finds actionable correctness issues inside the supervised worker's approved
scope:

1. Verify the finding is concrete enough to act on, or ask the reviewer/worker for the missing
   source, donor, or test reference.
2. Send a fix packet to the owning repo worker immediately.
3. Poll the worker through implementation, verification, commit when appropriate, and clean closeout.
4. Report the fixed result and evidence to the user.

Pause before routing only when the finding needs product judgment, changes user-visible scope,
requires destructive action, or conflicts with an explicit user constraint. In that case, state the
decision needed and why.

## Closeout Evidence

A supervised worker closeout must include:

- commit hash or explicit no-code-change status;
- dirty-tree status for source files and sensitive instruction files;
- phase telemetry report path or explicit reason it was not captured when the lane was
  long-running, verification-heavy, performance/UI-heavy, or repeated-failure-prone;
- exact validation commands and artifact IDs, including OSTM/viewport/session evidence when visible
  behavior is involved;
- for GUI, viewport, OSTM, or per-frame profiling closeout, row-level full-size timing proof:
  accepted render/resource dimensions, accepted row count, rejected startup/resize row count, and
  the artifact/helper path used to prove that metrics were computed from the full-size viewport
  rather than only from the final UI-state maximized fields;
- exact user-facing launcher command, selected executable/build tree, and stale-binary rejection or
  freshness evidence for any GUI/windowed/visible proof;
- explicit disposition for every supervisor correction, failed contact attempt, or pending concern
  raised during the lane; a committed worker slice must still be audited against those concerns before
  the supervisor accepts it;
- parameter-surface closure evidence for any new or changed runtime/user-adjustable settings,
  including UI/control inventory proof and visible reachability proof when the app has a
  product-facing UI; JSON/model inventory alone is incomplete unless each hidden/deferred control is
  explicitly justified;
- Agent-Planning-Harness escalation state when applicable: packet path, validation command, current
  scaffold/readiness state, or the exact reason escalation was not triggered;
- live UI mutation proof for product-facing controls: before/after visible control values,
  committed model/state values, and runtime/readback deltas through the real widget path or a harness
  action that invokes the same UI handler; inventory, screenshot, model-only API, or static wiring
  evidence alone is incomplete;
- unresolved concerns classified as resolved, unresolved, not-tested, or user-decision-needed;
- whether any reusable CppStudio rule, donor route, code-map rule, or skill needs hardening.

If the closeout is missing those basics, ask the worker for them before telling the user the lane is
done.

When setup, validation, rollout, profiling, or dependency scripts/docs changed, also audit the final
transcript, diff, and committed files for machine-specific absolute paths or workstation wording.
Local absolute paths are acceptable in validation commands and evidence logs, but reusable repo
scripts/docs must use environment variables, config/cache discovery, repo-relative paths, or clear
setup errors instead of hardcoded personal checkout locations.
