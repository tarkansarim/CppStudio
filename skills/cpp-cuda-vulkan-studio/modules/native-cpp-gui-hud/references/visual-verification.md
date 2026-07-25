# Visual Verification

Use this before claiming GUI polish, product-fit, or command-surface completion.

## Minimum Evidence

- fresh screenshot or captured frame from the real app
- the affected convention table or peer-tool notes
- command/action inventory when practical
- build/run/test evidence for the UI path
- for reported visible bugs, comparable before/after evidence from the same or equivalent
  interaction path
- Sonar readback, harness state, logs, or action inventory when available for the affected surface

## Screenshot Scorecard

Check:

- control placement matches the chosen UI convention
- icons or text fit their containers
- no clipping, overlap, crowding, or stale debug controls
- viewport is the correct dimensionality and framed for the task
- timeline/transport, inspector, scene tree, node graph, and status surfaces are where users expect
- visible labels distinguish preview/diagnostic/final/destructive states clearly
- the UI looks like a tool for its target user, not only a developer test harness
- familiar commands use familiar icon, menu, shortcut, or context affordances unless the donor
  evidence justifies visible text controls
- the screenshot matches the reported interaction or product surface, not a nearby or synthetic path

## Action Inventory

For UI-heavy slices, capture these fields when practical:

- action id
- visible label
- icon name or icon-present flag
- tooltip/accessibility text
- shortcut/menu/context path
- surface location
- enabled state
- command target
- selected-object or focus requirement
- exercised, introspected, screenshot-only, or metadata-only proof

Do not claim a menu, context action, shortcut, timeline command, viewport command, or toolbar action
was tested unless it was actually exercised or introspected.

## Reported GUI Bug Proof

For user-reported GUI issues, save the closest available before evidence before editing when
practical: the visible controls, active mode, selection, exact input sequence, pointer or widget
target, screenshot or captured frame, Sonar text/visual readback, harness state, and relevant logs.
After the fix, rerun the same scenario or document the equivalent path and compare against the before
state in the symptom's own terms.

Do not close a reported GUI issue from backend-only success, a generic nonblank capture, a stale
artifact, or one convenient control when the report described a broader interaction problem. If the
after proof is identical to the before proof or narrower than the report, continue diagnosis or state
that the bug is not proven fixed.

## Failure Response

If the screenshot or inventory looks debug-heavy, crowded, convention-breaking, misleading, or
visually stale, treat that as a product bug even when functional tests pass. Fix the UI surface before
claiming the slice is polished. If product-fit evidence is missing, gather donor or peer-tool
evidence and rerun the visual review instead of substituting a unit test pass.
