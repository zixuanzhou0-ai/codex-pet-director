param(
    [string]$Repo = "zixuanzhou0-ai/codex-pet-director",
    [string]$Branch = "main",
    [string]$InstallRoot = "",
    [string]$AgentsInstallRoot = "",
    [switch]$SkipAgentsMirror,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$SkillName = "codex-pet-director"

function Write-Step {
    param([string]$Message)
    Write-Host "[codex-pet-director] $Message"
}

function Write-NextStep {
    Write-Step "Next step: restart Codex if needed, then paste this into Codex:"
    Write-Host "/create-pet"
}

function Get-DefaultInstallRoot {
    if ($env:CODEX_HOME) {
        return (Join-Path $env:CODEX_HOME "skills")
    }
    return (Join-Path (Join-Path $HOME ".codex") "skills")
}

function Get-DefaultAgentsInstallRoot {
    if ($env:AGENTS_HOME) {
        return (Join-Path $env:AGENTS_HOME "skills")
    }
    return (Join-Path (Join-Path $HOME ".agents") "skills")
}

function Get-NormalizedPath {
    param([string]$Path)

    $trimChars = [char[]]@(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    return [System.IO.Path]::GetFullPath($Path).TrimEnd($trimChars)
}

function Assert-Inside {
    param(
        [string]$Path,
        [string]$Parent
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullParent = [System.IO.Path]::GetFullPath($Parent)
    if (-not $fullParent.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullParent = $fullParent + [System.IO.Path]::DirectorySeparatorChar
    }
    if (-not $fullPath.StartsWith($fullParent, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to write outside expected parent. Path: $fullPath Parent: $fullParent"
    }
}

function Get-LocalSkillSource {
    $roots = @()
    if ($PSScriptRoot) {
        $roots += $PSScriptRoot
    }
    if ($PSCommandPath) {
        $roots += (Split-Path -Parent $PSCommandPath)
    }
    $roots += (Get-Location).Path

    foreach ($root in ($roots | Select-Object -Unique)) {
        $candidate = Join-Path $root $SkillName
        if (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md")) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Get-RemoteSkillSource {
    param(
        [string]$RepoSlug,
        [string]$RepoBranch
    )

    if ([string]::IsNullOrWhiteSpace($RepoSlug) -or $RepoSlug -like "YOUR_GITHUB_USER/*") {
        throw "Set the real GitHub repo first. Replace YOUR_GITHUB_USER/codex-pet-director in install.ps1, or run with -Repo owner/repo."
    }

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-pet-director-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    $zipPath = Join-Path $tempRoot "source.zip"
    $archiveUrl = "https://github.com/$RepoSlug/archive/refs/heads/$RepoBranch.zip"
    Write-Step "Downloading $archiveUrl"
    Invoke-WebRequest -UseBasicParsing -Uri $archiveUrl -OutFile $zipPath

    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

    $skill = Get-ChildItem -Path $tempRoot -Directory -Recurse -Filter $SkillName |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") } |
        Select-Object -First 1

    if (-not $skill) {
        throw "Could not find $SkillName/SKILL.md in the downloaded archive."
    }

    return $skill.FullName
}

function Invoke-EnvironmentCheck {
    param([string]$InstalledSkill)

    $checkScript = Join-Path $InstalledSkill "scripts/check_pet_environment.py"
    if (-not (Test-Path -LiteralPath $checkScript)) {
        Write-Warning "Environment check script was not found."
        return
    }

    $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
    $python = Get-Command python -ErrorAction SilentlyContinue

    if ($pyLauncher) {
        Write-Step "Running environment check"
        & $pyLauncher.Source -3 $checkScript --fix
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Environment check reported issues. The skill was installed, but Codex pet support may still need attention."
        }
        return
    }

    if ($python) {
        Write-Step "Running environment check"
        & $python.Source $checkScript --fix
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Environment check reported issues. The skill was installed, but Codex pet support may still need attention."
        }
        return
    }

    Write-Warning "Python was not found, so the environment check was skipped."
}

function Install-SkillCopy {
    param(
        [string]$Source,
        [string]$Root,
        [string]$Label
    )

    $destination = Join-Path $Root $SkillName
    Write-Step "$Label target: $destination"

    if ($DryRun) {
        return $destination
    }

    Assert-Inside -Path $destination -Parent $Root
    New-Item -ItemType Directory -Path $Root -Force | Out-Null

    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }

    Copy-Item -LiteralPath $Source -Destination $destination -Recurse
    return $destination
}

if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    $InstallRoot = Get-DefaultInstallRoot
}
if ([string]::IsNullOrWhiteSpace($AgentsInstallRoot)) {
    $AgentsInstallRoot = Get-DefaultAgentsInstallRoot
}

$source = Get-LocalSkillSource
if (-not $source) {
    $source = Get-RemoteSkillSource -RepoSlug $Repo -RepoBranch $Branch
}

$installRootPath = Get-NormalizedPath -Path $InstallRoot
$agentsRootPath = Get-NormalizedPath -Path $AgentsInstallRoot
$shouldMirrorToAgents = (-not $SkipAgentsMirror) -and
    (-not [string]::Equals($installRootPath, $agentsRootPath, [System.StringComparison]::OrdinalIgnoreCase))

Write-Step "Source: $source"
Write-Step "Codex skill root: $InstallRoot"
if ($shouldMirrorToAgents) {
    Write-Step "Agents skill mirror root: $AgentsInstallRoot"
}

if ($DryRun) {
    Install-SkillCopy -Source $source -Root $InstallRoot -Label "Codex skill" | Out-Null
    if ($shouldMirrorToAgents) {
        Install-SkillCopy -Source $source -Root $AgentsInstallRoot -Label "Agents skill mirror" | Out-Null
    }
    Write-Step "Dry run only. No files were copied."
    exit 0
}

$destination = Install-SkillCopy -Source $source -Root $InstallRoot -Label "Codex skill"
Write-Step "Installed $SkillName to Codex skills"

if ($shouldMirrorToAgents) {
    Install-SkillCopy -Source $source -Root $AgentsInstallRoot -Label "Agents skill mirror" | Out-Null
    Write-Step "Mirrored $SkillName to Agents skills for skill search discovery"
}

Invoke-EnvironmentCheck -InstalledSkill $destination

Write-Step "Done. Restart Codex if the skill list has not refreshed yet."
Write-NextStep
