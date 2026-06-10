#!/usr/bin/env bash

# Claude-lane managed-skill inventory. SEPARATE from the Codex lane (managed_skills.sh) by design:
# CppStudio installs into ~/.claude/skills via its own installer, kept distinct from ~/.codex per the
# provider-lane-separation doctrine. Sourced by rollout_to_claude.sh / sync_to_claude.sh.
# shellcheck disable=SC2034 # Sourced by Claude-lane rollout/sync scripts.

# Main coordinator skill (installed via SKILL_NAME).
CPPSTUDIO_CLAUDE_MAIN_SKILL="cpp-cuda-vulkan-studio"

# Full auxiliary set (slice 3 reconciliation complete, 2026-06-09): all 10 CppStudio auxiliary
# skills install into ~/.claude/skills.
#   - native-cpp-gui-hud / agentic-control-harness: user decided CppStudio is the source of truth.
#     The previous Claude variants were stale rule-packet forks maintained in private local
#     single-skill repos (frozen 2026-05-18, missing CppStudio's later hardening); their
#     unique reference content was imported into CppStudio source first, and those repos are marked
#     superseded for the Claude install target.
#   - cppstudio-project-planner / gpu-profiling-workstation: install under their own names alongside
#     cpp-cuda-research-to-plan / cuda-profiling-and-debugging (distinct trigger surfaces, no
#     name collision).
CPPSTUDIO_CLAUDE_AUXILIARY_SKILL_NAMES=(
    "cppstudio-supervisor"
    "viewport-session-testing"
    "important-instruction-ledger"
    "vulkan-compute-sync"
    "modern-cpp-cmake"
    "cuda-kernel-authoring"
    "native-cpp-gui-hud"
    "agentic-control-harness"
    "cppstudio-project-planner"
    "gpu-profiling-workstation"
)

# Reconcile set: empty since slice 3. Kept for lane tooling compatibility.
CPPSTUDIO_CLAUDE_RECONCILE_SKILL_NAMES=()
