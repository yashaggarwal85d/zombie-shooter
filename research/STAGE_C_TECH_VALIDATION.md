# Stage C: Tech and Pipeline Validation

Stage C (tech and pipeline validation) · 22 October 2026 · Status: **in progress. Experiments are built; the hardware runs and the human tests are Yash's to do.**

Input: [STAGE_B_DESIGN_RESEARCH.md](STAGE_B_DESIGN_RESEARCH.md) section 11 (C1–C6), approved as D9. Code: [`experiments/stage_c/`](../experiments/stage_c/README.md), a throwaway Godot 4.7.2 project nested in the repo. It is built on the tooling skeleton (PR #3) and copies that skeleton's export presets and InputMap. Builds and media are in the project files under `stage_c/`.

**What "ran" means here.** I ran everything that can run in a cloud container with no GPU: the logic headless, and the scenes under a software renderer (Mesa llvmpipe) to take screenshots and record the clip. Frame rates from this machine say nothing about your PC or phone, so I don't report them. Nothing has been launched on Windows, Android or Steam yet.

---

## Summary

| # | Experiment | Status | Result so far |
|---|---|---|---|
| C1 | Toolchain, exports, input | **Built, waiting for your hardware** | Windows and Android (arm64) builds export headless from Godot 4.7.2 with the skeleton's presets. The input scene shows every action and which device fired it. |
| C2 | Look test | **Harness done, judgement pending** | Renders with HIGH and LOW presets plus a greyscale check. My honest read is below: it reads clearly, but it doesn't yet look like something people would click. |
| C3 | Performance | **Built, waiting for your hardware** | Sweep and 20-minute soak with CSV logging. Horde logic costs 0.3 ms a frame at 60 enemies on a cloud CPU core; the GPU side is unmeasured. |
| C4 | Pathing and the noise rule | **PASS (logic, headless)** | 60, 100 and 200 agents, 3 seeds × 10 simulated minutes: 0 stuck, 0 path failures, 0 off-geometry, p99 ≤ 1.1 ms. One design fix found (below). |
| C5 | GodotSteam | **Half done** | GodotSteam GDExtension 4.23.2 (20 Oct 2026) loads in Godot 4.7.2 and reaches `SteamAPI_Init`. The achievement and cloud save need Steam running on your PC. |
| C6 | Hook test | **Kit ready, needs 10+ strangers** | 12-second clip (GIF and MP4), capsule mock, and a scripted protocol. |

**Go/no-go for Stage D (prototype): not decidable yet.** C4 passes. C1, C3 and C5 need about 2 hours of your time on your PC and phone. C2 and C6 need other people. The section "What you need to run" lists each step.

---

## C4. Pathing and the noise rule: PASS (logic)

**Setup.** Three floors plus a roof; the chamber on floor 1; stairwell A (floors 0–2) and B (floors 0–3, its top flight is the roof hatch); 8 entries, 3–4 open each "night" (re-rolled every 2 simulated minutes). The waypoint graph has 25 nodes, searched with Godot's `AStar2D`. Enemies walk floors and take stairs only. Each shambler re-evaluates its target twice a second using the Stage B rule: loudness × distance falloff × 0.35 per floor crossed, ties to the nearer source. Runners ignore noise. A scripted stand-in player wanders between floors, fires bursts of 2–5 shots, and drops a lure every 15–25 s.

**Result** (`soak.gd`, 60 Hz fixed step, run 22 Oct 2026 on one cloud CPU core):

| Agents | Seeds | Stuck | Path failures | Off floor/stairs | Logic p99 (ms) | Worst single frame (ms) |
|---|---|---|---|---|---|---|
| 60 | 1, 2, 3 | 0 | 0 | 0 | 0.30–0.36 | 3.6–8.3 |
| 100 | 1, 2, 3 | 0 | 0 | 0 | 0.51–0.57 | 6.4–177 |
| 200 | 1, 2, 3 | 0 | 0 | 0 | 0.99–1.04 | 5.7–11.2 |

Pass criteria (Stage B): no stuck agents in a 10-minute soak and under 2 ms a frame. Both are met, using p99. The worst single frames are isolated spikes; one of 177 ms in a run whose p99 was 0.55 ms points to the shared cloud machine rather than the code. Treat them as unproven until C3 logs `sim_ms` on your PC.

**What it found (these change the design, so they need your eye):**

1. **The bare rule makes crowds dither.** On the first soak, 34 agents were flagged as stuck. Traces showed they weren't stuck in geometry. They flipped between the hum and short gunshot pulses every half-second and went nowhere. Fix: each agent **remembers a sound's position for 3 s** after it stops, and a new sound must be **25% louder** than the current one to take the agent. After the fix there were 0 stuck agents. I changed the stuck test to count only agents that kept the same route for 2 s without moving, so turning round no longer counts as stuck. **Proposal for the GDD: add memory and hysteresis to the noise rule.** They are also tuning knobs: a longer memory makes the pull stronger.
2. **Turning round is common: 2.1–2.9 reversals per agent per minute** with the scripted player's gunfire. That's the pull working, but it's also how often a crowd changes direction on screen. The combat toy should check that it reads as "I pulled them" rather than as jitter.
3. **Crowds form conga lines.** On a side-on floor, agents following the same target collapse into one stacked file (see the C3 screenshot and the C6 clip). Stage B predicted this. The prototype needs a little separation, such as a spacing rule or a staggered stop distance, and the 30–60 cap stays right.

## C3. Performance: built, needs your PC and phone

**What it does.** It draws the C4 sim with the full C2 look: rim-lit sprites, 8 lights with shadows on HIGH (3 lights, no shadows on LOW), two fog layers, grain, and a muzzle-flash light. It logs fps, the worst frame each second, draw calls and sim time to a CSV. The **sweep** runs 60 s each of 60/100 enemies on HIGH, 60/100 on LOW, and 150 on LOW, then shows a table. The **soak** runs 20 minutes and reports the worst one-minute average, which catches thermal throttling.

**Pass** (Stage B): 60 fps at 60 enemies on the reference PC; 30 fps on the reference phone at LOW; no one-minute average below target over 20 minutes.

**Renderers.** The skeleton uses the Mobile renderer everywhere, provisionally, and asks C3 to compare it with Compatibility. So there are two APKs that install side by side (the "Stage C (Compat)" app uses Compatibility), and `run_compatibility.bat` runs the Windows build on Compatibility.

**Seen here, not measured:** at 60 enemies on HIGH the scene issues about 230 draw calls, because each shadowed light redraws what it touches. If the phone fails, the first cuts are shadows and light count, then batching the sprites (Stage B's fallback).

## C2. Look test: harness done; my read

**Built:** the layered scene from Stage B section 8. The background is darkest. The back walls are mid-dark and lit by lamps. The silhouettes are near-black with a cold rim on the side facing the light. The chamber is the brightest thing on screen. Fog sits behind the actors, and nothing large sits in front of a floor lane. There's a HIGH/LOW preset, a greyscale toggle, close and full framing, and a "crowd" toggle. The silhouettes are original shapes drawn by a script (`art_src/make_silhouettes.py`), so there's no licence question. Screenshots are in `stage_c/look_test/` (software-rendered here; your GPU will show the same image).

**Greyscale check (my judgement, from the screenshots):** passes the readability rules. Every enemy separates from the wall behind it, the chamber is the brightest object, and LOW reads like HIGH minus the shadows.

**Honest quality read:** this is a clean programmer greybox, not the Silksong-feel target. Walls are flat stripes, the silhouettes are stiff and unanimated, and there's no painted depth. I don't think strangers would click on this capsule today. That's the expected starting point, not a verdict. The 10–15 h look test in D4 is your time on top of this harness: rig one enemy in Skeleton2D, tune the lights and fog, and replace or redraw the placeholder shapes. Then run the "would you click" test with you plus 3 others. If it still falls short, D4 says an artist becomes a precondition for the vertical slice, and Stage B section 8 estimates ₹30,000–1,80,000 for the key assets.

## C5. GodotSteam: loads; Steam features untested

**Fact (checked 22 Oct 2026):** the newest GodotSteam GDExtension on Codeberg is 4.23.2 (released 20 Oct 2026; Steamworks SDK 1.65; MIT), built for Godot 4.4+ ([releases](https://codeberg.org/godotsteam/godotsteam/releases)). In this container it loaded in Godot 4.7.2, reported its version, and called `SteamAPI_Init`, which failed only because no Steam client was running (status 1, "Failed to load module steamclient.so"). That is the expected result without Steam.

**Still to check on your PC:** the Spacewar (app 480) achievement unlocks with an overlay toast, and a file written to Steam Cloud reads back identical. The Windows build includes the plugin and `steam_appid.txt`.

**Implication for the architecture:** the plugin ships Android libraries too. The real game must exclude `addons/godotsteam/*` from the Android and iOS presets and guard Steam calls with `Engine.has_singleton("Steam")`.

## C6. Hook test: kit ready

The 12-second clip shows the hook in one take. A crowd heads for the chamber. The protagonist, behind them, fires and pulls them off her. He goes quiet and they turn back. One runner ignores the noise and goes straight for her. Captions read: *"The machine keeping her alive hums." / "They go to the loudest thing in the house." / "Be louder. Or let the traps work."* The capsule mock uses a placeholder title, **THE HUM**, which I haven't checked against existing games or trademarks. The protocol is in `experiments/stage_c/c6_hook/README.md`. Pass: at least half of 10+ strangers say a sentence that mentions protecting someone **and** noise or luring.

## C1. Toolchain and input: built

The skeleton's presets were copied with their package and product names changed, so these builds install next to the real game. Both exported headless here: Windows release x86_64, and Android debug arm64 signed with a throwaway key (min SDK 24, target 36). The APK signature verifies with `apksigner`. The input scene lists all 11 actions from the skeleton's InputMap and marks which device triggered each one: keyboard, mouse, gamepad or touch. It moves a test character along the floor, changes floor at a stairwell, and draws the aim line from the mouse pointer, the right stick, or a touch drag. Touch buttons press the same actions through `TouchScreenButton`.

Two notes for the tooling setup:

- The main project's import printed `Detected another project.godot at res://experiments/stage_c. The folder will be ignored.` That confirms the nested project doesn't leak into the game.
- The Android export needs an icon; it currently falls back to the default and logs an error.

## What you need to run (about 2 hours, plus people)

Files are in the project files: `stage_c/builds/`, `stage_c/look_test/`, `stage_c/hook_test/`.

1. **Windows, about 45 min.** Unzip `StageC-windows.zip` and run `StageC.exe`.
   - **C1:** play with the keyboard and mouse, then a gamepad if you have one. Every row should show the right device.
   - **C3:** run the sweep, then photograph the table. Run `run_compatibility.bat` and do the sweep again.
   - **C5:** with Steam running, choose C5. Look for PASS and the overlay toast.
   - Start the HIGH soak (20 min) and photograph the result.
2. **Android, about 60 min.** Install both APKs (allow "install unknown apps").
   - **C1:** use the touch buttons and drag to aim.
   - **C3:** run the sweep in each app. Then run the LOW soak (20 min) in the faster one, with the phone not on a charger, and photograph each result screen.
3. **Send me:** the photos (or the CSVs from `%APPDATA%\Godot\app_userdata\Stage C experiments\`), your PC's CPU/GPU/RAM, and the phone model.
4. **C2, your 10–15 h:** open `experiments/stage_c` in Godot 4.7.2 and work in `shared/house_view.gd` and the silhouettes. Then show the close HIGH shot to 3 people.
5. **C6:** run the protocol with 10+ strangers.

## Decisions this will need (after the runs)

- **Renderer:** Mobile or Compatibility, decided by the phone numbers (TECHNICAL_ARCHITECTURE section 3 says to switch if Compatibility is clearly faster).
- **Noise rule amendment:** add memory (about 3 s) and hysteresis (about 1.25×) to GDD section 2. This needs your approval because it's a core rule.
- **Art path:** the C2 result decides whether an artist becomes a slice precondition (D4).
