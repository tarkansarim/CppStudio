# Active Slice Watchlist

This file is agent-maintained. It lists what the supervising or direct agent must keep
watching during each implementation slice: constraints, risks, gates, donor facts, user
rules, verification expectations, and rejection conditions that must survive compaction and
worker handoffs.

## Active

1. **Treat this mechanism as an active slice supervision watchlist, not passive user-note capture**
   - Status: `active`
   - Slice: `reusable-skill supervision`
   - Scope: `reusable-skill-supervision`
   - Source: User correction: be mindful and keep an eye on important things in each slice
   - Revisit when: Before worker nudges, direct source edits, slice approval, commits, status summaries, or after compaction
   - Gate: The active item must affect what is watched, verified, blocked, or rejected during the slice
   - Evidence: self-improvement:friction:46442a0ee6a96e07
   - Recorded: `2026-05-17T02:06:46Z`

2. **CppStudio planner/routing changes must enforce donor feature disposition, not only donor citation: high-salience donor features for shaders/tools/subsystems must be inventoried and marked included/deferred/rejected/blocked with reasons and validation signals before source edits.**
   - Status: `active`
   - Slice: `donor feature disposition enforcement`
   - Scope: `reusable-skill`
   - Source: user rule: agents may eyeball donors and silently omit important features
   - Revisit when: before source patch closeout, rollout, or trigger-lane claim
   - Gate: Reject the CppStudio change if source skills still allow broad donor rows or chat-only donor citation to stand in for explicit feature disposition.
   - Evidence: none recorded
   - Recorded: `2026-05-17T08:40:19Z`

3. **Before planning from donor shader/tool/subsystem code, agents must break down the donor's important elements first rather than skimming: shader stages/passes, inputs/outputs, descriptor/uniform/state contracts, spaces/units, variants/macros, quality features, edge cases, validation signals, and omitted features. Plans must be derived from that breakdown.**
   - Status: `active`
   - Slice: `donor feature disposition enforcement`
   - Scope: `reusable-skill`
   - Source: user refinement: break down every important donor shader element before planning so donor code is not skimmed
   - Revisit when: before source patch closeout, rollout, trigger-lane claim, or worker nudge using donor shaders/tools
   - Gate: Reject the reusable change if it only says inventory features after the fact and does not require a pre-plan donor-code breakdown before plan creation.
   - Evidence: none recorded
   - Recorded: `2026-05-17T08:55:45Z`

4. **Implement viewport session testing as a real generated runtime scaffold plus skill routing, not only advisory prose; extract production grooming-style session replay and paint/simulation GUI scenario concepts without copying app-specific code.**
   - Status: `active`
   - Slice: `viewport-session-testing lane`
   - Scope: `reusable-skill`
   - Source: user request and donor inspection
   - Revisit when: before source edits, validation, rollout, and closeout
   - Gate: Skill exists, template runtime/files/docs/scripts exist, validation includes them, rollout succeeds, and trigger/behavior evidence is reported.
   - Evidence: none recorded
   - Recorded: `2026-05-18T00:47:44Z`

5. **User-facing verification is the primary acceptance surface for interactive features: backend/control/OSTM success is supporting evidence only until the real visible control, gesture shape, and visible result are proven.**
   - Status: `active`
   - Slice: `user-facing verification gate`
   - Scope: `reusable-skill`
   - Source: user correction: user-facing verification must not be an afterthought
   - Revisit when: before source patch closeout, rollout, trigger-lane claim, or approving interactive worker slices
   - Gate: Reject reusable skill changes or worker slices that let hidden CLI/backend/event smokes stand in for visible user workflow proof.
   - Evidence: none recorded
   - Recorded: `2026-05-18T07:09:04Z`

6. **Sculpt brush behavior must be donor-backed against production sculpt implementations such as Blender before accepting architecture or tests; live stroke/dab semantics cannot be inferred from training data.**
   - Status: `active`
   - Slice: `3dSculptTool supervision`
   - Scope: `reusable-skill`
   - Source: user correction: release-only sculpting proved donor route was missed
   - Revisit when: before approving sculpt brush fixes or changing CppStudio routing
   - Gate: worker shows Blender/donor route, exact code behavior considered, and mid-drag proof exists
   - Evidence: none recorded
   - Recorded: `2026-05-18T09:53:41Z`

7. **Substantial greenfield planning must stop after the research brief with an explicit Plan-mode handoff; supervisor, replay, or test prompts to write a plan or use defaults must not waive that gate.**
   - Status: `active`
   - Slice: `greenfield plan-mode handoff`
   - Scope: `reusable-skill`
   - Source: fresh 3dSculptTool worker produced good research but asked unresolved stack choices inline
   - Revisit when: before rollout, trigger-lane claim, or approving a fresh greenfield planning worker
   - Gate: Reject the reusable change if the fresh worker asks unresolved template, GUI/input, code-map, authoring-model, GPU-lane, dependency, donor, or validation choices inline in normal chat instead of asking the user to switch to Plan mode or recording an explicit waiver.
   - Evidence: none recorded
   - Recorded: `2026-05-18T12:14:03Z`

