extends GutTest
## The infected against structures and the shelter: blocking, piles,
## climbing (D12), and how a night ends (spec edge cases 6a–10).

var sim: FieldSim
var shambler: EnemyDefinition
var runner: EnemyDefinition


func before_each() -> void:
	sim = ToyTestHelpers.empty_field()
	ToyTestHelpers.park_player(sim)
	shambler = ToyContent.enemy(ToyContent.SHAMBLER)
	runner = ToyContent.enemy(ToyContent.RUNNER)


func _spawn_many(def: EnemyDefinition, x: float, count: int) -> Array[ToyEnemy]:
	var out: Array[ToyEnemy] = []
	for i: int in count:
		out.append(sim.spawn_enemy(def, x - i * 4.0))
	return out


func test_shambler_stops_at_a_wall_and_hits_it() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 700.0)
	var e: ToyEnemy = sim.spawn_enemy(shambler, 500.0)
	ToyTestHelpers.run(sim, 8.0)
	assert_eq(e.state, ToyEnemy.State.PILE)
	assert_lt(e.x, wall.left())
	assert_lt(wall.health, wall.definition.health, "it's being broken")


func test_runner_vaults_a_fence_but_stops_at_a_wall() -> void:
	var fence: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.FENCE), 500.0)
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 800.0)
	var r: ToyEnemy = sim.spawn_enemy(runner, 300.0)
	ToyTestHelpers.run(sim, 4.0)
	assert_gt(r.x, fence.right(), "over the fence")
	assert_lt(r.x, wall.left(), "held by the wall")
	assert_eq(fence.health, fence.definition.health, "didn't stop to break the fence")


func test_pile_stacks_one_body_per_step() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	_spawn_many(shambler, 500.0, 4)
	ToyTestHelpers.run(sim, 8.0)
	var pile: Array = hw.piles[-1]
	assert_eq(pile.size(), 4)
	for i: int in pile.size():
		var m: ToyEnemy = pile[i]
		assert_almost_eq(m.y, i * FieldSim.PILE_STEP, 0.6, "body %d" % i)


func test_only_the_bottom_of_a_pile_hits() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	_spawn_many(shambler, 500.0, 4)
	ToyTestHelpers.run(sim, 5.0)
	var before: float = hw.health
	ToyTestHelpers.run(sim, shambler.attack_interval + shambler.wind_up)
	var per_round: float = shambler.damage_structure * FieldSim.PILE_HITTERS
	assert_almost_eq(before - hw.health, per_round, per_round * 0.51)


func test_tall_enough_pile_climbs_over_a_wall() -> void:
	# D12: they pile on each other and climb over.
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 700.0)
	wall.health = 1.0e6
	_spawn_many(shambler, 450.0, 6)
	ToyTestHelpers.run(sim, 20.0)
	assert_gt(sim.climbs, 0)
	var over: int = 0
	for e: ToyEnemy in sim.enemies:
		if e.x > wall.right():
			over += 1
	assert_gt(over, 0, "some got over without breaking it")
	assert_true(wall.is_standing())


func test_small_pile_cannot_climb() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	hw.health = 1.0e6
	_spawn_many(shambler, 500.0, 3)
	ToyTestHelpers.run(sim, 15.0)
	assert_eq(sim.climbs, 0)


func test_pile_reaches_a_player_on_top() -> void:
	# Edge case 6a: height never protects you for long.
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	hw.health = 1.0e6
	sim.player.health = 100.0
	sim.player.x = hw.left() + 6.0
	sim.player.y = hw.height()
	sim.player.surface = hw
	# Keep firing loud so they come for the player, not the hum.
	var input: ToyInput = ToyInput.new()
	input.fire_held = true
	input.aim = Vector2(0.0, 1.0)
	_spawn_many(shambler, 400.0, 9)
	ToyTestHelpers.run(sim, 25.0, input)
	assert_lt(sim.player.health, 100.0)


