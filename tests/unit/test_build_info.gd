extends GutTest


func test_version_matches_project_setting() -> void:
	var expected: String = ProjectSettings.get_setting("application/config/version")
	assert_eq(BuildInfo.version(), expected)


func test_label_names_engine_and_platform() -> void:
	var text: String = BuildInfo.label()
	assert_string_contains(text, BuildInfo.engine_version())
	assert_string_contains(text, OS.get_name())
