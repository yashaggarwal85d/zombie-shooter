extends GutTest
## The jump's feel (D14): variable height, a heavier fall, a capped fall
## speed, instant air control, and bounces that letting go doesn't cut.

var sim: FieldSim


func before_each() -> void:
	sim = ToyTestHelpers.empty_field()
	sim.player.x = 500.0


func _in(move: float = 0.0, jump: bool = false, hold: bool = false) -> ToyInput:
	var i: ToyInput = ToyInput.new()
	i.move = move
	i.jump_pressed = jump
	i.jump_held = hold
	return i


## Peak height of one jump, holding jump for `hold_frames` frames.
func _peak(hold_frames: int) -> float:
	var peak: float = 0.0
	sim.step(ToyTestHelpers.DT, _in(0.0, true, hold_frames > 0))
	for n: int in 120:
		sim.step(ToyTestHelpers.DT, _in(0.0, false, n + 1 < hold_frames))
		peak = maxf(peak, sim.player.y)
	return peak


func test_a_tap_is_a_short_hop() -> void:
	var peak: float = _peak(0)
	assert_between(peak, 45.0, 75.0, "about 60 px")
	assert_lt(peak, ToyContent.structure(ToyContent.FENCE).height + 5.0, "barely a fence")


func test_holding_gives_the_full_jump() -> void:
	var peak: float = _peak(60)
	assert_between(peak, 130.0, 150.0, "about 140 px")
	assert_gt(peak, ToyContent.structure(ToyContent.WALL).height)
	assert_lt(peak, ToyContent.structure(ToyContent.HIGH_WALL).height)
	assert_lt(peak, ToyContent.structure(ToyContent.SHELTER).height)


func test_releasing_midway_gives_a_middle_height() -> void:
	var short: float = _peak(0)
	before_each()
	var mid: float = _peak(3)
	before_each()
	var full: float = _peak(60)
	assert_gt(mid, short + 10.0)
	assert_lt(mid, full - 10.0)


func test_falls_faster_than_it_rises() -> void:
	var rise_frames: int = 0
	var fall_frames: int = 0
	sim.step(ToyTestHelpers.DT, _in(0.0, true, true))
	rise_frames = 1
	while sim.player.vy > 0.0:
		sim.step(ToyTestHelpers.DT, _in(0.0, false, true))
		rise_frames += 1
	while not sim.player.supported():
		sim.step(ToyTestHelpers.DT, _in(0.0, false, true))
		fall_frames += 1
	assert_lt(fall_frames, rise_frames, "rise %d frames, fall %d" % [rise_frames, fall_frames])


func test_fall_speed_is_capped() -> void:
	sim.player.y = 3000.0
	sim.player.grounded = false
	var fastest: float = 0.0
	for n: int in 120:
		sim.step(ToyTestHelpers.DT, _in())
		fastest = maxf(fastest, -sim.player.vy)
	assert_almost_eq(fastest, ToyPlayer.MAX_FALL_SPEED, 0.01)


func test_turns_instantly_in_the_air() -> void:
	sim.step(ToyTestHelpers.DT, _in(1.0, true, true))
	ToyTestHelpers.run(sim, 0.1, _in(1.0, false, true))
	assert_true(sim.player.is_off_ground())
	var x0: float = sim.player.x
	sim.step(ToyTestHelpers.DT, _in(-1.0, false, true))
	assert_almost_eq(sim.player.x, x0 - ToyPlayer.SPEED * ToyTestHelpers.DT, 0.01, "no momentum to undo")
	assert_eq(sim.player.facing, -1)


func test_a_bounce_is_not_cut_by_letting_go() -> void:
	sim.player.y = 100.0
	sim.player.grounded = false
	sim.player.bounce(FieldSim.BOUNCE_VELOCITY)
	sim.step(ToyTestHelpers.DT, _in())
	assert_gt(sim.player.vy, ToyPlayer.JUMP_CUT_VELOCITY)


func test_landing_is_counted_for_the_squash() -> void:
	sim.step(ToyTestHelpers.DT, _in(0.0, true, true))
	ToyTestHelpers.run(sim, 1.0, _in(0.0, false, true))
	assert_eq(sim.player.landings, 1)
	assert_gt(sim.player.last_land_speed, 0.0)
