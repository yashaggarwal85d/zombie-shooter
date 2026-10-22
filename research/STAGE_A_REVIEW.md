# Stage A Review: Adversarial Check of the Concept Validation Report

Prepared 22 October 2026 · Reviews [CONCEPT_VALIDATION_REPORT.md](CONCEPT_VALIDATION_REPORT.md) and [RESEARCH_LOG.md](RESEARCH_LOG.md) as they stand on `main`. The original report is unchanged. Nothing here overrides an approved decision. Where this review disagrees, it proposes a change with evidence for Yash to accept or reject.

Labels used: **Verified** (re-checked today against the source), **Error** (the report misstates the source), **Weak** (true but misleading or used beyond what it supports), **Estimate** (my number, reasoning shown), **Unchecked** (not re-verified today).

New input since the report: Yash approved the five recommendations, and said he **can't draw** and wants art that is "very artistic and impeccable", with the feel of Silksong (message of 22 Oct 2026). That changes the art and budget analysis more than anything else in this review (section 5).

---

## Bottom line

The report is honest in tone and mostly accurate on facts. Its main weaknesses are in what it concludes from them:

1. **The revenue scenarios are anchored too high.** The "conservative" case is above what most Steam games sell. There's no typical-outcome scenario at all (section 2).
2. **The plan's own numbers don't connect.** The 7,000-wishlist gate can't produce the 5,000-unit target. The production milestone (12–18 months) doesn't fit the report's own 2–4-year total (sections 2 and 3).
3. **The minimum release is still too big for a first game at 1–2 hours a day.** Two to four years of part-time solo work on an unproven first game is the largest risk in the project, larger than the camera or the theme (section 3).
4. **The art plan assumed someone can paint.** Yash can't draw. "Impeccable, Silksong-feel" art, ₹10,000, solo and no AI art can't all be true at once. One of them has to give (section 5).
5. **One material factual error:** the Google Play fee for a paid game in the US, UK and EEA is 20–25%, not 10% + 5% (section 1).

None of this reverses the conditional go. It changes what game one should be.

---

## 1. Source and claim verification

Steam prices and reviews were re-pulled today from Steam's public `appreviews` and `appdetails` endpoints. Other claims were checked against the cited page.

