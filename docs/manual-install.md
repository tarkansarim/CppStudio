# Manual Install Reference

Use this only when a coding agent cannot run `./scripts/rollout_to_codex.sh` or when each copied
path needs direct review. Normal installation is agent-run through the repo scripts.

Manual install touches only:

- the managed `cpp-cuda-vulkan-studio`, `native-cpp-gui-hud`, `cppstudio-project-planner`,
  `agentic-control-harness`, `viewport-session-testing`, `important-instruction-ledger`, and
  `vulkan-compute-sync` skill folders
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

## Managed Skill Folders

Linux or macOS:

```bash
cd /path/to/CppStudio

codex_home="${CODEX_HOME:-${HOME}/.codex}"
skills_root="${codex_home}/skills"
skill_names=("cpp-cuda-vulkan-studio" "native-cpp-gui-hud" "cppstudio-project-planner" "agentic-control-harness" "viewport-session-testing" "important-instruction-ledger" "vulkan-compute-sync")
system_validator="${skills_root}/.system/skill-creator/scripts/quick_validate.py"
repo_validator="${PWD}/scripts/quick_validate_skill.py"
package_validator="${PWD}/scripts/validate_skill_package.py"
if [[ -f "${system_validator}" ]]; then
  validator="${system_validator}"
elif [[ -f "${repo_validator}" ]]; then
  validator="${repo_validator}"
else
  echo "Missing skill validator: ${system_validator} or ${repo_validator}" >&2
  exit 1
fi
mkdir -p "${skills_root}"
if [[ -L "${skills_root}" ]]; then
  echo "Refusing symlinked Codex skills root: ${skills_root}" >&2
  exit 1
fi
if [[ ! -f "${package_validator}" ]]; then
  echo "Missing package validator: ${package_validator}" >&2
  exit 1
fi

for skill_name in "${skill_names[@]}"; do
  skill_source="skills/${skill_name}"
  skill_target="${skills_root}/${skill_name}"
  if [[ ! -f "${skill_source}/SKILL.md" ]]; then
    echo "Missing managed skill source: ${skill_source}" >&2
    exit 1
  fi
  if [[ -L "${skill_target}" ]]; then
    echo "Refusing symlinked skill target: ${skill_target}" >&2
    exit 1
  fi
done

staging_root="$(mktemp -d)"
backup_root="$(mktemp -d "${codex_home}/cppstudio-skill-backup.XXXXXX")"
changes_started=0

restore_all() {
  if [[ "${changes_started}" == "1" ]]; then
    for skill_name in "${skill_names[@]}"; do
      skill_target="${skills_root}/${skill_name}"
      backup_target="${backup_root}/${skill_name}"
      rm -rf "${skill_target}"
      if [[ -e "${backup_target}" ]]; then
        mv "${backup_target}" "${skill_target}"
        echo "Restored previous skill ${skill_name}" >&2
      fi
    done
  fi
  rm -rf "${staging_root}"
}
trap restore_all ERR

for skill_name in "${skill_names[@]}"; do
  staged_skill="${staging_root}/${skill_name}"
  cp -a "skills/${skill_name}" "${staged_skill}"
  python3 "${validator}" "${staged_skill}"
  python3 "${package_validator}" "${staged_skill}"
done

changes_started=1
for skill_name in "${skill_names[@]}"; do
  skill_target="${skills_root}/${skill_name}"
  if [[ -e "${skill_target}" ]]; then
    mv "${skill_target}" "${backup_root}/${skill_name}"
  fi
done

for skill_name in "${skill_names[@]}"; do
  skill_target="${skills_root}/${skill_name}"
  mv "${staging_root}/${skill_name}" "${skill_target}"
  python3 "${validator}" "${skill_target}"
  python3 "${package_validator}" "${skill_target}"
done

trap - ERR
rm -rf "${staging_root}"
echo "Installed managed CppStudio skills. Backup root: ${backup_root}"
```

Windows PowerShell:

