extends GutTest
## The build step (D12).

var plan: BuildPlan


func before_each() -> void:
	plan = ToyContent.new_plan(8)


func test_three_spots_each_side() -> void:
	assert_eq(plan.spot_xs.size(), 6)
	var left: int = 0
	for x: float in plan.spot_xs:
		if x < FieldSim.SHELTER_X:
			left += 1
	assert_eq(left, 3)


func test_cycle_order_and_costs() -> void:
	var labels: PackedStringArray = []
	var costs: Array[int] = []
	for i: int in 5:
		plan.cycle(0)
		labels.append(plan.option_at(0).label())
		costs.append(plan.option_at(0).cost())
	assert_eq(labels, PackedStringArray(["Fence", "Wall", "High wall", "High wall + ladder", "Empty"]))
	assert_eq(costs, [1, 2, 3, 4, 0])


func test_refunds_when_cycling_back_to_empty() -> void:
	for i: int in 5:
		plan.cycle(0)
	assert_eq(plan.remaining(), 8)


func test_cannot_spend_past_the_budget() -> void:
	plan = ToyContent.new_plan(3)
	plan.cycle(0) # fence 1
	plan.cycle(0) # wall 2
	plan.cycle(1) # fence 1 -> 3 spent
	assert_eq(plan.remaining(), 0)
	plan.cycle(0) # high wall would be 3 + fence 1 = 4 > 3: skips to empty
	assert_eq(plan.option_at(0).structure, null)
	assert_eq(plan.remaining(), 2)


func test_plan_builds_the_field() -> void:
	plan.cycle(0)
	plan.cycle(5)
	plan.cycle(5)
	plan.cycle(5)
	plan.cycle(5) # high wall + ladder
	var sim: FieldSim = ToyContent.new_field(ToyContent.night(), plan)
	assert_eq(sim.structures.size(), 3, "shelter + 2")
	var hw: ToyStructure = sim.structures[2]
	assert_eq(hw.definition.id, &"high_wall")
	assert_true(hw.has_ladder)
	assert_eq(sim.telemetry.layout, plan.describe())


func test_nearest_spot() -> void:
	assert_eq(plan.nearest_spot(plan.spot_xs[2] + 20.0, 60.0), 2)
	assert_eq(plan.nearest_spot(FieldSim.SHELTER_X, 60.0), -1)
