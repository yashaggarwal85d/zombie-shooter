class_name ToyFieldView
extends Node2D
## Draws the stop: sky, layered woods, fog, ground, the shelter with the pod's
## light, built structures and build spots. World units are field units with
## y flipped (screen up is -y). The infected and the player are drawn by
## ToyActorLayer so they can carry the rim shader.

const TREE_LAYERS: int = 3
const GROUND_DEPTH: float = 400.0

var sim: FieldSim
var plan: BuildPlan
var building: bool = true
var nearest_spot: int = -1
var palette: ToyPalette = ToyPalette.night()
var flash: Dictionary[ToyStructure, float] = {}
var shelter_flash: float = 0.0
var _trees: Array[Array] = []
var _time: float = 0.0


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 11
	for layer: int in TREE_LAYERS:
		var polys: Array[PackedVector2Array] = []
		var x: float = -900.0
		var scale_f: float = 0.6 + layer * 0.25
		while x < FieldSim.WORLD_WIDTH + 900.0:
			polys.append_array(_pine(x, rng.randf_range(260.0, 520.0) * scale_f, rng.randf_range(80.0, 130.0) * scale_f, rng))
			x += rng.randf_range(60.0, 150.0) * scale_f
		_trees.append(polys)


## A pine as stacked triangles (one polygon per tier), drawn as silhouettes.
func _pine(x: float, h: float, w: float, rng: RandomNumberGenerator) -> Array[PackedVector2Array]:
	var tiers: int = rng.randi_range(4, 6)
	var out: Array[PackedVector2Array] = [PackedVector2Array([Vector2(x - 3.0, 0.0), Vector2(x + 3.0, 0.0), Vector2(x + 2.0, -h * 0.3), Vector2(x - 2.0, -h * 0.3)])]
	for i: int in tiers:
		var k: float = float(i) / tiers
		var base: float = -h * (0.18 + 0.7 * k)
		var half: float = w * 0.5 * (1.0 - 0.75 * k) * rng.randf_range(0.85, 1.1)
		var tip: float = base - h * 0.32
		out.append(PackedVector2Array([Vector2(x - half, base), Vector2(x + half, base + rng.randf_range(-4.0, 4.0)), Vector2(x + rng.randf_range(-3.0, 3.0), tip)]))
	return out


func _process(delta: float) -> void:
	_time += delta
	for s: ToyStructure in flash.keys():
		flash[s] = flash[s] - delta
		if flash[s] <= 0.0:
			flash.erase(s)
	shelter_flash = maxf(0.0, shelter_flash - delta)
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	var view: Rect2 = _visible_world()
	_draw_sky(view)
	for layer: int in TREE_LAYERS:
		var c: Color = palette.trees[layer]
		for poly: PackedVector2Array in _trees[layer]:
			draw_colored_polygon(poly, c)
		if layer < TREE_LAYERS - 1:
			# Ground fog thickening toward the ground, behind the play plane.
			for band: int in 8:
				var top_y: float = -300.0 + layer * 60.0 + band * 30.0
				draw_rect(Rect2(view.position.x, top_y, view.size.x, -top_y), Color(palette.fog, palette.fog.a * 0.3))
	draw_rect(Rect2(view.position.x, 0.0, view.size.x, GROUND_DEPTH), palette.ground)
	draw_line(Vector2(view.position.x, 0.0), Vector2(view.end.x, 0.0), palette.wood_edge.darkened(0.6), 2.0)
	_draw_shelter(sim.shelter)
	for s: ToyStructure in sim.structures:
		if not s.is_shelter and s.is_standing():
			_draw_structure(s)
	if building and plan != null:
		_draw_build_spots()


func _visible_world() -> Rect2:
	var inv: Transform2D = get_canvas_transform().affine_inverse()
	var size: Vector2 = get_viewport_rect().size
	var a: Vector2 = inv * Vector2.ZERO
	var b: Vector2 = inv * size
	return Rect2(a, b - a)


