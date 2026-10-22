# Stage D, step 1: combat toy spec

Version 0.3 · 22 October 2026 · Status: **approved by Yash, 22 October 2026** (D12), with his changes folded in: a build step with limited scrap, and the infected piling up to climb structures. v0.1 (inside a two-floor house) was withdrawn after Yash's direction change (D11).

Source of truth: GAME_DESIGN_DOCUMENT.md v0.2, sections 5–8 and 13. Items marked ⚑ are my proposals from the GDD. Numbers marked *(tune)* are starting values the toy exists to tune.

## 1. What the new direction costs and risks (candid)

**What gets simpler.** Enemies walking a line is much easier than floors and stairs: no waypoint graph, no stair logic, no stuck agents. Two attack sides read instantly and work well on a phone screen. The structure (prepare by day, hold both sides at night, move on) is proven: Kingdom Two Crowns and Dome Keeper are built on it, and both are already in our comparables.

**What gets harder or riskier.**

1. **It's close to Kingdom Two Crowns.** Side view, a base in the middle, attacks from both sides, walls built by day, and moving on to the next place. Players and press will make the comparison. What sets us apart has to be the noise rule, the spouse and the loop, and the hook test (C6) has to be redone outdoors to check that people see the difference. This is the biggest new risk.
2. **The hook loses its image if she's never seen.** The Stage C look test and the hook clip were built around the glowing chamber as the brightest thing on screen. With her hidden, the screen shows a cabin, and a cabin alone isn't a hook. ⚑ My fix: you never see her, but the pod's light glows through the cabin's window and cracks. It's the brightest thing on screen, and it dims as the cabin takes damage. Without something like that, the emotional premise lives only in text.
3. **Height can become a safe spot.** If the player can stand on a wall or the roof and nothing can reach them, the night is solved. Yash's rule (D12) closes this: the infected pile up and climb, and the shelter is on their path, so hiding up high loses her. The gate checks for this ("height is a choice, not a safe spot").
4. **Art for each location.** Every stop needs a backdrop and a shelter. Open-ended, that blows the art budget. ⚑ The cap is 3 reusable backdrop kits (woods, farmland, town edge) and one shelter rig with 3–5 dressings. Silhouette woods are among the cheapest backdrops to make in our style; town buildings cost more. Estimate: about +40–80 h of art over v0.1's one building, partly offset by dropping the interior.
5. **Travel and the loop.** ⚑ Each stop is one day and one night, five stops make a run, and the route is fixed and ends at her lab, so the loop resets you to stop 1. That fits D3 (3–7 nights) and P2 (win by findings) unchanged. One real loss: structures don't carry from night to night, so "which barricade do I repair" is gone. In its place, you plan a fresh field at every stop.
6. **New verbs.** Jumping, ladders and building are new work (estimate +15–25 h over v0.1). Touch controls must fit move, jump, aim and fire at once, which is harder than v0.1's no-jump design. I cut dodge to make room ⚑.
7. **Wasted work.** The waypoint graph and floor work from C4 isn't needed now. The noise logic, memory and hysteresis carry over. The C2 look test and C6 hook clip show the interior, so both need redoing outdoors (about 8–12 h) before the D4 art gate means anything.

**Net scope:** roughly neutral within D6's 600–900 h *if* the art caps in point 4 hold. The combat toy itself stays about 15–25 h.

## 2. Purpose

Answer before anything else is built: **is holding a shelter from both sides fun for five minutes, with loud vs quiet and ground vs height as the main choices?** It also settles the noise rule's 3 s memory and 1.25× hysteresis (D10).

**Not in the toy:** the day action budget, scrap from kills, travel, backdrops beyond one, brute, traps, experiments, saves, story, Steam, touch controls, final art.

## 3. Behaviour

### The field (one stop: woods at night)
- One fixed screen. The cabin is in the centre, with flat ground on both sides. The infected enter at the left and right edges.
- **Build step (D12):** before each night, in daylight, you have **8 scrap** *(tune)* and **3 build spots on each side**. Walk to a spot and press `interact` to cycle it: empty → fence (1) → wall (2) → high wall (3) → high wall with ladder (4) → empty, with refunds. Press `start_night` (Enter, or Start on a gamepad) when ready. A free ladder always reaches the cabin roof. After a loss, the build step starts again with your last layout already placed.
- The world is about 15% wider than 16:9, so 20:9 phones see more woods, not empty space.
- The cabin glows from inside ⚑ (section 1, point 2): the brightest thing on screen, dimming with integrity.

