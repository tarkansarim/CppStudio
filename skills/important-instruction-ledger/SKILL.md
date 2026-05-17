---
name: important-instruction-ledger
description: "Maintain an active per-slice watchlist for supervising or directly implementing work: what must be watched, verified, rejected, revisited, or carried across compaction before planning, worker nudges, source edits, closeout, commits, or status claims. Use for substantial implementation slices, worker supervision, slice approval, direct source work, repeated misses, and also when the user gives important constraints, hard rules, prerequisites, always/never instructions, or decisions."
---

# Active Slice Watchlist

Use this skill to maintain an active supervision watchlist for each implementation slice. It is not
passive note-taking and it is not limited to user quotes. The watchlist tells the supervising or
direct agent what to keep an eye on as the slice progresses, what would invalidate the slice, and
what evidence must exist before approval or closeout.

User instructions are one source of watch items. Other sources include plan packets, donor facts,
code-map routes, previous misses, review findings, tool failures, visible-loop requirements,
verification gates, and current worker risks.

## Trigger

Trigger when any of these are true:

- a substantial slice is being planned, nudged to a worker, implemented directly, approved, committed,
  or closed out
- a supervising agent needs to monitor a worker's plan, implementation, validation, or next slice
- the slice has quality risks, blocked scope, donor requirements, UI/visible-loop expectations,
  code-map requirements, tool/harness expectations, or verification gates
- a repeated miss shows that the agent lost track of what mattered during the slice
- the user says or implies "important", "don't forget", "remember", "keep in mind", "hard rule",
  "from now on", "always", "never", "must", "do not", "before you continue", "prerequisite", or
  "constraint"
- an active project decision, product choice, route, scope limit, test requirement, or blocked action
  must survive compaction or worker handoff

## Watchlist Path

Default target-project watchlist:

- Markdown: `docs/agent-context/SLICE_WATCHLIST.md`
- JSONL: `docs/agent-context/slice-watchlist.jsonl`

Legacy files named `IMPORTANT_USER_INSTRUCTIONS.md` and `important-user-instructions.jsonl` may be
loaded for compatibility, but new entries belong in the slice watchlist.

If the watch item is about reusable agent behavior or source skills, write it in the owning source
repo, not only in the current target project. If it is about a supervised worker, use the supervised
target repo unless the issue changes the supervising harness itself.

Do not hand-edit installed user-level skill copies as the source of truth. Update the source repo and
roll out normally.

## Required Workflow

1. Before doing related work, run `scripts/important_instruction_ledger.py review --project <repo>`.
2. Before a slice starts, append or update the active watch items that matter for that slice:

```bash
python /path/to/skill/scripts/important_instruction_ledger.py append \
  --project /absolute/repo \
  --slice "short slice name" \
  --watch "What must be watched, rejected, or verified" \
  --scope "project | supervision | reusable-skill | worker:<name>" \
  --source "user rule, plan packet, donor fact, review finding, tool failure, or prior miss" \
  --trigger "when to revisit this" \
  --gate "approval evidence or rejection condition"
```

3. When nudging or supervising a worker, include the relevant active watch items in the nudge.
4. Before approving a plan, slice, commit, closeout, or status claim, review the watchlist again and
   explicitly check active items against primary artifacts.
5. If a watch item is satisfied, superseded, or historical, append a new entry with the updated
   status and name the evidence or superseding decision. Do not silently delete history.

## Closeout Gate

Before saying a worker slice, plan, or reusable behavior is acceptable:

- show that the watchlist was reviewed during the current supervision/direct-work pass
- name the active watch items that affect the slice
- reject the slice if an active watch item is unmet, even when other tests pass
- do not treat "I took notes" as compliance; compliance means the item changed what the agent
  watched, asked, verified, blocked, or rejected during the slice

Passing build, OSTM, code-map, or planning validators does not satisfy the watchlist unless the
specific active item was checked against the primary evidence it requires.
