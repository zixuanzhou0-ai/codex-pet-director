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
$AliasSkillName = "create-pet"

function Write-Step {
    param([string]$Message)
    Write-Host "[codex-pet-director] $Message"
}

function Write-NextStep {
    Write-Step "Next step: restart Codex if needed, then search create-pet in the slash menu or paste this into Codex:"
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
    param([string]$Name = $SkillName)

    $roots = @()
    if ($PSScriptRoot) {
        $roots += $PSScriptRoot
    }
    if ($PSCommandPath) {
        $roots += (Split-Path -Parent $PSCommandPath)
    }
    $roots += (Get-Location).Path

    foreach ($root in ($roots | Select-Object -Unique)) {
        $candidate = Join-Path (Join-Path $root "skills") $Name
        if (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md")) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }

        $candidate = Join-Path $root $Name
        if (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md")) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Get-RemoteSkillSource {
    param(
        [string]$RepoSlug,
        [string]$RepoBranch,
        [string]$Name = $SkillName
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

    $canonicalSkill = Get-ChildItem -Path $tempRoot -File -Recurse -Filter "SKILL.md" |
        Where-Object { ($_.FullName -replace "/", "\") -like "*\skills\$Name\SKILL.md" } |
        Select-Object -First 1

    if (-not $canonicalSkill) {
        $canonicalSkill = Get-ChildItem -Path $tempRoot -File -Recurse -Filter "SKILL.md" |
            Where-Object { ($_.FullName -replace "/", "\") -like "*\$Name\SKILL.md" } |
            Select-Object -First 1
    }

    if (-not $canonicalSkill) {
        throw "Could not find $Name/SKILL.md in the downloaded archive."
    }

    return (Split-Path -Parent $canonicalSkill.FullName)
}

function Get-SkillSourcePath {
    param(
        [string]$Source,
        [string]$Name = $SkillName
    )

    $normalized = ([System.IO.Path]::GetFullPath($Source) -replace "/", "\")
    if ($normalized -like "*\skills\$Name") {
        return "skills/$Name/SKILL.md"
    }
    return "$Name/SKILL.md"
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

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }
    $raw = Get-Content -Raw -LiteralPath $Path
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return $null
    }
    return $raw | ConvertFrom-Json
}

function Write-JsonFile {
    param(
        [string]$Path,
        [object]$Value
    )
    $json = $Value | ConvertTo-Json -Depth 20
    New-Item -ItemType Directory -Path (Split-Path -Parent $Path) -Force | Out-Null
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Get-SkillFolderHash {
    param([string]$Path)

    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    $stream = New-Object System.IO.MemoryStream
    $root = [System.IO.Path]::GetFullPath($Path)
    $trimChars = [char[]]@("\", "/")

    foreach ($file in (Get-ChildItem -LiteralPath $Path -Recurse -File | Sort-Object FullName)) {
        $relative = [System.IO.Path]::GetFullPath($file.FullName).Substring($root.Length).TrimStart($trimChars) -replace "\\", "/"
        $nameBytes = [System.Text.Encoding]::UTF8.GetBytes($relative + "`n")
        $stream.Write($nameBytes, 0, $nameBytes.Length)
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $stream.Write($fileBytes, 0, $fileBytes.Length)
        $stream.WriteByte(10)
    }

    $hashBytes = $sha1.ComputeHash($stream.ToArray())
    $stream.Dispose()
    $sha1.Dispose()
    return -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
}

function Update-AgentsSkillLock {
    param(
        [string]$AgentsInstallRoot,
        [string]$InstalledSkill,
        [string]$SourcePath,
        [string]$Name = $SkillName
    )

    if (-not (Test-Path -LiteralPath (Join-Path $InstalledSkill "SKILL.md"))) {
        Write-Step "Agents skill lock skipped because the Agents mirror was not installed."
        return
    }

    $agentsHome = Split-Path -Parent ([System.IO.Path]::GetFullPath($AgentsInstallRoot))
    $lockPath = Join-Path $agentsHome ".skill-lock.json"
    $lock = Read-JsonFile -Path $lockPath
    if (-not $lock) {
        $lock = [pscustomobject]@{
            version = 3
            skills = [pscustomobject]@{}
        }
    }
    if (-not $lock.PSObject.Properties["version"]) {
        $lock | Add-Member -NotePropertyName version -NotePropertyValue 3
    }
    if (-not $lock.PSObject.Properties["skills"] -or -not $lock.skills) {
        $lock | Add-Member -Force -NotePropertyName skills -NotePropertyValue ([pscustomobject]@{})
    }

    $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    $installedAt = $now
    $existing = $lock.skills.PSObject.Properties[$Name]
    if ($existing -and $existing.Value -and $existing.Value.PSObject.Properties["installedAt"]) {
        $installedAt = $existing.Value.installedAt
    }

    $entry = [pscustomobject]@{
        source = $Repo
        sourceType = "github"
        sourceUrl = "https://github.com/$Repo.git"
        skillPath = $SourcePath
        skillFolderHash = (Get-SkillFolderHash -Path $InstalledSkill)
        installedAt = $installedAt
        updatedAt = $now
    }

    $lock.skills | Add-Member -Force -NotePropertyName $Name -NotePropertyValue $entry
    Write-JsonFile -Path $lockPath -Value $lock
    Write-Step "Updated Agents skill lock: $lockPath"
}

function Install-SkillCopy {
    param(
        [string]$Source,
        [string]$Root,
        [string]$Label,
        [string]$Name = $SkillName
    )

    $destination = Join-Path $Root $Name
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

$source = Get-LocalSkillSource -Name $SkillName
if (-not $source) {
    $source = Get-RemoteSkillSource -RepoSlug $Repo -RepoBranch $Branch -Name $SkillName
}

$aliasSource = Get-LocalSkillSource -Name $AliasSkillName
if (-not $aliasSource) {
    $aliasSource = Get-RemoteSkillSource -RepoSlug $Repo -RepoBranch $Branch -Name $AliasSkillName
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
    Install-SkillCopy -Source $aliasSource -Root $InstallRoot -Label "Codex slash alias skill" -Name $AliasSkillName | Out-Null
    if ($shouldMirrorToAgents) {
        Install-SkillCopy -Source $source -Root $AgentsInstallRoot -Label "Agents skill mirror" | Out-Null
        Install-SkillCopy -Source $aliasSource -Root $AgentsInstallRoot -Label "Agents slash alias mirror" -Name $AliasSkillName | Out-Null
    }
    if (-not $SkipAgentsMirror) {
        Write-Step "Would update Agents skill lock under $AgentsInstallRoot"
    }
    Write-Step "Dry run only. No files were copied."
    exit 0
}

$destination = Install-SkillCopy -Source $source -Root $InstallRoot -Label "Codex skill"
Write-Step "Installed $SkillName to Codex skills"
$aliasDestination = Install-SkillCopy -Source $aliasSource -Root $InstallRoot -Label "Codex slash alias skill" -Name $AliasSkillName
Write-Step "Installed $AliasSkillName slash entry to Codex skills"

if ($shouldMirrorToAgents) {
    Install-SkillCopy -Source $source -Root $AgentsInstallRoot -Label "Agents skill mirror" | Out-Null
    Install-SkillCopy -Source $aliasSource -Root $AgentsInstallRoot -Label "Agents slash alias mirror" -Name $AliasSkillName | Out-Null
    Write-Step "Mirrored $SkillName to Agents skills for skill search discovery"
}

$agentsDestination = Join-Path $AgentsInstallRoot $SkillName
$aliasAgentsDestination = Join-Path $AgentsInstallRoot $AliasSkillName
if (-not $SkipAgentsMirror) {
    Update-AgentsSkillLock -AgentsInstallRoot $AgentsInstallRoot -InstalledSkill $agentsDestination -SourcePath (Get-SkillSourcePath -Source $source -Name $SkillName) -Name $SkillName
    Update-AgentsSkillLock -AgentsInstallRoot $AgentsInstallRoot -InstalledSkill $aliasAgentsDestination -SourcePath (Get-SkillSourcePath -Source $aliasSource -Name $AliasSkillName) -Name $AliasSkillName
}

Invoke-EnvironmentCheck -InstalledSkill $destination

Write-Step "Done. Restart Codex if the skill list has not refreshed yet."
Write-NextStep
