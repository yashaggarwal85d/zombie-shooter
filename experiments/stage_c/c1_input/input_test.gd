extends Node2D
## EXPERIMENT C1 (Stage C): do the root project's InputMap actions drive a
## test character with keyboard and mouse, a gamepad, and touch?
## Pass (Stage B 11): on Windows and Android exports, every action below
## lights up from each device that should trigger it, and the character
## moves along the floor and changes floor at a stairwell.

const ACTIONS: PackedStringArray = ["move_left", "move_right", "stairs_up", "stairs_down", "aim", "fire", "melee", "dodge", "reload", "interact", "pause"]
const SPEED: float = 260.0
const STAIR_REACH: float = 50.0

var view: StageCHouseView
var hero: Sprite2D
var level: int = 1
var aim_dir: Vector2 = Vector2.RIGHT
var _seen: Dictionary = {}
var _last_device: String = "-"
var _status: Label
var _flash: float = 0.0
var _touch_aim_index: int = -1
var _touch_aim_origin: Vector2
var _overlay: Node2D


func _ready() -> void:
	view = StageCHouseView.new()
	add_child(view)
	view.apply_preset(StageCHouseView.Preset.LOW)
	hero = view.make_actor(StageCHouseView.PROTAGONIST_TEX)
	hero.position = view.building.floor_point(level, 700.0)
	_overlay = Node2D.new()
	add_child(_overlay) # after the view, so the aim line draws on top
	_overlay.draw.connect(_draw_overlay)
	for a: String in ACTIONS:
		_seen[a] = PackedStringArray()
	_build_ui()


func _build_ui() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	_status = Label.new()
	_status.position = Vector2(24, 16)
	_status.add_theme_font_size_override("font_size", 22)
	_status.add_theme_color_override("font_outline_color", Color.BLACK)
	_status.add_theme_constant_override("outline_size", 6)
	layer.add_child(_status)
	# Touch controls: TouchScreenButton feeds InputMap actions directly, so the
	# same action names drive touch. Left thumb: move and stairs; right: fire,
	# dodge, melee. Aim on touch is a drag anywhere on the right half.
	var specs: Array = [
		["move_left", Vector2(60, 860)], ["move_right", Vector2(260, 860)],
		["stairs_up", Vector2(160, 720)], ["stairs_down", Vector2(160, 960)],
		["fire", Vector2(1700, 860)], ["dodge", Vector2(1540, 940)], ["melee", Vector2(1560, 760)],
	]
	for spec: Array in specs:
		var btn: TouchScreenButton = TouchScreenButton.new()
		btn.action = spec[0] as String
		btn.position = spec[1] as Vector2
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(150, 110)
		btn.shape = shape
		btn.shape_centered = false
		btn.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
		layer.add_child(btn)
		var label: Label = Label.new()
		label.text = (spec[0] as String).replace("_", " ")
		label.position = (spec[1] as Vector2) + Vector2(10, 40)
		label.add_theme_font_size_override("font_size", 22)
		label.visible = DisplayServer.is_touchscreen_available()
		layer.add_child(label)
	var back: Button = StageCLaunch.button("Menu", StageCLaunch.back_to_menu.bind(get_tree()))
	back.position = Vector2(1720, 16)
	back.custom_minimum_size = Vector2(170, 72)
	layer.add_child(back)


func _input(event: InputEvent) -> void:
	var device: String = _device_name(event)
	for a: String in ACTIONS:
		if event.is_action(a) and (event.is_action_pressed(a) or event is InputEventJoypadMotion and absf(event.get_action_strength(a)) > 0.5):
			var seen: PackedStringArray = _seen[a]
			if not seen.has(device):
				seen.append(device)
				_seen[a] = seen
			_last_device = device
	# Mouse aim reads the pointer (tooling thread note); touch aim is a drag.
	var mm: InputEventMouseMotion = event as InputEventMouseMotion
	if mm != null:
		aim_dir = (get_global_mouse_position() - hero.position - Vector2(0, -60)).normalized()
	var st: InputEventScreenTouch = event as InputEventScreenTouch
	if st != null and st.position.x > 960 and st.position.x < 1500:
		if st.pressed:
			_touch_aim_index = st.index
			_touch_aim_origin = st.position
		elif st.index == _touch_aim_index:
			_touch_aim_index = -1
	var sd: InputEventScreenDrag = event as InputEventScreenDrag
	if sd != null and sd.index == _touch_aim_index and sd.position.distance_to(_touch_aim_origin) > 20.0:
		aim_dir = (sd.position - _touch_aim_origin).normalized()
		_mark("aim", "touch")


func _mark(action: String, device: String) -> void:
	var seen: PackedStringArray = _seen[action]
	if not seen.has(device):
		seen.append(device)
		_seen[action] = seen


func _device_name(event: InputEvent) -> String:
	if event is InputEventKey:
		return "keyboard"
	if event is InputEventMouse:
		return "mouse"
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return "gamepad"
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return "touch"
	if event is InputEventAction:
		return "touch" # TouchScreenButton emits actions
	return event.get_class()


func _process(delta: float) -> void:
	var b: StageCBuilding = view.building
	var dir: float = Input.get_axis("move_left", "move_right")
	hero.position.x = clampf(hero.position.x + dir * SPEED * delta, b.level_left(level), b.level_right(level))
	if dir != 0.0:
		hero.flip_h = dir < 0.0
	var stick: Vector2 = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	if stick.length() > 0.3:
		aim_dir = stick.normalized()
	if Input.is_action_just_pressed("stairs_up"):
		_take_stairs(1)
	if Input.is_action_just_pressed("stairs_down"):
		_take_stairs(-1)
	if Input.is_action_just_pressed("fire"):
		_flash = 0.15
	_flash = maxf(0.0, _flash - delta)
	if Input.is_action_just_pressed("pause"):
		StageCLaunch.back_to_menu(get_tree())
		return
	var lines: PackedStringArray = ["C1 input check  ·  %s  ·  touchscreen %s  ·  joypads %s  ·  last device: %s" % [
		OS.get_name(), "yes" if DisplayServer.is_touchscreen_available() else "no", Input.get_connected_joypads().size(), _last_device]]
	for a: String in ACTIONS:
		var seen: PackedStringArray = _seen[a]
		lines.append("%s %-12s %s" % ["■" if not seen.is_empty() else "□", a, ", ".join(seen)])
	lines.append("Move along the floor, take a stairwell (stand near one), aim, fire. Pause returns to the menu.")
	_status.text = "\n".join(lines)
	_overlay.queue_redraw()


## Stairwells connect floors at fixed x positions; walk to one and press up
## or down to move to the floor it leads to.
func _take_stairs(step: int) -> void:
	var b: StageCBuilding = view.building
	for e: Vector2i in b.stair_edges:
		var lo: int = e.x
		var hi: int = e.y
		var from: int = lo if step > 0 else hi
		var to: int = hi if step > 0 else lo
		var p: Vector2 = b.astar.get_point_position(from)
		if b.node_level[from] == level and absf(p.x - hero.position.x) < STAIR_REACH:
			level = b.node_level[to]
			hero.position = b.astar.get_point_position(to)
			return


func _draw_overlay() -> void:
	var muzzle: Vector2 = hero.position + Vector2(0, -60)
	_overlay.draw_line(muzzle, muzzle + aim_dir * 140.0, Color(0.9, 0.9, 0.9, 0.5), 2.0)
	if _flash > 0.0:
		_overlay.draw_circle(muzzle + aim_dir * 150.0, 14.0, Color(1, 0.95, 0.8))
