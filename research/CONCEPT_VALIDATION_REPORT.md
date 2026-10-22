# Concept Validation and Feasibility Report

Stage A (concept validation) · Prepared 22 October 2026 · **Revised 22 October 2026** after the adversarial review in [STAGE_A_REVIEW.md](STAGE_A_REVIEW.md) · Status: **five decisions approved by Yash; art path decided; ready for Stage B on Yash's go-ahead**

Sources are numbered `[S1]` and listed with access dates in [RESEARCH_LOG.md](RESEARCH_LOG.md). Every figure in this report is labelled as one of:

- **Fact**: verified from a cited source on the date shown.
- **Estimate**: my own number, with the reasoning shown. Treat it as a planning input, not a prediction.
- **Recommendation**: my judgement. You can overrule it.

Approved decisions are listed at the end. Everything else is a recommendation until you approve it.

**What changed in this revision:** corrected the Google Play fee, the Steam launch-discount rule and the review-count labels; added Steam base rates and a typical-outcome revenue row; defined "$1M"; raised the wishlist gate; fixed the production-time contradiction; set enemy counts for the side-on camera; split the prototype; cut the minimum release; and rewrote the art plan now that Yash has said he can't draw.

---

## Summary

**Verdict: conditional go.** Proceed to design research and a greybox prototype. Do not start production, buy assets or open a Steam page yet.

The emotional frame is strong and can do mechanical work: you defend the one room that keeps your spouse alive. The genre around it is saturated (zombies, horde survival), and the brief proposes seven signature systems for a solo developer with 1–2 hours a day. That is roughly three too many. What survives will depend on four things:

1. **Cut the system count.** Merge infection powers into the research system ("self-experimentation"), keep modular weapons small and tag-based, and make the time loop mostly a framing and persistence layer.
2. **Pick a camera that sells the identity.** My lead recommendation is a side-on cross-section of a single building, which no top-down survivors-like can copy at a glance. A top-down view is the fallback.
3. **Prove it in small steps.** A look test (10–15 h), then a combat toy (15–25 h), then a loop prototype, each with its own gate (section 13).
4. **Reset the money expectations.** The median Steam game earns about $1,100 over its lifetime [S41]. US$1M from a first game is a top-1–3% outcome. The ₹10,000 budget is almost exactly the Steam Direct fee.
5. **Make game one smaller.** Cut the minimum release to about 600–900 hours (12–20 months at your pace) instead of 1,200–2,000 (section 15).
6. **Mobile as a port, not a launch platform.** Build every system so it can run on phones (input abstraction, scalable UI, a mobile performance budget), but ship on Windows and Steam first and port to Android and iOS after launch. Section 16A has the evidence.

---

## 1. The game, restated

A fixed-screen 2D horde-survival shooter. Each run is a sequence of nights. During the day you prepare: you modify weapons, place traps, and test samples taken from the infected. At night you hold one location against escalating hordes. The location contains a life-support chamber that keeps your infected spouse alive. You are infected too. When you die, or the chamber falls, the timeline resets to the first night. What you have learned (recipes, research findings, story revelations) carries over. Resources and raw power mostly do not.

The intended emotional core is devotion under hopeless odds, and the cost of trying again.

## 2. The most compelling aspect

**The chamber makes the fixed screen meaningful.** Most arena shooters never explain why you can't leave. Here the reason is the premise: the chamber can't be moved, so you stand and defend it. That ties together:

- **Fiction and structure.** One place, defended repeatedly, is exactly what a time loop and a fixed screen both need.
- **Stakes and the lose condition.** If the chamber falls, the night is lost. That gives the player a second health bar that is a person.
- **A possible core tension (suggestion).** If the chamber's generator noise or heat is what draws the dead, the thing keeping her alive also endangers her. That links noise, traps and lures to the story without extra systems.
- **Infection as power.** The protagonist's own infection mirrors the spouse's and is the source of abilities through self-experimentation (section 10). Using it as a run timer is **not** part of the prototype; revisit only if runs lack pressure.

This is the hook to test first. Everything else should serve it.

## 3. The weakest and most generic aspects

