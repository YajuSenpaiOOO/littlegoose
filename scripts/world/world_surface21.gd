extends "res://scripts/world/world_surface20.gd"
## Return to the original woodland floor. Future rise should include its forest belt.
func _init() -> void:
	super._init()
	terrace_enabled = false
	for entry in named_routes:
		if entry.name!="junction_to_grove": continue
		for source in plan.routes:
			if source.name!=entry.name: continue
			var controls := PackedVector2Array()
			for p in source.points: controls.append(from_plan(Vector2(p[0],p[1])))
			controls[0] = landmarks.junction-Vector2(RING_RADIUS,0)
			entry.controls = controls
			entry.points = _smooth(controls)
	_reindex_routes()
