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

