param(
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\AircraftCosts')
)
# Builds the "Aircraft Costs -50%" templates: purchase price and monthly upkeep of Xenonaut aircraft halved.
# The price is the CashPq cost of the engineering project that builds the aircraft (the Cash component on the
# aircraft profiles is not what the player pays). Upkeep goes through the aircraft_expense_multiplier global
# variable, so the aircraft profiles stay untouched and the mod does not clash with Better Aircraft.
# Material costs (ItemsPq) are not changed.
# Only the template files are written; manifest.json and preview.png are maintained by hand.
$ErrorActionPreference = 'Stop'

$multiplier = 0.5
$projects = 'aircraft_interceptor_tier1', 'aircraft_interceptor_tier2', 'aircraft_interceptor_tier3',
            'aircraft_dropship_tier1', 'aircraft_dropship_tier2', 'aircraft_dropship_tier3'
$inv = [Globalization.CultureInfo]::InvariantCulture

function Scale-Once([string]$text, [string]$pattern, [string]$what) {
    if ([regex]::Matches($text, $pattern).Count -ne 1) { throw "$what : not found exactly once" }
    return [regex]::Replace($text, $pattern, {
        param($x)
        $x.Groups[1].Value + ([double]::Parse($x.Groups[2].Value, $inv) * $multiplier).ToString('0.0###', $inv) + $x.Groups[3].Value
    })
}

# Purchase price
$src = Join-Path $VanillaDir 'template\strategy\projects\engineering'
$dst = Join-Path $OutDir 'template\strategy\projects\engineering'
New-Item -ItemType Directory -Force $dst | Out-Null
foreach ($p in $projects) {
    $text = [IO.File]::ReadAllText((Join-Path $src "$p.json"))
    $text = Scale-Once $text '(\{"value":)([0-9.]+)(,"Variant":"Cost","\$t":"CashPq"\})' "$p CashPq"
    [IO.File]::WriteAllText((Join-Path $dst "$p.json"), $text, (New-Object Text.UTF8Encoding $false))
}

# Upkeep. The Soviet Union regional bonus still subtracts 0.25 from this multiplier.
$rel = 'template\common\global_variables\aircraft_expense_multiplier.json'
$text = [IO.File]::ReadAllText((Join-Path $VanillaDir $rel))
$text = Scale-Once $text '(\{"\$content":)([0-9.]+)(,"\$t":"Float"\})' 'aircraft_expense_multiplier'
New-Item -ItemType Directory -Force (Split-Path (Join-Path $OutDir $rel)) | Out-Null
[IO.File]::WriteAllText((Join-Path $OutDir $rel), $text, (New-Object Text.UTF8Encoding $false))

"Aircraft Costs -50%: $($projects.Count + 1) templates written"
