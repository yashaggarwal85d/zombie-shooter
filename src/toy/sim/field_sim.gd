class_name FieldSim
extends RefCounted
## The combat toy's rules, independent of drawing and input devices: one stop,
## the shelter in the middle, built structures, the player, the infected and
## the noise rule (research/STAGE_D_COMBAT_TOY_SPEC.md). Scenes own a FieldSim,
## feed it a ToyInput each frame, and draw what it holds. Tests and the
## headless soak step it directly.
##
## Field units: x runs along the ground (0 to WORLD_WIDTH), y is height above
## the ground (up is positive).

signal shot_fired(origin: Vector2, end: Vector2, loud: bool, hit: bool)
signal melee_swung(x: float, y: float, facing: int)
signal enemy_hit(enemy: ToyEnemy)
signal enemy_killed(enemy: ToyEnemy)
signal attack_landed(enemy: ToyEnemy, target_kind: StringName)
signal structure_destroyed(structure: ToyStructure)
signal night_ended(result: StringName)

enum Result { NONE, DAWN, PLAYER_DIED, SHELTER_FELL }

const WORLD_WIDTH: float = 2200.0
const SHELTER_X: float = 1100.0
const SPAWN_MARGIN: float = 60.0
## Distance of each build spot from the shelter's centre, per side.
const BUILD_SPOT_OFFSETS: Array[float] = [230.0, 440.0, 660.0]

# Noise rule (GDD 5; memory and hysteresis from Stage C C4, tunable, D10).
const REPLAN_INTERVAL: float = 0.5
const MEMORY: float = 3.0
const HYSTERESIS: float = 1.25
const COMMIT_TIME: float = 2.0
const HUM_LOUDNESS: float = 40.0
## Large enough that the hum is heard across the whole field.
const HUM_RADIUS: float = 4000.0
const SHOT_PULSE: float = 0.2
const MELEE_LOUDNESS: float = 20.0
const MELEE_RADIUS: float = 400.0
const BREAK_LOUDNESS: float = 50.0
const BREAK_RADIUS: float = 900.0

# Piles and climbing (D12).
## Height each body adds to a pile.
const PILE_STEP: float = 28.0
## Only the bottom of a pile can hit the structure.
const PILE_HITTERS: int = 2
const CLIMB_TIME: float = 0.5
const PILE_RISE_SPEED: float = 140.0
const FALL_SPEED: float = 500.0

# Combat.
const ENEMY_REACH: float = 18.0
const MELEE_RANGE: float = 70.0
const MELEE_DAMAGE: float = 1.0
const MELEE_COOLDOWN: float = 0.4
const MELEE_KNOCKBACK: float = 40.0
const SHOT_RANGE: float = 2600.0
## Gun height above the player's feet.
const MUZZLE_HEIGHT: float = 44.0
const ON_SCREEN_CAP: int = 40

var night: NightDefinition
var shelter: ToyStructure
var structures: Array[ToyStructure] = []
var player: ToyPlayer
var weapon: ToyWeapon
var enemies: Array[ToyEnemy] = []
var sources: Array[NoiseSource] = []
var hum: NoiseSource
var elapsed: float = 0.0
var result: Result = Result.NONE
var telemetry: ToyTelemetry = ToyTelemetry.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## How many times the infected climbed over or onto something (soak check).
var climbs: int = 0

## One persistent source each, so a burst of fire reads as one moving sound
## rather than a string of separate ones (followers track the player).
var _shot_source: NoiseSource
var _melee_source: NoiseSource
var _melee_cooldown: float = 0.0
var _pending: Array[Dictionary] = []
var _next_id: int = 1
var _last_hit_by: StringName = &""
var _last_hit_target: StringName = &""


func _init(p_night: NightDefinition, shelter_definition: StructureDefinition, barrels: Array[WeaponComponent], seed_value: int = 1) -> void:
	night = p_night
	rng.seed = seed_value
	shelter = ToyStructure.new(shelter_definition, SHELTER_X, true, true)
	shelter.destroyed.connect(_on_structure_destroyed)
	structures.append(shelter)
	hum = NoiseSource.new(NoiseSource.Kind.HUM, SHELTER_X, HUM_LOUDNESS, HUM_RADIUS, INF)
	sources.append(hum)
	_shot_source = NoiseSource.new(NoiseSource.Kind.SHOT, SHELTER_X, 0.0, 1.0, 0.0)
	_melee_source = NoiseSource.new(NoiseSource.Kind.MELEE, SHELTER_X, MELEE_LOUDNESS, MELEE_RADIUS, 0.0)
	sources.append(_shot_source)
	sources.append(_melee_source)
	player = ToyPlayer.new(SHELTER_X - 60.0)
	weapon = ToyWeapon.new(barrels)
	for ev: SpawnEvent in night.spawns:
		for i: int in ev.count:
			_pending.append({"time": ev.time + i * ev.interval, "side": ev.side, "enemy": ev.enemy})
	_pending.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return (a["time"] as float) < (b["time"] as float))


