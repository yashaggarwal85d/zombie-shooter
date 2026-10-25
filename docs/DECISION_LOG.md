# Decision log

Doc G3 · Started 2026-10-25 · Owner: Yash · Sources: [PLAN.md](../PLAN.md) v1, [GAME_VISION.md](GAME_VISION.md), project threads

Every decision that shapes the game, newest first within each group, with what was rejected and why. Only Yash approves a decision. A low-level doc may detail a decision but never change it; a change is a new entry here that names the one it supersedes.

**Status values:** *Decided* means Yash chose it explicitly. *Plan default* means it was a default in PLAN.md v1 that Yash froze on 2026-10-24 without changing it. *Proposed* means it is waiting for Yash.

The earlier design's decisions D1–D14 (the 2D side-on shooter) were all superseded by V01 and are not repeated here. Their record is on the closed PRs #2, #4, #5 and #6.

## Decided after the v1 freeze (2026-10-25)

These change or extend PLAN.md v1. Each will be carried into PLAN v2 when it is written.

| ID | Date | Decision | Rejected alternatives and why | By, where |
|---|---|---|---|---|
| V33 | 2026-10-25 | **Players assemble from ready-made parts; they do not draw parts.** Yash draws a large library of voxel parts. The physics behind every creation is real: a heavy barrel on a small grip sways, kicks and is dropped often. Proposed method: physics computed from parts (mass, centre of mass, inertia, recoil against grip and strength), not a rigid-body simulation. | In-game voxel part editor (PLAN 5.3b): harder to balance, a big UI cost, and drawn shapes carried no real behaviour. Full rigid-body simulation of every item: slow, unpredictable, hard to test. | Yash, GAME_VISION review. Supersedes V20 in part |
| V32 | 2026-10-25 | **Everything is built from parts, and parts from smaller parts.** Guns (barrel, muzzle, magazine and more), bows, crossbows, melee, throwables and base devices all use one system. Every part has options and can be printed from any physically sensible material. Players design grenades and choose the chemical filling. Proposed: about 40 basic part types that nest into assemblies. | About 25 flat components (PLAN 5.2): too few options for the invention fantasy. Unlimited part types: code and testing would grow with every weapon. | Yash, GAME_VISION review. Supersedes the "about 25 components" cap in V07 |
| V31 | 2026-10-25 | **Pillar 4, "Think or die".** The player must get smarter to survive; shooting blindly loses. The prototype gate adds: a shoot-only player loses by night 3 to 5. | An action game where aim and reflexes carry you. | Yash, GAME_VISION review |
| V30 | 2026-10-25 | **She is a scientist; you are an engineer who knows far less.** You keep asking her (the LLM) questions to figure things out. | The player as the expert, with the wife as a side advisor. | Yash, GAME_VISION review |
| V29 | 2026-10-25 | **It's all science: chemistry, physics and biology.** Biology is new: collect zombie samples and examine them. Proposed scope: an analysis bench that feeds resistances, director mutations and cure clues into the journal (doc D22), about 40–60 h. | Chemistry-only sandbox (PLAN v1). A full biology simulation: not solo-buildable. | Yash, GAME_VISION review; scope proposed |
| V28 | 2026-10-25 | **Low-level documents:** a list of 50 documents, written just in time per stage, as Markdown in the repo under `docs/`. | Writing every document up front: 150–250 h before any prototype, mostly rewritten after playtests. | Yash approved the [list](https://claude.ai/artifact/6iady1ZA7r9ArXtUtdUnVD) |
| V27 | 2026-10-25 | **Old work deleted.** Only the Godot setup from PR #3 stays; ASSET_REGISTER, DECISION_LOG and research/ removed; PRs #2, #4, #5 and #6 closed. | Keeping the old docs side by side with the new design: two conflicting sources of truth. | Yash, decision card |

## PLAN.md v1 (frozen 2026-10-24)

| ID | Date | Decision | Rejected alternatives and why | By, where |
|---|---|---|---|---|
| V26 | 2026-10-24 | **Plan frozen as v1.** Further changes go into a new version. | — | Yash |
| V25 | 2026-10-24 | **Opt-in telemetry from the demo onward**, used only to train the horde director. The fully offline rule is relaxed for this one purpose. | Fully offline: no player data to learn from. | Yash, decision card. PLAN 4.3 |
| V24 | 2026-10-24 | **A data-driven horde director** trained on bot simulations first, then player data. It aims for a rising target chance of losing, not the maximum. The rule-based director stays as fallback and guard rails. | A true maximiser: finds one unbeatable mix and players feel cheated. | Yash asked for it; target-not-max is a plan default. PLAN 4.3 |
| V23 | 2026-10-24 | **10 zombie types** (5 in the slice), each forcing a different answer, with a **rule-based adaptive director** (counter-mix, weak point, mutation, tactics; one change per night, shown at dusk). | A neural network from the start: untestable, no data yet. | Yash asked for 5–10 types and adaptation; method is a plan default. PLAN 4.1–4.2 |
| V22 | 2026-10-24 | **The game is winnable but very hard.** Exactly one combination cures her, found through subtle, detective-level clues. | Unwinnable (the first pivot description). | Yash, doc comment. PLAN 9.1 |
| V21 | 2026-10-24 | **The wife is a fine-tuned small local LLM** (Qwen3 1.7B or 4B, LoRA, through NobodyWho), grounded in game data by tool calls. Wrong answers are part of her illness. Guards: lucidity tied to health, scripted clue lines, recipe checks, safety filter, scripted fallback. | Scripted advisor only: always right, but less alive. Scripted first with the LLM as an optional extra (PLAN 8.3). Cloud LLM: costs per player forever, needs internet. | Yash; the guards are plan defaults. PLAN 8.4 |
| V20 | 2026-10-24 | **Voxel world (3D pixel art)**, drawn by Yash in MagicaVoxel. Materials are colour plus a shader. The in-game part editor in this decision was replaced by V33. | 3D low-poly in Blender: needs a new skill. 2D isometric sprites: 4–8× the character art. | Yash. PLAN 3.1 |
| V19 | 2026-10-24 | **Angled three-quarter camera** like Project Tomorrow or Baldur's Gate 3, with limited pan, zoom and 90-degree rotation. | Flat top-down. | Yash. PLAN 3 |
| V18 | 2026-10-24 | **Windows only, on Steam.** | Windows plus Android and iOS (old D8): phone limits, store fees and an Apple fee that does not fit the budget. | Yash, doc comment |
| V17 | 2026-10-24 | **Yash draws all art and supplies the sounds.** CC0 placeholders only while greyboxing, all logged and replaced before release. | Bought or generated art. | Yash |
| V16 | 2026-10-24 | **Devices are manual by default.** They fire on their own only if the player wires a trigger circuit. | Every device fires automatically. | Yash. PLAN 5.3 |
| V15 | 2026-10-24 | **No mid-night saves.** A death or quit returns to that night's dawn snapshot. Pause is allowed. | Saving during the night: removes the tension. | Yash. PLAN 4 |
| V14 | 2026-10-24 | **Night length grows** from about 2–3 minutes to a cap of about 20. | Fixed short nights. | Yash. PLAN 4 |
| V13 | 2026-10-24 | **The day has no time limit**; the player starts the night. Nothing trickles in while waiting, and her decline ticks at dawn. | A timed day. | Yash. PLAN 4 |
| V12 | 2026-10-24 | **Builds stay on the map.** Dismantling returns about 60% of each element, less if damaged; burned or exploded compounds return nothing. | Builds that vanish each night. A full refund: no cost to switching. | Yash. PLAN 4 |
| V11 | 2026-10-24 | **Economy: one stockpile number per element and compound, plus energy.** Mass comes from scrap, energy from burning corpses. | Item slots, stacks and carry weight: Project Tomorrow's players disliked inventory juggling. | Yash. PLAN 4 |
| V10 | 2026-10-24 | **Real elements and compounds**: about 20 elements reacting into about 35 compounds, with every effect going through a fixed set of property channels. Weather and a supplies need for both of you. | The first 10-element set: too few. | Yash asked for more; the channel rule is a plan default. PLAN 5.1b |
| V09 | 2026-10-24 | **Keep the latest 5 loops**, replayable from any dawn in any order, with 2 echoes (rewinds) per loop. The journal, blueprints, story fragments and her knowledge persist. | Unlimited rewinds: save-scumming kills the tension. Deterministic replay of a whole loop: big cost, little play value. | Yash asked for 5 loops in any order; echoes are a plan default. PLAN 7 |
| V08 | 2026-10-24 | **Two endings:** an acceptance ending followed by endless mode for most players, and the cure ending for the few who solve it. | A single cure ending: most players would get no closure. | Plan default. PLAN 9 |
| V07 | 2026-10-24 | **A bounded systemic sandbox** with hard caps until release, instead of "the whole of reality". The component cap was changed by V32. | Full reality simulation, per-pixel sand, rigid-body construction, real chemical equations: each is a team-scale engine. | Plan default (open question 2). PLAN 1 and 5.4 |
| V06 | 2026-10-24 | **Big weapons can hurt your own base and her**, through fallout and fire. | Friendly fire off: removes the nuclear trade-off. | Plan default (open question 3). PLAN 5.3 |
| V05 | 2026-10-24 | **Five damage channels:** kinetic, fire, electric, radiation, explosive. | Many named damage types: harder to learn and to read. | Plan default. PLAN 1 |
| V04 | 2026-10-24 | **The nuclear transmutation device and 3D printer** are the core machines; corpses are fuel and scrap is material. | — | Yash, pivot brief |
| V03 | 2026-10-24 | **No NFTs or blockchain.** Designs are shared as free blueprint codes. | NFT designs like The Sandbox: Steam does not allow blockchain games (to verify against current Valve wording). | Plan default. PLAN 3.1 |
| V02 | 2026-10-24 | **Godot 4.7.2 with statically typed GDScript**, a simulation kept separate from the view, data as Godot Resources, GUT tests. | Another engine: no concrete advantage. | Unchanged from earlier; PLAN 10 |
| V01 | 2026-10-24 | **Pivot to an angled-view transmutation base-defence game**, inspired by Project Tomorrow, protecting an infected wife. Supersedes D1–D14. | The 2D side-on horde shooter. | Yash, pivot brief |

## Waiting for Yash

| ID | Question | Proposed default | Raised |
|---|---|---|---|
| Q1 | The cure: one fixed answer for everyone, or values seeded per save so wikis cannot spoil it? | Seeded | PLAN 9.1, 2026-10-24 |
| Q2 | Base model for the wife: Qwen3 1.7B or 4B? | Choose by the wife test | PLAN 16 |
| Q3 | Time-loop fiction: light (she remembers), or a game feature only? | Light | PLAN 16 |
| Q4 | Field grid size, now that the world is 3D voxels (PLAN says 32 px cells) | Cells in world units, for example 1 cell = 1 m = 10 voxels | Doc list, 2026-10-25 |
| Q5 | Number of basic part types | About 40, nesting into assemblies | V32, 2026-10-25 |
| Q6 | Prototype element count (PLAN says 4, 6 and 10 in different places) | 6 | Doc list, 2026-10-25 |
| Q7 | Zombie types in the paper test (PLAN says 6; the slice has 5) | Paper-test all 10; build 3 in the prototype and 5 in the slice | Doc list, 2026-10-25 |
| Q8 | Languages at launch | English only, with all text in translation files | Doc list, 2026-10-25 |
| Q9 | Biology scope (V29) | Analysis bench feeding the journal and cure clues, about 40–60 h | 2026-10-25 |
