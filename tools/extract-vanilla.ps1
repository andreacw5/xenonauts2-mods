param(
    [string]$GameDir = 'E:\SteamLibrary\steamapps\common\Xenonauts2',
    [string]$OutDir = (Join-Path $PSScriptRoot '..\vanilla')
)
# Extracts the game's moddable data (moddable_content.zip) into vanilla/, the source for the build scripts.
# vanilla/ is Goldhawk's content: it is git-ignored and recreated from the installed game after every patch.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = Join-Path $GameDir 'Assets\Assets\xenonauts\moddable_content.zip'
$manifest = Join-Path $GameDir 'Assets\Assets\xenonauts\manifest.json'
if (-not (Test-Path $zip)) { throw "moddable_content.zip not found under $GameDir" }

$OutDir = [IO.Path]::GetFullPath($OutDir)
if (Test-Path $OutDir) { Remove-Item $OutDir -Recurse -Force -Confirm:$false }
[IO.Compression.ZipFile]::ExtractToDirectory($zip, $OutDir)

$version = (Get-Content $manifest -Raw | ConvertFrom-Json).asset.Version
Set-Content -Path (Join-Path $OutDir 'GAME_VERSION.txt') -Value $version -Encoding ascii
"Extracted game data v$version to $OutDir"
