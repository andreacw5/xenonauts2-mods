# CLAUDE.md

Repo delle mod di Xenonauts 2 di andreacw96. Cosa fanno le mod e perché: [docs/PRD.md](docs/PRD.md). Uso per persone: [README.md](README.md).

L'utente parla italiano: rispondi in italiano. Testi delle mod (descrizioni, tag, immagini) in inglese.

## Percorsi

| Cosa | Dove |
|---|---|
| Repo | `C:\Users\andrea\xenonauts2-mods` |
| Gioco | `E:\SteamLibrary\steamapps\common\Xenonauts2` |
| Dati moddabili del gioco | `<gioco>\Assets\Assets\xenonauts\moddable_content.zip` (versione in `manifest.json` accanto) |
| Mod locali caricate dal gioco | `%USERPROFILE%\AppData\LocalLow\Goldhawk Interactive\Xenonauts 2\Mods\<Mod>` → **junction** verso `<repo>\<Mod>` |
| Mod del Workshop installate | `E:\SteamLibrary\steamapps\workshop\content\538030\<id>` (app id 538030) |
| Log del gioco | `%USERPROFILE%\AppData\LocalLow\Goldhawk Interactive\Xenonauts 2\Logs\output.log` |
| Git | non è nel PATH: usa quello di GitKraken, `C:\Users\andrea\AppData\Local\gitkraken\app-<versione>\resources\app.asar.unpacked\git\cmd\git.exe` (cerca la cartella `app-*` più recente). Chiama sempre `git -C <repo>` |

Non toccare mai i file dentro la cartella del gioco: si lavora su `vanilla/` (estratta) e sulle cartelle delle mod.

## Ambiente

- Windows, **PowerShell 5.1**. Niente Python, niente Node. Immagini con `System.Drawing`.
- La cartella scratchpad della sessione spesso **non è visibile a PowerShell** (percorso troppo lungo): per file temporanei usa `$env:TEMP\<nome corto>`.
- Font disponibili per le grafiche: famiglia Bahnschrift (`Bahnschrift SemiBold Condensed`, `Bahnschrift SemiBold SemiCondensed`, `Bahnschrift SemiBold`, ...). `Bahnschrift Bold Condensed` **non esiste**: GDI ripiega silenziosamente su Arial.
- In PowerShell la virgola lega più del `+`: dentro `@(...)` metti tra parentesi le stringhe concatenate, `@(('A' + 'B'), 'C')`.

## Come sono fatti i dati del gioco

- Template JSON compatti su una riga. Ogni componente ha un tipo `"$t"`, per esempio `{"$content":25000.0,"$t":"Expense"}` oppure i range `{"_min":0.0,"_val":40.0,"_max":40.0,"$t":"PowerGeneration"}`.
- Una mod **sostituisce interi file**: contiene il file vanilla completo con solo i valori cambiati, nello stesso percorso relativo (`template/...`). Due mod che toccano lo stesso file vanno in conflitto.
- Edifici: `template/strategy/construction/building/*.json`. Tempo di costruzione = `ProgressPoints._max` nello stato `Constructing`, in **ore** (288/360/480 = 12/15/20 giorni). Il mantenimento è `Expense`. I posti di lavoro sono la lista `PersonnelSlotsLink` nello stato `Enabled`. Gli upgrade (`*_improved`, `*_advanced`, torrette 2-4) non hanno un proprio `Expense`: lo ereditano.
- Personale: `template/strategy/masters/actor/combatant/human/xenonauts/{engineer,scientist}_master.json` (`Expense` = stipendio, `Cash` = costo di assunzione).
- Regioni: `template/strategy/geo_region/*.json`. `FlatRelationsFunding` è la quota fissa, `VariableRelationsFunding` la parte che dipende dai rapporti con la regione.
- Variabili globali utili: `template/common/global_variables/` (per esempio `engineering_point_generation_multiplier`).
- La velocità di costruzione **non** dipende dagli ingegneri e i dati non lo permettono: servirebbe un plugin di codice (BepInEx + Harmony). Nel codice esiste `ConstructionAssignmentEffects`, ma nessun dato lo usa.
- Aerei: profili in `template/strategy/aircraft/profiles/xenonaut/`, valori mancanti ereditati da `masters/aircraft/xenonaut.json` (`aircraft.json` è condiviso con gli UFO: non toccarlo). Il prezzo d'acquisto è il `CashPq` dei progetti `projects/engineering/aircraft_*_tier*.json`, non il `Cash` dei profili. I motori potenziati **sostituiscono** la velocità (`Speed` `Replace`).
- Nel gioco la velocità mostrata in km/h è `Speed` × 15.

## Aggiungere contenuti nuovi (verificato in gioco, vedi `ResearchTest/` e docs/PRD.md)

