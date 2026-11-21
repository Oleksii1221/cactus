[CmdletBinding()]
param(
    [string]$DistributionName = 'CactusUbuntu',
    [string]$InstallRoot = 'D:\CactusBack\wsl\CactusUbuntu'
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'WSL is unavailable. Run wsl --install --no-distribution as Administrator and reboot.'
}

$status = (& wsl.exe --status 2>&1 | Out-String)
if ($status -match 'restart|reboot') {
    throw 'Windows must be restarted before the WSL distribution can be installed.'
}

$existing = (& wsl.exe --list --quiet 2>$null) -replace "`0", '' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
if ($existing -contains $DistributionName) {
    throw "The target WSL distribution '$DistributionName' already exists. Nothing was changed."
}
if ($existing -contains 'Ubuntu-20.04') {
    throw "An existing Ubuntu-20.04 distribution was found. Refusing to export or unregister user-owned data."
}

New-Item -ItemType Directory -Path (Split-Path -Parent $InstallRoot) -Force | Out-Null
& wsl.exe --install --distribution Ubuntu-20.04 --no-launch --web-download
if ($LASTEXITCODE -ne 0) {
    throw 'Ubuntu 20.04 installation failed. A Windows restart may still be required.'
}

$export = Join-Path (Split-Path -Parent $InstallRoot) 'ubuntu-20.04.tar'
& wsl.exe --export Ubuntu-20.04 $export
if ($LASTEXITCODE -ne 0) { throw 'WSL export failed.' }
& wsl.exe --unregister Ubuntu-20.04
New-Item -ItemType Directory -Path $InstallRoot -Force | Out-Null
& wsl.exe --import $DistributionName $InstallRoot $export --version 2
if ($LASTEXITCODE -ne 0) { throw 'WSL import to drive D failed.' }
Remove-Item -LiteralPath $export

$configureUser = 'id -u cactus >/dev/null 2>&1 || useradd --create-home --shell /bin/bash cactus; usermod -aG sudo cactus; printf "cactus ALL=(ALL) NOPASSWD:ALL\n" > /etc/sudoers.d/cactus; chmod 0440 /etc/sudoers.d/cactus; printf "[user]\ndefault=cactus\n" > /etc/wsl.conf'
& wsl.exe -d $DistributionName -u root -- bash -lc $configureUser
if ($LASTEXITCODE -ne 0) { throw 'The WSL distribution was imported, but the cactus build user could not be configured.' }
& wsl.exe --terminate $DistributionName

Write-Host "$DistributionName was imported to $InstallRoot"
Write-Host "Launch it with: wsl -d $DistributionName"
