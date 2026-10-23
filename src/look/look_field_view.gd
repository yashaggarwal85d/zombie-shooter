class_name LookFieldView
extends ToyFieldView
## The play plane in the look-test style: a kath-kuni hill hut (stone courses
## between timber bands, a slate hip roof with a carved fringe) with the pod's
## light in its window, and structures built from stone and deodar poles.
## With `look_on` false it draws the greybox exactly as before.
## Rules it follows (ART_AND_AUDIO_GUIDE section 3): the play plane is the
## darkest band; every surface you can stand on carries a key-light edge;
## the pod's window is the brightest thing on screen.

const GLOW: Texture2D = preload("res://src/look/radial_glow.tres")
## The pod's light reaches about this far along the ground.
const POD_REACH: float = 760.0

var look_on: bool = false
var look: LookPalette
## 0..1: how bright the pod is right now (time of day × the cabin's health).
var pod_light: float = 1.0
var _bloom: Node2D


func _ready() -> void:
	super._ready()
	_bloom = Node2D.new()
	var m: CanvasItemMaterial = CanvasItemMaterial.new()
	m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_bloom.material = m
	_bloom.draw.connect(_draw_bloom)
	add_child(_bloom)


func _process(delta: float) -> void:
	super._process(delta)
	_bloom.queue_redraw()


## Where the pod's light comes from, in world space.
func pod_window() -> Vector2:
	if sim == null:
		return Vector2(FieldSim.SHELTER_X - 52.0, -80.0)
	return Vector2(sim.shelter.x - 52.0, -80.0)


func pod_glow() -> float:
	if sim == null:
		return pod_light
	var flicker: float = 1.0 - 0.3 * shelter_flash / 0.2 + 0.03 * sin(_time * 7.0)
	return pod_light * (0.3 + 0.7 * sim.shelter.health_fraction()) * flicker


func _draw() -> void:
	if not look_on or look == null:
		_bloom.visible = false
		super._draw()
		return
	_bloom.visible = true
	if sim == null:
		return
	var glow: float = pod_glow()
	var pod: Color = palette.pod_light
	# Light pooled on the ground in front of the cabin.
	var w: Vector2 = pod_window()
	draw_texture_rect(GLOW, Rect2(w.x - 380.0, -40.0, 760.0, 90.0), false, Color(pod, 0.22 * glow))
	_draw_hut(sim.shelter, glow)
	for s: ToyStructure in sim.structures:
		if not s.is_shelter and s.is_standing():
			_draw_piece(s, glow)
	if building and plan != null:
		_draw_build_spots()


func _draw_bloom() -> void:
	if sim == null or not look_on:
		return
	var glow: float = pod_glow()
	var pod: Color = palette.pod_light
	var w: Vector2 = pod_window()
	_bloom.draw_texture_rect(GLOW, Rect2(w - Vector2(150.0, 130.0), Vector2(300.0, 260.0)), false, Color(pod, 0.30 * glow))
	_bloom.draw_texture_rect(GLOW, Rect2(w - Vector2(46.0, 40.0), Vector2(92.0, 80.0)), false, Color(pod, 0.5 * glow))


# --- The hut --------------------------------------------------------------

