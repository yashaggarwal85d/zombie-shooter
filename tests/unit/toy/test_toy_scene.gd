extends GutTest
## The toy scene loads with its parts, and the build step hands over to the
## night (spec section 5, last item).

const TOY: String = "res://src/toy/toy.tscn"


func test_toy_scene_has_its_parts() -> void:
	var toy: CombatToy = (load(TOY) as PackedScene).instantiate() as CombatToy
	add_child_autofree(toy)
	for path: String in ["Camera2D", "FieldView", "Actors", "Fx", "Audio", "HudLayer/Hud"]:
		assert_not_null(toy.get_node_or_null(path), path)
	assert_true(toy.get_node("Actors").material is ShaderMaterial, "silhouettes are rim-lit")


func test_starts_in_the_build_step_then_runs_a_night() -> void:
	var toy: CombatToy = (load(TOY) as PackedScene).instantiate() as CombatToy
	add_child_autofree(toy)
	assert_eq(toy.phase, CombatToy.Phase.BUILD)
	assert_eq(toy.plan.remaining(), toy.night.start_scrap)
	toy.plan.cycle(0)
	toy._start_night()
	assert_eq(toy.phase, CombatToy.Phase.NIGHT)
	assert_eq(toy.sim.structures.size(), 2, "the shelter plus the fence just built")
	assert_eq(toy.sim.night, toy.night)


func test_night_end_shows_the_card_and_keeps_the_layout() -> void:
	var toy: CombatToy = (load(TOY) as PackedScene).instantiate() as CombatToy
	add_child_autofree(toy)
	toy.plan.cycle(2)
	toy._start_night()
	toy.sim.shelter.health = 0.0
	toy.sim.step(1.0 / 60.0, ToyInput.new())
	assert_eq(toy.phase, CombatToy.Phase.END)
	assert_eq(toy._hud.end_title, "The shelter fell")
	toy._enter_build()
	assert_eq(toy.plan.option_at(2).label(), "Fence", "last layout is kept for the next try")
