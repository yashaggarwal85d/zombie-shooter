class_name StructureDefinition
extends Resource
## Something the player builds at a build spot (GDD section 6).

@export var id: StringName = &""
@export var display_name: String = ""
@export var height: float = 60.0
@export var width: float = 40.0
@export var health: float = 15.0
@export var cost: int = 1
## Low enough for runners to vault (fences).
@export var vaultable: bool = false
