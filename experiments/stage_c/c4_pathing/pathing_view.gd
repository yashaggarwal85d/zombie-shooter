extends Node2D
## EXPERIMENT C4 (Stage C): debug view of the pathing and the noise rule.
## Left click on a floor: loud shot there. Right click: lure. Q: quiet shot.
## S toggles the scripted player. Esc: menu. Shamblers are grey, runners red;
## each agent draws a line to the sound it is following.

var sim: StageCHordeSim
var hud: Label
var _last_click_level: int = 1
var _last_click_x: float = 960.0


func _ready() -> void:
	var count: int = StageCLaunch.get_int("agents", 60)
	sim = StageCHordeSim.new(count, 2)
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(24, 12)
	hud.add_theme_font_size_override("font_size", 22)
	layer.add_child(hud)
	var back: Button = StageCLaunch.button("Menu", StageCLaunch.back_to_menu.bind(get_tree()))
	back.position = Vector2(1720, 12)
	back.custom_minimum_size = Vector2(170, 64)
	layer.add_child(back)


func _process(delta: float) -> void:
	var t0: int = Time.get_ticks_usec()
	sim.step(minf(delta, 0.05))
	var ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	hud.text = "C4  %d agents  logic %.2f ms  chamber hits %d  stuck %d  path failures %d  reversals %d   scripted player %s\nLeft click: shot   Right click: lure   Q: quiet shot at last click   S: toggle scripted player" % [
		sim.agents.size(), ms, sim.chamber_hits, sim.stuck_events, sim.path_failures, sim.reversals, "on" if sim.scripted_noise else "off"]
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb != null and mb.pressed:
		var lvl: int = _nearest_level(mb.position.y)
		_last_click_level = lvl
		_last_click_x = mb.position.x
		if mb.button_index == MOUSE_BUTTON_LEFT:
			sim.add_source(StageCNoise.Kind.SHOT, lvl, mb.position.x, 1.6, 900.0, 0.4)
		elif mb.button_index == MOUSE_BUTTON_RIGHT:
			sim.add_source(StageCNoise.Kind.LURE, lvl, mb.position.x, 2.5, 1400.0, 6.0)
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo:
		match key.keycode:
			KEY_Q:
				sim.add_source(StageCNoise.Kind.QUIET_SHOT, _last_click_level, _last_click_x, 0.6, 300.0, 0.3)
			KEY_S:
				sim.scripted_noise = not sim.scripted_noise
			KEY_ESCAPE:
				StageCLaunch.back_to_menu(get_tree())


func _nearest_level(y: float) -> int:
	var best: int = 0
	for lvl: int in StageCBuilding.LEVEL_COUNT:
		if absf(StageCBuilding.LEVEL_Y[lvl] - y) < absf(StageCBuilding.LEVEL_Y[best] - y):
			best = lvl
	return best


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color(0.06, 0.06, 0.08))
	var b: StageCBuilding = sim.building
	for lvl: int in StageCBuilding.LEVEL_COUNT:
		var y: float = StageCBuilding.LEVEL_Y[lvl]
		draw_line(Vector2(b.level_left(lvl), y), Vector2(b.level_right(lvl), y), Color(0.4, 0.4, 0.45), 3.0)
	for e: Vector2i in b.stair_edges:
		draw_line(b.astar.get_point_position(e.x), b.astar.get_point_position(e.y), Color(0.4, 0.4, 0.45), 3.0)
	for id: int in b.node_count():
		draw_circle(b.astar.get_point_position(id), 5.0, Color(0.55, 0.55, 0.6))
	for e: Dictionary in sim.open_entries:
		var lvl: int = e["level"]
		draw_rect(Rect2(b.floor_point(lvl, e["x"] as float) + Vector2(-8, -40), Vector2(16, 40)), Color(0.3, 0.6, 0.3), false, 2.0)
	draw_rect(Rect2(b.chamber_position() + Vector2(-30, -120), Vector2(60, 120)), Color(0.75, 0.88, 1.0))
	for s: StageCNoise.Source in sim.sources:
		var c: Color = Color(0.9, 0.4, 0.2) if s.kind == StageCNoise.Kind.SHOT else (Color(0.9, 0.8, 0.2) if s.kind == StageCNoise.Kind.LURE else Color(0.5, 0.7, 1.0))
		draw_arc(s.position, minf(s.radius, 120.0) * minf(1.0, s.loudness), 0.0, TAU, 32, c, 2.0)
	for a: StageCHordeSim.Agent in sim.agents:
		if a.state == StageCHordeSim.State.DEAD:
			continue
		var col: Color = Color(0.9, 0.3, 0.3) if a.kind == StageCHordeSim.AgentKind.RUNNER else Color(0.75, 0.75, 0.75)
		var p: Vector2 = a.position + Vector2(a.spread, -10.0)
		if a.target != null:
			draw_line(p, a.target.position, Color(col, 0.12), 1.0)
		draw_circle(p, 7.0, col)
	draw_circle(b.floor_point(sim.player_level, sim.player_x) + Vector2(0, -20), 10.0, Color(0.3, 0.9, 0.5))
