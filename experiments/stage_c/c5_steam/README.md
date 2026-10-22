# C5: GodotSteam test

Uses Valve's public test app **Spacewar (app id 480)**, so it needs no
Steamworks account and no Steam Direct fee yet.

The addon is not committed (about 120 MB of native libraries for every
platform). The Windows build in the project files already includes it.

## Run from the Windows build

1. Start Steam and log in.
2. Unzip `StageC-windows.zip`; keep `steam_appid.txt` next to `StageC.exe`.
3. Run `StageC.exe`, choose **C5**.
4. Pass: `RESULT: PASS`, and the Steam overlay shows an achievement toast.
   Use **Reset achievement** to run it again.

## Run from the editor

1. Download `godotsteam-4.23.2-gdextension-plugin-4.4.zip` from
   https://codeberg.org/godotsteam/godotsteam/releases/tag/v4.23.2-gde
   (GodotSteam GDExtension 4.23.2, Steamworks SDK 1.65, released 20 Oct 2026, MIT).
2. Unzip its `addons/` folder into `experiments/stage_c/` (git ignores it).
3. Create `experiments/stage_c/steam_appid.txt` containing `480` (git ignores it).
4. Start Steam, open the project, run, choose C5.

## Notes for the real game

- The plugin ships Android and Linux arm64 libraries too. Exclude
  `addons/godotsteam/*` from the Android and iOS export presets, and guard
  every Steam call with `Engine.has_singleton("Steam")` so mobile builds run
  without it.
- Steam isn't needed for development: without it this scene reports FAIL and
  the rest of the project still runs.
