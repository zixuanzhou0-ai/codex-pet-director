param(
    [string]$Repo = "zixuanzhou0-ai/codex-pet-director",
    [string]$Branch = "main",
    [string]$PluginRoot = "",
    [string]$MarketplaceRoot = "",
    [string]$CodexHome = "",
    [string]$AgentsSkillRoot = "",
    [switch]$SkipAgentsSkillMirror,
    [switch]$SkipConfig,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$PluginName = "codex-pet-director"
$MarketplaceName = "local-codex-pet-director"

function Write-Step {
    param([string]$Message)
    Write-Host "[codex-pet-director plugin] $Message"
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

function Copy-CleanDirectory {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$AllowedParent
    )

    Assert-Inside -Path $Destination -Parent $AllowedParent
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    New-Item -ItemType Directory -Path (Split-Path -Parent $Destination) -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse
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

function Test-RepoRoot {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    $hasSkill = (
        (Test-Path -LiteralPath (Join-Path $Path "skills\$PluginName\SKILL.md")) -or
        (Test-Path -LiteralPath (Join-Path $Path "$PluginName\SKILL.md"))
    )
    return (
        $hasSkill -and
        (Test-Path -LiteralPath (Join-Path $Path "commands\create-pet.md")) -and
        (Test-Path -LiteralPath (Join-Path $Path ".codex-plugin\plugin.json"))
    )
}

function Get-SkillSourceRoot {
    param([string]$RepoRoot)

    $canonical = Join-Path (Join-Path $RepoRoot "skills") $PluginName
    if (Test-Path -LiteralPath (Join-Path $canonical "SKILL.md")) {
        return $canonical
    }
    return (Join-Path $RepoRoot $PluginName)
}

function Get-SkillSourcePath {
    param([string]$Source)

    $normalized = ([System.IO.Path]::GetFullPath($Source) -replace "/", "\")
    if ($normalized -like "*\skills\$PluginName") {
        return "skills/$PluginName/SKILL.md"
    }
    return "$PluginName/SKILL.md"
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
        [string]$AgentsSkillRoot,
        [string]$InstalledSkill,
        [string]$SourcePath
    )

    if (-not (Test-Path -LiteralPath (Join-Path $InstalledSkill "SKILL.md"))) {
        Write-Step "Agents skill lock skipped because the Agents mirror was not installed."
        return
    }

    $agentsHome = Split-Path -Parent ([System.IO.Path]::GetFullPath($AgentsSkillRoot))
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
    $existing = $lock.skills.PSObject.Properties[$PluginName]
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

    $lock.skills | Add-Member -Force -NotePropertyName $PluginName -NotePropertyValue $entry
    Write-JsonFile -Path $lockPath -Value $lock
    Write-Step "Updated Agents skill lock: $lockPath"
}

function Get-RemoteRepoRoot {
    param(
        [string]$RepoSlug,
        [string]$RepoBranch
    )

    if ([string]::IsNullOrWhiteSpace($RepoSlug) -or $RepoSlug -like "YOUR_GITHUB_USER/*") {
        throw "Set a real GitHub repo first, or run this script from a local clone."
    }

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-pet-director-plugin-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    $zipPath = Join-Path $tempRoot "source.zip"
    $archiveUrl = "https://github.com/$RepoSlug/archive/refs/heads/$RepoBranch.zip"
    Write-Step "Downloading $archiveUrl"
    Invoke-WebRequest -UseBasicParsing -Uri $archiveUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

    $repoRoot = Get-ChildItem -Path $tempRoot -Directory -Recurse |
        Where-Object { Test-RepoRoot -Path $_.FullName } |
        Select-Object -First 1

    if (-not $repoRoot) {
        throw "Could not find a valid $PluginName repo root in the downloaded archive."
    }

    return $repoRoot.FullName
}

function Resolve-RepoRoot {
    $candidates = @()
    if ($PSScriptRoot) {
        $candidates += $PSScriptRoot
    }
    if ($PSCommandPath) {
        $candidates += (Split-Path -Parent $PSCommandPath)
    }
    $candidates += (Get-Location).Path

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (Test-RepoRoot -Path $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return Get-RemoteRepoRoot -RepoSlug $Repo -RepoBranch $Branch
}

function Update-MarketplaceJson {
    param([string]$Path)

    $marketplace = Read-JsonFile -Path $Path
    if (-not $marketplace) {
        $marketplace = [pscustomobject]@{
            name = $MarketplaceName
            interface = [pscustomobject]@{
                displayName = "Local Codex Pet Director"
            }
            plugins = @()
        }
    }

    if (-not $marketplace.PSObject.Properties["name"]) {
        $marketplace | Add-Member -NotePropertyName name -NotePropertyValue $MarketplaceName
    }
    if (-not $marketplace.PSObject.Properties["interface"] -or -not $marketplace.interface) {
        $marketplace | Add-Member -Force -NotePropertyName interface -NotePropertyValue ([pscustomobject]@{
            displayName = "Local Codex Pet Director"
        })
    }
    if (-not $marketplace.interface.PSObject.Properties["displayName"]) {
        $marketplace.interface | Add-Member -NotePropertyName displayName -NotePropertyValue "Local Codex Pet Director"
    }
    if (-not $marketplace.PSObject.Properties["plugins"] -or -not $marketplace.plugins) {
        $marketplace | Add-Member -Force -NotePropertyName plugins -NotePropertyValue @()
    }

    $entry = [pscustomobject]@{
        name = $PluginName
        source = [pscustomobject]@{
            source = "local"
            path = "./plugins/$PluginName"
        }
        policy = [pscustomobject]@{
            installation = "AVAILABLE"
            authentication = "ON_INSTALL"
        }
        category = "Productivity"
    }

    $plugins = @()
    foreach ($plugin in @($marketplace.plugins)) {
        if ($plugin -and $plugin.name -and $plugin.name -ne $PluginName) {
            $plugins += $plugin
        }
    }
    $plugins += $entry
    $marketplace | Add-Member -Force -NotePropertyName plugins -NotePropertyValue $plugins

    Write-JsonFile -Path $Path -Value $marketplace
}

function Update-CodexConfig {
    param(
        [string]$ConfigPath,
        [string]$SourceRoot
    )

    New-Item -ItemType Directory -Path (Split-Path -Parent $ConfigPath) -Force | Out-Null
    if (-not (Test-Path -LiteralPath $ConfigPath)) {
        Set-Content -LiteralPath $ConfigPath -Value "" -Encoding UTF8
    }

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $source = [System.IO.Path]::GetFullPath($SourceRoot)
    $marketplaceBlock = @"
[marketplaces.$MarketplaceName]
last_updated = "$timestamp"
source_type = "local"
source = '$source'
"@

    $pluginBlock = @"
[plugins."$PluginName@$MarketplaceName"]
enabled = true
"@

    $content = Get-Content -Raw -LiteralPath $ConfigPath
    $backup = "$ConfigPath.bak-$(Get-Date -Format yyyyMMddHHmmss)"
    Copy-Item -LiteralPath $ConfigPath -Destination $backup -Force

    $marketplaceHeader = "[marketplaces.$MarketplaceName]"
    $pluginHeader = "[plugins.`"$PluginName@$MarketplaceName`"]"
    $lines = [regex]::Split($content, "\r?\n")
    $kept = New-Object System.Collections.Generic.List[string]
    $skip = $false

    foreach ($line in $lines) {
        if ($line -match "^\s*\[.+\]\s*$") {
            $header = $line.Trim()
            if ($header -eq $marketplaceHeader -or $header -eq $pluginHeader) {
                $skip = $true
                continue
            }
            $skip = $false
        }

        if (-not $skip) {
            $kept.Add($line)
        }
    }

    $content = ($kept.ToArray() -join "`r`n").TrimEnd()
    $content = $content + "`r`n`r`n" + $marketplaceBlock + "`r`n`r`n" + $pluginBlock + "`r`n"

    Set-Content -LiteralPath $ConfigPath -Value $content -Encoding UTF8
    Write-Step "Backed up Codex config to $backup"
}

$RepoRoot = Resolve-RepoRoot
$SkillSource = Get-SkillSourceRoot -RepoRoot $RepoRoot
$CommandsSource = Join-Path $RepoRoot "commands"
$ManifestSource = Join-Path $RepoRoot ".codex-plugin\plugin.json"

if (-not (Test-Path -LiteralPath (Join-Path $SkillSource "SKILL.md"))) {
    throw "Could not find $PluginName/SKILL.md under $RepoRoot"
}
if (-not (Test-Path -LiteralPath (Join-Path $CommandsSource "create-pet.md"))) {
    throw "Could not find commands/create-pet.md under $RepoRoot"
}
if (-not (Test-Path -LiteralPath $ManifestSource)) {
    throw "Could not find .codex-plugin/plugin.json under $RepoRoot"
}

if ([string]::IsNullOrWhiteSpace($MarketplaceRoot)) {
    $MarketplaceRoot = $HOME
}
if ([string]::IsNullOrWhiteSpace($PluginRoot)) {
    $PluginRoot = Join-Path (Join-Path $MarketplaceRoot "plugins") $PluginName
}
if ([string]::IsNullOrWhiteSpace($AgentsSkillRoot)) {
    $AgentsSkillRoot = Join-Path (Join-Path $MarketplaceRoot ".agents") "skills"
}
if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if ($env:CODEX_HOME) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME ".codex"
    }
}

$PluginParent = Join-Path $MarketplaceRoot "plugins"
$MarketplacePath = Join-Path (Join-Path $MarketplaceRoot ".agents") "plugins\marketplace.json"
$ConfigPath = Join-Path $CodexHome "config.toml"
$InstalledSkillRoot = Join-Path (Join-Path $CodexHome "skills") $PluginName
$AgentsInstalledSkillRoot = Join-Path $AgentsSkillRoot $PluginName

Assert-Inside -Path $PluginRoot -Parent $PluginParent
Assert-Inside -Path $MarketplacePath -Parent $MarketplaceRoot
Assert-Inside -Path $ConfigPath -Parent $CodexHome
Assert-Inside -Path $AgentsInstalledSkillRoot -Parent $AgentsSkillRoot

Write-Step "Repo source: $RepoRoot"
Write-Step "Plugin target: $PluginRoot"
Write-Step "Marketplace: $MarketplacePath"
Write-Step "Codex config: $ConfigPath"
if (-not $SkipAgentsSkillMirror) {
    Write-Step "Agents skill mirror: $AgentsInstalledSkillRoot"
}

if ($DryRun) {
    Write-Step "Dry run only. No files were changed."
    exit 0
}

New-Item -ItemType Directory -Path $PluginRoot -Force | Out-Null

Copy-CleanDirectory -Source $SkillSource -Destination (Join-Path (Join-Path $PluginRoot "skills") $PluginName) -AllowedParent $PluginRoot
Copy-CleanDirectory -Source $CommandsSource -Destination (Join-Path $PluginRoot "commands") -AllowedParent $PluginRoot

New-Item -ItemType Directory -Path (Join-Path $PluginRoot ".codex-plugin") -Force | Out-Null
$manifest = Read-JsonFile -Path $ManifestSource
$manifest.skills = "./skills/"
$manifest | Add-Member -Force -NotePropertyName commands -NotePropertyValue "./commands/"
Write-JsonFile -Path (Join-Path $PluginRoot ".codex-plugin\plugin.json") -Value $manifest

New-Item -ItemType Directory -Path (Split-Path -Parent $InstalledSkillRoot) -Force | Out-Null
Copy-CleanDirectory -Source $SkillSource -Destination $InstalledSkillRoot -AllowedParent (Join-Path $CodexHome "skills")

if (-not $SkipAgentsSkillMirror) {
    New-Item -ItemType Directory -Path $AgentsSkillRoot -Force | Out-Null
    Copy-CleanDirectory -Source $SkillSource -Destination $AgentsInstalledSkillRoot -AllowedParent $AgentsSkillRoot
    Update-AgentsSkillLock -AgentsSkillRoot $AgentsSkillRoot -InstalledSkill $AgentsInstalledSkillRoot -SourcePath (Get-SkillSourcePath -Source $SkillSource)
}

Update-MarketplaceJson -Path $MarketplacePath
if (-not $SkipConfig) {
    Update-CodexConfig -ConfigPath $ConfigPath -SourceRoot $MarketplaceRoot
}

Write-Step "Installed local plugin package metadata."
if (-not $SkipAgentsSkillMirror) {
    Write-Step "Mirrored $PluginName to Agents skills for skill search discovery."
}
Write-Step "Current Codex desktop builds do not expose third-party plugin commands in the slash menu."
Write-Step "Restart Codex if needed, then send /create-pet as a normal chat message to start the flow."
