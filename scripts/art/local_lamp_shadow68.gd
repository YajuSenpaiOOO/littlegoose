extends Node3D
## One nearby lamp silhouette for the hero; no new native shadow maps or lights.
var world: Node3D
var enabled := true
var strength := 0.
var source_tag := ""
var source_light: OmniLight3D
var scan_left := 0.
var sources: Array[Dictionary]=[]
var scores: Dictionary={}
var projection: MeshInstance3D
var moon_material: ShaderMaterial

func _ready() -> void:
	name="NearbyWarmLightShadow68"
	sources=[{"tag":"小屋暖窗","light":world.time55.window_spill56,"softness":2.1},{"tag":"路灯","light":world.woodland_life.lantern_light,"softness":1.3}]
	projection=preload("res://scripts/art/cached_actor_shadow68.gd").new()
	projection.battle=world; projection.visual=world.hero.visual
	projection.enabled=false
	world.hero.add_child(projection)
	for shadow in world.actor_shadows:
		if shadow.get_parent()==world.hero: moon_material=shadow.ink; break

func _score(light: OmniLight3D) -> float:
	if not light.is_visible_in_tree() or light.light_energy<=.05: return 0.
	var actor: Vector3=world.hero.global_position
	var distance := Vector2(actor.x-light.global_position.x,actor.z-light.global_position.z).length()
	var influence := 1.-smoothstep(light.omni_range*.25,light.omni_range,distance)
	if influence<=.005: return 0.
	var ray := PhysicsRayQueryParameters3D.create(light.global_position,actor+Vector3.UP*.75,2,[world.hero.get_rid()])
	if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty(): return 0.
	return influence*clampf(light.light_energy/2.4,0.,1.)

func update_shadow(delta: float) -> void:
	scan_left-=delta
	if scan_left<=0.:
		scan_left=.1
		for source in sources: scores[source.tag]=_score(source.light)
	var best := ""
	var best_score := .005
	for source in sources:
		var score: float=scores.get(source.tag,0.)
		if score>best_score: best=source.tag; best_score=score
	var previous_score: float=scores.get(source_tag,0.)
	if previous_score>best_score*.72: best=source_tag; best_score=previous_score
	# Fade out before changing source, rather than swinging a shadow across the floor.
	if best!=source_tag and strength<.015:
		source_tag=best
		source_light=null
		for source in sources:
			if source.tag==source_tag:
				source_light=source.light
				projection.ink.set_shader_parameter("softness68",source.softness)
	var night: float=1.-world.porch49.daylight55
	var target: float=best_score*night if enabled and best==source_tag and is_instance_valid(source_light) else 0.
	strength=move_toward(strength,target,delta*2.8)
	projection.enabled=enabled and world.silhouettes_enabled
	projection.opacity_scale=strength*.95
	if is_instance_valid(source_light):
		var at: Vector3=world.hero.global_position
		var height: float=maxf(1.5,source_light.global_position.y-world.floor_height(Vector2(at.x,at.z)))
		var away := Vector2(at.x-source_light.global_position.x,at.z-source_light.global_position.z)/height
		away=away.limit_length(1.45)
		projection.light_direction=Vector3(away.x,-1.,away.y)
	# The existing weak moon shadow yields to the nearby warm light.
	if is_instance_valid(moon_material):
		for shadow in world.actor_shadows:
			if shadow.get_parent()==world.hero:
				moon_material.set_shader_parameter("opacity",.27*world.hero.visual.modulate.a*shadow.opacity_scale*(1.-strength*.8))
				break

func _process(delta: float) -> void:
	update_shadow(delta)

func _exit_tree() -> void:
	if is_instance_valid(projection): projection.queue_free()
