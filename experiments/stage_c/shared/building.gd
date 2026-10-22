class_name StageCBuilding
extends RefCounted
## EXPERIMENT (Stage C, C3/C4). Greybox cross-section: three floors plus a
## roof, the chamber on floor 1, two stairwells. Enemies walk floors and use
## stairs only, following an authored waypoint graph searched with AStar2D.

const LEVEL_COUNT: int = 4 # 0, 1, 2 = floors, 3 = roof
const LEVEL_Y: PackedFloat32Array = [890.0, 660.0, 430.0, 200.0]
const FLOOR_LEFT: float = 160.0
const FLOOR_RIGHT: float = 1760.0
const ROOF_LEFT: float = 760.0
const ROOF_RIGHT: float = 1560.0
const CHAMBER_LEVEL: int = 1
const CHAMBER_X: float = 960.0
## Stair runs: [bottom_x, top_x]. A spans floors 0-2, B spans floors 0-3
## (its top flight is the roof hatch).
const STAIR_A: Vector2 = Vector2(440.0, 560.0)
const STAIR_B: Vector2 = Vector2(1480.0, 1360.0)
const STAIR_A_LEVELS: int = 2
const STAIR_B_LEVELS: int = 3

var astar: AStar2D = AStar2D.new()
## Node ids per level, sorted by x.
var level_nodes: Array[PackedInt32Array] = []
## Each node's level.
var node_level: PackedInt32Array = PackedInt32Array()
## Entry points: Array of Dictionary {name, level, x}.
var entries: Array[Dictionary] = []
## Pairs of node ids that are stair flights (the only cross-level edges).
var stair_edges: Array[Vector2i] = []


func _init() -> void:
	for i: int in LEVEL_COUNT:
		level_nodes.append(PackedInt32Array())
	entries = [
		{"name": "F0 west window", "level": 0, "x": FLOOR_LEFT + 20.0},
		{"name": "F0 east window", "level": 0, "x": FLOOR_RIGHT - 20.0},
		{"name": "front door", "level": 0, "x": 1180.0},
		{"name": "F1 west window", "level": 1, "x": FLOOR_LEFT + 20.0},
		{"name": "F1 east window", "level": 1, "x": FLOOR_RIGHT - 20.0},
		{"name": "F2 west window", "level": 2, "x": FLOOR_LEFT + 20.0},
		{"name": "F2 east window", "level": 2, "x": FLOOR_RIGHT - 20.0},
		{"name": "roof edge", "level": 3, "x": ROOF_LEFT + 20.0},
	]
	_build_graph()


func _build_graph() -> void:
	var xs_per_level: Array[PackedFloat32Array] = []
	for i: int in LEVEL_COUNT:
		xs_per_level.append(PackedFloat32Array())
	for e: Dictionary in entries:
		xs_per_level[e["level"] as int].append(e["x"] as float)
	xs_per_level[CHAMBER_LEVEL].append(CHAMBER_X)
	for lvl: int in STAIR_A_LEVELS:
		xs_per_level[lvl].append(STAIR_A.x)
		xs_per_level[lvl + 1].append(STAIR_A.y)
	for lvl: int in STAIR_B_LEVELS:
		xs_per_level[lvl].append(STAIR_B.x)
		xs_per_level[lvl + 1].append(STAIR_B.y)
	# A few mid-floor nodes so the graph has the ~20-30 nodes Stage B budgets.
	for lvl: int in 3:
		xs_per_level[lvl].append(800.0)
		xs_per_level[lvl].append(1120.0)

	var next_id: int = 0
	for lvl: int in LEVEL_COUNT:
		var xs: PackedFloat32Array = xs_per_level[lvl]
		xs.sort()
		var ids: PackedInt32Array = PackedInt32Array()
		var last_x: float = -INF
		for x: float in xs:
			if absf(x - last_x) < 1.0:
				continue # duplicate x on one level
			astar.add_point(next_id, Vector2(x, LEVEL_Y[lvl]))
			node_level.append(lvl)
			ids.append(next_id)
			next_id += 1
			last_x = x
		level_nodes[lvl] = ids
		for i: int in range(1, ids.size()):
			astar.connect_points(ids[i - 1], ids[i])

	for lvl: int in STAIR_A_LEVELS:
		_connect_stair(lvl, STAIR_A)
	for lvl: int in STAIR_B_LEVELS:
		_connect_stair(lvl, STAIR_B)


