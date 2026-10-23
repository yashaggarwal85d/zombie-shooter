class_name LookDirector
extends Node
## Runs the look test on top of the combat toy (D13 proposal). Picks the time
## of day from the toy's phase (day while building; dusk, night and dawn
## across the night's clock), blends the palettes, and pushes the colours to
## every layer. Keys: F5 look on/off (back to the greybox), F6 time of day
## (auto, day, dusk, night, dawn), F7 quality (high, low).

enum TimeMode { AUTO, DAY, DUSK, NIGHT, DAWN }

const DAY: LookPalette = preload("res://data/look/day.tres")
const DUSK: LookPalette = preload("res://data/look/dusk.tres")
const NIGHT: LookPalette = preload("res://data/look/night.tres")
const DAWN: LookPalette = preload("res://data/look/dawn.tres")
const RIM_SHADER: Shader = preload("res://src/look/look_rim.gdshader")
const MODE_NAMES: Array[String] = ["auto", "day", "dusk", "night", "dawn"]
const HINT_TIME: float = 8.0

@export var enabled: bool = true
@export var time_mode: TimeMode = TimeMode.AUTO

var quality_high: bool = true
## The palette in use this frame, for tests and the capture tool.
var current: LookPalette
var _toy: CombatToy
var _backdrop: LookBackdrop
var _field: LookFieldView
var _actors: ToyActorLayer
var _foreground: LookForeground
var _post: CanvasLayer
var _post_rect: ColorRect
var _hint: Label
var _hint_left: float = HINT_TIME
var _greybox_material: Material
var _rim_material: ShaderMaterial


func _ready() -> void:
	_toy = get_parent() as CombatToy
	_backdrop = _toy.get_node(^"Backdrop") as LookBackdrop
	_field = _toy.get_node(^"FieldView") as LookFieldView
	_actors = _toy.get_node(^"Actors") as ToyActorLayer
	_foreground = _toy.get_node(^"Foreground") as LookForeground
	_post = _toy.get_node(^"PostLayer") as CanvasLayer
	_post_rect = _post.get_node(^"Post") as ColorRect
	_hint = _toy.get_node(^"LookHintLayer/Hint") as Label
	_greybox_material = _actors.material
	_rim_material = ShaderMaterial.new()
	_rim_material.shader = RIM_SHADER
	quality_high = not OS.has_feature("mobile")
	_set_enabled(enabled)


func _unhandled_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_F5:
			_set_enabled(not enabled)
		KEY_F6:
			time_mode = ((time_mode + 1) % TimeMode.size()) as TimeMode
		KEY_F7:
			quality_high = not quality_high
		_:
			return
	_hint_left = HINT_TIME


func _set_enabled(on: bool) -> void:
	enabled = on
	_backdrop.visible = on
	_foreground.visible = on
	_post.visible = on
	_field.look_on = on
	_actors.material = _rim_material if on else _greybox_material


func _process(delta: float) -> void:
	_hint_left = maxf(0.0, _hint_left - delta)
	_hint.text = "F5 look: %s   F6 time: %s   F7 quality: %s" % ["on" if enabled else "greybox", MODE_NAMES[time_mode], "high" if quality_high else "low"]
	_hint.modulate.a = clampf(_hint_left, 0.0, 1.0)
	if not enabled:
		return
	current = palette_now()
	var pod_glow: float = _pod_glow()
	_field.look = current
	_field.pod_light = current.pod_strength
	_backdrop.apply(current, quality_high, _field.pod_window(), pod_glow)
	_foreground.apply(current, quality_high)
	_rim_material.set_shader_parameter(&"body_color", current.plane)
	_rim_material.set_shader_parameter(&"key_color", current.key_rim)
	_rim_material.set_shader_parameter(&"pod_color", _field.palette.pod_light)
	_rim_material.set_shader_parameter(&"pod_strength", pod_glow)
	_rim_material.set_shader_parameter(&"pod_uv", _to_screen_uv(_field.pod_window()))
	var m: ShaderMaterial = _post_rect.material as ShaderMaterial
	m.set_shader_parameter(&"shadow_tint", current.grade_shadow)
	m.set_shader_parameter(&"vignette", current.vignette)
	m.set_shader_parameter(&"grain", 0.035 if quality_high else 0.0)


func _pod_glow() -> float:
	return _field.pod_glow()


## The palette for this moment: fixed if F6 picked a time, otherwise from
## the toy's phase and the night's clock.
func palette_now() -> LookPalette:
	match time_mode:
		TimeMode.DAY:
			return DAY
		TimeMode.DUSK:
			return DUSK
		TimeMode.NIGHT:
			return NIGHT
		TimeMode.DAWN:
			return DAWN
	if _toy.phase == CombatToy.Phase.BUILD or _toy.sim == null:
		return DAY
	return palette_at(_toy.sim.elapsed / _toy.sim.night.duration)


## Dusk at the start of the night, full night through the middle, and the
## first grey of dawn in the last fifth: the sky is a second clock.
static func palette_at(k: float) -> LookPalette:
	if k < 0.06:
		return DUSK
	if k < 0.2:
		return LookPalette.blend(DUSK, NIGHT, smoothstep(0.06, 0.2, k))
	if k < 0.82:
		return NIGHT
	return LookPalette.blend(NIGHT, DAWN, smoothstep(0.82, 1.0, k) * 0.8)


func _to_screen_uv(world: Vector2) -> Vector2:
	var vp: Viewport = _toy.get_viewport()
	var screen: Vector2 = vp.get_canvas_transform() * world
	return screen / vp.get_visible_rect().size
