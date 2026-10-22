extends Node2D
## EXPERIMENT C3 (Stage C): performance. The C4 horde sim drawn with the C2
## look (rim-lit sprites, 2D lights with shadows on HIGH, two fog layers,
## grain), with a frame-time log.
## Options: --agents=60 --preset=high|low --minutes=20, or --sweep for five
## 60-second runs (60/100 enemies on HIGH and LOW, plus 150 on LOW).
## Pass (Stage B 11): 60 fps on the reference PC at 60 enemies; 30 fps on the
## reference Android phone on LOW; over a 20-minute soak, no one-minute
## average below the target (that would be thermal throttling).

const SWEEP: Array[Dictionary] = [
	{"agents": 60, "preset": "high"},
	{"agents": 100, "preset": "high"},
	{"agents": 60, "preset": "low"},
	{"agents": 100, "preset": "low"},
	{"agents": 150, "preset": "low"},
]
const SWEEP_SECONDS: float = 60.0
const WARMUP_SECONDS: float = 3.0

static var sweep_index: int = -1
static var sweep_results: Array[String] = []

var view: StageCHouseView
var sim: StageCHordeSim
var sprites: Array[Sprite2D] = []
var phases: PackedFloat32Array = PackedFloat32Array()
var player: Sprite2D
var flash: PointLight2D
var hud: Label
var target_fps: float = 60.0
var duration: float = 60.0
var agent_count: int = 60
var preset_name: String = "high"
var _elapsed: float = 0.0
var _frame_ms: PackedFloat32Array = PackedFloat32Array()
var _sim_ms_total: float = 0.0
var _second_frames: int = 0
var _second_time: float = 0.0
var _per_second_fps: PackedFloat32Array = PackedFloat32Array()
var _csv: FileAccess
var _done: bool = false
var _last_source_count: int = 0
var _shot_taken: bool = false


func _ready() -> void:
	target_fps = 30.0 if OS.has_feature("mobile") else 60.0
	if StageCLaunch.get_str("sweep", "0") == "1" and sweep_index < 0:
		sweep_index = 0
		sweep_results.clear()
	if sweep_index >= 0:
		var cfg: Dictionary = SWEEP[sweep_index]
		agent_count = cfg["agents"]
		preset_name = cfg["preset"]
		duration = SWEEP_SECONDS
	else:
		agent_count = StageCLaunch.get_int("agents", 60)
		preset_name = StageCLaunch.get_str("preset", "high")
		duration = StageCLaunch.get_float("minutes", 1.0) * 60.0

	view = StageCHouseView.new()
	add_child(view)
	view.apply_preset(StageCHouseView.Preset.LOW if preset_name == "low" else StageCHouseView.Preset.HIGH)
	sim = StageCHordeSim.new(agent_count, 1)
	sim.validate_geometry = false
	for a: StageCHordeSim.Agent in sim.agents:
		var tex: Texture2D = StageCHouseView.RUNNER_TEX if a.kind == StageCHordeSim.AgentKind.RUNNER else StageCHouseView.SHAMBLER_TEX
		sprites.append(view.make_actor(tex))
		phases.append(randf() * TAU)
	player = view.make_actor(StageCHouseView.PROTAGONIST_TEX)
	flash = PointLight2D.new()
	flash.texture = view.lights[0].texture
	flash.color = Color(0.95, 0.9, 0.8)
	flash.texture_scale = 1.5
	flash.energy = 0.0
	flash.shadow_enabled = preset_name != "low"
	view.add_child(flash)

	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(24, 16)
	hud.add_theme_font_size_override("font_size", 24)
	hud.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	hud.add_theme_color_override("font_outline_color", Color.BLACK)
	hud.add_theme_constant_override("outline_size", 6)
	layer.add_child(hud)
	var stop: Button = StageCLaunch.button("Stop", _finish)
	stop.position = Vector2(1720, 16)
	stop.custom_minimum_size = Vector2(170, 72)
	layer.add_child(stop)

	var stamp: String = Time.get_datetime_string_from_system().replace(":", "-")
	var path: String = "user://c3_%s_%d_%s.csv" % [preset_name, agent_count, stamp]
	_csv = FileAccess.open(path, FileAccess.WRITE)
	if _csv != null:
		_csv.store_line("second,fps,worst_frame_ms,draw_calls,canvas_items,sim_ms_avg")
	print("C3 logging to ", ProjectSettings.globalize_path(path))


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	var t0: int = Time.get_ticks_usec()
	sim.step(minf(delta, 0.05))
	var sim_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	_update_sprites()
	var shot: String = StageCLaunch.get_str("shot", "")
	if shot != "" and _elapsed > 12.0 and not _shot_taken:
		_shot_taken = true
		get_viewport().get_texture().get_image().save_png(shot)

	if _elapsed < WARMUP_SECONDS:
		hud.text = "C3 warming up..."
		return
	_frame_ms.append(delta * 1000.0)
	_sim_ms_total += sim_ms
	_second_frames += 1
	_second_time += delta
	if _second_time >= 1.0:
		var fps: float = _second_frames / _second_time
		_per_second_fps.append(fps)
		var worst: float = 0.0
		for i: int in range(maxi(0, _frame_ms.size() - _second_frames), _frame_ms.size()):
			worst = maxf(worst, _frame_ms[i])
		var draws: float = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		var items: float = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
		if _csv != null:
			_csv.store_line("%d,%.1f,%.2f,%d,%d,%.3f" % [_per_second_fps.size(), fps, worst, draws, items, sim_ms])
		hud.text = "C3  %s  %d enemies (%d on screen)  preset %s  %s\nfps %.0f (target %.0f)   worst frame %.1f ms   draw calls %d   %d / %d s" % [
			"sweep %d/%d" % [sweep_index + 1, SWEEP.size()] if sweep_index >= 0 else "run",
			agent_count, sim.alive_count(), preset_name.to_upper(), RenderingServer.get_current_rendering_method(),
			fps, target_fps, worst, draws, int(_elapsed - WARMUP_SECONDS), int(duration)]
		_second_frames = 0
		_second_time = 0.0
	if _elapsed - WARMUP_SECONDS >= duration:
		_finish()


