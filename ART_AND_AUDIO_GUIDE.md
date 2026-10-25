# Art and Audio Guide

How art and audio are made, imported and kept consistent. Status: **skeleton** (22 October 2026). The art direction itself (palette, shape language, references) is written after the look test (Stage C, C2). Until then this file holds only the pipeline rules and the decisions already made.

## Decided (DECISION_LOG D4)

- Silhouette-led cutout or skeletal characters (Skeleton2D), one painted multi-layer building, fog and light done in shaders.
- Light-led style that Yash builds himself, with an artist if the look test falls short.
- The *feel* of Hollow Knight: Silksong as a principle only. No copying its style, characters, scenes or assets.
- **No AI-generated art or music ships.**
- Placeholders: CC0 preferred, CC-BY with attribution. Nothing NC, personal-use only or unclear. Every file logged in ASSET_REGISTER.md before it is committed.
- Readability first: effects never hide danger (project rule).

## To write after the look test

- Palette and value ranges; how light marks danger.
- Silhouette rules per enemy type.
- Layer stack for the building (background, playfield, foreground fog).
- Animation style, rig conventions, frame counts.
- Audio direction: ambience, the chamber's hum, weapon loudness matching the noise rule.

## Pipeline rules (technical)

| Topic | Rule |
|---|---|
| Folders | `assets/art/`, `assets/audio/`, `assets/fonts/`; placeholders in a `placeholder/` subfolder |
| Source files | Krita/PSD/project files are kept outside the repo until Git LFS is turned on (TECHNICAL_ARCHITECTURE section 7) |
| Image format | PNG for art; SVG for icons and UI where it fits |
| Texture filter | Linear (project default), for painted art |
| Resolution | Author at the 1920×1080 base scale; mipmaps on for anything that scales down a lot |
| Mobile | Import with VRAM compression where quality allows; ETC2/ASTC is on in project settings |
| Audio | WAV for short effects, Ogg Vorbis for music and loops |
| Fonts | OFL or equivalent licence, logged in ASSET_REGISTER.md |
| Quality presets | Fog and light effects must have a low preset that runs at 30 fps on the reference phone (C3) |
