# Art and Audio Guide

How the game looks and sounds, and how art and audio are made, imported and kept consistent.
Status: **art direction v1, 23 October 2026.** The setting (section 2) is approved by Yash (D13). The rules in sections 3–6 become binding once Yash passes the look test (section 9). Final assets are still a vertical-slice job; this guide fixes the rules they will follow.

## 1. Decided earlier (DECISION_LOG D4, D11)

- Silhouette-led cutout or skeletal characters (Skeleton2D), painted or shape-built layered backdrops, fog and light done in shaders.
- Light-led style that Yash builds himself, with an artist if the look test falls short.
- The *feel* of Hollow Knight: Silksong as a principle only. No copying its style, characters, scenes or assets.
- **No AI-generated art or music ships.**
- Placeholders: CC0 preferred, CC-BY with attribution. Nothing NC, personal-use only or unclear. Every file logged in ASSET_REGISTER.md before it is committed.
- Readability first: effects never hide danger (project rule).
- Outdoors, side view of a small shelter, attacked from left and right, day and night, moving stop to stop (D11).

## 2. Theme: the Himalayan hill road (approved, D13)

The journey runs up a Himalayan hill road at the tail of the monsoon. Cloud sits in the valleys, deodar forests climb the slopes, and snow peaks show only at dusk, dawn and by day. The setting is a place, not a culture: no religious symbols, no named real towns, no costume or dialect work. The story stays as it is.

**Why:** it is distinct from the American and European woods most zombie games use (capsule and trailer stand out), mist is part of the place rather than decoration, and it maps one to one onto GDD v0.2's three backdrop kits. Yash can photograph his own references.

**Three backdrop kits (cap: 3; five stops mix them):**

| Kit | Shelter | Backdrop | Stops |
|---|---|---|---|
| Woods (built in the look test) | Kath-kuni hut: stone courses between timber bands, slate hip roof, carved eave fringe, stovepipe | Snow massif, foothills, forested ridge, two deodar layers, valley cloud | 1, 2 |
| Terraces | Stone farmhouse with a wooden upper balcony | Stepped fields as horizontal bands, a lone walnut tree, a stream gully | 3 |
| Hill-station edge | Tin-roofed shop or rest house, the end of a bazaar | Stacked roofs on a slope, water tanks, a clock tower, power lines | 4, 5 (her lab is the last building) |

Each kit reuses the same layer stack (section 4) and the same procedural tools; only the shapes change.

## 3. Readability and light rules

These are the rules every asset must pass. Tests in `tests/unit/look/test_look.gd` check the palette rules.

1. **The play plane is the darkest band.** The cabin, structures and every figure's body are darker than any layer behind them, and the mist at the foot of the trees keeps the play lane lighter than the figures standing in it. Figures read as dark shapes against light, never dark on dark.
2. **One cold light: the pod.** Her light through the window is always the brightest thing in the world (HUD aside). It pools on the ground, glows in the mist and edges the side of every figure and structure that faces the cabin. Its strength follows the cabin's health, so her light *is* her health bar.
3. **Warm means danger.** Saturated warm colours belong only to threat: the wind-up tell, hits on you, the loud barrel's flash. Dusk and dawn may warm the sky and the snow, muted (saturation under 0.35 on the play plane), never the play plane's tells. The quiet barrel is cold.
4. **Framing never enters the play lane.** Foreground boughs stay above the lane (above a high wall plus a jump); grass stays below the feet. Nothing in front of the band where the fighting happens.
5. **Every surface you can stand on carries a key-light edge** (roof ridge, wall tops, ladder rungs), so you can read where you can go at a glance.
6. **The player keeps a full thin cold outline**; the infected only get edges from the light. The player must never vanish against the cabin.
7. **Effects are brief and small.** Tracers, sparks and smoke last under half a second near figures and never cover a body.

## 4. Layer stack (far to near)

| # | Layer | Notes |
|---|---|---|
| 1 | Sky gradient | Top colour, then horizon colour low behind the peaks |
| 2 | Sun or moon | Additive glow; hidden by day (overcast) |
| 3 | Far massif + snow | One large peak over the cabin's right shoulder anchors the frame |
| 4 | Valley cloud | Fog shader, drifting |
| 5 | Foothills | |
| 6 | Mist | |
| 7 | Forested ridge | Tree fringe along the crest |
| 8 | Mist | |
| 9 | Near hill + small deodars | |
| 10 | Ground mist | Catches the pod's light |
| 11 | Near deodars | A clearing around the cabin so its outline reads |
| 12 | Lane mist | Rule 1 depends on this layer |
| 13 | Ground | |
| 14 | **Play plane** | Cabin, structures, ladders, then figures, then effects |
| 15 | Foreground | Rain, mist motes, boughs at the top corners, short grass |
| 16 | Screen grade | Shadow lift toward the time of day's tint, vignette, grain |
| 17 | HUD | Not graded |

## 5. Palettes and time of day

