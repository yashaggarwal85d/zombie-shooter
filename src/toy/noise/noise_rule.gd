class_name NoiseRule
extends RefCounted
## The central rule (GDD section 5): each infected heads for the loudest sound
## it can hear, weighted by distance. Ported from the Stage C experiment
## (experiments/stage_c/shared/noise.gd), without floors.

## Below this, a sound isn't heard at all.
const HEARING_THRESHOLD: float = 0.05
const TIE_EPSILON: float = 0.001


static func perceived(source: NoiseSource, listener_x: float) -> float:
	if source.radius <= 0.0:
		return 0.0
	var falloff: float = maxf(0.0, 1.0 - absf(source.x - listener_x) / source.radius)
	return source.loudness * falloff


## The loudest active source this listener hears, or null. Ties go to the
## nearer source.
static func loudest(sources: Array[NoiseSource], listener_x: float) -> NoiseSource:
	var best: NoiseSource = null
	var best_value: float = HEARING_THRESHOLD
	var best_dist: float = INF
	for s: NoiseSource in sources:
		if not s.is_active():
			continue
		var value: float = perceived(s, listener_x)
		var dist: float = absf(s.x - listener_x)
		if value > best_value + TIE_EPSILON or (best != null and absf(value - best_value) <= TIE_EPSILON and dist < best_dist):
			best = s
			best_value = value
			best_dist = dist
	return best


## Whether a listener following `current` switches to `candidate`. A sound
## that has stopped still holds the listener while its memory lasts, fading
## with it; a newcomer must beat the current pull by `hysteresis` (the Stage C
## finding that stopped crowds dithering, D10).
static func should_switch(current: NoiseSource, memory_left: float, memory: float, candidate: NoiseSource, listener_x: float, hysteresis: float) -> bool:
	if candidate == null or candidate == current:
		return false
	if current == null:
		return true
	var current_pull: float = perceived(current, listener_x)
	if not current.is_active():
		if memory_left <= 0.0 or memory <= 0.0:
			return true
		current_pull *= memory_left / memory
	return perceived(candidate, listener_x) > hysteresis * current_pull
