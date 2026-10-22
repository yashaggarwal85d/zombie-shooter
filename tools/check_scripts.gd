extends SceneTree
## Loads every project script outside addons/ and fails if any won't compile.
## Catches typing errors (warnings set to error) in files no test touches yet.
## Usage: godot --headless --path . --script res://tools/check_scripts.gd
## Skips addons/, this script itself, and nested projects (folders with their
## own project.godot or a .gdignore), which the editor also skips.

const SKIP_DIRS: Array[String] = ["res://addons", "res://.godot"]


func _initialize() -> void:
	var failures: Array[String] = []
	var self_path: String = (get_script() as Script).resource_path
	for path: String in _find_scripts("res://"):
		if path == self_path:
			continue  # Reloading the running script crashes the VM.
		var script: GDScript = ResourceLoader.load(path, "GDScript", ResourceLoader.CACHE_MODE_IGNORE)
		if script == null or not script.can_instantiate():
			failures.append(path)
	if failures.is_empty():
		print("check_scripts: all scripts compile")
		quit(0)
	else:
		printerr("check_scripts: failed to compile:\n  " + "\n  ".join(failures))
		quit(1)


func _find_scripts(dir_path: String) -> Array[String]:
	var found: Array[String] = []
	for skip: String in SKIP_DIRS:
		if dir_path.trim_suffix("/") == skip:
			return found
	if dir_path != "res://" and (FileAccess.file_exists(dir_path.path_join("project.godot")) or FileAccess.file_exists(dir_path.path_join(".gdignore"))):
		return found
	for file: String in DirAccess.get_files_at(dir_path):
		if file.get_extension() == "gd":
			found.append(dir_path.path_join(file))
	for sub: String in DirAccess.get_directories_at(dir_path):
		found.append_array(_find_scripts(dir_path.path_join(sub)))
	return found
