# Visual Readback

Use this when an app has a GUI, viewport, canvas, renderer, terminal window, or any visible state the
user would judge.

## Sonar Posture

Observation is not decoration. The harness should expose enough readback for an agent to understand
what is happening without guessing:

- text-queryable app state
- recent logs/warnings/errors
- UI state: focus, selection, active mode, enabled actions, active panel/dialog
- screenshots, frame captures, render-target dumps, or accessibility/text readback
- freshness fields showing the capture reflects the requested state

Prefer text-queryable signals when possible. Use screenshots to cross-check and calibrate missing
text signals. If visual proof reveals a fact not available in text, add a text-readable surrogate
when practical.

## Freshness Contract

Screenshot/frame endpoints should avoid stale evidence. Include fields such as:

- requested state or scenario id
- requested revision/frame
- rendered revision/frame
- capture timestamp
- capture path
- settled or in-sync boolean tied to the exact invariant

If the capture cannot settle on the requested state, return a harness error with observed and
requested revisions instead of silently returning old pixels.

## Reported GUI Bug Evidence

When a GUI bug is reported by a user, visual readback must prove the reported symptom changed.
Record a before artifact from the closest user-equivalent path before changing code, then record an
after artifact from the same path or a documented-equivalent path after changing code.

Comparable evidence should include:

- scenario id, launch command, input sequence, and target surface
- UI state, app state, logs/warnings/errors, and capture path
- event-to-state readback that is independent of the command response
- the visible artifact, screenshot, frame, accessibility/text readback, or text-readable surrogate
- the assertion or metric that fails before and passes after in the user's terms

Fail the proof if before and after are identical, stale, self-confirming, backend-only for a visible
bug, or too narrow for the report. For example, a brush-selection report that names repeated enabled
entries needs repeated selection coverage, and a pointer-offset report needs requested pointer,
committed edit/hit point, and visible result comparison. A mesh revision increment, successful
command response, or internally predicted click coordinate is not enough by itself.

## Failure Discipline

After repeated stale capture, render scheduling, or command-routing failures:

1. stop patch stacking
2. record failing scenario ids and exact response fields
3. classify cause as command routing, render scheduling, capture timing, or smoke order
4. revert or isolate speculative patches unless evidence shows they are necessary
5. continue with a smaller targeted repro

## Offscreen/Windowed Lanes

When a GUI app needs a window to render correctly, route it through the project's windowed/offscreen
test manager when available. The control harness should still own semantic commands and readback;
the offscreen manager owns safe process/window execution.