| Claim in report | Finding | Status |
|---|---|---|
| Review counts for comparables (Brotato 32,638, Dome Keeper 11,837, The Last Spell 6,752, YAZS 5,665, Into the Dead 3,236, Endoparasitic 1,800) | They match **English-language, Steam-purchase reviews only**, not all reviews. All-language totals today: Brotato 120,038; Dome Keeper 22,721; The Last Spell 13,819; YAZS 15,927; Into the Dead 10,078; Endoparasitic 3,107. Percentages are about right. The filter wasn't stated, so the counts understate audience size by 2–4×. | **Weak** (unlabelled filter) |
| Zombie Cure Lab 65% of 393; The Horde Wants You Dead 63% of 258 | Today: Zombie Cure Lab 219 English / 468 all (65–68%); The Horde 215 English (61%) / 291 all (65%). Neither number matches either filter, though the "Mixed" verdict holds. | **Weak** (likely drift or a different filter) |
| Prices: Brotato $4.99, Dome Keeper $17.99, The Last Spell $24.99, Zombie Cure Lab $24.99, YAZS $14.99, The Horde $9.99, Into the Dead $24.99, Endoparasitic $9.99 | All match the US store today. | **Verified** |
| Google Play: "In the US, UK and EEA, that's now a 10% rate plus a 5% billing fee" [S37] | The 10% + 5% rate applies to **auto-renewing subscriptions only**. For a paid game in the US, UK and EEA after 30 June 2026, the first $1M costs **20% + 5% billing fee (25%) for new installs**, 25% + 5% for existing installs, or 15% + 5% (20%) inside the Play Games Level Up programme. The 15% rate still applies in other markets. | **Error** (material for mobile maths) |
| Steam: "Discounts can't run within 30 days of release" [S31] | Incomplete. Steamworks allows a **launch discount** at release. The 30-day rules apply to other discounts, to discounts after a launch discount, and to price increases. | **Weak** (affects launch planning) |
| ~48.8% of 2025 releases had 10 or fewer reviews [S19] | The figure is correct, but the article is dated **12 Dec 2025**. Games released in late 2025 had barely had time to collect reviews, so the share is overstated. It's still right as a warning. | **Weak** |
| GodotSteam archived 20 Oct 2026 [S24] | True. But the project **moved to Codeberg and is active**: commits up to 16 Oct 2026, current build 4.23.2. The readme notes a Godot 4.7 breaking change. The risk is smaller than the report implies. Keep the Stage C test. | **Verified, risk overstated** |
| Godot 4.7.2 stable, 18 Aug 2026 [S20] | Matches the Godot release archive. | **Verified** |
| Godot mobile renderer and C# claims [S33] | The cited page is the **French 4.5** docs, not 4.7. The claims are probably still true, but cite the 4.7 English docs. | **Weak** (outdated citation) |
| Unity Pro $2,310 a year; Personal free to $200k [S21] | Matches Unity's pricing page (5% rise from 12 Jan 2026). | **Verified** |
| Thronefall 1M+ copies, 2 developers, €12.99 [S13] | Matches (5 Feb 2025; copies, not players). | **Verified** |
| Dome Keeper 1M players [S5] | Matches, and the report correctly labels it as players, not sales. | **Verified** |
| Halls of Torment 1M sales [S15] | Matches (18 Oct 2024). The report omits that it sells for under $5, like Brotato. | **Weak** (omits price) |
| The Last Spell 400k+ units [S4] | Matches (12 Apr 2024), but the total **includes PS4, PS5 and Switch**. It isn't a Steam figure. | **Weak** |
| Brotato solo, 1M+ copies [S2] | Solo during development. Wikipedia now says development passed to Evil Empire, and mentions 10M+ copies by 2025 with no citation. | **Verified, with caveat** |
| Ari Gibson "15 years" remark; Team Cherry is three people [S25] | Matches. | **Verified** |
| Steam AI disclosure; code assistants exempt [S26] | Matches (16 Jan 2026). Note that disclosure also covers **marketing and store-page assets**. | **Verified** |
| Google Play closed test with 12 testers for 14 days [S39] | Matches. It applies to personal accounts created after 13 Nov 2023. | **Verified** |
| GameDiscoverCo wishlist conversion 0.15× overall, 0.10× above $10 [S12] | Matches (17 Oct 2025). The sample is games with **25k+ launch wishlists**, so the figures don't describe a 7k-wishlist launch. | **Verified, misapplied** (section 2) |
| Premium mobile: 0.3% of revenue; median $30k net and 6,000 downloads [S40] | Matches. The report says "most of the top 100 were ports". The source says 37 of the top 100 are mobile-native IPs and the rest use PC, console or board-game IPs. That's close enough. | **Verified** |
| ₹95.5 per US$ [S27] | Still about right: a secondary source shows about 95.05 on 15 Oct 2026. | **Verified** (approximately) |
| India–US royalty withholding 10% or 15% [S32] | Couldn't confirm the category split from the embassy PDF. A chartered accountant (CA) is still required. | **Unchecked** |
| Hades, Twelve Minutes, Apple fees | Not re-checked; low impact. | **Unchecked** |

**Missing evidence the report should have used:** a base rate for typical Steam outcomes. Chris Zukowski's analysis of 2019 Steam releases (VG Insights data, measured Nov 2022) found a **median lifetime gross of about $1,136**, with 68% of games under $10,000 ([Game World Observer, 29 Nov 2022](https://gameworldobserver.com/2022/11/29/median-indie-game-earnings-steam-barely-over-1000)). He also uses 1,000 reviews as a rough marker for about $300k gross. Only 232 of 8,000+ games released in the first half of 2024 reached it ([Game World Observer, 18 Jul 2024](https://gameworldobserver.com/2024/07/18/top-game-genres-on-steam-first-half-2024-key-trends)). Newer 2025 figures I found (median about $250–$1,000; ~66% under $1,000) come from secondary aggregators that I couldn't trace to a primary source, so I don't rely on them.