Four palettes live in `data/look/*.tres` (`LookPalette` resources, editable in the Godot inspector). Swatches are on the mood board (project files, `art_direction/mood_board.jpg`).

| Time | Mood | When it shows |
|---|---|---|
| Day | Overcast monsoon: cool green-grey, cloud in the valleys, light drizzle; pod light faint | The build step |
| Dusk | The ember stays in the sky and on the snow; the land goes black | The first ~5% of the night, blending to night by 20% |
| Night | Moonlit mist, rain, one cold light | The middle of the night |
| Dawn | Rose-grey first light on the snow | Blends in over the last 18%: the sky is a second clock |

Fixed accents: **pod light** `#B8E6FF` (hope), **danger** `#FF5A3C` (tells, hits, loud flash).

## 6. Shapes

- **Deodar** (the signature tree): flat drooping tiers that shorten toward the top, a nodding leader. Built by `LookShapes.deodar`.
- **Ridges:** peaks are folded noise; forested ridges get a fringe of tiny trees; snow follows the crest with a wandering lower edge.
- **Hut:** kath-kuni banding gives texture under rim light without detail painting; the slate roof's ridge is the walkable top.
- **Built pieces:** fence of leaning deodar poles and lashed slats; dry-stone wall under a timber cap; high wall as a log palisade on a stone footing.
- **Characters (not done yet):** still the Stage C placeholder silhouettes. Final characters are Skeleton2D cutouts (D4) made after Yash's rigging practice. Rules to keep: a distinct head-and-shoulder shape per enemy type, readable at 70 px tall, no interior detail that rim light can't show.

## 7. How the art gets made (budget under ₹10,000)

| Asset | Method | Who | Status |
|---|---|---|---|
| Backdrops, trees, ridges, mist | Procedural shapes and shaders in Godot (`src/look/`) | Claude builds, Yash tunes palettes | Woods kit v1 in the look test |
| Shelters and built pieces | Procedural shapes | Claude, Yash tunes | Woods hut v1 |
| Characters | Skeleton2D cutouts from shapes drawn in Krita | Yash (learning path in D4) | Not started |
| UI and fonts | OFL fonts, simple shapes | Claude | Toy HUD only |
| Capsule and key art | Composed from the in-game layers plus hand-drawn figure silhouettes | Yash + Claude | After the slice |
| Audio | See section 8 | | Synth placeholders |

If the look test or the slice art check falls short, D4's fallback applies: commission an artist for the key assets.

## 8. Audio direction (draft)

- Ambience: steady rain on slate, wind in the deodars, distant water. Night adds the pod's hum, which the infected hear.
- Weapons follow the noise rule: the loud barrel is a sharp crack with a valley echo; the quiet barrel is a dry cough.
- Music: sparse, one sustained instrument at dusk and dawn; silence through the night except the hum. No music ships unless it is made by a person and licensed (D4).

## 9. Look test (the D4 gate)

Run the combat toy (`src/toy/toy.tscn`); the look is on by default.

| Key | Does |
|---|---|
| F5 | Look on or off (back to the greybox, to compare) |
| F6 | Time of day: auto, day, dusk, night, dawn |
| F7 | Quality: high or low (low is the default on phones: no fog noise, less rain, no grain) |

Screenshots without a GPU: `xvfb-run godot --path . --rendering-driver opengl3 --resolution 1920x1080 --script res://tools/look/capture.gd -- <out_dir>`.

**Pass criteria (Yash judges):**
1. A still from the night would make you click on a Steam capsule.
2. You can always tell where you are, where the infected are and which of them is winding up, at a glance, in all four times of day.
3. The hut and the setting feel like a real place, not a generic forest.
4. 60 fps on your PC at high; 30 fps on your phone at low (C3 check).
5. You can see yourself tuning it: palettes and shapes are understandable enough for you to edit.

**If it passes:** build the other two kits at the slice, start the character rigs. **If it fails on taste:** say what's wrong and I iterate once. **If it fails twice:** D4's artist fallback.

## 10. Pipeline rules (technical)

| Topic | Rule |
|---|---|
| Folders | `assets/art/`, `assets/audio/`, `assets/fonts/`; placeholders in a `placeholder/` subfolder; procedural art in `src/look/`, palettes in `data/look/` |
| Source files | Krita/PSD/project files are kept outside the repo until Git LFS is turned on (TECHNICAL_ARCHITECTURE section 7) |
| Image format | PNG for art; SVG for icons and UI where it fits |
| Texture filter | Linear (project default), for painted art |
| Resolution | Author at the 1920×1080 base scale; mipmaps on for anything that scales down a lot |
| Mobile | Import with VRAM compression where quality allows; ETC2/ASTC is on in project settings |
| Shaders | Must run on Mobile and Compatibility renderers; anything costly has a low-preset path |
| Audio | WAV for short effects, Ogg Vorbis for music and loops |
| Fonts | OFL or equivalent licence, logged in ASSET_REGISTER.md |
| Quality presets | Fog and light effects must have a low preset that runs at 30 fps on the reference phone (C3) |
