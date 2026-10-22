# Backlog

Every feature with its cost and class. Seeded from the cost cards in research/STAGE_B_DESIGN_RESEARCH.md section 9 (Stage B PR #2); that table is the source until it changes, and this file follows it. Hours are estimates for a first-time game developer, art and audio excluded unless stated. Status: **skeleton** (22 October 2026).

**Classes:** Prototype · Loop prototype · Vertical slice · Release · Post-launch · Rejected. A feature joins only if it creates a new decision for the player.

## Tooling (this PR)

| Item | State |
|---|---|
| Godot 4.7.2 project, typed GDScript, folder layout | Done |
| GUT tests, script compile check, CI | Done |
| Windows, Android, iOS export presets | Done (iOS builds parked, D8) |
| Release signing for Android (upload key in CI secrets) | Port |
| GodotSteam integration | After C5 |

## Prototype

| Feature | Impl. | Testing | Content | Impact |
|---|---|---|---|---|
| Noise targeting rule | 6–10 h | Low–medium | None | Central |
| Waypoint-graph pathing (floors + stairs) | 4–6 h | Medium | 1 graph per arena | Required |
| Player move, aim, dodge, 2 weapons | 15–25 h | Medium (feel) | 2 weapons | Required |
| Chamber with health and hum | 3–5 h | Low | 1 object | Central |
| Shambler, runner | 8–12 h | Medium | 2 enemies | High |

## Loop prototype

| Feature | Impl. | Testing | Content | Impact |
|---|---|---|---|---|
| Brute + barricades | 8–12 h | Medium | 1 enemy, barricades | High |
| Day action budget (D9 P1) | 6–10 h | Low | Action list | High |
| 1 trap (lure) at sockets | 5–8 h | Medium | 1 trap | High |
| 1 weapon slot, 2 options (loud/quiet) | 8–12 h | Medium | 2 components | High |
| 1 experiment with finding | 6–10 h | Low | 1 experiment | Medium–high |
| Reset keeping one unlock; lab wall (basic) | 8–12 h | Medium (save/reset) | — | High |

## Vertical slice → release

| Feature | Impl. | Testing | Content | Class |
|---|---|---|---|---|
| Full tag system, 10–12 components | 40–70 h | Medium–high | 10–12 components | Slice → release |
| 4–5 traps | 15–25 h | Medium | 4–5 traps | Slice (3) → release |
| 6–8 experiments | 20–30 h | Medium | 6–8 experiments | Slice (3) → release |
| Arena state changes (burst pipe, power failure, broken stairs) | 15–25 h | Medium–high | 3 states | Slice |
| Win by findings (D9 P2) + one ending | 10–15 h + writing | Medium | ~5 key findings | Slice |
| ~20 story fragments | 30–50 h writing | Low | ~2,500 words | Slice (5) → release |
| Wailer (4th enemy) | 6–10 h | Medium | 1 enemy | Slice decides |
| Boss night (power failure) | 10–15 h | Medium | 1 set piece | Release |
| Gamepad + Steam Deck | 6–10 h | Medium | Prompts | Slice |
| Settings, quality presets, save system | in "UI, save and settings" 40–60 h | Medium | — | Slice |

## Post-launch

| Feature | Impl. | Notes |
|---|---|---|
| Touch controls (aim assist toward chamber threats) | 30–50 h | Mobile port |
| Android + iOS port (D8) | 200–350 h | Outside the game-one budget |
| Second arena | 80–150 h | |

## Rejected

Infection clock (unless runs lack pressure) · scavenging trips outside the house · free trap placement · jumping and platforming · voiced dialogue and dialogue trees. Reasons in the Stage B research, section 9.
