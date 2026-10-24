# The plan: transmutation base-defence (pivot v1)

Status: draft for Yash's approval · 2026-10-24 · supersedes every earlier design decision (D1–D14). Earlier work is archived, not deleted (section 15).

Everything below is a hypothesis until a gate in section 14 passes. Facts carry a source and date. Estimates and opinions are labelled.

---

## 1. The verdict in one paragraph

The pivot is buildable, but not as literally described. "The whole reality completely simulated, create anything" cannot be built by one person at 1–2 hours a day, and no shipped game does it. Noita, Oxygen Not Included and Zelda's chemistry engine all *feel* limitless because a small set of rules interact, not because reality is simulated. So the plan is a bounded systemic sandbox: about 20 real elements that react into about 35 real compounds, about 14 printable components, and 5 damage channels (kinetic, fire, electric, radiation, explosive) that follow simple, learnable rules. A device is whatever the player assembles on a grid, and its behaviour comes from those rules. That gives thousands of working combinations and the honest feeling of freedom. The wife is a fine-tuned small local LLM in her voice (Yash's decision), grounded in game data through tool calls; her mistakes are part of her illness, but the cure clues and safety stay controlled. The cure exists but is almost impossible to find: exactly one combination works, and its hints need real detective work. That works only if every run shows measurable progress for the many who never find it, and the answer cannot simply be looked up online (section 9). Realistic scope for a minimum Steam release is about 1,250–1,450 hours including art, roughly 2–2.5 years at 1.5 h/day.

---

## 2. Research

### 2.1 Project Tomorrow (Steam app 4402200)

