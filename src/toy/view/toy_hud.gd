class_name ToyHud
extends Control
## The toy's HUD, drawn inside the screen's safe area (TECHNICAL_ARCHITECTURE
## 3): dawn bar, health, shelter integrity, barrel and ammo, edge markers for
## incoming groups, the build-step panel, the end card and pause.

enum Mode { BUILD, NIGHT, END, PAUSED }

const MARGIN: float = 32.0

var sim: FieldSim
var plan: BuildPlan
var mode: Mode = Mode.BUILD
var end_title: String = ""
var debug: bool = false
var sim_ms: float = 0.0
var prompt: String = ""
var attempts: int = 0


func _process(_delta: float) -> void:
	queue_redraw()


func _safe_rect() -> Rect2:
	var size: Vector2 = get_viewport_rect().size
	var rect: Rect2 = Rect2(Vector2(MARGIN, MARGIN), size - Vector2(MARGIN, MARGIN) * 2.0)
	var window: Vector2 = Vector2(DisplayServer.window_get_size())
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	if window.x > 0.0 and safe.size.x > 0 and OS.has_feature("mobile"):
		var k: Vector2 = size / window
		var inset_l: float = safe.position.x * k.x
		var inset_r: float = (window.x - safe.end.x) * k.x
		rect.position.x = maxf(rect.position.x, inset_l + 8.0)
		rect.end.x = minf(rect.end.x, size.x - inset_r - 8.0)
	return rect


func _draw() -> void:
	if sim == null:
		return
	var font: Font = ThemeDB.fallback_font
	var r: Rect2 = _safe_rect()
	var white: Color = Color(0.9, 0.93, 0.96)
	var dim: Color = Color(0.9, 0.93, 0.96, 0.6)

	if mode == Mode.BUILD:
		_panel(Rect2(r.get_center().x - 360.0, r.position.y, 720.0, 120.0))
		draw_string(font, Vector2(r.get_center().x - 340.0, r.position.y + 36.0), "DAY · BUILD BEFORE NIGHTFALL", HORIZONTAL_ALIGNMENT_CENTER, 680.0, 26, white)
		draw_string(font, Vector2(r.get_center().x - 340.0, r.position.y + 70.0), "Scrap: %d of %d" % [plan.remaining(), plan.budget], HORIZONTAL_ALIGNMENT_CENTER, 680.0, 22, Color(1.0, 0.9, 0.6))
		draw_string(font, Vector2(r.get_center().x - 340.0, r.position.y + 102.0), prompt, HORIZONTAL_ALIGNMENT_CENTER, 680.0, 18, dim)
		_controls_help(font, r, dim)
		return

	# Dawn bar.
	var bar: Rect2 = Rect2(r.get_center().x - 300.0, r.position.y, 600.0, 14.0)
	draw_rect(bar, Color(0.1, 0.12, 0.16, 0.8))
	var k: float = clampf(sim.elapsed / sim.night.duration, 0.0, 1.0)
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * k, bar.size.y)), Color(0.85, 0.7, 0.45))
	draw_string(font, Vector2(bar.position.x, bar.end.y + 22.0), "Dawn in %d s" % int(ceilf(sim.time_left())), HORIZONTAL_ALIGNMENT_CENTER, bar.size.x, 18, dim)

	# Health and shelter integrity.
	_meter(font, Vector2(r.position.x, r.position.y), "You", sim.player.health / ToyPlayer.MAX_HEALTH, Color(0.85, 0.35, 0.3))
	_meter(font, Vector2(r.position.x, r.position.y + 44.0), "Her (cabin)", sim.shelter.health_fraction(), Color(0.65, 0.88, 1.0))

	# Barrel and ammo.
	var w: ToyWeapon = sim.weapon
	var loud: bool = w.is_loud()
	var barrel: String = ("LOUD · " if loud else "QUIET · ") + w.current().display_name
	var bcol: Color = Color(1.0, 0.8, 0.5) if loud else Color(0.6, 0.85, 1.0)
	var bottom: float = r.end.y
	draw_string(font, Vector2(r.position.x, bottom - 40.0), barrel, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 24, bcol)
	var ammo_text: String = "%d / %d" % [w.ammo, w.current().magazine]
	if w.is_swapping():
		ammo_text = "swapping barrel…"
	elif w.is_reloading():
		ammo_text = "reloading…"
	draw_string(font, Vector2(r.position.x, bottom - 8.0), ammo_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, white)

	_edge_markers(font, r)

	if debug:
		draw_string(font, Vector2(r.end.x - 360.0, bottom - 8.0), "fps %d · sim %.2f ms · enemies %d" % [Engine.get_frames_per_second(), sim_ms, sim.alive_enemies()], HORIZONTAL_ALIGNMENT_RIGHT, 360.0, 16, dim)

	if mode == Mode.END:
		_card(font, r, end_title, "Fire or Enter to try again (attempt %d)" % (attempts + 1))
	elif mode == Mode.PAUSED:
		_card(font, r, "Paused", "Esc to resume")


