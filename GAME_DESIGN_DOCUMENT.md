# Game Design Document

Version 0.1 · 22 October 2026 · Status: **draft for Yash's approval** (Stage B). Everything here is a hypothesis until the prototype tests it. Numbers marked *(tune)* are starting values, not balance.

Why each choice was made: [research/STAGE_B_DESIGN_RESEARCH.md](research/STAGE_B_DESIGN_RESEARCH.md). Approved decisions: [DECISION_LOG.md](DECISION_LOG.md). The one-page vision: [GAME_VISION.md](GAME_VISION.md). Items marked ⚑ are proposals that need Yash's approval.

---

## 1. Overview

A side-on, fixed-screen horde-defence shooter. One building, shown as a cross-section. The life-support chamber holding the player's infected spouse sits on the middle floor. Runs are five nights. Days are for preparation; nights are real-time defence. Death, or the chamber falling, resets the loop. Recipes, findings and story persist.

Four systems (D2): **combat**, **preparation** (weapons and traps), **self-experimentation**, **the loop**. One rule links them: **noise** (section 5).

**Platforms (D5, D8):** Windows on Steam first; then Android and iOS together as a premium port. iOS build work is parked until the port, but every system is designed to run on phones from day one: input through actions only, UI that scales from 16:9 monitors to 20:9 phones with safe areas for notches and the Dynamic Island, touch targets of at least about 9 mm, no hover-only information, scalable fog and light presets, and saves that survive the app being suspended.

## 2. Core loop

```
Run start (night 1 of 5)
  └─ Day: spend 4 action hours ── repair · trap · weapon · experiment · read
       └─ Night: 3–5 min real-time defence ── loud or quiet? where do I pull them?
            └─ Dawn: results, samples, findings pinned to the lab wall
                 └─ next day … after night 5: cure attempt (needs key findings)
Fail (you die or the chamber falls) → loop resets to night 1, knowledge kept
```

- **Moment to moment (night):** shoot, strike, dodge, move between floors; decide whether to make noise.
- **Run (20–35 min):** spend scarce day hours; survive escalating nights; choose experiments.
- **Across loops (3–5 h to the ending):** fill the lab wall; unlock components and traps; learn her story; collect the key findings that make the cure attempt possible.

## 3. Day phase ⚑ P1

**Proposal:** the day is a budget of **4 action hours** *(tune)*, not a real-time timer. Time doesn't pass while the player thinks. Each action costs hours:

| Action | Cost | Effect |
|---|---|---|
| Repair or build a barricade | 1 h | Restores one entry's barricade to full |
| Place or move a trap | 1 h | Puts an unlocked trap in an empty socket |
| Weapon work | 1 h | Swap any components on one frame |
| Run an experiment | 2 h | Uses a sample; grants mutation + finding (section 11) |
| Read her notes | 0 h, once a day | Shows one unlocked story fragment |
| Rest | remaining hours | +10% health per hour *(tune)* |

Scrap (the one resource) is spent on barricades and traps, and is earned from kills at night. It resets with the loop (D3).

**Why:** every hour is a visible trade-off; cheaper to build and test than a timed day; works unchanged on touch.

## 4. Night phase

- **Length:** 3–5 min *(tune)*, ending at dawn. A dawn bar is always visible.
- **Escalation:** each night adds **one new pressure** from a per-run list: a new entry point opens, a new enemy type, a power flicker, a burst pipe (water on one floor). Never just more health.
- **Spawns:** authored per night in a `NightDefinition` resource: which entries open, which enemies and when.
- **Lose:** player health 0, or chamber integrity 0. Either resets the loop.
- **Night 5** of game one's later runs can be the **boss night** (power failure, section 8).

## 5. The noise rule (central mechanic)

> Each infected targets the loudest sound it can hear, weighted by distance. The chamber hums all the time.

**Spec (v0):**

- A `NoiseSource` has `loudness` (0–100) and `radius` (px). Perceived noise = `loudness × (1 − distance / radius)`, minus **one floor of falloff** (−50% *(tune)*) for each floor between source and listener.
- Each infected re-picks its target every **0.5 s** *(tune)*. Ties go to the nearer source. Once in melee range it commits for 2 s so it doesn't jitter.
- **Sources:** chamber hum (constant, loudness 40 *(tune)*); gunshots (pulse, 60–90 by component); melee hits (pulse, 20); barricade breaking (pulse, 50); lure trap (pulse, 100, 6 s); mutations may add a constant hum on the player.
- **Runners ignore noise** and always target the chamber.
- **Debug overlay** (prototype only): a line from each infected to its current target, and noise rings.

