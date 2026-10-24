class_name ToyActorLayer
extends Node2D
## Draws the player and the infected as rim-lit silhouettes (the rim shader is
## this node's material), plus a separate overlay node for their tells, hit
## flashes and aim, which must not be rim-shaded.

const SHAMBLER_TEX: Texture2D = preload("res://assets/art/toy/shambler.png")
const RUNNER_TEX: Texture2D = preload("res://assets/art/toy/runner.png")
const PLAYER_TEX: Texture2D = preload("res://assets/art/toy/protagonist.png")
## Silhouettes are drawn a little taller than their hit boxes.
const ART_SCALE: float = 1.25
const SQUASH_TIME: float = 0.12

var sim: FieldSim
var hit_flash: Dictionary[ToyEnemy, float] = {}
var player_flash: float = 0.0
## Landing squash (D14 greybox): set from the player's landing counter.
var _squash_left: float = 0.0
var _squash_amount: float = 0.0
var _seen_landings: int = 0


func _process(delta: float) -> void:
	for e: ToyEnemy in hit_flash.keys():
		hit_flash[e] = hit_flash[e] - delta
		if hit_flash[e] <= 0.0:
			hit_flash.erase(e)
	player_flash = maxf(0.0, player_flash - delta)
	_squash_left = maxf(0.0, _squash_left - delta)
	if sim != null and sim.player.landings != _seen_landings:
		_seen_landings = sim.player.landings
		_squash_amount = clampf(sim.player.last_land_speed / ToyPlayer.MAX_FALL_SPEED, 0.0, 1.0) * 0.25
		_squash_left = SQUASH_TIME
	queue_redraw()


func _draw() -> void:
	if sim == null:
		return
	for e: ToyEnemy in sim.enemies:
		if not e.is_alive():
			continue
		var tex: Texture2D = RUNNER_TEX if e.is_runner() else SHAMBLER_TEX
		var h: float = e.definition.height * ART_SCALE
		if e.wind_up_left >= 0.0:
			h *= 1.08
		var tint: Color = Color(1.0, 0.55, 0.45) if e.wind_up_left >= 0.0 else Color.WHITE
		if hit_flash.has(e):
			tint = Color(2.0, 2.0, 2.0)
		_draw_figure(tex, Vector2(e.x, -e.y), h, e.heading, tint)
	var p: ToyPlayer = sim.player
	if p.is_alive():
		var ptint: Color = Color(1.0, 0.4, 0.4) if player_flash > 0.0 else Color(0.85, 1.0, 0.9)
		# Squash on landing, stretch while moving fast up or down.
		var squash: float = _squash_amount * (_squash_left / SQUASH_TIME)
		var stretch: float = clampf(absf(p.vy) / ToyPlayer.MAX_FALL_SPEED, 0.0, 1.0) * 0.08 if not p.supported() else 0.0
		var sy: float = 1.0 - squash + stretch
		_draw_figure(PLAYER_TEX, Vector2(p.x, -p.y), ToyPlayer.HEIGHT * 1.2, p.facing, ptint, Vector2(1.0 / sy, sy))


func _draw_figure(tex: Texture2D, feet: Vector2, h: float, facing: int, tint: Color, scale: Vector2 = Vector2.ONE) -> void:
	var w: float = h * tex.get_width() / tex.get_height()
	draw_set_transform(feet, 0.0, Vector2(float(facing) * scale.x, scale.y))
	draw_texture_rect(tex, Rect2(-w * 0.5, -h, w, h), false, tint)
	draw_set_transform(Vector2.ZERO)