func _draw_hut(s: ToyStructure, glow: float) -> void:
	var l: float = s.left()
	var r: float = s.right()
	var top: float = -s.height()
	var eave: float = top + 50.0
	var plane: Color = look.plane
	var stone: Color = plane.lerp(look.key_rim, 0.09)
	var timber: Color = plane.lerp(look.key_rim, 0.03)
	var pod: Color = palette.pod_light
	if shelter_flash > 0.0:
		plane = plane.lerp(pod, 0.12)
	# Stone plinth.
	draw_rect(Rect2(l - 10.0, -18.0, r - l + 20.0, 18.0), stone)
	var jx: float = l - 4.0
	while jx < r + 6.0:
		draw_line(Vector2(jx, -17.0), Vector2(jx + 2.0, -2.0), plane, 1.5)
		jx += 23.0 + fmod(jx * 7.0, 11.0)
	# Walls: stone courses between timber bands; the beam ends stick out at the corners.
	draw_rect(Rect2(l, eave, r - l, -18.0 - eave), plane)
	var y: float = -18.0
	var course: int = 0
	while y > eave + 4.0:
		var band: float = 7.0 if course % 2 == 0 else 15.0
		var top_y: float = maxf(y - band, eave)
		if course % 2 == 0:
			draw_rect(Rect2(l - 8.0, top_y, r - l + 16.0, y - top_y), timber)
		else:
			var sx: float = l + fmod(course * 13.0, 17.0)
			while sx < r - 4.0:
				var sw: float = 14.0 + fmod(sx * 3.1, 9.0)
				draw_rect(Rect2(sx, top_y + 2.0, minf(sw, r - sx) - 3.0, y - top_y - 3.0), stone)
				sx += sw
		y = top_y
		course += 1
	# Window: a deep timber frame with a lattice, lit by the pod.
	var win: Rect2 = Rect2(s.x - 75.0, -102.0, 46.0, 42.0)
	draw_rect(win.grow(5.0), timber)
	draw_rect(win, Color(pod, clampf(0.3 + 0.7 * glow, 0.0, 1.0)))
	for i: int in 3:
		var fx: float = win.position.x + win.size.x * (i + 1) / 4.0
		draw_line(Vector2(fx, win.position.y), Vector2(fx, win.end.y), plane, 2.5)
	draw_line(Vector2(win.position.x, win.get_center().y), Vector2(win.end.x, win.get_center().y), plane, 2.5)
	# Door, with cold light leaking at its edges.
	var door: Rect2 = Rect2(s.x + 36.0, -96.0, 42.0, 78.0)
	draw_rect(door.grow(4.0), timber)
	draw_rect(door, plane.darkened(0.4))
	draw_line(door.position, Vector2(door.position.x, door.end.y), Color(pod, 0.35 * glow), 1.5)
	draw_line(door.position, Vector2(door.end.x, door.position.y), Color(pod, 0.2 * glow), 1.0)
	# Slate hip roof, wide eaves, a carved fringe under the eave line.
	var roof: PackedVector2Array = [Vector2(l - 36.0, eave + 4.0), Vector2(r + 36.0, eave + 4.0), Vector2(r, top), Vector2(l, top)]
	draw_colored_polygon(roof, plane)
	var rows: int = 5
	for i: int in rows:
		var k: float = float(i + 1) / (rows + 1)
		var ry: float = lerpf(eave + 4.0, top, k)
		var rx0: float = lerpf(l - 36.0, l, k)
		var rx1: float = lerpf(r + 36.0, r, k)
		draw_line(Vector2(rx0, ry), Vector2(rx1, ry), Color(stone, 0.55), 1.0)
	var fx2: float = l - 34.0
	while fx2 < r + 34.0:
		draw_colored_polygon(PackedVector2Array([Vector2(fx2, eave + 4.0), Vector2(fx2 + 7.0, eave + 4.0), Vector2(fx2 + 3.5, eave + 11.0)]), timber)
		fx2 += 9.0
	# Tin stovepipe and a thread of smoke.
	draw_rect(Rect2(r - 58.0, top - 34.0, 9.0, 36.0), timber)
	draw_rect(Rect2(r - 62.0, top - 38.0, 17.0, 4.0), timber)
	for i: int in 6:
		var t: float = fmod(_time * 0.12 + i / 6.0, 1.0)
		var sp: Vector2 = Vector2(r - 54.0 + sin(t * 5.0 + i) * 8.0 + t * 40.0, top - 40.0 - t * 160.0)
		draw_circle(sp, 6.0 + t * 22.0, Color(look.fog, 0.10 * (1.0 - t)))
	# The ridge you stand on carries the key light.
	draw_line(Vector2(l, top), Vector2(r, top), look.key_rim, 2.0)
	draw_line(Vector2(l - 36.0, eave + 4.0), Vector2(l, top), Color(look.key_rim, 0.35), 1.0)
	draw_line(Vector2(r + 36.0, eave + 4.0), Vector2(r, top), Color(look.key_rim, 0.35), 1.0)
	_draw_cracks(s, Rect2(l, eave, r - l, -18.0 - eave))
	if s.has_ladder:
		_pole_ladder(l - ToyPlayer.HALF_WIDTH, s.height(), timber)
		_pole_ladder(r + ToyPlayer.HALF_WIDTH, s.height(), timber)


