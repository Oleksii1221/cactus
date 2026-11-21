[CmdletBinding()]
param(
    [string]$BackupRoot = 'D:\CactusBack'
)

$ErrorActionPreference = 'Stop'
$platformTools = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools'
$adb = Join-Path $platformTools 'adb.exe'
if (-not (Test-Path -LiteralPath $adb)) {
    throw 'adb.exe is missing. Install Google.PlatformTools with winget first.'
}

$device = (& $adb shell getprop ro.product.device).Trim()
if ($device -ne 'cactus') {
    throw "Expected an authorized cactus device, detected '$device'."
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outputDir = Join-Path $BackupRoot "user-data\$stamp"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Write-Host 'Copying shared internal storage. Keep the phone unlocked and connected.'
& $adb pull -a '/sdcard/' (Join-Path $outputDir 'sdcard')
if ($LASTEXITCODE -ne 0) {
    throw 'adb pull failed. The incomplete directory was kept for inspection.'
}

Get-ChildItem -LiteralPath $outputDir -Recurse -File |
    Get-FileHash -Algorithm SHA256 |
    ForEach-Object { "{0} *{1}" -f $_.Hash.ToLowerInvariant(), $_.Path.Substring($outputDir.Length + 1) } |
    Set-Content -LiteralPath (Join-Path $outputDir 'SHA256SUMS.txt') -Encoding ascii

Write-Host "User-data backup completed at $outputDir"
Write-Warning 'This does not include private application data or raw modem/calibration partitions.'
