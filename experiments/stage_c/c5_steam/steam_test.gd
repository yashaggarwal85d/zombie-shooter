extends Node2D
## EXPERIMENT C5 (Stage C): GodotSteam GDExtension on Godot 4.7, one
## achievement and one cloud save, against Valve's public test app Spacewar
## (app id 480), so no Steamworks account or fee is needed yet.
## Setup and run steps are in c5_steam/README.md. Without the addon this
## scene just reports that it's missing; the project still runs without it.
## Pass (Stage B 11): init succeeds, the achievement unlocks (Steam overlay
## toast), and a file written to Steam Cloud reads back identical.

const APP_ID: int = 480
const ACHIEVEMENT: String = "ACH_WIN_ONE_GAME" # exists in Spacewar
const CLOUD_FILE: String = "stage_c_c5_test.sav"

var _log: Label
var _lines: PackedStringArray = []
var _steam: Object
var _results: Dictionary = {"init": false, "achievement": false, "cloud": false}


func _ready() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.055, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	_log = Label.new()
	_log.position = Vector2(60, 40)
	_log.add_theme_font_size_override("font_size", 24)
	layer.add_child(_log)
	var bar: HBoxContainer = HBoxContainer.new()
	bar.position = Vector2(60, 960)
	bar.add_theme_constant_override("separation", 16)
	layer.add_child(bar)
	bar.add_child(StageCLaunch.button("Reset achievement", _reset_achievement))
	bar.add_child(StageCLaunch.button("Menu", StageCLaunch.back_to_menu.bind(get_tree())))
	_run()


func _process(_delta: float) -> void:
	if _steam != null:
		_steam.call("run_callbacks")


func _say(text: String) -> void:
	_lines.append(text)
	_log.text = "\n".join(_lines)
	print(text)


func _run() -> void:
	_say("C5 GodotSteam test  ·  Godot %s  ·  %s" % [Engine.get_version_info()["string"], OS.get_name()])
	if not Engine.has_singleton("Steam"):
		_say("FAIL: the Steam singleton isn't registered. Is addons/godotsteam installed? See c5_steam/README.md.")
		return
	_steam = Engine.get_singleton("Steam")
	_say("GodotSteam loaded: %s" % str(_steam.call("get_godotsteam_version")) if _steam.has_method("get_godotsteam_version") else "GodotSteam loaded")
	var init: Dictionary = _steam.call("steamInitEx", false, APP_ID) as Dictionary
	_say("steamInitEx(%d): %s" % [APP_ID, str(init)])
	if int(init.get("status", -1)) != 0:
		_say("FAIL: Steam didn't initialise. Is the Steam client running and logged in? Is steam_appid.txt next to the exe/project?")
		_finish()
		return
	_results["init"] = true
	_say("Logged in as: %s" % str(_steam.call("getPersonaName")))

	# Achievement.
	var set_ok: bool = _steam.call("setAchievement", ACHIEVEMENT) as bool
	var store_ok: bool = _steam.call("storeStats") as bool
	var got: Dictionary = _steam.call("getAchievement", ACHIEVEMENT) as Dictionary
	_say("setAchievement=%s storeStats=%s getAchievement=%s" % [set_ok, store_ok, str(got)])
	_results["achievement"] = set_ok and store_ok and bool(got.get("achieved", false))

	# Cloud save round trip.
	var account: bool = _steam.call("isCloudEnabledForAccount") as bool
	var app: bool = _steam.call("isCloudEnabledForApp") as bool
	_say("Cloud enabled: account=%s app=%s" % [account, app])
	var payload: PackedByteArray = ("stage c cloud test %s" % Time.get_datetime_string_from_system()).to_utf8_buffer()
	var wrote: bool = _steam.call("fileWrite", CLOUD_FILE, payload) as bool
	var size: int = _steam.call("getFileSize", CLOUD_FILE) as int
	var read: Dictionary = _steam.call("fileRead", CLOUD_FILE, size) as Dictionary
	var buf: PackedByteArray = read.get("buf", PackedByteArray()) as PackedByteArray
	_say("fileWrite=%s size=%d read ok=%s" % [wrote, size, read.get("ret", false)])
	_results["cloud"] = wrote and buf == payload
	_say("Read back identical: %s" % (buf == payload))
	_finish()


func _finish() -> void:
	var ok: bool = _results["init"] and _results["achievement"] and _results["cloud"]
	_say("\nRESULT: %s  (init %s, achievement %s, cloud %s)" % ["PASS" if ok else "FAIL", _results["init"], _results["achievement"], _results["cloud"]])
	_say("Check the Steam overlay showed the achievement toast. Take a photo of this screen for the report.")


func _reset_achievement() -> void:
	if _steam == null or not _results["init"]:
		return
	_steam.call("clearAchievement", ACHIEVEMENT)
	_steam.call("storeStats")
	_say("Achievement cleared, so the test can run again.")
