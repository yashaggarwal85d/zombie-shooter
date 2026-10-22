class_name StageCHouseView
extends Node2D
## EXPERIMENT (Stage C, C2/C3). Builds the greybox house as layered
## silhouettes, fog and light, in code so the scenes stay tiny. Draw order,
## back to front: sky, skyline, far fog, back walls, near fog, structure,
## chamber, actors, foreground, post. Fog never sits in front of actors.

enum Preset { HIGH, LOW }

const SHAMBLER_TEX: Texture2D = preload("res://shared/art/shambler.png")
const RUNNER_TEX: Texture2D = preload("res://shared/art/runner.png")
const PROTAGONIST_TEX: Texture2D = preload("res://shared/art/protagonist.png")
const ACTOR_SCALE: float = 0.38
const SLAB: float = 22.0

const SKY_TOP: Color = Color(0.015, 0.018, 0.03)
const SKY_LOW: Color = Color(0.07, 0.08, 0.11)
const SKYLINE: Color = Color(0.035, 0.04, 0.055)
const BACK_WALL: Color = Color(0.085, 0.088, 0.105)
const STRUCTURE: Color = Color(0.03, 0.03, 0.04)
const CHAMBER_LIGHT: Color = Color(0.7, 0.85, 1.0)
## Near-neutral: amber is reserved for infection (Stage B section 8, rule 4).
const LAMP_LIGHT: Color = Color(0.78, 0.74, 0.68)

var preset: Preset = Preset.HIGH
var building: StageCBuilding = StageCBuilding.new()
var actors_root: Node2D
var post_material: ShaderMaterial
var lights: Array[PointLight2D] = []
var _fog_materials: Array[ShaderMaterial] = []
var _post_rect: ColorRect
var _grain_layer: CanvasLayer
var _chamber_material: ShaderMaterial
var _chamber_light: PointLight2D
var _light_texture: GradientTexture2D
var _rim_material: ShaderMaterial
var _greyscale: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 11
	_light_texture = _make_light_texture()
	_rim_material = StageCShaders.material(StageCShaders.RIM)
	# No CanvasModulate: it would also dim the unshaded chamber and rims.
	# Base colours are authored dark and the lights add to them.
	_build_sky()
	_build_fog(0.5, Color(0.3, 0.35, 0.44), 2.2)
	_build_back_walls()
	_build_fog(0.22, Color(0.42, 0.48, 0.58), 3.5)
	_build_structure()
	_build_chamber()
	actors_root = Node2D.new()
	actors_root.name = "Actors"
	add_child(actors_root)
	_build_lights()
	_build_foreground()
	_build_post()
	apply_preset(preset)


func _process(_delta: float) -> void:
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 700.0)
	_chamber_material.set_shader_parameter("pulse", pulse)
	_chamber_light.energy = 1.6 + 0.15 * pulse


func apply_preset(p: Preset) -> void:
	preset = p
	var high: bool = p == Preset.HIGH
	for i: int in lights.size():
		var l: PointLight2D = lights[i]
		# The chamber light (index 0) and two lamps survive the low preset.
		l.visible = high or i < 3
		l.shadow_enabled = high
	for m: ShaderMaterial in _fog_materials:
		m.set_shader_parameter("octaves", 5 if high else 2)
	_update_post()


func set_greyscale(on: bool) -> void:
	_greyscale = on
	_update_post()


func is_greyscale() -> bool:
	return _greyscale


func _update_post() -> void:
	if post_material == null:
		return
	var high: bool = preset == Preset.HIGH
	post_material.set_shader_parameter("greyscale", _greyscale)
	post_material.set_shader_parameter("grain", 0.045 if high else 0.0)
	# Low preset skips the full-screen pass unless the greyscale check is on.
	_post_rect.visible = high or _greyscale


