# Game Design Document

Version 0.2 · 22 October 2026 · Status: **v0.2 draft.** The outdoor, on-the-road direction is Yash's decision (D11). Items marked ⚑ are my proposals that fill gaps in that direction, and they wait for Yash's approval. Everything is a hypothesis until the prototype tests it. Numbers marked *(tune)* are starting values, not balance.

v0.1 (approved D9) described the inside of one building in cross-section. D11 replaces that. Sections 3, 9, 11 and 15 carry over almost unchanged. Why each original choice was made: [research/STAGE_B_DESIGN_RESEARCH.md](research/STAGE_B_DESIGN_RESEARCH.md). Approved decisions: [DECISION_LOG.md](DECISION_LOG.md).

---

## 1. Overview

A side-view, fixed-screen horde-defence shooter set **outside** a small shelter: a cabin in the woods, a shack at a town's edge. The player's infected spouse lies inside it in a life-support pod. You never go inside, and the camera never shows the interior. The infected come from **the left and the right**. The player runs, jumps and climbs on the shelter and on the walls, fences and ladders they build. They also shoot, strike and lay traps.

**The journey (D11):** the two of you are on the move. Each stop is one day and one night. By day you build, research and gather. By night you hold the shelter. At dawn you pack the pod and move on. Each stop has its own backdrop (woods, farm, town edge) and its own shelter. Death, or the shelter falling, resets the loop back to the first stop. Recipes, findings and story persist.

Four systems (D2): **combat**, **preparation** (building, weapons and traps), **self-experimentation**, **the loop**. One rule links them: **noise** (section 5).

**Platforms (D5, D8):** Windows on Steam first, then Android and iOS together as a premium port. Every system is designed to run on phones: input through actions only, UI that scales from 16:9 to 20:9 with safe areas, touch targets of at least about 9 mm, no hover-only information, quality presets, and saves that survive the app being suspended.

## 2. Core loop

```
Run start (stop 1 of 5)
  └─ Arrive by day: spend 4 action hours ── build · trap · weapon · experiment · scavenge · read
       └─ Night: 3–5 min real-time defence ── loud or quiet? which side? up on the wall or down?
            └─ Dawn: results, samples, findings; pack up and travel to the next stop
                 └─ … after stop 5: reach her lab, the cure attempt (needs key findings)
Fail (you die or the shelter falls) → loop resets to stop 1, knowledge kept
```

- **Moment to moment (night):** shoot, strike, jump, climb; hold a side; decide whether to make noise.
- **Run (25–40 min):** each stop starts with an empty field, so you build from scratch with what you carry.
- **Across loops (3–5 h to the ending):** fill the notebook; unlock components, structures and traps; learn her story.

## 3. Day phase (P1, approved D9; scavenge added ⚑)

The day is a budget of **4 action hours** *(tune)*, not a real-time timer, played in the same outdoor scene in daylight. Each action costs hours:

| Action | Cost | Effect |
|---|---|---|
| Build a structure | 1 h | Place a fence, wall, high wall or ladder at a build spot (section 6) |
| Place a trap | 1 h | Put an unlocked trap on a build spot |
| Weapon work | 1 h | Swap components on one frame |
| Run an experiment | 2 h | Uses a sample; grants mutation + finding (section 11) |
| Scavenge ⚑ | 1 h | Gain scrap from the stop's search spot (each stop has a different yield) |
| Read her notes | 0 h, once a day | One unlocked story fragment |
| Rest | remaining hours | +10% health per hour *(tune)* |

Scrap (the one resource) pays for structures and traps. You earn it from kills and scavenging, it travels with you, and it resets with the loop (D3).

⚑ **Scavenge is an action, not a walk-around phase.** A real-time scavenging map would be a second game to build; this keeps "gather resources" (D11) inside the action budget.

## 4. Night phase

- **Length:** 3–5 min *(tune)*, ending at dawn. A dawn bar is always visible.
- **Both sides are always open.** Each stop authors how the waves split between left and right, and adds **one new pressure**: a new enemy type, heavier waves from one side, fog that shortens sight, rain that soaks the ground (water for shock). Never just more health.
- **Spawns:** authored per stop in a `NightDefinition` resource.
- **Lose:** player health 0, or shelter integrity 0. Either resets the loop.

## 5. The noise rule (central mechanic)

> Each infected heads for the loudest sound it can hear, weighted by distance. The pod hums all the time.

**Spec (v0.2):** the field is a line, so distance is horizontal.

- A `NoiseSource` has `loudness` (0–100) and `radius` (px). Perceived noise = `loudness × (1 − |dx| / radius)`.
- Each infected re-picks its target every **0.5 s** *(tune)*. Ties go to the nearer source. Once in melee range it commits for 2 s.
- **Memory** 3 s and **hysteresis** 1.25× *(tune, from Stage C C4; whether they stay is decided at the combat toy gate, D10).*
- **Sources:** the pod's hum from the shelter (constant, loudness 40); gunshots (60–90 by component); melee hits (20); a structure breaking (50); lure trap (100, 6 s).
- **Runners ignore noise** and always go for the shelter.
- **Debug overlay** (prototype only): a line from each infected to its target, and noise rings.

