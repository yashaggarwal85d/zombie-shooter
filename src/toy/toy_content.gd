class_name ToyContent
extends RefCounted
## Where the toy's data lives, and how to make a field from it. Definitions
## are shared, read-only templates: runtime state lives in FieldSim objects.

const SHAMBLER: String = "res://data/enemies/shambler.tres"
const RUNNER: String = "res://data/enemies/runner.tres"
const FENCE: String = "res://data/structures/fence.tres"
const WALL: String = "res://data/structures/wall.tres"
const HIGH_WALL: String = "res://data/structures/high_wall.tres"
const SHELTER: String = "res://data/structures/shelter.tres"
const OPEN_BARREL: String = "res://data/weapons/open_barrel.tres"
const SUPPRESSOR: String = "res://data/weapons/suppressor.tres"
const NIGHT: String = "res://data/nights/toy_night.tres"


static func structure(path: String) -> StructureDefinition:
	return load(path) as StructureDefinition


static func enemy(path: String) -> EnemyDefinition:
	return load(path) as EnemyDefinition


static func night() -> NightDefinition:
	return load(NIGHT) as NightDefinition


## Fence, wall, high wall: the build options in cycle order.
static func buildables() -> Array[StructureDefinition]:
	return [structure(FENCE), structure(WALL), structure(HIGH_WALL)]


static func barrels() -> Array[WeaponComponent]:
	return [load(OPEN_BARREL) as WeaponComponent, load(SUPPRESSOR) as WeaponComponent]


static func new_plan(budget: int) -> BuildPlan:
	return BuildPlan.new(budget, FieldSim.build_spot_xs(), buildables())


static func new_field(night_definition: NightDefinition, plan: BuildPlan, seed_value: int = 1) -> FieldSim:
	var sim: FieldSim = FieldSim.new(night_definition, structure(SHELTER), barrels(), seed_value)
	if plan != null:
		sim.apply_plan(plan)
	return sim
