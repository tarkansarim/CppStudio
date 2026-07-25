# CppStudio Engineering Intake For Planning

Use this module only for Governed native C++ GPU work or when the user
explicitly requests substantial architecture planning.

Planning Harness is the sole durable planning authority. CppStudio does not own
a parallel Level 0-5 plan, per-slice packet hierarchy, approval gate, or
completion state.

## Engineering Intake

Provide only the C++ GPU facts needed by the active Planning Harness work item:

- target users and the primary visible or computational outcome;
- existing repository and code-map ownership;
- selected Vulkan, CUDA, or explicit interop lane;
- synchronization, lifetime, device, data, persistence, and integration risks;
- architecture or dependency decisions that genuinely remain open;
- relevant official contracts, donors, or current upstream sources;
- canonical build, launch, profiling, and acceptance routes;
- first functional proof and forbidden substitutes;
- parallel ownership boundaries when multi-agent work is justified.

Map these facts into Planning Harness `requirements`, the active Work Item Plan,
and `acceptance`. Do not create duplicate CppStudio control documents.

## Research

Research is decision-driven:

- Use repository facts first.
- Use official API or format sources for external contracts.
- Use focused donor or peer research for an unfamiliar subsystem or real
  architecture choice.
- Use current web research when the decision is version-sensitive or asks for
  the current ceiling.
- Stop researching when the evidence decides the bounded choice.

Do not require an extensive web scan, donor candidate file, research brief,
product dos-and-don'ts document, or subsystem matrix for every project. Persist
research only when it materially shapes the plan or must survive handoff.

## Product And Proof

For interactive tools, name the primary user-visible loop and the exact
interaction shape. For GPU compute or libraries, name the first numerical,
correctness, or performance proof. Additional product breadth is not blocked by
a universal CppStudio gate; sequence it according to the approved Planning
Harness work items and actual dependencies.

## Technical Overlays

Load `../technical-overlays.md` and only the affected overlays. Architecture
planning does not automatically activate every GUI, control-harness, profiling,
code-map, and donor mechanism.

## Preserved Strict Reference

The previous detailed planner remains at
`references/strict-project-planner.md`. Use it selectively in Recovery or when
the user explicitly asks for the former strict planning protocol. The existing
`references/project-intake.md` and `references/choice-matrix.md` are optional
deep references, not mandatory planning authority.
