# Pravidla pro práci v tomto repozitáři

Platí pro lidi i pro AI agenty (Claude Code, Codex, Copilot a další).
Projekt je 2D plošinovka v Godotu 4.7, popis struktury je v `README.md`.

## Formát commitů

```
<typ>: <krátký popis česky>
```

Příklady:

```
feat: přidá dvojskok
fix: hráč už nepropadává pohyblivou plošinou
level: druhá úroveň s ledovými plošinami
art: sprite hráče a animace běhu
```

Povolené typy:

| Typ | Kdy ho použít |
|---|---|
| `feat` | nová herní mechanika nebo funkce |
| `fix` | oprava chyby |
| `level` | stavba a úpravy úrovní |
| `art` | grafika, animace, fonty |
| `audio` | zvuky a hudba |
| `ui` | menu, HUD, texty na obrazovce |
| `refactor` | úprava kódu beze změny chování |
| `docs` | README, AGENTS.md, komentáře |
| `chore` | nastavení projektu, export, Git, úklid |

Pravidla pro zprávu:

- Typ malými písmeny, za ním dvojtečka a mezera.
- Popis česky, začíná malým písmenem, bez tečky na konci.
- První řádek má nejvýš 72 znaků.
- Popis říká, co commit dělá (`přidá`, `opraví`, `zrychlí`), ne co jsi dělal ty.
- Podrobnosti patří do těla zprávy, odděleného prázdným řádkem. Většinou není potřeba.
- Zprávy jako `update`, `wip`, `asdf` nebo `fix` bez popisu se nepoužívají.

## Čistá historie

- Jeden commit je jedna ucelená změna. Nemíchej opravu chyby s novou úrovní.
- Commituj jen funkční stav: hra se po commitu musí spustit (F5) bez chyb.
- Před pushem vždy `git pull --rebase`. Merge commity v historii nechceme.
- Na větvi `main` se nikdy nepoužívá `git push --force` ani přepisování
  už pushnutých commitů.
- Přidávej soubory jmenovitě (`git add scenes/level_2.tscn`), ne `git add .`,
  ať se do commitu nedostane nic navíc.

Jednorázové nastavení po naklonování (zapne kontrolu formátu a rebase):

```
git config core.hooksPath .githooks
git config pull.rebase true
```

## Godot

- Všichni používají Godot 4.7.
- Do Gitu patří `*.tscn`, `*.gd`, `*.gd.uid`, `*.import` a `project.godot`.
  Složka `.godot/` a exporty hry do Gitu nepatří.
- Scény (`.tscn`) se špatně slučují. Na jedné scéně pracuje v jednu chvíli jeden
  člověk, nové věci dělej raději jako vlastní scénu a do úrovně ji jen vlož.
- Neukládej scény, které jsi neměnil. Godot v nich umí přepsat ID a vznikne
  zbytečný rozdíl.
- `project.godot` měň jen kvůli konkrétní věci (nová klávesa, autoload) a dej to
  do samostatného commitu typu `chore`.
- Hodnoty k ladění dávej do `@export` proměnných, ať jdou měnit v Inspektoru.
- Komentáře v kódu česky, názvy proměnných, funkcí, uzlů a souborů anglicky.
- Styl kódu podle oficiálního GDScript style guide: `snake_case` pro proměnné,
  funkce a soubory, `PascalCase` pro uzly a třídy, odsazení tabulátory.

## Pro AI agenty navíc

- Drž věci jednoduché. Je to hra na game jam, ne framework: žádné zbytečné
  abstrakce, správce stavů ani pluginy, dokud o ně někdo nepožádá.
- Než cokoli commitneš, ověř, že se projekt načte bez chyb:
  `godot --headless --path . --quit-after 60`.
- Necommituj a nepushuj bez pokynu člověka, se kterým pracuješ.
- Neměň soubory, které s úkolem nesouvisí, a nepřeformátovávej cizí kód.
- Používej jen assety, které tým vytvořil nebo ke kterým má licenci, a zdroj
  zapiš do `README.md`.
