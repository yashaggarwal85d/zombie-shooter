class_name ToyTelemetry
extends RefCounted
## What one night logs for the toy gate (spec section 3, Telemetry): one CSV
## row per night in user://toy_log.csv. Nothing leaves the device.

const LOG_PATH: String = "user://toy_log.csv"
const COLUMNS: PackedStringArray = [
	"build", "date", "result", "cause_enemy", "cause_target", "duration_s", "layout",
	"loud_fire_s", "quiet_fire_s", "loud_shots", "quiet_shots", "loud_fire_share",
	"swaps", "off_ground_s", "fence_s", "wall_s", "high_wall_s", "roof_s", "ladder_s",
	"structures_lost", "player_hits", "shelter_hits_shambler", "shelter_hits_runner",
	"kills_shambler", "kills_runner",
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


func add_kill(enemy_id: StringName) -> void:
	kills[enemy_id] = kills.get(enemy_id, 0) + 1


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
