$ErrorActionPreference = 'Stop'

function Get-AvailableWslDistros {
    $allDistros = & wsl.exe -l -q 2>$null

    return @(
        $allDistros |
            Where-Object { $_ -and $_.Trim() -and $_ -notmatch '^docker-desktop' } |
            ForEach-Object { $_.Trim() }
    )
}

function Get-DefaultWslDistro {
    $distros = Get-AvailableWslDistros

    if (-not $distros) {
        return $null
    }

    $verboseList = & wsl.exe -l -v 2>$null
    $defaultLine = $verboseList | Where-Object { $_ -match '^\*' } | Select-Object -First 1

    if ($defaultLine) {
        $trimmed = ($defaultLine -replace '^\*\s*', '').Trim()

        foreach ($distro in ($distros | Sort-Object Length -Descending)) {
            if ($trimmed.StartsWith($distro)) {
                return $distro
            }
        }
    }

    return $distros[0]
}

function Install-WezTermConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRootWindows
    )

    $weztermSource = Join-Path $RepoRootWindows 'terminal\wezterm\.wezterm.lua'

    if (-not (Test-Path $weztermSource)) {
        return
    }

    $weztermTarget = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.wezterm.lua'
    $managedSource = $weztermSource -replace '\\', '/'
    $wrapperContent = "return dofile([[${managedSource}]])`n"

    if (Test-Path $weztermTarget) {
        $existingContent = Get-Content -Path $weztermTarget -Raw

        if ($existingContent -ne $wrapperContent -and $existingContent -notmatch 'terminal/wezterm/.wezterm.lua') {
            Move-Item -Path $weztermTarget -Destination "${weztermTarget}.bak" -Force
            Write-Host "Backed up existing WezTerm config to ${weztermTarget}.bak"
        }
    }

    Set-Content -Path $weztermTarget -Value $wrapperContent -NoNewline
    Write-Host "Configured WezTerm at $weztermTarget"
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'wsl.exe was not found. Please install WSL and rerun this script.'
}

$existingDistros = Get-AvailableWslDistros
if (-not $existingDistros) {
    Write-Host 'No WSL distro found. Installing Ubuntu...'
    & wsl.exe --install -d Ubuntu
    Write-Host 'WSL install started. Reboot if prompted, then rerun ./windows/setup.ps1.'
    exit 0
}

$distro = Get-DefaultWslDistro
if (-not $distro) {
    throw 'Unable to determine WSL distro. Run wsl -l -v and set a default distro.'
}

$repoRootWindows = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repoRootWsl = (& wsl.exe -d $distro -- wslpath -a "$repoRootWindows").Trim()

if (-not $repoRootWsl) {
    throw 'Could not map the repo path into WSL.'
}

Write-Host "Running WSL bootstrap in distro '$distro'..."
& wsl.exe -d $distro -- bash "$repoRootWsl/wsl/setup.sh" "$repoRootWsl"

if ($LASTEXITCODE -ne 0) {
    throw "WSL bootstrap failed with exit code $LASTEXITCODE."
}

Install-WezTermConfig -RepoRootWindows $repoRootWindows

Write-Host 'Windows setup complete (WSL-first mode).'
