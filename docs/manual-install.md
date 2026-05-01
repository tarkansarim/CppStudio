# Manual Install Reference

Use this only when a coding agent cannot run `./scripts/rollout_to_codex.sh` or when each copied
path needs direct review. Normal installation is agent-run through the repo scripts.

Manual install touches only:

- the managed `cpp-cuda-vulkan-studio` skill folder
- optional marked CppStudio relay content in user-level `AGENTS.md`
- optional marked donor-library blocks in matching companion skills

User-created sibling skills under `${HOME}/.codex/skills` are not part of this package and should be
left alone.

## Main Skill

Linux or macOS:

```bash
cd /path/to/CppStudio
mkdir -p "${HOME}/.codex/skills"
rm -rf "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
cp -a skills/cpp-cuda-vulkan-studio "${HOME}/.codex/skills/"
python3 "${HOME}/.codex/skills/.system/skill-creator/scripts/quick_validate.py" \
  "${HOME}/.codex/skills/cpp-cuda-vulkan-studio"
```

Windows PowerShell:

```powershell
Set-Location C:\path\to\CppStudio
$CodexHome = Join-Path $HOME ".codex"
$SkillsRoot = Join-Path $CodexHome "skills"
$SkillTarget = Join-Path $SkillsRoot "cpp-cuda-vulkan-studio"
New-Item -ItemType Directory -Force $SkillsRoot | Out-Null
if (Test-Path $SkillTarget) { Remove-Item -Recurse -Force $SkillTarget }
Copy-Item -Recurse -Force ".\skills\cpp-cuda-vulkan-studio" $SkillTarget
python (Join-Path $HOME ".codex\skills\.system\skill-creator\scripts\quick_validate.py") $SkillTarget
```

Restart Codex after manual installation so changed skill metadata is rediscovered.

## Optional AGENTS.md Relay

The user-level `AGENTS.md` relay is intentionally tiny. It only tells agents to load
`cpp-cuda-vulkan-studio` for C++ Vulkan, C++ CUDA, and mixed CUDA/Vulkan work. The full C++ GPU
mindset lives inside the skill.

Linux or macOS:

```bash
python3 scripts/install_user_agents_relay.py \
  --install \
  --target "${HOME}/.codex/AGENTS.md" \
  --expected-target "${HOME}/.codex/AGENTS.md" \
  --snippet companion-skill-snippets/user-agents/cppstudio-relay.md
```

Windows PowerShell:

```powershell
$AgentsPath = Join-Path $CodexHome "AGENTS.md"
python .\scripts\install_user_agents_relay.py `
  --install `
  --target $AgentsPath `
  --expected-target $AgentsPath `
  --snippet ".\companion-skill-snippets\user-agents\cppstudio-relay.md"
```

## Optional Companion Donor Links

Linux or macOS:

```bash
python3 scripts/install_companion_donor_links.py \
  --install \
  --codex-home "${HOME}/.codex" \
  --donor-root "${HOME}/.codex/skills/cpp-cuda-vulkan-studio/references/donor-library" \
  --source-skill-dir skills/cpp-cuda-vulkan-studio \
  --snippet-root companion-skill-snippets
```

Windows PowerShell:

```powershell
$DonorRoot = Join-Path $SkillTarget "references\donor-library"
python .\scripts\install_companion_donor_links.py `
  --install `
  --codex-home $CodexHome `
  --donor-root $DonorRoot `
  --source-skill-dir ".\skills\cpp-cuda-vulkan-studio" `
  --snippet-root ".\companion-skill-snippets"
```

## Managed Blocks

The managed marker blocks are the only script-owned regions:

- `<!-- cppstudio-user-agents-relay:begin -->` through
  `<!-- cppstudio-user-agents-relay:end -->`
- `<!-- cppstudio-donor-library:begin -->` through
  `<!-- cppstudio-donor-library:end -->`

Content inside those markers may be replaced by reinstall. Content outside those markers is
user-owned and must be preserved. Duplicate or mismatched markers should be treated as a cleanup
problem before reinstalling.
