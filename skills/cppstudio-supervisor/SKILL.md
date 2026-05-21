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
