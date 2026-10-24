class_name NoiseSource
extends RefCounted
## One sound the infected can hear (GDD section 5). The field is a line, so a
## source only has an x position. The pod's hum never runs out.

enum Kind { HUM, SHOT, MELEE, STRUCTURE_BREAK }

var kind: Kind
var x: float
var loudness: float
var radius: float
## Seconds left; INF for the hum.
var time_left: float


func _init(p_kind: Kind, p_x: float, p_loudness: float, p_radius: float, p_time_left: float) -> void:
	kind = p_kind
	x = p_x
	loudness = p_loudness
	radius = p_radius
	time_left = p_time_left


func is_active() -> bool:
	return time_left > 0.0
