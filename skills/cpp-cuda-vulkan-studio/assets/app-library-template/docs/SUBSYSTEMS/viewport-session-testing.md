# Viewport Session Testing

App-owned viewport/UI session recording and replay, generated fake-host smoke coverage, session
artifact reporting, and user-equivalent visible bug proof.

## Canonical Docs

- `docs/VIEWPORT_SESSION_TESTING.md`
- `docs/VALIDATION_PIPELINE.md`

## Primary Paths

- `include/*/viewport_session.hpp`
- `src/testing/`
- `tests/unit/viewport_session_test.cpp`
- `scripts/run_viewport_session_smoke.py`
- `docs/VIEWPORT_SESSION_TESTING.md`

## Update When

- viewport/session event schema, host adapter contract, scenario artifact layout, replay behavior,
  screenshot/capture freshness, or report fields change
- visible GUI or viewport validation moves from fake-host smoke to real app interaction scenarios
- scripts or CTest labels for viewport-session proof change