**Selection bias in the comparables:** every comparable except Zombie Cure Lab and The Horde is a hit. Lessons drawn only from winners overstate the odds. The comparables that support "Godot is proven" (Brotato, Halls of Torment) are also $5 survivors-likes, which is exactly the price anchor the report says to avoid.

## 2. Revenue model

**The arithmetic is correct.** 0.60 realised price × 0.90 after VAT × 0.93 after refunds × 0.70 after Valve's cut = 0.351. Every row of the pricing table checks out. The 190,000 units needed for $1M net at $14.99 is correct (1,000,000 ÷ 5.25).

**The problems are in the inputs and the framing:**

1. **"Conservative" isn't conservative.** At 1,500 units × $9.99 ≈ $15k gross, it sits above the 68th percentile of the 2019 cohort. A median outcome is a few hundred units. The table has no row for the most likely result.
2. **Two kinds of "gross" are mixed together.** The table's "headline gross" is base price × units. Zukowski's medians and Valve's "adjusted gross revenue" are realised revenue, which is about 55–60% of headline. Compare like with like.
3. **"Net" is before withholding tax and income tax.** After 15% US withholding (if that rate applies; confirm with a CA), about 30% of headline reaches the bank, and Indian income tax comes out of that. **Estimate:** 20–25% of headline is take-home.
4. **"$1M" isn't defined.** The project memory says "$1M in revenue". At $14.99, that's about **67,000 units** as headline gross, about **120,000** as Steam gross, about **190,000** as pre-tax net, and about **240,000+** as take-home. Yash should pick one definition. The report's "scale of Dome Keeper or Thronefall" is loose: 190k is about a fifth of Thronefall's 1M copies. It's still a top-1–3% outcome by the review benchmark above.
5. **The wishlist gate can't hit the unit target.** 7,000 wishlists × 0.10 ≈ 700 first-week sales. Even with a generous 3–5× lifetime multiple (**estimate**), that's about 2,000–3,500 units, short of the 5,000-unit goal. Also, the 0.10× figure comes from games with 25k+ wishlists, and smaller launches get less algorithmic lift. **Proposal:** set the gate at 15k+ wishlists, or lower the goal to 2,000–3,000 units.

**Re-anchored scenarios at $12.99** (**estimates**; take-home ≈ $3.86 per unit after Valve, VAT, refunds and 15% withholding, before Indian income tax):

| Outcome | Units | Take-home (approx.) | Comment |
|---|---|---|---|
| Typical (median-like) | 150–400 | $0.6k–1.5k | Most likely without a strong hook and marketing |
| Modest | 1,000–2,500 | $4k–10k | The report's "conservative" |
| Solid | 5,000–10,000 | $19k–39k | The report's game-one target; needs ~15k+ wishlists |
| Breakout | 50,000+ | $190k+ | Top few percent |

At 1,500 hours of work, the "solid" case pays about **$13–26 an hour** before income tax. That's a fair price for learning to ship, not a business case. **The $1M goal can't be a plan built on one 2–4-year game at this pace. It's a long-shot outcome.** The report says something similar in softer words.

## 3. Scope and timeline

**Arithmetic check:** 1,200–2,000 h at 10–12 h/week is 100–200 weeks, or 2–4 years. Correct. The project constraint is 1–2 h/day, which is 7–14 h/week, so 2–5.5 years.

**Internal contradictions:**

- Milestone 6 says full production should fit "within ~12–18 months". After a prototype and slice of roughly 200–300 h, the report's own estimate leaves **900–1,700 h of production, which is 1.5–3.3 years** at 10–12 h/week. One of the two numbers is wrong.
- The 150–250 enemy performance target (section 11) comes from top-down survivors-likes. In a side-on cross-section (camera A), 150 enemies on two or three floors would be unreadable, which breaks the rule that effects must never hide danger. A mid-range phone at 30 fps also can't be expected to carry it. Set the count per camera: **estimate 30–60 on screen for A**, with heavier, more distinct enemies.
- Section 2 sells infection as "the run timer". Section 10 rejects any corruption meter. The prototype needs one answer. **Proposal:** no infection clock in the prototype.