static func build_spot_xs() -> Array[float]:
	var xs: Array[float] = []
	for i: int in range(BUILD_SPOT_OFFSETS.size() - 1, -1, -1):
		xs.append(SHELTER_X - BUILD_SPOT_OFFSETS[i])
	for off: float in BUILD_SPOT_OFFSETS:
		xs.append(SHELTER_X + off)
	return xs


## Places the planned structures. Call once, before the first step.
func apply_plan(plan: BuildPlan) -> void:
	for i: int in plan.spot_xs.size():
		var option: BuildPlan.Option = plan.option_at(i)
		if option.structure == null:
			continue
		add_structure(option.structure, plan.spot_xs[i], option.ladder)
	telemetry.layout = plan.describe()


func add_structure(definition: StructureDefinition, x: float, ladder: bool = false) -> ToyStructure:
	var s: ToyStructure = ToyStructure.new(definition, x, ladder)
	s.destroyed.connect(_on_structure_destroyed)
	structures.append(s)
	return s


func spawn_enemy(definition: EnemyDefinition, x: float) -> ToyEnemy:
	var e: ToyEnemy = ToyEnemy.new(definition, x, _next_id)
	_next_id += 1
	e.heading = 1 if x < SHELTER_X else -1
	e.stop_offset = rng.randf_range(0.0, 40.0)
	e.speed_factor = rng.randf_range(0.9, 1.1)
	e.target = hum
	e.target_x = hum.x
	e.replan_in = rng.randf_range(0.0, REPLAN_INTERVAL)
	enemies.append(e)
	return e


func alive_enemies() -> int:
	var n: int = 0
	for e: ToyEnemy in enemies:
		if e.is_alive():
			n += 1
	return n


func is_over() -> bool:
	return result != Result.NONE


func time_left() -> float:
	return maxf(0.0, night.duration - elapsed)


## Spawns due within `window` seconds, per side, for the edge markers.
func upcoming(side: int, window: float) -> int:
	var n: int = 0
	for p: Dictionary in _pending:
		if (p["time"] as float) > elapsed + window:
			break
		if (p["side"] as int) == side:
			n += 1
	return n


func step(delta: float, input: ToyInput) -> void:
	if is_over():
		return
	elapsed += delta
	telemetry.duration = elapsed
	for s: NoiseSource in sources:
		if s.time_left != INF:
			s.time_left = maxf(0.0, s.time_left - delta)
	_spawn_due()
	_step_player(delta, input)
	for e: ToyEnemy in enemies:
		_step_enemy(e, delta)
	_cleanup_dead()
	_check_end()


# --- Player ---------------------------------------------------------------

func _step_player(delta: float, input: ToyInput) -> void:
	if not player.is_alive():
		return
	player.step(delta, input, structures)
	player.x = clampf(player.x, 10.0, WORLD_WIDTH - 10.0)
	weapon.step(delta)
	_melee_cooldown = maxf(0.0, _melee_cooldown - delta)
	if input.swap_pressed:
		if not weapon.is_swapping():
			telemetry.swaps += 1
		weapon.start_swap()
	if input.reload_pressed:
		weapon.start_reload()
	if input.fire_held and weapon.try_fire():
		_fire(input.aim)
	if input.melee_pressed and _melee_cooldown <= 0.0:
		_melee()
	telemetry.off_ground_time = player.air_and_height_time
	if player.surface != null:
		var key: StringName = &"roof" if player.surface.is_shelter else player.surface.definition.id
		telemetry.add_height_time(key, delta)
	elif player.ladder != null:
		telemetry.add_height_time(&"ladder", delta)


