param(
    [string]$OutDir = (Join-Path $PSScriptRoot '..\ResearchTest')
)
# Writes the Heavy Plating test content into the Research Test mod: four armour tiers and four engineering
# projects (Mk1-Mk4). These are new files, not edited vanilla templates, so they are written from scratch.
# Mk1 is unlocked by the research modtest_heavy_plating_research. Mk2-Mk4 need the vanilla armour upgrade of
# the same tier plus the previous Mk; each one makes its tier available in every base and upgrades the lower
# Heavy Plating tiers already fitted, like the vanilla armour upgrades do. No vanilla file is touched.
$ErrorActionPreference = 'Stop'

# tier -> armour, hull bonus, project cost, project duration master
$tiers = @(
    @{ n = 1; armour = 12; hull = 50;  cost = 50000;  duration = 'engineering_duration0' }
    @{ n = 2; armour = 18; hull = 75;  cost = 100000; duration = 'engineering_duration2' }
    @{ n = 3; armour = 24; hull = 100; cost = 150000; duration = 'engineering_duration3' }
    @{ n = 4; armour = 30; hull = 125; cost = 200000; duration = 'engineering_duration4' }
)
$payload = 5          # Ablative Plating: 3
$combatSpeed = 0.9    # x0.9 air combat speed
$icon = 'ST-::-ui/aircraft_weapons/modtest_heavy_plating.png'
$enc = New-Object Text.UTF8Encoding $false
$inv = [Globalization.CultureInfo]::InvariantCulture

# Stable GUIDs: the same name always gives the same GUID, so rebuilding does not change the files
function Get-Guid([string]$seed) {
    $md5 = [Security.Cryptography.MD5]::Create()
    ([guid]::new($md5.ComputeHash([Text.Encoding]::UTF8.GetBytes("xenonauts2-mods/$seed")))).ToString()
}
function N([double]$x) { $x.ToString('0.0###', $inv) }
function Loc([string]$id) {
    '{"$content":[{"GUID":"' + (Get-Guid "$id/name") + '","TargetComponent":"Common.Components.NameComponent","Request":"Ignore"},' +
    '{"GUID":"' + (Get-Guid "$id/description") + '","TargetComponent":"Common.Components.DescriptionComponent","Request":"Ignore"}],"$t":"LocalizableGUID"}'
}
function Modifier([string]$target, [string]$type, [string]$value, [string]$max) {
    $min = if ($type -eq 'Multiplication') { $max } else { '0.0' }
    '{"Target":"' + $target + '","Type":"' + $type + '","DeltaMinimum":' + $min + ',"DeltaValue":' + $value + ',"DeltaMaximum":' + $max +
    ',"MinimumRounding":"None","ValueRounding":"None","MaximumRounding":"None","Precedence":0,"UniqueKey":false,"$t":"36"}'
}
function Ref([string]$path) { '{"$content":"ST-::-' + $path + '","$t":"ar_Template"}' }
function Write-Template([string]$rel, [string]$json) {
    $path = Join-Path $OutDir $rel
    New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
    [IO.File]::WriteAllText($path, $json, $enc)
}

