extends "res://scripts/world/lake79_probe.gd"
class StairSample:
	extends "res://scripts/world/world80.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass

func closed80(mesh: ArrayMesh) -> bool:
	var faces := mesh.get_faces();var edges := {}
	for i in range(0,faces.size(),3):
		for j in 3:
			var a: Vector3=faces[i+j].snapped(Vector3.ONE*.0001)
			var b: Vector3=faces[i+(j+1)%3].snapped(Vector3.ONE*.0001)
			var sa := str(a);var sb := str(b)
			var key := sa+"/"+sb if sa<sb else sb+"/"+sa
			edges[key]=edges.get(key,0)+1
	for count in edges.values():
		if count!=2: return false
	return true

func shot80(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(35)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/stairs80_"+tag+".png")

func run() -> void:
	var sample := StairSample.new();root.add_child(sample)
	while not is_instance_valid(sample.accents79): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	verify(closed80(sample.rail72.front_steps80.mesh),"front stair extrusion is a closed solid with every mesh edge shared twice")
	verify(closed80(sample.rail72.side_steps80.mesh),"side stair extrusion is a closed solid with every mesh edge shared twice")
	verify(not sample.rail72.front_steps79.visible and not sample.rail72.side_steps79.visible,"separate old tread pieces are hidden")
	verify(sample.ground_materials[0].get_shader_parameter("cut_stairs80")==true,"underlying terrain rendering is cut only beneath stair footprints")
	verify(sample._grass_allowed19(Vector2(-4.5,-2.8)) and not sample._grass_allowed19(s.SIDE_FOOT75-Vector2(2.,0.)),"yard grass restores while side stairs stay free of grass instances")
	verify(sample.ground_style80==0,"clean moss grass is default rather than brown mud")
	sample.hero.controls_enabled=true;sample._teleport15(s.stair_start73()+Vector2(0,.9));await settle72(8)
	var front_ok := await walk_to(sample,s.stair_start73()-Vector2(0,s.station_stair_run74()+1.))
	front_ok=front_ok and await walk_to(sample,s.stair_start73()+Vector2(0,.9))
	verify(front_ok,"actual hero climbs and descends closed front stairs on smooth physical ramp")
	sample._teleport15(s.SIDE_FOOT75);await settle72(8)
	var side_ok := await walk_to(sample,s.SIDE_TOP75)
	side_ok=side_ok and await walk_to(sample,Vector2(s.SIDE_TOP75.x,-50.)) and await walk_to(sample,s.SIDE_TOP75) and await walk_to(sample,s.SIDE_FOOT75)
	verify(side_ok,"actual hero climbs closed side stairs joins shelf and returns")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot80(sample,s.landmarks.station+Vector2(0,13),"front")
	await shot80(sample,s.SIDE_FOOT75+Vector2(1.1,2.),"side")
	await shot80(sample,s.landmarks.home+Vector2(0,3.3),"moss_grass")
	paused=true
	var frames: Array[Image]=[]
	for style in 3:
		sample.set_ground_style80(style)
		var frame := await snapshot();frames.append(frame)
		frame.save_png("res://docs/captures/world_restart/stairs80_ground_"+str(style+1)+".png")
	verify(changed(frames[0],frames[1],Rect2i(Vector2i.ZERO,frames[0].get_size()))>1000,"light fine gravel visibly differs from default moss grass")
	verify(changed(frames[0],frames[2],Rect2i(Vector2i.ZERO,frames[0].get_size()))>100,"thin leaf treatment remains distinguishable but restrained")
	sample.set_ground_style80(0);paused=false
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot80(sample,s.landmarks.station+Vector2(0,13),"front_night")
	var data := {"checks":checks,"failures":failures}
	var file := FileAccess.open("res://docs/stairs80-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STAIRS80 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
