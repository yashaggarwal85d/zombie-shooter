# Roadmap

Stages run in order, each with a go/no-go gate and Yash's approval before the next starts. Status: **skeleton** (22 October 2026). Hours are estimates; game one is budgeted at about 600–900 h (D6).

| Stage | State | Main output | Gate |
|---|---|---|---|
| A. Concept validation | **Done** (conditional go) | research/CONCEPT_VALIDATION_REPORT.md, STAGE_A_REVIEW.md | D1–D5 |
| B. Design research | **Go for C** (D9, pending PR #2 merge) | GAME_VISION.md, GAME_DESIGN_DOCUMENT.md v0, research/STAGE_B_DESIGN_RESEARCH.md | Stage B section 12 |
| C. Tech and pipeline validation | **Starting** | Project skeleton and CI (this PR); experiments C1–C6 | Every C experiment passes or has an accepted fallback |
| D. Prototype | Not started | Combat toy (15–25 h), then the loop prototype | GDD prototype gates |
| E. Vertical slice | Not started | One polished run with real art for its content | Art check (D4), playtests, wishlist trend |
| F. Production planning | Not started | Content schedule to release | Fits the 600–900 h budget |
| G. Release (Steam) | Not started | Store page, demo, launch | 15k-wishlist gate (Stage A amendments) |
| H. Mobile port (Android + iOS) | Not started | Port, about 200–350 h, outside the game-one budget (D8) | Steam results |

## Stage C plan

From research/STAGE_B_DESIGN_RESEARCH.md section 11. About 30–45 h in total.

| # | Experiment | Est. | Pass if |
|---|---|---|---|
| C0 | Project skeleton, CI, export presets (this PR) | done here | Tests and exports run in CI |
| C1 | Windows and Android exports launch; actions drive a test character | 4–6 h | Both launch on hardware; input works on each |
| C2 | Look test (D4) | 10–15 h | Yash and 3 others would click on the capsule; passes greyscale readability |
| C3 | Performance: 60 enemies (to 100), 2D lights, fog | 4–6 h | 60 fps reference PC; 30 fps reference phone at low preset; no throttling below 30 fps over 20 min |
| C4 | Waypoint-graph pathing, three floors, two stairwells | 4–6 h | 60 agents, no stuck agents in a 10-minute soak, under 2 ms a frame |
| C5 | GodotSteam for 4.7: one achievement, one cloud save | 2–4 h | Both work in a test app |
| C6 | Hook test: mock capsule, pitch, GIF | 3–5 h | Half of 10+ strangers can repeat the hook |

**Needed from Yash for C3:** the reference PC spec and an Android phone to test on.