func make_actor(tex: Texture2D) -> Sprite2D:
	var s: Sprite2D = Sprite2D.new()
	s.texture = tex
	s.material = _rim_material
	s.centered = true
	s.offset = Vector2(0.0, -tex.get_height() * 0.5)
	s.scale = Vector2.ONE * ACTOR_SCALE
	actors_root.add_child(s)
	return s


func _make_light_texture() -> GradientTexture2D:
	var g: Gradient = Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	g.add_point(0.35, Color(1, 1, 1, 0.45))
	var t: GradientTexture2D = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 256
	t.height = 256
	return t


func _rect(pos: Vector2, size: Vector2, color: Color, parent: Node = self) -> Polygon2D:
	var p: Polygon2D = Polygon2D.new()
	p.polygon = PackedVector2Array([pos, pos + Vector2(size.x, 0), pos + size, pos + Vector2(0, size.y)])
	p.color = color
	parent.add_child(p)
	return p


func _poly(points: PackedVector2Array, color: Color, parent: Node = self) -> Polygon2D:
	var p: Polygon2D = Polygon2D.new()
	p.polygon = points
	p.color = color
	parent.add_child(p)
	return p


func _occlude(pos: Vector2, size: Vector2) -> void:
	var o: LightOccluder2D = LightOccluder2D.new()
	var poly: OccluderPolygon2D = OccluderPolygon2D.new()
	poly.polygon = PackedVector2Array([pos, pos + Vector2(size.x, 0), pos + size, pos + Vector2(0, size.y)])
	o.occluder = poly
	add_child(o)


func _build_sky() -> void:
	var g: Gradient = Gradient.new()
	g.set_color(0, SKY_TOP)
	g.set_color(1, SKY_LOW)
	var t: GradientTexture2D = GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	var sky: TextureRect = TextureRect.new()
	sky.texture = t
	sky.position = Vector2(-400, -300)
	sky.size = Vector2(2720, 1680)
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(sky)
	# Distant skyline: ragged blocks, a crane, a water tower.
	var x: float = -400.0
	var pts: PackedVector2Array = PackedVector2Array([Vector2(-400, 1100)])
	while x < 2320.0:
		var h: float = _rng.randf_range(520.0, 780.0)
		var w: float = _rng.randf_range(60.0, 180.0)
		pts.append(Vector2(x, h))
		pts.append(Vector2(x + w, h))
		x += w + _rng.randf_range(0.0, 30.0)
	pts.append(Vector2(2320, 1100))
	_poly(pts, SKYLINE)
	_poly(PackedVector2Array([Vector2(1830, 300), Vector2(1840, 300), Vector2(1846, 700), Vector2(1824, 700)]), SKYLINE)
	_poly(PackedVector2Array([Vector2(1660, 300), Vector2(2050, 300), Vector2(2050, 310), Vector2(1660, 312)]), SKYLINE)
	var moon: Polygon2D = _poly(_circle(Vector2(300, 130), 38.0, 32), Color(0.55, 0.6, 0.68))
	moon.material = _unshaded()


func _circle(c: Vector2, r: float, n: int) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for i: int in n:
		var a: float = TAU * i / n
		out.append(c + Vector2(cos(a), sin(a)) * r)
	return out


func _unshaded() -> CanvasItemMaterial:
	var m: CanvasItemMaterial = CanvasItemMaterial.new()
	m.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	return m


func _build_fog(density: float, color: Color, scale_value: float) -> void:
	var r: ColorRect = ColorRect.new()
	r.position = Vector2(-400, -300)
	r.size = Vector2(2720, 1680)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m: ShaderMaterial = StageCShaders.material(StageCShaders.FOG)
	m.set_shader_parameter("density", density)
	m.set_shader_parameter("fog_color", color)
	m.set_shader_parameter("scale", scale_value)
	r.material = m
	_fog_materials.append(m)
	add_child(r) # draw order comes from tree order, see the class comment


