class_name NightDefinition
extends Resource
## One authored night (GDD section 4): its length and spawn schedule.

@export var duration: float = 240.0
@export var start_scrap: int = 8
@export var spawns: Array[SpawnEvent] = []
