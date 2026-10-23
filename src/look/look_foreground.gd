class_name LookForeground
extends Node2D
## In front of the play plane: fine monsoon rain, drifting mist motes, deodar
## boughs hanging into the top corners and short grass along the ground.
## Framing never enters the play lane, the band from the ground to the top of
## a high wall plus a jump (ART_AND_AUDIO_GUIDE section 3, rule 4).

const LANE_TOP: float = -330.0
const RAIN_HIGH: int = 420
const RAIN_LOW: int = 90
const MOTES: int = 40

var quality_high: bool = true
var _palette: LookPalette
var _rain: PackedVector2Array = []
var _motes: PackedVector2Array = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _boughs: Node2D
var _grass: Node2D
var _time: float = 0.0


func _ready() -> void:
	_rng.seed = 23
	for i: int in RAIN_HIGH:
		_rain.append(Vector2(_rng.randf_range(-200.0, 2400.0), _rng.randf_range(-1100.0, 160.0)))
	for i: int in MOTES:
		_motes.append(Vector2(_rng.randf_range(0.0, 2200.0), _rng.randf_range(-260.0, -10.0)))
	var shapes: Array[PackedVector2Array] = []
	# Boughs reach in from off screen at the top corners, well above the lane.
	for side: int in [-1, 1]:
		var root_x: float = 80.0 if side < 0 else 2120.0
		for k: int in 4:
			var y: float = -960.0 + k * 52.0 + _rng.randf_range(-10.0, 10.0)
			var reach: float = _rng.randf_range(160.0, 300.0) * (1.0 - k * 0.15)
			shapes.append(LookShapes.tier(root_x, y, reach * -side, 16.0, 26.0, _rng))
		shapes.append(PackedVector2Array([Vector2(root_x - 18.0, -1200.0), Vector2(root_x + 18.0, -1200.0), Vector2(root_x + 14.0, -760.0), Vector2(root_x - 14.0, -760.0)]))
	_boughs = _make_layer(shapes)
	var grass: Array[PackedVector2Array] = []
	var gx: float = -200.0
	while gx < 2400.0:
		# Short blades only: feet stay visible (rule 4).
		var gh: float = _rng.randf_range(3.0, 9.0)
		grass.append(PackedVector2Array([Vector2(gx, 2.0), Vector2(gx + 4.0, 2.0), Vector2(gx + 2.0 + _rng.randf_range(-3.0, 3.0), 2.0 - gh)]))
		gx += _rng.randf_range(4.0, 12.0)
	_grass = _make_layer(grass)


func apply(p: LookPalette, high: bool) -> void:
	_palette = p
	quality_high = high
	_boughs.self_modulate = p.plane
	_grass.self_modulate = p.plane


func _make_layer(shapes: Array[PackedVector2Array]) -> Node2D:
	var n: LookBackdrop.LookLayer = LookBackdrop.LookLayer.new()
	n.shapes = shapes
	add_child(n)
	return n


func _process(delta: float) -> void:
	_time += delta
	var count: int = _rain_count()
	for i: int in count:
		var p: Vector2 = _rain[i] + Vector2(-90.0, 900.0) * delta
		if p.y > 160.0:
			p = Vector2(_rng.randf_range(-200.0, 2500.0), _rng.randf_range(-1150.0, -1000.0))
		_rain[i] = p
	queue_redraw()


func _rain_count() -> int:
	if _palette == null:
		return 0
	var cap: int = RAIN_HIGH if quality_high else RAIN_LOW
	return int(cap * _palette.rain)


func _draw() -> void:
	if _palette == null:
		return
	var rc: Color = Color(_palette.fog.lightened(0.25), 0.22)
	for i: int in _rain_count():
		var p: Vector2 = _rain[i]
		draw_line(p, p + Vector2(-3.0, 22.0), rc, 1.0)
	if quality_high:
		var mc: Color = Color(_palette.fog.lightened(0.3), 0.12)
		for i: int in _motes.size():
			var m: Vector2 = _motes[i]
			var off: Vector2 = Vector2(sin(_time * 0.3 + i) * 30.0 + _time * 6.0, cos(_time * 0.21 + i * 1.7) * 12.0)
			var mp: Vector2 = Vector2(fposmod(m.x + off.x, 2200.0), m.y + off.y)
			draw_circle(mp, 1.6, mc)
