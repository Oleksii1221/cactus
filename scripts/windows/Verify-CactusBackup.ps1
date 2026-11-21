[CmdletBinding()]
param(
    [string]$BackupRoot = 'D:\CactusBack',
    [string]$BackupDirectory
)

$ErrorActionPreference = 'Stop'
if (-not $BackupDirectory) {
    $BackupDirectory = Get-ChildItem -LiteralPath (Join-Path $BackupRoot 'user-data') -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $BackupDirectory) {
    throw 'No user-data backup directory was found.'
}

$sumFile = Join-Path $BackupDirectory 'SHA256SUMS.txt'
if (-not (Test-Path -LiteralPath $sumFile)) {
    throw "Missing checksum file: $sumFile"
}

$failures = [System.Collections.Generic.List[string]]::new()
foreach ($line in Get-Content -LiteralPath $sumFile) {
    if ($line -notmatch '^([0-9a-f]{64}) \*(.+)$') {
        $failures.Add("Malformed checksum line: $line")
        continue
    }
    $expected = $Matches[1]
    $relative = $Matches[2]
    $path = Join-Path $BackupDirectory $relative
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Missing file: $relative")
        continue
    }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        $failures.Add("Checksum mismatch: $relative")
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    throw "Backup verification failed with $($failures.Count) error(s)."
}

Write-Host "Backup verified successfully: $BackupDirectory"
