class_name LookShapes
extends RefCounted
## Procedural silhouettes for the look test: deodar cedars, ridge lines and
## forested ridge edges. All shapes are built once, in white, and coloured
## by the layer's modulate, so a change of time of day costs nothing.
## Screen up is -y; the ground line is y = 0.


## A deodar: a tapered trunk, flat drooping tiers that shorten toward the
## top, and a leader that bends over at the tip. Returns one polygon per part.
static func deodar(x: float, base_y: float, h: float, rng: RandomNumberGenerator) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var trunk_w: float = maxf(2.0, h * 0.02)
	out.append(PackedVector2Array([
		Vector2(x - trunk_w, base_y), Vector2(x + trunk_w, base_y),
		Vector2(x + trunk_w * 0.3, base_y - h * 0.9), Vector2(x - trunk_w * 0.3, base_y - h * 0.9)]))
	var tiers: int = rng.randi_range(7, 10)
	var spread: float = h * rng.randf_range(0.34, 0.46)
	for i: int in tiers:
		var k: float = float(i) / float(tiers - 1)
		var y: float = base_y - h * lerpf(0.16, 0.88, k) + rng.randf_range(-1.0, 1.0) * h * 0.012
		var reach: float = spread * lerpf(1.0, 0.16, pow(k, 0.8)) * rng.randf_range(0.85, 1.12)
		var thick: float = h * lerpf(0.075, 0.04, k) * rng.randf_range(0.85, 1.2)
		var droop: float = thick * rng.randf_range(0.9, 1.6)
		for side: int in [-1, 1]:
			# One side often reaches further, as wind-shaped trees do.
			var r: float = reach * rng.randf_range(0.7, 1.1)
			out.append(tier(x, y, r * side, thick, droop, rng))
	# The leader nods over at the top, the deodar's tell.
	var nod: float = (1.0 if rng.randf() < 0.5 else -1.0) * h * 0.012
	out.append(PackedVector2Array([
		Vector2(x - trunk_w * 0.5, base_y - h * 0.86), Vector2(x + trunk_w * 0.5, base_y - h * 0.86),
		Vector2(x + 1.0, base_y - h * 0.97), Vector2(x - 1.0, base_y - h * 0.97)]))
	out.append(PackedVector2Array([Vector2(x - 1.0, base_y - h * 0.95), Vector2(x + 1.0, base_y - h * 0.975), Vector2(x + nod, base_y - h * 0.945)]))
	return out


## One flat tier reaching `reach` sideways (negative is left): a gently domed
## top, a scalloped underside, and a tip that droops.
static func tier(x: float, y: float, reach: float, thick: float, droop: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var steps: int = 9
	var top: PackedVector2Array = []
	var bottom: PackedVector2Array = []
	var scallops: float = rng.randf_range(1.5, 3.0)
	for s: int in steps + 1:
		var t: float = float(s) / steps
		var px: float = x + reach * t
		var sag: float = droop * t * t
		var ty: float = y - thick * (1.0 - t * t) * (0.6 + 0.4 * sin(t * PI)) + sag + rng.randf_range(-1.0, 1.0) * thick * 0.08
		var lump: float = absf(sin(t * PI * scallops)) * thick * 0.22
		var by: float = y + thick * 0.25 * (1.0 - t) + sag + lump
		if s == steps:
			ty = y + sag + thick * 0.15
			by = ty
		top.append(Vector2(px, ty))
		bottom.append(Vector2(px, maxf(by, ty)))
	bottom.reverse()
	top.append_array(bottom)
	return top


## A ridge from x0 to x1: `noise` sets the rise above `base_y`, `sharp` turns
## rolling hills into peaks. The polygon is closed down to `floor_y`.
static func ridge(x0: float, x1: float, base_y: float, amp: float, floor_y: float, noise: FastNoiseLite, sharp: float = 0.0, step: float = 10.0) -> PackedVector2Array:
	var pts: PackedVector2Array = ridge_line(x0, x1, base_y, amp, noise, sharp, step)
	pts.append(Vector2(x1, floor_y))
	pts.append(Vector2(x0, floor_y))
	return pts


static func ridge_line(x0: float, x1: float, base_y: float, amp: float, noise: FastNoiseLite, sharp: float = 0.0, step: float = 10.0) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	var x: float = x0
	while x <= x1 + 0.1:
		var n: float = noise.get_noise_1d(x) * 0.5 + 0.5
		if sharp > 0.0:
			# Fold the noise so crests become peaks.
			var folded: float = 1.0 - absf(noise.get_noise_1d(x * 0.7 + 300.0))
			n = lerpf(n, folded * folded, sharp)
		pts.append(Vector2(x, base_y - n * amp))
		x += step
	return pts


## Small trees along a ridge line, so a far ridge reads as forest.
static func tree_fringe(line: PackedVector2Array, size: float, rng: RandomNumberGenerator) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var i: int = 0
	while i < line.size():
		var p: Vector2 = line[i]
		var h: float = size * rng.randf_range(0.6, 1.4)
		var w: float = h * rng.randf_range(0.35, 0.5)
		out.append(PackedVector2Array([Vector2(p.x - w, p.y + 4.0), Vector2(p.x + w, p.y + 4.0), Vector2(p.x + rng.randf_range(-1.5, 1.5), p.y - h)]))
		i += rng.randi_range(1, 2)
	return out


## Snow on the peaks: the part of each ridge point above `line_y`, as thin
## caps hugging the crest, with ragged lower edges.
static func snow_caps(line: PackedVector2Array, line_y: float, rng: RandomNumberGenerator) -> Array[PackedVector2Array]:
	var out: Array[PackedVector2Array] = []
	var run: PackedVector2Array = []
	for p: Vector2 in line:
		if p.y < line_y:
			run.append(p)
		elif run.size() > 2:
			out.append(_cap(run, line_y, rng))
			run = []
		else:
			run = []
	if run.size() > 2:
		out.append(_cap(run, line_y, rng))
	return out


static func _cap(run: PackedVector2Array, line_y: float, rng: RandomNumberGenerator) -> PackedVector2Array:
	var poly: PackedVector2Array = run.duplicate()
	# The snow line wanders smoothly: gullies run down, ribs stay bare.
	var phase: float = rng.randf_range(0.0, TAU)
	for i: int in range(run.size() - 1, -1, -1):
		var p: Vector2 = run[i]
		var wander: float = 0.55 + 0.25 * sin(p.x * 0.031 + phase) + 0.12 * sin(p.x * 0.093 + phase * 2.0)
		var depth: float = (line_y - p.y) * wander
		poly.append(Vector2(p.x, minf(p.y + depth, line_y)))
	return poly
