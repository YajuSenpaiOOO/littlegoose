extends RefCounted
## Fake top-down height projection, sharing actual light visibility and energy.
static func evaluate(at: Vector2,sources: Array[Dictionary],height: float,max_length: float) -> Dictionary:
	var total := 0.0
	var direction_sum := Vector2.ZERO
	for source: Dictionary in sources:
		if not source.get("casts_actor_shadows",true): continue
		var light: PointLight2D = source.light
		if not light.enabled or not light.is_visible_in_tree() or light.energy<=0: continue
		var radius: Vector2 = source.radius
		var distance := ((at-light.global_position)/radius).length()
		if distance>=1: continue
		var weight := light.energy*pow(1-distance,1.3)
		var ground: Vector2 = source.anchor.to_global(source.ground_offset)
		var away := at-ground
		var length := minf(max_length,away.length()*height/maxf(8,source.height-height))
		direction_sum += away.normalized()*length*weight
		total += weight
	return {"vector":direction_sum/total if total>0.0001 else Vector2.ZERO,"opacity":clampf(total*0.90,0,0.30)}
