# Risk Register

Risks to shipping game one, with owner checks. Design risks are seeded from research/STAGE_B_DESIGN_RESEARCH.md section 10 (Stage B PR #2); that section stays the source for them. Status: **skeleton** (22 October 2026). Review at every stage gate.

**Likelihood / impact:** Low · Medium · High · Critical.

## Design

| Risk | Likelihood | Impact | Mitigation | Checked by |
|---|---|---|---|---|
| The noise rule creates no real choice | Medium | Critical | Debug overlay; log loud vs quiet use; tune pulse size and radius | Combat toy gate |
| Side-view fights feel one-dimensional | Medium | High | Two attack sides, height from walls and the roof, structures that break (D11) | Combat toy gate |
| Standing on a wall or the roof is always safe | Medium | High | The infected break what they reach; shooting from the roof draws them to the shelter; gate checks time off the ground | Combat toy gate |
| Reads as "Kingdom with guns" (side view, two sides, walls, moving on) | Medium | High | Lead with the noise rule, the spouse and the loop in the hook; redo the hook test outdoors | New hook test |
| Per-location art grows past the budget | Medium | High | 3 reusable backdrop kits and one shelter rig with dressings (GDD 12) | Loop prototype |
| Touch controls for move, jump, aim and fire at once | Medium | Medium | Test on a phone during the loop prototype; aim assist | Loop prototype |
| One build dominates | Medium | High | Tags tied to world states that change per night; no strictly better components | Slice playtests |
| Darkness hides danger | Medium | High | Readability rules; greyscale test | Look test |
| The spouse reads as a prop | Medium | High | Her own notes and choice; outside readers check fragments | Slice |
| Five key findings feel like grinding | Medium | Medium | Each finding comes from a choice; tune to ending at run 6–10 | Loop prototype |
| Near-identical premise already failed commercially | — | High | Hook test with a GIF before the prototype grows | C6 |

## Technical (added with the tooling setup)

| Risk | Likelihood | Impact | Mitigation | Checked by |
|---|---|---|---|---|
| Mobile renderer is too slow on mid-range Android with lights and fog | Medium | High | Compare with Compatibility in C3; quality presets; cut light count | C3 |
| GodotSteam lags behind Godot 4.7 | Low–medium | Medium | Test in C5; ship without Steam features at first if needed | C5 |
| Engine upgrade mid-project breaks things | Medium | Medium | Pinned version, upgrade only between milestones in one PR (TECHNICAL_ARCHITECTURE section 1) | Every upgrade |
| A shared Resource is mutated at runtime and corrupts other users | Medium | Medium | Code rule: duplicate before changing; unit tests for runtime copies | Code review, tests |
| Phone suspends the app and a run is lost | High (on mobile) | Medium | Mid-run save at each day and on pause/close notifications (GDD) | Suspend test (TEST_PLAN) |
| Package/bundle ID chosen badly and locked forever on the stores | Low | Medium | Placeholder now; confirm with the game's name before first store upload | RELEASE_CHECKLIST |
| Signing keys leaked or lost | Low | High | Never in the repo (.gitignore); keep a backup of the Android upload key and use Play App Signing | RELEASE_CHECKLIST |
| iOS export never tested until the port | High | Medium | Keep iOS-safe rules (D8); one test export on the Mac before the slice is signed off (proposal, not yet decided) | Slice gate |

## Production

| Risk | Likelihood | Impact | Mitigation | Checked by |
|---|---|---|---|---|
| Scope creeps past 600–900 h | High | Critical | Every feature gets a cost card and class; content is cut before polish | Every stage gate |
| Art can't reach the target with a non-drawing solo developer | High | High | Look test first; artist becomes a slice precondition if it fails (D4) | C2 |
| Burnout at 1–2 h a day over 12–20 months | Medium | High | Small playable milestones; no stage longer than planned without a re-plan | Roadmap reviews |