foreach ($t in $tiers) {
    $n = $t.n
    $id = "modtest_heavy_plating_tier$n"

    # Armour item. Tier 1 is a child of Ablative Plating (icon on the aircraft, slot, sell price); the others of tier 1.
    # Armour uses DeltaValue 0 like the vanilla plating (it charges up); hull points raise value and maximum together.
    $parent = if ($n -eq 1) { 'item/aircraft_equipment/armor_tier1.json' } else { 'item/aircraft_equipment/modtest_heavy_plating_tier1.json' }
    $mods = (Modifier 'Xenonauts.Strategy.Components.AirCombatArmorComponent' 'Additive' '0.0' (N $t.armour)),
            (Modifier 'Xenonauts.Common.Stats.HitPoints' 'Additive' (N $t.hull) (N $t.hull)),
            (Modifier 'Xenonauts.Strategy.Components.AirCombatSpeedComponent' 'Multiplication' (N $combatSpeed) (N $combatSpeed))
    $desc = "Test item from the Research Test mod. Thick plating: +$($t.armour) Armour and +$($t.hull) hull points, but payload $payload and $([int]((1 - $combatSpeed) * 100))% slower in air combat."
    $components = @(
        (Loc $id)
        '{"$content":"Heavy Plating Mk' + $n + ' (MOD TEST)","$t":"Name"}'
        '{"$content":"' + $desc + '","$t":"Description"}'
        '{"$content":[' + ($mods -join ',') + '],"$t":"Modifiers"}'
    )
    if ($n -eq 1) {
        $components += '{"$content":"' + $icon + '","$t":"Portrait"}'
        $components += '{"_min":' + (N $payload) + ',"_val":' + (N $payload) + ',"_max":' + (N $payload) + ',"$t":"PowerUsage"}'
    }
    Write-Template "template\strategy\item\aircraft_equipment\$id.json" (
        '{"version":"0.1.0","asset":{"Parent":' + (Ref $parent) + ',"Name":"' + $id + '","_components":[' + ($components -join ',') + '],"$t":"4"},"$t":"15"}')

    # Engineering project
    $item = "item/aircraft_equipment/$id.json"
    $unlocks = if ($n -eq 1) { @('projects/research/modtest_heavy_plating_research.json') }
               else { @("projects/engineering/aircraft_armour_tier$n.json", "projects/engineering/modtest_heavy_plating_mk$($n - 1).json") }
    $prereq = @($unlocks | ForEach-Object { '{"Project":' + (Ref $_) + ',"Status":"Finished","Variant":"Unlocks","$t":"ProjectPq"}' }) +
              @('{"Operator":"All","Number":0,"selector":{"Player":"xenonauts","$t":"PlayerSe"},"prerequisites":[{"value":' + (N $t.cost) + ',"Variant":"Cost","$t":"CashPq"}],"Variant":"Cost","$t":"ADelegatePq"}')
    $effects = @(
        '{"selector":{"Group":"Xenonauts.Strategy.Components.GeoBaseGroup","$t":"GEntitySe"},"effects":[{"Quantity":Infinity,"Rounding":"None","Item":' + (Ref $item) + ',"SlotType":{"$content":"Stores","$t":"MainBaseSlots"},"$t":"DeltaItemEffect"}],"$t":"AManyDelegateEffect"}'
        '{"selector":{"Tag":"Xenonauts.Common.CampaignTag","$t":"TaggedEntitySe"},"effects":[{"Quantity":Infinity,"Item":' + (Ref $item) + ',"SlotType":{"$content":"Stores","$t":"MainBaseSlots"},"$t":"AddItemToGeoBaseRequisitionEffect"}],"$t":"ADelegateEffect"}'
    )
    if ($n -gt 1) {
        $upgrades = (1..($n - 1)) | ForEach-Object { '{"From":' + (Ref "item/aircraft_equipment/modtest_heavy_plating_tier$_.json") + ',"To":' + (Ref $item) + ',"$t":"UpgradeItemsEffect"}' }
        $effects += '{"selector":{"Player":"xenonauts","$t":"PlayerSe"},"effects":[' + ($upgrades -join ',') + '],"$t":"ADelegateEffect"}'
    }
    $pdesc = if ($n -eq 1) { 'Makes Heavy Plating available on our interceptor aircraft.' } else { "Upgrades our Heavy Plating to Mk$n, matching our improved standard plating." }
    $projId = "modtest_heavy_plating_mk$n"
    Write-Template "template\strategy\projects\engineering\$projId.json" (
        '{"version":"0.1.0","asset":{"Parent":' + (Ref "masters/projects/engineering/$($t.duration).json") + ',"Name":"' + $projId + '","_components":[' +
        '{"$content":"Test project added by the Research Test mod. ' + $pdesc + '","$t":"Description"},' + (Loc $projId) + ',' +
        '{"$content":"MOD TEST: Heavy Plating Mk' + $n + '","$t":"Name"},' +
        '{"$content":"ST-::-ui/engineering/aircraft_armour_tier' + [Math]::Max(2, $n) + '.png","$t":"Portrait"},' +
        '{"$content":[' + ($prereq -join ',') + '],"$t":"Prerequisites"},' +
        '{"$content":"Cancellable,CompleteNotification,AvailableNotification","$t":"ProjectMeta"},' +
        '{"TriggerEffects":{},"EntryEffects":{"Finished":[' + ($effects -join ',') + ']},"ExitEffects":{},"Prerequisites":{},"State":"Setup","$t":"ProjectFSM"},' +
        '{"$content":[' + (Ref 'sort_categories/project/engineering/aircraft_equipment.json') + '],"$t":"SortCategoriesReference"},' +
        '{"$content":' + (N (485 + $n)) + ',"$t":"SortOrder"}],"$t":"4"},"$t":"15"}')
}
"Heavy Plating: $($tiers.Count) tiers and $($tiers.Count) projects written"
