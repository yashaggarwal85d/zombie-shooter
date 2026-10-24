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
## Brawler: closes in on the nearest pile or crowd and fights with the hatchet,
## jumping to strike down on pile tops (D14), and only shoots far-off runners.
var brawler: bool = false
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
	if brawler:
		return _brawl(sim, p, input)
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
		input.jump_held = true
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
		# In the air over an infected (or a pile): strike down to bounce.
		if not p.supported() and best < 40.0 and nearest.top() <= p.y + 10.0:
			input.climb = -1.0
			input.melee_pressed = true
	_swap_in -= delta
	if _swap_in <= 0.0:
		_swap_in = rng.randf_range(10.0, 30.0)
		input.swap_pressed = true
	return input


func _brawl(sim: FieldSim, p: ToyPlayer, input: ToyInput) -> ToyInput:
	if p.ladder != null:
		input.climb = -1.0
		return input
	# Prefer the top of a pile; otherwise the nearest of the infected.
	var goal: ToyEnemy = null
	var best: float = INF
	for e: ToyEnemy in sim.enemies:
		if not e.is_alive():
			continue
		var d: float = absf(e.x - p.x) - (200.0 if e.state == ToyEnemy.State.PILE else 0.0)
		if d < best:
			best = d
			goal = e
	input.jump_held = true
	if goal == null:
		input.move = signf(FieldSim.SHELTER_X - p.x) if absf(FieldSim.SHELTER_X - p.x) > 40.0 else 0.0
		return input
	var dx: float = goal.x - p.x
	var origin: Vector2 = Vector2(p.x, p.y + FieldSim.MUZZLE_HEIGHT)
	input.aim = Vector2(goal.x, goal.y + goal.definition.height * 0.5) - origin
	if absf(dx) > 300.0 and goal.is_runner():
		input.fire_held = rng.randf() < trigger_rate
	if goal.state == ToyEnemy.State.PILE:
		# Get over the pile top, then come down on it.
		if absf(dx) > 6.0:
			input.move = signf(dx)
		if p.supported() and absf(dx) < 60.0 and goal.top() > p.y + 20.0:
			input.jump_pressed = true
		if not p.supported() and absf(dx) < 30.0 and p.vy < 0.0 and goal.top() <= p.y + 10.0:
			input.climb = -1.0
			input.melee_pressed = true
	else:
		if absf(dx) > 45.0:
			input.move = signf(dx)
		elif p.facing != int(signf(dx)) and dx != 0.0:
			input.move = signf(dx)
		if absf(dx) < 70.0:
			input.melee_pressed = true
			if goal.y > p.y + ToyPlayer.HEIGHT * 0.5:
				input.climb = 1.0
	return input
