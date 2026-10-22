class_name ScriptedPlayer
extends RefCounted
## A stand-in player for the headless soak and tests. Not an AI to beat the
## game: it wanders between the shelter and the walls, shoots the nearest
## infected, swaps barrels now and then, and climbs to the roof sometimes, so
## every rule gets exercised.

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Passive: climbs to the roof and never fires (Yash's rule, D12: hiding up
## high still loses her).
var passive: bool = false
## Chance per frame of holding fire while a target is in range.
var trigger_rate: float = 1.0
var _goal_x: float = FieldSim.SHELTER_X
var _goal_in: float = 0.0
var _swap_in: float = 15.0
var _climb_until: float = 0.0
var _time: float = 0.0


func _init(seed_value: int) -> void:
	rng.seed = seed_value


func next_input(sim: FieldSim, delta: float) -> ToyInput:
	_time += delta
	var input: ToyInput = ToyInput.new()
	var p: ToyPlayer = sim.player
	if passive:
		var ladder_x0: float = sim.shelter.left() - ToyPlayer.HALF_WIDTH
		if p.surface != sim.shelter:
			if p.ladder != null or absf(p.x - ladder_x0) <= 8.0:
				input.climb = 1.0
			else:
				input.move = signf(ladder_x0 - p.x)
		elif absf(p.x - sim.shelter.x) > 6.0:
			input.move = signf(sim.shelter.x - p.x)
		return input
	_goal_in -= delta
	if _goal_in <= 0.0:
		_goal_in = rng.randf_range(3.0, 8.0)
		_goal_x = FieldSim.SHELTER_X + rng.randf_range(-500.0, 500.0)
		if rng.randf() < 0.25:
			_climb_until = _time + rng.randf_range(3.0, 8.0)
	if _time < _climb_until:
		# Head for the shelter's ladder and go up.
		var ladder_x: float = sim.shelter.left() - ToyPlayer.HALF_WIDTH
		if p.ladder != null or p.surface == sim.shelter:
			input.climb = 1.0
		elif absf(p.x - ladder_x) > 8.0:
			input.move = signf(ladder_x - p.x)
		else:
			input.climb = 1.0
	else:
		if p.surface != null and rng.randf() < 0.02:
			input.climb = -1.0
		elif absf(_goal_x - p.x) > 10.0:
			input.move = signf(_goal_x - p.x)
		if p.ladder != null:
			input.climb = -1.0
		input.jump_pressed = rng.randf() < 0.01
	var nearest: ToyEnemy = null
	var best: float = 900.0
	for e: ToyEnemy in sim.enemies:
		if e.is_alive():
			var d: float = absf(e.x - p.x)
			if d < best:
				best = d
				nearest = e
	if nearest != null:
		var origin: Vector2 = Vector2(p.x, p.y + FieldSim.MUZZLE_HEIGHT)
		var aim_at: Vector2 = Vector2(nearest.x, nearest.y + nearest.definition.height * 0.5)
		input.aim = aim_at - origin
		input.fire_held = rng.randf() < trigger_rate
		input.melee_pressed = best < 50.0
	_swap_in -= delta
	if _swap_in <= 0.0:
		_swap_in = rng.randf_range(10.0, 30.0)
		input.swap_pressed = true
	return input
