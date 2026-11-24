param([switch]$Full, [switch]$VerifyIntegrity)
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'common.ps1')
    $executable = Resolve-ToolkitMagick
    Write-Output "Executable: $executable"
    $version = & $executable -version
    if ($LASTEXITCODE -ne 0) { throw 'ImageMagick failed to start.' }
    if (($version -join ' ') -notmatch 'ImageMagick 7\.') { throw 'ImageMagick 7 is required.' }
    $version | Write-Output
    if ($VerifyIntegrity) {
        $root = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..')).FullName
        $manifest = Get-Content -LiteralPath (Join-Path $root 'vendor/manifest.json') -Raw | ConvertFrom-Json
        foreach ($entry in $manifest.files) {
            $filePath = Join-Path $root $entry.path
            if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) { throw "Missing: $($entry.path)" }
            $actual = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash
            if ($actual -ne $entry.sha256) { throw "Hash mismatch: $($entry.path)" }
        }
        Write-Output 'Bundled files match manifest (integrity only, not upstream authenticity).'
    }
    if ($Full) {
        foreach ($kind in @('format', 'font', 'policy')) {
            Write-Output "--- $kind ---"
            & $executable -list $kind
            if ($LASTEXITCODE -ne 0) { throw "Cannot list $kind." }
        }
    }
    exit 0
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
