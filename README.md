# Game Jam Platformer (šablona)

Úplně jednoduchý základ 2D plošinovky v **Godotu 4.7**. Žádné obrázky ani zvuky,
všechno jsou barevné obdélníky, takže se dá cokoli hned vyměnit za vlastní grafiku.

## Spuštění

1. Otevři Godot 4.7 (všichni v týmu stejnou verzi) → **Importovat** → vyber `project.godot`.
2. Zmáčkni **F5**.

## Ovládání

| Akce | Klávesy | Gamepad |
|---|---|---|
| Pohyb | A / D nebo šipky | páčka, kříž |
| Skok | Mezerník | A |
| Útok (sek) | levé tlačítko myši nebo J | X |
| Dash | Shift | RB |
| Míření nahoru / dolů | W / S nebo šipky | páčka, kříž |
| Restart | R | Back |

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
- **Útok na nepřítele:** když má objekt funkci `hit(direction)`, sek ji zavolá.
  Když je ve skupině `pogo`, hráč se od něj sekem dolů odrazí (vzor: `enemy.tscn`).

## Práce v týmu

- Před prací `git pull --rebase`, po práci commit a `git push`.
- Formát commitů a další pravidla jsou v `AGENTS.md`. Po naklonování jednou spusť
  `git config core.hooksPath .githooks` a `git config pull.rebase true`.
- Scény (`.tscn`) se špatně slučují. Domluvte se, kdo zrovna upravuje kterou
  scénu, ideálně má každý svoji úroveň nebo svůj objekt.
- Soubory `*.uid` a `*.import` do Gitu patří, složka `.godot/` ne.
