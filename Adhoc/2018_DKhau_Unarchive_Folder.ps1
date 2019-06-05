$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$z = "C:\Program Files\7-Zip\7z.exe"

$files = Get-ChildItem $ScriptDir -r | where {$_.Extension -match "gz"}

foreach ($file in $files) {
    $source = $file.FullName
    $destination = "./"
    Write-Host $destination
    $destination = "-o" + $destination
    & "$z" x -y $source $destination
    Remove-Item $source
}