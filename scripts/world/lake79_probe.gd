extends "res://scripts/world/landscape78_probe.gd"
class LakeSample:
	extends "res://scripts/world/world79.gd"
	var permit_combat79 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat79: super.start_combat(reposition)

func shot79(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(40)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/lake79_"+tag+".png")

func run() -> void:
	var sample := LakeSample.new();root.add_child(sample)
	while not is_instance_valid(sample.accents79): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	verify(sample.far_tree_count79>40,"real far-shore forest closes the expanded lake")
	verify(sample.accents79.flower_count79>40,"flower meadow regions contain sparse actual flower stems")
	verify(sample.house_art.texture==sample.draw_textures.slate and sample.house_art.material_override.shader.code.contains("float gable=245.") and not sample.house_art.material_override.shader.code.contains("step79"),"cottage art and original painted doorstep remain unchanged")
	verify(sample.rail72.front_count79==7 and sample.rail72.side_count79==9,"both station stair flights retain original step counts and runs")
	verify(not sample.rail72.get_node("StationFrontSteps74").visible and sample.rail72.front_steps79.visible and sample.rail72.side_steps79.visible,"new painted stone stair meshes replace old block treads")
	verify(sample.water_material19.get_shader_parameter("shore59")!=null,"new lake shore depth mask is bound")
	sample._teleport15(s.landmarks.home+Vector2(0,3.2));sample.hero.controls_enabled=true;await settle72(8)
	verify(await walk_to(sample,s.landmarks.home+Vector2(0,.4)),"actual hero follows dirt all the way to cottage step foot")
	for name in ["home_to_junction","junction_to_shore","junction_to_station","junction_to_grove","home_to_landing"]:
		verify(await walk_route72(sample,name),"actual hero traverses "+name)
	verify(await walk_route72(sample,"junction_to_station",true),"front station stairs descend through preserved physical ramp")
	sample._teleport15(s.SIDE_FOOT75);sample.hero.controls_enabled=true;await settle72(8)
	var side_ok := await walk_to(sample,s.SIDE_TOP75)
	side_ok=side_ok and await walk_to(sample,Vector2(s.SIDE_TOP75.x,-50.))
	side_ok=side_ok and await walk_to(sample,s.SIDE_TOP75) and await walk_to(sample,s.SIDE_FOOT75)
	verify(side_ok,"painted side stairs climb onto shelf and return without a lip")
	var bridge: Rect2=s.bridge_rect
	sample._teleport15(Vector2(bridge.position.x-1.,bridge.get_center().y));await settle72(8)
	var bridge_ok := true
	for i in range(1,6): bridge_ok=bridge_ok and await walk_to(sample,Vector2(lerpf(bridge.position.x-1.,bridge.end.x+1.,float(i)/5.),bridge.get_center().y))
	verify(bridge_ok,"actual hero crosses original bridge into expanded island")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot79(sample,s.landmarks.home+Vector2(0,3.3),"home")
	paused=true
	var varied := await snapshot()
	for material in sample.ground_materials: material.set_shader_parameter("ground_variety79",false)
	var plain := await snapshot()
	verify(changed(varied,plain,Rect2i(Vector2i.ZERO,varied.get_size()))>5000,"yard earth visibly differs from grass rather than merely adding props")
	for material in sample.ground_materials: material.set_shader_parameter("ground_variety79",true)
	paused=false
	await shot79(sample,s.landmarks.station+Vector2(0,13),"front_steps")
	await shot79(sample,s.SIDE_FOOT75+Vector2(1.1,2.),"side_steps")
	await shot79(sample,Vector2(-34,-26),"forest_ground")
	await shot79(sample,s.landmarks.shore+Vector2(2,-7),"island_north")
	await shot79(sample,s.landmarks.shore+Vector2(10,0),"island_east")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot79(sample,s.landmarks.shore+Vector2(2,-7),"island_night")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/lake79_overview.png")
	sample.set_review72(false)
	verify(sample.atmosphere41.enabled and sample.camera.far<300.,"normal camera and depth effects restore after expanded overview")
	sample.label.get_parent().show();sample.frames66.panel.show()
	sample.permit_combat79=true;sample.start_combat();await settle72(60)
	var perf := await record(sample,240,false)
	await clear_wave76(sample)
	verify(sample.wave_reward_pending and sample.defeated_count==1,"live AI and native projectiles still finish the first wave")
	verify(await choose76(sample,"eye_exercise"),"first-wave reward remains selectable")
	var data := {"checks":checks,"failures":failures,"trees":sample.trees.size(),"far_trees":sample.far_tree_count79,"flowers":sample.accents79.flower_count79,"combat_sample":perf}
	var file := FileAccess.open("res://docs/lake79-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("LAKE79 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
