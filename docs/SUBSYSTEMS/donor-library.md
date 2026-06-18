# Donor Library

Owns the nested donor-reference router, production overlays, category files, deep profiles, donor
selection policy, and trigger-regression metadata.

## Canonical Docs

- `skills/cpp-cuda-vulkan-studio/references/donor-library/README.md`
- `skills/cpp-cuda-vulkan-studio/references/donor-library/selection-policy.md`
- `skills/cpp-cuda-vulkan-studio/references/donor-library/agent-lookup.md`

## Primary Paths

- `skills/cpp-cuda-vulkan-studio/references/donor-library/`
- `skills/cpp-cuda-vulkan-studio/references/donor-library/profiles/`
- `research/donor-library/trigger-matrix.json`
- `research/donor-library/trigger-results-2026-05-10-installed.json`
- `scripts/validate_donor_library.py`
- `scripts/validate_trigger_matrix.py`
- `scripts/validate_trigger_results.py`
- `scripts/render_trigger_eval_prompt.py`
- `scripts/audit_donor_freshness.py`

## Update When

- donor categories, production overlays, profiles, or caveat identifiers change
- a donor tier changes between safe-donor, dependency-candidate, or study-only
- a donor caveat such as mixed-native or reference-only changes
- trigger prompts, expected donor routing, or donor inventory in the README changes
- donor refresh dates or source research notes change
- donor-candidate capture, project-local research artifact expectations, or promotion rules between
  target-project research and the CppStudio source donor library change
- source-versus-installed donor-library promotion boundaries change, including when target-project
  agents may promote a web-discovered donor into the reusable CppStudio source library
- donor validation or donor freshness audit behavior changes, including source URL metadata parsing
- donor validation/freshness parser fixtures, plural or wrapped `Sources:` handling, route/profile
  source matching, or `Last checked` metadata policy changes
- donor-grounding or web-ceiling-check expectations for broad native GPU design prompts change
- standard-format, interchange-format, protocol, SDK-schema, or conformance-suite donor semantics
  change, including when reference-only donors still define contract-level import/export behavior
- native C++ GUI/HUD/editor UI donor categories or visual inspection link rules change
- platform/window/input donor categories change, including SDL3, GLFW, Qt tablet events, native
  tablet APIs, or other artist-input routes for pressure-sensitive tools
- sculpting, brush, high-poly mesh editing, Paint BVH/PBVH, or dense-mesh performance donor
  categories/profiles change
- donor-realignment gates change for stalled visible bugs, brush/viewport interaction fixes, or
  domain algorithm slices that must return to donors before more local patching
- trigger-matrix expectations for GUI convention tables, icon/text affordance checks, screenshot
  scorecards, harness readiness invariants, route inventory reconciliation, or action inventories
  change
- trigger-evaluation prompt wording, matrix-anchored result-artifact validation, pass/fail evidence
  rules, or forbidden-path probe rules change
- trigger-matrix expectations for greenfield code-map pre-source gates, code-map bootstrap,
  enabled-map maintenance, code-map sidecar maintenance, or routing-smoke proof change
- required trigger case-name validation changes
