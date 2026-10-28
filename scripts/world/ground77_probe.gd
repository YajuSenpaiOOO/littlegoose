extends "res://scripts/world/woodland76_probe.gd"

class GroundSample:
	extends "res://scripts/world/world77.gd"
	var permit_combat77 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat77: super.start_combat(reposition)

func shot77(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/ground77_"+tag+".png")

func run() -> void:
	var sample := GroundSample.new();root.add_child(sample)
	while not is_instance_valid(sample.wall76): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	# Porch lighting wraps the shader in an in-memory Shader, so resource_path
	# is intentionally empty. Check the active compiled source instead.
	verify(sample.ground_materials[0].shader.code.contains("float worn77=") and sample.ground_materials[0].shader.code.contains("sample_enabled76?1.:0."),"live terrain uses full painted ground shader")
	verify(sample.ground_materials[0].get_shader_parameter("paint")!=null,"approved ground paint remains bound")
	verify(sample.ground_materials[0].get_shader_parameter("road_end_count77")==3,"three intentional path destinations dissolve into grass")
	verify(s.road_finish77(s.landmarks.grove)<.01,"forest route ending reaches undisturbed grass")
	verify(sample.wall76.wall_mesh76.mesh.get_aabb().size.y>.75 and sample.wall76.block_count76>7,"painted wall retains real height and joined collision sections")
	verify(sample.wall76.wall_mesh76.material_override.get_shader_parameter("stone_paint77")!=null,"generated stone paint is imported and bound to the wall")
	verify(s.world_bounds==preload("res://scripts/world/world_surface76.gd").new().world_bounds,"ground restoration preserves world dimensions")
	for name in ["woodland_return72","home_to_landing","junction_to_grove"]:
		verify(await walk_route72(sample,name),"actual hero traverses "+name)
	verify(await walk_route72(sample,"woodland_return72",true),"connected forest bypass also returns without a step or collision trap")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot77(sample,s.landmarks.home+Vector2(0,4),"home")
	paused=true;sample.set_art_sample76(false)
	var plain := await snapshot();sample.set_art_sample76(true)
	var painted := await snapshot()
	verify(changed(plain,painted,Rect2i(Vector2i.ZERO,painted.get_size()))>5000,"restored grass and dirt visibly affect cottage area outside the old sample")
	painted.save_png("res://docs/captures/world_restart/ground77_home.png");paused=false
	await shot77(sample,Vector2(-26,-32.3),"wall_day")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look();await settle72(45)
	var night := await snapshot();night.save_png("res://docs/captures/world_restart/ground77_wall_night.png")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot77(sample,s.landmarks.grove+Vector2(0,4),"field")
	paused=true
	var with_endings := await snapshot()
	for material in sample.ground_materials: material.set_shader_parameter("road_end_count77",0)
	var no_endings := await snapshot()
	verify(changed(with_endings,no_endings,Rect2i(Vector2i.ZERO,with_endings.get_size()))>100,"destination breakup visibly changes the rendered forest route ending")
	for material in sample.ground_materials: material.set_shader_parameter("road_end_count77",3)
	paused=false
	await shot77(sample,s.landmarks.shore+Vector2(0,3),"shore")
	await shot77(sample,s.landmarks.station+Vector2(0,12),"station")
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/ground77_overview.png")
	sample.set_review72(false);sample.label.get_parent().show();sample.frames66.panel.show()
	sample.permit_combat77=true;sample.start_combat();await settle72(60)
	verify(not alive76(sample).is_empty() and sample.hero.is_on_floor(),"live battle still starts on restored forest ground")
	var perf := await record(sample,240,false)
	var report := {"checks":checks,"failures":failures,"combat_sample":perf}
	var file := FileAccess.open("res://docs/ground77-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"))
	print("GROUND77 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
