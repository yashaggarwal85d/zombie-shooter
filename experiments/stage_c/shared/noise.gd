class_name StageCNoise
extends RefCounted
## EXPERIMENT (Stage C, C4). The central rule from Stage B section 2: each
## infected goes to the loudest sound it can hear, weighted by distance.
## Sound loses FLOOR_FALLOFF per floor crossed, so it reaches neighbouring
## floors but not the whole house. Ties go to the nearer source.

const FLOOR_FALLOFF: float = 0.35
const HEARING_THRESHOLD: float = 0.05
const TIE_EPSILON: float = 0.001

enum Kind { HUM, SHOT, LURE, QUIET_SHOT }


class Source:
	extends RefCounted
	var kind: Kind
	var level: int
	var position: Vector2
	var loudness: float
	var radius: float
	## Seconds left; INF for the chamber hum.
	var time_left: float

	func _init(p_kind: Kind, p_level: int, p_position: Vector2, p_loudness: float, p_radius: float, p_time_left: float) -> void:
		kind = p_kind
		level = p_level
		position = p_position
		loudness = p_loudness
		radius = p_radius
		time_left = p_time_left


static func perceived(source: Source, level: int, position: Vector2) -> float:
	var dist: float = absf(source.position.x - position.x)
	var falloff: float = maxf(0.0, 1.0 - dist / source.radius)
	var floors: int = absi(source.level - level)
	return source.loudness * falloff * pow(FLOOR_FALLOFF, floors)


## Index into `sources` of the one this listener goes to, or -1 if it hears
## nothing above the threshold.
static func pick(sources: Array[Source], level: int, position: Vector2) -> int:
	var best: int = -1
	var best_value: float = HEARING_THRESHOLD
	var best_dist: float = INF
	for i: int in sources.size():
		var s: Source = sources[i]
		var value: float = perceived(s, level, position)
		var dist: float = absf(s.position.x - position.x) + absi(s.level - level) * 1000.0
		if value > best_value + TIE_EPSILON or (absf(value - best_value) <= TIE_EPSILON and best >= 0 and dist < best_dist):
			best = i
			best_value = value
			best_dist = dist
	return best
