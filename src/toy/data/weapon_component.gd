class_name WeaponComponent
extends Resource
## A barrel for the toy's firearm (GDD section 9). One tag, one noise pulse.

@export var id: StringName = &""
@export var display_name: String = ""
@export var tag: StringName = &""
@export var damage: float = 2.0
@export var fire_interval: float = 0.28
@export var magazine: int = 8
@export var reload_time: float = 1.2
@export var noise_loudness: float = 80.0
@export var noise_radius: float = 1200.0
