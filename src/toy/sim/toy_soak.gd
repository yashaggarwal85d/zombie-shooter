class_name ToySoak
extends RefCounted
## One scripted night with rule checks, shared by tools/toy/soak.gd and the
## soak test. Checks: nobody passes a standing structure except by climbing,
## nobody floats above a pile or the ground, and the night ends.


## `layout` is one option index per build spot (see BuildPlan.options).
static func run_night(seed_value: int, layout: Array, dt: float, trigger_rate: float = 1.0, passive: bool = false, max_seconds: float = 600.0) -> Dictionary:
	var night: NightDefinition = ToyContent.night()
	var plan: BuildPlan = ToyContent.new_plan(99)
	for i: int in mini(layout.size(), plan.choices.size()):
		plan.choices[i] = layout[i] as int
	var sim: FieldSim = ToyContent.new_field(night, plan, seed_value)
	var bot: ScriptedPlayer = ScriptedPlayer.new(seed_value)
	bot.trigger_rate = trigger_rate
	bot.passive = passive
	var violations: int = 0
	var notes: PackedStringArray = []
	var worst_ms: float = 0.0
	var times: Array[float] = []
	var steps: int = 0
	var last_side: Dictionary[int, int] = {}
	while not sim.is_over() and steps * dt < max_seconds:
		var input: ToyInput = bot.next_input(sim, dt)
		var t0: int = Time.get_ticks_usec()
		sim.step(dt, input)
		var ms: float = (Time.get_ticks_usec() - t0) / 1000.0
		times.append(ms)
		worst_ms = maxf(worst_ms, ms)
		steps += 1
		for e: ToyEnemy in sim.enemies:
			if not e.is_alive():
				continue
			var v: String = check_enemy(sim, e, last_side)
			if v != "":
				violations += 1
				if notes.size() < 5:
					notes.append("t=%.1f %s" % [sim.elapsed, v])
	times.sort()
	var p99: float = times[int(times.size() * 0.99)] if not times.is_empty() else 0.0
	return {
		"seed": seed_value, "result": FieldSim.result_name(sim.result), "seconds": sim.elapsed,
		"kills": sim.telemetry.kills, "shelter": sim.shelter.health, "player": sim.player.health,
		"lost": sim.telemetry.structures_lost, "loud_share": sim.telemetry.loud_share(),
		"p99_ms": p99, "worst_ms": worst_ms, "violations": violations, "notes": notes,
		"ended": sim.is_over(), "climbs": sim.climbs, "player_hits": sim.telemetry.player_hits,
	}


## Empty when fine; otherwise what went wrong. `last_side` remembers which
## side of each structure an enemy was on, keyed by enemy id * 4096 + the structure's x.
static func check_enemy(sim: FieldSim, e: ToyEnemy, last_side: Dictionary[int, int]) -> String:
	# Nobody floats: a grounded state means y is 0, or a vault hop over a fence.
	if (e.state == ToyEnemy.State.WALK or e.state == ToyEnemy.State.WAIT) and e.y > 0.5 and not e.definition.vaults_fences:
		return "enemy %d floating at y=%.1f while walking" % [e.id, e.y]
	if e.state == ToyEnemy.State.PILE:
		var pile: Array = e.structure.piles[e.pile_side]
		var idx: int = pile.find(e)
		if idx < 0:
			return "enemy %d piled but not in the pile" % e.id
		# Bodies above a kill drop at FALL_SPEED, so allow a moment to land.
		var key_float: int = -e.id
		if e.y > idx * FieldSim.PILE_STEP + 0.5:
			last_side[key_float] = last_side.get(key_float, 0) + 1
			if last_side[key_float] > 20:
				return "enemy %d stuck above its pile slot" % e.id
		else:
			last_side.erase(key_float)
	# Nobody walks through a standing structure on the ground.
	for s: ToyStructure in sim.structures:
		if not s.is_standing() or (s.definition.vaultable and e.definition.vaults_fences):
			continue
		var key: int = e.id * 4096 + int(s.x)  # Spots never share an x.
		var on_ground: bool = e.state == ToyEnemy.State.WALK or e.state == ToyEnemy.State.WAIT
		if not on_ground:
			last_side.erase(key)
			continue
		var side: int = 0
		if e.x < s.left():
			side = -1
		elif e.x > s.right():
			side = 1
		if side == 0:
			if s.is_shelter:
				continue
			return "enemy %d inside %s on the ground" % [e.id, s.definition.id]
		var prev: int = last_side.get(key, side)
		last_side[key] = side
		if prev != side:
			return "enemy %d crossed %s without climbing" % [e.id, s.definition.id]
	return ""


static func describe(stats: Dictionary) -> String:
	return "night seed=%d climbs=%d player_hits=%d result=%s t=%.0fs kills=%s shelter=%.0f player=%.0f lost=%d loud=%.2f p99=%.3fms worst=%.2fms violations=%d %s" % [
		stats["seed"], stats["climbs"], stats["player_hits"], stats["result"], stats["seconds"], stats["kills"], stats["shelter"], stats["player"],
		stats["lost"], stats["loud_share"], stats["p99_ms"], stats["worst_ms"], stats["violations"],
		" | ".join(stats["notes"] as PackedStringArray),
	]
