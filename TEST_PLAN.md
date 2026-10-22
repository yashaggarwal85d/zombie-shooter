# Test Plan

How we check that the game works and stays working. Status: **skeleton** (22 October 2026). Feature-level test cases are added with each feature, from its acceptance criteria in GAME_DESIGN_DOCUMENT.md.

**Rule:** nothing is called done until it has been run. "The code should work" is not a result. Say what was run, where (CI, editor, which device) and what happened.

## 1. Automated (every push and PR)

| Check | Tool | Catches |
|---|---|---|
| Script compile check | `tools/check_scripts.gd` | Untyped or broken scripts anywhere outside `addons/`, even ones no test loads |
| Unit tests | GUT, `tests/unit/` | Logic in Resources and plain scripts (damage, noise, loop rules, save round trips) |
| Project config guard | `tests/unit/test_project_config.gd` | Engine version drift, typing turned off, missing input actions, display settings changed |
| Main scene smoke test | same file | The entry scene fails to load or loses required nodes |
| Exports (on `main` and on demand) | CI export job | Windows and Android builds that no longer export |

Run locally before pushing:

```
godot --headless --path . --import
godot --headless --path . --script res://tools/check_scripts.gd
godot --headless --path . -s res://addons/gut/gut_cmdln.gd
```

**What to unit test:** rules and numbers, not visuals or feel. A good test names one rule from the GDD and checks it ("a loud weapon's noise pulse pulls enemies within radius R"). Keep logic out of `_process` where possible so it can be tested without running frames.

**What not to unit test:** animation, shaders, layout, feel. Those are checked by hand (section 2).

## 2. Manual

| Check | When | How |
|---|---|---|
| Feel and fun | Every playable build | Yash plays; notes against the prototype gates in the GDD |
| Readability | Look test, slice | Greyscale screenshot test: danger stays visible without colour (Stage B section 3) |
| Performance | Stage C (C3), then every milestone | Reference PC at 60 fps; reference Android phone at 30 fps on the low preset over 20 minutes. Record the device, build and numbers. |
| Device launch | Each export milestone | Install the CI artifact on Windows and on an Android phone; launch, play 5 minutes, quit, relaunch |
| Suspend and resume | Once saves exist | Phone: switch away mid-night, kill the app, reopen, check the mid-run save |
| Input | Each input change | Mouse and keyboard, gamepad (slice), touch (port) |
| Safe areas | Any HUD change | Phone with a notch or cutout, both landscape directions |

## 3. Playtests

Planned from the vertical slice. Recruitment, questions and the go/no-go use for results go in ROADMAP.md when the slice is scheduled.

## 4. Platforms not tested yet

- **iOS:** parked (D8). Needs a Mac export and an iPhone.
- **Steam Deck:** at the slice, with gamepad support.