func test_killing_the_bottom_drops_the_rest() -> void:
	# Edge case 6b.
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	_spawn_many(shambler, 500.0, 3)
	ToyTestHelpers.run(sim, 8.0)
	var pile: Array = hw.piles[-1]
	var bottom: ToyEnemy = pile[0]
	sim._damage_enemy(bottom, 100.0, &"gun")
	ToyTestHelpers.run(sim, 0.5)
	assert_eq(pile.size(), 2)
	for i: int in pile.size():
		var m: ToyEnemy = pile[i]
		assert_almost_eq(m.y, i * FieldSim.PILE_STEP, 0.6)


func test_falling_structure_scatters_its_pile() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 700.0)
	var crowd: Array[ToyEnemy] = _spawn_many(shambler, 500.0, 3)
	ToyTestHelpers.run(sim, 6.0)
	wall.take_damage(1.0e6)
	ToyTestHelpers.run(sim, 0.5)
	for e: ToyEnemy in crowd:
		assert_ne(e.state, ToyEnemy.State.PILE)
		assert_eq(e.y, 0.0)
	assert_false(sim.structures.has(wall), "removed from the field")
	assert_eq(sim.telemetry.structures_lost, 1)


func test_piled_enemy_leaves_when_its_target_moves_to_its_side() -> void:
	# Edge case 6c.
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	var crowd: Array[ToyEnemy] = _spawn_many(shambler, 500.0, 2)
	ToyTestHelpers.run(sim, 6.0)
	sim.sources.append(NoiseSource.new(NoiseSource.Kind.SHOT, 300.0, 100.0, 4000.0, 8.0))
	# Attacking commits them for COMMIT_TIME before they re-pick.
	ToyTestHelpers.run(sim, FieldSim.COMMIT_TIME + 2.0)
	assert_eq((hw.piles[-1] as Array).size(), 0)
	for e: ToyEnemy in crowd:
		assert_lt(e.x, 640.0, "walking back toward the shot")


func test_hiding_on_the_roof_loses_her() -> void:
	# Edge case 6d (Yash, D12): the shelter is on their path.
	sim.player.health = 100.0
	sim.player.x = sim.shelter.x
	sim.player.y = sim.shelter.height()
	sim.player.surface = sim.shelter
	_spawn_many(shambler, 300.0, 6)
	ToyTestHelpers.run(sim, 120.0)
	assert_eq(sim.result, FieldSim.Result.SHELTER_FELL)


func test_shelter_hits_have_a_tell() -> void:
	var e: ToyEnemy = sim.spawn_enemy(shambler, sim.shelter.left() - 40.0)
	var hits: Array[float] = []
	var wind_ups: Array[float] = []
	sim.attack_landed.connect(func(_en: ToyEnemy, kind: StringName) -> void:
		if kind == &"shelter":
			hits.append(sim.elapsed))
	for i: int in 600:
		sim.step(ToyTestHelpers.DT, ToyInput.new())
		if e.wind_up_left >= 0.0 and (wind_ups.is_empty() or sim.elapsed - wind_ups[wind_ups.size() - 1] > 1.0):
			wind_ups.append(sim.elapsed)
	assert_gt(hits.size(), 0)
	assert_almost_eq(hits[0] - wind_ups[0], shambler.wind_up, 0.05, "0.5 s tell before the hit")


func test_runner_never_attacks_the_player() -> void:
	sim.player.health = 100.0
	sim.player.x = 600.0
	sim.spawn_enemy(runner, 560.0)
	ToyTestHelpers.run(sim, 3.0)
	assert_eq(sim.player.health, 100.0)


func test_shambler_hits_a_player_on_the_ground() -> void:
	sim.player.health = 100.0
	sim.player.x = 600.0
	sim.spawn_enemy(shambler, 560.0)
	ToyTestHelpers.run(sim, 3.0)
	assert_lt(sim.player.health, 100.0)


