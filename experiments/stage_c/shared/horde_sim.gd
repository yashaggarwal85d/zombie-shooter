class_name StageCHordeSim
extends RefCounted
## EXPERIMENT (Stage C, C3/C4). Engine-independent horde logic: agents follow
## the noise rule and path along the waypoint graph. Rendering lives in the
## scenes that own a sim, so the same logic is soak-tested headless (C4) and
## drawn under lights and fog (C3).

enum AgentKind { SHAMBLER, RUNNER }
enum State { WALK, LINGER, DEAD }

const SHAMBLER_SPEED: float = 40.0
const RUNNER_SPEED: float = 140.0
const STAIR_SPEED_FACTOR: float = 0.6
const REPLAN_INTERVAL: float = 0.5
const ARRIVE_DISTANCE: float = 2.0
const STUCK_WINDOW: float = 2.0
const STUCK_MIN_MOVE: float = 2.0
const NIGHT_LENGTH: float = 120.0
const RUNNER_SHARE: float = 0.2
## An agent keeps walking to where it last heard a pulse for this long after
## the pulse ends. Without it, crowds dither between gunfire and the hum (the
## first soak logged 34 stuck agents doing exactly that).
const MEMORY: float = 3.0
## A new sound must be this much louder than the current one to steal an agent.
const HYSTERESIS: float = 1.25


class Agent:
	extends RefCounted
	var kind: AgentKind
	var state: State = State.WALK
	var level: int
	var position: Vector2
	var path: PackedVector2Array = PackedVector2Array()
	var path_index: int = 0
	var target: StageCNoise.Source = null
	var replan_in: float = 0.0
	var memory_left: float = 0.0
	var linger_left: float = 0.0
	var respawn_in: float = 0.0
	var stuck_anchor: Vector2
	var stuck_timer: float = 0.0
	## Small per-agent offset so a crowd doesn't draw as one dot.
	var spread: float = 0.0
	var replanned_in_window: bool = false
	var heading: float = 0.0


var building: StageCBuilding = StageCBuilding.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var agents: Array[Agent] = []
var sources: Array[StageCNoise.Source] = []
var hum: StageCNoise.Source
var open_entries: Array[Dictionary] = []
## When false, the scripted player and lures stay silent (manual control).
var scripted_noise: bool = true
## Debug check that every agent stays on a floor or stair (costs time).
var validate_geometry: bool = true

var elapsed: float = 0.0
var night_left: float = 0.0
var player_level: int = 1
var player_x: float = 960.0
var _player_move_in: float = 0.0
var _burst_in: float = 0.0
var _burst_shots: int = 0
var _shot_in: float = 0.0
var _lure_in: float = 20.0

# Metrics.
var chamber_hits: int = 0
var other_arrivals: int = 0
var stuck_events: int = 0
var path_failures: int = 0
var off_geometry: int = 0
var unheard_fallbacks: int = 0
var replans: int = 0
var target_switches: int = 0
## Times an agent turned round because a different sound won.
var reversals: int = 0
var stuck_log: Array[String] = []
var targets_by_kind: Dictionary = {}


func _init(agent_count: int, seed_value: int = 1) -> void:
	rng.seed = seed_value
	hum = StageCNoise.Source.new(StageCNoise.Kind.HUM, StageCBuilding.CHAMBER_LEVEL,
			building.chamber_position(), 1.0, 2400.0, INF)
	sources.append(hum)
	for k: int in StageCNoise.Kind.size():
		targets_by_kind[k] = 0
	_start_night()
	for i: int in agent_count:
		var a: Agent = Agent.new()
		a.kind = AgentKind.RUNNER if rng.randf() < RUNNER_SHARE else AgentKind.SHAMBLER
		a.spread = rng.randf_range(-10.0, 10.0)
		_spawn(a)
		a.replan_in = rng.randf() * REPLAN_INTERVAL
		agents.append(a)


func _start_night() -> void:
	night_left = NIGHT_LENGTH
	var pool: Array[Dictionary] = building.entries.duplicate()
	open_entries.clear()
	var count: int = rng.randi_range(3, 4)
	for i: int in count:
		open_entries.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))


func _spawn(a: Agent) -> void:
	var e: Dictionary = open_entries[rng.randi_range(0, open_entries.size() - 1)]
	a.state = State.WALK
	a.level = e["level"] as int
	a.position = building.floor_point(a.level, e["x"] as float)
	a.path = PackedVector2Array()
	a.path_index = 0
	a.target = null
	a.replan_in = 0.0
	a.stuck_anchor = a.position
	a.stuck_timer = 0.0


func add_source(kind: StageCNoise.Kind, level: int, x: float, loudness: float, radius: float, duration: float) -> StageCNoise.Source:
	var s: StageCNoise.Source = StageCNoise.Source.new(kind, level, building.floor_point(level, x), loudness, radius, duration)
	sources.append(s)
	return s


func step(dt: float) -> void:
	elapsed += dt
	night_left -= dt
	if night_left <= 0.0:
		_start_night()
	if scripted_noise:
		_script_player(dt)
	for i: int in range(sources.size() - 1, -1, -1):
		var s: StageCNoise.Source = sources[i]
		s.time_left -= dt
		if s.time_left <= 0.0:
			sources.remove_at(i)
	for a: Agent in agents:
		_step_agent(a, dt)


