extends SceneTree
## Headless soak for the combat toy (spec section 5): a scripted player plays
## nights on several layouts at a fixed 60 Hz step. Prints one line a night
## and fails if a rule check breaks.
## Usage: godot --headless --path . --script res://tools/toy/soak.gd [-- nights]

const DT: float = 1.0 / 60.0


func _initialize() -> void:
	var nights: int = 3
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() > 0:
		nights = int(args[0])
	var failures: int = 0
	var layouts: Array[Array] = [
		[0, 1, 2, 0, 0, 4],
		[4, 0, 2, 2, 0, 1],
		[1, 1, 1, 1, 1, 1],
	]
	for n: int in nights:
		var layout: Array = layouts[n % layouts.size()]
		# Every third night the bot hides on the roof and never fires; the rest
		# it fires at 1/4 of frames so the infected get through sometimes.
		var passive: bool = n % 3 == 2
		var stats: Dictionary = ToySoak.run_night(n + 1, layout, DT, 0.25, passive)
		if passive and stats["result"] != &"shelter_fell":
			print("  FAIL: hiding on the roof should lose the shelter (D12)")
			failures += 1
		print(ToySoak.describe(stats))
		failures += stats["violations"] as int
	print("soak: %d nights, %d rule violations" % [nights, failures])
	quit(1 if failures > 0 else 0)
