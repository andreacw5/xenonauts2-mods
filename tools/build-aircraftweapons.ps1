param(
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\AircraftWeapons')
)
# Builds the "Aircraft Weapons +25%" templates: damage of every Xenonaut aircraft weapon x1.25.
# Tiers without their own ACWeaponDamage (weapon_lance_2) inherit it from the previous tier.
# No UFO weapon inherits from these files, and the tutorial missile is scripted: not touched.
# Only the template files are written; manifest.json and preview.png are maintained by hand.
$ErrorActionPreference = 'Stop'

$multiplier = 1.25
$weapons = @(
    'cannon_tier1', 'cannon_tier2', 'cannon_tier3', 'cannon_tier4'
    'missile_tier1', 'missile_tier2', 'missile_tier3', 'missile_tier4'
    'torpedo_tier1', 'torpedo_tier2', 'torpedo_tier3', 'torpedo_tier4'
    'weapon_lance_1', 'weapon_lance_3'
)
$inv = [Globalization.CultureInfo]::InvariantCulture

$src = Join-Path $VanillaDir 'template\strategy\item\aircraft_equipment'
$dst = Join-Path $OutDir 'template\strategy\item\aircraft_equipment'
New-Item -ItemType Directory -Force $dst | Out-Null

foreach ($w in $weapons) {
    $text = [IO.File]::ReadAllText((Join-Path $src "$w.json"))
    $pattern = '\{"_min":([-0-9.E+]+),"_val":([-0-9.E+]+),"_max":([-0-9.E+]+),"\$t":"ACWeaponDamage"\}'
    if ([regex]::Matches($text, $pattern).Count -ne 1) { throw "$w : ACWeaponDamage not found exactly once" }
    $text = [regex]::Replace($text, $pattern, {
        param($x)
        $v = 1..3 | ForEach-Object { ([double]::Parse($x.Groups[$_].Value, $inv) * $multiplier).ToString('0.0###', $inv) }
        '{"_min":' + $v[0] + ',"_val":' + $v[1] + ',"_max":' + $v[2] + ',"$t":"ACWeaponDamage"}'
    })
    [IO.File]::WriteAllText((Join-Path $dst "$w.json"), $text, (New-Object Text.UTF8Encoding $false))
}
"Aircraft Weapons +25%: $($weapons.Count) templates written"
