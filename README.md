# The Forest Bounced Back

A 2D platformer made for a game jam in Godot 4.7. Travel between the past and
present to change the forest and open a path forward. Slash enemies, bounce off
crystals and reach the chest at the end.

## Run

Open `project.godot` in Godot 4.7 and press **F5**. Press Enter or Space on the
title screen to start.

## Controls

| Action | Key |
|---|---|
| Move | A / D |
| Jump | Space |
| Slash | Arrow keys; each arrow attacks in that direction |
| Dash | Shift |
| Look up / down | Hold W / S while standing still |
| Restart from checkpoint | R |
| Pause / resume | Esc |

After finishing the game, wait for the credits to end, then press R to play again.
Collected coins and solved puzzles survive death; checkpoints restore health.

## Working on the game

| File | Purpose |
|---|---|
| `scenes/title.tscn` | Title screen; the game starts here |
| `scenes/level_forest.tscn` | Main level, generated from `levels/level_forest.json` |
| `scenes/level_1.tscn` | Original test level |
| `scenes/player.tscn`, `scripts/player.gd` | Movement, combat and camera |
| `scripts/time_world.gd` | Switches between the past and present |
| `scenes/time_trigger.tscn`, `scenes/time_blocker.tscn` | Objects that link changes in the past to the present |
| `scripts/game.gd` | Coins, puzzle flags, checkpoints and scene changes |
| `scenes/hud.tscn`, `scenes/pause_menu.tscn`, `scenes/credits.tscn` | HUD, pause menu and end credits |
| `scenes/music.tscn`, `scenes/time_flash.tscn` | Music crossfade and flash when changing time |
| `assets/sfx/`, `scripts/sfx.gd` | Jump, slash, coin and time travel sounds |
| `scenes/vfx/`, `scripts/vfx.gd` | Combat and movement effects |

Player settings are exported on the `Player` node. Character animations are in
`assets/characters/poutnik/poutnik_frames.tres`; enemy animations are in
`assets/characters/mushroom/mushroom_frames.tres`.

Coordinate forest layout changes with Antonín. The level editor reads
`levels/level_forest.json` and generates `scenes/level_forest.tscn`, overwriting
manual edits to that scene. To open the editor, run this from the project root
with Python 3 and `godot` on your PATH:

```sh
python3 tools/level_editor/server.py
```

The editor opens at `http://127.0.0.1:8765`. Set `GODOT` to the executable path
if Godot is installed under a different name or location.

See [AGENTS.md](AGENTS.md) for the Git workflow, Czech commit format and code
conventions. After cloning, enable the commit hook and rebase pulls:

```sh
git config core.hooksPath .githooks
git config pull.rebase true
```

## Credits and asset licenses

| Asset | Source | License / terms |
|---|---|---|
| Player sprites — `assets/characters/poutnik/` | David, team artwork | Team work |
| Mushroom enemy — `assets/characters/mushroom/` | [Forest Monsters 2D Pixel Art](https://monopixelart.itch.io/forest-monsters-pixel-art) by MonoPixelArt; free Mushroom pack, original files | Commercial and non-commercial game use allowed; asset resale and redistribution restricted |
| Present music — `assets/music/present.wav` | David | Team work |
| Past music — `assets/music/past.mp3` | David, with [Black Forest bird ambience](https://www.epidemicsound.com/sound-effects/tracks/01136a7f-b7ce-4e05-be80-be15e7fac08d/) from Epidemic Sound | Team work; ambience subject to Epidemic Sound subscription terms |
| Coin sound — `assets/sfx/coin.wav` | [coin 1.wav](https://freesound.org/people/robbeman/sounds/495643/) by robbeman (Freesound); original file | CC0 1.0 |
| Slash sound — `assets/sfx/sword.wav` | [10SWORD05.aif](https://freesound.org/people/lostchocolatelab/sounds/1468/) by lostchocolatelab (Freesound); lossless AIFF-to-WAV conversion | CC0 1.0 |
| Jump sound — `assets/sfx/jump.wav` | [JH FX Short Whoosh 1](https://freesound.org/people/Johnnie_Holiday/sounds/696649/) by Johnnie_Holiday (Freesound); shortened and converted from MP4 to WAV | CC0 1.0 |
| Time travel sound — `assets/sfx/portal.wav` | [Portal Phase Jump.wav](https://freesound.org/people/Vic5555/sounds/494484/) by Vic5555 (Freesound); original file | CC0 1.0 |
| Slash, hit, hurt, dash dust, jump/landing dust, treasure glint and bloom effects — `assets/vfx/` | [PVFX Foundry](https://nerijs.itch.io/pvfx-foundry) by nerijs / Pixel VFX Studio, Strict style | CC0 1.0 |
| Portal — `assets/vfx/portal.png` | [Portals 32 x 48](https://opengameart.org/content/portals-32-x-48) by RodHakGames; original file | CC0 1.0 |
| Collectible coin — `assets/items/coin.png` | [Simple rotating coin](https://opengameart.org/content/simple-rotating-coin) by sacio; original file | CC0 1.0 |
| Pickup effect — `assets/vfx/item_feedback.png` | [Sunny Land](https://opengameart.org/content/sunny-land-2d-pixel-art-pack) by Luis Zuno (ansimuz); four frames combined into a sheet | CC0 1.0 |
| Bounce crystal — `assets/items/crystal.png` | [Ancient Crystal 2D Pixel Art](https://opengameart.org/content/ancient-crystal-2d-pixel-art) by One To Zero; original file | CC0 1.0 |
| Forest tiles, backgrounds, props, chest and chest sound — `assets/levels/sunnyland/` | [Sunnyland Forest](https://opengameart.org/content/sunnyland-forest) by Luis Zuno (ansimuz) | CC0 1.0; [included license](assets/levels/sunnyland/LICENSE.txt) |
| HUD hearts — `assets/ui/hearts.png`, `hearts_gray.png` | [Healthbar sprite](https://opengameart.org/node/182567) by ArtBIT; original files | CC0 1.0 |
| HUD coin icons — `assets/ui/coin.png`, `coins.png` | [Gold treasure icons 16x16](https://opengameart.org/content/gold-treasure-icons-16x16) by [Bonsaiheldin](http://bonsaiheld.org); original files | CC0 1.0 |
| Font — `assets/fonts/PixelifySans.ttf` | [Pixelify Sans](https://github.com/google/fonts/tree/main/ofl/pixelifysans) by Stefie Justprince | [SIL OFL 1.1](assets/fonts/PixelifySans-OFL.txt) |

Portals made by RodHakGames - RHG.

The mushroom pack has separate restrictions on distributing its source assets.
Check with the author before publishing those files in a public repository.