**Intended decision:** loud weapons pull the crowd off her and onto you; quiet play keeps them on their path into your traps. If testing shows one option is always right, change pulse sizes before adding anything.

## 6. The arena

- **One building, cross-section:** basement (generator), ground floor, middle floor (the chamber), upper floor, roof. Prototype: two floors and one stairwell; game one: three floors plus roof and basement, two stairwells.
- **Entries:** 8 in game one (window at each end of three floors, the front door, roof hatch, basement grate; *count to confirm in the slice*). Each night opens 3–4.
- **Barricades** at entries; **trap sockets** (about 10) at stair tops, doorways and window frames.
- **Arena states** (vertical slice): burst pipe (water on a floor), power failure (lights out, chamber silent), broken stair (one stairwell blocked for the night). Damage persists between nights within a run, and resets with the loop.
- **Pathing:** an authored waypoint graph (entries, stair ends, barricades, the chamber) searched with `AStar2D`. Enemies walk floors and use stairs only; they never jump.

## 7. Player and controls

- Move left and right; take stairs at a stairwell; free aim (most shots are along a floor); fire; melee; dodge (short, with invulnerability frames *(tune)*); reload; interact.
- **No jumping.**
- **All input goes through InputMap actions:** `move_left`, `move_right`, `stairs_up`, `stairs_down`, `aim` (mouse position or right stick), `fire`, `melee`, `dodge`, `reload`, `interact`, `pause`. Mouse and keyboard first, gamepad by the slice, touch for the Android and iOS port (aim assist toward the threat nearest the chamber). Side-on aim is mostly along one axis, which makes touch easier than in a top-down shooter.
- Health 100 *(tune)*. No stamina in v0.

## 8. Enemies

| Enemy | Speed | Health | Behaviour | Drops | In |
|---|---|---|---|---|---|
| Shambler | Slow | Low | Groups; follows noise | Scrap | Combat toy |
| Runner | Fast | Low | Ignores noise; straight to the chamber | Scrap, runner sample | Combat toy |
| Brute | Slow | High | Breaks barricades in ~3 hits; staggered by heavy melee | Scrap, marrow sample | Loop prototype |
| Wailer *(candidate)* | Medium | Medium | Stops and screams: a noise pulse that redirects nearby shamblers | Scrap | Slice decides |
| Boss night | — | — | Power fails for 60 s (chamber cold and silent, lights out), then the generator restarts at double hum | Key finding | Release |

Every enemy has a unique silhouette, a rim light and a 0.5 s tell before any attack that can hit the chamber.

## 9. Weapons and the tag system

- **Frames:** one melee tool, one firearm. **Slots:** mechanism, payload, mod.
- **Components:** each changes stats (damage, rate, spread, noise, reliability, cost) and carries **at most one tag**.
- **Tags (game one):** `loud`, `quiet`, `shock`, `fire`, `cold`.
- **World interactions (the only synergies):** shock + water chains along a wet floor; fire + barricade burns it (yours too); cold slows the infected, but drains chamber power within a radius of the chamber; loud + lure stacks; quiet lowers the pulse below the chamber's hum.
- **Prototype:** firearm only, one slot, two components: *open barrel* (`loud`, strong) vs *suppressor* (`quiet`, −30% damage *(tune)*).
- **Game one:** 10–12 components, unlocked by findings (they persist; they count as power progression and are balanced as such, D3).

## 10. Traps

Placed by day at sockets only. They share the tag system.

| Trap | Tag | Effect | In |
|---|---|---|---|
| Lure (radio) | `loud` | Noise pulse 100 for 6 s when triggered or on a timer | Loop prototype |
| Spike barricade | — | Damages anything breaking it | Slice |
| Shock wire | `shock` | Stuns; chains on water | Slice |
| Oil spill | `fire` | Ignites when shot; burns barricades too | Slice |
| Cold vent | `cold` | Slows; drains chamber power if near it | Release |

## 11. Self-experimentation

- Samples drop from runners and brutes. By day, running an experiment costs 2 hours and one sample.
- Choose from 2–3 experiments. Each shows a **known effect**; its **side effect** is revealed when taken. Both last until the loop resets.
- Every experiment yields a **finding** that persists: a fact (shown on the lab wall), a recipe (unlocks a component or trap) or a story fragment.
- About **5 findings are key**: holding all of them at the last dawn allows the cure attempt (section 14).
- Prototype: one experiment from a runner sample, with a choice of two.
- No corruption meter, no infection clock (D2).