func _fire(aim: Vector2) -> void:
	var c: WeaponComponent = weapon.current()
	var dir: Vector2 = aim.normalized() if aim.length() > 0.01 else Vector2(player.facing, 0.0)
	player.facing = 1 if dir.x >= 0.0 else -1
	var origin: Vector2 = Vector2(player.x, player.y + MUZZLE_HEIGHT)
	var max_t: float = SHOT_RANGE
	if dir.y < -0.0001:
		max_t = minf(max_t, origin.y / -dir.y)
	var best: ToyEnemy = null
	var best_t: float = max_t
	for e: ToyEnemy in enemies:
		if not e.is_alive():
			continue
		var t: float = _ray_rect(origin, dir, e.rect())
		if t >= 0.0 and t < best_t:
			best_t = t
			best = e
	_shot_source.x = player.x
	_shot_source.loudness = c.noise_loudness
	_shot_source.radius = c.noise_radius
	_shot_source.time_left = SHOT_PULSE
	telemetry.add_shot(weapon.is_loud(), c.fire_interval)
	shot_fired.emit(origin, origin + dir * best_t, weapon.is_loud(), best != null)
	if best != null:
		_damage_enemy(best, c.damage)


## Distance along the ray to the rectangle, or -1 for a miss (slab method).
static func _ray_rect(origin: Vector2, dir: Vector2, r: Rect2) -> float:
	var t_min: float = 0.0
	var t_max: float = INF
	for axis: int in 2:
		var o: float = origin[axis]
		var d: float = dir[axis]
		var lo: float = r.position[axis]
		var hi: float = r.end[axis]
		if absf(d) < 0.000001:
			if o < lo or o > hi:
				return -1.0
		else:
			var t1: float = (lo - o) / d
			var t2: float = (hi - o) / d
			if t1 > t2:
				var tmp: float = t1
				t1 = t2
				t2 = tmp
			t_min = maxf(t_min, t1)
			t_max = minf(t_max, t2)
			if t_min > t_max:
				return -1.0
	return t_min


func _melee() -> void:
	_melee_cooldown = MELEE_COOLDOWN
	_melee_source.x = player.x
	_melee_source.time_left = SHOT_PULSE
	melee_swung.emit(player.x, player.y, player.facing)
	for e: ToyEnemy in enemies:
		if not e.is_alive():
			continue
		var dx: float = (e.x - player.x) * player.facing
		if dx < -10.0 or dx > MELEE_RANGE + e.definition.width * 0.5:
			continue
		if e.top() < player.y - 10.0 or e.y > player.y + ToyPlayer.HEIGHT + 10.0:
			continue
		_damage_enemy(e, MELEE_DAMAGE)
		if e.is_alive() and (e.state == ToyEnemy.State.WALK or e.state == ToyEnemy.State.WAIT):
			e.x = _knockback_x(e, player.facing * MELEE_KNOCKBACK)
			e.wind_up_left = -1.0


## Where a knockback leaves an enemy: never through a standing structure.
func _knockback_x(e: ToyEnemy, push: float) -> float:
	var nx: float = e.x + push
	var hw: float = e.definition.width * 0.5
	for s: ToyStructure in structures:
		if not s.is_standing() or s.is_shelter:
			continue
		if s.definition.vaultable and e.definition.vaults_fences:
			continue
		if push > 0.0 and e.x <= s.left() and nx + hw > s.left():
			nx = minf(nx, s.left() - hw)
		elif push < 0.0 and e.x >= s.right() and nx - hw < s.right():
			nx = maxf(nx, s.right() + hw)
	return nx


func _damage_enemy(e: ToyEnemy, amount: float) -> void:
	e.health -= amount
	enemy_hit.emit(e)
	if e.health <= 0.0:
		_kill(e)


func _kill(e: ToyEnemy) -> void:
	_leave_structure(e)
	e.state = ToyEnemy.State.DEAD
	telemetry.add_kill(e.definition.id)
	enemy_killed.emit(e)


# --- Infected -------------------------------------------------------------

