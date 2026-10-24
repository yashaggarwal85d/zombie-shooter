class_name SpawnEvent
extends Resource
## A group of infected entering from one side at a set time in the night.

@export var time: float = 0.0
## -1 enters from the left edge, 1 from the right.
@export_enum("Left:-1", "Right:1") var side: int = -1
@export var enemy: EnemyDefinition
@export var count: int = 1
## Seconds between members of the group.
@export var interval: float = 0.6
