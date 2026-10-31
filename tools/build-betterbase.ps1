param(
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla'),
    [string]$OutDir = (Join-Path $PSScriptRoot '..\BetterBase')
)
# Builds the "Better Base" mod from current vanilla templates by targeted text replacement,
# so every other field stays exactly as the installed game version ships it.
# Only the template files are written; manifest.json and preview.png are maintained by hand.
$ErrorActionPreference = 'Stop'

# vanilla build hours -> modded build hours (12/15/20 days -> 6/9/12 days)
$buildHours = @{ '288.0' = '144.0'; '360.0' = '216.0'; '480.0' = '288.0' }
$upkeep = '2500.0'
$slotsPerBuilding = 10

# building -> list of @(componentType, field, newValue)
$stats = @{
    'storeroom'             = @(@('Capacity', '_val', '500.0'), @('Capacity', '_max', '500.0'))
    'living_quarters'       = @(@('PersonnelCapacity', '_val', '500.0'), @('PersonnelCapacity', '_max', '500.0'))
    'generator'             = @(@('PowerGeneration', '_val', '250.0'), @('PowerGeneration', '_max', '250.0'))
    'alenium_generator'     = @(@('PowerGeneration', '_val', '500.0'), @('PowerGeneration', '_max', '500.0'))
    'medical_room'          = @(@('HitPointsHealingRate', '_val', '3.0'), @('HitPointsHealingRate', '_max', '3.0'), @('SurvivalChance', '_val', '50.0'))
    'medical_room_advanced' = @(@('HitPointsHealingRate', '_val', '6.0'), @('HitPointsHealingRate', '_max', '6.0'), @('SurvivalChance', '_val', '100.0'))
    'training_center'       = @(@('TrainingCapacity', '_val', '50.0'), @('TrainingCapacity', '_max', '50.0'))
}

function Replace-Once([string]$text, [string]$pattern, [string]$replacement, [string]$what) {
    $n = [regex]::Matches($text, $pattern).Count
    if ($n -ne 1) { throw "$what : expected 1 match, found $n" }
    return [regex]::Replace($text, $pattern, $replacement)
}

function Set-RangeField([string]$text, [string]$type, [string]$field, [string]$value, [string]$what) {
    # Range components look like {"_min":0.0,"_val":40.0,"_max":40.0,"$t":"PowerGeneration"}
    $pattern = '(\{"_min":[-0-9.E+]+,"_val":)([-0-9.E+]+)(,"_max":)([-0-9.E+]+)(,"\$t":"' + $type + '"\})'
    $m = [regex]::Matches($text, $pattern)
    if ($m.Count -ne 1) { throw "$what $type : expected 1 match, found $($m.Count)" }
    return [regex]::Replace($text, $pattern, {
        param($x)
        $val = if ($field -eq '_val') { $value } else { $x.Groups[2].Value }
        $max = if ($field -eq '_max') { $value } else { $x.Groups[4].Value }
        $x.Groups[1].Value + $val + $x.Groups[3].Value + $max + $x.Groups[5].Value
    })
}

$srcBuild = Join-Path $VanillaDir 'template\strategy\construction\building'
$dstBuild = Join-Path $OutDir 'template\strategy\construction\building'
New-Item -ItemType Directory -Force $dstBuild | Out-Null

foreach ($file in Get-ChildItem $srcBuild -Filter *.json) {
    $name = $file.BaseName
    $text = [IO.File]::ReadAllText($file.FullName)

    # Build time: ProgressPoints max of the Constructing state
    $text = [regex]::Replace($text, '("_max":)([0-9.]+)(,"\$t":"ProgressPoints")', {
        param($x)
        $old = $x.Groups[2].Value
        if (-not $buildHours.ContainsKey($old)) { throw "$name : unexpected build time $old" }
        $x.Groups[1].Value + $buildHours[$old] + $x.Groups[3].Value
    })

    # Upkeep (upgrades without their own Expense inherit it from the base building)
    $text = [regex]::Replace($text, '(\{"\$content":)[0-9.]+(,"\$t":"Expense"\})', '${1}' + $upkeep + '${2}')

    if ($stats.ContainsKey($name)) {
        foreach ($s in $stats[$name]) { $text = Set-RangeField $text $s[0] $s[1] $s[2] $name }
    }

    # Personnel slots: labs and workshops get $slotsPerBuilding slots once enabled
    if ($name -match '^(laboratory|workshop)') {
        $text = [regex]::Replace($text, '("Xenonauts\.Strategy\.Components\.PersonnelSlotsLink":\[)(\{[^\[\]]*?\})(?:,\{[^\[\]]*?\})*(\])', {
            param($x)
            $x.Groups[1].Value + ((@($x.Groups[2].Value) * $slotsPerBuilding) -join ',') + $x.Groups[3].Value
        })
    }

    [IO.File]::WriteAllText((Join-Path $dstBuild $file.Name), $text, (New-Object Text.UTF8Encoding $false))
}

# Personnel hiring cost and wages
$srcPers = Join-Path $VanillaDir 'template\strategy\masters\actor\combatant\human\xenonauts'
$dstPers = Join-Path $OutDir 'template\strategy\masters\actor\combatant\human\xenonauts'
New-Item -ItemType Directory -Force $dstPers | Out-Null
foreach ($n in 'engineer_master', 'scientist_master') {
    $text = [IO.File]::ReadAllText((Join-Path $srcPers "$n.json"))
    $text = Replace-Once $text '(\{"\$content":)[0-9.]+(,"\$t":"Expense"\})' ('${1}' + $upkeep + '${2}') "$n Expense"
    $text = Replace-Once $text '\{"_min":[0-9.]+,"_val":[0-9.]+,"_max":[0-9.]+,"\$t":"Cash"\}' '{"_min":5000.0,"_val":5000.0,"_max":5000.0,"$t":"Cash"}' "$n Cash"
    [IO.File]::WriteAllText((Join-Path $dstPers "$n.json"), $text, (New-Object Text.UTF8Encoding $false))
}
