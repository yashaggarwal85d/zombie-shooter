extends Node2D
## EXPERIMENT C6 (Stage C): a 12-second scripted clip of the hook for the
## hook test GIF. A crowd heads for the chamber; the protagonist, behind them,
## fires and pulls them off her; he goes quiet and they turn back.
## Record it with Godot's movie maker (see c6_hook/README.md).

const CLIP_SECONDS: float = 12.0
const FIRE_FROM: float = 3.0
const FIRE_TO: float = 6.5
const SHOT_INTERVAL: float = 0.3

var view: StageCHouseView
var sim: StageCHordeSim
var sprites: Array[Sprite2D] = []
var player: Sprite2D
var flash: PointLight2D
var caption: Label
var muzzle: Polygon2D
var _t: float = 0.0
var _next_shot: float = FIRE_FROM


func _ready() -> void:
	view = StageCHouseView.new()
	add_child(view)
	sim = StageCHordeSim.new(0, 4)
	sim.scripted_noise = false
	var lvl: int = StageCBuilding.CHAMBER_LEVEL
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 21
	for i: int in 12:
		var a: StageCHordeSim.Agent = StageCHordeSim.Agent.new()
		a.kind = StageCHordeSim.AgentKind.RUNNER if i == 5 else StageCHordeSim.AgentKind.SHAMBLER
		a.level = lvl
		a.position = sim.building.floor_point(lvl, 1180.0 + i * 34.0 + rng.randf_range(-8.0, 8.0))
		a.stuck_anchor = a.position
		a.spread = rng.randf_range(-12.0, 12.0)
		a.replan_in = rng.randf() * 0.3
		sim.agents.append(a)
		var tex: Texture2D = StageCHouseView.RUNNER_TEX if a.kind == StageCHordeSim.AgentKind.RUNNER else StageCHouseView.SHAMBLER_TEX
		sprites.append(view.make_actor(tex))
	player = view.make_actor(StageCHouseView.PROTAGONIST_TEX)
	player.position = sim.building.floor_point(lvl, 1700.0)
	player.flip_h = true
	flash = PointLight2D.new()
	flash.texture = view.lights[0].texture
	flash.color = Color(0.95, 0.9, 0.8)
	flash.texture_scale = 2.0
	flash.shadow_enabled = true
	flash.position = player.position + Vector2(-50, -60)
	view.add_child(flash)
	muzzle = Polygon2D.new()
	var tip: Vector2 = player.position + Vector2(-64, -62)
	muzzle.polygon = PackedVector2Array([tip + Vector2(-30, 0), tip + Vector2(-4, -6), tip + Vector2(0, -14), tip + Vector2(4, -5), tip + Vector2(10, 0), tip + Vector2(4, 5), tip + Vector2(0, 14), tip + Vector2(-4, 6)])
	muzzle.color = Color(1.0, 0.96, 0.85)
	var unshaded: CanvasItemMaterial = CanvasItemMaterial.new()
	unshaded.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	muzzle.material = unshaded
	view.add_child(muzzle)
	var cam: Camera2D = Camera2D.new()
	cam.position = Vector2(1240, 560)
	cam.zoom = Vector2.ONE * 1.45
	add_child(cam)
	cam.make_current()
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	caption = Label.new()
	caption.position = Vector2(0, 960)
	caption.size = Vector2(1920, 80)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 46)
	caption.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95))
	layer.add_child(caption)


func _process(delta: float) -> void:
	_t += delta
	if _t >= FIRE_FROM and _t <= FIRE_TO and _t >= _next_shot:
		_next_shot += SHOT_INTERVAL
		sim.add_source(StageCNoise.Kind.SHOT, StageCBuilding.CHAMBER_LEVEL, player.position.x, 2.5, 1500.0, 0.35)
		flash.energy = 1.6
	flash.energy = maxf(0.0, flash.energy - delta * 9.0)
	flash.visible = flash.energy > 0.0
	muzzle.visible = flash.energy > 0.8
	sim.step(delta)
	for i: int in sprites.size():
		var a: StageCHordeSim.Agent = sim.agents[i]
		var s: Sprite2D = sprites[i]
		s.visible = a.state != StageCHordeSim.State.DEAD
		if not s.visible:
			a.respawn_in = 999.0 # no respawns in the clip
		s.position = a.position + Vector2(a.spread, 0.0)
		if a.path_index < a.path.size():
			s.flip_h = a.path[a.path_index].x < a.position.x
		s.rotation = 0.05 * sin(_t * (7.0 if a.kind == StageCHordeSim.AgentKind.RUNNER else 2.6) + i)
	if _t < 3.0:
		caption.text = "The machine keeping her alive hums."
	elif _t < 8.0:
		caption.text = "They go to the loudest thing in the house."
	else:
		caption.text = "Be louder. Or let the traps work."
	if _t >= CLIP_SECONDS and StageCLaunch.get_str("quit", "0") == "1":
		get_tree().quit()
