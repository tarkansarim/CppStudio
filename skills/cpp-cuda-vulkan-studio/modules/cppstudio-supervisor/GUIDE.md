# CppStudio Supervisor

Use this module only when supervising C++ GPU workers. The worker owns target
repository implementation unless the user explicitly reassigns it.

## Supervisor Duties

- Confirm the worker is on the correct work item and source owner.
- Select the current CppStudio process state from `../studio-core.md`.
- Verify implementation and live-behavior claims against primary evidence.
- Keep user constraints, scope, and integration ownership clear.
- Route shared CppStudio, Planning Harness, or tooling defects to their owning
  source instead of encoding generic process rules in the target app.
- Interrupt or redirect a worker that is on the wrong task, accumulating
  invalid output, or blocking correction.

Worker summaries are evidence pointers, not proof. Inspect only the decisive
artifacts needed for the claim; do not repeat a bounded worker investigation
when its citations and evidence pass spot-checks.

## Process States

- `Standard`: bounded worker change with focused verification.
- `Investigative`: one uncertainty, one hypothesis, one canonical proof route.
- `Governed`: Planning Harness owns connected work items and integration.
- `Recovery`: freeze speculative work and reconcile contradictory evidence.

Record transitions only. Do not require a separate supervisor watchlist when
Planning Harness already owns durable constraints.

## Reviews

Do not use a fixed review cadence. Run a fresh review only when:

- the protected contract or material risk boundary changes;
- evidence remains contradictory after canonical replay;
- integration crosses uncertain shared ownership;
- a prior blocking finding remains unresolved; or
- the user explicitly asks.

Reuse valid review evidence while its contract remains stable. A reviewer does
not gain authority to expand scope.

## Telemetry

Phase telemetry is optional in ordinary supervision. Activate it in Recovery
only when timing or cycle location is genuinely unknown and the telemetry can
decide what to stop or change. Do not require timing markers in every worker
reply.

The existing `scripts/slice_phase_report.py` remains available for that
diagnostic.

## Closeout

A worker closeout needs only:

- implemented scope and changed-file status;
- exact build/test/proof commands and decisive artifacts;
- canonical launch, binary, hardware, or runtime provenance when relevant;
- unresolved concerns or user decisions;
- commit status when a commit belongs to the workflow.

Add overlay-specific evidence only when that overlay was active. Do not demand
the full historical closeout checklist for every worker lane.

## Preserved Strict Reference

The previous detailed supervisor protocol remains at
`references/strict-supervisor.md`. Use it selectively during Recovery or when
the user explicitly requests the former strict supervision protocol.