| Element | Why it's weak | Recommendation |
|---|---|---|
| **Zombies** | Among the most crowded themes on Steam. Players see "zombie wave shooter" on the capsule and stop reading. | Keep the infected, but make their look and behaviour specific to the cure fiction (for example, they're drawn by sound and cold). Never lead marketing with "zombies". |
| **Horde survival, fixed arena** | Brotato and other survivors-likes have set a US$4.99 price anchor [S3]. Low-effort entries get mixed reviews: The Horde Wants You Dead sits at Mixed (61% of 215 English reviews) at $9.99 [S10]. | Differentiate on the camera, the preparation and the chamber. Don't look like a survivors-like. |
| **Infection powers as a separate system** | A fourth progression track competing with weapons, traps and research. The brief itself asks whether it's essential. | **Merge it into research** as self-experimentation (section 10). |
| **Time-loop roguelite** | Standard since Hades, Returnal and Deathloop. A loop explains resets but doesn't sell anything on its own. | Use it for story and persistence. Each loop must change knowledge or story, not just stats. |
| **Saving an infected loved one** | Familiar from The Last of Us and many others. Twelve Minutes, a loop game about a husband and wife, was criticised for using the wife as a puzzle object and for its ending [S6]. | Write the spouse as a person with agency (logs, recordings, choices she made before the chamber). Never make harming her a mechanic. |
| **"Research toward a cure" premise** | Zombie Cure Lab, a game built entirely on curing zombies, sits at Mixed (65% of 219 English reviews) at $24.99 [S8]. The premise doesn't sell itself. | Research must change what you do on the next night, or it's a menu. |
| **Seven signature systems** | Each one needs content, balancing and testing. Solo, part-time, that guarantees shallow systems. | Cut to four: combat, preparation (weapons plus traps), self-experimentation, and the loop. |

## 4. Is it differentiated enough?

**Not yet.** The combination of systems is unusual on paper, but players don't buy combinations of systems. They buy what a capsule and a 10-second GIF communicate. As a feature list, this reads as "zombie roguelite shooter with crafting", which describes hundreds of games.

Differentiation can come from three places, in order of strength:

1. **The image.** A lit chamber in the middle of a dark, layered building lit by fog and light, with silhouettes coming through the walls. This needs the camera decision (section 8).
2. **The verb.** "Defend her" is different from "survive". The chamber should be the centre of every decision.
3. **The research twist.** You test cures on yourself, and the side effects become your powers.

**Test:** if a stranger can't repeat the hook in one sentence after seeing a GIF, it isn't differentiated (see the external tests in section 14).

## 5. Comparable games and lessons

All review counts and prices were taken from Steam on 22 October 2026 (facts). Review counts are **English-language, Steam-purchase** reviews, with all-language totals in brackets where they differ a lot. Sales figures come from the cited reports. **Caution:** almost every row is a hit, so these show what's possible, not what's likely. Section 16 uses base rates for that.

| Game | What it is | Signals | Lesson for us |
|---|---|---|---|
| **Dome Keeper** (Bippinbits, 2022, Godot) | Mine in the day, defend the dome against waves | $17.99; 93% of 11,830 reviews (22,721 all languages) [S11]; 1M *players* by Sept 2024 (players, not sales) [S5] | **Closest structural comparable.** A two-phase loop around one defended object, with a distinctive premise, from a tiny team, holds up near $18. |
| **Thronefall** (Grizzly Games, 2023, 2 people) | Build by day, defend by night | €12.99; 1M+ copies by Feb 2025 [S13] | Ruthless minimalism wins. Very few systems, all of them sharp. |
| **The Last Spell** (Ishtar Games) | Prepare by day, horde defence at night, roguelite meta | $24.99; 93% of 6,768 reviews (13,819 all languages) [S14]; 400k+ units across PC and consoles per publisher [S4] | Players want prep-then-horde, but this one was built by a studio. |
| **Brotato** (Blobfish, solo during development, Godot) | Fixed-arena survivors-like with a shop between waves | $4.99; 96% of 32,605 reviews (120,038 all languages) [S3]; over 1M copies (reported) [S2] | A solo developer can ship a fixed-arena wave game in Godot. Its replay value comes from **hundreds of items**, which we can't match. The genre is also priced low. |
| **Halls of Torment** (Godot) | Survivors-like | Under $5; 1M sales by Oct 2024 [S15] | Godot handles commercial horde games with large enemy counts. Like Brotato, it's priced in the $5 band we want to avoid. |
| **Into the Dead: Our Darkest Days** (PikPok, Early Access April 2025) | 2D side-view zombie shelter survival | $24.99; 93% of 3,230 reviews (10,078 all languages) [S16] | There's an audience for **atmospheric, grounded, side-view** zombie survival. |
| **Endoparasitic** (solo, Godot) | Infected protagonist, one strange core mechanic | $9.99; 93% of 1,802 reviews [S17] | One distinctive mechanic plus infection fiction works at $9.99 with a small scope. |
| **Zombie Cure Lab** (Thera Bytes) | Lab management to cure zombies | $24.99; 65% of 219 reviews (Mixed) [S8] | A cure premise isn't a hook by itself. Execution and depth decide reviews. |
| **Twelve Minutes** (Luís António, then a team of 5, ~9 years) | Time loop, husband and wife, one apartment | Metacritic 76 on PC; 53% of critics recommend on OpenCritic [S6] | One location plus a loop plus a spouse is a risky narrative. The ending and how the spouse is treated make or break it. |
| **Hades** (Supergiant) | Narrative delivered across deaths | 1M copies by Sept 2020 [S7] | Story that advances on death works, but its writing and voice budget is far out of reach. Copy the principle, not the scale. |
| **Yet Another Zombie Survivors** | Zombie horde with meta-progression | $14.99; 94% of 5,762 reviews (15,927 all languages) [S9] | Zombie horde games can hold $14.99 with enough content and polish. |

**Market context (facts):** About 19,000–20,500 games were released on Steam in 2025, depending on the tracker [S18][S19]. About 48.8% of them had 10 or fewer reviews when counted in mid-December 2025, which overstates the share because late releases had little time [S19]. The best-measured base rate is older: the median 2019 release earned about **$1,136 lifetime gross**, and 68% earned under $10,000 [S41]. Only 232 of 8,000+ games from the first half of 2024 reached 1,000 reviews, roughly $300k gross [S42]. Shipping is not the hard part; being noticed is.

## 6. Most promising target audience (hypothesis)

- **Primary:** players of prep-then-defend games such as Dome Keeper, Thronefall, The Last Spell and Brotato who want more meaningful choices between waves, and who value atmosphere. They buy small, replayable PC games at $10–18 and play on Steam Deck.
- **Secondary:** narrative-indie players drawn by an emotional premise. This group is smaller and less tolerant of repetitive combat, so they can't be the main target.
- **Not the audience:** survival-sim players looking for open worlds (Project Zomboid), or bullet-heaven players who want an auto-attack power fantasy at $5.

To validate: whether primary-audience players respond to the emotional framing, or treat it as flavour. See section 14.

## 7. Likely selling point (draft)

> *"Hold the house. Keep her frozen. Every death rewinds the night, but you remember what you learned."*

In shorter form: a horde-defence shooter where you protect the chamber keeping your infected spouse alive, and test the cure on yourself. This is a draft to test, not a slogan to commit to.

## 8. Risk of fixed-screen horde combat becoming repetitive

**Risk: high.** One screen, repeated across loops, is the most repetition-prone structure there is. Brotato gets away with it through build variety from a very large item pool. We can't afford that content volume.

**Mitigations, in order of value:**

1. **Change the enemy mix, not enemy health.** Each night adds one new pressure, such as a new archetype, a new entry point or a power failure.
2. **Let the arena change state.** Barricades break, rooms flood, power fails, and damage persists across nights within a run.
3. **Let research change the player's verbs.** Self-experiment results should open new ways to play, not just add +10% damage.
4. **Keep runs short.** Recommendation: 20–35 minutes, so repetition is felt across sessions rather than within one.
5. **Spatial choices.** Multiple entry points mean prep decisions are about where to defend.

**Camera decision (my top recommendation to test):**

| Option | For | Against |
|---|---|---|
| **A. Side-on cross-section of one building** (two or three floors, stairs, windows, roof; the chamber in the centre) | Delivers the layered depth, silhouettes and fog of the Hollow Knight reference; puts the chamber at the visual centre; natural chokepoints for traps; stands out on a capsule against thousands of top-down survivors-likes | Less proven for horde shooting; aiming and movement across floors need tuning; enemy pathing across floors is more complex |
| **B. Top-down or 3/4 single arena** | Proven to be fun for horde combat; easy 360° positioning and trap placement | Loses most of the layered-depth art identity; looks like the survivors-likes it competes with, and inherits their price anchor |

**Approved:** A is the lead hypothesis, tested first through the combat toy (section 13), with B as the fallback if A fails its gate after about 15–25 hours. Dome Keeper's side-on defence is supporting evidence that this view can carry a defend-the-object loop. A side view can't show a survivors-like crowd and stay readable, so **plan for about 30–60 enemies on screen (estimate)**, with heavier, more distinct enemies rather than swarms. Side-on aiming is mostly one-axis, which also makes touch controls far easier (section 16A).

## 9. Modular weapon engineering: solo feasibility

**Feasible if constrained. Infeasible as a free-form crafting system.** The testing load grows with the number of *interactions*, not the number of components.

**Recommended shape (for Stage B to refine):**

- **Two frames:** one melee and one ranged. Each has three slots, for example *mechanism*, *payload* and *mod*.
- **Components change stats** (damage, rate, spread, noise, reliability, cost) and carry **at most one tag**, such as `fire`, `shock`, `loud`, `silent`, `cold` or `infected`.
- **Synergies come from tags meeting the world, not from pairwise recipes.** Shock plus water makes a chain. Loud plus a lure trap pulls enemies. Cold slows the infected but drains the chamber's power. Six tags give at most 36 interactions to test. That is manageable, and authored the same way as Godot Resources.
- **Noise as the shared currency.** Loud weapons are strong but draw more of the horde toward you or toward the chamber. One tension sits across weapons, traps and story.
- **Discovery:** components are unlocked by research and persist across loops (section 10).

**Estimates:**

| Scope | Implementation | Testing | Content | Impact |
|---|---|---|---|---|
| Prototype: 1 frame, 1 slot, 2 options | ~8–12 h | Low | 2 components | Proves whether a trade-off is felt |
| Release (reduced game one): 2 frames × 3 slots, ~10–12 components, 5–6 tags | ~40–70 h (system plus content) | Medium (tag matrix plus per-component tests) | 10–12 components, each with art, audio and a short description | High, if each component changes behaviour |

## 10. Traps, experimentation, infection powers and the time loop

| System | Value | Complexity | Recommendation |
|---|---|---|---|
| **Traps** | **High.** They are the "prepare" half of the loop and the main source of spatial decisions. | Medium. Placement rules, triggers and AI interaction. | **Keep.** Placed during the day only, at authored sockets (doorways, stairs, windows) rather than free placement, which cuts edge cases. 1 trap in the prototype, 3 in the slice, 4–5 at release. Traps share the tag system with weapons. |
| **Experimentation (science)** | **High** for narrative, **medium** for gameplay unless it changes play. | High risk of menu sprawl. | **Keep, but small.** Samples from specific enemies feed one choice per day: two or three experiments, each with a known effect and one uncertain side effect. Failed experiments give a story fragment or a hint. No lab simulation. |
| **Infection powers (standalone)** | Medium | Medium-high: a fourth progression track | **Cut as a separate system. Merge into experimentation.** Self-tests grant mutations (for example, seeing infected through walls, or fewer attacks on you but more on the chamber) with a clear cost. The cause and effect are clear because the player chose the experiment. No corruption meter. |
| **Time loop and persistence** | **High** as framing and motivation | Medium. Save and reset logic, and it multiplies writing. | **Keep, with strict persistence.** Persists: recipes and components, research findings, story revelations, some changes in the spouse's condition. Resets: resources, the arena state, mutations. Trigger: death or loss of the chamber. Unlocked components **are** a form of power progression; balance for it openly. Story advances through discoveries, capped at **about 20 story fragments and one ending** for game one, because loop-reactive writing is the hidden fifth system. |

**Roguelite structure:** a light version is justified. The prototype uses a fixed **five nights**; release runs may range from three to seven, with a reset and knowledge-based meta-progression. A heavy upgrade tree that grinds stats would contradict the brief's rule that each loop must change knowledge or understanding.

**Narrative contradictions to settle in Stage B:**

- **Why does knowledge survive the reset?** The cleanest answer ties it to the infection (the strain affects the protagonist's memory and time perception), or leaves it deliberately ambiguous. A loop with no explanation sits awkwardly beside the "scientific uncertainty" theme.
- **Why not flee with her?** The chamber can't be moved and needs power. This is already strong.
- **What does the ending require?** It must resolve the relationship even if the cure is ambiguous. Twelve Minutes shows how badly a twist ending can land [S6].

## 11. Godot 4.x and GDScript: provisional assessment

**Recommendation: stay with Godot 4.7.x and statically typed GDScript. No engine switch is justified.** The current stable release is **4.7.2, from 18 August 2026** (fact) [S20].

| Criterion | Godot 4.7 | Unity 6 | GameMaker |
|---|---|---|---|
| Licence and cost | Free, MIT, no royalties | Personal is free up to $200k revenue plus funding; Pro is $2,310 a year per seat [S21] | Commercial use needs Professional at **$99.99** one-time [S22][S23] |
| Fixed-screen 2D fit | Strong. Dedicated 2D renderer, lights and normal maps, GPU particles, Skeleton2D for cutout animation | Good, but 2D is layered on a 3D engine; heavier for one person | Strong for 2D; weaker built-in lighting and tooling for this look |
| Shipped proof in our genre | Brotato, Dome Keeper, Halls of Torment, Endoparasitic [S2][S5][S15][S17] | Many | Many 2D hits |
| Solo iteration speed | Fast editor, small project | Slower editor and compile loop | Fast |
| AI-assisted workflow | **Known risk.** AI tools often produce Godot 3 syntax. Mitigate by pinning the version, insisting on typed Godot 4 code, and checking against the docs. | Most training data | Less training data |
| Steam integration | **Moderate plugin risk.** It depends on the community GodotSteam project. Its GitHub repo was archived on 20 Oct 2026 because it moved to Codeberg, where it's active, but it notes a Godot 4.7 breaking change [S24]. | Mature options | Built-in |

**Mobile export (fact):** Godot exports to Android and iOS. The Mobile renderer is the default on phones, and the Compatibility (OpenGL) renderer targets low-end devices; Forward+ is desktop-only. C# on Android and iOS is still experimental [S33; cited from the 4.5 docs, to re-check against 4.7]. That's another reason to stay with GDScript. iOS builds need a Mac with Xcode, per Godot's iOS export docs (not re-checked today).

**Things to answer with small Godot experiments in Stage C, not by debate:**

1. 60 enemies (with headroom to 100) plus 2D lights and fog at 60 fps on a mid-range PC, for camera A. Use simple movement, avoid one physics body per enemy, and fall back to batching if needed. Raise the target to 150–250 only if the camera falls back to B.
2. A side-on cross-section with stairs: is enemy pathing manageable?
3. Is the GodotSteam build for 4.7 healthy (achievements and cloud saves only)?
4. The same crowded scene on a mid-range Android phone with the Mobile renderer: frame rate, and heat after 20 minutes. Because the art style depends on light and fog (section 12), build quality presets into the look test from the start.

## 12. Production cost of hand-crafted atmospheric 2D art

**This is the largest feasibility risk after scope.** Hollow Knight was made by a three-person team. Its lead artist said that if he kept drawing everything for the sequel, it would "take 15 years to finish" [S25].

**Estimate of frame-by-frame animation load for a minimal release:** player with about 8 animations × about 8 frames = 64; five enemy types × five animations × about 8 frames = 200; weapons, traps and effects = 80–120. That's about 350–400 cleaned frames. At 20–45 minutes per frame for a competent artist, that's **about 120–300 hours for character animation alone**, before backgrounds. At 1–2 hours a day, that's 3–9 months of art time.

**Yash can't draw (22 Oct 2026), and wants art that feels as artistic as Silksong.** That bar comes from specialist hand-drawn and painted work, so it can't be met directly on ₹10,000 without an artist or AI art. **Approved path:** a light-led silhouette style that Yash builds himself, with an artist brought in if the look test falls short (below). Free public assets are used only as placeholders, and Yash will practise drawing alongside.

**Recommendation:**

- **Characters:** silhouette-led **cutout or skeletal animation** with Godot's Skeleton2D (free). Dark shapes with rim light and a few accent colours. Draw parts once and animate many times. Use frame-by-frame only for a few signature moments.
- **Backgrounds:** **one** building in three or four layers, built from shapes, gradients, fog, particles and light shaders rather than detailed painting. A fixed screen is a large art-cost *advantage*: one excellent scene instead of a world.
- **Look test (Stage C, before the prototype, ~10–15 h):** the chamber, one silhouette enemy, fog and light on one screen, with a mobile quality preset. **If it falls short of the bar, a freelance artist for the capsule, background and character parts becomes a precondition for the vertical slice**, and the budget has to rise. Get three quotes in Stage B so the cost is known.
- **Free assets:** only for greybox, UI and placeholder sound. Prefer CC0, never non-commercial licences, credit CC-BY, and log every file in ASSET_REGISTER. Replace them before anything public (capsule, trailer, slice), because packs are recognisable and their styles clash.
- **Tools:** Krita (free) for painting. Aseprite is optional (about $19.99 on Steam, or free if you compile it from source) and only needed if you go pixel art.
- **AI-generated art:** Steam requires disclosure of AI-generated content in the game and in marketing and store-page assets; coding assistants are exempt [S26]. Players also respond badly to visible AI art. **Recommendation:** use AI for code and documentation, and don't ship AI-generated art or music.

## 13. The smallest prototype that validates the core experience

Greybox only, with free placeholder assets. No final art and no story beyond placeholder text. It runs in two steps with a gate between them, after the look test in section 12.

**Step 1, combat toy (~15–25 h):** camera A, one floor plus stairs, the chamber, one weapon, two enemies. **Gate:** is holding the chamber fun for five minutes, and is it readable? If not, try camera B before going on.

**Step 2, loop prototype (only if step 1 passes). Contents:** one arena (cross-section A), the chamber with health, movement and aim and dodge, one melee and one ranged weapon, three enemies (shambler crowd; runner that targets the chamber; brute that breaks barricades), a run of five nights with a timed day phase, one trap (a noise lure), one weapon slot with two options (loud/strong vs. quiet/weak), one research choice (a runner sample leads to one of two self-tests), a reset on death that keeps one unlocked component, placeholder sound effects, and one lit fog layer for the performance test.

**Estimate:** 100–150 hours across both steps for a first-time game developer (the earlier 60–100 h was optimistic), or about 10–15 weeks at 10 hours a week.

**Acceptance criteria (proposed; to be fixed before testing):**

| Question | Pass if |
|---|---|
| Is combat responsive? | Input-to-action under 100 ms; at least 4 of 5 testers rate the feel 4/5 or higher |
| Are threats readable? | Testers correctly say what killed them in at least 80% of deaths |
| Does preparation matter? | Survival time or chamber health differs measurably between good and poor trap placement (logged), and testers place traps differently from each other |
| Does the weapon slot create a trade-off? | Testers can explain why they chose loud or quiet, and choices are split, not 90/10 |
| Do testers understand the loop uncoached? | At least 4 of 5 can explain day → night → reset after one run |
| Do they want another run? | At least 3 of 5 start another run without being asked |
| Performance | 60 fps with 60 enemies, lights and fog on a mid-range PC (the reference machine is to be named in Stage C); 30 fps on a mid-range Android phone at the low preset |

**If it fails:** diagnose the cause, change the design (camera first), and retest. Do not add content.

## 14. Key assumptions to test with external players

1. The chamber and spouse framing makes players care about defending, rather than skipping text. Measure whether they protect the chamber at a cost to themselves.
2. Preparation is fun on its own, not a chore between fights.
3. Side-view horde combat is satisfying, not cramped.
4. Self-experimentation feels like a gamble worth taking, not a menu.
5. Knowledge carried across a reset is enough motivation without stat grinding.
6. One screen stays interesting for 3+ runs.
7. **Hook test before the prototype (cheap):** post a mock capsule, one-line pitch and short greybox GIF in developer and player communities. Measure whether strangers can repeat the hook. This is a weak signal; use it only to catch a hook that doesn't land.

## 15. Preliminary budget and scope

**Budget (fact plus arithmetic):** at about ₹95.5 per US$ (25 Aug 2026 close) [S27], ₹10,000 is about **US$105**. The Steam Direct fee is **$100 per game** (about ₹9,550). It can be recouped after $1,000 of adjusted gross revenue [S28]. **The fee alone uses about 95% of the budget.**

| Item | Cost | Note |
|---|---|---|
| Steam Direct fee | $100 | Required |
| Godot, Krita, Audacity, Git and GitHub | Free | |
| Sound effects | Free | CC0 or self-recorded; log each in ASSET_REGISTER |
| Music | $0 within budget | Composing your own, CC-licensed music, or a budget increase |
| Art, audio or marketing contractors | Not possible within budget | |

**Recommendation:** keep the ₹10,000 for the Steam fee and spend nothing else until the vertical slice passes. Decide then whether to raise the budget for music and capsule art, which most affect a store page's conversion.

**Time and scope (estimate):** the original minimum commercial release (one arena with state changes, 5–6 enemies, 2 weapon frames with about 16–20 components, 6–8 traps, about 12 experiments, a 3–5 hour story arc across loops, 6–12 hours of replay) is about **1,200–2,000 hours for a solo developer shipping a first game**, art included. At 10–12 hours a week, that's **2–4 years**. This is my estimate, not sourced. It's the main reason to cut systems now.

**Recommended cut for game one (from the review):** about **600–900 hours, or 12–20 months** at your pace. Contents: 3–4 enemies plus one boss night, about 10–12 components, 4–5 traps, 6–8 experiments, about 20 story fragments and one ending, one arena with state changes. Price at $9.99–12.99. A finished small game gives the data and the following that game one is for. A 2,000-hour game risks giving neither. Stage B confirms the exact content list.

**Proposed exclusions** (in addition to the brief's defaults): free-to-play or ad-based mobile monetisation, a simultaneous PC and mobile launch, standalone infection powers, free-form trap placement, free-form crafting recipes, voiced dialogue, multiple arenas before release, base building beyond barricades and traps, and resource persistence across loops.

## 16. Commercial validation plan

### How Steam revenue reaches you (facts plus labelled assumptions)

- Valve takes **30%** of revenue up to $10M [S29].
- Refunds are possible within **14 days and under 2 hours** played [S30]. Short games are exposed to this.
- Regional pricing is set in 37 currencies. Discounts can't run within 30 days of release, or within 30 days after a launch discount [S31].
- US withholding tax under the India–US treaty is listed at **10% or 15%** depending on the royalty type [S32]. File a W-8BEN, and confirm with an Indian chartered accountant whether a foreign tax credit is available. Indian income tax then applies.
- **Assumptions (estimates):** lifetime realised price after discounts and regional pricing is about 60% of the base price; sales tax and VAT about 10%; refunds about 7%; Valve 30%. Net to you before income tax and withholding is about **35% of base price × units**. After 15% US withholding (if that rate applies; a CA must confirm), about **30%** reaches the bank, and Indian income tax comes out of that, so **take-home is about 20–25%** of headline gross.
- **Two kinds of "gross":** the table's headline gross is base price × units. Valve's "adjusted gross" and the base rates in [S41] are realised revenue, about 55–60% of headline. Compare like with like.

### Pricing scenarios (estimates, not forecasts)

Unit counts are hypothetical inputs to show the trade-off. The **typical** row reflects base rates [S41]: most games land there, and the "conservative" row is already above the median.

| Price | Outcome | Lifetime units | Headline gross (price × units) | Net to developer (~35%) |
|---|---|---|---|---|
| Any price in the band | **Typical (median-like)** | 150–400 | $1.5k–8k | **$0.5k–2.8k** |
| $9.99–12.99 (modelled at $9.99) | Conservative | 1,500 | $15k | **$5.2k** (~₹5 lakh) |
| | Moderate | 12,000 | $120k | **$42k** |
| | Optimistic | 60,000 | $599k | **$210k** |
| $14.99–16.99 (modelled at $14.99) | Conservative | 1,100 | $16k | **$5.8k** |
| | Moderate | 9,000 | $135k | **$47k** |
| | Optimistic | 45,000 | $675k | **$236k** |
| $19.99 | Conservative | 550 | $11k | **$3.8k** |
| | Moderate | 5,000 | $100k | **$35k** |
| | Optimistic | 25,000 | $500k | **$175k** |

**What US$1M takes depends on which $1M (at $14.99):** about **67,000 units** as headline gross, about **120,000** as Steam gross, about **190,000** as pre-tax net, and about **240,000+** as take-home. Even the smallest is a top-few-percent outcome [S42]. **Yash should pick which definition the goal uses.** **Recommendation:** treat $1M as a long-shot portfolio goal, not a plan. Set game one's target as shipping, recouping costs, building a following, and selling **2,000–5,000 units**.

**Pricing recommendation:** with the smaller game-one scope, plan for **$9.99–12.99**. Move to $14.99 only if the slice shows more content and polish than planned. **$19.99** is only justified with Dome Keeper-level polish and content; Dome Keeper itself is $17.99 [S11]. GameDiscoverCo's 2025 data shows games above $10 had a median first-week conversion of **0.10× wishlists**, against 0.15× overall [S12]. Higher prices convert worse. That sample is games with 25k+ launch wishlists; smaller launches are likely to do worse.

**Discounts:** Steam allows a launch discount at release. Other discounts can't run within 30 days of release or of the launch discount ending, and a price increase blocks discounts for 30 days [S31].

### Release risks

Theme saturation; being mistaken for a survivors-like; years-long part-time development leading to burnout; art quality falling short of the reference; refunds if the first two hours don't hook; dependency on GodotSteam; backlash over AI disclosure.

### Milestones and go/no-go criteria (proposed)

| # | Milestone | Go if | No-go response |
|---|---|---|---|
| 1 | Concept and audience | You approve the decisions below; strangers can repeat the hook | Revise the hook or camera |
| 2 | Prototype | Section 13 criteria pass | Change design; don't add content |
| 3 | External playtest | 8–10 uncoached players: 60%+ start a second run; average 4/5 or higher on "want to play more" | Fix the loop or cut systems |
| 4 | Vertical slice | Release-quality art and audio in one arena; feasible production pace (measured hours per enemy and component) | Simplify the art style or scope |
| 5 | Store page and demo | **Estimate:** 15,000+ wishlists before release, after Next Fest. (7,000 × 0.10 ≈ 700 first-week sales, or about 2,000–3,500 lifetime, which doesn't reach 5,000 units.) | Re-scope, re-price or ship small; at 7,000–15,000, lower the unit target to 2,000–3,500 |
| 6 | Full production | The reduced content plan fits the measured pace within ~9–14 months after the slice (about 600–900 h in total) | Cut content |
| 7 | Release | 80%+ positive in the first week; under 10% refunds | Patch quickly; adjust price later |
| 8 | Post-launch | Support costs under 25% of dev time | Decide on a sequel or new game based on data |

## 16A. Mobile (Android and iOS) feasibility

You asked for mobile support as well as Windows and Steam. **Recommendation: design for mobile from day one, but release on Steam first and port to mobile after launch.** Brotato took this path: Steam Early Access in Sept 2022, then a premium mobile release at $4.99 in March 2023 through a porting studio [S2][S34].

**Store costs and rules (facts):**

| | Google Play | Apple App Store |
|---|---|---|
| Account | **$25 one-time** [S35] | **$99 a year, every year**, or the app is removed [S36] |
| Store fee | 15% on the first $1M a year in most markets. **In the US, UK and EEA from 30 June 2026, a paid game pays 20% + 5% billing fee (25%) for new installs**, or 20% in the Play Games Level Up programme [S37] | 15% under the Small Business Program (under $1M proceeds a year) [S38] |
| Hurdle | New personal accounts must run a closed test with **12 testers for 14 consecutive days** before production [S39]. Recruit them from the Stage D playtester list | A Mac with Xcode is needed to build for iOS |

**Monetisation:**

- **Premium (pay once): recommended.** Price at about **$3.99–6.99**, well below the Steam price, because that's where premium mobile prices sit (Brotato was $4.99 [S34]).
- **Free-to-play or ads: rejected.** It needs a different game design (energy, retention loops, live operations), analytics and ongoing content. It contradicts the brief's single-player, offline, premium identity.
- **Market reality (one analyst; label as indicative):** in 2022, premium games made about 0.3% of mobile game revenue. The median premium game earned about **$30k net from 6,000 downloads**, and most of the top 100 were ports of known PC, console or board game IPs [S40]. Mobile works as a second channel for a game that has already succeeded on Steam, not as a launch platform for an unknown one.

**Controls:**

- **Day phase (preparation):** works well on touch. Tap trap sockets, drag components into weapon slots.
- **Night phase (combat):** the hard part. Twin-stick virtual joysticks work but feel worse than a mouse. Options are auto-aim with manual override, or aim-assist toward the nearest threat to the chamber. The side-on cross-section (camera option A) may suit touch better than top-down, because movement is mostly along floors and stairs.
- **Rules from day one:** all input through Godot's input actions (no hard-coded mouse logic); UI that scales from 16:9 monitors to 20:9 phones with notches; touch targets at least about 9 mm; no hover-only information.

**Performance:**

- Phones throttle under sustained load, and 2D lights and fog are exactly what stresses them. The art style relies on them, so quality presets are part of the look test, not a later add-on.
- **Recommendation:** set a mobile budget at the prototype stage (for example, 30 fps locked on a mid-range Android phone from about 2022), keep fog and light effects scalable with quality presets, and test thermal throttling over a 20-minute run.

**Estimates:**

| Item | Implementation | Testing | Content | Impact |
|---|---|---|---|---|
| Design-for-mobile rules during development | ~5% overhead on UI and input work | Low | None | Avoids a rewrite later |
| Full mobile port after Steam launch | ~150–300 h (touch controls, UI layouts, performance, store setup) | **High** (device range, aspect ratios, heat, store review) | Touch UI art, store assets | Second revenue channel; **estimate 10–30% of Steam revenue**. A $4.99 US sale nets about $2.50–3.00 before tax |

**Order:** Android first. Port to iOS only if Android sales justify a Mac and the yearly fee.

**Budget impact:** the Apple fee (about ₹9,500 a year) plus a Mac if you don't have one doesn't fit the current ₹10,000, which the Steam fee already uses. Android alone adds ₹2,400.

## 17. Go/no-go recommendation

**Conditional GO for Stage B (design research) and a time-boxed greybox prototype.**

**Reasons to go:**

- The chamber premise gives the fixed screen and the time loop a real reason to exist, and it can carry real mechanics (noise, chamber health, self-experimentation).
- The closest comparables (Dome Keeper, Thronefall, The Last Spell) show demand for prep-then-defend games from tiny teams at $13–25.
- Godot is proven in this exact space.
- The first gates are cheap: a 10–15 h look test and a 15–25 h combat toy, with no money spent.

**Conditions (otherwise no-go):**

1. Reduce to four systems (merge infection into experimentation).
2. Fix the camera by greybox test.
3. Spend no money and make no Steam page until the vertical slice passes, except an artist if the look test fails (that becomes a slice precondition).
4. Art path: light-led silhouette style built by Yash, judged by the look test before the prototype.
5. Accept that the commercial target for game one is far below $1M, and that game one is cut to about 600–900 hours.
6. Mobile is a post-launch port. Systems are built mobile-ready, but the mobile release isn't on the critical path.

**No-go for now:** production, asset purchases, a soundtrack, narrative scripting, or a store page.

## 18. Unresolved decisions, prioritised

1. **Camera:** cross-section building (A) or top-down arena (B).
2. **System count:** merge infection powers into self-experimentation.
3. **Run and loop structure:** nights per run, reset trigger, what persists.
4. **Art pipeline and artist:** can you draw at the target quality, and which style (cutout silhouettes or frame-by-frame).
5. **Commercial target and budget:** a realistic goal for game one; whether to raise the budget after the slice.
6. Why knowledge survives the loop, in the fiction.
7. The spouse's characterisation and the ending's requirements.
8. Engine version pin (4.7.x) and the reference PC for performance.
9. The noise-attraction rule as the central mechanic.
10. Weapon frame and slot structure, and the tag list.
11. Trap placement model (sockets or free placement).
12. Target run length and total playtime.
13. Pricing band, once slice evidence exists.
14. Demo strategy and Next Fest timing.
15. Mobile port timing, and which stores first (Android only, or Android and iOS).

---

## Decisions approved by Yash (22 October 2026)

Yash approved all five recommendations. The amendments from the review are folded in.

| # | Decision | Approved, with review amendments |
|---|---|---|
| 1 | **Camera and perspective** | **Side-on cross-section** of one building, tested by the 15–25 h combat toy. Fall back to top-down if it fails. Plan for about 30–60 enemies on screen. |
| 2 | **Cut infection powers as a separate system** | **Yes.** Merged into self-experimentation; research results become mutations with clear costs. No infection clock in the prototype. Four core systems, plus story capped at about 20 fragments. |
| 3 | **Loop rules** | Five nights in the prototype (3–7 at release); reset when you die or the chamber falls. Persist recipes, components, research findings and story; never resources or stats. Unlocks count as power and are balanced as such. |
| 4 | **Art feasibility** | Yash can't draw. **Light-led silhouette style** built by Yash, free assets only as placeholders, no shipped AI art. A 10–15 h look test comes before the prototype. If it falls short, a freelance artist becomes a precondition for the slice. |
| 5 | **Commercial target, budget and platform order** | Game one: ship, recoup costs and sell 2,000–5,000 units at $9.99–12.99 on Steam, with a 15k-wishlist gate. Keep ₹10,000 for the Steam fee (artist budget only if the look test fails). Build mobile-ready, then port to Android first at $3.99–6.99 premium after the Steam launch, and iOS only if Android justifies it. |

**Still open for Yash:** which definition of "$1M" the goal uses, and confirming the cut to a 600–900-hour game one. Both can be settled at the start of Stage B.

**Final outcome: conditional GO for Stage B (design research).** Stage B starts on Yash's go-ahead.
