class_name LookPalette
extends Resource
## One time of day for the look test (ART_AND_AUDIO_GUIDE section 3). Values
## step from light far away to dark at the play plane, so figures always read
## as dark shapes against something lighter. Warm colours belong to danger.

@export var sky_top: Color = Color(0.03, 0.04, 0.07)
@export var sky_horizon: Color = Color(0.1, 0.13, 0.2)
## The sun or moon disc. Alpha 0 hides it.
@export var orb: Color = Color(0.79, 0.83, 0.88)
@export var orb_height: float = 0.75
## Snow on the far peaks (the Himalayan tell); alpha sets how much shows.
@export var snow: Color = Color(0.28, 0.32, 0.42)
## Ridges far to near, then tree layers far to near.
@export var ridges: Array[Color] = [Color(0.17, 0.2, 0.26), Color(0.13, 0.16, 0.21), Color(0.09, 0.12, 0.16), Color(0.07, 0.09, 0.13)]
@export var trees: Array[Color] = [Color(0.055, 0.075, 0.1), Color(0.035, 0.045, 0.065)]
## Mist in the valleys and on the ground. Alpha is the thickest it gets.
@export var fog: Color = Color(0.35, 0.42, 0.53, 0.5)
@export var ground: Color = Color(0.02, 0.025, 0.035)
## The play plane: the cabin, structures and figures' bodies.
@export var plane: Color = Color(0.016, 0.018, 0.026)
## Edge light on the play plane from the sky (moon or overcast).
@export var key_rim: Color = Color(0.45, 0.52, 0.65)
## How strongly the pod's cold light shows (low by day, full at night).
@export_range(0.0, 1.0) var pod_strength: float = 1.0
## Fine rain amount, 0 to 1.
@export_range(0.0, 1.0) var rain: float = 0.6
## Screen grade: shadows are lifted toward this colour.
@export var grade_shadow: Color = Color(0.04, 0.05, 0.09)
@export_range(0.0, 1.0) var vignette: float = 0.45


## Blends two times of day, for dusk turning to night and night to dawn.
static func blend(a: LookPalette, b: LookPalette, t: float) -> LookPalette:
	var p: LookPalette = LookPalette.new()
	p.sky_top = a.sky_top.lerp(b.sky_top, t)
	p.sky_horizon = a.sky_horizon.lerp(b.sky_horizon, t)
	p.orb = a.orb.lerp(b.orb, t)
	p.orb_height = lerpf(a.orb_height, b.orb_height, t)
	p.snow = a.snow.lerp(b.snow, t)
	p.ridges = _blend_list(a.ridges, b.ridges, t)
	p.trees = _blend_list(a.trees, b.trees, t)
	p.fog = a.fog.lerp(b.fog, t)
	p.ground = a.ground.lerp(b.ground, t)
	p.plane = a.plane.lerp(b.plane, t)
	p.key_rim = a.key_rim.lerp(b.key_rim, t)
	p.pod_strength = lerpf(a.pod_strength, b.pod_strength, t)
	p.rain = lerpf(a.rain, b.rain, t)
	p.grade_shadow = a.grade_shadow.lerp(b.grade_shadow, t)
	p.vignette = lerpf(a.vignette, b.vignette, t)
	return p


static func _blend_list(a: Array[Color], b: Array[Color], t: float) -> Array[Color]:
	var out: Array[Color] = []
	for i: int in mini(a.size(), b.size()):
		out.append(a[i].lerp(b[i], t))
	return out
