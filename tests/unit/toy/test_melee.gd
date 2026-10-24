extends GutTest
## The hatchet (D14): three swing directions, hit-stop, recoil, knockback that
## never crosses a structure, and the down-strike bounce that knocks the top
## body off a pile.

var sim: FieldSim
var shambler: EnemyDefinition


func before_each() -> void:
	sim = ToyTestHelpers.empty_field()
	sim.player.x = 500.0
	sim.player.health = 1.0e9
	shambler = ToyContent.enemy(ToyContent.SHAMBLER)


func _swing(climb: float = 0.0) -> ToyInput:
	var i: ToyInput = ToyInput.new()
	i.melee_pressed = true
	i.climb = climb
	return i


func _airborne(y: float) -> void:
	sim.player.y = y
	sim.player.vy = 0.0
	sim.player.grounded = false
	sim.player.surface = null


func _hit(e: ToyEnemy) -> bool:
	return e.health < shambler.health


func test_forward_swing_hits_in_front_not_behind() -> void:
	var front: ToyEnemy = sim.spawn_enemy(shambler, 550.0)
	var behind: ToyEnemy = sim.spawn_enemy(shambler, 450.0)
	sim.step(ToyTestHelpers.DT, _swing())
	assert_eq(sim.swing_dir, Vector2i(1, 0))
	assert_true(_hit(front))
	assert_false(_hit(behind))


func test_up_swing_hits_above_and_forward_does_not() -> void:
	var above: ToyEnemy = sim.spawn_enemy(shambler, 510.0)
	above.y = ToyPlayer.HEIGHT + 30.0
	sim.step(ToyTestHelpers.DT, _swing())
	assert_false(_hit(above), "too high for a forward swing")
	ToyTestHelpers.run(sim, FieldSim.MELEE_COOLDOWN + 0.1)
	above.y = ToyPlayer.HEIGHT + 30.0
	sim.step(ToyTestHelpers.DT, _swing(1.0))
	assert_eq(sim.swing_dir, Vector2i(0, 1))
	assert_true(_hit(above))


func test_down_swing_only_in_the_air() -> void:
	sim.step(ToyTestHelpers.DT, _swing(-1.0))
	assert_eq(sim.swing_dir, Vector2i(1, 0), "on the ground, down + melee swings forward")
	ToyTestHelpers.run(sim, FieldSim.MELEE_COOLDOWN + 0.1)
	_airborne(200.0)
	var below: ToyEnemy = sim.spawn_enemy(shambler, 505.0)
	below.y = 130.0
	sim.step(ToyTestHelpers.DT, _swing(-1.0))
	assert_eq(sim.swing_dir, Vector2i(0, -1))
	assert_true(_hit(below))


func test_one_swing_hits_each_enemy_once() -> void:
	var e: ToyEnemy = sim.spawn_enemy(shambler, 540.0)
	sim.step(ToyTestHelpers.DT, _swing())
	ToyTestHelpers.run(sim, FieldSim.MELEE_ACTIVE + 0.1)
	assert_eq(e.health, shambler.health - FieldSim.MELEE_DAMAGE)


func test_swings_are_spaced_by_the_cooldown() -> void:
	var swings: Array[int] = []
	sim.melee_swung.connect(func(_x: float, _y: float, _d: Vector2i) -> void: swings.append(1))
	ToyTestHelpers.run(sim, 1.0, _swing())
	assert_eq(swings.size(), 3, "at 0, 0.35 and 0.7 s")


func test_a_hit_freezes_the_field_for_a_few_frames() -> void:
	var e: ToyEnemy = sim.spawn_enemy(shambler, 540.0)
	sim.step(ToyTestHelpers.DT, _swing())
	assert_almost_eq(sim.hit_stop_left, FieldSim.HIT_STOP, 0.0001)
	var frozen: int = 0
	var t: float = sim.elapsed
	var ex: float = e.x
	for n: int in 10:
		sim.step(ToyTestHelpers.DT, ToyInput.new())
		if sim.elapsed == t:
			frozen += 1
			assert_eq(e.x, ex, "the infected hold still too")
		t = sim.elapsed
	assert_between(frozen, 2, 4, "about 3 frames at 60 fps")


