class_name EnemyDefinition
extends Resource
## One kind of infected (GDD section 8). Loaded as a read-only template.

@export var id: StringName = &""
@export var speed: float = 60.0
@export var health: float = 3.0
@export var width: float = 36.0
@export var height: float = 56.0
## Runners go straight for the shelter.
@export var ignores_noise: bool = false
## Runners vault low fences instead of piling against them.
@export var vaults_fences: bool = false
@export var attacks_player: bool = true
@export var damage_player: float = 10.0
@export var damage_structure: float = 5.0
@export var damage_shelter: float = 6.0
## Seconds between hits, after the wind-up.
@export var attack_interval: float = 1.5
## The tell before a hit (GDD section 8: 0.5 s before any hit on the shelter).
@export var wind_up: float = 0.5
