# Shared resolver. Dot-source from scripts in this directory.
function Resolve-ToolkitMagick {
    if ($env:IMAGEMAGICK_EXECUTABLE) {
        if (-not [IO.Path]::IsPathRooted($env:IMAGEMAGICK_EXECUTABLE) -or
            -not (Test-Path -LiteralPath $env:IMAGEMAGICK_EXECUTABLE -PathType Leaf)) {
            throw 'IMAGEMAGICK_EXECUTABLE must point to an existing executable by absolute path.'
        }
        return (Get-Item -LiteralPath $env:IMAGEMAGICK_EXECUTABLE).FullName
    }
    if ($env:OS -ne 'Windows_NT') {
        throw 'Use run-magick.sh with a system ImageMagick 7 on macOS/Linux.'
    }
    if ($env:PROCESSOR_ARCHITECTURE -ne 'AMD64') {
        throw 'Bundled runtime requires a Windows x64 process. Use a matching system runtime via IMAGEMAGICK_EXECUTABLE.'
    }
    $runtime = Join-Path $PSScriptRoot '../vendor/imagemagick/windows-x64/magick.exe'
    if (-not (Test-Path -LiteralPath $runtime -PathType Leaf)) {
        throw 'Bundled magick.exe is missing. Restore the complete skill bundle or set IMAGEMAGICK_EXECUTABLE.'
    }
    return (Get-Item -LiteralPath $runtime).FullName
}
