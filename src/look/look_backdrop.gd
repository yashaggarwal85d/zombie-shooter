class_name LookBackdrop
extends Node2D
## The woods kit of the Himalayan hill road, behind the play plane: sky, the
## sun or moon, snow peaks, valley cloud, forested ridges, two layers of
## deodars and ground mist (ART_AND_AUDIO_GUIDE section 4). Every layer is
## built once in white and coloured through modulate by apply().

const X0: float = -700.0
const X1: float = 2900.0
const TOP: float = -1500.0
const BOTTOM: float = 600.0
## Trees keep back from the cabin so its outline reads against the mist.
const CLEARING: Vector2 = Vector2(840.0, 1360.0)
const GLOW: Texture2D = preload("res://src/look/radial_glow.tres")
const FOG_SHADER: Shader = preload("res://src/look/fog.gdshader")

var _sky: Node2D
var _orb: Node2D
var _orb_pos: Vector2 = Vector2(1640.0, -760.0)
var _snow: Node2D
var _ridges: Array[Node2D] = []
var _trees: Array[Node2D] = []
var _fogs: Array[ColorRect] = []
var _ground: Node2D
var _palette: LookPalette


func _ready() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	_sky = _layer(_draw_sky)
	_orb = _layer(_draw_orb)
	_orb.material = _additive()
	# Far peaks, with snow.
	var far: FastNoiseLite = _noise(3, 0.0016)
	var far_line: PackedVector2Array = LookShapes.ridge_line(X0, X1, -400.0, 260.0, far, 0.75, 6.0)
	# One massif stands over the cabin's right shoulder and anchors the frame.
	for i: int in far_line.size():
		var d: float = (far_line[i].x - 1480.0) / 380.0
		far_line[i].y -= 190.0 * exp(-d * d)
	var far_poly: PackedVector2Array = far_line.duplicate()
	far_poly.append(Vector2(X1, BOTTOM))
	far_poly.append(Vector2(X0, BOTTOM))
	_ridges.append(_shape_layer([far_poly]))
	_snow = _shape_layer(LookShapes.snow_caps(far_line, -580.0, rng))
	_fogs.append(_fog(-640.0, -300.0, 0.3, 1.0))
	# Lower foothills between the snow and the forest.
	var foot: FastNoiseLite = _noise(4, 0.0026)
	_ridges.append(_shape_layer([LookShapes.ridge(X0, X1, -330.0, 150.0, BOTTOM, foot, 0.4, 8.0)]))
	_fogs.append(_fog(-470.0, -180.0, 0.3, 0.9))
	# Mid ridge, forested.
	var mid: FastNoiseLite = _noise(5, 0.003)
	var mid_line: PackedVector2Array = LookShapes.ridge_line(X0, X1, -250.0, 170.0, mid, 0.15, 10.0)
	var mid_shapes: Array[PackedVector2Array] = [LookShapes.ridge(X0, X1, -250.0, 170.0, BOTTOM, mid, 0.15, 10.0)]
	mid_shapes.append_array(LookShapes.tree_fringe(mid_line, 16.0, rng))
	_ridges.append(_shape_layer(mid_shapes))
	_fogs.append(_fog(-420.0, -90.0, 0.25, 0.9))
	# Near hill, then the far deodars on it.
	var near: FastNoiseLite = _noise(9, 0.004)
	var near_line: PackedVector2Array = LookShapes.ridge_line(X0, X1, -70.0, 120.0, near, 0.0, 12.0)
	var near_shapes: Array[PackedVector2Array] = [LookShapes.ridge(X0, X1, -70.0, 120.0, BOTTOM, near, 0.0, 12.0)]
	near_shapes.append_array(LookShapes.tree_fringe(near_line, 26.0, rng))
	_ridges.append(_shape_layer(near_shapes))
	_trees.append(_shape_layer(_forest(rng, 150.0, 300.0, 55.0, 110.0, -20.0, 120.0)))
	_fogs.append(_fog(-330.0, 0.0, 0.2, 1.0))
	_trees.append(_shape_layer(_forest(rng, 330.0, 560.0, 140.0, 260.0, 0.0, 40.0)))
	# Mist at the foot of the near trees keeps the play lane lighter than
	# the figures standing in it (rule 1).
	_fogs.append(_fog(-300.0, 0.0, 0.35, 1.15))
	_ground = _layer(_draw_ground)


