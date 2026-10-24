class_name ToyFxLayer
extends Node2D
## Tracers, muzzle flashes, sparks, the aim line, enemy tells and the debug
## overlay (target lines, noise rings, structure health). Effects stay small
## and brief so they never hide danger.

const TRACER_TIME: float = 0.08
## A greybox hatchet arc: a little longer than the hit, so the eye catches it.
const SLASH_TIME: float = 0.12

var sim: FieldSim
var aim_dir: Vector2 = Vector2.RIGHT
var debug: bool = false
var _tracers: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []
var _slashes: Array[Dictionary] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func add_tracer(origin: Vector2, end: Vector2, loud: bool) -> void:
	_tracers.append({"a": Vector2(origin.x, -origin.y), "b": Vector2(end.x, -end.y), "t": TRACER_TIME, "loud": loud})


## Draws the swing around the player, who it follows while it fades.
func add_slash(direction: Vector2i) -> void:
	_slashes.append({"d": direction, "t": SLASH_TIME})


func add_burst(at: Vector2, color: Color, count: int) -> void:
	for i: int in count:
		var v: Vector2 = Vector2(_rng.randf_range(-160.0, 160.0), _rng.randf_range(-260.0, -40.0))
		_sparks.append({"p": Vector2(at.x, -at.y), "v": v, "t": _rng.randf_range(0.2, 0.45), "c": color})


func _process(delta: float) -> void:
	for t: Dictionary in _tracers:
		t["t"] = (t["t"] as float) - delta
	_tracers = _tracers.filter(func(t: Dictionary) -> bool: return (t["t"] as float) > 0.0)
	for s: Dictionary in _sparks:
		s["t"] = (s["t"] as float) - delta
		var v: Vector2 = s["v"]
		v.y += 900.0 * delta
		s["v"] = v
		s["p"] = (s["p"] as Vector2) + v * delta
	_sparks = _sparks.filter(func(s: Dictionary) -> bool: return (s["t"] as float) > 0.0)
	for sl: Dictionary in _slashes:
		sl["t"] = (sl["t"] as float) - delta
	_slashes = _slashes.filter(func(sl: Dictionary) -> bool: return (sl["t"] as float) > 0.0)
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	if debug:
		_draw_debug()
	var p: ToyPlayer = sim.player
	if p.is_alive():
		var origin: Vector2 = Vector2(p.x, -(p.y + FieldSim.MUZZLE_HEIGHT))
		var dir: Vector2 = Vector2(aim_dir.x, -aim_dir.y).normalized()
		var col: Color = Color(1.0, 0.85, 0.6, 0.55) if sim.weapon.is_loud() else Color(0.6, 0.85, 1.0, 0.45)
		draw_line(origin, origin + dir * 46.0, Color(0.05, 0.05, 0.06), 5.0)
		draw_line(origin + dir * 60.0, origin + dir * 90.0, col, 1.5)
	for t: Dictionary in _tracers:
		var k: float = (t["t"] as float) / TRACER_TIME
		var loud: bool = t["loud"]
		var c: Color = Color(1.0, 0.86, 0.55, k) if loud else Color(0.7, 0.85, 1.0, 0.5 * k)
		draw_line(t["a"], t["b"], c, 2.0 if loud else 1.0)
		if loud:
			draw_circle(t["a"] as Vector2, 14.0 * k, Color(1.0, 0.85, 0.5, 0.8 * k))
	if p.is_alive():
		for sl: Dictionary in _slashes:
			_draw_slash(p, sl["d"] as Vector2i, (sl["t"] as float) / SLASH_TIME)
	for s: Dictionary in _sparks:
		draw_rect(Rect2((s["p"] as Vector2) - Vector2(2, 2), Vector2(4, 4)), s["c"])
	# Tells: eyes glow red during the wind-up before a hit.
	for e: ToyEnemy in sim.enemies:
		if e.is_alive() and e.wind_up_left >= 0.0:
			var head: Vector2 = Vector2(e.x + e.heading * 6.0, -(e.top() + 6.0))
			draw_circle(head, 3.0, Color(1.0, 0.25, 0.15))


func _draw_slash(p: ToyPlayer, d: Vector2i, k: float) -> void:
	# Screen space: y is flipped. The arc sweeps across the side it hits.
	var centre: Vector2 = Vector2(p.x, -(p.y + ToyPlayer.HEIGHT * 0.5))
	var facing_angle: float = 0.0 if d.x > 0 else PI
	if d.y > 0:
		facing_angle = -PI * 0.5
	elif d.y < 0:
		facing_angle = PI * 0.5
	var spread: float = 1.1
	var sweep: float = (1.0 - k) * 0.4
	var radius: float = FieldSim.MELEE_RANGE * 0.75 if d.y == 0 else FieldSim.MELEE_VERTICAL_REACH * 0.8
	var c: Color = Color(0.92, 0.95, 1.0, 0.85 * k)
	draw_arc(centre, radius, facing_angle - spread + sweep, facing_angle + spread + sweep, 18, c, 7.0 * k + 1.0)
	draw_arc(centre, radius - 10.0, facing_angle - spread * 0.7 + sweep, facing_angle + spread * 0.7 + sweep, 14, Color(c, 0.4 * k), 2.0)


func _draw_debug() -> void:
	var font: Font = ThemeDB.fallback_font
	for src: NoiseSource in sim.sources:
		if src.is_active():
			var c: Color = Color(1.0, 0.8, 0.3, 0.35) if src.kind != NoiseSource.Kind.HUM else Color(0.5, 0.8, 1.0, 0.12)
			draw_arc(Vector2(src.x, 0.0), minf(src.radius, 2600.0), PI, TAU, 96, c, 2.0)
	for e: ToyEnemy in sim.enemies:
		if not e.is_alive():
			continue
		var c: Color = Color(0.5, 0.8, 1.0, 0.35) if e.target == sim.hum else Color(1.0, 0.7, 0.3, 0.6)
		draw_line(Vector2(e.x, -e.top() - 10.0), Vector2(e.target_x, -8.0), c, 1.0)
	if sim.swing_left > 0.0:
		var r: Rect2 = sim.swing_rect()
		draw_rect(Rect2(r.position.x, -r.end.y, r.size.x, r.size.y), Color(1.0, 1.0, 1.0, 0.5), false, 1.0)
	for s: ToyStructure in sim.structures:
		draw_string(font, Vector2(s.x - 30.0, -s.height() - 24.0), "%d" % int(s.health), HORIZONTAL_ALIGNMENT_CENTER, 60.0, 16, Color(1, 1, 1, 0.8))
		for side: int in [-1, 1]:
			var n: int = (s.piles[side] as Array).size()
			if n > 0:
				draw_string(font, Vector2(s.face_x(side) + side * 40.0 - 20.0, -s.height() - 6.0), "pile %d" % n, HORIZONTAL_ALIGNMENT_CENTER, 60.0, 14, Color(1, 0.6, 0.4))
