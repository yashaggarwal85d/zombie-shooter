class_name ToyPlayer
extends RefCounted
## The player's body on the field: walking, jumping, ladders, and standing on
## structure tops and the shelter roof (D11). Hand-rolled rather than physics
## bodies, so every rule here is deterministic and unit-tested.

const SPEED: float = 220.0
# Jump feel (D14): a fast rise, a brief ease at the top, a heavier fall, and a
# height set by how long jump is held. Our own starting values, to tune.
## Rising gravity: a full jump peaks at about 140 px in about 0.3 s, onto
## fences and walls but not high walls or the roof.
const GRAVITY: float = 3100.0
const JUMP_VELOCITY: float = 930.0
## Falling is heavier than rising.
const FALL_GRAVITY_SCALE: float = 1.6
const MAX_FALL_SPEED: float = 1100.0
## Near the top of a held jump, gravity eases off for a moment of hang.
const APEX_SPEED: float = 120.0
const APEX_GRAVITY_SCALE: float = 0.5
## Letting go of jump while rising caps the climb speed: a tap gives a hop of
## about 60 px.
const JUMP_CUT_VELOCITY: float = 600.0
const CLIMB_SPEED: float = 260.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER: float = 0.1
const HALF_WIDTH: float = 14.0
const HEIGHT: float = 64.0
## How far from a structure's side you can grab its ladder.
const LADDER_REACH: float = 26.0
const DROP_THROUGH_TIME: float = 0.2
const MAX_HEALTH: float = 100.0

var x: float
var y: float = 0.0
var vy: float = 0.0
var facing: int = 1
var health: float = MAX_HEALTH
## What the player stands on: null means ground or the air (see on_ground()).
var surface: ToyStructure = null
var grounded: bool = true
var ladder: ToyStructure = null
var coyote_left: float = 0.0
var jump_buffer_left: float = 0.0
var drop_through_left: float = 0.0
var drop_through: ToyStructure = null
## False for a bounce or a ladder hop that letting go must not cut short.
var jump_cuttable: bool = false
## A short shove from a melee hit (D14), field units per second.
var recoil_vx: float = 0.0
var recoil_left: float = 0.0
## Landings so far and the speed of the last one, for the view's squash.
var landings: int = 0
var last_land_speed: float = 0.0
## Seconds spent off the ground this night, for the gate.
var air_and_height_time: float = 0.0


func _init(p_x: float) -> void:
	x = p_x


func is_alive() -> bool:
	return health > 0.0


func is_off_ground() -> bool:
	return y > 0.5


func on_ground() -> bool:
	return grounded and surface == null and ladder == null


func supported() -> bool:
	return grounded or ladder != null


func take_damage(amount: float) -> void:
	health = maxf(0.0, health - amount)


## Pushes the body sideways for `time` seconds; walls still block it.
func recoil(vx: float, time: float) -> void:
	recoil_vx = vx
	recoil_left = time


## Launches the body up off a down-strike. Holding or releasing jump doesn't
## change a bounce's height.
func bounce(velocity: float) -> void:
	ladder = null
	surface = null
	grounded = false
	coyote_left = 0.0
	vy = velocity
	jump_cuttable = false


## Advances the body one step. `structures` are the standing obstacles and
## platforms, including the shelter. The shelter never blocks walking (its
## door is open), but its roof can be stood on.
func step(delta: float, input: ToyInput, structures: Array[ToyStructure]) -> void:
	if input.move != 0.0:
		facing = 1 if input.move > 0.0 else -1
	if input.jump_pressed:
		jump_buffer_left = JUMP_BUFFER
	else:
		jump_buffer_left = maxf(0.0, jump_buffer_left - delta)
	recoil_left = maxf(0.0, recoil_left - delta)
	if recoil_left <= 0.0:
		recoil_vx = 0.0
	drop_through_left = maxf(0.0, drop_through_left - delta)
	if drop_through_left <= 0.0:
		drop_through = null

	if ladder != null and not ladder.is_standing():
		ladder = null
		grounded = false
	if surface != null and (not surface.is_standing() or not surface.spans(x)):
		surface = null
		grounded = false
		coyote_left = COYOTE_TIME

	if ladder != null:
		_step_ladder(delta, input)
	else:
		_try_grab_ladder(input, structures)
		if ladder == null:
			_step_free(delta, input, structures)

	if is_off_ground():
		air_and_height_time += delta