func apply(p: LookPalette, quality_high: bool, pod_world: Vector2, pod_light: float) -> void:
	_palette = p
	_sky.queue_redraw()
	_orb.queue_redraw()
	_orb.visible = p.orb.a > 0.01
	_orb_pos = Vector2(1720.0, lerpf(-300.0, -900.0, p.orb_height))
	_snow.self_modulate = p.snow
	for i: int in _ridges.size():
		_ridges[i].self_modulate = p.ridges[mini(i, p.ridges.size() - 1)]
	for i: int in _trees.size():
		_trees[i].self_modulate = p.trees[mini(i, p.trees.size() - 1)]
	_ground.self_modulate = p.ground
	for i: int in _fogs.size():
		var m: ShaderMaterial = _fogs[i].material as ShaderMaterial
		m.set_shader_parameter(&"fog_color", p.fog)
		m.set_shader_parameter(&"detail", 1.0 if quality_high else 0.0)
		m.set_shader_parameter(&"light_pos", pod_world)
		# Only the two nearest mist layers catch the pod's light.
		m.set_shader_parameter(&"light_strength", pod_light * (0.9 if i >= 2 else 0.0))


func _layer(painter: Callable) -> Node2D:
	var n: LookLayer = LookLayer.new()
	n.painter = painter
	add_child(n)
	return n


func _shape_layer(shapes: Array[PackedVector2Array]) -> Node2D:
	var n: LookLayer = LookLayer.new()
	n.shapes = shapes
	add_child(n)
	return n


func _fog(top: float, bottom: float, floor_share: float, density: float) -> ColorRect:
	var r: ColorRect = ColorRect.new()
	r.position = Vector2(X0, top)
	r.size = Vector2(X1 - X0, bottom - top)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m: ShaderMaterial = ShaderMaterial.new()
	m.shader = FOG_SHADER
	m.set_shader_parameter(&"floor_share", floor_share)
	m.set_shader_parameter(&"density", density)
	m.set_shader_parameter(&"seed", float(_fogs.size()) * 13.7)
	m.set_shader_parameter(&"drift", 6.0 + _fogs.size() * 4.0)
	r.material = m
	add_child(r)
	return r


func _noise(seed_value: int, freq: float) -> FastNoiseLite:
	var n: FastNoiseLite = FastNoiseLite.new()
	n.seed = seed_value
	n.frequency = freq
	n.fractal_octaves = 4
	return n


func _additive() -> CanvasItemMaterial:
	var m: CanvasItemMaterial = CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


## Deodars spread along the field, thinned around the cabin.
func _forest(rng: RandomNumberGenerator, h0: float, h1: float, gap0: float, gap1: float, base_y: float, base_jitter: float) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var x: float = X0
	while x < X1:
		var in_clearing: bool = x > CLEARING.x and x < CLEARING.y
		var h: float = rng.randf_range(h0, h1) * (0.55 if in_clearing else 1.0)
		if not in_clearing or rng.randf() < 0.35:
			out.append_array(LookShapes.deodar(x, base_y - rng.randf_range(0.0, base_jitter), h, rng))
		x += rng.randf_range(gap0, gap1)
	return out


func _draw_sky(n: Node2D) -> void:
	if _palette == null:
		return
	var top: Color = _palette.sky_top
	var hor: Color = _palette.sky_horizon
	var mid: Color = top.lerp(hor, 0.35)
	n.draw_polygon(PackedVector2Array([Vector2(X0, TOP), Vector2(X1, TOP), Vector2(X1, -880.0), Vector2(X0, -880.0)]), PackedColorArray([top, top, top, top]))
	n.draw_polygon(PackedVector2Array([Vector2(X0, -880.0), Vector2(X1, -880.0), Vector2(X1, -640.0), Vector2(X0, -640.0)]), PackedColorArray([top, top, mid, mid]))
	n.draw_polygon(PackedVector2Array([Vector2(X0, -640.0), Vector2(X1, -640.0), Vector2(X1, -400.0), Vector2(X0, -400.0)]), PackedColorArray([mid, mid, hor, hor]))
	n.draw_rect(Rect2(X0, -400.0, X1 - X0, 400.0), hor)


func _draw_orb(n: Node2D) -> void:
	if _palette == null:
		return
	var c: Color = _palette.orb
	n.draw_texture_rect(GLOW, Rect2(_orb_pos - Vector2(420.0, 420.0), Vector2(840.0, 840.0)), false, Color(c, c.a * 0.22))
	n.draw_texture_rect(GLOW, Rect2(_orb_pos - Vector2(120.0, 120.0), Vector2(240.0, 240.0)), false, Color(c, c.a * 0.35))
	n.draw_circle(_orb_pos, 34.0, Color(c, c.a * 0.9))


func _draw_ground(n: Node2D) -> void:
	n.draw_rect(Rect2(X0, 0.0, X1 - X0, BOTTOM), Color.WHITE)


## A node that draws white shapes once, or calls a painter every redraw.
class LookLayer:
	extends Node2D
	var shapes: Array[PackedVector2Array] = []
	var painter: Callable

	func _ready() -> void:
		# Generated shapes can fold over themselves; drop any that can't be filled.
		shapes = shapes.filter(func(poly: PackedVector2Array) -> bool: return not Geometry2D.triangulate_polygon(poly).is_empty())

	func _draw() -> void:
		if painter.is_valid():
			painter.call(self)
			return
		for poly: PackedVector2Array in shapes:
			draw_colored_polygon(poly, Color.WHITE)