```powershell
Set-Location C:\path\to\CppStudio
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$SkillsRoot = Join-Path $CodexHome "skills"
$SkillNames = @("cpp-cuda-vulkan-studio", "native-cpp-gui-hud", "cppstudio-project-planner", "agentic-control-harness", "viewport-session-testing", "important-instruction-ledger", "vulkan-compute-sync")
$SystemValidator = Join-Path $SkillsRoot ".system\skill-creator\scripts\quick_validate.py"
$RepoValidator = Join-Path (Get-Location) "scripts\quick_validate_skill.py"
$PackageValidator = Join-Path (Get-Location) "scripts\validate_skill_package.py"
if (Test-Path $SystemValidator) {
  $Validator = $SystemValidator
} elseif (Test-Path $RepoValidator) {
  $Validator = $RepoValidator
} else {
  throw "Missing skill validator: $SystemValidator or $RepoValidator"
}
if (-not (Test-Path $PackageValidator)) {
  throw "Missing package validator: $PackageValidator"
}
$StagingRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("cppstudio-skill-" + [System.Guid]::NewGuid())

New-Item -ItemType Directory -Force $StagingRoot | Out-Null
New-Item -ItemType Directory -Force $SkillsRoot | Out-Null
if ((Get-Item $SkillsRoot).LinkType) {
  throw "Refusing symlinked Codex skills root: $SkillsRoot"
}

foreach ($SkillName in $SkillNames) {
  $SkillSource = Join-Path ".\skills" $SkillName
  $SkillTarget = Join-Path $SkillsRoot $SkillName
  if (Test-Path $SkillTarget) {
    $TargetItem = Get-Item $SkillTarget
    if ($TargetItem.LinkType) {
      throw "Refusing symlinked skill target: $SkillTarget"
    }
  }
  if (-not (Test-Path (Join-Path $SkillSource "SKILL.md"))) {
    throw "Missing managed skill source: $SkillSource"
  }
}

try {
  foreach ($SkillName in $SkillNames) {
    $SkillSource = Join-Path ".\skills" $SkillName
    $StagedSkill = Join-Path $StagingRoot $SkillName
    Copy-Item -Recurse $SkillSource $StagedSkill
    python $Validator $StagedSkill
    python $PackageValidator $StagedSkill
  }

  $BackupRoot = Join-Path $CodexHome ("cppstudio-skill-backup." + [System.Guid]::NewGuid())
  New-Item -ItemType Directory -Force $BackupRoot | Out-Null
  $ChangesStarted = $true

  foreach ($SkillName in $SkillNames) {
    $SkillTarget = Join-Path $SkillsRoot $SkillName
    if (Test-Path $SkillTarget) {
      Move-Item $SkillTarget (Join-Path $BackupRoot $SkillName)
    }
  }

  foreach ($SkillName in $SkillNames) {
    $SkillTarget = Join-Path $SkillsRoot $SkillName
    $StagedSkill = Join-Path $StagingRoot $SkillName
    Move-Item $StagedSkill $SkillTarget
    python $Validator $SkillTarget
    python $PackageValidator $SkillTarget
  }

  Write-Host "Installed managed CppStudio skills. Backup root: $BackupRoot"
} catch {
  if ($ChangesStarted) {
    foreach ($SkillName in $SkillNames) {
      $SkillTarget = Join-Path $SkillsRoot $SkillName
      $BackupTarget = Join-Path $BackupRoot $SkillName
      if (Test-Path $SkillTarget) {
        Remove-Item -Recurse -Force $SkillTarget
      }
      if (Test-Path $BackupTarget) {
        Move-Item $BackupTarget $SkillTarget
        Write-Error "Restored previous skill $SkillName"
      }
    }
  }
  throw
} finally {
  if (Test-Path $StagingRoot) {
    Remove-Item -Recurse -Force $StagingRoot
  }
}
```

Restart Codex after manual installation so changed skill metadata is rediscovered.

## Optional AGENTS.md Relay

The user-level `AGENTS.md` relay is intentionally tiny. It only tells agents to load
`cpp-cuda-vulkan-studio` for native C++ GPU, realtime rendering/visualization, C++ GPU code-map,
Vulkan, CUDA, or mixed CUDA/Vulkan work. The full C++ GPU mindset lives inside the skill.

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
$CppStudioSkillTarget = Join-Path $SkillsRoot "cpp-cuda-vulkan-studio"
$DonorRoot = Join-Path $CppStudioSkillTarget "references\donor-library"
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
