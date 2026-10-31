param(
    [Parameter(Mandatory)][string]$ModDir,
    [string]$VanillaDir = (Join-Path $PSScriptRoot '..\vanilla')
)
$ModDir = [IO.Path]::GetFullPath($ModDir).TrimEnd('\')
$VanillaDir = [IO.Path]::GetFullPath($VanillaDir)
# Flattens JSON files to path=value lines and prints the leaves that differ between mod and vanilla.

function Flatten($node, [string]$path, $out) {
    if ($null -eq $node) { $out.Add("$path=null"); return }
    if ($node -is [System.Management.Automation.PSCustomObject]) {
        foreach ($p in $node.PSObject.Properties) { Flatten $p.Value "$path.$($p.Name)" $out }
    } elseif ($node -is [System.Array]) {
        for ($i = 0; $i -lt $node.Count; $i++) { Flatten $node[$i] "$path[$i]" $out }
    } else { $out.Add("$path=$node") }
}

Get-ChildItem $ModDir -Recurse -Filter *.json | Where-Object Name -ne 'manifest.json' | ForEach-Object {
    $rel = $_.FullName.Substring($ModDir.Length)
    $van = Join-Path $VanillaDir $rel
    "##### $rel"
    if (-not (Test-Path $van)) { "  (no vanilla file)"; return }
    $a = New-Object System.Collections.Generic.List[string]
    $b = New-Object System.Collections.Generic.List[string]
    Flatten (Get-Content $van -Raw | ConvertFrom-Json) '' $a
    Flatten (Get-Content $_.FullName -Raw | ConvertFrom-Json) '' $b
    Compare-Object $a $b | Sort-Object { $_.InputObject } | ForEach-Object {
        $side = if ($_.SideIndicator -eq '<=') { 'VAN' } else { 'MOD' }
        "  $side $($_.InputObject)"
    }
}
