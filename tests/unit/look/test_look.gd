extends GutTest
## The look test (ART_AND_AUDIO_GUIDE): palettes keep the value rules, the
## sky follows the night's clock, the shapes can be filled, and the toy can
## switch between the look and the greybox.

const TOY: String = "res://src/toy/toy.tscn"
const PALETTES: Array[String] = ["day", "dusk", "night", "dawn"]


func _palette(name: String) -> LookPalette:
	return load("res://data/look/%s.tres" % name) as LookPalette


func test_play_plane_is_the_darkest_band() -> void:
	# Rule 1: figures and the cabin are darker than every layer behind them.
	for name: String in PALETTES:
		var p: LookPalette = _palette(name)
		for c: Color in p.ridges + p.trees:
			assert_lt(p.plane.get_luminance(), c.get_luminance(), "%s: plane vs %s" % [name, c])


func test_layers_get_lighter_with_distance() -> void:
	# Atmospheric perspective: each ridge is lighter than the one in front.
	for name: String in PALETTES:
		var p: LookPalette = _palette(name)
		for i: int in p.ridges.size() - 1:
			assert_gt(p.ridges[i].get_luminance(), p.ridges[i + 1].get_luminance(), "%s ridge %d" % [name, i])
		assert_gt(p.ridges[p.ridges.size() - 1].get_luminance(), p.trees[0].get_luminance(), "%s ridges vs trees" % name)


func test_warm_colours_stay_out_of_the_play_plane() -> void:
	# Rule 3: warm hues mean danger, so the plane and its key light are never
	# redder than they are blue, except the dusk and dawn rim, which is muted.
	for name: String in PALETTES:
		var p: LookPalette = _palette(name)
		assert_true(p.plane.r <= p.plane.b + 0.02, "%s plane is not warm" % name)
		if name == "day" or name == "night":
			assert_true(p.key_rim.r <= p.key_rim.b, "%s key light is cool" % name)
		assert_lt(p.key_rim.s, 0.35, "%s key light is muted" % name)


func test_sky_follows_the_night_clock() -> void:
	assert_eq(LookDirector.palette_at(0.0), LookDirector.DUSK)
	assert_eq(LookDirector.palette_at(0.5), LookDirector.NIGHT)
	var late: LookPalette = LookDirector.palette_at(0.99)
	assert_ne(late, LookDirector.NIGHT, "the last stretch blends toward dawn")
	assert_gt(late.sky_horizon.get_luminance(), LookDirector.NIGHT.sky_horizon.get_luminance())


func test_blend_lands_on_its_ends() -> void:
	var a: LookPalette = _palette("dusk")
	var b: LookPalette = _palette("night")
	assert_eq(LookPalette.blend(a, b, 0.0).sky_top, a.sky_top)
	assert_eq(LookPalette.blend(a, b, 1.0).fog, b.fog)
	assert_eq(LookPalette.blend(a, b, 0.5).ridges.size(), a.ridges.size())


func test_deodars_can_be_filled() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for seed_value: int in 40:
		rng.seed = seed_value
		for poly: PackedVector2Array in LookShapes.deodar(0.0, 0.0, rng.randf_range(60.0, 560.0), rng):
			assert_false(Geometry2D.triangulate_polygon(poly).is_empty(), "seed %d" % seed_value)


func test_toy_switches_between_look_and_greybox() -> void:
	var toy: CombatToy = (load(TOY) as PackedScene).instantiate() as CombatToy
	add_child_autofree(toy)
	var look: LookDirector = toy.get_node("Look") as LookDirector
	var field: LookFieldView = toy.get_node("FieldView") as LookFieldView
	assert_true(look.enabled)
	assert_true(field.look_on)
	assert_true((toy.get_node("Backdrop") as Node2D).visible)
	look._set_enabled(false)
	assert_false(field.look_on)
	assert_false((toy.get_node("Backdrop") as Node2D).visible)
	assert_false((toy.get_node("PostLayer") as CanvasLayer).visible)
	assert_true(toy.get_node("Actors").material is ShaderMaterial, "greybox keeps its rim shader")


func test_day_while_building_night_after() -> void:
	var toy: CombatToy = (load(TOY) as PackedScene).instantiate() as CombatToy
	add_child_autofree(toy)
	var look: LookDirector = toy.get_node("Look") as LookDirector
	assert_eq(look.palette_now(), LookDirector.DAY)
	toy._start_night()
	toy.sim.elapsed = toy.night.duration * 0.5
	assert_eq(look.palette_now(), LookDirector.NIGHT)