func _build_back_walls() -> void:
	var top: float = StageCBuilding.LEVEL_Y[3]
	var bottom: float = StageCBuilding.LEVEL_Y[0]
	_rect(Vector2(StageCBuilding.FLOOR_LEFT, top), Vector2(StageCBuilding.FLOOR_RIGHT - StageCBuilding.FLOOR_LEFT, bottom - top), BACK_WALL)
	# Peeling wallpaper strips, frames, a shelf: value noise for the lights to catch.
	for lvl: int in 3:
		var floor_y: float = StageCBuilding.LEVEL_Y[lvl]
		var ceil_y: float = StageCBuilding.LEVEL_Y[lvl + 1] + SLAB
		var x: float = StageCBuilding.FLOOR_LEFT
		while x < StageCBuilding.FLOOR_RIGHT:
			var w: float = _rng.randf_range(30.0, 90.0)
			var shade: float = _rng.randf_range(-0.035, 0.03)
			_rect(Vector2(x, ceil_y), Vector2(w, floor_y - ceil_y), BACK_WALL + Color(shade, shade, shade, 0))
			x += w
		for i: int in 4:
			var fx: float = _rng.randf_range(220.0, 1660.0)
			if absf(fx - StageCBuilding.CHAMBER_X) < 120.0 and lvl == StageCBuilding.CHAMBER_LEVEL:
				continue
			var fw: float = _rng.randf_range(40.0, 90.0)
			var fh: float = _rng.randf_range(40.0, 70.0)
			_rect(Vector2(fx, floor_y - 170.0), Vector2(fw, fh), BACK_WALL.darkened(0.45))
			_rect(Vector2(fx + 5, floor_y - 165.0), Vector2(fw - 10, fh - 10), BACK_WALL.darkened(0.2))
		# Crack running down from the ceiling.
		var cx: float = _rng.randf_range(300.0, 1600.0)
		var crack: PackedVector2Array = PackedVector2Array()
		var cy: float = ceil_y
		while cy < floor_y - 60.0:
			crack.append(Vector2(cx, cy))
			cx += _rng.randf_range(-14.0, 14.0)
			cy += _rng.randf_range(12.0, 26.0)
		var line: Line2D = Line2D.new()
		line.points = crack
		line.width = 2.0
		line.default_color = BACK_WALL.darkened(0.6)
		add_child(line)


func _build_structure() -> void:
	var left: float = StageCBuilding.FLOOR_LEFT
	var right: float = StageCBuilding.FLOOR_RIGHT
	var width: float = right - left
	# Floor slabs; the walk line is the top of each slab.
	for lvl: int in 3:
		var y: float = StageCBuilding.LEVEL_Y[lvl]
		_rect(Vector2(left - 20, y), Vector2(width + 40, SLAB), STRUCTURE)
		_occlude(Vector2(left - 20, y), Vector2(width + 40, SLAB))
	var roof_y: float = StageCBuilding.LEVEL_Y[3]
	_rect(Vector2(left - 30, roof_y), Vector2(width + 60, SLAB + 6), STRUCTURE)
	_occlude(Vector2(left - 30, roof_y), Vector2(width + 60, SLAB + 6))
	# Ground and basement below floor 0.
	_rect(Vector2(-400, StageCBuilding.LEVEL_Y[0] + SLAB), Vector2(2720, 400), Color(0.02, 0.02, 0.025))
	# Outer walls with window gaps at each entry.
	for side: float in [left - 20.0, right]:
		for lvl: int in 3:
			var y0: float = StageCBuilding.LEVEL_Y[lvl + 1] + SLAB
			var y1: float = StageCBuilding.LEVEL_Y[lvl]
			_rect(Vector2(side, y0), Vector2(20, 40), STRUCTURE)
			_rect(Vector2(side, y1 - 40), Vector2(20, 40), STRUCTURE)
			_occlude(Vector2(side, y0), Vector2(20, 40))
			# Broken boards across the window.
			_poly(PackedVector2Array([Vector2(side - 6, y0 + 70), Vector2(side + 26, y0 + 54), Vector2(side + 26, y0 + 62), Vector2(side - 6, y0 + 79)]), STRUCTURE)
	# Rooftop parapet and water tank.
	_rect(Vector2(left - 30, roof_y - 24), Vector2(12, 24), STRUCTURE)
	_rect(Vector2(right + 18, roof_y - 24), Vector2(12, 24), STRUCTURE)
	_rect(Vector2(420, roof_y - 120), Vector2(110, 80), STRUCTURE)
	for lx: float in [430.0, 510.0]:
		_rect(Vector2(lx, roof_y - 40), Vector2(8, 40), STRUCTURE)
	# Stairs: a stringer and treads along each flight.
	for e: Vector2i in building.stair_edges:
		var a: Vector2 = building.astar.get_point_position(e.x)
		var b: Vector2 = building.astar.get_point_position(e.y)
		var line: Line2D = Line2D.new()
		line.points = PackedVector2Array([a + Vector2(0, 8), b + Vector2(0, 8)])
		line.width = 12.0
		line.default_color = STRUCTURE
		add_child(line)
		var steps: int = 10
		for i: int in steps:
			var p: Vector2 = a.lerp(b, (i + 0.5) / steps)
			var dir: float = signf(b.x - a.x)
			_rect(p + Vector2(-6.0 * dir - 6.0, 0), Vector2(12, 4), STRUCTURE)
	# The entries as dark doorways on the front door and roof hatch.
	_rect(Vector2(1160, StageCBuilding.LEVEL_Y[0] - 150), Vector2(56, 150), Color(0.01, 0.01, 0.015))


