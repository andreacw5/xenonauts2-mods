param(
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\FinanceX3')
)
# Builds the Finance x3 templates: base (flat) funding of the six funding regions x3.
# Only the template files are written; manifest.json and preview.png are maintained by hand.
$ErrorActionPreference = 'Stop'

$multiplier = 3
$regions = 'africa', 'asia_pacific', 'latin_america', 'north_america', 'soviet_union', 'western_europe'
$inv = [Globalization.CultureInfo]::InvariantCulture

$src = Join-Path $VanillaDir 'template\strategy\geo_region'
$dst = Join-Path $OutDir 'template\strategy\geo_region'
New-Item -ItemType Directory -Force $dst | Out-Null

foreach ($r in $regions) {
    $text = [IO.File]::ReadAllText((Join-Path $src "$r.json"))
    $pattern = '("_val":)([0-9.]+)(,"_max":[-0-9.E+]+,"\$t":"FlatRelationsFunding")'
    if ([regex]::Matches($text, $pattern).Count -ne 1) { throw "$r : FlatRelationsFunding not found exactly once" }
    $text = [regex]::Replace($text, $pattern, {
        param($x)
        $new = [double]::Parse($x.Groups[2].Value, $inv) * $multiplier
        $x.Groups[1].Value + $new.ToString('0.0', $inv) + $x.Groups[3].Value
    })
    [IO.File]::WriteAllText((Join-Path $dst "$r.json"), $text, (New-Object Text.UTF8Encoding $false))
}
