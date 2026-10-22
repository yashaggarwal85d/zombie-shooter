class_name ToyStructure
extends RefCounted
## A built structure, or the shelter itself, standing on the field line.
## Positions are in field units: x along the ground, y as height above it.
## The infected pile up against a face (one pile per side) and climb it
## once the pile is tall enough (D12).

signal destroyed(structure: ToyStructure)

var definition: StructureDefinition
var x: float
var health: float
var has_ladder: bool = false
var is_shelter: bool = false
## Piles keyed by the side of the face they stand against: -1 left, 1 right.
var piles: Dictionary[int, Array] = {-1: [], 1: []}


func _init(p_definition: StructureDefinition, p_x: float, p_has_ladder: bool = false, p_is_shelter: bool = false) -> void:
	definition = p_definition
	x = p_x
	health = p_definition.health
	has_ladder = p_has_ladder
	is_shelter = p_is_shelter


func is_standing() -> bool:
	return health > 0.0


func height() -> float:
	return definition.height


func half_width() -> float:
	return definition.width * 0.5


func left() -> float:
	return x - half_width()


func right() -> float:
	return x + half_width()


## The x of the face an enemy coming from `side` stands against.
func face_x(side: int) -> float:
	return left() if side < 0 else right()


func spans(px: float) -> bool:
	return px >= left() and px <= right()


func health_fraction() -> float:
	return clampf(health / definition.health, 0.0, 1.0)


func take_damage(amount: float) -> void:
	if not is_standing():
		return
	health = maxf(0.0, health - amount)
	if health <= 0.0:
		destroyed.emit(self)
