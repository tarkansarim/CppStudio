# CppStudio

Canonical working repo for the reusable C++/CUDA/Vulkan Codex studio backbone.

Agents should start with `AGENTS.md`. This repo also includes a project-level Codex onboarding
skill at `.codex/skills/cppstudio-repo-onboarding/`.

Edit the skill here:

```bash
skills/cpp-cuda-vulkan-studio
```

Validate before publishing:

```bash
./scripts/validate.sh
```

Publish the working copy to user-level Codex skills:

```bash
./scripts/sync_to_codex.sh
```

Roll out the skill and companion-skill donor-library links:

```bash
./scripts/rollout_to_codex.sh
```

Companion-skill donor link snippets are source-owned under:

```bash
companion-skill-snippets/
```

Research notes that informed the reusable skill updates live under:

```bash
research/
```

Continuously publish changes while editing:

```bash
./scripts/watch_to_codex.sh
```

The sync target defaults to the user-level Codex home even inside nested Codex sessions:

```bash
${SYNC_CODEX_HOME:-$HOME/.codex}/skills/cpp-cuda-vulkan-studio
```

Use `TARGET_DIR=/path/to/skill ./scripts/sync_to_codex.sh` for an exact override.
