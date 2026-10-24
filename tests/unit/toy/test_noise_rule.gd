extends GutTest
## GDD section 5 and spec edge cases 1–5.

func _src(x: float, loudness: float, radius: float, time_left: float = 1.0) -> NoiseSource:
	return NoiseSource.new(NoiseSource.Kind.SHOT, x, loudness, radius, time_left)


func test_perceived_falls_off_linearly_with_distance() -> void:
	var s: NoiseSource = _src(100.0, 80.0, 1000.0)
	assert_almost_eq(NoiseRule.perceived(s, 100.0), 80.0, 0.001)
	assert_almost_eq(NoiseRule.perceived(s, 600.0), 40.0, 0.001)
	assert_almost_eq(NoiseRule.perceived(s, -400.0), 40.0, 0.001, "distance is horizontal, either side")


func test_nothing_heard_beyond_the_radius() -> void:
	assert_eq(NoiseRule.perceived(_src(0.0, 80.0, 500.0), 501.0), 0.0)
	assert_null(NoiseRule.loudest([_src(0.0, 80.0, 500.0)], 900.0))


func test_loudest_wins() -> void:
	var quiet: NoiseSource = _src(0.0, 30.0, 1000.0)
	var loud: NoiseSource = _src(0.0, 80.0, 1000.0)
	assert_eq(NoiseRule.loudest([quiet, loud], 100.0), loud)


func test_tie_goes_to_the_nearer_source() -> void:
	# Same perceived value (40) from a nearer quiet source and a farther loud one.
	var near: NoiseSource = _src(100.0, 50.0, 500.0) # 50 * (1 - 100/500) = 40
	var far: NoiseSource = _src(600.0, 80.0, 1200.0) # 80 * (1 - 600/1200) = 40
	assert_eq(NoiseRule.loudest([far, near], 0.0), near)
	assert_eq(NoiseRule.loudest([near, far], 0.0), near)


func test_finished_sources_are_ignored_by_loudest() -> void:
	assert_null(NoiseRule.loudest([_src(0.0, 80.0, 1000.0, 0.0)], 0.0))


func test_hysteresis_keeps_the_current_target() -> void:
	var current: NoiseSource = _src(0.0, 40.0, 4000.0, INF)
	var slightly_louder: NoiseSource = _src(0.0, 45.0, 4000.0)
	var much_louder: NoiseSource = _src(0.0, 60.0, 4000.0)
	assert_false(NoiseRule.should_switch(current, 3.0, 3.0, slightly_louder, 0.0, 1.25))
	assert_true(NoiseRule.should_switch(current, 3.0, 3.0, much_louder, 0.0, 1.25))


func test_memory_holds_a_stopped_sound_then_fades() -> void:
	var stopped: NoiseSource = _src(0.0, 80.0, 1000.0, 0.0)
	var hum: NoiseSource = _src(0.0, 40.0, 4000.0, INF)
	assert_false(NoiseRule.should_switch(stopped, 3.0, 3.0, hum, 0.0, 1.25), "fresh memory: the gunshot still wins")
	assert_true(NoiseRule.should_switch(stopped, 0.5, 3.0, hum, 0.0, 1.25), "faded memory: the hum takes over")
	assert_true(NoiseRule.should_switch(stopped, 0.0, 3.0, hum, 0.0, 1.25), "forgotten")


func test_quiet_shot_does_not_steal_from_the_hum() -> void:
	# Edge case 5: a suppressed shot right next to a shambler heading for the hum.
	var sim: FieldSim = ToyTestHelpers.empty_field()
	var hum_pull: float = NoiseRule.perceived(sim.hum, 600.0)
	var quiet: WeaponComponent = load(ToyContent.SUPPRESSOR) as WeaponComponent
	var shot: NoiseSource = _src(600.0, quiet.noise_loudness, quiet.noise_radius)
	assert_false(NoiseRule.should_switch(sim.hum, 3.0, 3.0, shot, 600.0, FieldSim.HYSTERESIS),
		"quiet %.1f vs hum %.1f" % [quiet.noise_loudness, hum_pull])


func test_loud_shot_steals_nearby_shamblers() -> void:
	var sim: FieldSim = ToyTestHelpers.empty_field()
	var loud: WeaponComponent = load(ToyContent.OPEN_BARREL) as WeaponComponent
	var shot: NoiseSource = _src(500.0, loud.noise_loudness, loud.noise_radius)
	assert_true(NoiseRule.should_switch(sim.hum, 3.0, 3.0, shot, 600.0, FieldSim.HYSTERESIS))


func test_runners_ignore_noise_in_the_field() -> void:
	var sim: FieldSim = ToyTestHelpers.empty_field()
	ToyTestHelpers.park_player(sim)
	var r: ToyEnemy = sim.spawn_enemy(ToyContent.enemy(ToyContent.RUNNER), 200.0)
	sim.sources.append(_src(100.0, 100.0, 4000.0, 10.0))
	ToyTestHelpers.run(sim, 1.0)
	assert_eq(r.target, sim.hum)
	assert_gt(r.x, 200.0, "still heading for the shelter")


func test_shambler_follows_a_loud_shot_then_returns_to_the_hum() -> void:
	var sim: FieldSim = ToyTestHelpers.empty_field()
	ToyTestHelpers.park_player(sim)
	var s: ToyEnemy = sim.spawn_enemy(ToyContent.enemy(ToyContent.SHAMBLER), 400.0)
	var shot: NoiseSource = _src(100.0, 80.0, 1200.0, 0.3)
	sim.sources.append(shot)
	ToyTestHelpers.run(sim, 1.0)
	assert_eq(s.target, shot)
	assert_lt(s.x, 400.0, "walked toward the shot")
	ToyTestHelpers.run(sim, FieldSim.MEMORY + 1.0)
	assert_eq(s.target, sim.hum, "forgot the shot after its memory ran out")