func test_a_miss_does_not_freeze() -> void:
	sim.step(ToyTestHelpers.DT, _swing())
	assert_eq(sim.hit_stop_left, 0.0)


func test_a_forward_hit_recoils_the_player() -> void:
	sim.spawn_enemy(shambler, 540.0)
	sim.step(ToyTestHelpers.DT, _swing())
	ToyTestHelpers.run(sim, 0.3)
	assert_lt(sim.player.x, 500.0 - 15.0)


func test_knockback_never_crosses_a_structure() -> void:
	var wall: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.WALL), 610.0)
	var e: ToyEnemy = sim.spawn_enemy(shambler, 560.0)
	sim.step(ToyTestHelpers.DT, _swing())
	assert_true(_hit(e))
	assert_lte(e.x, wall.left() - shambler.width * 0.5 + 0.01)


func test_knockback_pushes_an_enemy_away() -> void:
	var e: ToyEnemy = sim.spawn_enemy(shambler, 540.0)
	e.heading = -1
	sim.step(ToyTestHelpers.DT, _swing())
	assert_gt(e.x, 540.0 + FieldSim.MELEE_KNOCKBACK * 0.5)


func test_down_strike_on_an_enemy_bounces() -> void:
	_airborne(200.0)
	var below: ToyEnemy = sim.spawn_enemy(shambler, 505.0)
	below.y = 130.0
	sim.step(ToyTestHelpers.DT, _swing(-1.0))
	assert_gt(sim.player.vy, FieldSim.BOUNCE_VELOCITY - 100.0)
	assert_eq(sim.bounces, 1)
	assert_eq(sim.telemetry.bounces, 1)


func test_down_strike_knocks_the_top_body_off_a_pile() -> void:
	var hw: ToyStructure = sim.add_structure(ToyContent.structure(ToyContent.HIGH_WALL), 700.0)
	hw.health = 1.0e6
	ToyTestHelpers.park_player(sim)
	for i: int in 4:
		sim.spawn_enemy(shambler, 500.0 - i * 4.0)
	ToyTestHelpers.run(sim, 8.0)
	var pile: Array = hw.piles[-1]
	assert_eq(pile.size(), 4)
	var top: ToyEnemy = pile[3]
	sim.player.x = top.x
	_airborne(top.top() + 30.0)
	sim.step(ToyTestHelpers.DT, _swing(-1.0))
	assert_eq(pile.size(), 3, "the top body is off")
	assert_false(pile.has(top))
	assert_eq(sim.telemetry.pile_knockoffs, 1)
	assert_eq(sim.bounces, 1, "and the player bounced")
	ToyTestHelpers.run(sim, 0.6)
	assert_eq(top.y, 0.0, "it fell to the ground")
	assert_lt(top.x, hw.left(), "on its own side of the wall")
	for i: int in pile.size():
		var m: ToyEnemy = pile[i]
		assert_almost_eq(m.y, i * FieldSim.PILE_STEP, 0.6, "the rest settle")


func test_kills_are_split_by_weapon() -> void:
	var e: ToyEnemy = sim.spawn_enemy(shambler, 540.0)
	e.heading = -1
	for n: int in 3:
		e.x = 540.0
		e.state = ToyEnemy.State.WALK
		sim.step(ToyTestHelpers.DT, _swing())
		ToyTestHelpers.run(sim, FieldSim.MELEE_COOLDOWN + FieldSim.HIT_STOP + 0.05)
	assert_false(e.is_alive())
	assert_eq(sim.telemetry.kills_by.get(&"melee", 0), 1)
	assert_almost_eq(sim.telemetry.melee_kill_share(), 1.0, 0.001)
	sim.telemetry.add_kill(&"shambler", &"gun")
	assert_almost_eq(sim.telemetry.melee_kill_share(), 0.5, 0.001)
