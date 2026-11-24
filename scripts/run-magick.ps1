# No param block: all arguments, including ImageMagick options, pass through.
# Call with & $script @argumentArray. No command-string evaluation.
$ErrorActionPreference = 'Stop'
try {
    . (Join-Path $PSScriptRoot 'common.ps1')
    $executable = Resolve-ToolkitMagick
    if ($args.Count -eq 0) {
        Write-Error 'Pass ImageMagick arguments, for example: -version' -ErrorAction Continue
        exit 2
    }
    # Native stderr must not change compare exit 2 into a PowerShell error exit 1.
    $ErrorActionPreference = 'Continue'
    $PSNativeCommandUseErrorActionPreference = $false
    $global:LASTEXITCODE = 0
    & $executable @args
    if (-not $? -and $LASTEXITCODE -eq 0) { exit 1 }
    exit $LASTEXITCODE
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 1
}
