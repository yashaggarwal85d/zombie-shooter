extends SceneTree
## EXPERIMENT C4 soak (Stage C). Runs the horde sim for a simulated duration
## at a fixed 60 Hz step, as fast as the CPU allows, and reports pass/fail.
## Run:
##   godot --headless --path experiments/stage_c --script res://c4_pathing/soak.gd -- --agents=60 --minutes=10
## Pass (Stage B 11, C4): no stuck agents, no path failures, every agent stays
## on floors or stairs, and the logic costs under 2 ms a frame.

const STEP: float = 1.0 / 60.0
const BUDGET_MS: float = 2.0


func _init() -> void:
	var args: Dictionary = _parse_args()
	var agent_count: int = int(args.get("agents", "60"))
	var minutes: float = float(args.get("minutes", "10"))
	var seed_value: int = int(args.get("seed", "1"))
	var validate: bool = args.get("validate", "1") == "1"
	var sim: StageCHordeSim = StageCHordeSim.new(agent_count, seed_value)
	sim.validate_geometry = validate
	var steps: int = int(minutes * 60.0 / STEP)
	var times: PackedFloat32Array = PackedFloat32Array()
	times.resize(steps)
	for i: int in steps:
		var t0: int = Time.get_ticks_usec()
		sim.step(STEP)
		times[i] = float(Time.get_ticks_usec() - t0) / 1000.0
	var sorted: PackedFloat32Array = times.duplicate()
	sorted.sort()
	var total: float = 0.0
	for t: float in times:
		total += t
	var mean: float = total / steps
	var p99: float = sorted[int(steps * 0.99)]
	var worst: float = sorted[steps - 1]
	var by_kind: Array[String] = []
	for k: int in sim.targets_by_kind:
		by_kind.append("%s=%d" % [StageCNoise.Kind.keys()[k], sim.targets_by_kind[k]])
	print("C4 soak: %d agents, %.1f simulated minutes, seed %d, geometry check %s" % [agent_count, minutes, seed_value, "on" if validate else "off"])
	print("  logic ms/frame: mean %.3f, p99 %.3f, worst %.3f (budget %.1f)" % [mean, p99, worst, BUDGET_MS])
	print("  chamber hits %d, other arrivals %d, replans %d, switches %d, target picks: %s" % [sim.chamber_hits, sim.other_arrivals, sim.replans, sim.target_switches, ", ".join(by_kind)])
	print("  stuck %d, path failures %d, off-geometry %d, nothing-heard fallbacks %d, reversals %d (%.2f per agent-minute)" % [sim.stuck_events, sim.path_failures, sim.off_geometry, sim.unheard_fallbacks, sim.reversals, sim.reversals / maxf(1.0, agent_count * minutes)])
	for line: String in sim.stuck_log:
		print("    stuck: " + line)
	var ok: bool = sim.stuck_events == 0 and sim.path_failures == 0 and sim.off_geometry == 0 and p99 < BUDGET_MS
	print("  RESULT: %s" % ("PASS" if ok else "FAIL"))
	quit(0 if ok else 1)


func _parse_args() -> Dictionary:
	var out: Dictionary = {}
	for a: String in OS.get_cmdline_user_args():
		if a.begins_with("--") and a.contains("="):
			var kv: PackedStringArray = a.substr(2).split("=", true, 1)
			out[kv[0]] = kv[1]
	return out
