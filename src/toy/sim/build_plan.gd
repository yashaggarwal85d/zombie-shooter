class_name BuildPlan
extends RefCounted
## The build step before the night (D12): what stands on each build spot,
## within a scrap budget. Each spot cycles empty → fence → wall → high wall →
## high wall with ladder → empty. Spending is checked; refunds are automatic.

const LADDER_COST: int = 1

## One entry per spot option after "empty". A null structure means empty.
class Option:
	extends RefCounted
	var structure: StructureDefinition
	var ladder: bool

	func _init(p_structure: StructureDefinition, p_ladder: bool) -> void:
		structure = p_structure
		ladder = p_ladder

	func cost() -> int:
		if structure == null:
			return 0
		return structure.cost + (LADDER_COST if ladder else 0)

	func label() -> String:
		if structure == null:
			return "Empty"
		return structure.display_name + (" + ladder" if ladder else "")


var budget: int
var spot_xs: Array[float] = []
var options: Array[Option] = []
## Index into `options` for each spot; 0 is empty.
var choices: Array[int] = []


func _init(p_budget: int, p_spot_xs: Array[float], structures: Array[StructureDefinition]) -> void:
	budget = p_budget
	spot_xs = p_spot_xs
	options.append(Option.new(null, false))
	for s: StructureDefinition in structures:
		options.append(Option.new(s, false))
	if not structures.is_empty():
		options.append(Option.new(structures[structures.size() - 1], true))
	for i: int in spot_xs.size():
		choices.append(0)


func spent() -> int:
	var total: int = 0
	for c: int in choices:
		total += options[c].cost()
	return total


func remaining() -> int:
	return budget - spent()


func option_at(spot: int) -> Option:
	return options[choices[spot]]


## The option a spot would move to next: the next one that fits the budget,
## wrapping round to empty (which always fits).
func peek_cycle(spot: int) -> int:
	var held: int = options[choices[spot]].cost()
	var next: int = choices[spot]
	for i: int in options.size():
		next = (next + 1) % options.size()
		if options[next].cost() - held <= remaining():
			break
	return next


## Moves a spot to its next affordable option. Returns the new option index.
func cycle(spot: int) -> int:
	choices[spot] = peek_cycle(spot)
	return choices[spot]


func nearest_spot(px: float, max_distance: float) -> int:
	var best: int = -1
	var best_d: float = max_distance
	for i: int in spot_xs.size():
		var d: float = absf(spot_xs[i] - px)
		if d <= best_d:
			best = i
			best_d = d
	return best


## A short text description for the log, e.g. "L:fence,wall,- R:-,-,high+L".
func describe() -> String:
	var parts: PackedStringArray = []
	for i: int in choices.size():
		var o: Option = options[choices[i]]
		if o.structure == null:
			parts.append("-")
		else:
			parts.append(String(o.structure.id) + ("+ladder" if o.ladder else ""))
	return " ".join(parts)
