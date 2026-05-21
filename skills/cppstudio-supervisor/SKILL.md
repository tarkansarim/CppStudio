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
- Use `agent-tickets` when the fix belongs to another repo, reusable skill, wrapper, hook, or
  owner agent.
- Use `verification-before-completion` before saying a worker fix is complete.

## Supervision Rules

1. Verify the target repo, provider, session, and chat identity before sending work.
2. Do not patch another repo directly when supervising it. Route implementation to that repo's owner
   worker unless the user explicitly assigns this agent as the owner.
3. Read the primary planning artifact before approving, rejecting, or judging plan quality. Acceptable
   artifacts include a plan packet, `PLAN.md`, ticket handoff, watchlist entry, or worker-written
   slice plan. If no artifact exists, report that evidence gap instead of inferring from chat.
4. Poll until the worker has actually stopped, reached a blocker, or produced closeout evidence. Do
   not summarize a moving worker as finished.
5. If the worker's decision is unclear, interrogate it before concluding why it acted that way. Ask
   for the exact skills, donor routes, web/upstream sources, plan artifacts, and verification commands
   it used.
6. If the worker drifts from the approved slice, stacks failed patches, skips donor realignment, skips
   visible proof, or claims unverified fixes, stop the lane and either redirect it or file a reusable
   CppStudio gap.
7. When a worker claims Rewind-backed causal proof, verify Rewind readiness, the exact pre-decision
   checkpoint or branch point, paired chat evidence when conversation matters, preserved-scope drift,
   and the replay delta. Do not accept a forward correction as rewind evidence.

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
- exact validation commands and artifact IDs, including OSTM/viewport/session evidence when visible
  behavior is involved;
- unresolved concerns classified as resolved, unresolved, not-tested, or user-decision-needed;
- whether any reusable CppStudio rule, donor route, code-map rule, or skill needs hardening.

If the closeout is missing those basics, ask the worker for them before telling the user the lane is
done.
