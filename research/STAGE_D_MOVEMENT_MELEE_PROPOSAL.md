# Movement and melee with a Hollow Knight feel: proposal

Version 0.2 · 24 October 2026 · Status: **approved by Yash, 24 October 2026** (D14), and built into the toy the same day (section 6 has the built values).

Numbered D14 because D13 is the Himalayan hill road setting (PR #6).

Yash (24 Oct 2026): "the movement mechanics are gonna be like hollow knight, how it jumps and melee attacks. The ranged attacks will also be there in our case."

This overrides the project rule against adopting Hollow Knight's combat. What we take is the **feel** (how responsive the controls are and how hits land), never its moves, numbers, weapon, healing system, UI, sounds or animations. Every value below is our own starting point to tune.

## 1. Candid read

**Why it's a good call.** The current toy movement is functional but flat: a fixed-height jump and a melee that is a single invisible box. Tight, responsive movement is what makes a 2D action game feel good in the first 30 seconds, and the climbing piles from D12 give a precise jump and a downward strike a real job (section 3).

**What it costs.**
- **Build:** about 15–25 h on top of the toy. Roughly 4–6 h for the jump feel, 6–10 h for directional melee with hit-stop, recoil and bounce, and 5–9 h of tuning. Most of that is feel, so it isn't fast just because the code is written quickly.
- **Testing:** the rules can be unit-tested (jump heights, hit boxes, bounce, noise), but the feel can't. It needs your hands on it, probably 3–4 tuning rounds of 15 minutes each. That is the real cost.
- **Art (later, not in the toy):** about 12 player animations instead of about 5 (section 5). Art direction should know now.
- **Phones:** precise jumping plus directional slashes plus aiming is the hardest control scheme to fit on a touch screen. This raises the existing touch risk from medium to high. It doesn't block Steam, but it makes the mobile port more expensive.

**What it does to the design.**
- **Melee is quiet** (noise 20, below the hum), so good melee makes quiet play stronger. If melee is too good, the loud/quiet choice collapses into "always melee". To guard against this: melee only reaches what's next to you, enemies hit back, and the gate checks that neither melee nor the gun takes more than about 80% of kills.
- **It gives piles a counter.** A downward strike on the top body of a pile knocks it off and bounces you up. "Break the pile from above, or shoot its base from range" becomes a real decision, and it ties straight into D12's climbing.
- **Height gets more interesting.** A variable jump lets you hop onto fences and walls and back out quickly, which supports the "height is a choice, not a safe spot" gate.

**The risk of looking derivative: high, and it's the biggest one.** We would now share three things with Hollow Knight: its art feel (D4), its movement and melee feel, and its side view. On top of that, we're structurally close to Kingdom Two Crowns (D11). A store page could read as "Hollow Knight meets Kingdom, with guns". To keep it ours:
- **Our weapon is a tool, not a sword:** a hatchet or a crowbar, with a heavier, shorter swing.
- **No soul meter, no healing from hits, no masks for health,** and no copied sounds or poses.
- **Lead every trailer and capsule with what's ours:** the gun and the noise pull, the cabin, piles climbing walls, and her light in the window.
- **Redo the hook test with strangers** (C6, still open) on the new look before spending more on art.

## 2. Proposed toy changes (spec v0.4)

**Jump.**
- **Variable height:** release early for a short hop, hold for the full jump. Starting values: about 60 px minimum, 140 px maximum *(tune)*.
- **Snappy arc:** a fast rise, a brief easing at the top, and a heavier fall (gravity about 1.6× on the way down) *(tune)*. Terminal fall speed is capped.
- **Instant air control:** no momentum. Left and right respond the same in the air as on the ground.
- Coyote time and the jump buffer stay as they are (already built).

**Melee.**
- A fast swing in **three directions:** forward, up, and down while airborne. Starting values: about 0.08 s active and about 0.35 s between swings *(tune)*. Holding up or down picks the direction.
- **Hit-stop:** a few frames of freeze on a hit, so hits land.
- **Recoil:** a hit pushes you back a little and knocks the enemy back. Knockback never pushes an enemy through a structure (already handled).
- **Downward bounce:** a down-strike that hits an enemy, or the top of a pile, bounces you up and knocks that body off the pile.
- **Damage and noise:** damage 1 (shamblers have 3 hp), noise 20, unchanged.

**The gun stays.** You can fire on the ground and in the air, with the same loud/quiet barrels and the same aim.

**Not added: a dash.** Dodge was cut for the jump in D11. Let's see whether the new jump is enough before adding another verb.

**Telemetry additions:** kills by melee vs gun, bounces, and pile bodies knocked off.

**A new gate line:** melee and the gun both matter, with neither above about 80% of kills across testers, and testers describe the jump as responsive.

**Tests to add:** short vs full jump heights, fall faster than rise, instant air turn, slash hit box per direction, hit-stop timing, recoil, down-bounce on an enemy and on a pile top (the body is removed and the pile settles), and knockback never crossing a structure.

## 3. What happens to the current toy

The current build stays playable for your first playtest. These changes go on the same branch (PR #5) after you OK this, and your playtest notes and toy_log.csv will still count for the noise and building questions.

## 4. Animations Art will need (for the slice, not the toy)

The toy uses greybox: the current silhouette, plus drawn slash arcs and a squash on landing. For final art, the player rig (Skeleton2D cutout, D4) needs about 12 animations: idle, run, jump rise, jump apex, fall, land, ladder climb, slash forward (two alternating), slash up, slash down, hit recoil, death, and an aim and fire overlay for the arms.

## 6. Built values (24 October 2026)

All in `src/toy/sim/toy_player.gd` and `src/toy/sim/field_sim.gd`, our own first-pass numbers to tune by hand:
- **Jump:** rise gravity 3100, take-off 930 (full jump about 140 px in about 0.3 s). Letting go while rising caps the climb speed at 600, so a tap is about 58 px. The cut only works in the first tenth of a second or so, which keeps the jump readable. Near the top of a held jump, gravity halves for a moment. Falling gravity is 1.6×, and fall speed is capped at 1100. Air control is instant (no momentum), as before.
- **Melee:** 0.08 s active, 0.35 s between swings. Forward reaches 70 px; up and down reach 70 px above the head or below the feet and 44 px to each side. Holding up picks up; holding down picks down, but only in the air (on the ground, down + melee swings forward, and down alone still drops through a top). A swing hits each body once.
- **Hit-stop:** 0.05 s (3 frames at 60 fps) on the first hit of a swing. The whole field holds still; a jump pressed during it still counts.
- **Recoil and knockback:** a forward hit shoves the player back about 24 px and knocks the body back 40 px, never through a structure. Knocking a body off the edge of a top it stands on drops it.
- **Down-strike:** any hit bounces the player about 90 px (letting go doesn't cut a bounce). If it hits the top body of a pile, or one climbing, that body is thrown to the ground in front of the face and the pile settles one step lower. One swing takes one body per pile.
- **Telemetry:** `toy_log_v2.csv` (a new file, so the first build's log stays clean) adds `kills_gun`, `kills_melee`, `melee_kill_share`, `bounces` and `pile_knockoffs`.
- **Greybox view:** a hatchet arc in the swing's direction, a small burst on a bounce, a squash on landing and a slight stretch in fast air. F3 also draws the swing's hit box.

**Soak note (candid):** the headless soak now has a hatchet brawler bot that only shoots far-off runners. It reached dawn on both of its nights with about 88% of kills by melee and only 1–2 hits taken. The bot isn't skilled, so melee may be too safe: the shamblers mostly ignore you while they chase the hum. If testers find the same, the knobs are knockback, recoil, the shamblers' wind-up, and whether a melee hit pulls a shambler onto you.