**The hidden fifth system is story.** "Four systems" leaves out a 3–5-hour story arc that has to change across loops, a spouse with agency, and an ending that has to land (Twelve Minutes is cited as the cautionary tale). Loop-reactive writing is expensive and hard to test. Budget it like a system.

**The prototype is too big as the first test.** 60–100 h, with three enemies, two weapons, a day phase, research, a reset and multi-floor pathing, is a vertical slice minus art. For a first-time game developer, **estimate 100–150 h**. **Proposal:** split it.

1. **Combat toy (15–25 h):** camera A only, one floor plus stairs, the chamber, one weapon, two enemies. Gate: is holding the chamber fun for 5 minutes?
2. **Loop prototype (50–80 h):** only if the toy passes. Add the day phase, trap, slot choice, research choice and reset.

**Proposed cut for game one (my strongest disagreement):** reduce the minimum release to fit **about 600–900 h (12–20 months)**. That means 3–4 enemies plus one boss night, about 10–12 components, 4–5 traps, 6–8 experiments, and a story told in about 20 fragments with one ending. Price it at $9.99–12.99. A finished small game produces the data and the following the report says game one is for. A 2,000-hour game risks producing neither. This touches scope, so it's Yash's call at the start of Stage B.

## 4. Mobile

Yash wants both Windows/Steam and mobile. The report's "build mobile-ready, port after launch" is right, and I'd keep it. Corrections and additions:

- **Fees:** after the Google Play correction, a $4.99 premium sale in the US loses about 25% to Google (20% with Level Up), not 15%. Combined with a low realised price, **estimate about $2.50–3.00** per US sale before tax.
- **Recurring costs:** Apple's $99 is **a year, every year**, or the app comes down. **Unchecked today:** Google requires yearly target-API updates, which turns a port into ongoing maintenance.
- **Closed testing:** recruiting 12 real testers for 14 straight days is a real chore for a solo developer with no community yet. Build a playtester list during Stage D anyway.
- **Art versus phone tension (new):** for a non-drawer, the cheapest route to atmosphere is lighting, fog and shaders. That's exactly what phones throttle. Quality presets must be designed from the first look test, not added later.
- **Camera A helps mobile.** Side-on aiming is mostly one-axis, so auto-aim with manual override is far easier than twin-stick. That's an argument for decision 1 the report undersold.
- **Proposal:** port to Android first, and port to iOS only if Android sales justify a Mac and the yearly fee. Treat the mobile port's revenue as **estimate: 10–30% of Steam revenue**, not a separate pillar.

## 5. The five approved decisions

| # | Approved | Verdict | Proposed amendment |
|---|---|---|---|
| 1 | Side-on cross-section first, top-down fallback | **Agree** | Gate it with the 15–25 h combat toy above. Set enemy counts and the performance target for A, not for survivors-likes. Dome Keeper's side-on defence is the supporting evidence. |
| 2 | Merge infection powers into self-experimentation | **Agree** | Settle the infection-as-clock contradiction (none in the prototype). Watch that research doesn't become the system that does everything: powers, unlocks and story at once. |
| 3 | 3–7 nights; persist recipes, research and story only | **Partly agree** | Unlocked components *are* power progression. Say so and balance for it. Fix the prototype at 5 nights rather than a range. "Story advances only through discoveries" multiplies writing. Cap it at about 20 fragments for game one. |
| 4 | Cutout silhouettes, one painted building, shader fog, no shipped AI art | **Must revisit** | It assumed someone can paint the building and the character parts. Yash can't. See below. |
| 5 | 5,000+ units at $12.99–14.99; spend nothing until the slice; mobile later | **Partly agree** | 5,000 units is an above-typical outcome. The 7k-wishlist gate doesn't reach it. "Spend nothing until the slice" conflicts with needing release-quality art *in* the slice (milestone 4). |

### Art, given that Yash can't draw

Silksong's look is fundamentally hand-drawn line art and painted environments made by specialists over years. **A non-drawing solo developer with a ₹10,000 budget and no AI art can't reach that bar.** That isn't pessimism; it's the same point the report makes with the "15 years" quote. Something has to give. The realistic options:

| Option | Cost | Fits "impeccable"? | Risk |
|---|---|---|---|
| **A. Light-led silhouette style.** Characters as solid shapes with rim light and a few accent colours. The environment built from layered shapes, gradients, fog, particles and shaders. Skeleton2D animation of simple parts. | ₹0, but many iteration hours | Can be striking. Atmosphere comes from light and composition, which a programmer can learn faster than drawing. | Taste is still needed. Risk of looking like a generic "Limbo-like". Phone performance (section 4). |
| **B. Freelance artist for the key pieces:** capsule art, one cross-section background, and character parts drawn for rigging. Yash animates and lights them. | Well above ₹10,000. I have no sourced rates, so get three quotes in Stage B. | Best chance of a distinctive, hand-made look | Budget, managing a contractor, keeping a consistent style when assets are added later |
| **C. Asset packs** | Low | **No.** Generic, recognisable, and the styles clash | Undercuts priority 2 (distinctive visuals). Use only for greybox, UI and placeholder sound. |
| **D. AI-generated art** | Low | Inconsistent across animation frames | Steam disclosure on the game *and* store page, player backlash, licensing uncertainty. The report rejected it, and I agree for shipped assets. |

**Recommendation:** use A as the baseline, and add B for the capsule and the background if the look test shows A falls short. Move the **look test earlier**, into Stage C, before the prototype: one screen with the chamber, one silhouette enemy, fog and light, about 10–15 h. The hook test in section 14 needs a mock capsule and GIF anyway, and nobody can make those yet. If the look test fails, raising the budget for an artist becomes a precondition for the slice, not an option after it.

## 6. What I'd change before Stage B starts

1. Define "$1M" (headline gross, Steam gross, net or take-home), and add a typical-outcome row to the revenue model.
2. Decide the art path (A, A+B, or other) and whether the budget can rise for an artist.
3. Decide whether game one is cut to about 600–900 h.
4. Fix the wishlist gate (15k+), the production-time contradiction, and the per-camera enemy and performance targets.
5. Correct the Google Play fee, the Steam launch-discount rule and the review-count labels in the research log.
6. Split the prototype into a combat toy and a loop prototype, with a gate between them.

## Sources checked today (22 Oct 2026)

All sources in RESEARCH_LOG.md marked Verified above, plus:

- Steam `appreviews` and `appdetails` endpoints for apps 1942280, 1637320, 1105670, 1620290, 2163330, 3552820, 2239710 and 2124780 (English Steam-purchase and all-language totals).
- [Google Play service fees](https://support.google.com/googleplay/android-developer/answer/112622?hl=en) (fee table for US, UK and EEA after 30 June 2026).
- [Steamworks pricing](https://partner.steamgames.com/doc/store/pricing) (launch discount and cooldowns).
- [GodotSteam on Codeberg](https://codeberg.org/GodotSteam/GodotSteam) (activity to 16 Oct 2026).
- [GameDiscoverCo: State of Steam wishlist conversions](https://newsletter.gamediscover.co/p/the-state-of-steam-wishlist-conversions) (17 Oct 2025; 25k+ wishlist sample).
- [Game World Observer: median indie earnings](https://gameworldobserver.com/2022/11/29/median-indie-game-earnings-steam-barely-over-1000) (29 Nov 2022) and [first half of 2024 genres](https://gameworldobserver.com/2024/07/18/top-game-genres-on-steam-first-half-2024-key-trends) (18 Jul 2024).
- Secondary, not relied on: [game-developers.org 2025 revenue distribution](https://game-developers.org/2025-steam-game-revenue-distribution) (Gamalytic-derived, sample unclear).

## Decision recorded after this review

- **22 Oct 2026, Yash: art path = option A (light-led silhouette style) with an artist if needed.** Yash builds the look himself for ₹0. A 10–15 h look test (the chamber, one silhouette enemy, fog and light on one screen) runs in Stage C before the prototype. If the look test falls short of the bar, raising the budget for a freelance artist (capsule, background, character parts) becomes a precondition for the vertical slice.
