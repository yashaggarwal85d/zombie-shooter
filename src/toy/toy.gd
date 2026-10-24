class_name CombatToy
extends Node2D
## The combat toy (Stage D step 1): a build step in daylight, then one night
## holding the cabin, on repeat. Reads InputMap actions into a ToyInput, steps
## the FieldSim, and hands it to the view nodes. Each finished night appends a
## row to user://toy_log.csv for the toy gate.

enum Phase { BUILD, NIGHT, END }

const SPOT_REACH: float = 70.0
const CAMERA_CENTER: Vector2 = Vector2(FieldSim.SHELTER_X, -400.0)
## The stick only counts as aiming past this much tilt.
const AIM_DEADZONE: float = 0.3

@export var night: NightDefinition

var phase: Phase = Phase.BUILD
var paused: bool = false
var sim: FieldSim
var plan: BuildPlan
var attempts: int = 0
var _aim: Vector2 = Vector2.RIGHT
var _mouse_aim: bool = true
var _debug: bool = false
## When set, plays itself (screenshots, clips and demos); otherwise reads input.
var bot: ScriptedPlayer = null

@onready var _camera: Camera2D = $Camera2D
@onready var _field: ToyFieldView = $FieldView
@onready var _actors: ToyActorLayer = $Actors
@onready var _fx: ToyFxLayer = $Fx
@onready var _audio: ToyAudio = $Audio
@onready var _hud: ToyHud = $HudLayer/Hud


func _ready() -> void:
	if night == null:
		night = ToyContent.night()
	_camera.position = CAMERA_CENTER
	plan = ToyContent.new_plan(night.start_scrap)
	_enter_build()


func _enter_build() -> void:
	phase = Phase.BUILD
	var keep_x: float = sim.player.x if sim != null else FieldSim.SHELTER_X - 60.0
	_make_build_preview(keep_x)
	_field.palette = ToyPalette.day()
	_field.building = true
	_hud.mode = ToyHud.Mode.BUILD
	_audio.set_hum(false, 1.0)


## During the build step the field is a sim with no spawns and no clock, so
## the player can walk, jump and try the ladders on what they've placed.
func _make_build_preview(player_x: float) -> void:
	var empty: NightDefinition = NightDefinition.new()
	empty.duration = INF
	_drop_sim()
	sim = ToyContent.new_field(empty, plan)
	sim.player.x = player_x
	_bind_views()


func _start_night() -> void:
	phase = Phase.NIGHT
	var player_x: float = sim.player.x
	_drop_sim()
	sim = ToyContent.new_field(night, plan, randi())
	sim.player.x = player_x
	sim.shot_fired.connect(_on_shot)
	sim.melee_swung.connect(_on_melee)
	sim.player_bounced.connect(_on_bounce)
	sim.enemy_hit.connect(_on_enemy_hit)
	sim.enemy_killed.connect(_on_enemy_killed)
	sim.attack_landed.connect(_on_attack_landed)
	sim.structure_destroyed.connect(_on_structure_destroyed)
	sim.night_ended.connect(_on_night_ended)
	_bind_views()
	_field.palette = ToyPalette.night()
	_field.building = false
	_hud.mode = ToyHud.Mode.NIGHT
	_audio.set_hum(true, 1.0)


func _drop_sim() -> void:
	if sim != null:
		sim.dispose()
	_actors.hit_flash.clear()
	_field.flash.clear()


func _bind_views() -> void:
	_field.sim = sim
	_field.plan = plan
	_actors.sim = sim
	_fx.sim = sim
	_hud.sim = sim
	_hud.plan = plan
	_hud.attempts = attempts


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_aim = true
	if event.is_action_pressed(&"pause") and phase == Phase.NIGHT:
		_set_paused(not paused)
	if event.is_action_pressed(&"debug_overlay"):
		_debug = not _debug
		_fx.debug = _debug
		_hud.debug = _debug


func _notification(what: int) -> void:
	# Phones suspend the app without warning; desktops lose focus. Either way
	# the night waits (spec edge case 15).
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if phase == Phase.NIGHT and is_node_ready():
			_set_paused(true)


func _set_paused(on: bool) -> void:
	paused = on
	_hud.mode = ToyHud.Mode.PAUSED if on else ToyHud.Mode.NIGHT


func _physics_process(delta: float) -> void:
	match phase:
		Phase.BUILD:
			_step_build(delta)
		Phase.NIGHT:
			if not paused:
				var t0: int = Time.get_ticks_usec()
				var input: ToyInput = bot.next_input(sim, delta) if bot != null else _read_input()
				if bot != null:
					_aim = input.aim.normalized()
				sim.step(delta, input)
				_hud.sim_ms = (Time.get_ticks_usec() - t0) / 1000.0
				_audio.set_hum(true, sim.shelter.health_fraction())
		Phase.END:
			if Input.is_action_just_pressed(&"fire") or Input.is_action_just_pressed(&"start_night"):
				_enter_build()
	_fx.aim_dir = _aim


