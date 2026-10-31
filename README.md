# Xenonauts 2 mods

Mods for [Xenonauts 2](https://store.steampowered.com/app/538030/Xenonauts_2/) by [andreacw96](https://steamcommunity.com/id/andreacw96/).

| Mod | Steam Workshop | What it does |
|---|---|---|
| [Better Base](BetterBase) | [3831149512](https://steamcommunity.com/sharedfiles/filedetails/?id=3831149512) | Faster construction (6 / 9 / 12 days), bigger facilities, cheaper staff and upkeep |
| [Finance x3](FinanceX3) | [3831149991](https://steamcommunity.com/sharedfiles/filedetails/?id=3831149991) | Triples the base monthly funding of every region |

Built against game version **7.27.13**.

## Layout

```
BetterBase/   the mod as the game loads it (manifest.json, preview.png, template/)
FinanceX3/    idem
tools/        PowerShell scripts that generate the template files from the game's data
vanilla/      game data extracted by tools/extract-vanilla.ps1 (git-ignored)
```

`manifest.json` and `preview.png` are edited by hand. Everything under `template/` is generated: change the values in the build scripts, not in the JSON.

## Playing with the local copy

The game only loads local mods from
`%USERPROFILE%\AppData\LocalLow\Goldhawk Interactive\Xenonauts 2\Mods`.
Each mod folder there is a directory junction pointing into this repo, so the game and the Workshop uploader always see the files in the repo. To recreate the junctions on a new PC:

```powershell
$mods = "$env:USERPROFILE\AppData\LocalLow\Goldhawk Interactive\Xenonauts 2\Mods"
foreach ($m in 'BetterBase', 'FinanceX3') { New-Item -ItemType Junction -Path "$mods\$m" -Target "$PWD\$m" }
```

Do not subscribe to these mods on the Workshop while the local copies are active: the game would load the same mod twice.

## Updating after a game patch

```powershell
.\tools\extract-vanilla.ps1            # unpack the new game data into vanilla/
.\tools\build-betterbase.ps1           # regenerate BetterBase/template
.\tools\build-financex3.ps1            # regenerate FinanceX3/template
.\tools\diff.ps1 -ModDir .\BetterBase  # check: only the intended values differ from vanilla
git diff                               # see what the patch changed in the mod files
```

`extract-vanilla.ps1` assumes the game is in `E:\SteamLibrary\steamapps\common\Xenonauts2`; pass `-GameDir` otherwise. The build scripts stop with an error if a value they edit is no longer where they expect it, which usually means the patch changed that file's structure.

Then bump the dependency version in each `manifest.json`, test in game, and upload the update from the in-game Mods menu.

## Tools

| Script | Purpose |
|---|---|
| `extract-vanilla.ps1` | Extracts `moddable_content.zip` from the game install into `vanilla/` |
| `build-betterbase.ps1` | Writes Better Base's building and staff templates (build times, capacities, slots, costs) |
| `build-financex3.ps1` | Writes Finance x3's region templates (flat funding x3) |
| `diff.ps1` | Lists every value a mod changes compared to `vanilla/` |
| `preview-financex3.ps1` | Draws Finance x3's preview image (`-TitleOnly` for the published version) |

## Credits

Better Base values started from the Better Buildings mods; Finance x3 is a gentler take on Finance x10.
Xenonauts 2 and its game data © Goldhawk Interactive. The `template/` files are game templates with modified values, the same files the mods ship on the Workshop; the unmodified game data is never committed.
