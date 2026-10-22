extends Node
## Entry scene. Runs the Stage D combat toy, with the build label in a corner
## so every screenshot and bug report says which build it came from.

@onready var _build_label: Label = %BuildLabel


func _ready() -> void:
	_build_label.text = BuildInfo.label()