func test_shot_stops_at_the_first_enemy() -> void:
	sim.player.x = 500.0
	sim.player.health = 100.0
	var near: ToyEnemy = sim.spawn_enemy(shambler, 700.0)
	var far: ToyEnemy = sim.spawn_enemy(shambler, 800.0)
	var input: ToyInput = ToyInput.new()
	input.fire_held = true
	input.aim = Vector2.RIGHT
	sim.step(ToyTestHelpers.DT, input)
	assert_lt(near.health, shambler.health)
	assert_eq(far.health, shambler.health)


func test_shot_into_the_ground_hits_nothing_but_makes_noise() -> void:
	# Edge case 11 (old numbering): shots stop at the ground and are still heard.
	sim.player.x = 500.0
	var e: ToyEnemy = sim.spawn_enemy(shambler, 900.0)
	var input: ToyInput = ToyInput.new()
	input.fire_held = true
	input.aim = Vector2(1.0, -1.0)
	sim.step(ToyTestHelpers.DT, input)
	assert_eq(e.health, shambler.health)
	assert_true(sim._shot_source.is_active())


func test_dawn_wins() -> void:
	sim = ToyTestHelpers.empty_field(2.0)
	ToyTestHelpers.run(sim, 2.5)
	assert_eq(sim.result, FieldSim.Result.DAWN)


func test_loss_beats_dawn_in_the_same_frame() -> void:
	# Edge case 9.
	sim = ToyTestHelpers.empty_field(1.0)
	ToyTestHelpers.run(sim, 1.0 - ToyTestHelpers.DT * 1.5)
	sim.player.health = 0.0
	sim.step(ToyTestHelpers.DT * 2.0, ToyInput.new())
	assert_eq(sim.result, FieldSim.Result.PLAYER_DIED)


func test_shelter_falling_beats_player_death() -> void:
	sim.player.health = 0.0
	sim.shelter.health = 0.0
	sim.step(ToyTestHelpers.DT, ToyInput.new())
	assert_eq(sim.result, FieldSim.Result.SHELTER_FELL)


func test_spawn_schedule_follows_the_night() -> void:
	var night: NightDefinition = NightDefinition.new()
	night.duration = 60.0
	var ev: SpawnEvent = SpawnEvent.new()
	ev.time = 1.0
	ev.side = 1
	ev.enemy = shambler
	ev.count = 3
	ev.interval = 1.0
	night.spawns = [ev]
	sim = ToyContent.new_field(night, null)
	ToyTestHelpers.park_player(sim)
	ToyTestHelpers.run(sim, 0.9)
	assert_eq(sim.alive_enemies(), 0)
	ToyTestHelpers.run(sim, 0.2)
	assert_eq(sim.alive_enemies(), 1)
	assert_gt(sim.enemies[0].x, FieldSim.WORLD_WIDTH, "enters at the right edge")
	ToyTestHelpers.run(sim, 2.5)
	assert_eq(sim.alive_enemies(), 3)


func test_cap_queues_spawns_instead_of_dropping_them() -> void:
	# Edge case 10.
	var night: NightDefinition = NightDefinition.new()
	night.duration = 600.0
	var ev: SpawnEvent = SpawnEvent.new()
	ev.time = 0.0
	ev.side = -1
	ev.enemy = shambler
	ev.count = FieldSim.ON_SCREEN_CAP + 10
	ev.interval = 0.05
	night.spawns = [ev]
	sim = ToyContent.new_field(night, null)
	ToyTestHelpers.park_player(sim)
	ToyTestHelpers.run(sim, 30.0)
	assert_lte(sim.alive_enemies(), FieldSim.ON_SCREEN_CAP)
	assert_eq(sim.alive_enemies() + sim.pending_spawns(), FieldSim.ON_SCREEN_CAP + 10)


func test_definitions_are_not_changed_by_play() -> void:
	var before: float = shambler.health
	var e: ToyEnemy = sim.spawn_enemy(shambler, 600.0)
	sim._damage_enemy(e, 1.0, &"gun")
	assert_eq(shambler.health, before)
	var wall_def: StructureDefinition = ToyContent.structure(ToyContent.WALL)
	var wall: ToyStructure = sim.add_structure(wall_def, 600.0)
	wall.take_damage(5.0)
	assert_eq(wall_def.health, 45.0)
