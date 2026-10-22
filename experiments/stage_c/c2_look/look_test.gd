extends Node2D
## EXPERIMENT C2 (Stage C): the look test. One screen with the chamber, one
## silhouette enemy, the protagonist, fog and light, on HIGH and LOW presets.
## Keys: P preset, G greyscale check, C close/full framing, E extra enemies,
## H hide help, F12 screenshot, Esc menu. The buttons do the same on touch.
## `-- --scene=c2 --capture=<dir>` saves the comparison shots and quits.

const FULL_CENTER: Vector2 = Vector2(960, 540)
const CLOSE_CENTER: Vector2 = Vector2(930, 560)
const CLOSE_ZOOM: float = 1.75

var view: StageCHouseView
var camera: Camera2D
var shambler: Sprite2D
var protagonist: Sprite2D
var extras: Array[Sprite2D] = []
var help: Label
var _close: bool = true
var _t: float = 0.0


func _ready() -> void:
	view = StageCHouseView.new()
	add_child(view)
	camera = Camera2D.new()
	add_child(camera)
	camera.make_current()
	var floor_y: float = StageCBuilding.LEVEL_Y[StageCBuilding.CHAMBER_LEVEL]
	protagonist = view.make_actor(StageCHouseView.PROTAGONIST_TEX)
	protagonist.position = Vector2(820, floor_y)
	protagonist.flip_h = true # facing the shambler on the left
	shambler = view.make_actor(StageCHouseView.SHAMBLER_TEX)
	shambler.position = Vector2(600, floor_y)
	var spots: Array[Vector2] = [
		Vector2(1300, StageCBuilding.LEVEL_Y[2]), Vector2(1340, StageCBuilding.LEVEL_Y[2]),
		Vector2(1560, StageCBuilding.LEVEL_Y[0]), Vector2(380, StageCBuilding.LEVEL_Y[0]),
	]
	for i: int in spots.size():
		var e: Sprite2D = view.make_actor(StageCHouseView.RUNNER_TEX if i == 0 else StageCHouseView.SHAMBLER_TEX)
		e.position = spots[i]
		e.flip_h = spots[i].x > StageCBuilding.CHAMBER_X
		e.visible = false
		extras.append(e)
	_build_ui()
	_apply_framing()
	var capture_dir: String = StageCLaunch.get_str("capture", "")
	if capture_dir != "":
		_capture_all.call_deferred(capture_dir)


func _process(delta: float) -> void:
	_t += delta
	# A slow shuffle: sway and bob rather than real animation (rigging comes later).
	shambler.position.x = 600.0 + fmod(_t * 14.0, 120.0)
	shambler.rotation = 0.05 * sin(_t * 2.6)
	shambler.offset.y = -StageCHouseView.SHAMBLER_TEX.get_height() * 0.5 + 4.0 * absf(sin(_t * 2.6))
	protagonist.rotation = 0.01 * sin(_t * 1.3)
	for i: int in extras.size():
		extras[i].rotation = 0.05 * sin(_t * 2.2 + i)


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.keycode:
		KEY_P:
			_toggle_preset()
		KEY_G:
			_toggle_grey()
		KEY_C:
			_toggle_framing()
		KEY_E:
			_toggle_extras()
		KEY_H:
			help.visible = not help.visible
		KEY_F12:
			_save_shot("user://look_%d.png" % Time.get_unix_time_from_system())
		KEY_ESCAPE:
			StageCLaunch.back_to_menu(get_tree())


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	help = Label.new()
	help.position = Vector2(24, 16)
	help.add_theme_font_size_override("font_size", 22)
	help.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	layer.add_child(help)
	var bar: HBoxContainer = HBoxContainer.new()
	bar.position = Vector2(24, 980)
	bar.add_theme_constant_override("separation", 12)
	layer.add_child(bar)
	for pair: Array in [["Preset", _toggle_preset], ["Greyscale", _toggle_grey], ["Framing", _toggle_framing], ["Crowd", _toggle_extras], ["Menu", StageCLaunch.back_to_menu.bind(get_tree())]]:
		var b: Button = StageCLaunch.button(pair[0] as String, pair[1] as Callable)
		b.custom_minimum_size = Vector2(170, 72)
		bar.add_child(b)
	_update_help()


func _update_help() -> void:
	help.text = "C2 look test  ·  preset %s  ·  greyscale %s  ·  %s  ·  %s\nP preset   G greyscale   C framing   E crowd   H hide   F12 screenshot   Esc menu" % [
		StageCHouseView.Preset.keys()[view.preset], "on" if view.is_greyscale() else "off",
		"close" if _close else "full house", RenderingServer.get_current_rendering_method()]


func _toggle_preset() -> void:
	view.apply_preset(StageCHouseView.Preset.LOW if view.preset == StageCHouseView.Preset.HIGH else StageCHouseView.Preset.HIGH)
	_update_help()


func _toggle_grey() -> void:
	view.set_greyscale(not view.is_greyscale())
	_update_help()


func _toggle_framing() -> void:
	_close = not _close
	_apply_framing()
	_update_help()


func _toggle_extras() -> void:
	for e: Sprite2D in extras:
		e.visible = not e.visible


func _apply_framing() -> void:
	camera.position = CLOSE_CENTER if _close else FULL_CENTER
	camera.zoom = Vector2.ONE * (CLOSE_ZOOM if _close else 1.0)


func _save_shot(path: String) -> void:
	var img: Image = get_viewport().get_texture().get_image()
	img.save_png(path)
	print("saved ", ProjectSettings.globalize_path(path))


func _capture_all(dir: String) -> void:
	help.get_parent().visible = false
	for e: Sprite2D in extras:
		e.visible = true
	for framing: bool in [true, false]:
		_close = framing
		_apply_framing()
		for p: StageCHouseView.Preset in [StageCHouseView.Preset.HIGH, StageCHouseView.Preset.LOW]:
			view.apply_preset(p)
			for grey: bool in [false, true]:
				view.set_greyscale(grey)
				for i: int in 12:
					await get_tree().process_frame
				var name: String = "%s_%s%s.png" % ["close" if framing else "full", StageCHouseView.Preset.keys()[p].to_lower(), "_grey" if grey else ""]
				_save_shot(dir.path_join(name))
	get_tree().quit()
