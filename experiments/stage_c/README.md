# Stage C experiments (throwaway)

Small, labelled experiments for Stage C (tech and pipeline validation), from
`research/STAGE_B_DESIGN_RESEARCH.md` section 11. **This is not game code.**
It is a standalone Godot 4.7.2 project nested inside the repo; the main
project ignores this folder because it has its own `project.godot`. Results
and the go/no-go are in `research/STAGE_C_TECH_VALIDATION.md`.

| Folder | Experiment |
|---|---|
| `c1_input/` | C1: InputMap actions (copied from the root project) on keyboard, mouse, gamepad and touch |
| `c2_look/` | C2: look test, HIGH/LOW presets, greyscale check, screenshot capture |
| `c3_perf/` | C3: performance sweep and 20-minute soak with a frame-time CSV |
| `c4_pathing/` | C4: waypoint-graph pathing and the noise rule; headless soak and a debug view |
| `c5_steam/` | C5: GodotSteam achievement and Steam Cloud round trip (see its README) |
| `c6_hook/` | C6: the 12-second hook clip used for the GIF |
| `shared/` | Building graph, noise rule, horde sim, the layered house view and shaders |
| `art_src/` | Script that draws the placeholder silhouettes (original, no third-party art) |
| `tests/` | Assert tests for the graph and noise rule |

## Run it

- **Editor:** open this folder's `project.godot` in Godot 4.7.2 and press F5. The menu lists every experiment.
- **Builds:** a Windows zip and Android APKs are in the project files under `stage_c/builds/`.
- **Command line** (anything after `--` is an option):

```
godot --path experiments/stage_c -- --scene=c3 --agents=100 --preset=low --minutes=20
godot --path experiments/stage_c --rendering-method gl_compatibility -- --scene=c3 --sweep
godot --headless --path experiments/stage_c --script res://tests/run_tests.gd
godot --headless --path experiments/stage_c --script res://c4_pathing/soak.gd -- --agents=60 --minutes=10 --seed=1
godot --path experiments/stage_c -- --scene=c2 --capture=/some/dir
```

C3 writes `c3_<preset>_<enemies>_<time>.csv` to the user data folder:
`%APPDATA%\Godot\app_userdata\Stage C experiments\` on Windows. On Android
the results screen shows the summary; take a photo of it.