func _build_chamber() -> void:
	var base: Vector2 = building.chamber_position()
	var w: float = 96.0
	var h: float = 184.0
	# Frame and base unit.
	_rect(base + Vector2(-w * 0.5 - 14, -h - 16), Vector2(w + 28, h + 16), STRUCTURE)
	_rect(base + Vector2(-w * 0.5 - 24, -26), Vector2(w + 48, 26), STRUCTURE)
	# Glass capsule.
	var glass: Polygon2D = Polygon2D.new()
	var pts: PackedVector2Array = PackedVector2Array()
	var r: float = w * 0.5
	var top_c: Vector2 = base + Vector2(0, -h + r)
	for i: int in 17:
		var a: float = PI + PI * i / 16.0
		pts.append(top_c + Vector2(cos(a), sin(a)) * r)
	pts.append(base + Vector2(r, -30))
	pts.append(base + Vector2(-r, -30))
	glass.polygon = pts
	var uvs: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in pts:
		uvs.append(Vector2((p.x - (base.x - r)) / w, (p.y - (base.y - h)) / h))
	glass.uv = uvs
	glass.color = Color.WHITE
	_chamber_material = StageCShaders.material(StageCShaders.CHAMBER_GLASS)
	glass.material = _chamber_material
	add_child(glass)
	# Her silhouette inside, faint: she is there, not an object (Stage B 7).
	var her_color: Color = Color(0.32, 0.42, 0.56, 0.38)
	var head: Polygon2D = _poly(_circle(base + Vector2(2, -138), 11.0, 20), her_color)
	head.material = _unshaded()
	var her: Polygon2D = _poly(PackedVector2Array([
		base + Vector2(-4, -127), base + Vector2(8, -127), base + Vector2(20, -116),
		base + Vector2(16, -80), base + Vector2(12, -40), base + Vector2(-10, -40),
		base + Vector2(-14, -80), base + Vector2(-18, -114)]), her_color)
	her.material = _unshaded()
	# Pipes and cables running to the generator below.
	for dx: float in [-38.0, 30.0]:
		var cable: Line2D = Line2D.new()
		cable.points = PackedVector2Array([base + Vector2(dx, -10), base + Vector2(dx * 1.6, 0), base + Vector2(dx * 3.0, 18)])
		cable.width = 6.0
		cable.default_color = STRUCTURE
		add_child(cable)
	# Frost motes drifting up around the glass.
	var motes: CPUParticles2D = CPUParticles2D.new()
	motes.position = base + Vector2(0, -90)
	motes.amount = 24
	motes.lifetime = 4.0
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(70, 90)
	motes.direction = Vector2(0, -1)
	motes.spread = 30.0
	motes.gravity = Vector2.ZERO
	motes.initial_velocity_min = 4.0
	motes.initial_velocity_max = 12.0
	motes.scale_amount_min = 1.5
	motes.scale_amount_max = 3.0
	motes.color = Color(0.8, 0.92, 1.0, 0.7)
	motes.material = _unshaded()
	add_child(motes)