8. **Claim vulkan-compute-sync as a CppStudio-owned bundled skill without editing unrelated repos directly; update rollout/install validation, code map, docs, manifests, and then file/dispatch description-deferral tickets to owner repos.**
   - Status: `active`
   - Slice: `vulkan-compute-sync ownership and skill-description ticketing`
   - Scope: `reusable-skill`
   - Source: user request
   - Revisit when: before source edits, validation, rollout, ticket filing, and closeout
   - Gate: Source skill exists under CppStudio, rollout installs it from source, validation passes, tickets are filed to source-owning repos, and owner agents are launched through guarded tmux/contact.
   - Evidence: none recorded
   - Recorded: `2026-05-18T21:05:36Z`

9. **Ticket #112 closeout requires source-only edits, compact frontmatter descriptions, moved details preserved in skill bodies/references, representative trigger probes, validate.sh, rollout_to_codex.sh, evidence comments, strict closeout-check, clean source worktree, and HEAD/commit/install evidence before closing.**
   - Status: `active`
   - Slice: `ticket-112 skill description deferral`
   - Scope: `reusable-skill`
   - Source: user ticket closeout gate and ticket #112 body
   - Revisit when: before source edits, validation, rollout, ticket evidence comments, closeout-check, close, and final status
   - Gate: Do not close ticket #112 unless the ticket contains validation results, before/after description lengths, trigger/detail probe evidence, install/rollout evidence, source clean status, and HEAD/commit evidence.
   - Evidence: none recorded
   - Recorded: `2026-05-18T21:17:19Z`

10. **Ticket #130 requires source-owned companion skills, compact frontmatter descriptions, installed .skill-source sentinels, exact validation evidence, rollout/sync evidence, clean source worktree, HEAD/commit evidence, strict closeout-check, and ticket comments before close.**
   - Status: `active`
   - Slice: `ticket-130 companion skill ownership`
   - Scope: `reusable-skill`
   - Source: ticket #130 closeout gate and installed skill-packaging audit
   - Revisit when: before source edits, rollout, ticket evidence comments, closeout-check, close, and final status
   - Gate: Do not close ticket #130 unless source owns the three target skills or explicitly routes ownership, target descriptions are <=300 chars, installed snapshots include .skill-source, rollout/sync evidence is commented, source worktree is clean, and HEAD/commit evidence is reported.
   - Evidence: none recorded
   - Recorded: `2026-05-19T00:31:38Z`

11. **Do not let semantic path coverage or absence of a debug overlay close product-visible stroke-direction or shading-quality concerns; each user-named visible concern must be classified resolved/unresolved/not-tested with matching visual/product proof.**
   - Status: `active`
   - Slice: `viewport visible proof hardening`
   - Scope: `reusable-skill`
   - Source: User correction after 3dSculptTool worker accepted OSTM semantic proof while live stroke direction and shader quality stayed questionable
   - Revisit when: before source patch closeout, rollout, trigger-lane claim, or worker nudge
   - Gate: Reject the reusable change if skills/templates still allow a narrower semantic assertion to close broader visible/product-quality complaints.
   - Evidence: none recorded
   - Recorded: `2026-05-19T19:25:21Z`

12. **Prevent repeated red visual/reference render lanes from treating diagnostic narrowing, debug buffers, wrapper execution, or local-source-only analysis as product progress; require top-level acceptance artifact status, current web/upstream realignment, and cutover decision before more local probes after repeated failure.**
   - Status: `active`
   - Slice: `long visual reference lane hardening`
   - Scope: `reusable-skill`
   - Source: user correction and long-running visual reference lane postmortem
   - Revisit when: before source patch closeout, rollout, trigger-lane claim, or supervising long-running render/reference workers
   - Gate: Reject the reusable change if skills/templates still allow more local probes after repeated unchanged acceptance artifacts without a written acceptance ledger, a narrow read-only `codex exec` stuck probe, substantive current web/upstream research into the exact stuck layer, recorded links/queries and source facts, filtered continue/cutover options that preserve user-named reference targets, an explicit continue/cutover/blocker decision, and a fresh scoped Codex adversarial review if the next focused attempt still leaves the final artifact red.
   - Evidence: none recorded
   - Recorded: `2026-05-19T20:19:16Z`

## Superseded Or Historical

1. **Record important user instructions immediately and revisit them before supervision or closeout**
   - Status: `superseded`
   - Slice: `global`
   - Scope: `reusable-skill-supervision`
   - Source: User: important information must be written down because compaction loses details
   - Revisit when: Before worker nudges, slice approval, planning validation, commits, status summaries, or after context compaction
   - Gate: Superseded by active slice-watchlist framing
   - Evidence: self-improvement:friction:68699857a7cc864e
   - Recorded: `2026-05-17T01:31:46Z`
