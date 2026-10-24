class_name ToyTelemetry
extends RefCounted
## What one night logs for the toy gate (spec section 3, Telemetry): one CSV
## row per night in user://toy_log.csv. Nothing leaves the device.

## A new file for the D14 build, so its extra columns never mix with rows
## from the first toy build in toy_log.csv.
const LOG_PATH: String = "user://toy_log_v2.csv"
const COLUMNS: PackedStringArray = [
	"build", "date", "result", "cause_enemy", "cause_target", "duration_s", "layout",
	"loud_fire_s", "quiet_fire_s", "loud_shots", "quiet_shots", "loud_fire_share",
	"swaps", "off_ground_s", "fence_s", "wall_s", "high_wall_s", "roof_s", "ladder_s",
	"structures_lost", "player_hits", "shelter_hits_shambler", "shelter_hits_runner",
	"kills_shambler", "kills_runner", "kills_gun", "kills_melee", "melee_kill_share",
	"bounces", "pile_knockoffs",
]

var result: StringName = &"none"
var cause_enemy: StringName = &""
var cause_target: StringName = &""
var duration: float = 0.0
var layout: String = ""
var loud_fire_time: float = 0.0
var quiet_fire_time: float = 0.0
var loud_shots: int = 0
var quiet_shots: int = 0
var swaps: int = 0
var off_ground_time: float = 0.0
var height_time: Dictionary[StringName, float] = {}
var structures_lost: int = 0
var player_hits: int = 0
var shelter_hits: Dictionary[StringName, int] = {}
var kills: Dictionary[StringName, int] = {}
## Kills by &"gun" or &"melee" (D14 gate: neither above about 80%).
var kills_by: Dictionary[StringName, int] = {}
var bounces: int = 0
var pile_knockoffs: int = 0


func add_shot(loud: bool, fire_interval: float) -> void:
	if loud:
		loud_shots += 1
		loud_fire_time += fire_interval
	else:
		quiet_shots += 1
		quiet_fire_time += fire_interval


## Share of firing time spent on the loud barrel, 0–1; -1 if nothing was fired.
func loud_share() -> float:
	var total: float = loud_fire_time + quiet_fire_time
	return -1.0 if total <= 0.0 else loud_fire_time / total


func add_height_time(where: StringName, delta: float) -> void:
	height_time[where] = height_time.get(where, 0.0) + delta


func add_shelter_hit(enemy_id: StringName) -> void:
	shelter_hits[enemy_id] = shelter_hits.get(enemy_id, 0) + 1


func add_kill(enemy_id: StringName, by: StringName = &"gun") -> void:
	kills[enemy_id] = kills.get(enemy_id, 0) + 1
	kills_by[by] = kills_by.get(by, 0) + 1


## Share of kills made with melee, 0–1; -1 if nothing was killed.
func melee_kill_share() -> float:
	var melee: int = kills_by.get(&"melee", 0)
	var total: int = melee + kills_by.get(&"gun", 0)
	return -1.0 if total == 0 else float(melee) / total


func row(build: String, date: String) -> PackedStringArray:
	return PackedStringArray([
		build, date, String(result), String(cause_enemy), String(cause_target), "%.1f" % duration, layout,
		"%.2f" % loud_fire_time, "%.2f" % quiet_fire_time, str(loud_shots), str(quiet_shots), "%.3f" % loud_share(),
		str(swaps), "%.1f" % off_ground_time,
		"%.1f" % height_time.get(&"fence", 0.0), "%.1f" % height_time.get(&"wall", 0.0),
		"%.1f" % height_time.get(&"high_wall", 0.0), "%.1f" % height_time.get(&"roof", 0.0),
		"%.1f" % height_time.get(&"ladder", 0.0),
		str(structures_lost), str(player_hits), str(shelter_hits.get(&"shambler", 0)), str(shelter_hits.get(&"runner", 0)),
		str(kills.get(&"shambler", 0)), str(kills.get(&"runner", 0)),
		str(kills_by.get(&"gun", 0)), str(kills_by.get(&"melee", 0)), "%.3f" % melee_kill_share(),
		str(bounces), str(pile_knockoffs),
	])


## Appends this night to the log, writing the header first if the file is new.
func append_to(path: String, build: String, date: String) -> Error:
	var exists: bool = FileAccess.file_exists(path)
	var f: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE if exists else FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.seek_end()
	if not exists:
		f.store_csv_line(COLUMNS)
	f.store_csv_line(row(build, date))
	f.close()
	return OK