**Intended decision:** loud shots on the far side of a wall pull the crowd onto the wall and off the shelter; loud shots from the shelter's roof call them straight to her. Quiet play leaves them walking into your traps.

## 6. The field and building

- **One screen:** the shelter in the middle, open ground to the left and right, and a backdrop of layered woods or buildings. The infected enter at the screen edges.
- **Build spots ⚑:** about 3 on each side *(tune)*, at fixed distances from the shelter. Each takes one structure or one trap.
- **Structures (D11):**

| Structure | Height | Player | Shamblers | Runners | Cost *(tune)* |
|---|---|---|---|---|---|
| Fence | Low | Jumps over or stands on it | Stop and break it | Vault over it ⚑ | 1 scrap |
| Wall | Medium | Jumps up onto it | Stop and break it | Stop and break it | 2 scrap |
| High wall | Tall | Needs a ladder | Stop and break it (more health) | Stop and break it | 3 scrap |
| Ladder | — | Climbs to a high wall or the shelter roof | Can't climb ⚑ | Can't climb ⚑ | 1 scrap |

- The **shelter roof** is reachable by a ladder or a jump from a wall next to it.
- ⚑ **The infected never jump or climb.** They walk, break what blocks them, and attack what they reach. Height belongs to the player. That keeps their pathing simple, and every structure is something they have to break through.
- ⚑ **A structure falls when its health hits 0.** If you're on it, you drop to the ground.
- Structures are left behind at dawn. Every stop starts from an empty field (this replaces "which barricade do I repair").

## 7. Player and controls

- Move left and right; **jump** (D11); climb ladders; free aim (mouse or right stick); fire; melee; reload; interact.
- ⚑ **No dodge in v0.2.** Jumping is the evasive move; one fewer verb to tune and to fit on a touch screen.
- **InputMap actions:** `move_left`, `move_right`, `jump`, `climb_up`, `climb_down`, `aim`, `fire`, `melee`, `reload`, `interact`, `pause`. `stairs_up`/`stairs_down` are renamed `climb_up`/`climb_down`.
- Mouse and keyboard first, gamepad by the slice, touch for the port. Touch needs move, jump, aim and fire at once: the main input risk (section 17).
- Health 100 *(tune)*.

## 8. Enemies

| Enemy | Speed | Health | Behaviour | Drops | In |
|---|---|---|---|---|---|
| Shambler | Slow | Low | Groups; follows noise; breaks what blocks it | Scrap | Combat toy |
| Runner | Fast | Low | Ignores noise; straight to the shelter; vaults fences ⚑ | Scrap, runner sample | Combat toy |
| Brute | Slow | High | Breaks structures in ~2 hits; staggered by heavy melee | Scrap, marrow sample | Loop prototype |
| Wailer *(candidate)* | Medium | Medium | Stops and screams: a noise pulse that redirects nearby shamblers | Scrap | Slice decides |
| Last stop *(candidate)* | — | — | An authored final night at her lab | Key finding | Release |

Every enemy has a unique silhouette, a rim light and a 0.5 s tell before any attack on the shelter.

## 9. Weapons and the tag system

- **Frames:** one melee tool, one firearm. **Slots:** mechanism, payload, mod.
- **Components:** each changes stats (damage, rate, spread, noise, reliability) and carries **at most one tag**.
- **Tags (game one):** `loud`, `quiet`, `shock`, `fire`, `cold`.
- **World interactions:** shock + rain-soaked ground chains; fire + a structure burns it (yours too); cold slows the infected but drains the pod within a radius of the shelter; loud + lure stacks; quiet sits below the pod's hum.
- **Prototype:** firearm only, one slot, two components: *open barrel* (`loud`, strong) vs *suppressor* (`quiet`, −30% damage *(tune)*).
- **Game one:** 10–12 components, unlocked by findings.

## 10. Traps

Placed by day on build spots. They share the tag system.

| Trap | Tag | Effect | In |
|---|---|---|---|
| Lure (radio) | `loud` | Noise pulse 100 for 6 s when triggered or on a timer | Loop prototype |
| Spike fence | — | Damages anything breaking it | Slice |
| Shock wire | `shock` | Stuns; chains on wet ground | Slice |
| Oil spill | `fire` | Ignites when shot; burns structures too | Slice |
| Cold vent | `cold` | Slows; drains the pod if near the shelter | Release |

## 11. Self-experimentation (unchanged)

- Samples drop from runners and brutes. By day, an experiment costs 2 hours and one sample.
- Choose from 2–3 experiments. Each shows a **known effect**; its **side effect** is revealed when taken. Both last until the loop resets.
- Every experiment yields a **finding** that persists: a fact, a recipe (unlocks a component, structure or trap) or a story fragment.
- About **5 findings are key**: holding them all at the last stop allows the cure attempt.
- No corruption meter, no infection clock (D2).

