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
- `scripts/validate_donor_library.py`
- `scripts/validate_trigger_matrix.py`
- `scripts/render_trigger_eval_prompt.py`
- `scripts/audit_donor_freshness.py`

## Update When

- donor categories, production overlays, profiles, or caveat identifiers change
- a donor tier changes between safe-donor, dependency-candidate, or study-only
- a donor caveat such as mixed-native or reference-only changes
- trigger prompts, expected donor routing, or donor inventory in the README changes
- donor refresh dates or source research notes change
- donor freshness audit behavior or source URL metadata expectations change
- donor-grounding or web-ceiling-check expectations for broad native GPU design prompts change
- native C++ GUI/HUD/editor UI donor categories or visual inspection link rules change
- trigger-matrix expectations for GUI convention tables, icon/text affordance checks, screenshot
  scorecards, harness readiness invariants, route inventory reconciliation, or action inventories
  change
- trigger-evaluation prompt wording or forbidden-path probe rules change
- trigger-matrix expectations for code-map bootstrap, enabled-map maintenance, or routing-smoke
  proof change
- required trigger case-name validation changes
