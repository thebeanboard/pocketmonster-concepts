# Pokémon Concepts Vector Archive

[![GitHub Pages](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-blue?style=flat-square&logo=github)](https://thebeanboard.github.io/pocketmonster-concepts/)
[![Vectors](https://img.shields.io/badge/Vectors-126%20SVGs-green?style=flat-square)](https://thebeanboard.github.io/pocketmonster-concepts/)

A complete, high-fidelity vector restoration of all 42 original hand-drawn Pokémon concepts from the scan archive (`Pokémon Concepts Scan Jun 23, 2020 at 7.16 PM.pdf`).

**Live Archive Gallery:** [https://thebeanboard.github.io/pocketmonster-concepts/](https://thebeanboard.github.io/pocketmonster-concepts/)

## Repository Structure

```
pocketmonster-concepts/
├── index.html                  # Interactive vector gallery viewer
├── pokemon_metadata.json       # Structured metadata for all 42 concepts
├── build_vectors.swift         # Vector generation & morphological extraction pipeline
├── vectors/
│   ├── cards/                  # 42 Pokémon Trading Card vector SVGs
│   │   ├── 01_ryeloaf_card.svg
│   │   ├── 02_flocicle_card.svg
│   │   └── ... (42 files)
│   ├── creatures/              # 42 Isolated Pokémon creature vector SVGs
│   │   ├── 01_ryeloaf_creature.svg
│   │   ├── 02_flocicle_creature.svg
│   │   └── ... (42 files)
│   └── concepts/               # 42 Restored hand-drawn concept sheet SVGs
│       ├── 01_ryeloaf.svg
│       ├── 02_flocicle.svg
│       └── ... (42 files)
```

## Vector Formats

Every Pokémon concept is vectorized into three distinct SVG formats (126 vector files total):

1. **Trading Cards (`vectors/cards/`)**: Full-color vector Pokémon trading cards styled with official type palettes (Fairy, Water, Bug, Fire, Electric, etc.), stage details, evolution chains, HP, custom attacks, and the centered creature illustration.
2. **Creature Vectors (`vectors/creatures/`)**: Pure standalone vector paths of the creature drawing, tightly cropped and centered with proper SVG `viewBox` coordinates. Ideal for icons, sprites, stickers, print, or web assets.
3. **Restored Concept Sheets (`vectors/concepts/`)**: Cleaned vector representations preserving the authentic hand-drawn creature illustration, handwritten name, and original evolution/type notes, with all scanner shadows, borders, spiral holes, and notepad advertising removed.

## Interactive Gallery Viewer

To explore the archive interactively, open `index.html` in any web browser:

```bash
open index.html
```

- **View Modes**: Toggle between **Trading Cards**, **Creature Vectors**, and **Concept Sheets**.
- **Type Filtering**: Filter by any of the 17 Pokémon types.
- **Search**: Instant search across names, evolutions, and concept notes.
- **Modal Inspector**: Zoom into vector curves, toggle formats, copy raw SVG XML, or download individual SVGs.

## Complete Concept Roster

| # | Name | Primary Type | Secondary Type | Evolution 1 | Evolution 2 | Notes |
|---|---|---|---|---|---|---|
| 01 | Ryeloaf | Fairy | — | Berkery | Kneeden | Bread loaf fairy |
| 02 | Flocicle | Water | Ice | — | — | Icicle / flow creature |
| 03 | Pholeap | Bug | — | Jiglon | — | Leaping insect |
| 04 | Scribs | Electric | — | Stato | Flowstat | Static charge creature |
| 05 | Firenado | Fire | — | Flamenado | Infernado | Vortex flame cyclone |
| 06 | Floatson | Normal | Water | Floatmore | Floatarey | Buoyant floating creature |
| 07 | Puku | Fairy | Fighting | Pillicka | — | Boxer puck (Dated 4/1/2010) |
| 08 | Stinsketto | Bug | Poison | — | — | Stink mosquito (Dated 10-5-10) |
| 09 | Leatherind | Normal | Dragon | — | — | Leathery dragon hide beast |
| 10 | Glaciator | Ice | Fighting | Freezard | — | Alligator gladiator with ice crystals |
| 11 | Stines | Poison | — | — | — | Toxic venomous stinger |
| 12 | Nipecoon | Normal | — | — | — | Cocoon / raccoon hybrid |
| 13 | Fizzsprits | Fairy | Water | Fizzaroo | Foamdoma | Effervescent fizz fairy |
| 14 | Drincup | Water | — | Spillsplash | Soakrack | Quiet but excitable |
| 15 | Bandiqui | Bug | Dark | Thievaity | — | Bandit bug thief |
| 16 | Craykee | Steel | — | — | — | Metallic key mechanism |
| 17 | Mussin | Fairy | Normal | Bushinch | — | Fluffy moss / bush sprite |
| 18 | Elelunt | Ghost | Normal | Elejint | Mamotuff | Haunted pachyderm mammoth |
| 19 | Acesheba | Normal | — | Aceruner | — | Swift runner canine |
| 20 | Frightnite | Ghost | — | Frightlite | Nite Lite | Corner nocturnal apparitions |
| 21 | Konetoad | Water | Ground | — | — | Cone-shelled amphibian |
| 22 | Floopy Jr. | Normal | — | — | — | Cheerful shapeless blob |
| 23 | Rosewall | Grass | — | — | — | Floral barrier blossom |
| 24 | Shinecloud | Fire | Electric | Funzap | Funderstorm | Playful and mischievous |
| 25 | Yourbee | Grass | Bug | Yourdrone | Youroyale | Happy but quick to anger |
| 26 | Zeebean | Fighting | Electric | Zeepod | Sproutbout | Energetic bean fighter |
| 27 | Zowzahorn | Fairy | Dragon | Drumiss | Zowzaband | Musical seahorse trumpet |
| 28 | Sir Pressur | Steel | — | — | — | Armored pressure knight |
| 29 | Mushroot | Grass | — | — | — | Fungal spore root |
| 30 | Nosesniffa | Normal | Flying | Achooket | Lucisnuff | Keen-scented avian |
| 31 | Lockit | Steel | — | — | — | Padlock fortress guardian |
| 32 | Shardu | Rock | Steel | Shardthrew | Shardpoon | Geometric crystal shard |
| 33 | Smile | Normal | Fairy | Emozs | — | Joyful emotion expression creature |
| 34 | Battlelite | Steel | Fighting | — | — | Combat automaton warrior |
| 35 | Bedder | Normal | — | Bedrsar | Snordabed | Sleepy slumber pillow creature |
| 36 | Grarepatch | Grass | — | Hopiow | Basebun | Meadow patch rabbit creature |
| 37 | Plastisteel | Steel | — | Amalgamate | — | Malleable synthetic alloy |
| 38 | Snarcor | Rock | Psychic | — | — | Mystic mineral psychic |
| 39 | Jointremel | Fairy | Normal | Nottied | — | Ribbon tied pretzel fairy |
| 40 | Clownini | Psychic | Ghost | — | — | Phantom jester apparition |
| 41 | Potlee | Ground | Grass | Baysprout | — | Earthen pot sproutling |
| 42 | Brufru | Fairy | Grass | Fruchew | Chuthrou | Sweet berry fruit fairy |