func _meter(font: Font, at: Vector2, label: String, frac: float, color: Color) -> void:
	draw_string(font, at + Vector2(0.0, 16.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 16, Color(0.9, 0.93, 0.96, 0.7))
	var bar: Rect2 = Rect2(at + Vector2(110.0, 4.0), Vector2(240.0, 14.0))
	draw_rect(bar, Color(0.1, 0.12, 0.16, 0.8))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * clampf(frac, 0.0, 1.0), bar.size.y)), color)


func _edge_markers(font: Font, r: Rect2) -> void:
	var xf: Transform2D = get_viewport().get_canvas_transform()
	for side: int in [-1, 1]:
		var offscreen: int = 0
		for e: ToyEnemy in sim.enemies:
			if not e.is_alive():
				continue
			var sx: float = (xf * Vector2(e.x, 0.0)).x
			if (side < 0 and sx < 0.0) or (side > 0 and sx > get_viewport_rect().size.x):
				offscreen += 1
		var coming: int = sim.upcoming(side, 2.0) + offscreen
		if coming <= 0:
			continue
		var ground_y: float = (xf * Vector2(0.0, 0.0)).y
		var x: float = r.position.x + 10.0 if side < 0 else r.end.x - 10.0
		var tip: Vector2 = Vector2(x, ground_y - 60.0)
		var c: Color = Color(1.0, 0.45, 0.35, 0.6 + 0.4 * absf(sin(Time.get_ticks_msec() / 160.0)))
		var pts: PackedVector2Array = [tip, tip + Vector2(-side * 26.0, -16.0), tip + Vector2(-side * 26.0, 16.0)]
		draw_colored_polygon(pts, c)
		draw_string(font, tip + Vector2(-side * 40.0 - (40.0 if side > 0 else 0.0), 6.0), str(coming), HORIZONTAL_ALIGNMENT_CENTER, 40.0, 20, c)


func _panel(rect: Rect2) -> void:
	draw_rect(rect, Color(0.02, 0.03, 0.05, 0.55))


func _card(font: Font, r: Rect2, title: String, sub: String) -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0.0, 0.0, 0.0, 0.55))
	draw_string(font, Vector2(r.position.x, r.get_center().y - 10.0), title, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 56, Color(0.92, 0.94, 0.97))
	draw_string(font, Vector2(r.position.x, r.get_center().y + 40.0), sub, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 22, Color(0.92, 0.94, 0.97, 0.7))


func _controls_help(font: Font, r: Rect2, c: Color) -> void:
	var lines: PackedStringArray = [
		"A/D move · Space jump (hold for higher) · W/S ladders (S drops off a top) · mouse aim · click fire",
		"F hatchet (hold W: up, S in the air: down) · R reload · E swap barrel (1.5 s) · F3 debug · Esc pause",
		"Build: stand at a marker and press E to cycle it · Enter to start the night",
	]
	for i: int in lines.size():
		draw_string(font, Vector2(r.position.x, r.position.y + 160.0 + i * 26.0), lines[i], HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 18, c)
