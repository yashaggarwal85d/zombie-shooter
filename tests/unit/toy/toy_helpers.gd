class_name ToyTestHelpers
extends RefCounted
## Builders shared by the combat toy tests.

const DT: float = 1.0 / 60.0


## A field with no scheduled spawns and the given night length.
static func empty_field(duration: float = 600.0) -> FieldSim:
	var night: NightDefinition = NightDefinition.new()
	night.duration = duration
	return ToyContent.new_field(night, null)


static func idle() -> ToyInput:
	return ToyInput.new()


static func run(sim: FieldSim, seconds: float, input: ToyInput = null) -> void:
	var i: ToyInput = input if input != null else ToyInput.new()
	var steps: int = int(ceilf(seconds / DT))
	for n: int in steps:
		sim.step(DT, i)


## Moves the player well out of the way so it doesn't draw or block anyone.
static func park_player(sim: FieldSim) -> void:
	sim.player.x = FieldSim.SHELTER_X
	sim.player.health = 1.0e9
