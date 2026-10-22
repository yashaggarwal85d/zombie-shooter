extends SceneTree
## EXPERIMENT tests (Stage C). Minimal assert runner so this nested project
## needs no addons. Run:
##   godot --headless --path experiments/stage_c --script res://tests/run_tests.gd

var _failures: int = 0
var _checks: int = 0


func _init() -> void:
	_test_graph_size()
	_test_routes_reach_every_level()
	_test_noise_loudest_wins()
	_test_noise_tie_goes_to_nearer()
	_test_noise_floor_falloff()
	_test_runner_ignores_noise()
	_test_nothing_heard_returns_minus_one()
	print("%d checks, %d failures" % [_checks, _failures])
	quit(1 if _failures > 0 else 0)


func _check(ok: bool, what: String) -> void:
	_checks += 1
	if not ok:
		_failures += 1
		push_error("FAIL: " + what)


func _test_graph_size() -> void:
	var b: StageCBuilding = StageCBuilding.new()
	_check(b.node_count() >= 20 and b.node_count() <= 30, "graph has 20-30 nodes (has %d)" % b.node_count())


func _test_routes_reach_every_level() -> void:
	var b: StageCBuilding = StageCBuilding.new()
	for e: Dictionary in b.entries:
		var lvl: int = e["level"]
		var start: Vector2 = b.floor_point(lvl, e["x"] as float)
		var r: PackedVector2Array = b.route(lvl, start, StageCBuilding.CHAMBER_LEVEL, b.chamber_position())
		_check(not r.is_empty(), "route from %s to chamber" % e["name"])
		var prev: Vector2 = start
		for p: Vector2 in r:
			var mid: Vector2 = (prev + p) * 0.5
			_check(b.is_walkable(p) and b.is_walkable(mid), "route from %s stays walkable at %s" % [e["name"], p])
			prev = p
		if not r.is_empty():
			_check(r[r.size() - 1] == b.chamber_position(), "route from %s ends at chamber" % e["name"])


func _src(kind: StageCNoise.Kind, level: int, x: float, loud: float, radius: float) -> StageCNoise.Source:
	return StageCNoise.Source.new(kind, level, Vector2(x, StageCBuilding.LEVEL_Y[level]), loud, radius, 1.0)


func _test_noise_loudest_wins() -> void:
	var s: Array[StageCNoise.Source] = [
		_src(StageCNoise.Kind.HUM, 1, 960.0, 1.0, 2400.0),
		_src(StageCNoise.Kind.SHOT, 1, 400.0, 1.6, 900.0),
	]
	_check(StageCNoise.pick(s, 1, Vector2(450.0, 660.0)) == 1, "near a shot, the shot wins")
	_check(StageCNoise.pick(s, 1, Vector2(1500.0, 660.0)) == 0, "far from the shot, the hum wins")


func _test_noise_tie_goes_to_nearer() -> void:
	var s: Array[StageCNoise.Source] = [
		_src(StageCNoise.Kind.LURE, 1, 400.0, 1.0, 1000.0),
		_src(StageCNoise.Kind.LURE, 1, 900.0, 2.0, 1000.0),
	]
	# At x=200: first is 1.0*0.8=0.8; second is 2.0*0.3=0.6 -> first wins.
	_check(StageCNoise.pick(s, 1, Vector2(200.0, 660.0)) == 0, "loudest perceived wins")
	var t: Array[StageCNoise.Source] = [
		_src(StageCNoise.Kind.LURE, 1, 1000.0, 1.0, 1000.0),
		_src(StageCNoise.Kind.LURE, 1, 600.0, 1.0, 1000.0),
	]
	# Listener at 800: both perceived equal (0.8); tie goes to... equal distance,
	# so move the listener 0.1 px toward the second.
	_check(StageCNoise.pick(t, 1, Vector2(799.9, 660.0)) == 1, "tie breaks to nearer")


func _test_noise_floor_falloff() -> void:
	var shot: StageCNoise.Source = _src(StageCNoise.Kind.SHOT, 2, 500.0, 1.0, 1000.0)
	var same: float = StageCNoise.perceived(shot, 2, Vector2(500.0, 0.0))
	var one: float = StageCNoise.perceived(shot, 1, Vector2(500.0, 0.0))
	var two: float = StageCNoise.perceived(shot, 0, Vector2(500.0, 0.0))
	_check(is_equal_approx(one, same * StageCNoise.FLOOR_FALLOFF), "one floor of falloff")
	_check(two < one and two > StageCNoise.HEARING_THRESHOLD, "two floors quieter but still audible at point blank")


func _test_runner_ignores_noise() -> void:
	var sim: StageCHordeSim = StageCHordeSim.new(0, 7)
	sim.scripted_noise = false
	var a: StageCHordeSim.Agent = StageCHordeSim.Agent.new()
	a.kind = StageCHordeSim.AgentKind.RUNNER
	a.level = 0
	a.position = sim.building.floor_point(0, 300.0)
	sim.agents.append(a)
	sim.add_source(StageCNoise.Kind.LURE, 0, 320.0, 5.0, 2000.0, 10.0)
	sim.step(0.016)
	_check(a.target == sim.hum, "runner targets the chamber despite a loud lure next to it")


func _test_nothing_heard_returns_minus_one() -> void:
	var s: Array[StageCNoise.Source] = [_src(StageCNoise.Kind.SHOT, 2, 200.0, 1.0, 300.0)]
	_check(StageCNoise.pick(s, 0, Vector2(1700.0, 890.0)) == -1, "out of range returns -1")
