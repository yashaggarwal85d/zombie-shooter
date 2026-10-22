extends GutTest
## GDD section 9 and spec edge case 12.

var weapon: ToyWeapon


func before_each() -> void:
	weapon = ToyWeapon.new(ToyContent.barrels())


func _run(seconds: float) -> void:
	var t: float = 0.0
	while t < seconds:
		weapon.step(0.01)
		t += 0.01


func test_barrels_load_from_data() -> void:
	var loud: WeaponComponent = weapon.components[0]
	var quiet: WeaponComponent = weapon.components[1]
	assert_eq(loud.tag, &"loud")
	assert_eq(quiet.tag, &"quiet")
	assert_almost_eq(quiet.damage, loud.damage * 0.7, 0.001, "suppressor is -30% damage")
	assert_lt(quiet.noise_loudness, FieldSim.HUM_LOUDNESS, "quiet sits below the hum")
	assert_gt(loud.noise_loudness, FieldSim.HUM_LOUDNESS)


func test_fire_rate_and_magazine() -> void:
	var shots: int = 0
	for i: int in 400:
		if weapon.try_fire():
			shots += 1
		weapon.step(0.01)
		if shots == weapon.current().magazine:
			break
	assert_eq(shots, 8)
	assert_eq(weapon.ammo, 0)
	assert_false(weapon.try_fire(), "empty")
	assert_true(weapon.is_reloading(), "an empty magazine starts a reload")


func test_reload_refills_after_its_time() -> void:
	weapon.ammo = 2
	weapon.start_reload()
	_run(weapon.current().reload_time - 0.05)
	assert_eq(weapon.ammo, 2)
	_run(0.1)
	assert_eq(weapon.ammo, 8)


func test_swap_takes_time_and_blocks_firing() -> void:
	weapon.start_swap()
	assert_false(weapon.try_fire())
	_run(ToyWeapon.SWAP_TIME - 0.05)
	assert_false(weapon.is_loud() == false, "still the loud barrel until the swap finishes")
	_run(0.1)
	assert_false(weapon.is_loud())
	assert_true(weapon.try_fire())


func test_swap_cancels_reload_and_comes_up_full() -> void:
	weapon.ammo = 1
	weapon.start_reload()
	weapon.start_swap()
	assert_false(weapon.is_reloading())
	_run(ToyWeapon.SWAP_TIME + 0.05)
	assert_eq(weapon.ammo, weapon.current().magazine)
