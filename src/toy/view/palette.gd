class_name ToyPalette
extends RefCounted
## Greybox colours for night and the daylight build step. The shelter's
## light is always the brightest thing on screen (readability rule 2).

var sky_top: Color
var sky_bottom: Color
var trees: Array[Color] = []
var fog: Color
var ground: Color
var wood: Color
var wood_edge: Color
var shelter_body: Color
var pod_light: Color = Color(0.72, 0.9, 1.0)


static func night() -> ToyPalette:
	var p: ToyPalette = ToyPalette.new()
	p.sky_top = Color(0.03, 0.04, 0.07)
	p.sky_bottom = Color(0.09, 0.11, 0.16)
	p.trees = [Color(0.075, 0.095, 0.13), Color(0.05, 0.065, 0.09), Color(0.03, 0.038, 0.05)]
	p.fog = Color(0.32, 0.4, 0.52, 0.10)
	p.ground = Color(0.02, 0.024, 0.03)
	p.wood = Color(0.07, 0.065, 0.06)
	p.wood_edge = Color(0.34, 0.4, 0.48)
	p.shelter_body = Color(0.035, 0.038, 0.045)
	return p


static func day() -> ToyPalette:
	var p: ToyPalette = ToyPalette.new()
	p.sky_top = Color(0.36, 0.42, 0.5)
	p.sky_bottom = Color(0.62, 0.66, 0.68)
	p.trees = [Color(0.42, 0.47, 0.5), Color(0.3, 0.34, 0.36), Color(0.17, 0.19, 0.2)]
	p.fog = Color(0.75, 0.78, 0.8, 0.16)
	p.ground = Color(0.12, 0.12, 0.11)
	p.wood = Color(0.2, 0.17, 0.14)
	p.wood_edge = Color(0.55, 0.5, 0.42)
	p.shelter_body = Color(0.14, 0.13, 0.12)
	return p
