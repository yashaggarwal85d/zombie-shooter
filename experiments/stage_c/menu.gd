extends Control
## EXPERIMENT (Stage C). Entry menu for the experiments. `--scene=c2` (etc.)
## on the command line skips straight to an experiment.

const SCENES: Dictionary = {
	"c1": "res://c1_input/input_test.tscn",
	"c2": "res://c2_look/look_test.tscn",
	"c3": "res://c3_perf/perf_test.tscn",
	"c4": "res://c4_pathing/pathing_view.tscn",
	"c5": "res://c5_steam/steam_test.tscn",
}


func _ready() -> void:
	var direct: String = StageCLaunch.get_str("scene", "")
	if SCENES.has(direct):
		get_tree().change_scene_to_file.call_deferred(SCENES[direct])
		return
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.055, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 160
	scroll.offset_right = -160
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	add_child(scroll)
	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 14)
	scroll.add_child(box)
	var title: Label = Label.new()
	title.text = "Stage C experiments (throwaway, not the game)  ·  %s  ·  %s" % [Engine.get_version_info()["string"], RenderingServer.get_current_rendering_method()]
	title.add_theme_font_size_override("font_size", 26)
	box.add_child(title)
	box.add_child(StageCLaunch.button("C1  Input check (keyboard, mouse, gamepad, touch)", _go.bind("c1", {})))
	box.add_child(StageCLaunch.button("C2  Look test", _go.bind("c2", {})))
	box.add_child(StageCLaunch.button("C3  Performance sweep (5 runs x 60 s)", _go.bind("c3", {"sweep": "1"})))
	box.add_child(StageCLaunch.button("C3  20-minute soak, 60 enemies, HIGH", _go.bind("c3", {"agents": "60", "preset": "high", "minutes": "20"})))
	box.add_child(StageCLaunch.button("C3  20-minute soak, 60 enemies, LOW (phone test)", _go.bind("c3", {"agents": "60", "preset": "low", "minutes": "20"})))
	box.add_child(StageCLaunch.button("C4  Pathing and noise debug view", _go.bind("c4", {})))
	box.add_child(StageCLaunch.button("C5  Steam achievement and cloud save", _go.bind("c5", {})))
	box.add_child(StageCLaunch.button("Quit", get_tree().quit))


func _go(key: String, opts: Dictionary) -> void:
	StageCLaunch.go(get_tree(), SCENES[key], opts)