func _step_enemy(e: ToyEnemy, delta: float) -> void:
	match e.state:
		ToyEnemy.State.DEAD:
			return
		ToyEnemy.State.FALL:
			e.y -= FALL_SPEED * delta
			if e.y <= 0.0:
				e.y = 0.0
				e.state = ToyEnemy.State.WALK
			return
		ToyEnemy.State.CLIMB:
			_step_climb(e, delta)
			return

	_retarget(e, delta)
	e.commit_left = maxf(0.0, e.commit_left - delta)
	e.attack_cooldown = maxf(0.0, e.attack_cooldown - delta)
	if e.state == ToyEnemy.State.PILE:
		_settle_in_pile(e, delta)

	if e.wind_up_left >= 0.0:
		e.wind_up_left -= delta
		if e.wind_up_left < 0.0:
			_land_attack(e)
		return

	if e.attack_cooldown <= 0.0 and e.definition.attacks_player and _can_reach_player(e):
		_start_wind_up(e, player)
		return

	match e.state:
		ToyEnemy.State.WALK, ToyEnemy.State.WAIT:
			_step_walk(e, delta)
		ToyEnemy.State.PILE:
			_step_pile(e)
		ToyEnemy.State.ON_TOP:
			_step_on_top(e, delta)


func _retarget(e: ToyEnemy, delta: float) -> void:
	if e.is_runner():
		e.target = hum
		e.target_x = hum.x
		return
	e.replan_in -= delta
	if e.target != null:
		if e.target.is_active():
			e.memory_left = MEMORY
		else:
			e.memory_left = maxf(0.0, e.memory_left - delta)
	if e.replan_in > 0.0:
		return
	e.replan_in = REPLAN_INTERVAL
	if e.commit_left > 0.0:
		return
	var candidate: NoiseSource = NoiseRule.loudest(sources, e.x)
	if candidate == null:
		candidate = hum
	var forgot: bool = e.target == null or (not e.target.is_active() and e.memory_left <= 0.0)
	if forgot or NoiseRule.should_switch(e.target, e.memory_left, MEMORY, candidate, e.x, HYSTERESIS):
		e.target = candidate
		e.memory_left = MEMORY
	if e.target.is_active() or e.target == candidate:
		e.target_x = e.target.x


## The first standing structure between this enemy and its target (or with
## the target on top of it), or null. Runners vault fences.
func _blocker(e: ToyEnemy, dir: int) -> ToyStructure:
	var best: ToyStructure = null
	var best_d: float = INF
	for s: ToyStructure in structures:
		if not s.is_standing():
			continue
		if s.definition.vaultable and e.definition.vaults_fences:
			continue
		var face: float = s.face_x(-dir)
		var ahead: float = (face - e.x) * dir
		if ahead < -2.0:
			continue  # Already past its near face (on top of it, or dropped off).
		if (e.target_x - face) * dir < 0.0:
			continue
		if ahead < best_d:
			best_d = ahead
			best = s
	return best


func _pile_capacity(s: ToyStructure, e: ToyEnemy) -> int:
	return int(ceilf(maxf(0.0, s.height() - e.definition.height) / PILE_STEP)) + 1


func _wants_over(e: ToyEnemy, s: ToyStructure) -> bool:
	if s.is_shelter and e.target == hum:
		return false
	return true


func _step_walk(e: ToyEnemy, delta: float) -> void:
	var gap: float = e.target_x - e.x
	var dir: int = 0 if absf(gap) < 2.0 else (1 if gap > 0.0 else -1)
	if dir == 0:
		e.y = 0.0
		return
	e.heading = dir
	var speed: float = e.definition.speed * e.speed_factor
	var goal: float = e.target_x - dir * e.stop_offset
	var blocker: ToyStructure = _blocker(e, dir)
	var side: int = -dir
	var join: bool = false
	if blocker != null:
		var pile: Array = blocker.piles[side]
		var at_face: float = blocker.face_x(side) + side * e.definition.width * 0.5
		if pile.size() < _pile_capacity(blocker, e):
			goal = at_face
			join = true
		else:
			goal = at_face + side * (16.0 + float(e.id % 5) * 12.0)
			e.state = ToyEnemy.State.WAIT
	if (goal - e.x) * dir <= 0.0:
		goal = e.x
	e.x = move_toward(e.x, goal, speed * delta)
	e.y = _vault_height(e)
	if join and absf(e.x - goal) < 0.5:
		_join_pile(e, blocker, side)
	elif blocker == null:
		e.state = ToyEnemy.State.WALK


## A runner's hop over any fence it is crossing.
func _vault_height(e: ToyEnemy) -> float:
	if not e.definition.vaults_fences:
		return 0.0
	for s: ToyStructure in structures:
		if not s.is_standing() or not s.definition.vaultable:
			continue
		var reach: float = s.half_width() + e.definition.width * 0.5 + 10.0
		var d: float = absf(e.x - s.x) / reach
		if d < 1.0:
			return (s.height() + 8.0) * (1.0 - d * d)
	return 0.0


