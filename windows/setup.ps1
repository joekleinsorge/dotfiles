$ErrorActionPreference = 'Stop'

function Get-DefaultWslDistro {
    $verboseList = & wsl.exe -l -v 2>$null
    $defaultLine = $verboseList | Where-Object { $_ -match '^\*' } | Select-Object -First 1

    if ($defaultLine) {
        $trimmed = ($defaultLine -replace '^\*\s*', '').Trim()
        return ($trimmed -split '\s+')[0]
    }

    $allDistros = & wsl.exe -l -q 2>$null
    $normalDistros = $allDistros | Where-Object { $_ -and $_.Trim() -and $_ -notmatch '^docker-desktop' }

    if ($normalDistros) {
        return $normalDistros[0].Trim()
    }

    return $null
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'wsl.exe was not found. Please install WSL and rerun this script.'
}

$existingDistros = & wsl.exe -l -q 2>$null | Where-Object { $_ -and $_.Trim() }
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

$bootstrapCmd = "bash '$repoRootWsl/wsl/setup.sh' '$repoRootWsl'"
Write-Host "Running WSL bootstrap in distro '$distro'..."
& wsl.exe -d $distro -- bash -lc $bootstrapCmd

Write-Host 'Windows setup complete (WSL-first mode).'