func _update_sprites() -> void:
	var now: float = _elapsed
	for i: int in sprites.size():
		var a: StageCHordeSim.Agent = sim.agents[i]
		var s: Sprite2D = sprites[i]
		s.visible = a.state != StageCHordeSim.State.DEAD
		if not s.visible:
			continue
		s.position = a.position + Vector2(a.spread, 0.0)
		if a.path_index < a.path.size():
			s.flip_h = a.path[a.path_index].x < a.position.x
		var rate: float = 7.0 if a.kind == StageCHordeSim.AgentKind.RUNNER else 2.6
		s.rotation = 0.05 * sin(now * rate + phases[i])
	player.position = sim.building.floor_point(sim.player_level, sim.player_x)
	# Muzzle flash when a shot source appears.
	var n: int = sim.sources.size()
	if n > _last_source_count and sim.sources[n - 1].kind == StageCNoise.Kind.SHOT:
		flash.position = player.position + Vector2(40, -60)
		flash.energy = 1.4
	_last_source_count = n
	flash.energy = maxf(0.0, flash.energy - 0.25)
	flash.visible = flash.energy > 0.0


func _finish() -> void:
	if _done:
		return
	_done = true
	var summary: String = _summary()
	print(summary)
	if _csv != null:
		_csv.close()
	if sweep_index >= 0:
		sweep_results.append(summary)
		sweep_index += 1
		if sweep_index < SWEEP.size():
			get_tree().reload_current_scene.call_deferred()
			return
		summary = "C3 sweep results (%s, target %.0f fps)\n\n%s" % [RenderingServer.get_current_rendering_method(), target_fps, "\n".join(sweep_results)]
		sweep_index = -1
	if StageCLaunch.get_str("quit", "0") == "1":
		get_tree().quit()
		return
	_show_results(summary)


func _summary() -> String:
	if _frame_ms.is_empty():
		return "no frames recorded"
	var sorted: PackedFloat32Array = _frame_ms.duplicate()
	sorted.sort()
	var total: float = 0.0
	for f: float in _frame_ms:
		total += f
	var mean_fps: float = 1000.0 * _frame_ms.size() / total
	var p99_ms: float = sorted[int(sorted.size() * 0.99)]
	var worst_minute: float = INF
	var m: int = 0
	while m + 60 <= _per_second_fps.size():
		var sum: float = 0.0
		for i: int in range(m, m + 60):
			sum += _per_second_fps[i]
		worst_minute = minf(worst_minute, sum / 60.0)
		m += 60
	var ok: bool = mean_fps >= target_fps * 0.98 and 1000.0 / p99_ms >= target_fps * 0.75
	if worst_minute != INF:
		ok = ok and worst_minute >= target_fps * 0.95
	return "%3d enemies %-4s  mean %5.1f fps  1%%-low %5.1f fps  worst 1-min avg %s  sim %.2f ms  -> %s" % [
		agent_count, preset_name.to_upper(), mean_fps, 1000.0 / p99_ms,
		"n/a" if worst_minute == INF else "%.1f" % worst_minute,
		_sim_ms_total / _frame_ms.size(), "PASS" if ok else "FAIL"]


func _show_results(text: String) -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 70
	add_child(layer)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	var label: Label = Label.new()
	label.position = Vector2(80, 80)
	label.add_theme_font_size_override("font_size", 26)
	label.text = text + "\n\nDevice: %s, %s\nCPU: %s\nGPU: %s\nTake a photo of this screen for the Stage C report." % [
		OS.get_name(), OS.get_model_name(), OS.get_processor_name(), RenderingServer.get_video_adapter_name()]
	layer.add_child(label)
	var back: Button = StageCLaunch.button("Back to menu", StageCLaunch.back_to_menu.bind(get_tree()))
	back.position = Vector2(80, 900)
	back.custom_minimum_size = Vector2(320, 80)
	layer.add_child(back)
