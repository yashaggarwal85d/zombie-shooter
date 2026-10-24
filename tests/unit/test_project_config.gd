extends GutTest
## Guards project settings that the architecture depends on, so an editor
## click can't silently undo them. See TECHNICAL_ARCHITECTURE.md.

const PINNED_ENGINE := "4.7.2"
const INPUT_ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"jump", &"climb_up", &"climb_down", &"aim", &"fire",
	&"melee", &"reload", &"interact", &"pause", &"start_night", &"debug_overlay",
]
const WARNING_LEVEL_ERROR := 2


func test_running_on_pinned_engine() -> void:
	var info: Dictionary = Engine.get_version_info()
	var running := "%d.%d.%d" % [info.major, info.minor, info.patch]
	assert_eq(running, PINNED_ENGINE, "Update TECHNICAL_ARCHITECTURE.md and CI before changing engine version")


func test_untyped_code_is_an_error() -> void:
	var level: int = ProjectSettings.get_setting("debug/gdscript/warnings/untyped_declaration")
	assert_eq(level, WARNING_LEVEL_ERROR)


func test_input_actions_exist() -> void:
	for action: StringName in INPUT_ACTIONS:
		assert_true(InputMap.has_action(action), "Missing input action: %s" % action)


func test_every_action_has_a_binding() -> void:
	for action: StringName in INPUT_ACTIONS:
		if InputMap.has_action(action):
			assert_gt(InputMap.action_get_events(action).size(), 0, "No binding for %s" % action)


func test_display_scales_for_phones_and_monitors() -> void:
	var mode: String = ProjectSettings.get_setting("display/window/stretch/mode")
	var aspect: String = ProjectSettings.get_setting("display/window/stretch/aspect")
	assert_eq(mode, "canvas_items")
	assert_eq(aspect, "expand")


func test_main_scene_instantiates() -> void:
	var path: String = ProjectSettings.get_setting("application/run/main_scene")
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	var main: Node = packed.instantiate()
	add_child_autofree(main)
	assert_not_null(main.get_node_or_null("%BuildLabel"))
	assert_not_null(main.get_node_or_null("Toy"), "the entry scene runs the combat toy")
