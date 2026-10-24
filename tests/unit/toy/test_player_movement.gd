extends GutTest
## Jump, ladders, standing on structures (D11) and edge cases 6, 7, 11, 15.

var sim: FieldSim


func before_each() -> void:
	sim = ToyTestHelpers.empty_field()
	sim.player.x = 500.0


## Jump is held unless `hold` is false, so these tests get full jumps.
func _in(move: float = 0.0, climb: float = 0.0, jump: bool = false, hold: bool = true) -> ToyInput:
	var i: ToyInput = ToyInput.new()
	i.move = move
	i.climb = climb
	i.jump_pressed = jump
	i.jump_held = hold
	return i


func _jump_peak() -> float:
	var peak: float = 0.0
	sim.step(ToyTestHelpers.DT, _in(0.0, 0.0, true))
	for n: int in 90:
		sim.step(ToyTestHelpers.DT, _in())
		peak = maxf(peak, sim.player.y)
	return peak


func test_walks_both_ways() -> void:
	ToyTestHelpers.run(sim, 1.0, _in(1.0))
	assert_almost_eq(sim.player.x, 500.0 + ToyPlayer.SPEED, 5.0)
	ToyTestHelpers.run(sim, 1.0, _in(-1.0))
	assert_almost_eq(sim.player.x, 500.0, 5.0)


func test_jump_clears_a_wall_but_not_a_high_wall() -> void:
	var peak: float = _jump_peak()
	assert_gt(peak, ToyContent.structure(ToyContent.WALL).height, "can jump onto a wall")
	assert_lt(peak, ToyContent.structure(ToyContent.HIGH_WALL).height, "a high wall needs a ladder")
	assert_lt(peak, ToyContent.structure(ToyContent.SHELTER).height, "so does the roof")
	assert_eq(sim.player.y, 0.0, "landed")


func test_walls_block_walking() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 600.0)
	ToyTestHelpers.run(sim, 2.0, _in(1.0))
	assert_almost_eq(sim.player.x, wall.left() - ToyPlayer.HALF_WIDTH, 1.0)


func test_jump_onto_a_wall_and_stand_on_it() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 560.0)
	sim.step(ToyTestHelpers.DT, _in(1.0, 0.0, true))
	ToyTestHelpers.run(sim, 0.25, _in(1.0))
	ToyTestHelpers.run(sim, 0.6, _in())
	assert_eq(sim.player.surface, wall)
	assert_almost_eq(sim.player.y, wall.height(), 0.01)


func test_ladder_climbs_a_high_wall_and_steps_onto_it() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 560.0, true)
	sim.player.x = hw.left() - ToyPlayer.HALF_WIDTH - 5.0
	ToyTestHelpers.run(sim, 1.5, _in(0.0, 1.0))
	assert_eq(sim.player.surface, hw)
	assert_almost_eq(sim.player.y, hw.height(), 0.01)


func test_no_ladder_means_no_climbing() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 560.0, false)
	sim.player.x = hw.left() - ToyPlayer.HALF_WIDTH - 5.0
	ToyTestHelpers.run(sim, 1.0, _in(0.0, 1.0))
	assert_eq(sim.player.y, 0.0)


func test_climb_up_away_from_a_ladder_does_nothing() -> void:
	sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 900.0, true)
	ToyTestHelpers.run(sim, 0.5, _in(0.0, 1.0))
	assert_eq(sim.player.y, 0.0)
	assert_null(sim.player.ladder)


func test_shelter_roof_reached_by_its_ladder() -> void:
	sim.player.x = sim.shelter.left() - ToyPlayer.HALF_WIDTH
	ToyTestHelpers.run(sim, 1.5, _in(0.0, 1.0))
	assert_eq(sim.player.surface, sim.shelter)


func test_player_walks_through_the_shelter_door() -> void:
	sim.player.x = sim.shelter.left() - 40.0
	ToyTestHelpers.run(sim, 2.0, _in(1.0))
	assert_gt(sim.player.x, sim.shelter.right())


func test_drop_through_a_top_with_down() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 500.0)
	sim.player.y = wall.height()
	sim.player.surface = wall
	ToyTestHelpers.run(sim, 0.6, _in(0.0, -1.0))
	assert_eq(sim.player.y, 0.0)


func test_falls_when_the_structure_under_it_breaks() -> void:
	# Edge case 6.
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 500.0)
	sim.player.y = wall.height()
	sim.player.surface = wall
	wall.take_damage(1000.0)
	ToyTestHelpers.run(sim, 0.6)
	assert_eq(sim.player.y, 0.0)
	assert_null(sim.player.surface)


func test_ladder_falls_with_its_wall() -> void:
	# Edge case 7.
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 560.0, true)
	sim.player.x = hw.left() - ToyPlayer.HALF_WIDTH
	ToyTestHelpers.run(sim, 0.3, _in(0.0, 1.0))
	assert_eq(sim.player.ladder, hw)
	hw.take_damage(1000.0)
	ToyTestHelpers.run(sim, 1.0)
	assert_null(sim.player.ladder)
	assert_eq(sim.player.y, 0.0)


func test_cannot_stand_on_the_infected() -> void:
	# Edge case 11: enemies aren't platforms.
	sim.spawn_enemy(ToyContent.enemy(ToyContent.SHAMBLER), 500.0)
	sim.player.y = 100.0
	sim.player.grounded = false
	ToyTestHelpers.run(sim, 0.5)
	assert_eq(sim.player.y, 0.0)


func test_off_ground_time_is_counted() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 500.0)
	sim.player.y = wall.height()
	sim.player.surface = wall
	ToyTestHelpers.run(sim, 2.0)
	assert_almost_eq(sim.telemetry.off_ground_time, 2.0, 0.05)
	assert_almost_eq(sim.telemetry.height_time[&"wall"], 2.0, 0.05)
