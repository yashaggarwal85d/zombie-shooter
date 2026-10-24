# Zombie Shooter (working title)

An atmospheric 2D side-view horde-defence shooter in Godot 4.7.2, for Windows (Steam), then Android and iOS. Stage D: the combat toy is playable (research/STAGE_D_COMBAT_TOY_SPEC.md).

## Run it

1. Install [Godot 4.7.2-stable](https://godotengine.org/download/archive/4.7.2-stable/) (standard build, not .NET).
2. Open `project.godot`. GUT is already in `addons/gut/`.
3. Press F5. The combat toy starts with the build step. Controls are on screen; F3 shows the debug overlay. Each finished night adds a row to `user://toy_log.csv` (on Windows, `%APPDATA%\Godot\app_userdata\Zombie Shooter (working title)\toy_log.csv`).

Tests: the GUT panel in the editor, or

```
godot --headless --path . -s res://addons/gut/gut_cmdln.gd
godot --headless --path . --script res://tools/toy/soak.gd -- 6   # scripted nights with rule checks
```

## Documents

| Document | What it holds |
|---|---|
| GAME_VISION.md, GAME_DESIGN_DOCUMENT.md | What the game is (Stage B) |
| DECISION_LOG.md | Every approved decision, with rejected alternatives |
| TECHNICAL_ARCHITECTURE.md | Engine, settings, code rules, folders, CI |
| ART_AND_AUDIO_GUIDE.md | Art and audio direction and pipeline |
| ROADMAP.md, BACKLOG.md | Stages and gates; features with cost and class |
| RISK_REGISTER.md, TEST_PLAN.md | Risks; how things get checked |
| ASSET_REGISTER.md | Source and licence of every asset |
| RELEASE_CHECKLIST.md | What must be true before a release |
| research/ | Stage A and B research |
