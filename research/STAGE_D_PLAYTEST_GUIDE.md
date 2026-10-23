# Combat toy: how to play it and what to note

Build of 22 October 2026 (PR #5). Allow about 20–30 minutes.

## Install

- **Windows:** unzip `stage_d/builds/StageD-toy-windows.zip` in project files (or run the project in Godot 4.7.2 and press F5) and run `ZombieShooter.exe`. If you get a black screen or a crash, run `run_compatibility.bat` instead, and tell me which one worked. That also answers the Mobile vs Compatibility renderer question.
- **Android:** install `stage_d/builds/StageD-toy-android.apk` in project files. There are **no touch controls yet** (the spec leaves them out of the toy), so you need a Bluetooth gamepad or keyboard. Otherwise, just check that it launches and note how smooth it looks. The phone model and frame rate are still open questions from Stage C.

## Controls

| Action | Keyboard and mouse | Gamepad |
|---|---|---|
| Move | A / D | Left stick or D-pad |
| Jump | Space | A |
| Ladders, and drop off a top | W / S | Left stick up/down |
| Aim and fire | Mouse, left click | Right stick, right trigger |
| Melee | F | X |
| Reload | R | Y |
| Swap barrel, loud or quiet (1.5 s) | E | B |
| Build: cycle the marker you're standing at | E | B |
| Start the night | Enter | Back |
| Pause / debug overlay | Esc / F3 | Start / — |

## The loop

1. **Day:** you have 8 scrap and 3 build spots on each side of the cabin. Each spot cycles through fence (1), wall (2), high wall (3), high wall with ladder (4) and empty. You can walk, jump and climb on what you build before committing.
2. **Night (4 minutes):** the infected come from both sides. Shamblers go to the loudest thing they hear: the cabin's hum, or your gunshots. Runners ignore noise and go straight for the cabin. Blocked enemies hit the structure and pile on each other until they can climb over it, or reach you on top.
3. You lose if you die or the cabin falls. Win by reaching dawn. Each restart keeps your last layout.

## What to note (the toy gate, GDD section 13)

Write down your honest first impressions, without trying to be fair to the game:

1. **Fun:** rate holding the cabin for five minutes from 1 to 5.
2. **Deaths:** after each loss, say what got you or the cabin *before* you look at the log.
3. **Loud vs quiet:** did you switch barrels on purpose? When, and why? Or was one always better?
4. **Height:** did standing on walls or the roof feel like a choice, or like a safe spot or a trap?
5. **Feel:** is jumping or climbing clunky or floaty? Do turning crowds read as "I pulled them" or as jitter? (Press F3 to see what each one is chasing.)
6. **Difficulty:** too easy, too hard, or about right? A guess at how many tries it took.

The log is at `%APPDATA%\Godot\app_userdata\Zombie Shooter (working title)\toy_log.csv`. Send it with your notes and I'll compute the loud share and the off-ground time.

The formal gate needs 4 of 5 testers, so after you play, the same build goes to four other people.
