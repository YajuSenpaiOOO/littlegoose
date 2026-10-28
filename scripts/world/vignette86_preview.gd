extends "res://scripts/world/station86_probe.gd"
func run() -> void:
 var sample := Sample86.new();root.add_child(sample)
 while not is_instance_valid(sample.station81): await physics_frame
 sample.hero.controls_enabled=false;sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample._teleport15(sample.meadow.landmarks.grove+Vector2(0,4.));await settle72(45)
 sample.label.get_parent().hide();sample.frames66.panel.hide()
 print("ART86_DEFAULTS noon=",sample.time55.noon_enabled85," vignette=",sample.time55.vignette_enabled86," strength=",sample.atmosphere41.focus_material.get_shader_parameter("vignette86"))
 var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/forest86_vignette_wider.png")
 sample.time55.vignette_enabled86=false;sample.time55.apply_look()
 frame=await snapshot();frame.save_png("res://docs/captures/world_restart/forest86_vignette_off.png")
 quit()
