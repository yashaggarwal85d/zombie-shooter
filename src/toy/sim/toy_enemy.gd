class_name ToyEnemy
extends RefCounted
## One infected's runtime state. The rules that move it live in FieldSim, so
## all of them can be stepped and tested without a scene.

enum State { WALK, WAIT, PILE, CLIMB, ON_TOP, FALL, DEAD }

var definition: EnemyDefinition
var state: State = State.WALK
var x: float
var y: float = 0.0
var health: float
## -1 heading left, 1 heading right.
var heading: int = 1
var target_x: float
var target: NoiseSource = null
var memory_left: float = 0.0
var replan_in: float = 0.0
var commit_left: float = 0.0
var attack_cooldown: float = 0.0
## Counts down the tell before a hit; negative when not winding up.
var wind_up_left: float = -1.0
var wind_up_target: Object = null
## The structure this enemy is piled against, climbing, or standing on.
var structure: ToyStructure = null
var pile_side: int = 0
var climb_left: float = 0.0
## Per-enemy stagger so a crowd spreads instead of stacking (C4 finding 3).
var stop_offset: float = 0.0
var speed_factor: float = 1.0
var id: int = 0


func _init(p_definition: EnemyDefinition, p_x: float, p_id: int) -> void:
	definition = p_definition
	x = p_x
	health = p_definition.health
	id = p_id


func is_alive() -> bool:
	return state != State.DEAD


func is_runner() -> bool:
	return definition.ignores_noise


## Hit box in field units (x left edge, y bottom, size).
func rect() -> Rect2:
	return Rect2(x - definition.width * 0.5, y, definition.width, definition.height)


func top() -> float:
	return y + definition.height
