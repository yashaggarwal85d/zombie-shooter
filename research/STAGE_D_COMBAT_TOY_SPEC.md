# Stage D, step 1: combat toy spec

Version 0.1 · 22 October 2026 · Status: **draft, waiting for Yash's approval.** No gameplay code is written until this is approved (project rule: confirm purpose, behaviour, edge cases, tests and acceptance criteria first).

Source of truth: GAME_DESIGN_DOCUMENT.md section 13 (the combat toy row) and sections 4–8. This spec adds detail; it doesn't change any approved decision. Where it fills a gap, the line says *(new)*. Numbers marked *(tune)* are starting values the toy exists to tune.

## 1. Purpose

Answer one question before any more of the game is built: **is holding the chamber against a horde, with loud vs quiet as the main choice, fun for five minutes in a side-on cross-section?** The noise rule is the design's central bet (Stage B risk: "creates no real choice", critical). If the toy fails, we change the rule or fall back to top-down (D1) before the loop prototype exists.

It also settles three tunables carried from Stage C (D10): the noise **memory** (3 s), **hysteresis** (1.25×), and whether both join the GDD rule.

**Not in the toy:** day phase, scrap, barricades, traps, brute, experiments, saves, story, menus beyond a restart card, Steam, touch controls, final art.

## 2. Behaviour

### Arena
- Two floors and one stairwell (GDD 13). Ground floor (0) and upper floor (1). **The chamber sits on floor 1**, off-centre, so one side of it is closer to the stairwell. *(new: GDD puts it on the middle floor of three; with two floors, floor 1 keeps "she is upstairs, they come up to her".)*
- **Four entries:** a window at each end of each floor. All four can spawn in the toy's night.
- Built about 15% wider than 16:9 so the 20:9 phone `expand` stretch shows more wall, not void (TECHNICAL_ARCHITECTURE 3).
- Pathing: authored waypoint graph searched with `AStar2D`, ported from `experiments/stage_c/shared/building.gd` with tests. Floors and stairs only, no jumping.

### Player
- Move left/right (220 px/s *(tune)*). At the stairwell, `stairs_up`/`stairs_down` moves to the other floor in **0.35 s** *(tune; gate needs under 0.5 s)*. The player can be hit mid-transition.
- Health 100, no regeneration.
- **Aim:** mouse position, or the right stick (`aim`). Stick at rest keeps the last direction.
- **Dodge:** 0.3 s horizontal dash, 0.25 s invulnerability, 0.8 s cooldown *(tune)*.
- **Melee:** short arc in front, 1 damage, knockback, 0.4 s cooldown, noise pulse 20 (GDD 5).

### The firearm (GDD 9: one slot, two components)
- Hitscan along the aim line. **Shots stop at floors and ceilings**; you can't shoot through the building. Hits the first enemy; no pierce.
- 8-round magazine, 1.2 s reload, infinite reserve *(tune)*. Reload is cancelled by dodge.
- **Open barrel** (`loud`): 2 damage, noise pulse loudness 80, radius 900 px.
- **Suppressor** (`quiet`): 1.4 damage (−30%), loudness 30, radius 500 px, which is below the chamber's hum of 40.
- **Swapping:** press `interact` anywhere to swap. It takes **1.5 s** and you can't fire meanwhile *(new; toy only. In the full game swaps happen by day, GDD 3. Mid-night swapping is what lets the toy measure the choice.)*