### Player
- Move 220 px/s; jump to wall height; climb ladders with `climb_up`/`climb_down`; stand on the fence, wall, high wall and roof *(tune)*. Coyote time and a jump buffer of about 0.1 s each, so jumps feel fair.
- Health 100, no regeneration. Falling does no damage.
- **Aim:** mouse, or the right stick (`aim`). Stick at rest keeps the last direction.
- **Melee:** short arc in front, 1 damage, knockback, 0.4 s cooldown, noise 20.

### The firearm
- Hitscan along the aim line; hits the first enemy; the ground stops shots. Structures don't block your own shots (you shoot over and through your defences) *(new)*.
- 8-round magazine, 1.2 s reload, infinite reserve *(tune)*.
- **Open barrel** (`loud`): 2 damage, loudness 80, radius 1200 px.
- **Suppressor** (`quiet`): 1.4 damage (−30%), loudness 30, radius 600 px, so it's below the hum (40).
- **Swap** with `interact`: takes 1.5 s, no firing meanwhile. It's toy only, so we can measure the choice. Swapping cancels a reload and starts with a full magazine.

### Noise rule (GDD 5)
- Perceived = `loudness × (1 − |dx| / radius)`. Height doesn't change it.
- Shamblers re-pick every 0.5 s, ties to the nearer source, with 3 s memory and 1.25× hysteresis *(tune)*.
- The hum (40) comes from the cabin and is everyone's fallback. Runners ignore noise.

