[CmdletBinding()]
param(
    [string]$BackupRoot = 'D:\CactusBack'
)

$ErrorActionPreference = 'Stop'
$platformTools = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe\platform-tools'
$adb = Join-Path $platformTools 'adb.exe'
$fastboot = Join-Path $platformTools 'fastboot.exe'

if (-not (Test-Path -LiteralPath $adb)) {
    throw 'adb.exe is missing. Install Google.PlatformTools with winget first.'
}

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$outputDir = Join-Path $BackupRoot "inventory\$stamp"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$devices = & $adb devices -l
$authorized = @($devices | Select-String '\sdevice\s')
if ($authorized.Count -ne 1) {
    $devices | Set-Content -LiteralPath (Join-Path $outputDir 'adb-devices.txt')
    throw 'Connect exactly one authorized Android device and accept the USB debugging prompt.'
}

$props = & $adb shell getprop
$device = (& $adb shell getprop ro.product.device).Trim()
if ($device -ne 'cactus') {
    throw "Expected Redmi 6A codename cactus, detected '$device'. No further action was taken."
}

$inventory = [ordered]@{
    captured_at = (Get-Date).ToString('o')
    product_device = $device
    product_model = (& $adb shell getprop ro.product.model).Trim()
    build_fingerprint = (& $adb shell getprop ro.build.fingerprint).Trim()
    build_version = (& $adb shell getprop ro.build.version.incremental).Trim()
    android_release = (& $adb shell getprop ro.build.version.release).Trim()
    android_sdk = (& $adb shell getprop ro.build.version.sdk).Trim()
    slot_suffix = (& $adb shell getprop ro.boot.slot_suffix).Trim()
    verified_boot_state = (& $adb shell getprop ro.boot.verifiedbootstate).Trim()
    flash_locked = (& $adb shell getprop ro.boot.flash.locked).Trim()
    hardware = (& $adb shell getprop ro.hardware).Trim()
}

$inventory | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $outputDir 'device-inventory.json') -Encoding utf8
$props | Set-Content -LiteralPath (Join-Path $outputDir 'getprop.txt') -Encoding utf8
& $adb shell 'cat /proc/partitions' | Set-Content -LiteralPath (Join-Path $outputDir 'partitions.txt') -Encoding utf8
& $adb shell 'cat /proc/mounts' | Set-Content -LiteralPath (Join-Path $outputDir 'mounts.txt') -Encoding utf8
& $adb shell 'cat /proc/cmdline' | Set-Content -LiteralPath (Join-Path $outputDir 'cmdline.txt') -Encoding utf8

if (Test-Path -LiteralPath $fastboot) {
    & $fastboot --version | Set-Content -LiteralPath (Join-Path $outputDir 'fastboot-version.txt') -Encoding utf8
}

Write-Host "Private device inventory saved to $outputDir"
Write-Host 'No partition was written and the bootloader was not changed.'