## 12. Game one content list (D6: 600–900 h)

| Content | Count |
|---|---|
| Stops per run | 5 (3–7 at release, D3), on a fixed route ⚑ |
| Backdrop sets ⚑ | 3 (woods, farmland, town edge), each a reusable layered kit; 5 stops mix them |
| Shelters ⚑ | 1 rig with 3–5 dressings (cabin, shed, shack, bus, chapel) |
| Structures | 4 (fence, wall, high wall, ladder) |
| Enemies | 3–4 plus an authored last stop |
| Weapon frames / components | 2 / 10–12 |
| Tags | 5 |
| Traps | 4–5 |
| Experiments | 6–8 (about 5 key findings) |
| Story | ~20 fragments, ~2,500 words, 1 ending |
| Playtime | 25–40 min runs; ending at ~3–5 h |

## 13. Prototype scope and acceptance criteria

**Combat toy (Stage D step 1):** one stop (woods, at night), the shelter with the hum, flat ground on both sides, a fixed layout of structures (a fence and a wall on one side, a high wall with a ladder on the other), the shelter roof, one firearm with the loud/quiet choice, melee, jump and climb, shambler and runner, the noise rule and its debug overlay, one night on repeat. No day phase, no building. Full spec: [research/STAGE_D_COMBAT_TOY_SPEC.md](research/STAGE_D_COMBAT_TOY_SPEC.md).

| Pass if | Measured by |
|---|---|
| Holding the shelter is fun for five minutes | 4 of 5 testers rate 4/5 or higher |
| Testers say what killed them (or hit the shelter) in 80%+ of cases | Ask after each death |
| Loud vs quiet is a real choice | Logged fire time between 30% and 70% loud across testers; testers can explain when they switch |
| Height is a choice, not a safe spot | Testers spend 20–70% of the night off the ground; nobody wins by standing in one place |
| Jumping and climbing feel good | No tester calls it clunky or floaty unprompted |
| Input to action under 100 ms | Frame capture |

**Loop prototype (Stage D step 2):** 5 stops on the route with two backdrop kits, the day action budget with building, the brute, the lure trap, one experiment, reset keeping one unlock, a basic notebook. Acceptance criteria are Stage A section 13's table, plus *at least 3 of 5 testers build differently from each other at stop 2*.

## 14. The loop, persistence and saving

- **Reset when:** the player dies or the shelter falls. Back to the morning of stop 1.
- **Persists (her notebook ⚑, which replaces the lab wall since there is no lab to come back to):** findings, unlocked components, structures and traps, story fragments read, the loop count (shown subtly).
- **Resets:** scrap, samples, health, mutations, structures, traps.
- **Win (P2, approved D9):** survive the last stop holding all key findings → cure attempt → the ending. Without them → a failed attempt (one fragment) → reset.
- **Save:** one profile with the notebook state, written at each dawn and on quit; a mid-run save at each stop's morning.

## 15. Narrative frame

- **She** was the researcher. The cure work is hers, and so is the route: ⚑ her notes lead to the lab where she can be cured. That's why you keep moving.
- **The pod** keeps her alive, and its hum calls the dead. ⚑ The hum is also why you can't stay: each night in one place draws more of them.
- She is never shown inside (D11). ⚑ Her presence is the pod's light through the shelter's window and cracks: the brightest thing on screen, and it dims as the shelter takes damage.
- **The protagonist** is infected and follows her work. Each loop the notebook already holds entries in the protagonist's own handwriting, with no memory of writing them. The loop's cause stays ambiguous.
- **Rules:** she is never harmed by a mechanic and never a puzzle object; one ending; ~20 fragments; no voice acting or dialogue trees.

## 16. Data model

Custom Godot Resources, typed GDScript, one `.tres` per item. Systems talk by signals, not global singletons.

| Resource | Key fields |
|---|---|
| `EnemyDefinition` | speed, health, damage, ignores_noise, vaults_fences, drops, silhouette scene |
| `StructureDefinition` | height, health, cost, climbable, blocks (shamblers / runners) |
| `WeaponFrame` / `WeaponComponent` | slots, stats, tag, noise loudness, unlock finding |
| `TrapDefinition` | tag, trigger, effect, cost |
| `ExperimentDefinition` | sample needed, known effect, side effect, finding |
| `FindingDefinition` | text, kind, is_key, unlocks |
| `StopDefinition` | backdrop kit, shelter dressing, build spots, scavenge yield, night |
| `NightDefinition` | duration, spawn schedule per side, pressure |
| `RouteDefinition` | list of stops |

## 17. Open questions

1. ⚑ proposals in this version (scavenge as an action, infected never climb, runners vault fences, no dodge, fixed route, the pod's light through the window): Yash approves or changes them.
2. Touch controls for move + jump + aim + fire together: test on a phone during the loop prototype.
3. Wailer as the 4th enemy: the slice decides.
4. Working title: after a new hook test (the Stage C clip and capsule show the old interior).
5. Reference PC and Android phone specs: still needed.
