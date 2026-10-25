# Zombie Shooter (working title)

An atmospheric 2D side-on horde-survival shooter in Godot 4.7.2, for Windows (Steam), then Android and iOS. Pre-prototype: there is no gameplay yet.

## Run it

1. Install [Godot 4.7.2-stable](https://godotengine.org/download/archive/4.7.2-stable/) (standard build, not .NET).
2. Open `project.godot`. GUT is already in `addons/gut/`.
3. Press F5. You'll see the skeleton screen with the build label.

Tests: the GUT panel in the editor, or

```
godot --headless --path . -s res://addons/gut/gut_cmdln.gd
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
