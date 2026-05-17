---
name: important-instruction-ledger
description: "Capture and revisit important user instructions, active constraints, hard rules, decisions, and supervision requirements so they survive compaction and are checked before planning, worker nudges, source edits, closeout, commits, or status claims. Use when the user says important, don't forget, remember, keep in mind, hard rule, from now on, always, never, prerequisite, constraint, or when a repeated miss shows an instruction was not preserved."
---

# Important Instruction Ledger

Use this skill when a user gives durable context that future turns, compacted context, workers, or
reviewers must not forget.

## Trigger

Trigger immediately when the user says or implies:

- "important", "don't forget", "remember", "keep in mind", "hard rule", "from now on"
- "always", "never", "must", "do not", "before you continue", "prerequisite", "constraint"
- a correction that should change future behavior, especially after compaction or worker supervision
- an active project decision, product choice, route, scope limit, test requirement, or blocked action

## Ledger Path

Default target-project ledger:

- Markdown: `docs/agent-context/IMPORTANT_USER_INSTRUCTIONS.md`
- JSONL: `docs/agent-context/important-user-instructions.jsonl`

If the instruction is about reusable agent behavior or source skills, write it in the owning source
repo, not only in the current target project. If the instruction is about a supervised worker, use
the supervised target repo unless the instruction changes the supervising harness itself.

Do not hand-edit installed user-level skill copies as the source of truth. Update the source repo and
roll out normally.

## Required Workflow

1. Before doing related work, run `scripts/important_instruction_ledger.py review --project <repo>`.
2. If the user just gave a durable instruction, append it first:

```bash
python /path/to/skill/scripts/important_instruction_ledger.py append \
  --project /absolute/repo \
  --summary "Short active constraint" \
  --scope "project | supervision | reusable-skill | worker:<name>" \
  --source "short user quote or paraphrase" \
  --trigger "when to revisit this"
```

3. When nudging or supervising a worker, include the relevant active ledger items in the nudge.
4. Before approving a plan, slice, commit, closeout, or status claim, review the ledger again and
   explicitly check the relevant active items against primary artifacts.
5. If an instruction is superseded, append a new item with `--status superseded` and name the
   superseding decision. Do not silently delete history.

## Closeout Gate

Before saying a worker slice, plan, or reusable behavior is acceptable:

- show that the ledger was reviewed during the current supervision pass
- name any active item that affects the slice
- reject the slice if the active item is unmet, even when other tests pass

Passing build, OSTM, code-map, or planning validators does not satisfy a user instruction unless the
instruction itself was checked.
