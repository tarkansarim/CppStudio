# CppStudio Core

CppStudio uses progressive enforcement. Keep model judgment active during
ordinary work. Add process only when current evidence shows it is needed.

## Active Model

For each work item, use:

`base invariants + one process state + relevant technical overlays`

Process states are `Standard`, `Investigative`, and `Governed`.
Recovery is an incident state that temporarily replaces the active process
state. It does not stack a second process bundle over Standard, Investigative,
or Governed. State changes never remove base invariants or active technical
overlays.

Read `modules/technical-overlays.md`, then load only the overlay modules that
match the task. Do not load every CppStudio module.

## Base Invariants

These apply in every state:

- Respect user, repository, scope, authority, and provider boundaries.
- Inspect the exact owning code and direct caller before editing.
- Use the repository's canonical build, launch, test, and install paths.
- Preserve user and project state. Use rollback protection proportional to
  actual consequence and restore difficulty.
- Do not silently change semantics, provenance, persistence, validation class,
  hardware lane, or quality.
- Match evidence to the claim. Visible, realtime, interaction, performance,
  and hardware claims need evidence from the path being claimed.
- Keep Vulkan/CUDA ownership, synchronization, lifetime, device identity, and
  resource transitions deliberate whenever those contracts are touched.
- Stop once the agreed acceptance evidence passes. Extra available checks are
  not automatically required.

## Consequence Check

Task size and consequence are separate.

- `tiny/direct`: bounded, understood, reversible, low-consequence work with
  focused verification.
- `guarded-direct`: bounded work whose failure could materially affect GPU
  lifetime or synchronization, durable contracts, user data, paid actions,
  security, persistence, or shipped behavior. Add a short pre-mortem, caller
  trace, focused tests, exact proof, and proportional rollback evidence. Do not
  create a Planning Harness packet by default.

A one-line semaphore, descriptor-lifetime, device-selection, capability, or
persistence change may be `guarded-direct`.

## Process State Selection

### Standard

Default for bounded, understood work. Load `modules/process/standard.md`.

### Investigative

Use when ownership, API behavior, the correct oracle, architecture, dependency,
or acceptance evidence is unclear; when measurement is necessary; or after one
focused hypothesis fails. Load `modules/process/investigative.md`.

### Governed

Use for connected work items, cross-subsystem architecture, uncertain shared
ownership, nontrivial multi-agent integration, repeated unexplained failures,
real compaction risk, or an explicit Planning Harness request. Load
`modules/process/governed.md`.

### Recovery

Enter from any process state when an Investigative hypothesis and canonical
rerun still leave contradictory evidence, speculative patches accumulate, the
lane cycles through wrappers or restarts, scope drifts, or required tools are
repeatedly worked around. Load `modules/process/recovery.md`.
One failed Standard hypothesis moves to Investigative, not Recovery. Recovery
ends when the incident is reconciled; classify the next work item again instead
of keeping Recovery active.

## Focused Attempt

A focused attempt is:

1. one named product or engineering hypothesis;
2. one bounded implementation change that tests it; and
3. one run through the canonical acceptance path.

Compiler errors, corrected command syntax, unavailable optional tools,
read-only diagnostics, and probes without a product hypothesis do not count as
failed implementation attempts.

Escalate based on unchanged or contradictory acceptance evidence, not elapsed
time alone. Time is a signal to reassess, never the sole reason to load more
process.

## Transitions

Record only state transitions, in chat or the existing Planning Harness control
log:

```text
CppStudio state: Investigative; reason=<evidence-backed reason>; evidence=<artifact or command>; exit=<condition>
```

Do not create a separate state file, watchlist, ledger, or packet solely to
record a transition.

Escalation does not authorize scope expansion, semantic changes, paid actions,
destructive actions, packet approval, or a new authority boundary. Those still
need the appropriate user decision.

## Planning Ownership

Planning Harness is the sole owner of durable roadmaps, milestones, work
packages, work items, approval, continuation, and completion state.

CppStudio contributes engineering intake: code ownership, donor or official
contracts when relevant, GPU lane, synchronization and lifetime risks,
profiling needs, technical acceptance evidence, and integration boundaries.
CppStudio must not create a parallel Level 0-5 authority, mandatory per-slice
packet hierarchy, or separate universal watchlist.

## Review And Telemetry

- Do not run reviews on a fixed slice cadence.
- Reuse a completed review while its protected contract and material risk
  boundary remain unchanged.
- Run a fresh review only for a materially changed risk boundary, unresolved
  contradictory evidence, or explicit user request.
- Phase telemetry is a Recovery diagnostic. It is not required in every worker
  reply or ordinary closeout.

## Preserved Strict Doctrine

The prior strict CppStudio doctrine remains at
`modules/process/strict-doctrine-reference.md` for Recovery and historical
traceability. Standard, Investigative, and Governed must not read it. In
Recovery, use `modules/process/strict-doctrine-index.md` to open only the
section that addresses the observed incident. Load the full reference only when
the user explicitly requests the former strict protocol.