func _draw_sky(view: Rect2) -> void:
	var top: float = view.position.y
	var bands: int = 48
	for i: int in bands:
		var k: float = float(i) / bands
		var y0: float = lerpf(top, 0.0, k)
		var y1: float = lerpf(top, 0.0, k + 1.0 / bands)
		draw_rect(Rect2(view.position.x, y0, view.size.x, y1 - y0 + 1.0), palette.sky_top.lerp(palette.sky_bottom, k))
	if not building:
		var moon: Vector2 = Vector2(FieldSim.SHELTER_X + 520.0, -760.0)
		for r: int in 4:
			draw_circle(moon, 46.0 + r * 26.0, Color(0.6, 0.7, 0.85, 0.035))
		draw_circle(moon, 40.0, Color(0.62, 0.68, 0.76))


func _draw_shelter(s: ToyStructure) -> void:
	var l: float = s.left()
	var r: float = s.right()
	var h: float = s.height()
	var body_h: float = h - 22.0
	var light: float = s.health_fraction()
	# Pod light spilling out (drawn first so the cabin sits over it).
	var window: Rect2 = Rect2(s.x - 70.0, -body_h + 40.0, 56.0, 42.0)
	var flicker: float = 1.0 - 0.25 * shelter_flash / 0.2 + 0.04 * sin(_time * 7.0)
	var glow: float = (0.25 + 0.75 * light) * flicker
	for i: int in 14:
		draw_circle(window.get_center(), 40.0 + i * 18.0, Color(palette.pod_light, 0.018 * glow))
	draw_rect(Rect2(l, -body_h, r - l, body_h), palette.shelter_body)
	var roof: PackedVector2Array = [Vector2(l - 16.0, -body_h), Vector2(r + 16.0, -body_h), Vector2(r + 6.0, -h), Vector2(l - 6.0, -h)]
	draw_colored_polygon(roof, palette.shelter_body.darkened(0.2))
	draw_line(Vector2(l - 6.0, -h), Vector2(r + 6.0, -h), palette.wood_edge, 2.0)
	# Logs.
	for i: int in int(body_h / 18.0):
		draw_line(Vector2(l, -i * 18.0), Vector2(r, -i * 18.0), palette.shelter_body.lightened(0.06), 1.0)
	# Window with the pod's cold light, the brightest thing on screen.
	draw_rect(window, Color(palette.pod_light, clampf(0.35 + 0.65 * glow, 0.0, 1.0)))
	draw_line(Vector2(window.get_center().x, window.position.y), Vector2(window.get_center().x, window.end.y), palette.shelter_body, 3.0)
	draw_line(Vector2(window.position.x, window.get_center().y), Vector2(window.end.x, window.get_center().y), palette.shelter_body, 3.0)
	# Door.
	draw_rect(Rect2(s.x + 40.0, -86.0, 40.0, 86.0), palette.shelter_body.darkened(0.5))
	draw_rect(Rect2(s.x + 40.0, -86.0, 40.0, 86.0), Color(palette.pod_light, 0.06 * glow), false, 2.0)
	# Chimney.
	draw_rect(Rect2(r - 50.0, -h - 30.0, 22.0, 30.0), palette.shelter_body.darkened(0.3))
	_draw_cracks(s, Rect2(l, -body_h, r - l, body_h))
	if s.has_ladder:
		_draw_ladder(l - ToyPlayer.HALF_WIDTH, h)
		_draw_ladder(r + ToyPlayer.HALF_WIDTH, h)