func _join_pile(e: ToyEnemy, s: ToyStructure, side: int) -> void:
	var pile: Array = s.piles[side]
	pile.append(e)
	e.state = ToyEnemy.State.PILE
	e.structure = s
	e.pile_side = side
	e.x = s.face_x(side) + side * (e.definition.width * 0.5 + float(e.id % 3 - 1) * 3.0)


func _settle_in_pile(e: ToyEnemy, delta: float) -> void:
	var pile: Array = e.structure.piles[e.pile_side]
	var goal: float = pile.find(e) * PILE_STEP
	if e.y < goal:
		e.y = minf(goal, e.y + PILE_RISE_SPEED * delta)
	else:
		e.y = maxf(goal, e.y - FALL_SPEED * delta)


func _step_pile(e: ToyEnemy) -> void:
	var s: ToyStructure = e.structure
	var side: int = e.pile_side
	# The target moved to this side: nothing to break through any more.
	if (e.target_x - s.face_x(side)) * side > 0.0:
		_leave_structure(e)
		e.state = ToyEnemy.State.FALL if e.y > 0.0 else ToyEnemy.State.WALK
		return
	var pile: Array = s.piles[side]
	var index: int = pile.find(e)
	var settled: bool = absf(e.y - index * PILE_STEP) < 1.0
	if index == pile.size() - 1 and settled and e.top() >= s.height() and _wants_over(e, s):
		_leave_structure(e)
		e.structure = s
		e.pile_side = side
		e.state = ToyEnemy.State.CLIMB
		e.climb_left = CLIMB_TIME
		climbs += 1
		return
	if index < PILE_HITTERS and e.attack_cooldown <= 0.0:
		_start_wind_up(e, s)


func _step_climb(e: ToyEnemy, delta: float) -> void:
	var s: ToyStructure = e.structure
	if s == null or not s.is_standing():
		e.structure = null
		e.state = ToyEnemy.State.FALL
		return
	var start_y: float = e.y
	e.climb_left -= delta
	var k: float = clampf(1.0 - e.climb_left / CLIMB_TIME, 0.0, 1.0)
	e.y = lerpf(start_y, s.height(), k)
	if e.climb_left <= 0.0:
		e.y = s.height()
		e.x = s.face_x(e.pile_side) - e.pile_side * e.definition.width * 0.5
		e.state = ToyEnemy.State.ON_TOP


func _step_on_top(e: ToyEnemy, delta: float) -> void:
	var s: ToyStructure = e.structure
	if s == null or not s.is_standing():
		e.structure = null
		e.state = ToyEnemy.State.FALL
		return
	if s.is_shelter and (e.target == hum or e.is_runner()):
		# On the roof with nothing else to chase: tear at the shelter.
		if e.attack_cooldown <= 0.0:
			_start_wind_up(e, s)
		return
	var gap: float = e.target_x - e.x
	if absf(gap) < 2.0:
		return
	var dir: int = 1 if gap > 0.0 else -1
	e.heading = dir
	e.x = move_toward(e.x, e.target_x, e.definition.speed * e.speed_factor * delta)
	if not s.spans(e.x):
		e.structure = null
		e.state = ToyEnemy.State.FALL


func _can_reach_player(e: ToyEnemy) -> bool:
	if not player.is_alive():
		return false
	var dx: float = absf(e.x - player.x)
	if dx > e.definition.width * 0.5 + ToyPlayer.HALF_WIDTH + ENEMY_REACH:
		return false
	return e.top() + 6.0 >= player.y and e.y <= player.y + ToyPlayer.HEIGHT


func _start_wind_up(e: ToyEnemy, what: Object) -> void:
	e.wind_up_left = e.definition.wind_up
	e.wind_up_target = what
	# Engaging the player holds the target so it doesn't jitter (GDD 5). Hits on
	# structures don't, or a pile could never be pulled away.
	if what == player and e.commit_left <= 0.0:
		e.commit_left = COMMIT_TIME


