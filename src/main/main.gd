extends Control
## Entry scene for the pre-prototype skeleton. Shows the build label only.
## Gameplay scenes replace this once the Stage C prototype is approved.

@onready var _build_label: Label = %BuildLabel


func _ready() -> void:
	_build_label.text = BuildInfo.label()