### Noise rule (GDD 5, plus the Stage C findings)
- Perceived = `loudness × (1 − distance / radius)`, × **0.5 per floor crossed** *(GDD value; the Stage C experiment used 0.35. GDD wins; it's a tunable.)*
- Each shambler re-picks every 0.5 s. Ties go to the nearer source. Commits for 2 s once in melee range.
- **Memory:** after a pulse ends, an agent keeps heading for where it heard it for **3 s** *(tune)*.
- **Hysteresis:** a new sound must be **1.25×** louder than the current one to take the agent *(tune)*.
- The hum is constant (loudness 40) and is the fallback target.
- **Runners ignore noise** and always go to the chamber.

### Enemies (GDD 8)
| | Shambler | Runner |
|---|---|---|
| Speed *(tune)* | 60 px/s | 200 px/s |
| Health *(tune)* | 3 (2 loud shots, 3 quiet) | 2 |
| Targets | The sound it hears (player position for shots and melee) | Always the chamber |
| Attack | 10 to the player, 6 to the chamber, every 1.5 s | 8 to the chamber every 1.2 s; never attacks the player |
| Tell | 0.5 s pose + sound before every hit on the chamber (GDD 8) | same |

- Runners pass through the player; you can't body-block them, you have to shoot or melee them *(new)*.
- **Crowd spacing** *(new, from C4 finding 3):* each enemy gets a small stop-distance offset and a soft spacing push from neighbours on the same floor, so a crowd spreads into a ragged group instead of a single stacked file.
- On-screen cap 40 *(tune)*; spawns beyond it wait at their entry.
- An off-screen-edge marker shows where an enemy is about to enter (readability rule 4).

### The night
- One `NightDefinition` resource: **4 minutes** *(tune)*, a timed spawn schedule per entry. Shamblers in groups of 3–6 from the start; the first runner at about 0:45; mixed waves after 2:00 *(tune)*.
- A dawn bar is always visible. HUD: health, chamber integrity, ammo, current barrel (loud/quiet icon).
- **Win:** reach dawn. **Lose:** player health 0 or chamber integrity 0 (100 at start).
- **End card:** "Dawn", "You died" or "The chamber fell", then `fire` restarts the same night. It does **not** say what killed you, because the gate asks testers to say it themselves.
- `pause` freezes everything; losing window focus or the app being suspended pauses too.

### Debug overlay (GDD 5, prototype only)
- Toggled by a new `debug_overlay` action (F3). Shows a line from each enemy to its target, noise rings, the waypoint graph, and an fps/sim-time readout.

### Telemetry *(new, needed by the gate)*
- One CSV row per night in `user://toy_log.csv`: build, date, result, cause of loss (enemy type and target), duration, seconds firing each barrel, shots per barrel, swaps, stair transitions and their average time, chamber hits by enemy type, kills by type. The "% loud fire time" gate reads from this. Nothing leaves the device.

### Art and audio
- Greybox shapes plus the Stage C silhouettes (project-owned, made by `experiments/stage_c/art_src/make_silhouettes.py`) and its rim-light shader, ported into the root project.
- Sound matters for this toy (the hum and the gunshot are the mechanic). Placeholder sounds will be **CC0 only** (Kenney or CC0 entries on Freesound), each logged in ASSET_REGISTER.md before it's committed. If I can't download them here, I'll generate simple tones in code and say so.

## 3. Edge cases (each one is a test or a manual check)

1. Two equal sources → the nearer one wins.
2. Player standing by the chamber while firing loud → hum and shot both pull the same way; enemies converge on both (intended, Stage B).
3. A shot on floor 0 heard on floor 1 → halved, so it can pull floor-1 shamblers off the chamber only when it's much louder than the hum.
4. A pulse ends while an enemy is walking to it → it carries on for 3 s, then re-picks (usually the hum).
5. A quiet shot (30) next to an enemy already heading for the hum (40) → doesn't steal it.
6. Player on the stairs when a shambler targets them → the target is their last position; the shambler re-paths when the player lands.
7. Player dies and dawn arrives in the same frame → **the loss counts** *(new)*.
8. Player death and chamber fall in the same frame → reported as the chamber fall (it's the core fail) *(new)*.
9. Spawn while the cap is full or the entry is crowded → it waits; it's never dropped and never spawns inside another enemy.
10. Swap during reload → cancels the reload; the swapped barrel starts with a full magazine *(new, keeps it simple)*.
11. Shooting into a floor or ceiling → the shot stops there; it still makes noise.
12. Aiming with a gamepad stick at rest → keeps the last aim.
13. Restart → everything resets; the telemetry row for the finished night is already written.
14. Window loses focus or the phone app is suspended → the night pauses.
15. Holding `stairs_up` away from the stairwell → nothing happens; no input is buffered.

## 4. Tests

**Automated (GUT, run in CI on every push):**
- Noise: the formula, floor falloff, radius cut-off, tie-break, threshold, memory decay, hysteresis switching, runners ignoring noise (edge cases 1–5).
- Waypoint graph: paths between every entry and the chamber, stairs only between floors, no path through a floor.
- Weapon: component stats load from `.tres`; damage, magazine, reload timing, swap timing and cancel (10); loud and quiet loudness values.
- Combat rules: damage to player and chamber, the 0.5 s tell before any chamber hit, win and loss conditions and their precedence (7, 8).
- Night: spawn schedule fires at the right times from `NightDefinition`; the cap queues spawns (9).
- Crowd spacing: 20 shamblers on one target settle with no two closer than the minimum gap.
- Resources: loaded definitions are never mutated at runtime (duplicated first).
- Telemetry: a scripted night writes one row with the correct loud/quiet split.
- **Headless soak:** a scripted player plays 10 simulated nights; 0 stuck enemies, no errors, sim time p99 under 2 ms.
- Main scene and toy scene load and have their required nodes.

**Manual (Yash):** feel, readability in motion, stairs and dodge feel, whether crowd turns read as "I pulled them" or as jitter (C4 finding 2), and the GDD gate below.

I will say exactly what ran where. Cloud runs are headless only; nothing will be claimed as "played" until you play it.

## 5. Acceptance criteria

**Build done (my side), before you play:**
- All automated tests pass in CI; the script check is clean.
- Windows build and Android debug APK export in CI; I'll put them in project files.
- Every asset logged in ASSET_REGISTER.md.

**Toy gate (GDD 13), your side:**

| Pass if | Measured by |
|---|---|
| Holding the chamber is fun for five minutes | 4 of 5 testers rate 4/5 or higher |
| Testers say what killed them (or hit the chamber) in 80%+ of cases | Ask after each death; compare with the log |
| Loud vs quiet is a real choice | Logged fire time 30–70% loud across testers; testers can explain when they switch |
| Moving between floors feels fine | No tester calls it clunky unprompted; transitions under 0.5 s (logged) |
| Input to action under 100 ms | Frame capture (phone slow-motion video of the screen is enough) |

Plus the tunables decision: keep, change or drop the 3 s memory and 1.25× hysteresis, and record it in the GDD.

**If it fails:** tune pulse sizes and radii first (GDD 5). If loud or quiet is still always right after two tuning rounds, the noise rule changes before anything else. If the side-on view feels cramped, we discuss the top-down fallback (D1).

## 6. Estimate and plan

About 15–25 h of build (GDD), most of it mine; your time is about 1–2 h to play and 1–2 h per tester session. One PR, built in this order, each step tested before the next: noise and graph port → player and weapon → enemies and chamber → night and HUD → overlay and telemetry → builds.

## 7. Carried checks from Stage C (D10)

These can run alongside the toy, and the toy builds make them easier:
- C1/C3: run the Stage C builds (or the toy builds) on your PC and phone. Still needed: **your PC's CPU, GPU and RAM, and your Android phone model.**
- Mobile vs Compatibility renderer: still provisional on Mobile until C3 runs.
- C2/D4 look-test art gate and C6 hook test with strangers: still open; not blocked by the toy.
