# Manual Install Reference

Use this only when a coding agent cannot run `./scripts/rollout_to_codex.sh` or when each copied
path needs direct review. Normal installation is agent-run through the repo scripts.

Manual install touches only:

- the managed `cpp-cuda-vulkan-studio` skill folder
- optional marked CppStudio relay content in user-level `AGENTS.md`
- optional marked donor-library blocks in matching companion skills

User-created sibling skills under `${HOME}/.codex/skills` are not part of this package and should be
left alone.

## Codex Home Variables

Manual snippets use `CODEX_HOME` because a person or agent is choosing one target Codex home
directly. The automated rollout and sync scripts intentionally use `SYNC_CODEX_HOME` instead, because
nested Codex sessions may set `CODEX_HOME` to an isolated session home. For normal scripted installs,
prefer:

```bash
SYNC_CODEX_HOME=/path/to/.codex ./scripts/rollout_to_codex.sh
```

Use the manual `CODEX_HOME` snippets below only when direct copy/review is required.

## Main Skill

Linux or macOS:

```bash
cd /path/to/CppStudio

codex_home="${CODEX_HOME:-${HOME}/.codex}"
skills_root="${codex_home}/skills"
skill_target="${skills_root}/cpp-cuda-vulkan-studio"
validator="${skills_root}/.system/skill-creator/scripts/quick_validate.py"

staging_root="$(mktemp -d)"
staged_skill="${staging_root}/cpp-cuda-vulkan-studio"
cp -a skills/cpp-cuda-vulkan-studio "${staged_skill}"
python3 "${validator}" "${staged_skill}"

mkdir -p "${skills_root}"
if [[ -e "${skill_target}" ]]; then
  backup_target="${skill_target}.backup.$(date +%Y%m%d%H%M%S)"
  mv "${skill_target}" "${backup_target}"
  echo "Backed up existing skill to ${backup_target}"
fi
mv "${staged_skill}" "${skill_target}"
rmdir "${staging_root}" 2>/dev/null || true
python3 "${validator}" "${skill_target}"
```

Windows PowerShell:

```powershell
Set-Location C:\path\to\CppStudio
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillsRoot = Join-Path $CodexHome "skills"
$SkillTarget = Join-Path $SkillsRoot "cpp-cuda-vulkan-studio"
$Validator = Join-Path $SkillsRoot ".system\skill-creator\scripts\quick_validate.py"
$StagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("cppstudio-skill-" + [System.Guid]::NewGuid())
$StagedSkill = Join-Path $StagingRoot "cpp-cuda-vulkan-studio"

New-Item -ItemType Directory -Force $StagingRoot | Out-Null
Copy-Item -Recurse ".\skills\cpp-cuda-vulkan-studio" $StagedSkill
python $Validator $StagedSkill

New-Item -ItemType Directory -Force $SkillsRoot | Out-Null
if (Test-Path $SkillTarget) {
  $BackupTarget = "$SkillTarget.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
  Rename-Item -Path $SkillTarget -NewName (Split-Path $BackupTarget -Leaf)
  Write-Host "Backed up existing skill to $BackupTarget"
}
Move-Item $StagedSkill $SkillTarget
Remove-Item -Force $StagingRoot
python $Validator $SkillTarget
```

Restart Codex after manual installation so changed skill metadata is rediscovered.

## Optional AGENTS.md Relay

The user-level `AGENTS.md` relay is intentionally tiny. It only tells agents to load
`cpp-cuda-vulkan-studio` for C++ Vulkan, C++ CUDA, and mixed CUDA/Vulkan work. The full C++ GPU
mindset lives inside the skill.

Linux or macOS:

```bash
codex_home="${CODEX_HOME:-${HOME}/.codex}"
agents_path="${codex_home}/AGENTS.md"

python3 scripts/install_user_agents_relay.py \
  --install \
  --target "${agents_path}" \
  --expected-target "${agents_path}" \
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
codex_home="${CODEX_HOME:-${HOME}/.codex}"
skill_target="${codex_home}/skills/cpp-cuda-vulkan-studio"
donor_root="${skill_target}/references/donor-library"

python3 scripts/install_companion_donor_links.py \
  --install \
  --codex-home "${codex_home}" \
  --donor-root "${donor_root}" \
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
