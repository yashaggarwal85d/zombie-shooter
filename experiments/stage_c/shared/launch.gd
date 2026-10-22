class_name StageCLaunch
extends RefCounted
## EXPERIMENT (Stage C). Hands options between scenes, and reads the same
## options from the command line (after `--`), e.g. `-- --scene=c3 --agents=100`.

const MENU: String = "res://menu.tscn"

static var options: Dictionary = {}
static var _cli_read: bool = false


static func cli() -> Dictionary:
	var out: Dictionary = {}
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--") and a.contains("="):
			var kv: PackedStringArray = a.substr(2).split("=", true, 1)
			out[kv[0]] = kv[1]
		elif a.begins_with("--"):
			out[a.substr(2)] = "1"
	return out


## Command-line options, merged under any set by the menu. The command line
## applies once, to the first scene that reads it.
static func get_options() -> Dictionary:
	if not _cli_read:
		_cli_read = true
		var merged: Dictionary = cli()
		merged.merge(options, true)
		options = merged
	return options


static func get_str(key: String, default: String) -> String:
	return str(get_options().get(key, default))


static func get_int(key: String, default: int) -> int:
	return int(get_options().get(key, str(default)))


static func get_float(key: String, default: float) -> float:
	return float(get_options().get(key, str(default)))


static func go(tree: SceneTree, scene: String, opts: Dictionary = {}) -> void:
	options = opts
	_cli_read = true
	tree.change_scene_to_file(scene)


static func back_to_menu(tree: SceneTree) -> void:
	go(tree, MENU)


## A big, touch-friendly button.
static func button(text: String, callback: Callable) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 72)
	b.add_theme_font_size_override("font_size", 30)
	b.pressed.connect(callback)
	return b
