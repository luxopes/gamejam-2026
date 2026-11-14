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
| `scenes/level_1.tscn` | původní zkušební úroveň |
| `scenes/level_forest.tscn` | hlavní úroveň (části 1–4 a šachta). Generuje ji Antonínův nástroj, ručně ji neupravuj (změny se přepíšou), změny v úrovni hlas Antonínovi |
| `scenes/player.tscn` + `scripts/player.gd` | hráč (pohyb, skok, kamera) |
| `scenes/platform.tscn` | plošina, velikost a barva se nastavují v Inspektoru |
| `scenes/coin.tscn` | mince |
| `scenes/hazard.tscn` | bodáky, dotyk ubere život |
| `scenes/checkpoint.tscn` | checkpoint: po smrti tu hráč začne, doplní životy |
| `scenes/enemy.tscn` | nepřítel (houba): chodí tam a zpět, po seku odletí, náraz do zdi ho zničí |
| `scenes/goal.tscn` | cíl úrovně |
| `scenes/hud.tscn` | počítadlo mincí a hláška o výhře |
| `scenes/time_flash.tscn` | bílý záblesk obrazovky při přechodu časem (autoload `TimeFlash`) |
| `scenes/music.tscn` | hudba přítomnosti a minulosti, při změně času se prolnou (autoload `Music`) |
| `assets/music/` | hudba (viz Zdroje assetů) |
| `scenes/vfx/` + `scripts/vfx.gd` | efekty: sek, zásah, zranění, dash, prach ze skoku a dopadu |
| `assets/vfx/` | obrázky efektů (viz Zdroje assetů) |
| `assets/characters/poutnik/` | sprite hráče (poutník): sheety a `poutnik_frames.tres` s animacemi |
| `assets/characters/mushroom/` | sprite nepřítele (houba): sheety a `mushroom_frames.tres` s animacemi |
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
| `assets/characters/mushroom/*.png` (nepřítel) | [Forest Monsters 2D Pixel Art](https://monopixelart.itch.io/forest-monsters-pixel-art) od MonoPixelArt, bezplatná verze: Mushroom (`Idle`, `Run`, `Die` bez VFX, `Hit` s VFX), soubory beze změny | použití v jakémkoli projektu i komerčně; balíček se nesmí přeprodávat ani šířit dál jako assety |
| `assets/music/present.wav` (hudba přítomnosti) | David (tým) | tým |
| `assets/music/past.mp3` (hudba minulosti) | David (tým), se zvukem [Ambience, Forest, Bird Sing, Black Forest Czech Republic](https://www.epidemicsound.com/sound-effects/tracks/01136a7f-b7ce-4e05-be80-be15e7fac08d/) z Epidemic Sound | tým; zvuk z Epidemic Sound podle předplatného |
| `assets/vfx/*.png` (efekty) | [PVFX Foundry](https://nerijs.itch.io/pvfx-foundry) od nerijs (Pixel VFX Studio), styl Strict: `axe-smear` → `slash`, `hit-spark` → `hit_spark`, `punch-hit` → `hurt_burst`, `dash-dust` → `dash_dust`, `dust-puff` → `dust_puff`, `treasure-glint` → `treasure_glint` (třpyt u hádankových věcí), `bloom-heal` → `bloom_heal` (rozkvět výhonku) | CC0 1.0 |
| `assets/vfx/portal.png` (portál) | [Portals 32 x 48](https://opengameart.org/content/portals-32-x-48) od RodHakGames, soubor beze změny; používá se modrý (do přítomnosti) a oranžový řádek (do minulosti) | CC0 1.0, autor prosí o uvedení: „Portals made by RodHakGames - RHG“ |
| `assets/items/coin.png` (zlatá mince) | [Simple rotating coin](https://opengameart.org/content/simple-rotating-coin) od sacio, soubor beze změny | CC0 1.0 |
| `assets/vfx/item_feedback.png` (efekt sebrání) | [Sunny Land](https://opengameart.org/content/sunny-land-2d-pixel-art-pack) od Luis Zuno (ansimuz); `item-feedback-1` až `4` spojené do jednoho pásu | CC0 1.0 |
| `assets/items/crystal.png` (odrazový krystal) | [Ancient Crystal 2D Pixel Art](https://opengameart.org/content/ancient-crystal-2d-pixel-art) od One To Zero, soubor beze změny | CC0 1.0 |
| `assets/levels/sunnyland/*` (dlaždice, pozadí, strom, chaloupka, rostliny, truhla v cíli a její zvuk) | [Sunnyland Forest](https://opengameart.org/content/sunnyland-forest) od Luis Zuno (ansimuz), licence v `assets/levels/sunnyland/LICENSE.txt` | CC0 1.0 |
| `assets/ui/hearts.png`, `hearts_gray.png` (srdíčka v horní liště) | [Healthbar sprite](https://opengameart.org/node/182567) od ArtBIT, soubory beze změny | CC0 1.0 |
| `assets/ui/coin.png`, `coins.png` (ikona mincí v horní liště) | [Gold treasure icons 16x16](https://opengameart.org/content/gold-treasure-icons-16x16) od Bonsaiheldin (http://bonsaiheld.org), soubory beze změny | CC0 1.0 |
| `assets/fonts/PixelifySans.ttf` (písmo celé hry) | [Pixelify Sans](https://github.com/google/fonts/tree/main/ofl/pixelifysans) od Stefie Justprince, licence v `assets/fonts/PixelifySans-OFL.txt` | SIL OFL 1.1 |

VFX from PVFX Foundry by Pixel VFX Studio.

Mushroom from Forest Monsters 2D Pixel Art by MonoPixelArt.

Licence houby: „use this asset pack in any project, commercial or not, but refrain
from reselling, redistributing, or modifying it“. Autor v komentářích upřesnil, že
bezplatná verze jde použít komerčně a úpravy jsou povolené, jen ne za účelem
přeprodeje. Ve hře ji použít smíme. Kdyby se repozitář zveřejnil, šly by z něj
původní obrázky volně stáhnout, což se blíží šíření, takže se předtím zeptejte
autora, nebo `assets/characters/mushroom/` vyjměte.

Přítomnost i minulost používají stejné dlaždice, jen přebarvené shaderem
`assets/levels/world_tint.gdshader`: přítomnost do šeda (`present_world.tres`),
minulost do zelena (`past_world.tres`).

## Práce v týmu

- Před prací `git pull --rebase`, po práci commit a `git push`.
- Formát commitů a další pravidla jsou v `AGENTS.md`. Po naklonování jednou spusť
  `git config core.hooksPath .githooks` a `git config pull.rebase true`.
- Scény (`.tscn`) se špatně slučují. Domluvte se, kdo zrovna upravuje kterou
  scénu, ideálně má každý svoji úroveň nebo svůj objekt.
- Soubory `*.uid` a `*.import` do Gitu patří, složka `.godot/` ne.
