extends SceneTree
## Renders the look test (the combat toy in the art direction) and saves one
## screenshot per time of day, plus the greybox and the low preset at the
## same moment, for judging the look without a GPU.
## Usage: xvfb-run godot --path . --rendering-driver opengl3 --resolution 1920x1080 --script res://tools/look/capture.gd -- <out_dir> [clip_frames]
## Not used by CI.

## [night seconds, file name, time mode, high quality, look on]
const SHOTS: Array[Array] = [
	[4.0, "2_dusk", LookDirector.TimeMode.AUTO, true, true],
	[34.0, "3_night", LookDirector.TimeMode.NIGHT, true, true],
	[34.2, "3_night_greybox", LookDirector.TimeMode.NIGHT, true, false],
	[34.4, "3_night_low", LookDirector.TimeMode.NIGHT, false, true],
	[46.0, "4_dawn", LookDirector.TimeMode.DAWN, true, true],
	[46.2, "1_day_in_combat", LookDirector.TimeMode.DAY, true, true],
]

var _toy: CombatToy
var _look: LookDirector
var _out: String
var _frame: int = 0
var _taken: int = 0
var _pending: int = -1
var _clip_frames: int = 0
var _clip_taken: int = 0


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else "user://look_capture"
	_clip_frames = int(args[1]) if args.size() > 1 else 0
	DirAccess.make_dir_recursive_absolute(_out)
	var packed: PackedScene = load("res://src/toy/toy.tscn")
	_toy = packed.instantiate() as CombatToy
	root.add_child(_toy)
	_look = _toy.get_node(^"Look") as LookDirector
	Engine.physics_ticks_per_second = 60
	Engine.max_fps = 60


func _setup() -> void:
	var layout: Array[int] = [1, 2, 0, 0, 4, 1]
	for i: int in layout.size():
		_toy.plan.choices[i] = layout[i]
	_toy._make_build_preview(FieldSim.SHELTER_X - 160.0)
	var bot: ScriptedPlayer = ScriptedPlayer.new(5)
	bot.trigger_rate = 0.35
	_toy.bot = bot


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 2:
		_setup()
	if _frame == 30:
		_save("1_day_build")
		_toy._start_night()
	if _toy.phase == CombatToy.Phase.BUILD:
		return false
	var t: float = _toy.sim.elapsed
	if _clip_frames > 0 and _clip_taken < _clip_frames and t > 20.0 and _frame % 2 == 0:
		_save("clip_%04d" % _clip_taken)
		_clip_taken += 1
	# A shot is staged one frame early so every layer has redrawn.
	if _pending >= 0:
		_save(SHOTS[_pending][1])
		_pending = -1
		_taken += 1
	elif _taken < SHOTS.size() and t >= float(SHOTS[_taken][0]):
		var s: Array = SHOTS[_taken]
		_look.time_mode = s[2]
		_look.quality_high = s[3]
		_look._set_enabled(s[4])
		_toy.paused = true
		_pending = _taken
		return false
	else:
		_toy.paused = false
		_look.time_mode = LookDirector.TimeMode.AUTO
		_look.quality_high = true
		_look._set_enabled(true)
	return _taken >= SHOTS.size() and _clip_taken >= _clip_frames


func _save(name: String) -> void:
	var img: Image = root.get_texture().get_image()
	img.save_png(_out.path_join(name + ".png"))
	print("saved ", name)