## A stand-in player: wanders between floors, alternates loud bursts with
## quiet spells, and drops a lure every ~20 s.
func _script_player(dt: float) -> void:
	_player_move_in -= dt
	if _player_move_in <= 0.0:
		_player_move_in = rng.randf_range(6.0, 12.0)
		player_level = rng.randi_range(0, 2)
		player_x = rng.randf_range(300.0, 1600.0)
	_burst_in -= dt
	if _burst_in <= 0.0:
		_burst_in = rng.randf_range(3.0, 7.0)
		_burst_shots = rng.randi_range(2, 5)
	_shot_in -= dt
	if _burst_shots > 0 and _shot_in <= 0.0:
		_shot_in = 0.35
		_burst_shots -= 1
		add_source(StageCNoise.Kind.SHOT, player_level, player_x, 1.6, 900.0, 0.4)
	_lure_in -= dt
	if _lure_in <= 0.0:
		_lure_in = rng.randf_range(15.0, 25.0)
		var lvl: int = rng.randi_range(0, 2)
		add_source(StageCNoise.Kind.LURE, lvl, rng.randf_range(300.0, 1600.0), 2.5, 1400.0, 6.0)


func _step_agent(a: Agent, dt: float) -> void:
	match a.state:
		State.DEAD:
			a.respawn_in -= dt
			if a.respawn_in <= 0.0:
				_spawn(a)
			return
		State.LINGER:
			a.linger_left -= dt
			if a.linger_left <= 0.0:
				a.state = State.WALK
				a.target = null
				a.replan_in = 0.0
			return

	var on_floor: bool = _on_level_line(a.position)
	a.replan_in -= dt
	if a.target != null and a.target.time_left <= 0.0:
		a.memory_left -= dt
		if a.memory_left <= 0.0:
			a.replan_in = 0.0 # forgot the sound it was following
	if a.replan_in <= 0.0 and on_floor:
		a.replan_in = REPLAN_INTERVAL
		_replan(a)

	if a.path_index >= a.path.size():
		_arrive(a)
		return
	var goal: Vector2 = a.path[a.path_index]
	var speed: float = RUNNER_SPEED if a.kind == AgentKind.RUNNER else SHAMBLER_SPEED
	if not is_equal_approx(goal.y, a.position.y):
		speed *= STAIR_SPEED_FACTOR
	a.position = a.position.move_toward(goal, speed * dt)
	if a.position.distance_to(goal) <= ARRIVE_DISTANCE:
		a.position = goal
		a.path_index += 1
		var lvl: int = _level_of(a.position)
		if lvl >= 0:
			a.level = lvl
	if validate_geometry and not building.is_walkable(a.position):
		off_geometry += 1

	a.stuck_timer += dt
	if a.stuck_timer >= STUCK_WINDOW:
		# Stuck = kept the same route for the whole window and still didn't move.
		# Turning round because a new sound won is behaviour, counted separately.
		if not a.replanned_in_window and a.position.distance_to(a.stuck_anchor) < STUCK_MIN_MOVE and a.path_index < a.path.size():
			stuck_events += 1
			if stuck_log.size() < 12:
				stuck_log.append("t=%.1f kind=%d lvl=%d pos=%s target=%s path=%s i=%d" % [elapsed, a.kind, a.level, a.position, StageCNoise.Kind.keys()[a.target.kind] if a.target else "none", a.path, a.path_index])
		a.stuck_anchor = a.position
		a.stuck_timer = 0.0
		a.replanned_in_window = false


func _replan(a: Agent) -> void:
	replans += 1
	var chosen: StageCNoise.Source
	if a.kind == AgentKind.RUNNER:
		chosen = hum # runners ignore noise
	else:
		var i: int = StageCNoise.pick(sources, a.level, a.position)
		if i < 0:
			unheard_fallbacks += 1
			chosen = hum
		else:
			chosen = sources[i]
	if chosen == a.target and a.path_index < a.path.size():
		return
	if a.target != null and a.path_index < a.path.size() and (a.target.time_left > 0.0 or a.memory_left > 0.0):
		var current: float = StageCNoise.perceived(a.target, a.level, a.position)
		if a.target.time_left <= 0.0:
			current *= a.memory_left / MEMORY
		if StageCNoise.perceived(chosen, a.level, a.position) <= HYSTERESIS * current:
			return
		target_switches += 1
	a.target = chosen
	a.memory_left = MEMORY
	targets_by_kind[chosen.kind] = (targets_by_kind[chosen.kind] as int) + 1
	a.path = building.route(a.level, a.position, chosen.level, chosen.position)
	a.path_index = 0
	a.replanned_in_window = true
	if a.path.is_empty():
		path_failures += 1
		return
	var new_heading: float = signf(a.path[0].x - a.position.x)
	if a.heading != 0.0 and new_heading != 0.0 and new_heading != a.heading:
		reversals += 1
	a.heading = new_heading


func _arrive(a: Agent) -> void:
	if a.target == null:
		a.replan_in = 0.0
		return
	if a.target == hum:
		chamber_hits += 1
		a.state = State.DEAD
		a.respawn_in = rng.randf_range(1.0, 3.0)
	else:
		other_arrivals += 1
		a.state = State.LINGER
		a.linger_left = 2.0
	a.path = PackedVector2Array()
	a.path_index = 0


func _on_level_line(p: Vector2) -> bool:
	return _level_of(p) >= 0


func _level_of(p: Vector2) -> int:
	for lvl: int in StageCBuilding.LEVEL_COUNT:
		if absf(p.y - StageCBuilding.LEVEL_Y[lvl]) < 0.01:
			return lvl
	return -1


func alive_count() -> int:
	var n: int = 0
	for a: Agent in agents:
		if a.state != State.DEAD:
			n += 1
	return n
