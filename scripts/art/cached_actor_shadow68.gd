extends "res://scripts/combat/actor_shadow25.gd"
var last_pose68: Array=[]
var last_build68 := -1000000
var rebuilds68 := 0

func _ready() -> void:
	super._ready()
	name="NearbyLampActorShadow68"
	ink.shader=preload("res://scripts/art/lamp_actor_shadow68.gdshader")

func _physics_process(delta: float) -> void:
	visible=enabled and opacity_scale>.001 and is_instance_valid(visual) and visual.is_visible_in_tree() and battle.contact_enabled
	if not visible: return
	ink.set_shader_parameter("opacity",.27*visual.modulate.a*opacity_scale)
	ink.set_shader_parameter("flipped",visual.flip_h)
	var pose := [visual.texture,visual.global_transform,visual.offset,visual.pixel_size,light_direction]
	if pose==last_pose68: return
	var now := Time.get_ticks_usec()
	if visual.texture==last_texture and now-last_build68<50000 and not last_pose68.is_empty() and visual.global_position.distance_to(last_pose68[1].origin)<2.: return
	super._physics_process(delta)
	last_pose68=pose
	last_build68=now
	rebuilds68+=1
