extends SceneTree
var sample: Node3D
func _initialize() -> void: run.call_deferred()
func settle(count: int) -> void:
 for i in count: await physics_frame
func shot(tag: String) -> void:
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/captures/world_restart/forest189_lightdiag_"+tag+".png")
func run() -> void:
 root.size=Vector2i(1600,1000)
 sample=preload("res://scripts/world/woodland_world189.gd").new();sample.memory_save116="user://forest189_diagnostic_tmp.cfg";root.add_child(sample)
 while not sample.forest_ready188: await physics_frame
 sample._teleport15(Vector2(-55.,17.));sample.hero.controls_enabled=false;sample.hero.facing="down";sample.hero.render_pose()
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await settle(90)
 sample.time55.set_process(false);sample.time55.accents57.set_process(false)
 var material: ShaderMaterial=sample.atmosphere41.focus_material
 var snapshot := {"fill_enabled":sample.porch49.fill_enabled,"fill_light_visible":sample.porch49.warm_light.visible,"hero_modulate":str(sample.hero.visual.modulate),"hero_shaded":sample.hero.visual.shaded,"spot_visible":sample.time55.accents57.stage_light.visible,"spot_position":str(sample.time55.accents57.stage_light.global_position)}
 for key in ["actor_stage57","stage_center57","stage_radius57","stage_depth57","cone_strength58","cone_bounds58","cone_top58","cone_bottom58","forest_strength186","night_mix56"]: snapshot[key]=str(material.get_shader_parameter(key))
 await shot("night_baseline")
 material.set_shader_parameter("cone_strength58",0.);await settle(3);await shot("night_no_cone")
 material.set_shader_parameter("actor_stage57",0.);sample.forest_mood188.set_process(false)
 var original_code: String=material.shader.code
 var shader := Shader.new();shader.code=original_code.replace("float actor186=smoothstep(.10,.88,actor_mask57);","float actor186=0.;")
 material.shader=shader
 await settle(3);await shot("night_no_cone_no_actor_mask")
 var restore := Shader.new();restore.code=original_code;material.shader=restore
 sample.time55.preview_at(7.5);sample.time55.visual_hour=7.5;sample.time55.apply_look();await settle(20);await shot("morning_baseline")
 snapshot["old_atlas_edge_screen_y"]=sample.camera.unproject_position(Vector3(-55.,sample.floor_height(Vector2(-55.,18.38333)),18.38333)).y
 for target in sample.porch49.materials.values(): target.set_shader_parameter("route_strength50",0.)
 await settle(3);await shot("morning_no_old_atlas")
 FileAccess.open("res://docs/forest189-light-diagnostic.json",FileAccess.WRITE).store_string(JSON.stringify(snapshot," "))
 print("FOREST189_LIGHT_DIAGNOSTIC ",JSON.stringify(snapshot))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(sample.memory_save116));quit()