# --- Built pieces ----------------------------------------------------------

func _draw_piece(s: ToyStructure, glow: float) -> void:
	var plane: Color = look.plane
	if flash.has(s):
		plane = plane.lerp(look.key_rim, 0.35)
	var stone: Color = plane.lerp(look.key_rim, 0.09)
	var timber: Color = plane.lerp(look.key_rim, 0.04)
	var l: float = s.left()
	var r: float = s.right()
	var h: float = s.height()
	match s.definition.id:
		&"fence":
			# Two leaning deodar poles with lashed slats.
			for px: float in [l + 5.0, r - 5.0]:
				draw_colored_polygon(PackedVector2Array([Vector2(px - 3.5, 0.0), Vector2(px + 3.5, 0.0), Vector2(px + 4.0, -h - 4.0), Vector2(px - 2.0, -h - 2.0)]), timber)
			for k: int in 3:
				var fy: float = -14.0 - k * 17.0
				draw_line(Vector2(l - 8.0, fy + 7.0), Vector2(r + 8.0, fy - 5.0), timber, 6.0)
		&"wall":
			# Dry-stone wall under a timber cap.
			draw_rect(Rect2(l, -h + 8.0, r - l, h - 8.0), plane)
			var row: int = 0
			var y: float = 0.0
			while y > -h + 10.0:
				var sx: float = l + (6.0 if row % 2 == 1 else 0.0)
				while sx < r - 2.0:
					var sw: float = minf(13.0 + fmod((sx + y) * 2.3, 6.0), r - sx)
					draw_rect(Rect2(sx + 1.0, y - 13.0, sw - 2.0, 11.0), stone)
					sx += sw
				y -= 13.0
				row += 1
			draw_rect(Rect2(l - 5.0, -h, r - l + 10.0, 8.0), timber)
		_:
			# High wall: a stone footing and a sharpened log palisade.
			draw_rect(Rect2(l - 3.0, -30.0, r - l + 6.0, 30.0), stone)
			var logs: int = 4
			var lw: float = (r - l) / logs
			for k: int in logs:
				var lx: float = l + k * lw
				draw_colored_polygon(PackedVector2Array([Vector2(lx + 0.5, -30.0), Vector2(lx + lw - 0.5, -30.0), Vector2(lx + lw - 0.5, -h), Vector2(lx + lw * 0.5, -h - 12.0), Vector2(lx + 0.5, -h)]), timber if k % 2 == 0 else plane)
			for by: float in [-70.0, -h + 30.0]:
				draw_line(Vector2(l - 4.0, by), Vector2(r + 4.0, by), timber.lightened(0.04), 5.0)
	# Key light on the top you stand on; the pod's light on the cabin-facing side.
	draw_line(Vector2(l, -h), Vector2(r, -h), Color(look.key_rim, 0.8), 1.5)
	var side: float = signf(sim.shelter.x - s.x)
	var near: float = clampf(1.0 - absf(sim.shelter.x - s.x) / POD_REACH, 0.0, 1.0)
	if near > 0.0:
		var fx: float = r if side > 0.0 else l
		draw_line(Vector2(fx, 0.0), Vector2(fx, -h), Color(palette.pod_light, 0.55 * near * glow), 2.0)
	_draw_cracks(s, Rect2(l, -h, r - l, h))
	if s.has_ladder:
		_pole_ladder(l - ToyPlayer.HALF_WIDTH, h, timber)
		_pole_ladder(r + ToyPlayer.HALF_WIDTH, h, timber)


func _pole_ladder(x: float, h: float, c: Color) -> void:
	var rim: Color = Color(look.key_rim, 0.5)
	draw_line(Vector2(x - 8.0, 0.0), Vector2(x - 6.0, -h - 10.0), c, 3.0)
	draw_line(Vector2(x + 8.0, 0.0), Vector2(x + 7.0, -h - 8.0), c, 3.0)
	var y: float = -12.0
	while y > -h:
		draw_line(Vector2(x - 8.0, y + 1.0), Vector2(x + 8.0, y - 1.0), c, 2.5)
		draw_line(Vector2(x - 8.0, y), Vector2(x + 8.0, y - 2.0), rim, 1.0)
		y -= 17.0
