# Recovery State

Recovery is an incident state, not a permanent complexity tier.

## Entry

Enter Recovery when one or more of these are evidenced:

- canonical acceptance remains contradictory after an Investigative hypothesis
  and canonical rerun;
- a fresh user report invalidates the prior proof and canonical replay does not
  reduce it to a stale launcher, stale binary, or wrong runtime;
- speculative patches have accumulated without isolated proof;
- the lane cycles through wrappers, fixtures, restarts, or alternate proof
  routes without changing the reported symptom;
- scope or architecture is drifting;
- required tool failures are repeatedly worked around.

Do not enter full Recovery merely because one test failed or the first proof
used a stale binary. Correct that direct cause and rerun first.

## Procedure

1. Freeze new speculative implementation.
2. Reproduce the canonical user or product path and identify the deciding
   acceptance artifact.
3. Inventory current patches, hypotheses, proof artifacts, runtime provenance,
   and tool failures.
4. Mark each patch `proven`, `unproven`, `rejected`, or `required for repro`.
5. Restore or quarantine unproven work when it obscures the baseline. Use
   Rewind only when causal replay or restoration needs it.
6. Activate only incident-specific mechanisms:
   - phase telemetry for unknown time or cycle location;
   - donor or upstream realignment for uncertain semantics or architecture;
   - profiler or frame capture for an unmeasured GPU claim;
   - one fresh review for a changed risk boundary or structurally false proof;
   - code-map sidecar for actual enabled-map drift;
   - acceptance ledger for conflicting or repeated proof artifacts.
7. Choose one outcome: continue with one named hypothesis, roll back, cut over
   while preserving the user contract, or stop with a concrete blocker.

## Exit

Exit Recovery when the false proof or patch stack is reconciled and the
canonical acceptance path either passes or has one plain blocker. If Planning
Harness already owns the work, its packet remains the durable record, but
Governed process controls stay inactive while Recovery is active. Classify the
next work item as Standard, Investigative, or Governed after Recovery ends.

Use `modules/process/strict-doctrine-index.md` to locate preserved strict rules
for the specific incident. Do not load the full strict reference by default.
