# C6: hook test kit

Files (in the project files under `stage_c/hook_test/`): `hook_clip.gif`
(480 px, 12 s), `hook_clip.mp4` (1280 px), `capsule_mock_920x430.png`.

The title on the mock, **THE HUM**, is a placeholder to make the test
realistic. It hasn't been checked for existing games or trademarks.

## Re-record the clip

```
godot --path experiments/stage_c --write-movie /tmp/clip/f.png --fixed-fps 30 -- --scene=c6 --quit=1
```

Then turn the frames into a GIF with ffmpeg (see the Stage C report).

## Protocol (Stage B 11, C6)

1. Find at least 10 people who don't know the project. Mix: people who
   play indie games on PC, and a few who don't.
2. Show the capsule for 3 seconds, then the GIF once. No explanation.
3. Ask, and write down their exact words:
   - "In one sentence, what do you do in this game?"
   - "Would you click on this in a store? Why or why not?"
   - "What does it remind you of?"
4. Score each answer: **got it** if they mention protecting someone or
   something *and* noise or drawing enemies away (any wording).
5. **Pass:** at least half say a sentence that gets it. Record the click
   answers too; they feed C2.

Bias to avoid: friends tend to be kind. Prefer strangers (a Discord for
indie games, r/playmygame, a college game club) and don't say it's yours.
