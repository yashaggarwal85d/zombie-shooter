extends SceneTree
## Renders the combat toy with the scripted player and saves screenshots, for
## reviewing the look without a GPU (run under xvfb with a software renderer).
## Usage: xvfb-run godot --path . --rendering-driver opengl3 --script res://tools/toy/capture.gd -- <out_dir> [frames_for_clip]
## Not used by CI.

const SHOTS: Array[float] = [20.0, 40.0]

var _toy: CombatToy
var _out: String
var _frame: int = 0
var _clip_frames: int = 0
var _taken: int = 0
var _build_shot: bool = false


func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	_out = args[0] if args.size() > 0 else "user://capture"
	_clip_frames = int(args[1]) if args.size() > 1 else 0
	DirAccess.make_dir_recursive_absolute(_out)
	var packed: PackedScene = load("res://src/toy/toy.tscn")
	_toy = packed.instantiate() as CombatToy
	root.add_child(_toy)
	Engine.physics_ticks_per_second = 60
	Engine.max_fps = 60


## Runs once the toy is in the tree (its _ready has made the plan).
func _setup() -> void:
	# A mixed layout: fence and wall on the left, high wall with ladder and a
	# fence on the right.
	var layout: Array[int] = [1, 2, 0, 0, 4, 1]
	for i: int in layout.size():
		_toy.plan.choices[i] = layout[i]
	_toy._make_build_preview(FieldSim.SHELTER_X - 160.0)
	var bot: ScriptedPlayer = ScriptedPlayer.new(5)
	bot.trigger_rate = 0.35
	# The hatchet brawler, so shots show slashes and bounces (D14).
	bot.brawler = true
	_toy.bot = bot


func _process(_delta: float) -> bool:
	_frame += 1
	if _frame == 2:
		_setup()
	if _frame == 20 and not _build_shot:
		_build_shot = true
		_save("build_step")
		_toy._start_night()
		_toy._debug = false
	if _toy.phase == CombatToy.Phase.NIGHT or _toy.phase == CombatToy.Phase.END:
		var t: float = _toy.sim.elapsed
		if _taken < SHOTS.size() and t >= SHOTS[_taken]:
			_save("night_%02ds" % int(SHOTS[_taken]))
			_taken += 1
		if _clip_frames > 0 and _frame % 2 == 0 and t > 20.0 and t <= 20.0 + _clip_frames / 30.0:
			_save("clip_%04d" % int((t - 20.0) * 30.0))
		if _taken >= SHOTS.size() and (_clip_frames == 0 or t > 20.0 + _clip_frames / 30.0):
			_toy._debug = true
			_toy._fx.debug = true
			_toy._hud.debug = true
			if t > SHOTS[SHOTS.size() - 1] + 1.0:
				_save("night_debug")
				return true
	return false


func _save(name: String) -> void:
	var img: Image = root.get_texture().get_image()
	img.save_png(_out.path_join(name + ".png"))
	print("saved ", name, " t=", _toy.sim.elapsed if _toy.sim else 0.0)