func _land_attack(e: ToyEnemy) -> void:
	e.wind_up_left = -1.0
	e.attack_cooldown = e.definition.attack_interval
	var what: Object = e.wind_up_target
	e.wind_up_target = null
	if what == player:
		if _can_reach_player(e):
			player.take_damage(e.definition.damage_player)
			telemetry.player_hits += 1
			_note_hit(e, &"player")
	elif what is ToyStructure:
		var s: ToyStructure = what as ToyStructure
		if not s.is_standing():
			return
		if s.is_shelter:
			s.take_damage(e.definition.damage_shelter)
			telemetry.add_shelter_hit(e.definition.id)
			_note_hit(e, &"shelter")
		else:
			s.take_damage(e.definition.damage_structure)
			attack_landed.emit(e, &"structure")


func _note_hit(e: ToyEnemy, target_kind: StringName) -> void:
	_last_hit_by = e.definition.id
	_last_hit_target = target_kind
	attack_landed.emit(e, target_kind)


func _leave_structure(e: ToyEnemy) -> void:
	if e.structure != null and e.state == ToyEnemy.State.PILE:
		var pile: Array = e.structure.piles[e.pile_side]
		pile.erase(e)
	e.structure = null


func _on_structure_destroyed(s: ToyStructure) -> void:
	for side: int in [-1, 1]:
		var pile: Array = s.piles[side]
		for m: ToyEnemy in pile:
			m.structure = null
			m.wind_up_left = -1.0
			m.state = ToyEnemy.State.FALL if m.y > 0.0 else ToyEnemy.State.WALK
		pile.clear()
	for e: ToyEnemy in enemies:
		if e.structure == s and e.is_alive():
			e.structure = null
			e.state = ToyEnemy.State.FALL
	if not s.is_shelter:
		telemetry.structures_lost += 1
		var pulse: NoiseSource = NoiseSource.new(NoiseSource.Kind.STRUCTURE_BREAK, s.x, BREAK_LOUDNESS, BREAK_RADIUS, 0.3)
		sources.append(pulse)
	structure_destroyed.emit(s)


func _cleanup_dead() -> void:
	for i: int in range(sources.size() - 1, -1, -1):
		var src: NoiseSource = sources[i]
		if src.kind == NoiseSource.Kind.STRUCTURE_BREAK and not src.is_active():
			var still_followed: bool = false
			for e: ToyEnemy in enemies:
				if e.target == src and e.memory_left > 0.0:
					still_followed = true
					break
			if not still_followed:
				sources.remove_at(i)
	for i: int in range(structures.size() - 1, -1, -1):
		if not structures[i].is_standing() and not structures[i].is_shelter:
			structures.remove_at(i)
	if enemies.size() > 120:
		var kept: Array[ToyEnemy] = []
		for e: ToyEnemy in enemies:
			if e.is_alive():
				kept.append(e)
		enemies = kept


# --- Night ----------------------------------------------------------------

func _spawn_due() -> void:
	var alive: int = alive_enemies()
	var i: int = 0
	while i < _pending.size():
		var p: Dictionary = _pending[i]
		if (p["time"] as float) > elapsed:
			break
		if alive >= ON_SCREEN_CAP:
			break
		var side: int = p["side"] as int
		var x: float = -SPAWN_MARGIN if side < 0 else WORLD_WIDTH + SPAWN_MARGIN
		if _spawn_point_busy(x):
			i += 1
			continue
		spawn_enemy(p["enemy"] as EnemyDefinition, x)
		alive += 1
		_pending.remove_at(i)


func _spawn_point_busy(x: float) -> bool:
	for e: ToyEnemy in enemies:
		if e.is_alive() and e.y < 1.0 and absf(e.x - x) < e.definition.width:
			return true
	return false


func pending_spawns() -> int:
	return _pending.size()


func _check_end() -> void:
	# A loss in the same frame as dawn counts as the loss; the shelter falling
	# outranks the player dying (spec edge case 9).
	if not shelter.is_standing():
		_end(Result.SHELTER_FELL)
	elif not player.is_alive():
		_end(Result.PLAYER_DIED)
	elif elapsed >= night.duration:
		_end(Result.DAWN)


func _end(r: Result) -> void:
	result = r
	var name: StringName = result_name(r)
	telemetry.result = name
	if r != Result.DAWN:
		telemetry.cause_enemy = _last_hit_by
		telemetry.cause_target = _last_hit_target
	night_ended.emit(name)


static func result_name(r: Result) -> StringName:
	match r:
		Result.DAWN:
			return &"dawn"
		Result.PLAYER_DIED:
			return &"player_died"
		Result.SHELTER_FELL:
			return &"shelter_fell"
	return &"none"