func _build_lights() -> void:
	var c: Vector2 = building.chamber_position()
	_chamber_light = _light(c + Vector2(0, -110), CHAMBER_LIGHT, 1.6, 4.0)
	_light(Vector2(640, StageCBuilding.LEVEL_Y[0] - 190), LAMP_LIGHT, 0.9, 2.6)
	_light(Vector2(1300, StageCBuilding.LEVEL_Y[2] - 190), LAMP_LIGHT, 0.8, 2.4)
	_light(Vector2(300, StageCBuilding.LEVEL_Y[1] - 190), LAMP_LIGHT, 0.6, 2.0)
	_light(Vector2(1600, StageCBuilding.LEVEL_Y[1] - 190), LAMP_LIGHT, 0.6, 2.0)
	_light(Vector2(400, StageCBuilding.LEVEL_Y[2] - 190), LAMP_LIGHT, 0.5, 2.0)
	_light(Vector2(1500, StageCBuilding.LEVEL_Y[0] - 190), LAMP_LIGHT, 0.5, 2.0)
	_light(Vector2(300, 130), Color(0.55, 0.62, 0.75), 0.6, 8.0) # moon over the roof


func _light(pos: Vector2, color: Color, energy: float, scale_value: float) -> PointLight2D:
	var l: PointLight2D = PointLight2D.new()
	l.position = pos
	l.texture = _light_texture
	l.color = color
	l.energy = energy
	l.texture_scale = scale_value
	l.shadow_filter = Light2D.SHADOW_FILTER_PCF5
	l.shadow_filter_smooth = 2.0
	add_child(l)
	lights.append(l)
	return l


func _build_foreground() -> void:
	# Near layer: big dark shapes kept below floor 0 and outside the walls,
	# never across a floor lane (Stage B section 8, principle 2).
	var fg: Node2D = Node2D.new()
	fg.name = "Foreground"
	add_child(fg)
	var near: Color = Color(0.0, 0.0, 0.0)
	_poly(PackedVector2Array([Vector2(-400, 1100), Vector2(-400, 940), Vector2(-100, 960), Vector2(120, 1000), Vector2(420, 1040), Vector2(520, 1100)]), near, fg)
	_poly(PackedVector2Array([Vector2(1500, 1100), Vector2(1700, 1010), Vector2(1900, 990), Vector2(2320, 1000), Vector2(2320, 1100)]), near, fg)
	var pipe: Line2D = Line2D.new()
	pipe.points = PackedVector2Array([Vector2(60, 1100), Vector2(60, 960), Vector2(100, 920), Vector2(100, 120)])
	pipe.width = 26.0
	pipe.default_color = near
	fg.add_child(pipe)
	var wire: Line2D = Line2D.new()
	wire.points = PackedVector2Array([Vector2(100, 240), Vector2(-200, 290), Vector2(-400, 270)])
	wire.width = 3.0
	wire.default_color = near
	fg.add_child(wire)


func _build_post() -> void:
	_grain_layer = CanvasLayer.new()
	_grain_layer.layer = 50
	add_child(_grain_layer)
	_post_rect = ColorRect.new()
	_post_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	post_material = StageCShaders.material(StageCShaders.POST)
	_post_rect.material = post_material
	_grain_layer.add_child(_post_rect)
