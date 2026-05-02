param(
    [string]$Repo = "zixuanzhou0-ai/codex-pet-director",
    [string]$Branch = "main",
    [string]$InstallRoot = "",
    [string]$AgentsInstallRoot = "",
    [string]$CodexHome = "",
    [string]$MarketplaceRoot = "",
    [string]$PluginRoot = "",
    [switch]$SkipAgentsMirror,
    [switch]$SkipConfig,
    [switch]$SkipEnvironmentCheck,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[codex-pet-director] $Message"
}

function Get-LocalPluginInstaller {
    $roots = @()
    if ($PSScriptRoot) {
        $roots += $PSScriptRoot
    }
    if ($PSCommandPath) {
        $roots += (Split-Path -Parent $PSCommandPath)
    }
    $roots += (Get-Location).Path

    foreach ($root in ($roots | Select-Object -Unique)) {
        $candidate = Join-Path $root "install-plugin.ps1"
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Get-CodexHomeFromInstallRoot {
    param([string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return ""
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if ([System.IO.Path]::GetFileName($fullPath).Equals("skills", [System.StringComparison]::OrdinalIgnoreCase)) {
        return (Split-Path -Parent $fullPath)
    }

    Write-Warning "InstallRoot is only mapped to plugin mode when it ends with a skills directory. Ignoring custom InstallRoot: $Path"
    return ""
}

function Get-DefaultCodexHome {
    if ($env:CODEX_HOME) {
        return $env:CODEX_HOME
    }
    return (Join-Path $HOME ".codex")
}

function Invoke-EnvironmentCheck {
    param([string]$EffectiveCodexHome)

    $checkScript = Join-Path $EffectiveCodexHome "skills\codex-pet-director\scripts\check_pet_environment.py"
    if (-not (Test-Path -LiteralPath $checkScript)) {
        Write-Warning "Environment check script was not found after installation."
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

function Get-RemotePluginInstaller {
    param(
        [string]$RepoSlug,
        [string]$RepoBranch
    )

    if ([string]::IsNullOrWhiteSpace($RepoSlug) -or $RepoSlug -like "YOUR_GITHUB_USER/*") {
        throw "Set a real GitHub repo first, or run this script from a local clone."
    }

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-pet-director-installer-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    $installer = Join-Path $tempRoot "install-plugin.ps1"
    $url = "https://raw.githubusercontent.com/$RepoSlug/$RepoBranch/install-plugin.ps1"

    Write-Step "Downloading plugin installer: $url"
    Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $installer
    return $installer
}

$installer = Get-LocalPluginInstaller
if (-not $installer) {
    $installer = Get-RemotePluginInstaller -RepoSlug $Repo -RepoBranch $Branch
}

$pluginArgs = @{
    Repo = $Repo
    Branch = $Branch
}

$codexHomeFromInstallRoot = Get-CodexHomeFromInstallRoot -Path $InstallRoot
$effectiveCodexHome = Get-DefaultCodexHome
if (-not [string]::IsNullOrWhiteSpace($CodexHome)) {
    $pluginArgs["CodexHome"] = $CodexHome
    $effectiveCodexHome = $CodexHome
} elseif (-not [string]::IsNullOrWhiteSpace($codexHomeFromInstallRoot)) {
    $pluginArgs["CodexHome"] = $codexHomeFromInstallRoot
    $effectiveCodexHome = $codexHomeFromInstallRoot
}
if (-not [string]::IsNullOrWhiteSpace($AgentsInstallRoot)) {
    $pluginArgs["AgentsSkillRoot"] = $AgentsInstallRoot
}
if (-not [string]::IsNullOrWhiteSpace($MarketplaceRoot)) {
    $pluginArgs["MarketplaceRoot"] = $MarketplaceRoot
}
if (-not [string]::IsNullOrWhiteSpace($PluginRoot)) {
    $pluginArgs["PluginRoot"] = $PluginRoot
}
if ($SkipAgentsMirror) {
    $pluginArgs["SkipAgentsSkillMirror"] = $true
}
if ($SkipConfig) {
    $pluginArgs["SkipConfig"] = $true
}
if ($DryRun) {
    $pluginArgs["DryRun"] = $true
}

Write-Step "Running full local plugin installer."
& $installer @pluginArgs

if (-not $DryRun -and -not $SkipEnvironmentCheck) {
    Invoke-EnvironmentCheck -EffectiveCodexHome $effectiveCodexHome
}
