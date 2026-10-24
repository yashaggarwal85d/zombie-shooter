extends GutTest
## Short versions of tools/toy/soak.gd that run in CI: the rules hold over
## whole scripted nights, and the logic stays cheap.

func test_scripted_night_breaks_no_rules() -> void:
	var stats: Dictionary = ToySoak.run_night(7, [0, 1, 2, 4, 0, 1], 1.0 / 30.0, 0.25)
	assert_true(stats["ended"] as bool)
	assert_eq(stats["violations"], 0, ToySoak.describe(stats))
	assert_lt(stats["p99_ms"] as float, 2.0)


func test_passive_night_loses_the_shelter() -> void:
	var stats: Dictionary = ToySoak.run_night(8, [2, 2, 2, 2, 2, 2], 1.0 / 30.0, 0.0, true)
	assert_eq(stats["result"], &"shelter_fell", ToySoak.describe(stats))
	assert_eq(stats["violations"], 0, ToySoak.describe(stats))


func test_hatchet_night_bounces_and_breaks_no_rules() -> void:
	# D14: down-strikes knock bodies off piles without anyone ending up
	# inside a structure or floating.
	var stats: Dictionary = ToySoak.run_night(9, [4, 0, 2, 2, 0, 1], 1.0 / 30.0, 0.25, false, 600.0, true)
	assert_eq(stats["violations"], 0, ToySoak.describe(stats))
	assert_gt(stats["bounces"] as int, 0, ToySoak.describe(stats))
	assert_gt(stats["knockoffs"] as int, 0, ToySoak.describe(stats))