func _draw_structure(s: ToyStructure) -> void:
	var rect: Rect2 = Rect2(s.left(), -s.height(), s.definition.width, s.height())
	var base: Color = palette.wood
	if flash.has(s):
		base = base.lerp(Color(0.6, 0.55, 0.5), 0.5)
	match s.definition.id:
		&"fence":
			for i: int in 2:
				draw_rect(Rect2(s.left() + 2.0 + i * (s.definition.width - 10.0), -s.height(), 6.0, s.height()), base)
			for k: int in 3:
				var y: float = -12.0 - k * 18.0
				draw_line(Vector2(s.left() - 6.0, y + 6.0), Vector2(s.right() + 6.0, y - 4.0), base, 7.0)
		_:
			draw_rect(rect, base)
			var plank: float = 16.0
			for k: int in int(s.height() / plank):
				draw_line(Vector2(s.left(), -k * plank), Vector2(s.right(), -k * plank), base.lightened(0.08), 1.0)
			if s.definition.id == &"high_wall":
				for k: int in 4:
					var px: float = s.left() + 5.0 + k * (s.definition.width - 10.0) / 3.0
					draw_colored_polygon(PackedVector2Array([Vector2(px - 4.0, -s.height()), Vector2(px + 4.0, -s.height()), Vector2(px, -s.height() - 10.0)]), base)
	draw_line(Vector2(s.left(), -s.height()), Vector2(s.right(), -s.height()), palette.wood_edge, 2.0)
	_draw_cracks(s, rect)
	if s.has_ladder:
		_draw_ladder(s.left() - ToyPlayer.HALF_WIDTH, s.height())
		_draw_ladder(s.right() + ToyPlayer.HALF_WIDTH, s.height())


func _draw_cracks(s: ToyStructure, rect: Rect2) -> void:
	var f: float = s.health_fraction()
	if f > 0.5:
		return
	var c: Color = Color(palette.wood_edge, 0.7)
	var cx: float = rect.get_center().x
	draw_polyline(PackedVector2Array([Vector2(cx - 6.0, rect.position.y + 6.0), Vector2(cx + 4.0, rect.position.y + rect.size.y * 0.3), Vector2(cx - 3.0, rect.position.y + rect.size.y * 0.55)]), c, 1.5)
	if f <= 0.25:
		draw_polyline(PackedVector2Array([Vector2(rect.position.x + 4.0, rect.end.y - 10.0), Vector2(cx, rect.end.y - rect.size.y * 0.4), Vector2(rect.end.x - 4.0, rect.end.y - rect.size.y * 0.7)]), c, 1.5)


func _draw_ladder(x: float, h: float) -> void:
	var c: Color = palette.wood_edge.darkened(0.35)
	draw_line(Vector2(x - 7.0, 0.0), Vector2(x - 7.0, -h - 8.0), c, 2.0)
	draw_line(Vector2(x + 7.0, 0.0), Vector2(x + 7.0, -h - 8.0), c, 2.0)
	var y: float = -10.0
	while y > -h:
		draw_line(Vector2(x - 7.0, y), Vector2(x + 7.0, y), c, 2.0)
		y -= 16.0


func _draw_build_spots() -> void:
	var font: Font = ThemeDB.fallback_font
	for i: int in plan.spot_xs.size():
		var x: float = plan.spot_xs[i]
		var active: bool = i == nearest_spot
		var c: Color = Color(1.0, 0.92, 0.6, 0.9) if active else Color(1.0, 1.0, 1.0, 0.35)
		draw_line(Vector2(x - 30.0, 6.0), Vector2(x + 30.0, 6.0), c, 3.0)
		draw_line(Vector2(x, 6.0), Vector2(x, 18.0), c, 2.0)
		var label: String = plan.option_at(i).label()
		draw_string(font, Vector2(x - 100.0, 44.0), label, HORIZONTAL_ALIGNMENT_CENTER, 200.0, 18, c)
		var cost: int = plan.option_at(i).cost()
		if cost > 0:
			draw_string(font, Vector2(x - 100.0, 66.0), "%d scrap" % cost, HORIZONTAL_ALIGNMENT_CENTER, 200.0, 14, Color(c, 0.6))
