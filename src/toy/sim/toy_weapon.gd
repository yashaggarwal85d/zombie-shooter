class_name ToyWeapon
extends RefCounted
## The toy's firearm: one slot, two barrels (GDD section 9). Swapping takes
## time and can happen mid-night only in the toy, so the loud/quiet choice can
## be measured. Timing only; FieldSim does the shooting.

const SWAP_TIME: float = 1.5

var components: Array[WeaponComponent] = []
var current_index: int = 0
var ammo: int = 0
var reload_left: float = 0.0
var swap_left: float = 0.0
var cooldown: float = 0.0


func _init(p_components: Array[WeaponComponent]) -> void:
	components = p_components
	ammo = current().magazine


func current() -> WeaponComponent:
	return components[current_index]


func is_loud() -> bool:
	return current().tag == &"loud"


func is_reloading() -> bool:
	return reload_left > 0.0


func is_swapping() -> bool:
	return swap_left > 0.0


func step(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if swap_left > 0.0:
		swap_left -= delta
		if swap_left <= 0.0:
			swap_left = 0.0
			current_index = (current_index + 1) % components.size()
			ammo = current().magazine
	if reload_left > 0.0:
		reload_left -= delta
		if reload_left <= 0.0:
			reload_left = 0.0
			ammo = current().magazine


func can_fire() -> bool:
	return ammo > 0 and cooldown <= 0.0 and not is_reloading() and not is_swapping()


## Spends a round if it can. Returns whether a shot happened. An empty
## magazine starts a reload by itself.
func try_fire() -> bool:
	if not can_fire():
		if ammo <= 0 and not is_reloading() and not is_swapping():
			start_reload()
		return false
	ammo -= 1
	cooldown = current().fire_interval
	return true


func start_reload() -> void:
	if is_swapping() or is_reloading() or ammo >= current().magazine:
		return
	reload_left = current().reload_time


## Swapping cancels a reload; the new barrel comes up with a full magazine.
func start_swap() -> void:
	if is_swapping() or components.size() < 2:
		return
	reload_left = 0.0
	swap_left = SWAP_TIME