Facts (retrieved 2026-10-24):
- Developer and publisher Advance Nine, a solo developer named Ryan. Early Access planned for **9 Nov 2026**; full release targeted later (Steam page; [TechTimes, 2026-09-07](https://www.techtimes.com/articles/326864/20260907/project-tomorrow-demo-draws-21000-wishlists-solo-dev-ships-two-overhauls-three-weeks.htm)).
- Pitch: "A base-building survival game with terraforming and crafting." You wake from stasis on a poisoned Earth, build terraforming machines, and alien waves attack those machines; expanding brings bigger attacks ([Steam store page](https://store.steampowered.com/app/4402200/)).
- Steam tags include Base Building, Tower Defense, Survival, Crafting, Resource Management, **Isometric, Third Person**. So its camera is angled; that is the view we adopt (Yash, 2026-10-24).
- Early Access scope: 3 regions, 20 buildings, 75 items, 18 enemies, 20 modifiers (store page).
- Demo since 17 Aug 2026: **21,000+ wishlists and about 6,000 demo players in its first two weeks** (TechTimes, 2026-09-07, citing the developer). No user reviews yet on 2026-10-24.
- Player feedback the developer acted on (TechTimes): passive terraforming was "boring" and encouraged idling, so progress now comes only from building and defending; inventory management pulled players out of play; oxygen and thirst drain felt "more exhausting than tense"; early waves were too punishing.

What we take: a base that is the thing being attacked, waves that grow as you grow, and a day/night rhythm. What we learn from its feedback:
1. Never reward waiting. Every resource must come from acting (killing, salvaging, defending).
2. No inventory juggling. Many elements and compounds, but each is one number in a stockpile (section 4), never item stacks or slots.
3. Survival meters must create decisions, not chores. The wife's needs are the one meter, and it is the story.

Competitive note (opinion): it launches into Early Access a long time before we could, in the same genre. Copying its structure is not a differentiator. The transmutation sandbox, the wife and the loops have to be the reason to buy.

### 2.2 Comparable games and what they prove

| Game | Evidence (source, date) | Lesson for us |
|---|---|---|
| Thronefall (Grizzly Games, 2 people) | 1M+ copies across PC and Switch at €12.99 ([GamesMarket](https://www.gamesmarket.global/indie-hit-thronefall-sells-over-one-million-copies-588b03986d04328e71544cbcb1d1b454/)); 315k in its first two months of Early Access in 2023, 6.9% refunds ([WN Hub](https://wnhub.io/news/indie/item-42153)); Raijin estimates 560k Steam copies, ~$4.4M gross, as of 2026-07-22 ([Raijin](https://raijin.gg/app/2239150/Thronefall)) | Build by day, defend by night sells when the loop is tight and the art is minimal. Its makers credit the "minimal" scope ([GameDiscover](https://newsletter.gamediscover.co/p/deep-dive-how-thronefall-went-minimal)). |
| They Are Billions (Numantian) | Raijin estimates ~1.1M Steam copies, ~$19.2M gross, as of 2026-07-22 ([Raijin](https://raijin.gg/app/644930/They_Are_Billions)); estimates vary by source ([Wikipedia](https://en.wikipedia.org/wiki/They_Are_Billions)) | A huge horde breaking a wall is the fantasy. One breach can end the run, which makes runs tense and short. |
| Project Tomorrow | 21k wishlists from a demo, solo dev (above) | The base-building plus tower-defence audience is active right now. |
| Noita, Oxygen Not Included, Zelda's chemistry engine (no figures used; design references only) | Opinion | Freedom comes from a few rules that interact. Each is a big-team or custom-engine effort, so we take the principle, not the tech. |

Thronefall and They Are Billions are outliers, not targets. Third-party Steam estimates (Raijin, SteamSpy) are models, not reported sales, and gross revenue is before Steam's cut, refunds, taxes and regional pricing.

### 2.3 Local LLM facts (for section 8)

- Godot integrations exist: **NobodyWho** (llama.cpp, Godot 4.5+, Windows/Linux/macOS/Android under Godot; no iOS export for Godot; tool calling with grammars; licence EUPL-1.2, usable in commercial projects, changes to its own code must be open-sourced) ([GitHub](https://github.com/nobodywho-ooo/nobodywho), read 2026-10-24). Others: Godot Llama (MIT) and godot-llama-cpp ([Godot Asset Library](https://godotengine.org/asset-library/asset/4810), [GitHub](https://github.com/hazelnutcloud/godot-llama-cpp)). Maintenance status not verified.
- **Qwen3-0.6B** weights are Apache-2.0. Qualcomm reports roughly 100–137 tokens/s at 512 context on Snapdragon 8 Elite-class phones with its own runtime, falling to about 18–40 tokens/s at 4,096 context ([Qualcomm AI Hub](https://aihub.qualcomm.com/mobile/models/qwen3_0_6b)). Those are flagship numbers from the vendor; mid-range phones will be much slower. NobodyWho recommends at least a Snapdragon 855 with 6 GB RAM.
- **Steam rules:** a game whose AI produces content while it runs ("live-generated") must describe its guardrails in the Content Survey, must let players report illegal content through the overlay, and gets an AI disclosure on its store page ([Steamworks Content Survey docs](https://partner.steamgames.com/doc/gettingstarted/contentsurvey); [80.lv](https://80.lv/articles/steam-introduces-new-rules-for-games-with-generative-ai/)). Secondary coverage says Valve narrowed the rules in January 2026 to content players actually experience; a live chat with the wife is exactly that, so the disclosure applies either way. Check the current Steamworks wording before submission.

---

## 3. The game in one screen

**Working premise.** You and your wife are the last people in your home. She is infected and lies in a cold chamber in the middle of the base. She built the two machines you have: a **transmutation device** that changes one element into another, and a **3D printer** that turns materials into parts. Every night the dead come. Every corpse you leave behind is fuel. Everyone, including her, believes there is no cure. There is one, hidden in plain sight.

**Camera.** An angled three-quarter view like Project Tomorrow or Baldur's Gate 3 (Yash, 2026-10-24), looking down at roughly 45–60 degrees. The whole base fits on screen with limited pan, zoom and 90-degree rotation, so the horde stays readable.

**Decision needed: 3D models or 2D isometric art.** Baldur's Gate 3 and, by its tags, Project Tomorrow are 3D games under an angled camera. Two ways to get that look:

| Option | Art work for Yash | Code | Fit |
|---|---|---|---|
| 3D low-poly models, angled camera (recommended) | Model, texture and rig in Blender (free). One model works from every angle; devices assemble from 3D component parts; materials tint by shader | Godot 3D: lights, shadows, clicking on a ground grid. A little more work than 2D | Closest to the references; rotation and zoom come free. Means learning 3D modelling |
| 2D isometric sprites | Every character animation drawn in 4–8 directions; buildings from 2 angles; no camera rotation | Simpler 2D code plus isometric depth sorting | Keeps drawing skills, but character art time multiplies by about 4–8 |

Recommendation: 3D low-poly with a painted, stylised look, if Yash is willing to learn Blender; art estimate becomes about 300–500 h instead of 250–450. Otherwise 2D isometric with 4 drawn directions mirrored to 8.

**Platform.** Windows only, on Steam (Yash, 2026-10-24). No mobile or console versions are planned.

**Pillars** (each feature must serve at least one):
1. **Invent, don't unlock.** Your defences are things you designed, not things you bought.
2. **Every night is worse.** The horde grows and adapts. You are measured by how far you get.
3. **Her.** Protecting and tending her is both the goal and the cost.

---

## 4. Core loop

```
DAY (about 4 min, pausable)            NIGHT (about 3–5 min, real time)        DAWN (30 s)
- burn corpses -> energy               - horde arrives from 2-4 edges            - count the dead
- melt scrap -> mass                   - your devices fire on their own          - corpses and wreckage
- transmute elements (costs energy)    - you move, shoot, repair, refuel,          become tomorrow's fuel
- print parts (costs mass)               reroute power, drag her chamber's       - her health ticks down
- assemble or upgrade devices            cooling back online                     - loop snapshot saved
- tend her: cool, sedate, talk          - lose if you die or she dies
- read dusk scouting: what's coming
```

**Resources: an element stockpile plus energy** (Yash, 2026-10-24).
- **Mass (kg)** comes from scrap: wrecked devices, debris, salvage piles on the map edges, and zombie remains. The stockpile shows one amount per element and compound (iron 12 kg, methane 3 kg); no slots, stacks or carry weight. Transmutation interchanges elements: it changes which element the mass is, never how much. Reactions turn elements into compounds. Printing spends them.
- **Energy (J)** comes from burning corpses in the bio-reactor. Transmutation and powered devices spend energy.

That one rule set ("mass from scrap, energy from corpses, transmuting costs energy, printing costs mass") is the whole economy, and it ties success at night to options in the day. It also self-balances: a strong night gives a rich day, and a bad night starts a spiral, which is what a near-impossible game needs.

**Build, place, salvage.** Whatever you print is placed on the map and stays there night after night. In any later day you can dismantle it and get back part of what went in: about 60% of each element by default, less if the device was damaged (scaled by remaining hp), and compounds that burned or exploded return nothing. Keeping a device that worked versus scrapping it to fund a counter to tomorrow's threat is a real tradeoff. The return rate is a prototype tuning value.

**Why day is not idle time** (Project Tomorrow lesson): the day clock only moves while you act, and the corpse pile rots. Corpses lose energy value each in-game hour, so delaying costs you.

**Dusk scouting.** At the end of each day you see the night's composition (for example "heavy bloaters, east side"). The player counter-builds. This is where most decisions come from.

**The horde learns** (strong hook, proposal). The night director looks at what killed most zombies last night and adds a counter-type: if fire killed most, tomorrow brings wet "drowned" zombies that resist it. This forces new inventions instead of one solved build, and it is cheap to build because it only changes the wave mix.

---

## 5. The transmutation and printing system

This is the heart of the game, so it gets the most design work and the first prototype.

### 5.1 Elements (prototype set; release grows to about 20)

Each element has six numbers. They are simplified game values, not real chemistry tables, but they point the way real physics does so players' intuition works.

| Element | Density | Hardness | Conducts | Burns / reacts | Radioactive | Typical use |
|---|---|---|---|---|---|---|
| Carbon (C) | low | low (or very high as diamond, late) | a little | burns | no | fuel, gunpowder part, diamond tips |
| Aluminium (Al) | low | mid | yes | thermite with iron oxide | no | light frames, fast projectiles |
| Silicon (Si) | low | mid | semi | no | no | chips, sensors, lenses |
| Sulfur (S) | low | low | no | burns, gunpowder | no | explosives, toxic smoke |
| Sodium (Na) | low | very low | yes | explodes with water | no | wet-zone traps |
| Iron (Fe) | mid | high | yes | no | no | walls, frames, steel with C |
| Copper (Cu) | mid | mid | best | no | no | wiring, coils, Tesla traps |
| Lead (Pb) | high | low | yes | no | shields radiation | slugs, shielding her chamber |
| Tungsten (W) | very high | very high | yes | no | no | penetrators, heat-proof parts |
| Uranium (U) | very high | mid | yes | no | yes | RTG power, the nuclear tier |

**Transmutation rule:** cost in energy = mass × (distance in the element list)², with extra cost for going "up" the list. The order is roughly atomic number, so the player can learn it ("heavier elements are expensive"). Uranium is deliberately far up and very expensive, which makes the nuclear tier a late, meaningful goal.

**Alloys:** the printer can blend two elements in one part. Stats are a weighted mix plus a few named bonuses (steel = Fe + a little C gets extra hardness; bronze = Cu + a little of something). About 6 named alloys in v1; others work but give only the plain average.

### 5.1b Real chemistry: elements into compounds (Yash, 2026-10-24: more elements, real compounds)

Players combine real elements into real compounds, and those compounds fight zombies, keep you and her alive, and lead to the cure. The cost of a bigger chemistry set is not the number of elements, it is the number of distinct effects. So the rule is: **every compound is data, and every effect it has goes through one of a fixed set of property channels.** Adding hydrogen or chlorine is then a table row, not new code.

**Release elements (about 20):** hydrogen, carbon, nitrogen, oxygen, sodium, magnesium, aluminium, silicon, phosphorus, sulfur, chlorine, potassium, calcium, iron, copper, zinc, silver, lead, tungsten, uranium. Oxygen and nitrogen come from air, hydrogen and oxygen from water; the rest come from scrap or transmutation. The 10-element table above is the prototype set.

**Reactions** are a table: inputs in a ratio, a condition (heat, spark, electricity, pressure, a catalyst) and outputs. Names and formulas are real, quantities are simplified.

| Need | Reaction (real, simplified) | Result in play |
|---|---|---|
| Cold night | carbon + hydrogen with heat → methane (CH₄) | Flammable gas: burn it in a heater, or pipe it into a flamethrower |
| Light, fast fuel | water + electricity → hydrogen + oxygen | Hydrogen burns hot; oxygen feeds fires and her breathing support |
| Explosive | potassium nitrate + sulfur + carbon → gunpowder | Charges, mines, shells |
| Breaching heat | aluminium + iron oxide + spark → thermite | Melts armoured zombies and your own walls |
| Area denial | sodium chloride + electricity → chlorine gas | Toxic cloud; drifts with wind and can reach her |
| Sustain | biomass fermented → ethanol | Fuel, disinfectant, an ingredient in her treatments |
| Sustain | nitrogen + hydrogen with catalyst → ammonia | Fertiliser for a small food crop; also a coolant for her chamber |
| Water | hydrogen burned in oxygen → water | Drinking water when supply runs out |

**Property channels** (the only things a compound can do): state (solid, liquid, gas), flammability and burn heat, explosiveness, toxicity, corrosiveness, coolant or heat value, nutrition, medicinal effect (on her), conductivity, radiation. Gases spread on the field grid and drift with wind; that one rule makes methane leaks, chlorine clouds and oxygen-fed fires all work.

**Weather and needs:** temperature becomes a real system. Cold nights and cold snaps drop the base temperature; you and she need heat, and her chamber needs the opposite (cold). Food and water are one simple "supplies" need for both of you. Project Tomorrow's players called constant drain "exhausting", so needs only bite on bad-weather days and are announced at dusk with the horde.

**The cure** becomes one specific compound (in a seeded save, one specific recipe of it), which gives the detective work a huge but learnable search space.

**Scope:** prototype 6 elements, 8 compounds and temperature; vertical slice 12 elements and 20 compounds; release 20 and about 35. Compounds need almost no new art: three container sprites (canister, flask, ingot) tinted per compound, plus gas tints on the grid. About 100 h more than the 10-element plan.

### 5.2 Printable components (v1: about 14)

| Group | Components | What material changes |
|---|---|---|
| Structure | frame, plate, wall block | hp, weight, conductivity (an electrified wall needs a conductive wall) |
| Power | battery, bio-burner, RTG (uranium only), solar sheet (silicon) | output, fuel use, radiation leak |
| Trigger | tripwire, proximity sensor, heat sensor, timer | range, false-trigger rate |
| Effector | barrel, spring launcher, coil (railgun or Tesla), nozzle (spray), charge (explosive) | damage channel and strength |
| Ammo / payload | slug, dart, canister, pellet | taken from the material: lead slug hits hard, sodium canister bursts in water, uranium dart irradiates |

### 5.3 Devices: assembly on a grid

A device is a small grid (3×3 at first, 4×4 later) where the player places components. A valid device needs: one power source, one trigger (or the player as trigger, for hand-held tools), and one effector, connected through structure. Everything else is choice.

Examples that come out of the rules, none of them hand-coded:
- **Automatic arrow shooter:** wood-equivalent (carbon) frame + spring launcher + proximity sensor + battery, with iron darts.
- **Tesla fence:** copper wall blocks + coil + battery + tripwire. Zombies touching the wall take electric damage; it also passes to any zombie touching that one.
- **Sodium moat:** a nozzle that sprays water + sodium canisters lobbed by a spring launcher. Explodes on contact.
- **Railgun:** tungsten slug + copper coil + big battery. Pierces a whole line, uses a lot of energy.
- **Nuclear launcher:** uranium charge + spring launcher. Huge damage, and it leaves radiation in the ground for several nights. Radiation that reaches her chamber hurts her unless you lined it with lead. That is the tradeoff that makes it a real choice and not just the best gun.

### 5.4 The simulation, honestly scoped

- **World:** a coarse grid of 32 px cells (about 40×22 on screen). Each cell holds temperature, wetness, radiation and "burning". Fire spreads to burnable neighbours, water conducts electricity and reacts with sodium, heat melts low-melting parts, radiation decays slowly. Simple cellular-automaton rules updated a few times a second, not per pixel.
- **Power:** devices connected by conductive structure share a power network (a simple graph).
- **Projectiles:** simple kinematic motion with mass and speed; damage = channel strength × target weakness. No rigid-body physics engine.
- **Zombies:** each type has resistances per channel plus mass, wetness, flammability and conductivity, so they take part in the same rules (a burning zombie spreads fire to your wooden wall).
- **Rejected:** per-pixel falling sand, rigid-body construction, real nuclear or chemical equations, free-form 3D modelling in the printer. Each is a team-scale engine project and breaks readability.

Readability rule (from the project instructions): effects never hide danger. Fields are drawn as soft tints under the zombies, zombies are always the highest-contrast thing on screen, and the wife's chamber has a clear health ring.

### 5.5 Discovery and the journal

New devices are recorded in a **journal** automatically the first time they kill something, with an auto-generated name and stats. The journal persists across every loop. Players can name and save blueprints, so re-printing a known design in a new loop is fast. Post-launch, blueprint share codes are a cheap, strong social hook.

---

## 6. The wife

**Her state:** one visible health value plus three needs that drift during the day and night.
- **Cold:** the chamber needs power. If power drops, her decline speeds up.
- **Calm:** sedation printed from materials. Neglected, she may wake and wander (later loops).
- **Company:** talking to her slows decline slightly and is where she gives knowledge. Time with her is time not building.

**The arc:** her health falls a little every dawn regardless of what you do. You can slow it; only the real cure reverses it. The "cure research" is a real mechanic: you print experimental treatments from rare materials; almost every one fails, and each failure reveals a story fragment and a clue. Exactly one treatment works (section 9).

**Loss conditions:** you die, or her health reaches zero, or a zombie reaches her chamber.

---

## 7. Loops: recording and replay

**Assumption** (question 4 for Yash): a "loop" is one run, from night 1 until a loss. During a run the game saves a snapshot at every dawn: the base layout, devices, resources, her state, the field grid, and the random seed.

- The game keeps the **latest 5 loops** and all their dawn snapshots.
- After a loss, the player picks **any of the 5 loops and any dawn inside it**, in any order, and plays on from there. Replaying from a snapshot creates a new loop, and the oldest is dropped.
- **What persists across everything:** the journal (all discoveries and blueprints), story fragments, her knowledge, and personal records. Nothing else.

**Risk: save-scumming kills tension.** If you can always rewind one night, a loss never hurts. Proposal: each loop has a limited number of rewinds (for example 2), shown as "echoes". A loop with no echoes left can only be replayed from its start. This turns the 5 slots into a resource, which fits the time-loop fiction.

**Technical requirement from day one:** the whole simulation state must be serialisable to a single snapshot Resource. That is cheap if designed in from the start and painful to retrofit, so it is part of the first prototype. Full deterministic replay ("watch your last loop") is rejected for v1: it needs a deterministic sim, which is a large cost for little play value.

---

## 8. The wife as an LLM

### 8.1 What you asked for and what is realistic

"Trained on this, she has all the knowledge for creation, she answers with the best she knows." The biggest problem is not speed, it is **hallucination**. A 0.6–2 B parameter model will confidently invent recipes and devices that do not exist in the game, and a player who prints her suggestion and finds it does nothing will feel lied to. Fine-tuning ("training") a small model does not fix that reliably and costs time and money.

### 8.2 Options

| Option | What it is | Pros | Cons |
|---|---|---|---|
| A. Scripted advisor | A structured "Ask her" panel: pick a topic (an element, a component, a zombie, last night) or type a question that is matched to a topic. Answers are generated from the game's own data plus hand-written lines in her voice. | Always correct, runs on any PC, no AI disclosure, cheap to test, her emotional lines are written by you | Less magical; free typing is limited |
| B. Small local LLM, grounded | Qwen3-0.6B or 1.7B (Apache-2.0) through NobodyWho in Godot. The model never answers from memory: it calls game functions ("look up element", "evaluate this device", "suggest a counter to zombie X") and only phrases the result in her voice. | Feels alive, answers odd questions, real differentiator | ~0.5–1.5 GB extra download (my estimate for 4-bit models), needs a decent CPU or GPU, Steam live-AI disclosure and reporting duties, some players dislike AI in games (opinion), 40–80 h to build and test |
| C. Cloud LLM | An API call | Best quality | Rejected: costs money per player forever, needs internet, breaks "offline single-player" |

### 8.3 Earlier recommendation (superseded by 8.4)

Build **A first, designed so B can sit on top of it**. The question-to-answer engine in A becomes the tool set that B calls, so no work is wasted. Ship B as an optional "Talk freely" mode, and only if it passes this test on the reference PC:
- 50 scripted questions: at least 95% of answers factually match the game data (no invented recipes).
- First words in under 1.5 s, full answer under 4 s.
- A list of 100 abusive or off-topic prompts produces zero unsafe outputs and stays in character.

If it fails, A ships alone and B becomes a post-launch experiment. With Windows as the only platform, B is more viable than before: every player can run it. Her story beats and emotional lines are always hand-written by you, never generated, because the tone matters too much to leave to a 1 B model.

---

### 8.4 Decision: the fine-tuned LLM is the wife (Yash, 2026-10-24; supersedes 8.3)

Yash chose the smallest capable model, fine-tuned for the game and her personality, with wrong answers accepted as part of her illness. The framing is good and worth leaning into. Four things still need design:

- **Make the errors a mechanic, not noise.** Tie her lucidity to her health. Well cared for, she answers precisely; as she declines she hesitates, mixes up elements and trails off. Players learn to read her, and caring for her has a visible payoff. Technically, her health value sets the sampling temperature and a confusion instruction.
- **Protect the cure clues.** If she can be wrong about anything, detectives cannot tell a clue from a symptom, and the cure becomes unfair. Clue lines are scripted and come only in lucid moments, with a small tell (her chamber light steadies). The model may discuss clues but cannot change them.
- **Check recipes that cost materials.** When she gives a recipe, a tool call checks it against the reaction table and the journal marks it "she said" until tested. Wrong recipes still feel like her illness, but nobody loses a night's materials to something the game could have flagged. Opinion: a wrong recipe is charming once and frustrating the fifth time.
- **Safety gets no illness excuse.** Steam's live-generated AI rules still apply: guardrails in the Content Survey, an in-game report path and a store disclosure. Plan an output filter plus refusal examples in the fine-tune.

**Model and fine-tune plan**

- Candidates: Qwen3 1.7B and 4B (Apache-2.0, permissive). Models under custom licences (Gemma, Llama) only if they test clearly better and their terms fit. Choose by the wife test, not by benchmarks.
- About 1–2.5 GB on disk at 4-bit (my estimate). Runs on the CPU of most gaming PCs and faster on GPU through NobodyWho's Vulkan support. Minimum specs come from the test.
- Fine-tune with LoRA on free cloud notebooks to stay in budget. Dataset of about 2,000–5,000 dialogues: her voice from seed lines Yash writes, game knowledge from the data tables, refusals, and lucid and confused pairs. The reaction table stays the source of truth, so the model learns to call tools rather than memorise recipes.
- Cost about 100–140 h across slice and release (dataset, training, tool wiring, testing). A scripted fallback (about 20 h) stays for weak PCs and players who switch AI off.

**Wife test (revised):** 50 recipe questions with at least 90% correct while she is lucid (errors only when confused); clue lines never altered; 100 red-team prompts with zero unsafe outputs; first words under 1.5 s on a mid-range PC.

## 9. The hidden cure, and keeping a near-impossible game fun

Most players will never find the cure, so the game must be great for them too. A near-impossible game survives when losing is the expected ending of a good story and each run leaves the player better off. Concretely:

1. **A score that means something.** Nights survived is the headline number, shown everywhere, with personal bests per loop and a Steam leaderboard (free through Steamworks).
2. **Permanent knowledge.** The journal, blueprints and her knowledge carry over. Night 1 of loop 10 feels very different from loop 1.
3. **New threats every few nights.** A new zombie type, an adaptation, or a night event (fog, rain that makes water everywhere, a blood moon). Players stay for "what comes next".
4. **Invention moments.** The best moment in the game is "I wonder if this works" and it does. Dusk scouting plus the learning horde produce those deliberately.
5. **A story with an end for everyone.** Two endings: most players reach the acceptance ending (after enough failed treatments she asks you to stop), then endless mode; the few who solve the case get the cure ending. **I recommend this strongly.** Without it, the large majority who never find the cure get no closure, which is likely to read as "pointless" in reviews.
6. **Daily seed** (release): the same night sequence for everyone that day, with its own leaderboard. Cheap and repeatable.
7. **Short sessions.** A day plus night is about 8 minutes. That suits "one more night".

What I would not do: punishing meta-currency grind, or making early nights impossible to "force" difficulty. Difficulty should come from the horde, not from stingy numbers.

### 9.1 The hidden cure (Yash, 2026-10-24: winnable, but very, very hard)

Exactly one combination makes the cure, and finding it should feel like solving a case.

- **What the combination is:** one printed treatment, for example two elements alloyed in an exact ratio, made through a specific transmutation route, delivered by a specific device, while her chamber is in a specific condition. Every part uses mechanics players already know, so the answer feels fair once seen. Cure attempts cost rare materials, so there are only a few tries per loop and brute force across 5 loops cannot find it.
- **Where the clues live:** in things players already see, never a separate puzzle mode: her scripted lines (never the LLM, which could garble or leak a clue), journal notes, story fragments from failed treatments, details on the map, the behaviour of one rare zombie type, machine readouts. Each clue alone is ambiguous; three or four together point to one answer. Clues persist in the journal, so the detective work spans many loops. Design references, no figures used: Return of the Obra Dinn, Outer Wilds, Tunic, Fez.
- **Near-miss feedback:** a failed treatment tells you, in character and vaguely, how close you were, so a near miss feels like progress rather than noise.
- **Fairness test:** a puzzle-minded stranger with every clue but not the answer must be able to deduce it; one who has seen only two clues must not. Test with 3 such people before release.
- **Spoiler risk:** a single fixed answer will likely be datamined or posted on a wiki soon after launch (opinion), and then the mystery is gone for everyone. **Recommendation:** fix the cure's structure but generate its values (which elements, the ratio, the condition) from each save's seed, and generate the clues from the same values. Every player solves their own case; a wiki can teach how to read clues but cannot hand over the answer. About 30–40 h more than a fixed answer, mostly clue templates. Alternative: one fixed answer, accept the leak, and use "first to cure her" as marketing.
- **Scope:** about 70 h of code plus 60 h of writing, minimum release. The prototype gets one stub clue chain to test fairness early.

---

## 10. Tech stack

| Layer | Choice | Why |
|---|---|---|
| Engine | **Godot 4.7.2, statically typed GDScript** (unchanged) | Free, exports to Windows; the earlier setup work (PR #3: project skeleton, GUT tests, CI, export presets) is design-independent and can be reused |
| Simulation | Plain GDScript classes with no nodes (sim) and a separate view layer, ticked at a fixed rate | Testable with GUT, snapshot-friendly for loops. Only if profiling shows the field grid or horde too slow, move that one hot path to a GDExtension (needs a demonstrated need, per project rules) |
| Data | Godot Resources: `ElementDef`, `AlloyDef`, `ComponentDef`, `DeviceBlueprint`, `EnemyDef`, `WaveDef`, `NightEventDef` | Data-driven tuning without code changes |
| Horde movement | Flow field from the base outward, recomputed when walls change | Cheap for 300+ zombies; one field for the whole horde |
| Horde drawing | `MultiMeshInstance3D` with baked vertex animation (if 3D) | Hundreds of zombies on screen |
| Field effects | One shader reading a small texture built from the grid | Cheap tints, keeps zombies readable |
| Save and loops | Snapshot Resource per dawn, saved to `user://` | Section 7 |
| Wife | Fine-tuned Qwen3 (or similar) via NobodyWho, scripted fallback | Section 8.4 |
| Steam | GodotSteam (achievements, leaderboards, cloud saves) | Standard Godot route; verify licence and version at setup |
| Tests | GUT for sim rules (transmutation cost, damage channels, power networks, snapshot round-trip) | Rules are the game; they must be tested |

No servers, no database, no accounts.

---

## 11. Assets: what and how

You draw all art and supply sounds. The design keeps the art list small on purpose.

**Art-saving rules**
- **Devices are composed from component sprites**, not drawn one by one. You draw about 14 components once; every device the player invents is assembled from them automatically.
- **Materials are a palette swap** (a shader tint plus a small texture overlay), not separate art. Ten elements times fourteen components would otherwise be 140 drawings.
- **With 3D models, characters turn freely,** so one walk cycle covers every direction. With 2D isometric sprites each animation needs 4–8 drawn directions.
- **Effects are particles and shaders**, not hand-drawn frame animations.

**Art list for the first playable slice** (your estimate, my counts)

| Asset | Count | Notes |
|---|---|---|
| Player | 1 body, walk (6–8 frames), shoot, hit, death | Angled view |
| Wife in chamber | chamber, 4 health states, 3 "need" overlays | The emotional centre; worth extra care |
| Zombies | 4 types (walker, runner, bloater, drowned) × walk, attack, death | More types later; each must create a new decision |
| Components | 14 icons that also work as device parts | Neutral grey, tinted by material |
| Machines | transmuter, printer, bio-reactor, scrap furnace | Big, readable, animated with simple loops |
| Terrain | ground tileset (dirt, concrete, water), 2–3 decoration sets | One biome for the slice |
| Field tints | fire, wet, electric, radiation | Mostly shader; small textures |
| UI | printer grid, transmuter panel, journal, "Ask her" panel, HUD | Clean flat UI, one font |
| Corpses and scrap | 4–6 pile variants | They are the economy, so they must read clearly |

**Placeholders while you draw:** CC0 packs (for example Kenney's isometric or 3D sets) for greybox, logged in ASSET_REGISTER.md and fully replaced before release. Fonts under the SIL Open Font License. Sound placeholders from CC0 libraries; verify each licence and log it.

**Audio list (you supply):** about 40 SFX for the slice (each component firing, element reactions, zombie types, machines), 2 music beds (day, night), her voice lines (text first; voice acting is a post-launch question).

---

## 12. Scope and cost per feature

Hours are my estimates for you at your pace, including testing, not counting art unless stated. Classes follow the project rules.

| Feature | Class | Hours | Testing burden | Notes |
|---|---|---|---|---|
| Movement, aim, hand weapon (angled camera) | Prototype | 15 | low | |
| Day/night clock, dusk scouting, wave director | Prototype | 30 | mid | |
| Flow-field horde, 300 zombies at 60 fps | Prototype | 35 | mid | Performance gate |
| Mass/energy economy, bio-reactor, scrap furnace | Prototype | 15 | low | |
| Transmuter (4 elements in prototype, 10 in release) | Prototype → release | 20 + 20 | mid | |
| Printer + device grid + device behaviour (6 components → 14) | Prototype → release | 60 + 120 | **high** | The core; most balancing |
| Field grid: fire, wet, electric, radiation | Prototype (fire, electric) → slice | 30 + 40 | high | Interactions multiply test cases |
| Wife needs and decline | Prototype | 20 | low | |
| Snapshot save system | Prototype | 25 | mid | Must exist from the start |
| Loops UI (5 loops, pick a dawn, echoes) | Vertical slice | 25 | mid | |
| Journal, blueprints | Vertical slice | 30 | mid | |
| Learning horde (counter-types) | Vertical slice | 20 | mid | |
| Scripted "Ask her" advisor | Vertical slice | 40 | mid | Plus your writing time |
| Cure research, clue chain, seeded cure, two endings | Minimum release | 70 + writing 60 | high | Section 9.1 |
| Nuclear tier (U, RTG, launcher, fallout) | Minimum release | 30 | high | |
| 8 zombie types, 6 night events | Minimum release | 60 | high | |
| Menus, settings, accessibility, controller | Minimum release | 50 | mid | |
| Steam: page, achievements, leaderboards, cloud, demo | Minimum release | 40 | mid | |
| Daily seed | Minimum release | 15 | low | |
| Fine-tuned local LLM wife (core feature) | Vertical slice, then release | 100–140 | **high** | Section 8.4 |
| Android + iOS port | Rejected | — | — | Windows only (Yash, 2026-10-24) |
| Blueprint share codes | Post-launch | 15 | low | |
| Full reality simulation, per-pixel physics, free-form CAD printer, multiplayer, open map | **Rejected** | — | — | Not solo-buildable |

**Totals (estimate):** prototype ~250 h, vertical slice +~200 h, minimum release +~550 h (including compounds, gases and weather) of code and writing, plus your art at roughly 250–450 h. That is about 1,250–1,450 h in total, or roughly 2–2.5 years at 1.5 h/day. The single biggest lever is holding the caps (20 elements, about 35 compounds, 14 components) until release.

**Money (approximate, check current prices):** Steam Direct fee US$100 per game (about INR 8,500–9,000). **That uses almost all of the INR 10,000 budget, leaving about INR 1,000–1,500.** Everything else in this plan is free (Godot, GUT, GodotSteam, NobodyWho, Qwen3 weights).

---

## 13. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Scope creep from "create anything" | high | fatal | Hard caps (20 elements, ~35 compounds, 14 components) until release; every addition must create a new decision |
| Cure too obscure, unfair, or spoiled online | high | high | Seeded cure, fairness test, acceptance ending, score and persistence (section 9) |
| Sandbox has a dominant build | high | high | Learning horde, zombie resistances, nuclear fallout cost |
| LLM hallucinates or says something harmful | high (if used) | high | Recipe checks by tool call, lucidity tied to her health, scripted clue lines, output filter, test gate |
| AI backlash in reviews | medium | medium | Scripted default; LLM optional and disclosed clearly |
| Saturated genre; Project Tomorrow and Thronefall-likes | medium | high | Lead marketing with inventions and her, not "base defence" |
| Performance (horde + field grid) on low-end PCs | medium | medium | Prototype gate at 300 zombies; GDExtension only if profiling demands |
| Effects hide danger | medium | high | Readability rule; greyscale test of screenshots |
| Solo art time (you draw everything) | high | high | Composed devices, palette swaps, rotation; art budget per slice |
| Dark premise (wife dies, "made to fail") feels bleak | medium | medium | Tone guide; warmth in her lines; acceptance ending |
| Steam fee uses nearly all the budget | certain | medium | No paid tools; anything paid waits for revenue |

---

## 14. Stages and go/no-go criteria

Stages follow the project rules; each waits for your approval.

**Stage 0. Approve this plan** (now). Go: you approve the bounded sandbox, the wife approach, the loop model and the acceptance ending, or you change them.

**Stage 1. Paper design (2 weeks, about 20 h).** Element table with numbers, 14 components, damage formulas, 20 example devices on paper, 6 zombie types with resistances. Go: at least 12 of the 20 devices have a distinct tactical job (not just "more damage"), and no single device beats every zombie type.

**Stage 2. Ugly prototype (about 250 h, greybox, CC0 placeholders).** One map, 4 elements, 6 components, fire and electric only, 3 zombie types, wife needs, snapshots, 10 nights. Go/no-go:
- 5 testers who are not friends of the game: at least 3 build a device we did not script, and median "fun" is 4/5 or better.
- At least 3 of 5 say "one more night" unprompted or keep playing past the test time.
- 300 zombies plus the field grid at 60 fps on a mid-range reference PC (not your RX 9070 XT PC).
- No dominant device: none gets more than 50% of kills across all testers' nights.
No-go means rework the system or stop, not more content.

**Stage 2b. Wife test (parallel, about 40 h).** First LoRA fine-tune against the revised test in section 8.4.

**Stage 3. Vertical slice + Steam page (about 200 h code, art starts in earnest).** Your art for the slice list, loops UI, journal, learning horde, "Ask her". Steam page live with a trailer. Go: about 3,000 wishlists within 3 months of the page going live, and a demo with median playtime over 45 minutes. (For calibration: Project Tomorrow reached 21k from a demo, but it is an outlier; 15k wishlists before launch remains the release gate.)

**Stage 4. Production → Early Access or 1.0.** Go: 15,000 wishlists, Stage 2 metrics hold with 20+ strangers, no crash in a 3-hour soak.

**Other platforms:** none planned; the game is Windows only (Yash, 2026-10-24).

---

## 15. What happens to the old work (nothing is deleted yet)

You asked to delete everything. I have not deleted anything. I propose archiving instead, because it costs nothing and the setup work is reusable:

- **Repository, merged on main:** `ASSET_REGISTER.md`, `DECISION_LOG.md`, `research/` (Stage A report, research log, Stage A review). Proposal: move them to `archive/v0-cabin/` in a later PR.
- **Open PRs:** #2 (Stage B design), #4 (Stage C experiments), #5 (combat toy), #6 (art direction and look test). Proposal: tag each branch head as `archive/v0-<name>` and close the PRs without merging.
- **PR #3 (Godot skeleton, tests, CI, export presets):** proposal: keep and merge it, since it does not depend on the old design.
- **Project files:** `research/`, `stage_c/`, `stage_d/`, `art_direction/`. Proposal: move into `archive/` in the project files.
- **Project memory:** the coordinator is updating it so old decisions are marked superseded.

Real deletion only happens if you confirm a list like this one.

---

## 16. Open questions for Yash (the plan assumes the defaults)

1. Decided: the fine-tuned LLM is the wife. Base model Qwen3 1.7B or 4B? *Default: choose by the wife test.*
2. Accept the bounded sandbox (20 elements, ~35 compounds, 14 components, rules) instead of "anything"? *Default: yes.*
3. Big weapons can hurt your own base and her? *Default: yes, through fallout and fire.*
4. Replaying a loop starts from any dawn in it, with limited echoes? *Default: yes.*
5. Cure values seeded per save so wikis can't spoil it, or one fixed answer for everyone? *Default: seeded.*
6. Keep the time-loop fiction, or make loops purely a game feature? *Default: keep it light: she remembers.*

---

## Sources (all read 2026-10-24)

- Project Tomorrow, Steam store page: https://store.steampowered.com/app/4402200/
- TechTimes, "Project Tomorrow demo draws 21,000 wishlists…", 2026-09-07: https://www.techtimes.com/articles/326864/20260907/project-tomorrow-demo-draws-21000-wishlists-solo-dev-ships-two-overhauls-three-weeks.htm
- GamesMarket, Thronefall passes one million copies: https://www.gamesmarket.global/indie-hit-thronefall-sells-over-one-million-copies-588b03986d04328e71544cbcb1d1b454/
- WN Hub, Thronefall first two months: https://wnhub.io/news/indie/item-42153
- GameDiscover, Thronefall deep dive: https://newsletter.gamediscover.co/p/deep-dive-how-thronefall-went-minimal
- Raijin estimates (third-party models), Thronefall and They Are Billions, data as of 2026-07-22: https://raijin.gg/app/2239150/Thronefall , https://raijin.gg/app/644930/They_Are_Billions
- They Are Billions, Wikipedia: https://en.wikipedia.org/wiki/They_Are_Billions
- NobodyWho: https://github.com/nobodywho-ooo/nobodywho
- Godot Llama: https://godotengine.org/asset-library/asset/4810 ; godot-llama-cpp: https://github.com/hazelnutcloud/godot-llama-cpp
- Qwen3-0.6B on Qualcomm AI Hub: https://aihub.qualcomm.com/mobile/models/qwen3_0_6b
- Steamworks Content Survey: https://partner.steamgames.com/doc/gettingstarted/contentsurvey ; 80.lv coverage: https://80.lv/articles/steam-introduces-new-rules-for-games-with-generative-ai/
