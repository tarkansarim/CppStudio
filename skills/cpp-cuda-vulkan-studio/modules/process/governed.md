# Governed Process

Use Governed for work that needs durable coordination.

## Planning Owner

Load `agent-planning-harness`.
Planning Harness is the only durable planning authority. Use its Work Package
and Work Item structures; do not create a parallel CppStudio planning
hierarchy.

CppStudio supplies only the engineering inputs needed by that packet:

- owning subsystems and direct contracts;
- active Vulkan, CUDA, GUI, format, performance, or code-map overlays;
- donor or official-source decisions that materially shape implementation;
- synchronization, lifetime, data, and integration risks;
- canonical build, launch, profile, and acceptance paths;
- multi-agent ownership and integration boundaries.

## Procedure

1. Bind the current work to one active Planning Harness work item.
2. Keep one canonical proof lane and one active implementation owner per
   overlapping source surface.
3. Use a rollback anchor appropriate to actual integration and restore risk.
4. Persist only decisions and constraints that must survive handoff or
   compaction.
5. Review only at a material architecture, integration, or risk-boundary
   change. Reuse valid prior review evidence.
6. Run enabled code-map checks only when the map is active and the work affects
   its routes or semantics.

## Prohibitions

- No separate CppStudio Level 0-5 authority.
- No mandatory CppStudio packet for every implementation slice.
- No universal watchlist alongside the Planning Harness packet.
- No fixed two-slice or three-slice review cadence.
- No phase telemetry unless the lane enters Recovery and telemetry can answer
  the observed incident.
- No reviewer-driven scope expansion without explicit user approval.

Classify each new work item again. Governed does not make every later edit
Governed automatically.