func _connect_stair(lvl: int, run: Vector2) -> void:
	var a: int = node_at(lvl, run.x)
	var b: int = node_at(lvl + 1, run.y)
	assert(a >= 0 and b >= 0, "stair node missing")
	astar.connect_points(a, b)
	stair_edges.append(Vector2i(a, b))


func node_count() -> int:
	return astar.get_point_count()


func node_at(lvl: int, x: float) -> int:
	for id: int in level_nodes[lvl]:
		if absf(astar.get_point_position(id).x - x) < 1.0:
			return id
	return -1


func level_left(lvl: int) -> float:
	return ROOF_LEFT if lvl == 3 else FLOOR_LEFT


func level_right(lvl: int) -> float:
	return ROOF_RIGHT if lvl == 3 else FLOOR_RIGHT


func chamber_position() -> Vector2:
	return Vector2(CHAMBER_X, LEVEL_Y[CHAMBER_LEVEL])


func floor_point(lvl: int, x: float) -> Vector2:
	return Vector2(clampf(x, level_left(lvl), level_right(lvl)), LEVEL_Y[lvl])


## Ids of the nodes on `lvl` either side of `x` (one id if x is past an end).
func bracket(lvl: int, x: float) -> PackedInt32Array:
	var ids: PackedInt32Array = level_nodes[lvl]
	var out: PackedInt32Array = PackedInt32Array()
	for i: int in ids.size():
		var nx: float = astar.get_point_position(ids[i]).x
		if nx >= x:
			if i > 0:
				out.append(ids[i - 1])
			out.append(ids[i])
			return out
	out.append(ids[ids.size() - 1])
	return out


## Shortest walkable route from a point on one level to a point on another,
## as world positions (excluding `from`, including `to`). Same level walks
## straight because floors have no internal walls in this greybox.
func route(from_level: int, from: Vector2, to_level: int, to: Vector2) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	if from_level == to_level:
		out.append(to)
		return out
	var best_cost: float = INF
	var best: PackedVector2Array = PackedVector2Array()
	for s: int in bracket(from_level, from.x):
		for t: int in bracket(to_level, to.x):
			var path: PackedVector2Array = astar.get_point_path(s, t)
			if path.is_empty():
				continue
			var cost: float = from.distance_to(path[0]) + path[path.size() - 1].distance_to(to)
			for i: int in range(1, path.size()):
				cost += path[i - 1].distance_to(path[i])
			if cost < best_cost:
				best_cost = cost
				best = path
	if best.is_empty():
		return out # caller counts this as a path failure
	# Drop leading nodes that only walk along the start floor (walk straight to
	# the first stair instead) and trailing ones on the target floor.
	var first: int = 0
	while first + 1 < best.size() and is_equal_approx(best[first + 1].y, from.y):
		first += 1
	var last: int = best.size() - 1
	while last - 1 > first and is_equal_approx(best[last - 1].y, to.y):
		last -= 1
	for i: int in range(first, last + 1):
		out.append(best[i])
	out.append(to)
	return out


## True if `p` lies on a floor or on a stair flight (geometry sanity check).
func is_walkable(p: Vector2) -> bool:
	for lvl: int in LEVEL_COUNT:
		if absf(p.y - LEVEL_Y[lvl]) < 0.5 and p.x >= level_left(lvl) - 0.5 and p.x <= level_right(lvl) + 0.5:
			return true
	for e: Vector2i in stair_edges:
		var a: Vector2 = astar.get_point_position(e.x)
		var b: Vector2 = astar.get_point_position(e.y)
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(p, a, b)
		if closest.distance_to(p) < 0.5:
			return true
	return false