## 12. Game one content list (D6: 600–900 h)

| Content | Count |
|---|---|
| Arenas | 1 (with 3 arena states) |
| Enemies | 3–4 plus 1 boss night |
| Weapon frames / components | 2 / 10–12 |
| Tags | 5 |
| Traps | 4–5 |
| Experiments | 6–8 (about 5 key findings) |
| Story | ~20 fragments, ~2,500 words, 1 ending |
| Nights per run | 5 (3–7 at release, D3) |
| Playtime | 20–35 min runs; ending at ~3–5 h |

Anything beyond this list is post-launch or a later game.

## 13. Prototype scope and acceptance criteria

**Combat toy (Stage D step 1, ~15–25 h):** two floors, one stairwell, the chamber with its hum, one firearm with the loud/quiet choice, melee, shambler and runner, the noise rule and its debug overlay, one night on a loop. No day phase.

| Pass if | Measured by |
|---|---|
| Holding the chamber is fun for five minutes | 4 of 5 testers rate 4/5 or higher |
| Testers say what killed them (or hit the chamber) in 80%+ of cases | Ask after each death |
| Loud vs quiet is a real choice | Logged fire time is between 30% and 70% loud across testers; testers can explain when they switch |
| Moving between floors feels fine | No tester calls it clunky unprompted; stair transitions under 0.5 s |
| Input to action under 100 ms | Frame capture |

**Loop prototype (Stage D step 2):** Stage A section 13 contents, using this document's systems: 5 nights, the day action budget, brute and barricades, the lure trap, one experiment, reset keeping one unlock, a basic lab wall. Acceptance criteria are Stage A section 13's table, plus: *at least 3 of 5 testers spend day hours differently from each other on day 2*.

## 14. The loop, persistence and saving

- **Reset when:** the player dies or the chamber falls. Back to day 1 of night 1.
- **Persists (the lab wall):** findings, unlocked components and traps, story fragments read, how many loops (shown subtly, never as a score).
- **Resets:** scrap, samples, health, mutations, barricades, traps placed, arena damage.
- **Win (⚑ P2):** survive night 5 holding all key findings → cure attempt → the ending. Survive night 5 without them → a failed attempt (one fragment) → reset.
- **Save:** one profile file with the lab-wall state, written at each dawn and on quit; a mid-run save at each day so quitting doesn't lose a run (Android and iOS can suspend or kill the app at any time). Steam Cloud if C5 passes.

## 15. Narrative frame

- **She** was the researcher. The cure work is hers; her notes and recordings guide the experiments. She chose the chamber.
- **The protagonist** is infected and follows her work. Each loop the lab wall already carries notes in the protagonist's own handwriting, with no memory of writing them. The loop's cause stays ambiguous.
- **The hum** that keeps her alive is what draws them. The fiction and the noise rule are the same thing.
- **Rules:** she is never harmed by a mechanic and never a puzzle object; the one ending resolves the relationship whether or not the cure works; ~20 fragments, no voice acting, no dialogue trees.
- Names, the ending and the fragment list are written in the vertical slice, not before.

## 16. Data model (for Stage C and D)

Custom Godot Resources, typed GDScript, one `.tres` per item. Systems communicate by signals, not global singletons (project rules).

| Resource | Key fields |
|---|---|
| `EnemyDefinition` | speed, health, damage, ignores_noise, drops, silhouette scene |
| `WeaponFrame` | slots, base stats |
| `WeaponComponent` | slot, stat modifiers, tag, noise loudness, unlock finding |
| `TrapDefinition` | tag, trigger, effect, cost |
| `ExperimentDefinition` | sample needed, known effect, side effect, finding |
| `FindingDefinition` | text, kind (fact / recipe / fragment), is_key, unlocks |
| `NightDefinition` | duration, open entries, spawn schedule, pressure (state change) |
| `RunDefinition` | list of nights |
| `Tag` | an enum, plus a world-interaction table resource |

## 17. Open questions

1. ⚑ P1 (day action budget) and ⚑ P2 (win by key findings): approve or reject.
2. Wailer as the 4th enemy, or none: decide in the vertical slice from playtests.
3. Exact entry count and floor count for game one: decide after the combat toy.
4. Working title: after the hook test (Stage C, C6).
5. Reference PC and Android phone for performance targets: needed for Stage C (C3). An iPhone joins the targets before the port.
