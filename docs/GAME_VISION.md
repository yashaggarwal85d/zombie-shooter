# Game vision

Doc G1 · Version 1 · 2026-10-25 · Owner: Yash · Source: [PLAN.md](../PLAN.md) v1 (frozen 2026-10-24), sections 1, 3, 9 and 12–14

This page is the test every feature is checked against. If a proposal does not serve a pillar below, or breaks a "not" rule, it is rejected or goes to the DECISION_LOG as a change to this vision. Everything here is a hypothesis until a stage gate passes (ROADMAP).

## The game in one sentence

Keep your infected wife alive one more night by inventing your own defences from real science (chemistry, physics and biology), against a horde that learns from how you fight.

## Premise

You and your wife are the last people in your home. She is a scientist; you are an engineer who builds well but knows far less than she does (Yash, 2026-10-25). She is infected and lies in a cold chamber at the centre of the base. She built the two machines you have: a **transmutation device** that changes one element into another, and a **3D printer** that turns materials into parts. Every night the dead come, and every corpse they leave is fuel. Everyone, including her, believes there is no cure. There is one, hidden in plain sight.

You keep asking her questions to figure things out: what an element does, why a device failed, what a new zombie is, what a sample means. She is your teacher and your partner, and the illness is slowly taking the mind you depend on.

## Pillars

Every feature must serve at least one.

1. **Invent, don't unlock.** Your defences are things you designed, drew and wired, not things you bought from a list.
2. **Every night is worse.** The horde grows and adapts to your favourite tactics. You are measured by how far you get.
3. **Her.** She is the scientist and your main source of knowledge. Protecting and tending her is the goal and the cost; time with her is time not building, and the sicker she gets, the less you can learn from her.

## What the player does

| Phase | Length | The player |
|---|---|---|
| Day | No limit; the player starts the night | Burns corpses for energy, melts scrap for mass, transmutes elements, mixes compounds, prints parts, builds and wires devices, tends her, reads the dusk scouting report |
| Night | About 2–3 minutes on night 1, growing to a cap of about 20 | Moves, shoots, repairs, refuels and reroutes power while wired devices fire on their own |
| Dawn | About 30 seconds | Counts the dead; wreckage becomes tomorrow's fuel; her health ticks down; a snapshot is saved |

A run (a loop) ends when you die, she dies, or a zombie reaches her chamber. The journal, blueprints, story fragments and her knowledge carry into every later loop; the latest 5 loops can be replayed from any dawn, with 2 echoes (rewinds) per loop.

## What makes it different

- **It's all science (Yash, 2026-10-25).** Everything the player makes comes from real science working by simplified, learnable rules:
  - **Chemistry:** about 20 real elements react into about 35 real compounds.
  - **Physics:** nuclear transmutation (with fusion and fission as the fiction behind it), energy, heat, electricity, radiation, mass and momentum, and 5 damage channels (kinetic, fire, electric, radiation, explosive).
  - **Biology:** collect zombie samples and examine them to learn each type's weaknesses and the infection itself, which feeds the cure.

  About 25 printable components turn this into thousands of devices; none are hand-scripted.
- **You draw your inventions in 3D.** The whole world is voxel art, so a part drawn in the in-game voxel editor is immediately a usable object in the same style.
- **She is alive, and she is the expert.** A small, fine-tuned local language model is the wife, grounded in game data. You learn the science mostly by asking her. Her confusion grows as her health falls, which is the illness, not a bug.
- **A horde that answers you.** A director counters your dominant damage channel and weak side every night, and shows you at dusk what is coming.
- **A cure for detectives.** The game is winnable: exactly one combination cures her, found only by connecting subtle clues across loops. Most players will reach the acceptance ending instead, then endless mode.

## Who it is for (hypothesis)

Players who like build-by-day, defend-by-night games (Thronefall, They Are Billions, Project Tomorrow) and systemic "I wonder if this works" sandboxes (Noita, Oxygen Not Included), with a pull toward story mysteries (Return of the Obra Dinn, Outer Wilds). These are design references for principles only; nothing is copied from them.

