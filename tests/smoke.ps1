# Windows x64 smoke tests; generated fixtures are kept in a unique temp folder.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$runner = Join-Path $root 'scripts/run-magick.ps1'
$work = Join-Path ([IO.Path]::GetTempPath()) ('imagemagick-toolkit-' + [guid]::NewGuid().ToString('N'))
$work = Join-Path $work (([string][char]0x56FE) + ([string][char]0x7247) + ' with spaces')
New-Item -ItemType Directory -Path $work -Force | Out-Null
$count = 0
function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    $script:count++
}
function Invoke-IM([string[]]$Arguments) {
    $result = & $runner @Arguments
    if ($LASTEXITCODE -ne 0) { throw "ImageMagick failed: $Arguments" }
    return $result
}
function Check-Image([string]$Path, [string]$Expected) {
    $actual = Invoke-IM -Arguments @('identify','-format','%w %h %m %n',$Path)
    Assert-True (($actual -join '') -eq $Expected) "Expected [$Expected], got [$actual]"
}
try {
    & (Join-Path $root 'scripts/doctor.ps1') -VerifyIntegrity
    Assert-True ($LASTEXITCODE -eq 0) 'Doctor failed'
    $source = Join-Path $work 'input source.png'
    Invoke-IM -Arguments @('-size','320x200','xc:none','-fill','red','-draw','rectangle 20,20 299,179',$source) | Out-Null
    $sourceHash = (Get-FileHash -LiteralPath $source).Hash

    $scaled = Join-Path $work 'scaled.webp'
    Invoke-IM -Arguments @($source,'-resize','160x160>',$scaled) | Out-Null
    Check-Image $scaled '160 100 WEBP 1'
    $crop = Join-Path $work 'cropped.png'
    Invoke-IM -Arguments @($source,'-resize','120x80^','-gravity','center','-extent','120x80','+repage',$crop) | Out-Null
    Check-Image $crop '120 80 PNG 1'
    $pad = Join-Path $work 'padded.png'
    Invoke-IM -Arguments @($source,'-resize','120x120','-background','white','-gravity','center','-extent','120x120',$pad) | Out-Null
    Check-Image $pad '120 120 PNG 1'
    $jpeg = Join-Path $work 'white background.jpg'
    Invoke-IM -Arguments @($source,'-background','white','-alpha','remove','-alpha','off','-quality','90',$jpeg) | Out-Null
    Check-Image $jpeg '320 200 JPEG 1'
    $pixel = Invoke-IM -Arguments @($jpeg,'-format','%[pixel:p{0,0}]','info:')
    Assert-True (($pixel -join '') -match '255,255,255|100%,100%,100%') 'JPEG background is not white'
    $joined = Join-Path $work 'joined.png'
    Invoke-IM -Arguments @($source,$source,'+append',$joined) | Out-Null
    Check-Image $joined '640 200 PNG 1'
    $grid = Join-Path $work 'grid.png'
    Invoke-IM -Arguments @('montage',$source,$source,'-tile','2x1','-geometry','+0+0',$grid) | Out-Null
    Check-Image $grid '640 200 PNG 1'
    $font = (Join-Path $env:WINDIR 'Fonts/arial.ttf').Replace('\', '/')
    Assert-True (Test-Path -LiteralPath $font) 'Arial test font not available'
    $text = Join-Path $work 'text.png'
    Invoke-IM -Arguments @($source,'-font',$font,'-pointsize','20','-fill','black','-annotate','+30+60','Toolkit test',$text) | Out-Null
    Check-Image $text '320 200 PNG 1'
    $difference = Invoke-IM -Arguments @($source,$text,'-compose','difference','-composite','-format','%[fx:mean]','info:')
    Assert-True ([double]::Parse(($difference -join ''),[Globalization.CultureInfo]::InvariantCulture) -gt 0) 'Text did not change pixels'
    $gif = Join-Path $work 'animation.gif'
    Invoke-IM -Arguments @('-delay','10','-size','64x32','xc:red','-delay','20','-size','64x32','xc:blue','-loop','0',$gif) | Out-Null
    $smallGif = Join-Path $work 'small.gif'
    Invoke-IM -Arguments @($gif,'-coalesce','-resize','32x16','-layers','Optimize',$smallGif) | Out-Null
    $frames = @(Invoke-IM -Arguments @('identify','-format','%w %h %T\n',$smallGif))
    Assert-True ($frames.Count -eq 2) 'Animation frame count changed'
    Assert-True ($frames[0] -eq '32 16 10' -and $frames[1] -eq '32 16 20') 'Animation timing/loop/size changed'
    $gifInfo = Invoke-IM -Arguments @('identify','-verbose',$smallGif)
    Assert-True (($gifInfo -join "`n") -match 'Iterations: 0') 'GIF loop changed'
    $batch = Join-Path $work 'batch'
    New-Item -ItemType Directory -Path $batch | Out-Null
    foreach ($inputFile in @($source,$pad)) {
        $output = Join-Path $batch (([IO.Path]::GetFileNameWithoutExtension($inputFile)) + '.webp')
        Invoke-IM -Arguments @($inputFile,'-quality','80',$output) | Out-Null
        Invoke-IM -Arguments @('identify',$output) | Out-Null
    }
    Assert-True (@(Get-ChildItem -LiteralPath $batch -File).Count -eq 2) 'Batch count mismatch'
    # Expected native stderr must not become terminating errors in Windows PowerShell.
    $savedPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $runner compare $source $source 'null:' 2>$null | Out-Null
    $sameExit = $LASTEXITCODE
    & $runner compare $source $text 'null:' 2>$null | Out-Null
    $differentExit = $LASTEXITCODE
    & $runner compare (Join-Path $work 'missing-a.png') (Join-Path $work 'missing-b.png') 'null:' 2>$null | Out-Null
    $compareErrorExit = $LASTEXITCODE
    & $runner (Join-Path $work 'missing.png') (Join-Path $work 'must-not-exist.png') 2>$null | Out-Null
    $missingExit = $LASTEXITCODE
    & $runner 2>$null | Out-Null
    $emptyExit = $LASTEXITCODE
    $savedExecutable = $env:IMAGEMAGICK_EXECUTABLE
    try {
        $env:IMAGEMAGICK_EXECUTABLE = Join-Path $work 'missing.exe'
        & $runner -version 2>$null | Out-Null
        $invalidOverrideExit = $LASTEXITCODE
        $env:IMAGEMAGICK_EXECUTABLE = (Get-Item -LiteralPath (Join-Path $root 'vendor/imagemagick/windows-x64/magick.exe')).FullName
        & $runner -version | Out-Null
        $validOverrideExit = $LASTEXITCODE
    } finally {
        $env:IMAGEMAGICK_EXECUTABLE = $savedExecutable
    }
    $ErrorActionPreference = $savedPreference
    Assert-True ($sameExit -eq 0) 'Identical compare must return 0'
    Assert-True ($differentExit -eq 1) 'Different compare must return 1'
    Assert-True ($compareErrorExit -eq 2) 'Compare errors must return 2'
    Assert-True ($missingExit -ne 0) 'Missing input must fail'
    Assert-True ($emptyExit -eq 2) 'Missing arguments must return 2'
    Assert-True ($invalidOverrideExit -ne 0) 'Invalid explicit executable must fail'
    Assert-True ($validOverrideExit -eq 0) 'Valid explicit executable must work'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $work 'must-not-exist.png'))) 'Invalid input produced output'
    Assert-True ((Get-FileHash -LiteralPath $source).Hash -eq $sourceHash) 'Source was modified'
    Write-Output "PASS: $count checks"
    Write-Output "Artifacts: $work"
    exit 0
} catch {
    Write-Error $_ -ErrorAction Continue
    Write-Output "Artifacts: $work"
    exit 1
}
