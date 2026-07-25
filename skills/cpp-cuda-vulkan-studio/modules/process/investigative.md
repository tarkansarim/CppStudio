# Investigative Process

Use Investigative to resolve a concrete uncertainty. It is not permission to
load every diagnostic mechanism.

## Procedure

1. Name the uncertainty and the canonical acceptance path.
2. Select only the matching investigation:
   - official API or format contract for semantic uncertainty;
   - known-good comparison for a regression or user-named working path;
   - focused donor or peer source for architecture or unfamiliar subsystem
     behavior;
   - profiler or hardware readback for performance or capability claims;
   - exact visible-path capture for interaction or presentation uncertainty.
3. Form one hypothesis from that evidence.
4. Make one bounded change and rerun the same acceptance path.
5. Return to Standard when ownership and the proof route are clear.

## Limits

- Keep one canonical proof route.
- Do not create a Planning Harness packet for one isolated uncertainty.
- Do not combine unrelated profiling, donor, UI, code-map, and review gates.
- Do not treat corrected command syntax or failed optional tooling as a failed
  implementation attempt.
- If the user says the behavior worked before or works in another path, inspect
  that known-good path before designing a replacement.

## Escalation

Move to Governed when the investigation reveals connected work items,
cross-subsystem ownership, nontrivial integration, or two unexplained focused
failures. Enter Recovery when evidence shows false proof, speculative patch
stacking, or cycling rather than ordinary uncertainty.
