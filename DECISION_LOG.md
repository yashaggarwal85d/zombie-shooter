# Decision Log

Confirmed decisions, with the reason for each and the alternatives rejected. Evidence for each is in [research/CONCEPT_VALIDATION_REPORT.md](research/CONCEPT_VALIDATION_REPORT.md).

## D1. Camera: side-on cross-section first, top-down as fallback
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

Source: [research/STAGE_A_REVIEW.md](research/STAGE_A_REVIEW.md). Yash asked for the review's fixes to be made to the research. These amend D1, D3 and D5 above. Two items stay open for Yash.

- **D1:** test the camera with a 15–25 h combat toy (one floor plus stairs, the chamber, one weapon, two enemies) before the full loop prototype. Plan for about 30–60 enemies on screen in the side-on view, not survivors-like crowds.
- **D2:** no infection clock in the prototype. Story is budgeted like a system and capped at about 20 fragments and one ending for game one.
- **D3:** the prototype uses a fixed five nights (3–7 at release). Unlocked components count as power progression and are balanced as such.
- **D5:** game one targets shipping, recouping costs and 2,000–5,000 units at $9.99–12.99, with a 15k-wishlist gate before release. Mobile goes to Android first, and iOS only if Android sales justify it. Google Play takes 20–25% on paid games in the US, UK and EEA.
- **Scope (open, confirm at Stage B):** cut game one to about 600–900 hours (12–20 months).
- **"$1M" definition (open):** headline gross, Steam gross, net or take-home. At $14.99 that's about 67k, 120k, 190k or 240k+ units.
- **Rejected alternative:** keeping the original 1,200–2,000 h scope and the 5,000-unit target with a 7k-wishlist gate (internally inconsistent; see the review, section 2).

## Also confirmed with the report
- **Engine:** Godot 4.7.x with statically typed GDScript. The exact patch version is pinned at prototype start.
- **Stage A verdict:** conditional go for Stage B (design research) and a greybox prototype.

## D10. Stage C passed; go to Stage D (prototype)
- **Date:** 2026-10-22 · **Approved by:** Yash (Stage C thread: "lets give this a pass and move on to the next stage")
- **Decision:** Stage C (tech and pipeline validation) is passed on what was verified in the cloud: C4 pathing and noise rule passed headless, the Windows and Android builds export, and GodotSteam 4.23.2 loads in Godot 4.7.2. See [research/STAGE_C_TECH_VALIDATION.md](research/STAGE_C_TECH_VALIDATION.md). Stage D starts with the combat toy.
- **Not verified, carried into Stage D as early checks:** C1 builds launching and input working on real hardware; C3 frame rates on Yash's PC and phone (so the Mobile vs Compatibility renderer choice stays provisional on Mobile); C5 Steam achievement and cloud save; C2 look-test judgement (the D4 art gate is still open); C6 hook test with strangers.
- **Noise rule:** the 3 s sound memory and 1.25× hysteresis found in C4 go into the combat toy as tunable values. Whether they join the rule in the GDD is decided at the combat toy gate.
- **Rejected alternative:** holding Stage D until every hardware and people test is done. That is safer but would stall the build while the runs wait on Yash's time.
