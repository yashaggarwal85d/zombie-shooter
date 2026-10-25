class_name BuildInfo
extends RefCounted
## Read-only facts about the running build, for on-screen labels and bug reports.


static func version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))


static func engine_version() -> String:
	return str(Engine.get_version_info().get("string", "unknown"))


static func label() -> String:
	return "v%s · Godot %s · %s" % [version(), engine_version(), OS.get_name()]