Opinion: the overlap of these three audiences is narrow. The Steam page test in Stage 3 must show whether the hook lands with base-defence players on its own.

## Experience goals

- **Night 1 of loop 10 feels nothing like loop 1**, because of what the player has learned and saved, not because numbers went up.
- **Tension, not chores.** Needs only bite on bad-weather days and are announced at dusk. Nothing rewards waiting.
- **The danger is always readable.** Zombies are the highest-contrast thing on screen; effects never hide them.
- **Losing is the expected end of a good story,** and every run leaves the player better off.
- **Tone (proposed, to confirm in N1):** quiet, warm and sad rather than gory. The love between them carries the game; the horror is the clock.

## What this game is not

- Not a simulation of all of reality. Science is real in its names and its direction, simplified in its numbers. Caps hold until release: 20 elements, about 35 compounds, about 25 components, and a small set of sample tests.
- Not physics construction: no rigid bodies, no per-pixel sand, no free-form mesh sculpting, no stress or aerodynamics.
- Not multiplayer, not procedural worlds, not a large open map. One map, one base.
- Not a grind: no meta-currency, no stingy numbers. Difficulty comes from the horde.
- Not a branching narrative or a dialogue tree. Story beats and clue lines are hand-written; the model only phrases and chats.
- Not online: single-player and offline, except opt-in telemetry that trains the horde director (approved 2026-10-24).
- No NFTs or blockchain. Player designs are shared as free blueprint codes.

## Constraints

| Constraint | Value |
|---|---|
| Team and time | Yash solo, 1–2 hours a day; Yash draws all art and supplies sound |
| Platform | Windows only, on Steam |
| Engine | Godot 4.7.2, statically typed GDScript |
| Budget | Under INR 10,000; the Steam Direct fee (US$100) uses most of it |
| Price hypothesis | US$9.99–19.99; the top end is not assumed |
| Scope estimate | About 1,550–1,800 hours to minimum release including art, roughly 3 years at 1.5 h/day |

## How we will know it works

| Stage | Gate (from PLAN.md section 14) |
|---|---|
| 1. Paper design | At least 12 of 20 paper devices have a distinct tactical job, and no device beats every zombie type |
| 2. Prototype | Of 5 strangers, at least 3 build an unscripted device and median fun is 4/5 or better; 3 of 5 want "one more night"; 300 zombies at 60 fps on a mid-range PC; no device takes over 50% of kills |
| 2b. Wife test | 90% of recipe answers correct while lucid; clue lines never altered; zero unsafe outputs from 100 red-team prompts; first words under 1.5 s |
| 3. Vertical slice | About 3,000 wishlists within 3 months of the Steam page; demo median playtime over 45 minutes |
| 4. Release | 15,000 wishlists before launch; no crash in a 3-hour soak |

The long-term goal is about US$1M net revenue across games (Yash, 2026-10-22). This game is not assumed to reach it alone.

## Open questions that affect this vision

- **Her as the main source of knowledge raises the stakes on the wife test** (opinion). If most learning goes through her, a wrong answer costs more, and players who turn AI off or have a weak PC must still be able to learn everything. Proposed: the journal records what she said and marks it untested until it is tried, recipes she gives are checked against the reaction table, and the scripted fallback covers every topic she can answer. Detailed in T7 and N2.

- **Biology is new since PLAN.md v1** (Yash, 2026-10-25). The plan's "Biology" is limited to corpses as fuel and one rare zombie type as a clue. Proposed scope: a sample-analysis bench where the player takes samples from kills (blood, tissue, spores), runs a few tests (microscope, culture, reagent), and learns resistances, mutations from the director and cure clues. It slots into the journal and the cure, not a new simulation. Estimate (mine): about 40–60 h of code plus writing, minimum release, with one test in the prototype. To be logged in DECISION_LOG and detailed in a new design doc.

- The cure: one fixed answer for everyone, or values seeded per save so wikis cannot spoil it? The plan's default is seeded.
- Does the time-loop fiction stay light (she remembers), or are loops purely a game feature? The plan's default is light.
