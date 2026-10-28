extends "res://scripts/world/ground77_probe.gd"
class LandscapeSample:
	extends "res://scripts/world/world78.gd"
	var permit_combat78 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat78: super.start_combat(reposition)

func shot78(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(40)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/landscape78_"+tag+".png")

func run() -> void:
	var sample := LandscapeSample.new();root.add_child(sample)
	while not is_instance_valid(sample.scenery78): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	verify(sample.removed_trees78>20 and sample.shifted_trees78>20 and sample.trees.size()<512,"trees form sparser offset groups without increasing total tree count")
	var roots_clear := true
	for tree in sample.trees:
		if tree.root==sample.landmark_tree.root: continue
		var at := Vector2(tree.root.position.x,tree.root.position.z)
		roots_clear=roots_clear and ((at-Vector2(s.landmarks.grove))/s.ROOT_BUFFER76).length()>1. and not s.is_water(at)
	verify(roots_clear,"regrouped ordinary trees stay out of water and the entire battle root buffer")
	verify(sample.ground_materials[0].shader.code.contains("rock_paint78") and sample.ground_materials[0].get_shader_parameter("paint")!=null,"painted ground remains restored with natural rock on exposed slopes")
	verify(sample.scenery78.forest_stones78>5 and sample.scenery78.shore_stones78>5,"forest toes and lake banks have separate sparse physical rock groups")
	for name in ["junction_to_grove","woodland_return72","junction_to_station","junction_to_shore","home_to_landing"]:
		verify(await walk_route72(sample,name),"actual hero traverses "+name)
	verify(await walk_route72(sample,"junction_to_grove",true),"enlarged forest returns downhill through existing entrance")
	sample.hero.controls_enabled=true
	var bridge: Rect2=s.bridge_rect
	sample._teleport15(Vector2(bridge.position.x-1.,bridge.get_center().y));await settle72(8)
	var bridge_ok := true
	for i in range(1,6): bridge_ok=bridge_ok and await walk_to(sample,Vector2(lerpf(bridge.position.x-1.,bridge.end.x+1.,float(i)/5.),bridge.get_center().y))
	verify(bridge_ok,"actual character crosses unchanged bridge between newly curved shores")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot78(sample,Vector2(-48,-59),"rear_rocks")
	await shot78(sample,s.landmarks.grove+Vector2(0,4),"field")
	await shot78(sample,s.landmarks.shore+Vector2(2,-7),"shore")
	await shot78(sample,Vector2(bridge.position.x-2.,bridge.get_center().y+1.),"bridge")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot78(sample,Vector2(-48,-59),"rear_night")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/landscape78_overview.png")
	sample.set_review72(false)
	verify(sample.atmosphere41.enabled,"approved normal-view depth effects restore after overview")
	sample.label.get_parent().show();sample.frames66.panel.show()
	sample.permit_combat78=true;sample.start_combat();await settle72(60)
	verify(not alive76(sample).is_empty() and sample.hero.is_on_floor(),"battle still starts on flat clearing with live AI")
	var perf := await record(sample,240,false)
	await clear_wave76(sample)
	verify(sample.wave_reward_pending and sample.defeated_count==1,"native projectiles and AI complete the first wave")
	verify(await choose76(sample,"eye_exercise"),"wave reward remains selectable after terrain changes")
	var report := {"checks":checks,"failures":failures,"trees":sample.trees.size(),"removed":sample.removed_trees78,"shifted":sample.shifted_trees78,"combat_sample":perf}
	var file := FileAccess.open("res://docs/landscape78-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"))
	print("LANDSCAPE78 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
