$ErrorActionPreference = 'Stop'

function Ensure-Winget {
    if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        throw 'winget.exe was not found. Install App Installer from Microsoft Store and rerun this script.'
    }
}

function Resolve-WingetPackageId {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$CandidateIds
    )

    foreach ($candidateId in $CandidateIds) {
        & winget.exe show --id $candidateId --exact --accept-source-agreements *> $null

        if ($LASTEXITCODE -eq 0) {
            return $candidateId
        }
    }

    return $null
}

function Test-WingetPackageInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId
    )

    & winget.exe list --id $PackageId --exact --accept-source-agreements *> $null

    return $LASTEXITCODE -eq 0
}

function Ensure-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string[]]$CandidateIds
    )

    $packageId = Resolve-WingetPackageId -CandidateIds $CandidateIds

    if (-not $packageId) {
        Write-Warning "Skipping $Name because none of the candidate winget IDs are available: $($CandidateIds -join ', ')"
        return
    }

    if (Test-WingetPackageInstalled -PackageId $packageId) {
        Write-Host "$Name is already installed."
        return
    }

    Write-Host "Installing $Name ($packageId)..."
    & winget.exe install --id $packageId --exact --silent --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {
        throw "winget install failed for $Name ($packageId) with exit code $LASTEXITCODE."
    }
}

function Install-WindowsPackages {
    Ensure-Winget

    $packages = @(
        @{ Name = 'PowerToys'; Ids = @('Microsoft.PowerToys') },
        @{ Name = 'Docker Desktop'; Ids = @('Docker.DockerDesktop') },
        @{ Name = 'Tailscale'; Ids = @('Tailscale.Tailscale') },
        @{ Name = 'Visual Studio Code'; Ids = @('Microsoft.VisualStudioCode') },
        @{ Name = 'WezTerm'; Ids = @('wez.wezterm') },
        @{ Name = 'PowerShell'; Ids = @('Microsoft.PowerShell') },
        @{ Name = 'Google Chrome'; Ids = @('Google.Chrome') },
        @{ Name = 'Firefox'; Ids = @('Mozilla.Firefox') },
        @{ Name = 'Postman'; Ids = @('Postman.Postman') },
        @{ Name = 'Spotify'; Ids = @('Spotify.Spotify') },
        @{ Name = 'Zoom'; Ids = @('Zoom.Zoom') },
        @{ Name = 'Anki'; Ids = @('Anki.Anki') },
        @{ Name = 'Calibre'; Ids = @('calibre.calibre') },
        @{ Name = 'Barrier'; Ids = @('DebaucheeOpenSourceGroup.Barrier', 'Barrier.Barrier') },
        @{ Name = 'Seafile'; Ids = @('Haiwen.Seafile', 'Seafile.Seafile') },
        @{ Name = 'Fira Code'; Ids = @('Fonticons,Inc.FiraCode', 'Mozilla.FiraCode') },
        @{ Name = 'FiraCode Nerd Font'; Ids = @('DEVCOM.FiraCodeNerdFont', 'RyanGosling.NerdFonts.FiraCode') },
        @{ Name = 'JetBrainsMono Nerd Font'; Ids = @('DEVCOM.JetBrainsMonoNerdFont', 'RyanGosling.NerdFonts.JetBrainsMono') },
        @{ Name = 'Hack Font'; Ids = @('SourceFoundry.HackFonts', 'HackFont.Hack') }
    )

    foreach ($package in $packages) {
        Ensure-WingetPackage -Name $package.Name -CandidateIds $package.Ids
    }
}

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

$repoRootWindows = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Install-WindowsPackages

$existingDistros = Get-AvailableWslDistros
if (-not $existingDistros) {
    Write-Host 'No WSL distro found. Installing Ubuntu...'
    & wsl.exe --install -d Ubuntu
    Install-WezTermConfig -RepoRootWindows $repoRootWindows
    Write-Host 'WSL install started. Reboot if prompted, then rerun ./windows/setup.ps1.'
    exit 0
}

$distro = Get-DefaultWslDistro
if (-not $distro) {
    throw 'Unable to determine WSL distro. Run wsl -l -v and set a default distro.'
}

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
