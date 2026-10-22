# Technical Architecture

How the project is built, what the tools are, and the rules code follows. Status: **skeleton** (22 October 2026). Nothing here is gameplay; the prototype fills in the systems once Stage C passes. Design facts come from GAME_DESIGN_DOCUMENT.md and DECISION_LOG.md. Where this file disagrees with them, they win and this file gets fixed.

## 1. Engine and tools

| Tool | Version | Why this one |
|---|---|---|
| Godot | **4.7.2-stable** (released 18 Aug 2026, current stable on [the archive](https://godotengine.org/download/archive/) as of 22 Oct 2026) | Approved engine. Standard build, not .NET: GDScript only, and .NET can't export to Android/iOS as reliably. |
| GDScript | statically typed | Untyped declarations are a compile error (section 4). |
| GUT | 9.7.1, vendored in `addons/gut/` ([bitwes/Gut](https://github.com/bitwes/Gut), MIT) | 9.7.x is the line built for Godot 4.7. Vendored so CI and offline work need no download. |
| GitHub Actions | `ubuntu-24.04` runners | Tests on every push and PR; exports on `main` and on demand. |

**Pin policy.** The version lives in four places: `tools/ci/install_godot.sh` (with SHA-512 hashes), `tests/unit/test_project_config.gd` (fails if the running engine differs), `project.godot` features, and this table. Upgrade only between milestones, never mid-feature, and only for a fix or feature we need. Change all four in one PR and re-run every export.

**Install locally.** Download the 4.7.2 standard build for your OS from the archive page and open `project.godot`. Export templates: Editor → Manage Export Templates → Download. Linux users can run `tools/ci/install_godot.sh <dir> --templates`.

## 2. Platforms (D5, D8)

| Platform | Preset | State |
|---|---|---|
| Windows x86_64 (Steam) | `Windows Desktop` | Exports from Linux CI. Ships first. |
| Android arm64-v8a | `Android` | Debug APK exports in CI with a throwaway keystore. Min SDK 24, target SDK 36 (Godot 4.7.2 defaults). Release signing is set up at the port. |
| iOS arm64 | `iOS` | Preset ready, **builds parked** (D8). Exporting needs macOS with Xcode and an Apple Team ID; Yash has a Mac. Nothing in CI. |

Every system is built so it runs on phones (D8): actions-only input, scalable UI with safe areas, no hover-only information, quality presets, and saves that survive suspension.

## 3. Project settings that matter

| Setting | Value | Reason |
|---|---|---|
| Renderer | **Mobile** on desktop and mobile (provisional) | One renderer means one look to tune, and the PC build shows what phones will show. Stage C test C3 compares it with Compatibility on the reference Android phone; switch if Compatibility is clearly faster with our lights and fog. |
| Base resolution | 1920×1080, window 1280×720 when developing | 16:9 is the Steam baseline. |
| Stretch | `canvas_items`, aspect `expand` | Scales smoothly to 4K and to 20:9 phones. `expand` shows more of the scene sideways on wide phones instead of letterboxing, so the arena must be built with extra margin at the sides. |
| Orientation | sensor landscape | Phones rotate between both landscape directions. |
| Texture compression | S3TC/BPTC (PC) and ETC2/ASTC (mobile) imported | Both are needed for one project to export everywhere. |
| Touch | `emulate_mouse_from_touch` on (default) | Menus work by touch without extra code. Gameplay touch controls come with the port. |

`tests/unit/test_project_config.gd` guards these, so an accidental editor change fails CI.

**Safe areas (D8).** HUD and menus sit inside a root `Control` that is inset by `DisplayServer.get_display_safe_area()`. Nothing interactive goes in the outer margin. This is built with the first HUD in the prototype.

## 4. Code rules

- **Typing.** `untyped_declaration` is an error, so every variable, parameter and return needs a type (`:=` inference is fine). `unsafe_*` warnings are on as warnings, not errors: GUT's assert helpers take untyped arguments, and treating `unsafe_call_argument` as an error rejects ordinary asserts in Godot 4.7. `addons/` is excluded from warnings.
- **Small, focused scripts.** One responsibility per script. Scene and script live together (`foo.tscn` + `foo.gd`).
- **Signals over singletons.** Children signal up, parents call down. No autoloads yet. Add one only for something that is truly global and outlives scenes (likely candidates: settings and save), and record it here when you do.
- **Data-driven content.** Weapons, components, enemies, traps, experiments and nights are custom `Resource` classes (GDD). The class scripts live in `src/<feature>/`; the `.tres` instances live in `data/<kind>/`. Treat loaded Resources as read-only templates. Anything that changes during a run is copied first (`resource.duplicate()`) or kept in a separate runtime object, because Godot shares one loaded Resource between everyone who loads it.
- **Input.** Gameplay reads InputMap actions only, never raw keys or buttons. `aim` is the right stick; mouse aim reads the pointer position. Touch controls will press the same actions. The action list comes from GDD section 5; bindings are provisional.
- **Movement and pathing.** The field is one line (D11). The infected walk left or right toward their target and stop at whatever structure blocks them; they never jump or climb. No navigation mesh or waypoint graph. The player uses `CharacterBody2D` with jump and ladders.
- **Saving.** Files go under `user://` with a version number in each file. A mid-run save is written at each day, plus on `NOTIFICATION_APPLICATION_PAUSED` and `NOTIFICATION_WM_CLOSE_REQUEST`, because phones suspend and kill apps without warning (GDD, D8).
- **Naming.** Godot style guide: `snake_case` files, functions and variables; `PascalCase` classes and nodes; `_leading_underscore` for private members.

## 5. Folder layout

```
project.godot, export_presets.cfg, icon.svg
addons/gut/          vendored test framework (excluded from exports)
src/                 game code and scenes, grouped by feature
  core/              small shared helpers (BuildInfo)
  main/              entry scene
data/                .tres content instances, one folder per kind
assets/              art/, audio/, fonts/ (each file logged in ASSET_REGISTER.md)
tests/unit/          GUT tests, test_*.gd
tools/               check_scripts.gd and CI scripts (excluded from exports)
experiments/         Stage C experiments, each its own nested Godot project (skipped by the editor and exports)
research/            design and market research (Markdown only)
*.md at the root     source-of-truth documents
```

## 6. Testing and CI

Details in TEST_PLAN.md. In short:

- `tools/check_scripts.gd` loads every script outside `addons/` and nested projects, and fails if any won't compile. This catches untyped code in files no test touches.
- GUT runs everything in `tests/`. Run locally: `godot --headless --path . -s res://addons/gut/gut_cmdln.gd`, or the GUT panel in the editor.
- `.github/workflows/ci.yml`: the **test** job runs on every push and PR. The **export** job runs on `main` and on manual dispatch, builds the Windows exe and an Android debug APK, and uploads both as artifacts for 14 days.
- Headless Godot can stop at a debugger prompt on a script error, so CI feeds it `/dev/null` and wraps each step in `timeout`.

## 7. Git

- `.gitattributes` normalises text to LF and marks art, audio and builds as binary.
- `.godot/`, `/build/` and every signing file (`*.keystore`, `*.jks`, `*.p12`, provisioning profiles) are ignored. Signing secrets go in GitHub Actions secrets or a local file outside the repo, never in `export_presets.cfg`.
- **Git LFS: not used yet.** The repo is a few MB, and LFS adds a bandwidth quota that CI checkouts eat into. Turn it on when large binary sources appear (Krita/PSD files, audio stems, video), likely at the look test. Track only those types, and do it before the first such file is committed.
- Each Godot script has a `.uid` file beside it (Godot 4.4+). Commit them; they keep references stable when files move.

## 8. Placeholders to settle before release

- **Package and bundle ID** `com.yashaggarwal.zombieshooter` in the Android and iOS presets. It can't change once the app is published on a store, so confirm it when the game has a name (RELEASE_CHECKLIST.md).
- Project name "Zombie Shooter (working title)", app icon, version numbers.

## 9. Open technical questions (Stage C)

From research/STAGE_B_DESIGN_RESEARCH.md section 11 (Stage B PR #2):

| # | Question | Experiment |
|---|---|---|
| C1 | Do the Windows and Android exports launch on real hardware and drive a test character with these actions? | Stage C thread |
| C3 | Mobile vs Compatibility renderer; can 60 enemies, 2D lights and fog hold 60 fps on PC and 30 fps on the reference phone? | Stage C thread |
| C4 | Does the waypoint graph handle 60 agents across three floors under 2 ms a frame? | Stage C thread |
| C5 | Does GodotSteam (Codeberg build) work with 4.7.2 for an achievement and cloud save? | Stage C thread |
| — | Is physics interpolation needed for smooth motion on 90/120 Hz phones? It's off for now. | Fold into C3 |