func _step_build(delta: float) -> void:
	var input: ToyInput = _read_input()
	input.fire_held = false
	input.melee_pressed = false
	input.swap_pressed = false
	sim.player.step(delta, input, sim.structures)
	sim.player.x = clampf(sim.player.x, 10.0, FieldSim.WORLD_WIDTH - 10.0)
	var spot: int = plan.nearest_spot(sim.player.x, SPOT_REACH)
	_field.nearest_spot = spot
	if spot >= 0:
		var next: BuildPlan.Option = plan.options[plan.peek_cycle(spot)]
		var price: String = "free" if next.cost() == 0 else "%d scrap" % next.cost()
		_hud.prompt = "E: %s → %s (%s)" % [plan.option_at(spot).label(), next.label(), price]
	else:
		_hud.prompt = "Walk to a marker to build. Enter starts the night."
	if Input.is_action_just_pressed(&"interact") and spot >= 0:
		plan.cycle(spot)
		_audio.play_ui(&"build", -6.0)
		_make_build_preview(sim.player.x)
	if Input.is_action_just_pressed(&"start_night"):
		_start_night()


func _read_input() -> ToyInput:
	var i: ToyInput = ToyInput.new()
	i.move = Input.get_axis(&"move_left", &"move_right")
	i.climb = Input.get_axis(&"climb_down", &"climb_up")
	i.jump_pressed = Input.is_action_just_pressed(&"jump")
	i.jump_held = Input.is_action_pressed(&"jump")
	i.fire_held = Input.is_action_pressed(&"fire")
	i.melee_pressed = Input.is_action_just_pressed(&"melee")
	i.reload_pressed = Input.is_action_just_pressed(&"reload")
	i.swap_pressed = Input.is_action_just_pressed(&"interact")
	i.aim = _read_aim()
	return i


## Mouse aims at the pointer. The right stick aims by direction; `aim` only
## reports how far it is pushed, so the direction is read from the stick axes
## (edge case 13: at rest it keeps the last aim).
func _read_aim() -> Vector2:
	if Input.get_action_strength(&"aim") > AIM_DEADZONE:
		_mouse_aim = false
		var stick: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if stick.length() > AIM_DEADZONE:
			_aim = Vector2(stick.x, -stick.y).normalized()
	elif _mouse_aim and sim != null:
		var m: Vector2 = get_global_mouse_position()
		var muzzle: Vector2 = Vector2(sim.player.x, -(sim.player.y + FieldSim.MUZZLE_HEIGHT))
		var d: Vector2 = m - muzzle
		if d.length() > 4.0:
			_aim = Vector2(d.x, -d.y).normalized()
	return _aim


# --- Sim events → effects ---------------------------------------------------

func _on_shot(origin: Vector2, end: Vector2, loud: bool, _hit: bool) -> void:
	_fx.add_tracer(origin, end, loud)
	_audio.play_at(&"shot_loud" if loud else &"shot_quiet", origin, 0.0 if loud else -6.0)


func _on_melee(x: float, y: float, direction: Vector2i) -> void:
	_fx.add_slash(direction)
	_audio.play_at(&"melee", Vector2(x, y + 30.0), -4.0)


func _on_bounce(x: float, y: float) -> void:
	_fx.add_burst(Vector2(x, y), Color(0.85, 0.9, 1.0, 0.8), 5)


func _on_enemy_hit(e: ToyEnemy) -> void:
	_actors.hit_flash[e] = 0.06
	_audio.play_at(&"flesh", Vector2(e.x, e.y + 30.0), -8.0)


func _on_enemy_killed(e: ToyEnemy) -> void:
	_fx.add_burst(Vector2(e.x, e.y + 30.0), Color(0.08, 0.09, 0.1), 10)


func _on_attack_landed(e: ToyEnemy, kind: StringName) -> void:
	match kind:
		&"player":
			_actors.player_flash = 0.15
			_audio.play_at(&"hurt", Vector2(sim.player.x, sim.player.y + 30.0))
		&"shelter":
			_field.shelter_flash = 0.2
			_audio.play_at(&"shelter_hit", Vector2(e.x, e.y + 40.0))
			_fx.add_burst(Vector2(e.x + e.heading * 16.0, e.y + 40.0), Color(0.6, 0.85, 1.0, 0.8), 4)
		&"structure":
			if e.structure != null:
				_field.flash[e.structure] = 0.08
			_audio.play_at(&"knock", Vector2(e.x, e.y + 30.0), -6.0)


func _on_structure_destroyed(s: ToyStructure) -> void:
	_audio.play_at(&"crash", Vector2(s.x, s.height() * 0.5))
	_fx.add_burst(Vector2(s.x, s.height() * 0.5), Color(0.3, 0.26, 0.2), 18)


func _on_night_ended(result: StringName) -> void:
	phase = Phase.END
	attempts += 1
	_hud.attempts = attempts
	_hud.mode = ToyHud.Mode.END
	match result:
		&"dawn":
			_hud.end_title = "Dawn"
			_audio.play_ui(&"dawn")
		&"player_died":
			_hud.end_title = "You died"
			_audio.play_ui(&"sting")
		_:
			_hud.end_title = "The shelter fell"
			_audio.play_ui(&"sting")
	_audio.set_hum(false, 0.0)
	var date: String = Time.get_datetime_string_from_system()
	var err: Error = sim.telemetry.append_to(ToyTelemetry.LOG_PATH, BuildInfo.label(), date)
	if err != OK:
		push_warning("Couldn't write the toy log: %s" % error_string(err))


func _exit_tree() -> void:
	if sim != null:
		sim.dispose()
