#!/usr/bin/env bash

# Claude-lane managed-skill inventory. SEPARATE from the Codex lane (managed_skills.sh) by design:
# CppStudio installs into ~/.claude/skills via its own installer, kept distinct from ~/.codex per the
# provider-lane-separation doctrine. Sourced by rollout_to_claude.sh / sync_to_claude.sh.
# shellcheck disable=SC2034 # Sourced by Claude-lane rollout/sync scripts.

# Main coordinator skill (installed via SKILL_NAME).
CPPSTUDIO_CLAUDE_MAIN_SKILL="cpp-cuda-vulkan-studio"

# Specialist guides are internal modules of the main router package.
CPPSTUDIO_CLAUDE_AUXILIARY_SKILL_NAMES=()

# Former top-level targets removed transactionally during rollout.
CPPSTUDIO_CLAUDE_LEGACY_TOP_LEVEL_SKILL_NAMES=(
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
