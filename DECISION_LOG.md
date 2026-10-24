# Decision Log

Confirmed decisions, with the reason for each and the alternatives rejected. Evidence for each is in [research/CONCEPT_VALIDATION_REPORT.md](research/CONCEPT_VALIDATION_REPORT.md).

## D1. Camera: side-on cross-section first, top-down as fallback (replaced by D11)
- **Date:** 2026-10-22 · **Approved by:** Yash
- **Decision:** Greybox a side-on cross-section of one building, with the chamber at its centre. If the combat fails the prototype criteria after about 15 hours of greybox work, switch to a top-down or 3/4 arena.
- **Why:** This view supports layered depth, silhouettes and fog, keeps the chamber at the visual centre, and stands out from top-down survivors-likes on a capsule.
- **Rejected:** Top-down as the default. It's proven for horde combat but looks generic and inherits the $4.99 survivors-like price anchor.

## D2. Infection powers merged into research ("self-experimentation")
- **Date:** 2026-10-22 · **Approved by:** Yash
- **Decision:** No standalone infection-power system. Self-tests on samples grant mutations that have clear costs. The game has four core systems: combat, preparation (weapons plus traps), self-experimentation, and the loop.
- **Why:** A fourth progression track would thin out every other system for a solo developer. Making powers come from experiments the player chose keeps cause and effect clear.
- **Rejected:** A separate powers tree; a corruption meter.