func _try_grab_ladder(input: ToyInput, structures: Array[ToyStructure]) -> void:
	if absf(input.climb) < 0.5:
		return
	for s: ToyStructure in structures:
		if not s.is_standing() or not s.has_ladder:
			continue
		var near_left: bool = absf(x - (s.left() - HALF_WIDTH)) <= LADDER_REACH
		var near_right: bool = absf(x - (s.right() + HALF_WIDTH)) <= LADDER_REACH
		var on_top_of_it: bool = surface == s
		if input.climb > 0.0 and (near_left or near_right) and y < s.height() - 1.0:
			ladder = s
			x = s.left() - HALF_WIDTH if near_left else s.right() + HALF_WIDTH
			_enter_ladder()
			return
		if input.climb < 0.0 and on_top_of_it:
			ladder = s
			x = s.left() - HALF_WIDTH if x < s.x else s.right() + HALF_WIDTH
			_enter_ladder()
			return


func _enter_ladder() -> void:
	surface = null
	grounded = false
	vy = 0.0


func _step_ladder(delta: float, input: ToyInput) -> void:
	var top: float = ladder.height()
	if jump_buffer_left > 0.0:
		jump_buffer_left = 0.0
		ladder = null
		vy = JUMP_VELOCITY * 0.8
		jump_cuttable = true
		return
	if input.move != 0.0 and absf(input.climb) < 0.5 and y > 0.0:
		# Stepping sideways off a ladder: onto its top if level with it, else fall.
		var s: ToyStructure = ladder
		ladder = null
		if y >= top - 4.0:
			y = top
			x = clampf(x, s.left() + 1.0, s.right() - 1.0)
			surface = s
			grounded = true
		return
	y += input.climb * CLIMB_SPEED * delta
	if y >= top:
		# Off the top onto the structure.
		y = top
		var s2: ToyStructure = ladder
		ladder = null
		x = clampf(x, s2.left() + 1.0, s2.right() - 1.0)
		surface = s2
		grounded = true
	elif y <= 0.0:
		y = 0.0
		ladder = null
		grounded = true


func _step_free(delta: float, input: ToyInput, structures: Array[ToyStructure]) -> void:
	# Drop through a top by pressing down while standing on it.
	if input.climb < -0.5 and surface != null:
		drop_through = surface
		drop_through_left = DROP_THROUGH_TIME
		surface = null
		grounded = false
		coyote_left = 0.0

	if grounded:
		coyote_left = COYOTE_TIME
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
	if jump_buffer_left > 0.0 and (grounded or coyote_left > 0.0):
		jump_buffer_left = 0.0
		coyote_left = 0.0
		vy = JUMP_VELOCITY
		jump_cuttable = true
		grounded = false
		surface = null

	# Horizontal: instant, in the air as on the ground (no momentum). Built
	# structures block the body below their top.
	var nx: float = x + (input.move * SPEED + recoil_vx) * delta
	for s: ToyStructure in structures:
		if s.is_shelter or not s.is_standing() or s == surface:
			continue
		if y >= s.height() - 0.5:
			continue
		var lo: float = s.left() - HALF_WIDTH
		var hi: float = s.right() + HALF_WIDTH
		if nx > lo and nx < hi:
			nx = lo if x <= lo + 0.01 else (hi if x >= hi - 0.01 else nx)
			if nx > lo and nx < hi:
				# Already inside (a structure built on top of the player): push out.
				nx = lo if x < s.x else hi
	x = nx

	# Vertical.
	if not grounded:
		var prev_y: float = y
		if vy > 0.0 and jump_cuttable and not input.jump_held:
			vy = minf(vy, JUMP_CUT_VELOCITY)
			jump_cuttable = false
		vy -= _gravity(input) * delta
		vy = maxf(vy, -MAX_FALL_SPEED)
		y += vy * delta
		if vy <= 0.0:
			var landed: ToyStructure = null
			for s: ToyStructure in structures:
				if not s.is_standing() or s == drop_through or not s.spans(x):
					continue
				if prev_y >= s.height() - 0.5 and y <= s.height():
					if landed == null or s.height() > landed.height():
						landed = s
			if landed != null or y <= 0.0:
				landings += 1
				last_land_speed = -vy
			if landed != null:
				y = landed.height()
				vy = 0.0
				grounded = true
				surface = landed
			elif y <= 0.0:
				y = 0.0
				vy = 0.0
				grounded = true
				surface = null


func _gravity(input: ToyInput) -> float:
	if vy <= 0.0:
		return GRAVITY * FALL_GRAVITY_SCALE
	if vy < APEX_SPEED and input.jump_held:
		return GRAVITY * APEX_GRAVITY_SCALE
	return GRAVITY
