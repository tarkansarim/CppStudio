# Web App Harness Patterns

Use this for browser-based apps and services. Keep the skill generic; do not assume native C++.

## Recommended Shape

- local dev server launch command
- health/readiness endpoint
- seeded test data or scenario fixture
- app-owned test/control routes gated to dev/test mode
- state/readback endpoints for current user, route, selected record, visible panel/dialog, feature
  flags, and recent errors
- Playwright or equivalent browser scenarios for user-visible workflows
- optional MCP facade that wraps stable HTTP or CLI controls

## Safety

- Keep dev controls unavailable in production builds.
- Do not expose arbitrary eval, shell, filesystem, database wipe, or broad admin endpoints.
- Prefer explicit scenario commands over raw mutation endpoints when a workflow spans many state
  transitions.
- Log enough to debug tests, but do not log secrets.

## Visual/UI Readback

For UI changes, combine structured app state with screenshots or accessibility/text readback. A
passing API response does not prove the user-visible browser state changed.

Track:

- current route
- focused/selected item
- active dialog/modal
- disabled/enabled action state
- error banners/toasts
- screenshot artifact path and timestamp
- browser console errors

## First Slice

For an existing app with no harness, start with a single documented scenario that launches the app,
loads a deterministic route/fixture, performs one semantic action, checks readback, and captures a
fresh screenshot.