### Enemies
| | Shambler | Runner |
|---|---|---|
| Speed *(tune)* | 60 px/s | 200 px/s |
| Health *(tune)* | 3 | 2 |
| Goes to | The sound it hears (for shots, the player's position) | Always the cabin |
| Blocked by | Fence, wall, high wall: hits it and piles up | Wall and high wall (piles up too); **vaults the fence** |
| Attacks | Player 10 (when in reach at ground level), structure 5, cabin 6, every 1.5 s | Structure 5, cabin 8, every 1.2 s; never the player |
| Tell | 0.5 s pose and sound before each hit on the cabin | same |

- If the target is beyond a structure, an enemy walks to it, hits it and **joins a pile** against it. Each enemy in the pile stands on the ones below (28 px a body *(tune)*). The bottom two keep hitting the structure.
- **Climbing (D12):** once the pile is as tall as the structure, the next arrivals climb onto its top, walk across and drop down the far side. A player standing on top can be hit by the top of the pile or by climbers.
- Killing an enemy in a pile drops the ones above it. A structure that falls scatters its pile.
- At the cabin, enemies after the hum hit it and pile against it. If the player is on the roof and making noise, the pile climbs onto the roof.
- The infected never jump and never use ladders.
- **Crowd spacing** (from C4): staggered stop distances and a soft push between neighbours, so crowds bunch up at a wall instead of stacking into one sprite.
- On-screen cap 40 *(tune)*; extra spawns wait off-screen. Edge markers show where the next group enters.

### Structures
- Health *(tune)*: fence 15, wall 30, high wall 50, ladder (not attackable; it falls with what it leans on). Cracks show at 50% and 25%.
- When a structure falls, anyone on it drops to the ground and it's gone for the night.

### The night
- One `NightDefinition`: **4 minutes** *(tune)*, a spawn schedule per side. Shamblers in groups of 3–6 from the start, the first runner at about 0:45, both sides at once after 2:00.
- HUD: dawn bar, health, cabin integrity, ammo, the current barrel. Laid out inside the safe area.
- **Win:** dawn. **Lose:** health 0 or cabin integrity 0 (100 at start).
- **End card:** "Dawn", "You died" or "The shelter fell", then `fire` restarts. It doesn't say what killed you; the gate asks testers.
- `pause`, losing focus or the app being suspended all pause the night.

### Debug overlay (`debug_overlay`, F3)
Target lines, noise rings, structure health numbers, fps and sim time.

### Telemetry (needed by the gate)
One CSV row per night in `user://toy_log.csv`: result, cause of loss, duration, seconds firing each barrel, shots per barrel, swaps, **seconds off the ground and where**, structures lost, cabin hits by enemy type, kills by type, layout used. Nothing leaves the device.

### Art and audio
Greybox shapes plus the Stage C silhouettes (project-owned) and rim-light shader, ported in. A simple layered woods backdrop drawn by script. Sounds: **CC0 only** (Kenney or CC0 Freesound), each logged in ASSET_REGISTER.md before it's committed; if I can't download them here, I'll generate tones in code and say so.

## 4. Edge cases

1. Two equal sources → the nearer wins.
2. Firing loud from the cabin roof → the shot and the hum pull the same way; shamblers converge on the cabin (intended: it should feel dangerous).
3. Firing loud from beyond the left wall → shamblers on the left go for the wall and break it; the right side keeps coming for the hum.
4. A pulse ends while a shambler walks to it → it carries on for 3 s, then re-picks.
5. A quiet shot next to a shambler heading for the hum → doesn't steal it.
6. A structure falls while the player stands on it → the player drops; if shamblers are below, they can hit next frame.
6a. Player on a high wall, pile reaches the top → the top of the pile can hit them; climbers walk over and drop behind the wall.
6b. The bottom of a pile is shot → everyone above drops one body height; nobody is left floating.
6c. A piled enemy's target moves to its own side → it leaves; the ones above drop.
6d. Player hides on the roof without making noise → the hum keeps the horde on the cabin, and the cabin falls (Yash: that's the loss).
7. The ladder's wall falls → the ladder falls with it; a player on it drops.
8. A runner meets the fence → it vaults it without slowing much; it stops at a wall.
9. Death and dawn in the same frame → the loss counts. Death and shelter fall together → reported as the shelter falling.
10. Spawn when the cap is full → it waits off-screen; it's never dropped.
11. Player jumps onto a shambler → no standing on enemies; the player slides off.
12. Swap during reload → cancels the reload; the new barrel is full.
13. Stick at rest → keeps the last aim.
14. Restart → everything resets; the night's log row is already written.
15. Focus lost or the app suspended → paused.

## 5. Tests

**Automated (GUT, in CI on every push):**
- Noise: formula, radius cut-off, tie-break, threshold, memory decay, hysteresis, runners ignore noise (cases 1–5).
- Movement rules: a shambler stops at the first blocking structure toward its target; a runner vaults fences and stops at walls; nobody passes a standing structure until the pile is tall enough to climb.
- Piles: heights stack, the pile climbs once tall enough, killing a lower member drops the rest, a falling structure scatters the pile, a pile reaches a player on top (6a–6d).
- Build step: costs, refunds, the scrap limit, and the layout carried into the next attempt.
- Structures: health, damage, falling, and a ladder falling with its wall; the player drops when the structure under them goes (6, 7).
- Weapon: stats from `.tres`, damage, magazine, reload, swap timing and cancel (12), loudness values.
- Combat: damage to player, structures and cabin; the 0.5 s tell before any cabin hit; win/loss and their precedence (9).
- Night: spawn schedule from `NightDefinition`, per side, with the cap queue (10).
- Crowd spacing: 20 shamblers at a wall settle with a minimum gap.
- Resources aren't mutated at runtime.
- Telemetry: a scripted night writes the right loud/quiet split and off-ground time.
- **Headless soak:** a scripted player plays 10 simulated nights on 3 layouts: no errors, nobody passes a standing structure without climbing a pile, nobody floats, sim time p99 under 2 ms.
- The toy scene loads with its required nodes.

**Manual (Yash):** jump and climb feel, readability, whether crowd turns read as "I pulled them", and the gate below.

I'll say exactly what ran where. Cloud runs are headless only; nothing counts as "played" until you play it.

## 6. Acceptance criteria

**Build done (my side):** all tests pass in CI and the script check is clean; the Windows build and Android debug APK export and go into project files; every asset is logged.

**Toy gate (GDD 13, your side):**

| Pass if | Measured by |
|---|---|
| Holding the shelter is fun for five minutes | 4 of 5 testers rate 4/5 or higher |
| Testers say what killed them or hit the shelter in 80%+ of cases | Ask after each death; compare with the log |
| Loud vs quiet is a real choice | 30–70% of fire time loud across testers; testers can explain when they switch |
| Height is a choice, not a safe spot | 20–70% of the night off the ground; no one wins by standing still |
| Jumping and climbing feel good | No tester calls it clunky or floaty unprompted |
| Input to action under 100 ms | Phone slow-motion video of the screen |

Plus a decision on the noise memory and hysteresis, recorded in the GDD.

**If it fails:** tune pulse sizes, radii and structure health first. If one choice is still always right after two tuning rounds, the noise rule changes before anything else is built.

## 7. Plan

One PR, built in this order and tested at each step: noise port → player movement, jump and ladders → structures and the build step → weapon → enemies, piles and the cabin → night and HUD → overlay and telemetry → builds. Estimate 15–25 h.

## 8. Carried checks (D10, updated for D11)

- C1/C3 hardware runs: still need **your PC's CPU, GPU and RAM, and your Android phone model.** The toy builds can stand in for the Stage C builds.
- Mobile vs Compatibility renderer: still provisional on Mobile.
- C2 look test (D4 art gate) and C6 hook test: **redo outdoors** with the cabin and the woods. The old ones show the interior.
