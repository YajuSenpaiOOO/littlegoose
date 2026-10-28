extends "res://scripts/art/local_lamp_shadow68.gd"
var slots69: Array[Dictionary]=[]

func _ready() -> void:
	name="VisibleWindowAndVolumeShadows69"
	sources=[{"tag":"左暖窗","light":world.time55.window_spill56,"pixel":Vector2(413.5,862.),"softness":2.1},{"tag":"右暖窗","light":world.time55.window_spill56,"pixel":Vector2(902.5,862.),"softness":2.1},{"tag":"路灯","light":world.woodland_life.lantern_light,"softness":1.3}]
	for i in 2:
		var shadow := preload("res://scripts/art/volume_actor_shadow69.gd").new()
		shadow.battle=world; shadow.visual=world.hero.visual; shadow.enabled=false
		world.hero.add_child(shadow)
		slots69.append({"shadow":shadow,"tag":"","weight":0.})
	projection=slots69[0].shadow

func anchor69(source: Dictionary) -> Vector3:
	return world._pixel_world(world.house_art,source.pixel) if source.has("pixel") else source.light.global_position

func score69(source: Dictionary) -> float:
	var light: OmniLight3D=source.light
	if not light.is_visible_in_tree() or light.light_energy<=.05: return 0.
	if source.has("pixel") and world.house_variant!=0: return 0.
	var at: Vector3=world.hero.global_position
	var anchor := anchor69(source)
	if source.has("pixel") and at.z<anchor.z-.15: return 0.
	var distance := Vector2(at.x-anchor.x,at.z-anchor.z).length()
	var influence := 1.-smoothstep(light.omni_range*.20,light.omni_range,distance)
	if influence<.005: return 0.
	var excludes: Array[RID]=[world.hero.get_rid()]
	if source.has("pixel"): excludes.append(world.cottage_body.get_rid())
	else: excludes.append(world.woodland_life.lantern_body.get_rid())
	var query := PhysicsRayQueryParameters3D.create(anchor,at+Vector3.UP*.75,2,excludes)
	if not get_world_3d().direct_space_state.intersect_ray(query).is_empty(): return 0.
	return influence*clampf(light.light_energy/2.4,0.,1.)*(.7 if source.has("pixel") else 1.)

func update_shadow(delta: float) -> void:
	scan_left-=delta
	if scan_left<=0.:
		scan_left=.1
		for source in sources: scores[source.tag]=score69(source)
	var ranked := sources.duplicate()
	ranked.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return float(scores.get(a.tag,0.))>float(scores.get(b.tag,0.)))
	if not ranked.is_empty() and float(scores.get(source_tag,0.))>=float(scores.get(ranked[0].tag,0.))*.88:
		for source in sources:
			if source.tag==source_tag: ranked.erase(source); ranked.push_front(source); break
	var desired: Dictionary={}
	var total := 0.
	for source in ranked:
		var score: float=scores.get(source.tag,0.)
		if score<.02 or desired.size()>=1: continue
		desired[source.tag]=source; total+=score
	for tag in desired:
		var bound := false
		for slot in slots69:
			if slot.tag==tag: bound=true
		if bound: continue
		for slot in slots69:
			if slot.weight<.005 and not desired.has(slot.tag): slot.tag=tag; break
	strength=0.
	source_tag=""
	var strongest := 0.
	for slot in slots69:
		var source: Dictionary={}
		for entry in sources:
			if entry.tag==slot.tag: source=entry; break
		var target: float=float(scores.get(slot.tag,0.))/maxf(1.,total)*(1.-world.porch49.daylight55) if enabled and desired.has(slot.tag) else 0.
		slot.weight=move_toward(slot.weight,target,delta*2.4)
		strength+=slot.weight
		var shadow: MeshInstance3D=slot.shadow
		shadow.enabled=enabled and world.silhouettes_enabled
		shadow.opacity_scale=slot.weight*.95
		if not source.is_empty():
			var at: Vector3=world.hero.global_position
			var anchor := anchor69(source)
			var height: float=maxf(1.5,anchor.y-world.floor_height(Vector2(at.x,at.z)))
			var away := (Vector2(at.x,at.z)-Vector2(anchor.x,anchor.z))/height
			away=away.limit_length(1.45)
			shadow.light_direction=Vector3(away.x,-1.,away.y)
			shadow.ink.set_shader_parameter("softness68",source.softness)
		if slot.weight>strongest: strongest=slot.weight; source_tag=slot.tag
	strength=minf(strength,1.)
	for moon in world.actor_shadows:
		if moon.get_parent()==world.hero:
			moon.ink.set_shader_parameter("opacity",.27*world.hero.visual.modulate.a*moon.opacity_scale*(1.-strength*.8))
			break

func _exit_tree() -> void:
	for slot in slots69:
		if is_instance_valid(slot.shadow): slot.shadow.queue_free()
