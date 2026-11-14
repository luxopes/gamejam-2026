# Game Jam Platformer (šablona)

Úplně jednoduchý základ 2D plošinovky v **Godotu 4.7**. Žádné obrázky ani zvuky,
všechno jsou barevné obdélníky, takže se dá cokoli hned vyměnit za vlastní grafiku.

## Spuštění

1. Otevři Godot 4.7 (všichni v týmu stejnou verzi) → **Importovat** → vyber `project.godot`.
2. Zmáčkni **F5**.

## Ovládání

| Akce | Klávesy |
|---|---|
| Pohyb | A / D |
| Skok | Mezerník |
| Útok (sek) | šipka rovnou sekne ve svém směru |
| Dash | Shift |
| Rozhlédnout se nahoru / dolů | podržet W / S ve stoje |
| Restart | R |

Klávesy se mění v *Projekt → Nastavení projektu → Mapa vstupů*.

## Co kde je

| Soubor | K čemu je |
|---|---|
| `scenes/level_1.tscn` | první úroveň, tady se staví |
| `scenes/player.tscn` + `scripts/player.gd` | hráč (pohyb, skok, kamera) |
| `scenes/platform.tscn` | plošina, velikost a barva se nastavují v Inspektoru |
| `scenes/coin.tscn` | mince |
| `scenes/hazard.tscn` | bodáky, dotyk ubere život |
| `scenes/checkpoint.tscn` | checkpoint: po smrti tu hráč začne, doplní životy |
| `scenes/enemy.tscn` | nepřítel: chodí tam a zpět, po seku odletí, náraz do zdi ho zničí |
| `scenes/goal.tscn` | cíl úrovně |
| `scenes/hud.tscn` | počítadlo mincí a hláška o výhře |
| `scenes/vfx/` + `scripts/vfx.gd` | efekty: sek, zásah, zranění, dash, prach ze skoku a dopadu |
| `assets/vfx/` | obrázky efektů (viz Zdroje assetů) |
| `assets/characters/poutnik/` | sprite hráče (poutník): sheety a `poutnik_frames.tres` s animacemi |
| `scripts/game.gd` | globální stav (`Game`): mince, restart, přechod do další úrovně |

## Nejčastější úpravy

- **Stavba úrovně:** v `level_1.tscn` označ plošinu, minci nebo past a zmáčkni
  Ctrl+D (duplikovat), pak ji přesuň. Plošině změň `Size` v Inspektoru.
  Zapni si přichytávání k mřížce (ikona magnetu nahoře).
- **Pocit ze skákání:** klikni na `Player` a v Inspektoru uprav `Speed`,
  `Jump Velocity`, `Gravity` a další.
- **Nová úroveň:** v panelu souborů duplikuj `level_1.tscn` jako `level_2.tscn`,
  přestav ji a v první úrovni nastav uzlu `Goal` vlastnost `Next Scene`.
  Když `Next Scene` zůstane prázdné, cíl ukáže „Vyhráno!“.
- **Vlastní grafika:** v dané scéně smaž `ColorRect` (nebo `Polygon2D`) a přidej
  místo něj `Sprite2D` nebo `AnimatedSprite2D`. Kolize zůstávají.
- **Nový nepřítel nebo past:** zkopíruj `hazard.tscn`. Cokoli ve skupině
  `hurts_player` hráči při dotyku ubere život. Okamžitě zabije `body.die()`.
- **Životy:** hráč má 5 životů, po zásahu chvíli bliká a je nezranitelný.
  Po smrti začíná na posledním checkpointu. Čísla jsou u `Player` ve skupině
  **Životy**, pro HUD je připravený signál `health_changed`.
- **Sprite postavy:** animace poutníka jsou v
  `assets/characters/poutnik/poutnik_frames.tres` (uzel `Sprite` v `player.tscn`).
  Kód sám přepíná `idle`, `run`, `jump`, `fall`, `dash`, `look_up` a `look_down`
  a otáčí postavu podle směru. Sek zatím animaci nemá, až bude, stačí přidat
  `attack` (volitelně `attack_up`, `attack_down`). Sheety mají snímky 128×128
  a ve hře se zmenšují na polovinu s vyhlazením (mipmapy), aby postava odpovídala
  hitboxu 32×48. Poutník ve sheetu kouká doprava (`Sprite Faces Left` u `Player`).
- **Útok na nepřítele:** když má objekt funkci `hit(direction)`, sek ji zavolá.
  Když je ve skupině `pogo`, hráč se od něj sekem dolů odrazí (vzor: `enemy.tscn`).

## Zdroje assetů

| Co | Zdroj | Licence |
|---|---|---|
| `assets/characters/poutnik/*.png` (hráč) | vlastní tvorba týmu: David | tým |
| `assets/vfx/*.png` (efekty) | [PVFX Foundry](https://nerijs.itch.io/pvfx-foundry) od nerijs (Pixel VFX Studio), styl Strict: `axe-smear` → `slash`, `hit-spark` → `hit_spark`, `punch-hit` → `hurt_burst`, `dash-dust` → `dash_dust`, `dust-puff` → `dust_puff` | CC0 1.0 |

VFX from PVFX Foundry by Pixel VFX Studio.

## Práce v týmu

- Před prací `git pull --rebase`, po práci commit a `git push`.
- Formát commitů a další pravidla jsou v `AGENTS.md`. Po naklonování jednou spusť
  `git config core.hooksPath .githooks` a `git config pull.rebase true`.
- Scény (`.tscn`) se špatně slučují. Domluvte se, kdo zrovna upravuje kterou
  scénu, ideálně má každý svoji úroveň nebo svůj objekt.
- Soubory `*.uid` a `*.import` do Gitu patří, složka `.godot/` ne.
