extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world70.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func settle70(frames: int=30) -> void:
	for i in frames: await physics_frame

func shot70(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false
	sample._teleport15(at); await settle70()
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/terrace70_"+tag+".png")

func run() -> void:
	var sample := Sample.new(); root.add_child(sample)
	while not is_instance_valid(sample.terrace70): await physics_frame
	await settle70()
	var g: Vector2=sample.meadow.landmarks.grove
	verify(absf(sample.floor_height(g)-2.65)<.02,"central combat floor has a clear 2.65m raised level")
	verify(sample.floor_height(g+Vector2(-3,15))<.25,"lower approach is below the visible cliff face")
	verify(sample.terrace70.boulders70.size()==7 and sample.terrace70.stair_count70==14,"seven physical boulders and fourteen visible stone steps")
	var old := preload("res://scripts/world/world_surface69.gd").new()
	for key in ["home","junction","station"]:
		var p: Vector2=sample.meadow.landmarks[key]
		verify(absf(sample.floor_height(p)-old.walk_height(p,true))<.005,"preserve established level: "+key)
	sample.hero.controls_enabled=true
	sample._teleport15(g+Vector2(-3,14.5)); await settle70()
	verify(await walk_to(sample,g+Vector2(-3,10)) and await walk_to(sample,g+Vector2(-3,5)) and await walk_to(sample,g),"actual hero climbs full stone staircase and enters arena")
	verify(absf(sample.hero.position.y-2.65)<.25,"hero stands on the upper arena floor")
	verify(await walk_to(sample,g+Vector2(7,0)) and await walk_to(sample,g+Vector2(12,0)) and await walk_to(sample,g+Vector2(19,0)),"actual hero leaves through east side ramp")
	verify(await walk_to(sample,g+Vector2(19,5)) and await walk_to(sample,g+Vector2(15,12)) and await walk_to(sample,g+Vector2(-3,14.5)),"lower trail reconnects ramp and staircase")
	# Sweep against a solid cliff and a boulder, from walkable floor height.
	var shape := CapsuleShape3D.new(); shape.radius=.3; shape.height=1.2
	var query := PhysicsShapeQueryParameters3D.new(); query.shape=shape; query.collision_mask=2
	query.transform=Transform3D(Basis.IDENTITY,Vector3(g.x+3,3.25,g.y+5))
	query.motion=Vector3(0,0,4)
	var sweep := sample.get_world_3d().direct_space_state.cast_motion(query)
	verify(sweep[0]<.9,"cliff boundary stops walking over the retaining face")
	query.transform=Transform3D(Basis.IDENTITY,Vector3(g.x-10,3.25,g.y+1))
	query.motion=Vector3(0,0,3)
	sweep=sample.get_world_3d().direct_space_state.cast_motion(query)
	verify(sweep[0]<.9,"large boulder has character collision")
	sample.label.get_parent().hide(); sample.frames66.panel.hide()
	await shot70(sample,g+Vector2(-3,15.5),"lower_stairs")
	await shot70(sample,g+Vector2(5,10.5),"cliff")
	await shot70(sample,g+Vector2(-3,4),"upper")
	await shot70(sample,g+Vector2(14,0),"side_ramp")
	sample.time55.preview_at(22.); sample.time55.visual_hour=22.; sample.time55.apply_look()
	await shot70(sample,g+Vector2(-3,14),"night")
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	sample._teleport15(g); sample.start_combat(); await settle70(60)
	verify(sample.enemies.size()>0 and sample.hero.is_on_floor(),"existing encounter starts with enemies and hero grounded on raised terrain")
	var route: PackedVector2Array=sample.navigation.path(g+Vector2(-3,14.5),g)
	verify(route.size()>4,"enemy navigation connects lower trail to raised arena")
	sample.label.get_parent().show(); sample.frames66.panel.show()
	var perf := await record(sample,240,false)
	await shot70(sample,g,"combat")
	var file := FileAccess.open("res://docs/terrace70-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"combat_sample":perf},"\t"))
	print("TERRACE70 ",checks," checks; failures=",failures.size()," ",JSON.stringify(perf))
	quit(0 if failures.is_empty() else 1)
