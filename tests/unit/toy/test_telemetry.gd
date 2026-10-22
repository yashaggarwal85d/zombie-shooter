extends GutTest
## The night log the toy gate reads (spec section 3).

const PATH: String = "user://test_toy_log.csv"


func after_each() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)


func test_loud_share() -> void:
	var t: ToyTelemetry = ToyTelemetry.new()
	assert_eq(t.loud_share(), -1.0)
	t.add_shot(true, 0.3)
	t.add_shot(false, 0.3)
	t.add_shot(false, 0.3)
	assert_almost_eq(t.loud_share(), 1.0 / 3.0, 0.001)


func test_row_matches_the_header() -> void:
	var t: ToyTelemetry = ToyTelemetry.new()
	assert_eq(t.row("b", "d").size(), ToyTelemetry.COLUMNS.size())


func test_appends_rows_with_one_header() -> void:
	var t: ToyTelemetry = ToyTelemetry.new()
	t.result = &"dawn"
	assert_eq(t.append_to(PATH, "test", "today"), OK)
	assert_eq(t.append_to(PATH, "test", "today"), OK)
	var text: String = FileAccess.get_file_as_string(PATH)
	var lines: PackedStringArray = text.strip_edges().split("\n")
	assert_eq(lines.size(), 3)
	assert_true(lines[0].begins_with("build,"))


func test_a_scripted_night_logs_its_shots_and_height() -> void:
	var sim: FieldSim = ToyTestHelpers.empty_field(5.0)
	sim.spawn_enemy(ToyContent.enemy(ToyContent.SHAMBLER), 900.0)
	var input: ToyInput = ToyInput.new()
	input.fire_held = true
	input.aim = Vector2.RIGHT
	ToyTestHelpers.run(sim, 1.0, input)
	input.swap_pressed = true
	sim.step(ToyTestHelpers.DT, input)
	input.swap_pressed = false
	ToyTestHelpers.run(sim, 3.0, input)
	var t: ToyTelemetry = sim.telemetry
	assert_gt(t.loud_shots, 0)
	assert_gt(t.quiet_shots, 0)
	assert_eq(t.swaps, 1)
	assert_true(t.loud_share() > 0.0 and t.loud_share() < 1.0)