- Una mod può aggiungere **file nuovi**, non solo sostituirli: ricerche, progetti di officina, oggetti. Non c'è un indice da aggiornare: il gioco li carica dalla cartella.
- Ricerche e progetti nuovi compaiono **solo in una nuova campagna**.
- Nome e descrizione senza file di traduzione: `LocalizableGUID` con GUID nuovi e `"Request":"Ignore"`, più i componenti `Name` e `Description` con il testo.
- Effetti utili nel `ProjectFSM` (`EntryEffects.Finished`): `UpgradeItemsEffect` sostituisce un oggetto su tutti gli aerei del giocatore (arriva anche agli aerei esistenti); `DeltaItemEffect` con `Quantity: Infinity` + `AddItemToGeoBaseRequisitionEffect` rendono un oggetto disponibile in tutte le basi. Modello: `projects/engineering/aircraft_missiles_all_tier1.json`.
- Gli equipaggiamenti modificano l'aereo con il componente `Modifiers`; per i punti struttura il target è `Xenonauts.Common.Stats.HitPoints`, con `DeltaValue` = `DeltaMaximum` (con `DeltaValue` 0 sale solo il massimo e l'aereo risulta danneggiato finché non si ripara). L'armatura (`AirCombatArmorComponent`) invece usa `DeltaValue` 0, come nel gioco.
- **Immagini:** non sono nei dati moddabili, ma il gioco carica PNG messi nella mod in `texture/strategy/<percorso>` e chiamati con `ST-::-<percorso>`. Gli originali stanno negli asset bundle e non si estraggono senza strumenti esterni: per modificarli si parte da una schermata.
- I JSON del gioco contengono `Infinity`, che `ConvertFrom-Json` non accetta: per validarli sostituisci `:Infinity` con `:1e308`.

## Regole per modificare i template

- Modifica **il testo**, con regex mirate che devono trovare esattamente un'occorrenza (gli script lanciano un errore se no). **Non** fare `ConvertFrom-Json | ConvertTo-Json` sui template: PowerShell 5.1 riformatta i numeri (`25000.0` → `25000`), riordina e fa l'escape dei caratteri, e il loader del gioco è tipizzato.
- Scrivi i template in UTF-8 **senza BOM**. I `manifest.json` invece il gioco li salva **con BOM**: mantienilo, così il diff resta pulito.
- I file in `template/` sono **generati**: cambia i valori negli script `tools/build-*.ps1` e rigenera, non modificare il JSON a mano.
- Dopo ogni build: `tools/diff.ps1 -ModDir .\<Mod>` deve mostrare solo le differenze volute, e ogni JSON deve passare `ConvertFrom-Json`.

## Flusso di lavoro

```powershell
.\tools\extract-vanilla.ps1             # dati del gioco -> vanilla/ (ignorata da git)
.\tools\build-betterbase.ps1            # rigenera BetterBase/template
.\tools\build-financex3.ps1             # rigenera FinanceX3/template
.\tools\diff.ps1 -ModDir .\BetterBase   # verifica
```

Dopo una patch del gioco: estrai, rigenera, controlla `git diff`, aggiorna la versione nella dipendenza del manifest.

## manifest.json

- Campi che usiamo: `UID` (GUID nuovo per ogni mod), `Name`, `Description` (inglese, sezioni in MAIUSCOLO con elenchi `- `), `Visibility`, `Author` = `andreacw96`, `Website` = `https://steamcommunity.com/id/andreacw96/`, `Credits`, `Tags`, `Dependencies` (core UID `7409d306-8813-4ae2-b2e2-8e94d4dc39f1`, `"Version": {"&v": "<versione del gioco>"}`), `Version` della mod, `"$t": "14"` dentro `asset` e `"$t": "15"` fuori.
- Una mod nuova **non** ha `Source` né `WorkshopID`: li aggiunge il gioco alla prima pubblicazione. Non toglierli dopo.
- La versione del gioco supportata va **solo** nella dipendenza, **non** nella descrizione (richiesta dell'utente).
- Se generi il manifest con `ConvertTo-Json`, sostituisci poi `\u0026` → `&` e `\u0027` → `'`.
- **Il gioco riscrive `manifest.json` quando carica sul Workshop**, usando la copia letta all'avvio. Modifica i manifest **a gioco chiuso** e riavvialo prima di caricare, altrimenti le tue modifiche vengono sovrascritte.

## Pubblicazione

- Si carica e si aggiorna dal menu Mods del gioco (Steam deve essere aperto): l'utente lo fa da solo.
- Non iscriversi alle proprie mod sul Workshop mentre le copie locali sono attive, perché verrebbero caricate due volte.
- Anteprima: `preview.png` 1024×1024. Stile: sfondo scuro a pannelli verticali, barra in alto "XENONAUTS 2 · <TIPO> MOD" con strisce gialle e nere, titolo grande bianco con ombra, sottotitolo ambra `#f2b234`. L'utente preferisce solo titolo e sottotitolo, senza tabelle di dati. Niente immagini generate con l'AI. L'anteprima di Better Base l'ha fatta l'utente e non va rigenerata.

## Nuova mod

1. Trova i file da cambiare in `vanilla/` (cerca il nome del componente o il valore).
2. Crea `<Mod>/` e `tools/build-<mod>.ps1`, sul modello di `build-financex3.ps1`.
3. Scrivi `manifest.json` e `preview.png`.
4. Crea la junction: `New-Item -ItemType Junction -Path "<Mods>\<Mod>" -Target "<repo>\<Mod>"`.
5. Aggiorna README.md e docs/PRD.md, poi committa.
6. L'utente la prova in gioco e la pubblica.

Prima di creare una mod, controlla che non tocchi gli stessi file di BetterBase o FinanceX3: in quel caso o la si unisce a una delle due, o si dichiara l'incompatibilità.
