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

Incompatibile con Finance x10 e con qualsiasi mod che modifichi i template delle regioni. Compatibile con Better Base. Il nuovo finanziamento arriva dal pagamento mensile successivo.

## Stato

| | Better Base | Finance x3 |
|---|---|---|
| Testata in gioco | sì | sì |
| Pubblicata sul Workshop | sì (1.0.0) | sì (1.0.0) |
| Anteprima | fatta dall'utente | `tools/preview-financex3.ps1 -TitleOnly` |

**Da fare:** la versione pubblicata di entrambe contiene ancora "Built for Xenonauts 2 v7.27.13" nella descrizione, perché il gioco l'ha reinserita durante il caricamento. Nel repo è già stata tolta: va caricato un aggiornamento dal gioco, riavviandolo prima.

## Idee per il futuro

- Tempi di costruzione che scalano con gli ingegneri (richiede un plugin di codice, vedi sopra).
- Varianti di Finance (x2, x5) generate dallo stesso script con un parametro.
- Controllo automatico dopo ogni patch: estrarre, rigenerare e segnalare se uno script non trova più un valore.
