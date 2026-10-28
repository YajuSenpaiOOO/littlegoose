extends "res://scripts/world/world_time56.gd"
var accents57: Node3D
var cottage_emitter57: Node
var lantern_emitter57: Node
var haze_enabled57 := true
var freeze_sun57 := false
var pose_updates57 := 0
var last_pose57 := Vector3(INF,INF,INF)
var last_opacity57 := -1.

func _day_palette() -> Resource:
	return preload("res://assets/lighting55/woodland_day57.tres")

func _ready() -> void:
	super._ready()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day57.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	accents57=_accents_script().new()
	accents57.world=world
	add_child(accents57)
	cottage_emitter57=accents57.emitter(preload("res://assets/lighting55/cottage57.tres"),window_spill56,world.porch49.house_material,&"window_emission55")
	var life: Node3D=world.woodland_life
	lantern_emitter57=accents57.emitter(preload("res://assets/lighting55/lantern57.tres"),life.lantern_light,life.lantern_root.get_child(0).material_override,&"glass_energy55")
	apply_look()
	update_guide()
	print("WORLD57_DUSK_HANDOFF_FIREFLIES_AND_STAGE_READY")

func _accents_script() -> Script:
	return preload("res://scripts/art/night_accents57.gd")

func _apply_sun_pose(look: Dictionary) -> void:
	if freeze_sun57: return
	var pose := Vector3(-look.elevation56,look.azimuth56,0.)
	if not last_pose57.is_finite() or pose.distance_to(last_pose57)>=.06:
		world.sun.rotation_degrees=pose
		last_pose57=pose
		pose_updates57+=1
	if absf(float(look.shadow_opacity56)-last_opacity57)>.001 or (float(look.shadow_opacity56)==0. and last_opacity57!=0.):
		world.sun.shadow_opacity=look.shadow_opacity56
		last_opacity57=look.shadow_opacity56

func apply_look() -> void:
	super.apply_look()
	var look: Dictionary=palette.sample(visual_hour)
	var night := 1.-float(look.daylight)
	for shadow in world.actor_shadows:
		if is_instance_valid(shadow): shadow.opacity_scale=float(look.shadow_opacity56)*lerpf(1.,.4,night)
	var focus: ShaderMaterial=world.atmosphere41.focus_material
	focus.set_shader_parameter("haze_strength57",lerpf(.035,.085,night) if haze_enabled57 else 0.)
	focus.set_shader_parameter("haze_color57",Vector3(.40,.54,.76).lerp(Vector3(.24,.37,.63),night))
	if not is_instance_valid(accents57): return
	accents57.set_strength(smoothstep(18.8,20.8,visual_hour))
	cottage_emitter57.set_level(night,look.lamps,world.house_art.visible)
	lantern_emitter57.set_level(look.lamps,look.lamps,world.woodland_life.lantern_enabled)
	world.porch49.stage_strength57=accents57.strength if accents57.stage_enabled else 0.
	world.porch49._update_actor()
	accents57.update_accents(0.)

func update_guide() -> void:
	super.update_guide()
	if not is_instance_valid(accents57): return
	guide.text+="\nAlt+F 萤火虫%s · Alt+L 舞台光%s\nAlt+H 远景柔化%s"%["开" if accents57.fireflies_enabled else "关","开" if accents57.stage_enabled else "关","开" if haze_enabled57 else "关"]

func handle_input(event: InputEvent) -> bool:
	if sleeping: return super.handle_input(event)
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and is_instance_valid(accents57):
		match event.physical_keycode:
			KEY_F: accents57.fireflies_enabled=not accents57.fireflies_enabled
			KEY_L: accents57.stage_enabled=not accents57.stage_enabled
			KEY_H: haze_enabled57=not haze_enabled57
			_: return super.handle_input(event)
		apply_look()
		update_guide()
		return true
	return super.handle_input(event)
