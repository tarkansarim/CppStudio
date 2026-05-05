# Sortie Assistant-Pack Adoption Audit

Source material: local Sortie assistant-pack snapshot with manifest `packVersion` 1.0.145.
The audited set contains 22 skill directories with `SKILL.md` files.

## Adoption Boundary

CppStudio should cherry-pick generic doctrine only. It should not import Sortie runtime mechanics,
including Sortie MCP call sequences, Sortie worker dispatch, workflow graph execution, L0/L1/L2
Harness roles, Harness checkpoints/rewinds/gauntlets, Sortie agent resource defaults, `.sortie`
artifact contracts, or VS Code extension control paths.

Classification meaning:

- `direct adopt`: generic doctrine maps cleanly to CppStudio guidance.
- `partial cherry-pick`: keep only the reusable rule or proof obligation; discard Sortie-specific
  runtime machinery.
- `redundant/too-specific`: already covered by CppStudio or tied too tightly to Sortie internals.

## Summary

- Direct adopt: 6
- Partial cherry-pick: 8
- Redundant/too-specific: 8

## Skill Classifications

| Sortie assistant-pack entry | Classification | CppStudio adoption note |
| --- | --- | --- |
| `api-discovery` | direct adopt | Keep the evidence-first rule: target API, command, enum, callback, or option-set claims need official docs, runtime introspection, or live probes before use. |
| `bridge-http-threaded` | partial cherry-pick | Reuse the bridge proof obligations for control harnesses: server reachability, round-trip execution, output/warning capture, and safe main-thread routing. Do not import Sortie's L1 brief rules or fixed bridge runtime. |
| `bridge-tcp-socket` | partial cherry-pick | Reuse the transport discipline for socket/REPL adapters: thin command channel, serialization when needed, state/output readback, and transport-vs-target failure separation. |
| `constraint-mapping` | direct adopt | Keep query-before-set doctrine for bounded values, hidden enums, mode flags, node types, and installation-specific constraints. |
| `cpp-cuda-project-layout` | redundant/too-specific | The useful CUDA layout ideas are already covered by CppStudio's template, CMake policy, and companion C++/CUDA skills; no Sortie graph mapping should be imported. |
| `cpp-cuda-research-to-plan` | partial cherry-pick | Keep the principle that substantive C++/CUDA leaves need current research, sourced options, and explicit user/auto choice policy before implementation. Do not import Sortie research-worker, graph MCP, or `.sortie/research` mechanics. |
| `cross-platform-paths` | redundant/too-specific | The concrete hardcoded paths are Sortie-extension bugs. CppStudio already keeps reusable path hygiene in scripts/templates and should not carry those Sortie file references. |
| `cuda-profiling-and-debugging` | partial cherry-pick | Reuse the correctness-before-profiling order and profiler/tool selection wording where it sharpens CppStudio's CUDA lane. CppStudio already owns the broader Nsight and generated-project profiling workflow. |
| `graph-conventions` | partial cherry-pick | Reuse architectural decomposition, implementation-context stacking, and shallow-graph warnings as code-map doctrine. Do not import Sortie graph UI, node color, stub, or MCP execution semantics. |
| `harness-architect-window` | redundant/too-specific | The skill is mostly Sortie Harness runtime operation: L0/L1/L2 roles, control manifests, rewinds, gauntlets, and VS Code reload contracts. CppStudio should keep only separately documented control-harness principles, not this runtime model. |
| `harness-building-process` | partial cherry-pick | Reuse expectation-gap handling, observability-first escalation, friction classification, scoped reprobes, and durability hardening. Do not import Sortie runtime records, lane types, checkpoint pairing, or Harness artifact schemas. |
| `manual-subagent-supervision` | direct adopt | Reuse supervision standards: monitor delegated work, inspect activity before declaring stuck, review outputs before acceptance, and avoid claiming visual proof without real visual evidence. Do not import Sortie worker APIs. |
| `parallel-lens-escalation` | partial cherry-pick | Keep the hard-problem escalation shape: freeze the problem, launch distinct investigation lenses, require hypothesis/evidence/falsifier reports, synthesize, then choose one implementation path. Do not import Sortie dispatch mechanics. |
| `pressure-fabric-design` | redundant/too-specific | The useful caution against adding process machinery prematurely is already covered by CppStudio's evidence and validation rules. Do not import Sortie's pressure-fabric vocabulary into public CppStudio guidance. |
| `pressure-rule-language` | redundant/too-specific | This is a notation system for Sortie's pressure-fabric design. CppStudio should keep plain-language skill rules instead of adopting a separate pseudo-DSL. |
| `self-improving` | redundant/too-specific | CppStudio should not import another mutable memory system. The useful generic rules, such as not learning from silence and promoting only repeated evidence, are already covered by existing user/workflow doctrine. |
| `sonar-design` | direct adopt | Keep the observation classes for agentic control harnesses: current state, recent output/warnings, and visual/UI-only conditions when text signals are insufficient. |
| `sortie-mcp-usage` | redundant/too-specific | This is an exact Sortie MCP and role-routing manual. CppStudio must not import Sortie MCP call order, worker APIs, workflow tools, or graph execution gates. |
| `stress-testing` | direct adopt | Keep the separation between first proof and durability proof: capabilities need adversarial, warning-heavy, recovery-heavy, and cross-boundary checks before being treated as durable. |
| `target-bootstrap` | partial cherry-pick | Reuse brief discipline: separate objective, preserved user deliverables, and meta instructions; keep target discovery evidence honest. Do not import Sortie target artifacts, L1/L2 runtime roles, or Harness checkpoint rules. |
| `verify-before-wiring` | direct adopt | Keep the integration rule: trace dependencies, prefer existing paths, and verify live initialization before wiring functions, endpoints, or handlers together. |
| `workflow-rules` | redundant/too-specific | Sortie's workflow graph execution model is too specific. CppStudio should keep ordinary planning, validation, and user-choice gates instead of importing workflow graph semantics. |

## Net Recommendation

Use Sortie as a doctrine audit source, not as a runtime donor. The strongest CppStudio candidates are
API discovery, constraint mapping, sonar/observation design, CUDA profiling order, stress testing,
and verify-before-wiring. The partial candidates should be translated into CppStudio's existing
skills, code maps, control harnesses, validation lanes, and donor-routing vocabulary only when a
skill edit needs them.
