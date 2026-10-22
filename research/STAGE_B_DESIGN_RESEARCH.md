# Stage B: Design Research

Stage B (design research) · Prepared 22 October 2026 · Status: **draft for Yash's approval; Stage C does not start until Yash approves**

Inputs: [CONCEPT_VALIDATION_REPORT.md](CONCEPT_VALIDATION_REPORT.md), [STAGE_A_REVIEW.md](STAGE_A_REVIEW.md), [../DECISION_LOG.md](../DECISION_LOG.md) (D1–D7). Outputs: this report, [../GAME_VISION.md](../GAME_VISION.md) and [../GAME_DESIGN_DOCUMENT.md](../GAME_DESIGN_DOCUMENT.md) v0. New sources are S43–S53 in [RESEARCH_LOG.md](RESEARCH_LOG.md).

Labels as in Stage A: **Fact** (cited, dated), **Estimate** (my number, reasoning shown), **Recommendation** (my judgement; you can overrule it). Nothing here has been built or run in Godot.

---

## Summary

**Verdict: go for Stage C (tech and pipeline validation), on your approval of the GDD v0 core loop and the two proposals marked ⚑ below.**

Stage B turned the four approved systems into one loop with a single rule at its centre: **the dead go to the loudest thing in the house.** The chamber hums all the time. The player is louder only when shooting. So every night asks one question over and over: *do I make noise to pull them off her, or stay quiet and let the traps work?* Weapons (loud vs quiet), traps (lures), experiments (mutations that change your noise) and the story (the chamber's hum is what keeps her alive and what draws them) all hang off that rule. That gives each system a reason to exist without adding a fifth.

Two proposals change something Stage A wrote down, so they need your yes:

- ⚑ **P1. The day is an action budget, not a timer.** Four "hours" to spend on repair, traps, weapon work, an experiment, or reading her notes. Stage A said "timed day phase". An action budget creates the same pressure, makes every action a choice, is cheaper to build and test, and works on touch without changes.
- ⚑ **P2. A run is won by reaching the last dawn with enough findings to attempt the cure.** Surviving five nights without the findings ends the run in a failed attempt (a story fragment, then the loop resets). This makes knowledge the win condition, as D3 intends, and gates the single ending behind about five key findings collected across loops.

Settled during Stage B: game one is cut to 600–900 h (D6); "$1M" means net revenue as the store dashboards report it (D7); and Windows, Android and iOS are all committed platforms, with Steam first, then Android and iOS together, and iOS build work parked until the port (D8).

---

## 1. What the closest games teach (design lessons, not features to copy)

Review counts are English-language Steam reviews read from Steam's API on 22 Oct 2026 (fact). Several prices were on sale that day, so base prices are given.

| Game | Structure (fact) | Signals (fact) | Lesson we take | What we don't take |
|---|---|---|---|---|
| **Darkwood** (Acid Wizard, 3 people) | Scavenge and repair by day; at night you can't leave the hideout and hold it with barricades and traps until morning [S43] | $19.99 base; 94% of 11,689 reviews [S43] | **Night dread comes from not seeing.** Fog and limited vision do more than enemy count. Repairing the same hideout each day makes it feel like *your* place | Procedural map, scavenging trips, top-down view (excluded by the brief and D1) |
| **Kingdom Two Crowns** (side-on) | The kingdom sits in the middle; the Greed attack from both sides at night, stronger each night [S44] | $19.99 base; 89% of 13,596 reviews [S44] | **A side-on defence game can carry tension with very simple verbs.** Two flanks plus a centre is readable at a glance. Players criticise threats that aren't signposted [S44] | Economy/recruiting, scrolling world |
| **Dome Keeper** | Mine, then defend the dome when the wave timer runs out | 93% of 13,712 reviews [S11] | **The defence phase is what makes the prep phase meaningful.** The designer says the battle's time limit is what gives mining decisions weight [S45]. A reviewer notes the optimal build repeats [S45] | Mining. Also a warning: if one build is best, replay dies |
| **Thronefall** (2 people) | Build by day, defend by night; you lose only when the castle falls [S46] | 1M+ copies [S13] | **Strip a genre to its decisions.** The team picks projects "small enough to be realized in high quality" for their size [S46] | Strategy-layer economy |
| **Barricadez** (side-on) | Gather underground, build traps, defend a "cradle" at night [S52] | $18.99; 20 of 22 reviews positive [S52] | **The closest premise on Steam got almost no attention.** Defend-the-helpless-thing isn't the hook by itself; presentation and a clear GIF are | — |
| **Zombie Night Terror** (side-on) | Cross-section levels; you direct the horde | $12.99; 91% of 1,390 reviews [S52] | Side-on cross-sections of buildings with zombies read well in GIFs and at small sizes | Puzzle/RTS control |
| **Outer Wilds** | Progress is only knowledge; a ship log records what you've learned [S47] | — | **Make the persistent knowledge visible as a place.** Our version: notes pinned to the lab wall, in the protagonist's handwriting, that survive the reset | Exploration scale |
| **Hades** | Story advances on death | 21,000+ voiced lines, 300k+ words [S49] | Reactive story works, but its volume is out of reach. **Cap stays at ~20 fragments** (D2 amendment); each fragment is triggered by a finding, not by death count | Voiced dialogue, relationship systems |
| **Limbo** | Monochrome silhouettes, lighting, film grain; shadows hide traps [S48] | 92% of 21,144 reviews; Best Visual Art, GDCA 2011 [S48] | **Silhouette plus light can win art awards with no painted detail.** It also shows the risk: darkness that hides danger. We keep danger lit (section 5) | Its look, puzzle structure, characters |

**Gap check (estimate, weak):** I found no side-on, cross-section, horde-*shooter* about defending one person on Steam. Searches surfaced side-on defence (Kingdom, Barricadez) and top-down shooters with barricades [S52]. Absence in a search is not proof of an open niche, and Barricadez shows a near-identical premise can sell almost nothing. The hook must land visually.

## 2. The central rule: noise

**Recommendation: build the whole loop on one targeting rule.**

> Each infected chooses the loudest sound it can hear, weighted by distance. The chamber hums all the time. Shots, explosions, breaking barricades and lures make short, loud pulses. Some infected ignore noise.

**Why noise:** it links all four systems with one number, and players already understand it. They Are Billions players describe the same pattern (louder units draw more zombies; zombies hitting walls make noise that pulls more in) [S50, community observation, not a published formula]. In our game it also carries the premise: the machine keeping her alive is what calls them.

**The decision it creates (every few seconds at night):**

| Choice | Benefit | Cost |
|---|---|---|
| Fire the loud rifle | High damage; pulls the crowd away from the chamber toward you | You're surrounded; the crowd may cross a floor you didn't trap |
| Melee or the quiet weapon | Crowd stays on its path to the chamber, into your traps | Chamber takes hits if traps fail |
| Trigger a lure trap | Pulls a crowd to a trapped stairwell | One use per night; wrong placement pulls them through a weak floor |

**Implementation cost (estimate):** 6–10 h. Each sound source is a node with a loudness and a radius; each infected re-evaluates its target about twice a second; no physics. Testing burden: low to medium (a debug overlay showing each infected's target). **Classification: prototype.** It is in the combat toy from day one, because if this rule doesn't produce the decision above, the design has to change before anything else is built.

**Edge cases to test:** two equal sources (tie-break to nearer); the player standing next to the chamber (the two sum, so enemies converge on both: intended); noise through floors (one floor of falloff per floor crossed, so noise reaches neighbouring floors but not the whole house).

## 3. Combat in a side-on cross-section

**The arena (recommendation):** one building, three floors plus a roof, with the chamber on the middle floor. Entry points are windows at each end of each floor, the front door, a roof hatch and a basement grate, which gives 8 entries but only 3–4 opened in any one night. Two stairwells connect the floors. The generator is in the basement.

**Movement and aim (recommendation):** left/right along a floor; up/down at a stairwell; free aim with the mouse or right stick, but most shots are horizontal, along a floor. A short dodge with invulnerability frames. No jumping in the prototype; it adds platforming that has nothing to do with defending her.

**Enemy pathing (fact plus recommendation):** Godot's 2D navigation handles flat ground, but paths break at ledges and level changes without hand-placed NavLink2D links; a community A* platformer tool exists (MIT, Godot 4.4) but warns it may not behave as expected in other projects [S51]. **Recommendation:** enemies don't jump. They walk along floors and use stairs only, following a small **authored waypoint graph** (about 20–30 nodes: entries, stair tops and bottoms, barricades, the chamber). Godot's built-in `AStar2D` searches it. That turns the pathing risk from Stage A section 11 into a 4–6 h task. Stage C experiment C4 checks it.

**Enemy count (D1 amendment):** 30–60 on screen. Side-on crowds stack and become unreadable, so the design uses fewer, more distinct enemies.

**Readability rules (from the brief: effects must never obscure danger):**

1. Every enemy has a unique silhouette and is lit by a thin rim light. Fog sits behind the gameplay plane, never in front of it.
2. The chamber is always the brightest object on screen.
3. Every attack that can hit the chamber has a 0.5 s tell (sound and pose).
4. Off-screen or in-wall threats show an edge marker on the floor where they'll enter.

## 4. Enemies for game one (3 plus a boss night)

Each enemy exists only because it creates a new decision (project rule).

| Enemy | Behaviour | The decision it forces | Game one | Prototype |
|---|---|---|---|---|
| **Shambler** | Slow, comes in groups, follows noise | Where do I pull the crowd? Loud or quiet? | Yes | Combat toy |
| **Runner** | Fast, **ignores noise**, goes straight for the chamber, drops the sample used in experiments | Do I leave my position to intercept, or trust a trap on its route? | Yes | Combat toy |
| **Brute** | Slow, heavy, breaks barricades in a few hits; staggered by heavy melee | Which barricade do I repair today? Do I meet it with melee (quiet, risky)? | Yes | Loop prototype |
| **Wailer** *(candidate 4th)* | Stops and screams, a noise pulse that redirects every shambler nearby | Target priority: kill it before it redirects the crowd onto her | Slice decides | No |
| **Boss night** | Power failure: the chamber goes cold and silent for 60 s, then the generator restarts at double volume | Hold her steady through the restart; one authored set piece | Yes | No |

**Rejected:** exploders, ranged spitters, flyers. Each adds new collision or projectile systems and none creates a decision the four above don't already create.

## 5. Weapons and traps: one tag system

**Weapons (recommendation, refining Stage A section 9):**

- **Two frames:** a melee tool and a firearm. Three slots each: **mechanism** (rate, reliability), **payload** (damage type), **mod** (one modifier).
- **Each component carries at most one tag.** Five tags for game one: `loud`, `quiet`, `shock`, `fire`, `cold`. `infected` is held back as a mutation-only effect (section 6) rather than a weapon tag.
- **About 10–12 components** at release (D6). Each must change behaviour, not just a number. Examples: *suppressor* (`quiet`, −30% damage); *slug load* (`loud`, knockback that clears a stairwell); *coil* (`shock`, chains along wet floors); *tar rounds* (`fire`, leaves a burning patch that also burns barricades).
- **Tags interact with the world, not with each other.** Shock + water (a burst pipe on one floor) chains. Fire + barricades burns your own defences. Cold slows the infected but drains chamber power when used near it. Five tags × about five world states is about 25 interactions to test (estimate).

**Traps (recommendation):** placed during the day at **authored sockets** (stair tops, doorways, window frames, about 10 sockets). Four or five at release: *lure* (radio: noise pulse), *spike barricade*, *shock wire*, *oil spill* (`fire`), *cold vent* (`cold`). Traps share tags with weapons, so one interaction table covers both.

## 6. Self-experimentation (research plus infection powers)

**Recommendation:**

- Runners and the brute drop **samples**. In the day you may spend one action to run **one experiment**, choosing from two or three.
- Each experiment shows a **known effect** and a hidden **side effect** revealed when you take it. Both last until the loop resets (mutations reset, D3).
- Every experiment also yields a **finding**, which persists: a fact about the infected, a recipe that unlocks a component, or a story fragment. Findings go on the **lab wall** (section 7).
- 6–8 experiments at release (D6).

Examples (placeholder; numbers to be tuned in the prototype):

| Experiment | Known effect | Side effect | Finding (persists) |
|---|---|---|---|
| Runner serum | Faster dodge recovery | You hum faintly: shamblers can hear you even when you're quiet | "Runners track heat, not sound" (unlocks cold vent) |
| Brute marrow | Heavy melee staggers brutes | −20% max health | Recipe: slug load |
| Cold adaptation | See infected through one wall | The chamber loses 5% power per night | Fragment: why she chose the chamber |

**The rule (from D2):** cause and effect must be clear because the player chose the experiment. No hidden corruption meter. No infection clock in the prototype.

## 7. The loop, persistence and the fiction

**Run structure (recommendation):** 5 nights. Day: 4 action "hours" (⚑ P1). Night: 3–5 minutes of real-time defence, ending at dawn. A run lasts **20–35 minutes** (estimate: 5 × (1–2 min day + 3–5 min night)).

**Winning a run (⚑ P2):** reach the last dawn and, if you hold enough key findings, attempt the cure. Game one has **about five key findings**, so the first successful attempt should come around run 6–10, which puts the ending at **about 3–5 hours** (estimate). Players who want more get harder nights and the remaining findings.

**Why knowledge survives the reset (Stage A open question 6; recommendation):** tie it to the infection, and make it physical. Each loop the protagonist finds the lab wall already covered in notes, in the protagonist's own handwriting, with no memory of writing them. Leave the mechanism ambiguous; the story never explains the loop in technical terms. This doubles as the persistent-progress UI, which is cheaper than a separate menu.

**The spouse (Stage A open question 7; recommendation):** she was the researcher. The cure work is *hers*; the protagonist is following her notes and recordings, and she chose to go into the chamber. That gives her agency and a voice without dialogue trees, and puts her at the centre of the research system. **Never a mechanic that harms her**, and she is never an object to be solved. The single ending must resolve the relationship whether or not the cure works.

**Story budget:** about 20 fragments (D2 amendment), each 50–150 words of her notes or the protagonist's, triggered by findings. Total about 2,000–3,000 words (estimate). No voice acting.

## 8. Art direction research

**Recommendation (within D4):** take three principles from Limbo [S48] and one from the Silksong *feel*, and none of their assets or style:

1. **Value hierarchy first.** Background darkest and foggiest, gameplay plane mid-value with rim light, chamber brightest. Test in greyscale before any colour.
2. **Three depth layers:** far (the street and sky through the walls), gameplay (the cross-section), near (foreground silhouettes of pipes and debris, kept off the gameplay plane).
3. **Grain, fog and light are the detail.** They're shaders and particles, which suits a programmer and scales down with quality presets for mobile.
4. **One accent colour per meaning:** cold white-blue for the chamber and her, sickly amber for infection and mutations. Everything else is near-monochrome.

**Artist quotes (Stage A asked for three):** I can't contact artists. Published benchmarks: Indian freelance 2D game artists at about **₹500–1,500 an hour** [S53], and a studio's price list of $100–1,000 per 2D character design and $500–1,000 for basic rigging [S53, marketing content]. **Estimate:** capsule art plus one cross-section background plus four rig-ready characters is about 60–120 artist-hours, so **₹30,000–1,80,000** at those rates. That's lower than Stage A's ₹3–10 lakh estimate, which assumed fuller painted backgrounds and Western rates. Only needed if the look test fails; I'd collect real quotes then.

## 9. Feature cost cards and classification

Hours are estimates for a first-time game developer, art and audio excluded unless stated.

| Feature | Implementation | Testing | Content | Impact on core | Class |
|---|---|---|---|---|---|
| Noise targeting rule | 6–10 h | Low–medium | None | **Central** | Prototype |
| Waypoint-graph pathing (floors + stairs) | 4–6 h | Medium | 1 graph per arena | Required | Prototype |
| Player move, aim, dodge, 2 weapons | 15–25 h | Medium (feel) | 2 weapons | Required | Prototype |
| Chamber with health and hum | 3–5 h | Low | 1 object | **Central** | Prototype |
| Shambler, runner | 8–12 h | Medium | 2 enemies | High | Prototype |
| Brute + barricades | 8–12 h | Medium | 1 enemy, barricades | High | Loop prototype |
| Day action budget (⚑ P1) | 6–10 h | Low | Action list | High | Loop prototype |
| 1 trap (lure) at sockets | 5–8 h | Medium | 1 trap | High | Loop prototype |
| 1 weapon slot, 2 options (loud/quiet) | 8–12 h | Medium | 2 components | High | Loop prototype |
| 1 experiment with finding | 6–10 h | Low | 1 experiment | Medium–high | Loop prototype |
| Reset keeping one unlock; lab wall (basic) | 8–12 h | Medium (save/reset) | — | High | Loop prototype |
| Full tag system, 10–12 components | 40–70 h | Medium–high | 10–12 components | High | Vertical slice → release |
| 4–5 traps | 15–25 h | Medium | 4–5 traps | High | Slice (3) → release |
| 6–8 experiments | 20–30 h | Medium | 6–8 experiments | Medium–high | Slice (3) → release |
| Arena state changes (burst pipe, power failure, broken stairs) | 15–25 h | Medium–high | 3 states | High (anti-repetition) | Vertical slice |
| Win by findings (⚑ P2) + one ending | 10–15 h + writing | Medium | ~5 key findings | High | Vertical slice |
| ~20 story fragments | 30–50 h writing | Low | ~2,500 words | Medium | Slice (5) → release |
| Wailer (4th enemy) | 6–10 h | Medium | 1 enemy | Medium | Slice decides |
| Boss night (power failure) | 10–15 h | Medium | 1 set piece | Medium–high | Release |
| Gamepad + Steam Deck | 6–10 h | Medium | Prompts | Medium | Vertical slice |
| Touch controls (aim assist toward chamber threats) | 30–50 h | High | Touch UI | Mobile only | Post-launch port |
| Android + iOS port (D8) | 200–350 h | High | Store assets, touch UI | Second channel | Post-launch port |
| Infection clock | 5–8 h | Medium | — | Unknown | Rejected unless runs lack pressure |
| Scavenging trips / map outside the house | 60+ h | High | Locations | Splits focus | **Rejected** |
| Free trap placement | 15–25 h | High | — | Low over sockets | **Rejected** |
| Jumping / platforming | 10–20 h | Medium | — | Off-premise | **Rejected** |
| Second arena | 80–150 h | High | Art, graph, balance | Medium | Post-launch |
| Voiced dialogue, dialogue trees | — | — | — | — | **Rejected** (brief) |

**Game one hour budget (estimate, must fit D6's 600–900 h):** core systems 120–160; content (enemies, components, traps, experiments, nights) 120–180; art 150–220; audio 30–50; writing 30–50; UI, save and settings 40–60; Steam integration and builds 20–30; QA and polish 60–90; store page, trailer and demo 40–60. **Total 610–900 h.** The Android and iOS port (200–350 h, D8) comes after the Steam launch and sits outside this budget. The tight items are art and marketing. If the look test shows art will take longer, content is what gets cut, not polish.

## 10. Design risks found in Stage B

| Risk | Likelihood | Impact | Mitigation | Checked by |
|---|---|---|---|---|
| The noise rule creates no real choice (one option always best) | Medium | **Critical** | Debug overlay; log loud vs quiet use; tune pulse size and radius | Combat toy gate |
| Side-on fights feel cramped or one-dimensional | Medium | High | Two stairwells, 3–4 open entries a night, dodge; fallback to top-down (D1) | Combat toy gate |
| One build dominates (Dome Keeper's repeat-build problem [S45]) | Medium | High | Tags tied to world states that change per night; no strictly better components | Slice playtests |
| Darkness hides danger | Medium | High | Readability rules 1–4 (section 3); greyscale test | Look test |
| The spouse reads as a prop | Medium | High | She's the researcher with her own notes and choice; outside readers check fragments | Slice |
| Five key findings feel like grinding | Medium | Medium | Each finding comes from a choice, not a repeat; tune to ending at run 6–10 | Loop prototype |
| Near-identical premise already failed commercially (Barricadez [S52]) | — | High | Hook test with a GIF in Stage C before the prototype grows | Stage C hook test |

## 11. Stage C plan: tech and pipeline validation

Stage C answers technical questions with small, labelled experiments. No content beyond what each test needs. Estimated **30–45 h** in total. The Godot tooling thread is setting up the project skeleton, CI and export presets separately.

| # | Experiment | Time (est.) | Pass if | If it fails |
|---|---|---|---|---|
| C1 | Pin Godot 4.7.2; typed GDScript skeleton; InputMap actions for mouse, gamepad and touch; Windows and Android debug exports run (iOS export parked per D8) | 4–6 h | Both exports launch; input actions drive a test character on each | Fix toolchain before anything else |
| C2 | **Look test** (D4): chamber, one silhouette enemy, fog and light on one screen, with high and low quality presets | 10–15 h | Yash and 3 others judge it "would click on the capsule"; passes the greyscale readability check | Artist becomes a slice precondition (D4) |
| C3 | Performance: 60 enemies (headroom to 100) + 2D lights + fog | 4–6 h | 60 fps on the reference PC; 30 fps on the reference Android phone at the low preset; no throttling below 30 fps over 20 min | Batch enemies (MultiMesh), cut light count, simplify fog |
| C4 | Waypoint-graph pathing across three floors and two stairwells, with the noise rule driving targets | 4–6 h | 60 agents path correctly with no stuck agents in a 10-minute soak; under 2 ms a frame | Simplify the building (two floors, one stairwell) |
| C5 | GodotSteam for 4.7 (Codeberg build [S24]): one achievement and a cloud save | 2–4 h | Both work in a test app | Ship without Steam features at first; revisit before the slice |
| C6 | Hook test: mock capsule, one-line pitch, a GIF from C2 | 3–5 h | At least half of 10+ strangers can repeat the hook in a sentence | Rework the image or pitch before the combat toy |

**Needed from you for C3:** the reference PC (your PC's CPU, GPU and RAM, or a named mid-range spec) and an Android phone to test on.

## 12. Go/no-go for Stage B → Stage C

| Criterion | Status |
|---|---|
| Scope and "$1M" definition settled | **Met** (D6, D7) |
| Core loop states one decision per phase (day: spend 4 hours; night: loud or quiet, where to pull them) | **Met on paper** (GDD sections 2–4) |
| Every system ties to the central rule and to the chamber | **Met on paper** (section 2) |
| Game-one content list fits 600–900 h | **Met as an estimate** (section 9; tight on art) |
| Prototype features have acceptance criteria | **Met** (GDD section 13; Stage A section 13) |
| Stage C experiments have pass/fail criteria | **Met** (section 11) |
| Yash approves the GDD v0 core loop, P1 and P2 | **Waiting for Yash** |

**Recommendation: GO for Stage C** once you approve. If you reject P1 or P2, I'll revise the GDD and keep Stage C unchanged, since none of its experiments depend on them.