## D3. Loop rules
- **Date:** 2026-10-22 · **Approved by:** Yash
- **Decision:** A run is 3–7 nights. The loop resets when the player dies or the chamber falls. Recipes and components, research findings and story revelations persist (plus some changes in the spouse's condition). Resources, arena state, mutations and stats reset.
- **Why:** Each loop should change the player's knowledge, not just their numbers.
- **Rejected:** Persistent resources; a stat-grinding meta-upgrade tree.

## D4. Art approach (partly decided)
- **Date:** 2026-10-22 · **Approved by:** Yash
- **Decision:** Silhouette-led cutout or skeletal characters (Godot Skeleton2D), one painted multi-layer building, and fog and light done in shaders. No AI-generated art or music ships. An art test comes before the vertical slice.
- **Known constraint:** Yash can't draw, and wants the art to be artistic and impeccable, with the *feel* (not the style or assets) of Hollow Knight: Silksong.
- **Sourcing (Yash, 2026-10-22):** use free online assets as **placeholders** for the prototype while Yash learns and starts contributing art. Placeholders don't need to match the final style. Licences allowed: CC0 preferred, CC-BY with attribution. Nothing non-commercial, personal-use only, or unclear. Every asset is logged in ASSET_REGISTER.md with its source, author and licence.
- **Learning order (recommendation):** Skeleton2D rigging and cutout animation, then 2D lighting, fog and shaders, then shape-based silhouette drawing in Krita.
- **Art path (Yash, 2026-10-22, decision card in the review thread):** a light-led silhouette style that Yash builds himself, with an artist if needed. Atmosphere comes from shapes, layering, fog, light and shaders rather than detailed painting.
- **Gate (updated 2026-10-22):** a 10–15 h **look test** in Stage C, *before* the prototype (the chamber, one silhouette enemy, fog and light on one screen, with a mobile quality preset). If it falls short of the target quality, commissioning an artist for the key assets (estimated ₹3–10 lakh in stages) becomes a **precondition for the vertical slice**. A second art check still happens at the slice.
- **Rejected for now:** commissioning an artist before the slice (no budget); a revenue-share art partner; shipping mixed free packs as final art.

## D5. Commercial target, budget and platform order
- **Date:** 2026-10-22 · **Approved by:** Yash
- **Decision:** Game one targets recouping costs and selling 5,000+ units at $12.99–14.99 on Steam. US$1M is a goal across several games. The ₹10,000 budget is reserved for the Steam Direct fee; nothing else is spent until the vertical slice passes. Systems are built mobile-ready from day one. Android, and iOS if a Mac is available, follow after the Steam launch as a premium port at $3.99–6.99.
- **Rejected:** A simultaneous PC and mobile launch; free-to-play or ad-based mobile monetisation; pricing at $19.99 without slice evidence.

## Amendments from the Stage A review (applied to the research at Yash's request, 2026-10-22)

Source: [research/STAGE_A_REVIEW.md](research/STAGE_A_REVIEW.md). Yash asked for the review's fixes to be made to the research. These amend D1, D3 and D5 above. The two items left open here were settled in D6 and D7.

- **D1:** test the camera with a 15–25 h combat toy (one floor plus stairs, the chamber, one weapon, two enemies) before the full loop prototype. Plan for about 30–60 enemies on screen in the side-on view, not survivors-like crowds.
- **D2:** no infection clock in the prototype. Story is budgeted like a system and capped at about 20 fragments and one ending for game one.
- **D3:** the prototype uses a fixed five nights (3–7 at release). Unlocked components count as power progression and are balanced as such.
- **D5:** game one targets shipping, recouping costs and 2,000–5,000 units at $9.99–12.99, with a 15k-wishlist gate before release. Mobile goes to Android first, and iOS only if Android sales justify it. Google Play takes 20–25% on paid games in the US, UK and EEA.
- **Scope (settled in D6):** cut game one to about 600–900 hours (12–20 months).
- **"$1M" definition (settled in D7):** headline gross, Steam gross, net or take-home. At $14.99 that's about 67k, 120k, 190k or 240k+ units.
- **Rejected alternative:** keeping the original 1,200–2,000 h scope and the 5,000-unit target with a 7k-wishlist gate (internally inconsistent; see the review, section 2).

## D6. Game one scope: about 600–900 hours
- **Date:** 2026-10-22 · **Approved by:** Yash ("let's go ahead" in the review thread, read as confirming the cut; say so if that reading is wrong)
- **Decision:** game one is cut to about 600–900 h (12–20 months at 10–12 h a week): 3–4 enemies plus one boss night, about 10–12 components, 4–5 traps, 6–8 experiments, about 20 story fragments and one ending, one arena with state changes, priced $9.99–12.99. The content list is fixed in GAME_DESIGN_DOCUMENT.md section 12.
- **Why:** the original list estimates at 1,200–2,000 h (2–4 years part-time). A finished small game gives the data and following game one is for.
- **Rejected:** the original 1,200–2,000 h scope; a middle 1,000–1,200 h scope.

## D7. What "US$1M" means
- **Date:** 2026-10-22 · **Approved by:** Yash (decision card)
- **Decision:** the long-term US$1M goal is **net revenue as the store dashboards report it** (Steamworks and Play Console: after the store's cut, refunds, chargebacks and VAT/sales tax, before income tax and withholding), summed across all games. At $14.99 that is about 190,000 units.
- **Why:** it can be read directly from the dashboards, so progress is measured, not estimated.
- **Rejected:** headline gross (overstates earnings 3–5×); take-home after tax (truest, but hardest to track).

## D8. Platforms: Windows, Android and iOS are all committed (amends D5)
- **Date:** 2026-10-22 · **Approved by:** Yash ("It needs to support windows android and IOS, all! Since godot already supports IOS", then "I have a mac but we will keep it parked for now, we will develop keeping in mind that it will be released for IOS as well.")
- **Decision:** the game ships on **Windows (Steam), Android and iOS**. iOS is no longer conditional on Android sales. Launch order stays as D5: Steam first, then the mobile port, with **Android and iOS released together** as a premium port ($3.99–6.99). **iOS build work is parked** until the port; until then every system is designed so it will run on iOS.
- **What Godot covers (fact):** Godot exports to iOS, but the export must run on **macOS with Xcode installed**, and needs an App Store Team ID [S56]. Yash has a Mac, so no hardware cost.
- **Costs (fact plus estimate):**
  - Apple Developer Program: **$99 a year, every year** [S36]; about **₹8,700 a year** in India by one developer's report [S54], or about ₹9,500 at ₹95.5/$. Only needed when iOS builds start.
  - An iPhone to test on: not budgeted (a borrowed one is fine).
  - Port work: **about 200–350 h for Android and iOS together**, against 150–300 h for Android alone (estimate; the extra is signing, App Store review, safe areas and a second device range).
  - Apple's fee: 15% under the Small Business Program [S38].
- **Budget impact:** the ₹10,000 budget is already used by the Steam fee (D5). iOS adds about ₹8,700–9,500 a year from the port onward. **Recommendation:** pay nothing to Apple until the port starts after the Steam launch, and fund it from Steam revenue or a budget increase decided then.
- **Design impact (from now):** the D5 mobile-ready rules (input actions only, scalable UI, touch targets, no hover-only information, quality presets), plus: safe-area layout for notches and the Dynamic Island, mid-run saves because iOS suspends apps without warning, and an iPhone added to the mobile performance targets before the port.
- **Rejected:** a same-day launch on all three platforms (puts the 200–350 h port on the critical path and moves the Steam launch back by roughly 4–8 months at 10–12 h a week; estimate); iOS only if Android justifies it (the earlier D5 amendment, overruled by Yash).

## D9. Day action budget, win by findings, and Stage C go
- **Date:** 2026-10-22 · **Approved by:** Yash (decision card)
- **Decision:** **P1:** the day is a budget of 4 action hours, not a real-time timer (GDD section 3). **P2:** a run is won by surviving night 5 while holding the key findings (about five), which allows the cure attempt and the ending (GDD section 14). **Stage B is closed with a GO for Stage C** (tech and pipeline validation, experiments C1–C6 in research/STAGE_B_DESIGN_RESEARCH.md section 11).
- **Why:** both make every choice visible and are cheaper to build and test; P2 makes knowledge the win condition, as D3 intends.
- **Rejected:** a timed day phase (Stage A section 13); surviving five nights as the win on its own.

## Also confirmed with the report
- **Engine:** Godot 4.7.x with statically typed GDScript. The exact patch version is pinned at prototype start.
- **Stage A verdict:** conditional go for Stage B (design research) and a greybox prototype.

## D10. Stage C passed; go to Stage D (prototype)
- **Date:** 2026-10-22 · **Approved by:** Yash (Stage C thread: "lets give this a pass and move on to the next stage")
- **Decision:** Stage C (tech and pipeline validation) is passed on what was verified in the cloud: C4 pathing and noise rule passed headless, the Windows and Android builds export, and GodotSteam 4.23.2 loads in Godot 4.7.2. See [research/STAGE_C_TECH_VALIDATION.md](research/STAGE_C_TECH_VALIDATION.md). Stage D starts with the combat toy.
- **Not verified, carried into Stage D as early checks:** C1 builds launching and input working on real hardware; C3 frame rates on Yash's PC and phone (so the Mobile vs Compatibility renderer choice stays provisional on Mobile); C5 Steam achievement and cloud save; C2 look-test judgement (the D4 art gate is still open); C6 hook test with strangers.
- **Noise rule:** the 3 s sound memory and 1.25× hysteresis found in C4 go into the combat toy as tunable values. Whether they join the rule in the GDD is decided at the combat toy gate.
- **Rejected alternative:** holding Stage D until every hardware and people test is done. That is safer but would stall the build while the runs wait on Yash's time.

## D11. Outside the shelter, on the road (replaces D1)
- **Date:** 2026-10-22 · **Decided by:** Yash, in the project chat: "I don't want to be the scene in the house… it would certainly not be inside. So yeah, zombie will come from two directions."
- **Decision:** the camera is outside only: a side view of a small shelter (a cabin in the woods, sometimes a building in town) with the spouse inside and never shown. The infected come from the left and the right. The backdrop changes by location, and there is day and night. The two of you travel: at each stop you research, fight, gather, then move on. The player can jump onto the shelter and onto structures they build (fences, walls, high walls with ladders), and lay traps.
- **Kept from earlier decisions:** the noise rule and the hum, runners that ignore noise, the loud/quiet weapon choice, D2 (self-experimentation), D3 (loop rules, with "arena state" now meaning the structures at a stop), D4 (art approach), D6 scope budget, D9 P1/P2.
- **Proposals that fill the gaps (GDD v0.2, items marked ⚑; waiting for Yash):** one stop per day and night, 5 stops on a fixed route ending at her lab; scavenging is a day action, not a separate phase; the infected never jump or climb, they break structures; runners vault low fences; no dodge (jump replaces it); 3 backdrop kits; her presence shown as the pod's light through the shelter.
- **Why (Yash):** he wants an outdoor scene with a story of moving, not a static house interior.
- **Consequences:** the waypoint graph, stairs and floors from Stage C (C4) are no longer needed; the noise and horde logic carry over. The C2 look test and the C6 hook clip show the old interior, so both need redoing outdoors before they count. Jumping, climbing and building are new work.
- **Rejected:** the side-on interior cross-section (D1), and its top-down fallback. The interior combat toy spec (v0.1) was withdrawn before any code was written.

## D12. Combat toy approved, with climbing piles and building (amends D11)
- **Date:** 2026-10-22 · **Approved by:** Yash (combat toy thread: "…let's implement this")
- **Decision:** the combat toy spec v0.2 and the GDD v0.2 proposals are approved, with Yash's changes: (1) the player builds by day with limited resources, so the toy gets a short build step before the night; (2) the infected break structures **or pile on top of each other and climb over them**, so height never protects the player for long; (3) the shelter is on their straight path, so a player who hides up high loses her, and the loop resets.
- **Replaces:** my proposal that the infected never climb.
- **Rejected:** a fixed, pre-built toy layout (Yash wants building in from the start).

## D13. Hollow Knight-like movement and melee feel, plus the gun (proposed)
- **Date:** 2026-10-24 · **Status:** proposed, waiting for Yash's OK on the spec change. The direction itself is Yash's: "the movement mechanics are gonna be like hollow knight, how it jumps and melee attacks. The ranged attacks will also be there in our case."
- **Decision (proposed):** an overriding of the project rule against adopting Hollow Knight's combat, limited to **feel**: a variable-height jump with a snappy arc and instant air control, and a fast three-direction melee (forward, up, down in the air) with hit-stop, recoil and a downward bounce that also knocks bodies off piles. The gun stays. Details: [research/STAGE_D_MOVEMENT_MELEE_PROPOSAL.md](research/STAGE_D_MOVEMENT_MELEE_PROPOSAL.md).
- **Not taken from Hollow Knight:** its numbers, moves list, nail or sword, soul or healing system, masks UI, sounds and animations. The melee weapon is a tool (a hatchet or crowbar).
- **Why:** the toy's movement and melee are flat. Responsive movement makes a 2D action game feel good, and a down-strike gives D12's climbing piles a counter.
- **Risks:** looking derivative, because we would share Hollow Knight's art feel, movement and side view while sitting close to Kingdom Two Crowns in structure; melee overpowering the loud/quiet choice; touch controls for the port; about 15–25 h of build and tuning, and about 12 player animations later.
- **Rejected alternatives:** keeping the toy's flat movement (cheaper, but the feel would likely fail the "fun for five minutes" gate); adding a dash now (wait to see whether the jump is enough).
