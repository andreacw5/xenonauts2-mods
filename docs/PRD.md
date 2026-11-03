# PRD: mod per Xenonauts 2

Autore: andreacw96 · Versione del gioco: 7.28.0 · Ultimo aggiornamento: 03/11/2026

## Obiettivo

Rendere la parte strategica (la base e l'economia) meno punitiva e meno lenta senza svuotarla: meno tempo ad aspettare le costruzioni, meno micro-gestione dei costi, ma con decisioni che contano ancora. Ogni mod deve:

- fare una cosa sola e chiara, con un nome che la descrive;
- stare un gradino sotto le mod "estreme" del Workshop da cui prende spunto;
- essere generata da script a partire dai dati del gioco, così da poterla rigenerare dopo ogni patch.

## Mod 1: Better Base

Workshop: [3831149512](https://steamcommunity.com/sharedfiles/filedetails/?id=3831149512) · Cartella: `BetterBase/` · Script: `tools/build-betterbase.ps1`

### Problema

In vanilla gli edifici richiedono da 12 a 20 giorni (in media circa 15), hanno capacità molto basse e costano parecchio da mantenere. L'utente usava la mod "Better Buildings AIO", che risolve il problema ma con valori eccessivi (magazzino e alloggi a 1000) e senza toccare i tempi di costruzione.

### Cosa fa

**Tempi di costruzione** (`ProgressPoints`, in ore)

| Edifici | Vanilla | Mod |
|---|---|---|
| Hangar, generatore, generatore Alenium, ascensore di accesso | 288 h (12 gg) | 144 h (6 gg) |
| Alloggi, magazzino, infermerie, radar livello 1 e 3, torrette 1-4, decodificatore quantistico | 360 h (15 gg) | 216 h (9 gg) |
| Laboratori e officine (tutti i livelli), centro addestramento, radar livello 2 | 480 h (20 gg) | 288 h (12 gg) |

**Edifici**

| Edificio | Componente | Vanilla | Mod |
|---|---|---|---|
| Magazzino | `Capacity` | 100 | 500 |
| Alloggi | `PersonnelCapacity` | 10 | 500 |
| Generatore | `PowerGeneration` | 40 | 250 |
| Generatore Alenium | `PowerGeneration` | 80 | 500 |
| Infermeria | `HitPointsHealingRate` / `SurvivalChance` | 2 / 20% | 3 / 50% |
| Infermeria avanzata | `HitPointsHealingRate` / `SurvivalChance` | 2,5 / 30% | 6 / 100% |
| Centro addestramento | `TrainingCapacity` | 12 | 50 |
| Laboratori e officine (tutti i livelli) | posti in `PersonnelSlotsLink` | 5 (4 nei potenziati) | 10 |

**Costi**

| Voce | Vanilla | Mod |
|---|---|---|
| Assunzione di ingegneri e scienziati (`Cash`) | $50.000 | $5.000 |
| Stipendio di ingegneri e scienziati (`Expense`) | $25.000/mese | $2.500/mese |
| Mantenimento di ogni edificio (`Expense`) | $25.000–120.000/mese | $2.500/mese |

**File toccati:** i 23 template in `template/strategy/construction/building/` più `engineer_master.json` e `scientist_master.json`.

### Scelte e motivazioni

- **Tempi 6/9/12 giorni.** Un primo −30% (8,4/10,5/14 gg) non bastava all'utente. 6/9/12 mantiene l'ordine tra gli edifici (più importante = più lento) con valori tondi.
- **Capacità dimezzate rispetto alla AIO** (500 invece di 1000, generatori 250/500 invece di 500/1000): restano generose ma non annullano del tutto la pianificazione dello spazio.
- **Ascensore di accesso con energia vanilla (80).** La AIO aveva un valore incoerente (`_val` 100 con `_max` 10), che non abbiamo riportato.
- **10 posti nei laboratori e nelle officine di ogni livello**, come la AIO (per i livelli potenziati è più del doppio).
- **Scartato:** tempi di costruzione che scalano con il numero di ingegneri. Non si può fare con i dati: servirebbe un plugin di codice (BepInEx + Harmony), che si rompe a ogni patch e non si distribuisce dal Workshop. Resta un'idea per il futuro.

### Compatibilità

Incompatibile con Better Buildings, con la sua AIO e con qualsiasi mod che modifichi gli stessi file. I nuovi tempi valgono per le costruzioni avviate dopo l'attivazione. Compatibile con Finance x3.

## Mod 2: Finance x3

Workshop: [3831149991](https://steamcommunity.com/sharedfiles/filedetails/?id=3831149991) · Cartella: `FinanceX3/` · Script: `tools/build-financex3.ps1`

### Problema

La mod "финансы х10" (Finance x10) moltiplica per 10 il finanziamento fisso delle regioni: il denaro smette di contare. L'utente voleva lo stesso approccio con un moltiplicatore moderato.

### Cosa fa

Moltiplica per 3 `FlatRelationsFunding` (la quota mensile fissa) delle sei regioni che finanziano il progetto:

| Regione | Vanilla | Mod |
|---|---|---|
| Nord America | $220.000 | $660.000 |
| Unione Sovietica | $220.000 | $660.000 |
| Europa occidentale | $160.000 | $480.000 |
| Asia-Pacifico | $160.000 | $480.000 |
| Africa e Medio Oriente | $110.000 | $330.000 |
| America Latina | $110.000 | $330.000 |
| **Totale** | **$980.000** | **$2.940.000** |

**File toccati:** 6 template in `template/strategy/geo_region/`. Groenlandia e acque internazionali non finanziano e non sono incluse.

### Scelte e motivazioni

- Come la x10, cambia solo la quota fissa. `VariableRelationsFunding`, cioè il bonus legato ai rapporti con la regione, resta vanilla: tenere contente le regioni conta ancora.
- Il moltiplicatore è una costante (`$multiplier`) nello script: per una variante (x2, x5) basta cambiarla e rigenerare.

### Compatibilità

Incompatibile con Finance x10 e con qualsiasi mod che modifichi i template delle regioni. Compatibile con Better Base. **Richiede una nuova campagna:** il finanziamento viene scritto nel salvataggio all'inizio della partita (verificato nei salvataggi e confermato da un commento su Finance x10).

## Mod 3: Better Aircraft

Cartella: `BetterAircraft/` · Script: `tools/build-betteraircraft.ps1`

### Problema

Gli aerei Xenonaut vanilla sono fragili, lenti sul Geoscape e con poca autonomia: si passa molto tempo a riparare e rifornire. L'utente voleva aerei più forti senza rendere banali i combattimenti aerei.

### Cosa fa

Su tutti gli intercettori (tier 0–3) e le dropship (tier 1–3):

| Componente | Effetto | Esempi vanilla → mod |
|---|---|---|
| `HitPoints` (`_val`, `_max`) | ×1,5 | intercettori 100/150/200 → 150/225/300; dropship 100/1000 → 150/1500 |
| `Speed` (velocità sul Geoscape) | ×1,25 | intercettori 144/240/320 → 180/300/400 |
| `FuelConsumptionRate` | ×0,75 (un terzo di autonomia in più) | 1,75 → 1,3125 |
| `HitPointRegenerate` (riparazione) | ×2 | 0,0625 → 0,125 |

**File toccati:** 7 profili in `template/strategy/aircraft/profiles/xenonaut/`, i master `masters/aircraft/xenonaut.json` e `xenonaut_dropship.json`, e i motori potenziati `engine_angel_tier2.json` e `engine_phantom_tier2.json`.

I motori potenziati (miglioria in officina) **sostituiscono** la velocità con un valore fisso: Angel 220, Phantom 300. Senza scalarli, dopo la miglioria il bonus andrebbe perso, e il Phantom (già a 300 con la mod) non guadagnerebbe nulla. Con la mod diventano 275 e 375.

### Scelte e motivazioni

- **Combattimento aereo invariato:** `ACSpeed`, accelerazione e virata restano vanilla, così gli scontri non diventano troppo facili.
- **Si modificano i master** perché alcuni aerei non hanno un valore proprio e lo ereditano (per esempio i punti struttura dell'intercettore tier 3 e della dropship tier 1). `masters/aircraft/aircraft.json` invece non si tocca: ne ereditano anche gli UFO.
- **Intercettore del tutorial escluso:** i suoi valori (20 punti struttura) sono parte dello scenario scritto. Eredita comunque la velocità e il consumo del master.
- L'intercettore tier 0 non ha una propria riparazione e la eredita da `aircraft.json` (0,04), quindi resta vanilla.

### Compatibilità

Incompatibile con qualsiasi mod che modifichi i profili o i master degli aerei Xenonaut. Compatibile con le altre tre mod. Da verificare in gioco se gli aerei già costruiti ricevono i nuovi valori.

## Mod 4: Aircraft Weapons +25%

Cartella: `AircraftWeapons/` · Script: `tools/build-aircraftweapons.ps1`

### Problema

Separata da Better Aircraft su richiesta dell'utente: chi vuole aerei più resistenti non per forza vuole anche più danno.

### Cosa fa

Moltiplica per 1,25 `ACWeaponDamage` (`_min`, `_val`, `_max`) di tutte le armi aeree Xenonaut:

| Arma | Vanilla (medio, tier 1–4) | Mod |
|---|---|---|
| Cannoni | 4 / 6 / 10 / 25 | 5 / 7,5 / 12,5 / 31,25 |
| Missili | 20 / 28 / 40 / 50 | 25 / 35 / 50 / 62,5 |
| Siluri | 45 / 68 / 90 / 140 | 56,25 / 85 / 112,5 / 175 |
| Lance (tier 1–3) | 15 / 15 / 40 | 18,75 / 18,75 / 50 |

**File toccati:** 14 template in `template/strategy/item/aircraft_equipment/`. `weapon_lance_2` non ha un danno proprio e lo eredita da `weapon_lance_1`.

### Scelte e motivazioni

- Solo il danno: distruzione dell'armatura, gittata, ricarica e munizioni restano vanilla.
- Nessuna arma UFO eredita dai file modificati (controllato), e i master delle armi non si toccano. Il missile del tutorial è escluso.
- Il moltiplicatore è una costante (`$multiplier`) nello script, come in Finance x3.

### Compatibilità

Incompatibile con qualsiasi mod che modifichi le armi aeree Xenonaut. Compatibile con le altre tre mod. Da verificare in gioco se le armi già montate ricevono i nuovi valori.

## Mod 5: Aircraft Costs -50%

Cartella: `AircraftCosts/` · Script: `tools/build-aircraftcosts.ps1`

### Problema

Gli aerei costano molto sia da comprare sia da mantenere. L'utente voleva ridurre solo i costi in dollari, lasciando invariati i materiali.

### Cosa fa

| Voce | Dove | Vanilla | Mod |
|---|---|---|---|
| Prezzo intercettori (tier 1–3) | `CashPq` dei progetti `projects/engineering/aircraft_interceptor_tier*.json` | $500.000 / 750.000 / 1.200.000 | $250.000 / 375.000 / 600.000 |
| Prezzo dropship (tier 1–3) | `CashPq` dei progetti `projects/engineering/aircraft_dropship_tier*.json` | $300.000 / 500.000 / 1.000.000 | $150.000 / 250.000 / 500.000 |
| Mantenimento di tutti gli aerei | variabile globale `aircraft_expense_multiplier` | 1,0 | 0,5 |

**File toccati:** 6 progetti in `template/strategy/projects/engineering/` e `template/common/global_variables/aircraft_expense_multiplier.json`.

### Scelte e motivazioni

- **Il prezzo vero è nel progetto di officina**, non nel `Cash` dei profili degli aerei (che ha valori incoerenti, come 1.000 per il tier 2). Così la mod non tocca i profili e non va in conflitto con Better Aircraft.
- **Mantenimento tramite la variabile globale:** un solo file, vale per tutti gli aerei, compresi quelli già costruiti.
- **Materiali invariati** (`ItemsPq`), su richiesta dell'utente.
- Il bonus regionale dell'Unione Sovietica sottrae 0,25 dalla stessa variabile: con la mod il moltiplicatore scende a 0,25 (vanilla 0,75).

### Compatibilità

Incompatibile con qualsiasi mod che modifichi i progetti di costruzione degli aerei o la variabile del mantenimento. Compatibile con tutte le altre mod del repo (verificato che non condivide file con loro né con le mod del Workshop installate).

## Stato

| | Better Base | Finance x3 | Better Aircraft | Aircraft Weapons +25% | Aircraft Costs -50% |
|---|---|---|---|---|---|
| Testata in gioco | sì | sì | sì (punti struttura, velocità) | no | sì (prezzo) |
| Pubblicata sul Workshop | sì (1.0.0) | sì (1.0.0) | no | no | no |
| Anteprima | fatta dall'utente | `tools/preview-financex3.ps1 -TitleOnly` | `tools/preview-card.ps1` | `tools/preview-card.ps1` | `tools/preview-card.ps1` |

## Prototipo: Research Test

Cartella: `ResearchTest/` · Non va pubblicata.

Serve a capire se si possono legare i bonus degli aerei a una ricerca nuova. Aggiunge un solo file **nuovo**, `template/strategy/projects/research/modtest_dummy_research.json`: una ricerca "MOD TEST: Dummy Research" senza prerequisiti (li eredita vuoti da `masters/projects/project.json`), 1.500 punti e nessun effetto. Il nome usa `LocalizableGUID` con `"Request":"Ignore"`, così il gioco mostra il testo del file senza voci nei file di traduzione.

Domande a cui risponde:

1. Il gioco carica un template nuovo aggiunto da una mod (finora le mod hanno solo sostituito file esistenti)?
2. La ricerca compare in laboratorio dall'inizio, con il suo nome e la sua descrizione?
3. Si completa senza errori?

**Risultato (03/11/2026, gioco 7.28.0):** in una **nuova campagna** la ricerca compare in laboratorio; caricando un salvataggio esistente no. Quindi:

- il gioco carica i template **nuovi** aggiunti da una mod, non solo quelli sostituiti;
- l'elenco delle ricerche viene fissato all'inizio della campagna: una mod che aggiunge ricerche richiede una nuova partita.

### Versione 0.2.0: ricerca con effetto vero

Aggiunge altri due file nuovi:

- `item/aircraft_equipment/modtest_armor_passiveregen_reinforced.json`: copia di `armor_passiveregen` (il pezzo di rigenerazione che tutti gli intercettori tier 1–3 montano di serie) con un modificatore `Xenonauts.Common.Stats.HitPoints` `Additive` +50. Nessun equipaggiamento aereo vanilla modifica i punti struttura; il componente e la forma del modificatore vengono dai moduli dell'esoscheletro (`groundcombat/item/attachment/module/simple/exosuit^extra_armour.json`).
- `projects/research/modtest_reinforced_airframe.json`: ricerca "MOD TEST: Reinforced Airframe" senza prerequisiti che, finita, applica `UpgradeItemsEffect` da `armor_passiveregen` al pezzo rinforzato, con lo stesso `ProjectFSM` dei potenziamenti delle corazze (`engineering/aircraft_armour_tier2.json`).

Domande a cui risponde:

1. Un modificatore di punti struttura su un equipaggiamento funziona sugli aerei?
2. Il potenziamento arriva agli intercettori già costruiti?
3. Arriva anche a quelli costruiti dopo la ricerca?
4. Nome e descrizione del pezzo nuovo si vedono?

Valori attesi per l'Angel (intercettore tier 1): 100 → 150, oppure 150 → 200 con Better Aircraft attiva.

**Risultato (03/11/2026, nuova campagna, con Better Aircraft attiva):** l'Angel di partenza passa da 150/150 a **200/200** a ricerca finita.

1. Sì: il modificatore `Xenonauts.Common.Stats.HitPoints` su un equipaggiamento funziona sugli aerei.
2. Sì: il potenziamento arriva all'aereo già esistente, con i punti struttura correnti alzati insieme al massimo.
3. **Da verificare:** un intercettore costruito dopo la ricerca.
4. Non applicabile: il pezzo di rigenerazione sta in un attacco nascosto (`HardpointType` `Reactor`) e non compare tra gli equipaggiamenti. Il bonus è visibile solo nel valore di Health.

Conferma anche Better Aircraft: l'Angel parte con 150 punti struttura invece di 100, e Top Speed 2.700 km/h invece di 2.160 (×1,25; il gioco mostra `Speed` × 15 in km/h).

### Versione 0.3.0: un equipaggiamento nuovo

Prova se una mod può aggiungere un oggetto equipaggiabile con la stessa catena del gioco (ricerca → progetto di officina → oggetto disponibile). Tre file nuovi:

- `item/aircraft_equipment/modtest_heavy_plating.json`: "Heavy Plating (MOD TEST)", figlia di `armor_tier1` (Ablative Plating) da cui eredita icona e aspetto sull'aereo. Modificatori: armatura +10 (Ablative 6), `HitPoints` +50, `AirCombatSpeedComponent` ×0,85; carico (`PowerUsage`) 5 invece di 3. È una scelta, non un potenziamento puro: più resistente ma più lenta e pesante.
- `projects/research/modtest_heavy_plating_research.json`: ricerca "MOD TEST: Heavy Plating", senza prerequisiti, 1.500 punti, nessun effetto proprio.
- `projects/engineering/modtest_heavy_plating.json`: progetto di officina sbloccato dalla ricerca (`ProjectPq` `Finished`), costo $50.000, durata `engineering_duration0` (60 punti). Finito, mette una quantità infinita della corazza nel magazzino di ogni base (`DeltaItemEffect`) e delle basi future (`AddItemToGeoBaseRequisitionEffect`), con lo stesso `ProjectFSM` del progetto dei missili (`engineering/aircraft_missiles_all_tier1.json`).

Domande a cui risponde:

1. Il progetto compare in officina dopo la ricerca?
2. A progetto finito, Heavy Plating compare con "∞" nella lista dello slot di equipaggiamento?
3. Montata sull'Angel, mostra armatura 10 al posto di 6 e Health +50, e il carico sale a 10/11?
4. Il nome e la descrizione si vedono nel tooltip?
5. Si vede l'icona nuova (piastre rosso ruggine con una fascia gialla e nera)?

**Icona.** Le immagini non sono tra i dati moddabili (`moddable_content.zip` contiene solo `.json`, `.csv`, `.txt`): stanno negli asset bundle. Dal manifest `generated_texture_strategy_1.manifest`, l'icona `ST-::-ui/aircraft_weapons/armor_tier1.png` è registrata come `Assets/Assets/xenonauts/texture/strategy/ui/aircraft_weapons/armor_tier1.png`. Per analogia con i template (`ST-::-` → `template/strategy/`), l'icona nuova sta in `ResearchTest/texture/strategy/ui/aircraft_weapons/modtest_heavy_plating.png` e la corazza la chiama `ST-::-ui/aircraft_weapons/modtest_heavy_plating.png`. È ricavata dall'icona dell'Ablative Plating, ritagliata da una schermata del gioco e ricolorata (l'originale non si può estrarre dal bundle senza strumenti esterni). Se lo slot mostra un'icona vuota, il gioco non carica immagini dalle mod: in quel caso si torna all'icona dell'Ablative Plating.

## Idee per il futuro

- Tempi di costruzione che scalano con gli ingegneri (richiede un plugin di codice, vedi sopra).
- Varianti di Finance (x2, x5) generate dallo stesso script con un parametro.
- Controllo automatico dopo ogni patch: estrarre, rigenerare e segnalare se uno script non trova più un valore.
