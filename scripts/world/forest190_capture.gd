extends "res://scripts/world/forest180_probe.gd"
var sample: Node3D
func picture190(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest190_"+tag+".png")
func hour190(hour: float) -> void:
 sample.time55.preview_at(hour);sample.time55.visual_hour=hour;sample.time55.apply_look();await settle(70)
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=preload("res://scripts/world/woodland_world190.gd").new();sample.memory_save116="user://forest190_validation_tmp.cfg";root.add_child(sample)
 while not sample.forest_ready188: await physics_frame
 sample.hero.controls_enabled=false;sample.hero.facing="down";sample.hero.render_pose()
 var focus: ShaderMaterial=sample.atmosphere41.focus_material
 verify(sample.hero.visual.shaded,"hero receives native scene lights")
 verify(not focus.shader.code.contains("actor_mask57*actor_stage57*.48") and not focus.shader.code.contains("actor186*.45"),"both screen actor exemptions removed")
 verify(focus.shader.code.contains("if(false && cone_strength58>0."),"screen cone veil disabled while native spotlight remains")
 verify(focus.shader.code.contains("emitter_mask190(SCREEN_UV,distance)*.94") and not focus.shader.code.contains("warm186*.92"),"warm protection uses registered emitters only")
 sample._teleport15(Vector2(-55.,17.));await hour190(7.5);await picture190("cottage_morning")
 var a: Color=sample.porch49.sample_field(Vector2(-55.,18.37333))
 var b: Color=sample.porch49.sample_field(Vector2(-55.,18.39333))
 verify(absf(a.a-b.a)<.002,"CPU actor field has no jump at old south atlas boundary")
 await hour190(18.);await picture190("cottage_dusk")
 await hour190(22.);await picture190("cottage_night")
 verify(not sample.porch49.fill_enabled and not sample.porch49.warm_light.visible,"old body-following fill stays disabled at night")
 verify(sample.time55.accents57.stage_light.visible,"native theatre spotlight remains available at night")
 verify(int(focus.get_shader_parameter("emitter_count190"))>=10,"forest lamp cores and house windows registered")
 sample._teleport15(Vector2(-44.,27.));await settle(80);await picture190("central_night")
 await hour190(12.);await picture190("central_noon")
 sample._teleport15(Vector2(-4.7,-2.6));await hour190(22.);await picture190("home_night")
 verify(sample.forest188.flowers189.size()==11 and is_instance_valid(sample.forest188.hammock_cat189),"reactive flowers and hammock cat retained")
 FileAccess.open("res://docs/forest190-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures}," "))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));print("FOREST190_DONE ",failures);quit(0 if failures.is_empty() else 1)
