extends "res://scripts/world/world_time87.gd"
func update_guide() -> void:
	super.update_guide()
	if is_instance_valid(guide): guide.text+="\n89：Ctrl+Alt+J 材质/景深[%s]"%["新版" if world.look_enabled89 else "88原版"]

func apply_look() -> void:
	super.apply_look()
	if not effects_ready86: return
	var radius := 2.5 if world.look_enabled89 else 6.2
	world.atmosphere41.focus_material.set_shader_parameter("radius_pixels",0. if focus_mode86==2 else radius)
