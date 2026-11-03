param(
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\BetterAircraft')
)
# Builds the "Better Aircraft" templates: hull, geoscape speed, fuel use and repair rate of the Xenonaut
# interceptors and dropships. Combat handling (ACSpeed, turning) and weapons stay vanilla.
# Only the template files are written; manifest.json and preview.png are maintained by hand.
$ErrorActionPreference = 'Stop'

# component type -> multiplier
$scale = [ordered]@{
    'HitPoints'           = 1.5
    'Speed'               = 1.25
    'FuelConsumptionRate' = 0.75
    'HitPointRegenerate'  = 2.0
}
# Aircraft without their own value inherit it from these masters. masters/aircraft/aircraft.json is
# left alone because the UFOs inherit from it too. The tutorial interceptor is scripted: not touched.
$files = @(
    'masters\aircraft\xenonaut.json'
    'masters\aircraft\xenonaut_dropship.json'
    'aircraft\profiles\xenonaut\interceptor_tier0.json'
    'aircraft\profiles\xenonaut\interceptor_tier1.json'
    'aircraft\profiles\xenonaut\interceptor_tier2.json'
    'aircraft\profiles\xenonaut\interceptor_tier3.json'
    'aircraft\profiles\xenonaut\dropship_tier1.json'
    'aircraft\profiles\xenonaut\dropship_tier2.json'
    'aircraft\profiles\xenonaut\dropship_tier3.json'
)
$inv = [Globalization.CultureInfo]::InvariantCulture

function Format-Number([double]$x) { $x.ToString('0.0###', $inv) }

function Scale-Component([string]$text, [string]$type, [double]$factor, [string]$what) {
    # Range components {"_min":0.0,"_val":100.0,"_max":100.0,"$t":"HitPoints"}: _val and _max scale, _min stays.
    # Scalar components {"$content":1.75,"$t":"FuelConsumptionRate"}.
    $range = '(\{"_min":[-0-9.E+]+,"_val":)([-0-9.E+]+)(,"_max":)([-0-9.E+]+)(,"\$t":"' + $type + '"\})'
    $scalar = '(\{"\$content":)([-0-9.E+]+)(,"\$t":"' + $type + '"\})'
    $total = [regex]::Matches($text, '"\$t":"' + $type + '"').Count
    $found = [regex]::Matches($text, $range).Count + [regex]::Matches($text, $scalar).Count
    if ($found -ne $total) { throw "$what $type : $total components but only $found in a known shape" }
    $text = [regex]::Replace($text, $range, {
        param($x)
        $x.Groups[1].Value + (Format-Number ([double]::Parse($x.Groups[2].Value, $inv) * $factor)) +
        $x.Groups[3].Value + (Format-Number ([double]::Parse($x.Groups[4].Value, $inv) * $factor)) + $x.Groups[5].Value
    })
    $text = [regex]::Replace($text, $scalar, {
        param($x)
        $x.Groups[1].Value + (Format-Number ([double]::Parse($x.Groups[2].Value, $inv) * $factor)) + $x.Groups[3].Value
    })
    return $text
}

$src = Join-Path $VanillaDir 'template\strategy'
$dst = Join-Path $OutDir 'template\strategy'
$changed = 0
foreach ($rel in $files) {
    $text = [IO.File]::ReadAllText((Join-Path $src $rel))
    $before = $text
    foreach ($type in $scale.Keys) { $text = Scale-Component $text $type $scale[$type] $rel }
    if ($text -eq $before) { throw "$rel : nothing to change" }
    $out = Join-Path $dst $rel
    New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null
    [IO.File]::WriteAllText($out, $text, (New-Object Text.UTF8Encoding $false))
    $changed++
}
"Better Aircraft: $changed templates written"
