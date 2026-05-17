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

