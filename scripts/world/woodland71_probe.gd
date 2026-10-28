extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world71.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass

func settle71(frames: int=35) -> void:
	for i in frames: await physics_frame

func shot71(sample: Node3D,p: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false
	sample._teleport15(sample.meadow.landmarks.grove+p); await settle71()
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/woodland71_"+tag+".png")

func run() -> void:
	var sample := Sample.new(); root.add_child(sample)
	while not is_instance_valid(sample.region71): await physics_frame
	await settle71()
	var g: Vector2=sample.meadow.landmarks.grove
	verify(sample.floor_height(g)>2.3,"clearing belongs to elevated woodland")
	verify(sample.floor_height(g+Vector2(-18,-7))>2.3 and sample.floor_height(g+Vector2(0,-15))>2.9,"west and rear forest stay elevated beyond combat space")
	verify(sample.floor_height(g+Vector2(0,-23))>3.5,"wooded foothills rise behind the tree belt")
	verify(sample.floor_height(g+Vector2(3,13.5))<.25,"front footpath remains below the forest escarpment")
	var raised_trees := 0
	for tree in sample.trees:
		var p: Vector3=tree.root.position
		if p.x<g.x+13 and p.z<g.y-6 and p.z>g.y-23 and p.y>2.3: raised_trees+=1
	verify(raised_trees>=8,"surrounding forest roots stand on the SAME raised terrain (%d trees)"%raised_trees)
	verify(sample.region71.front_faces71.size()==4 and sample.region71.boulders70.size()==3,"front escarpment and sparse rocks replace the closed arena perimeter")
	verify(is_instance_valid(sample.region71.ridge71) and sample.region71.ridge71.texture.get_width()>1500,"painted rocky ridge is present behind forest")
	var old := preload("res://scripts/world/world_surface69.gd").new()
	for key in ["home","junction","station"]:
		var p: Vector2=sample.meadow.landmarks[key]
		verify(absf(sample.floor_height(p)-old.walk_height(p,true))<.005,"retain established level: "+key)
	sample.hero.controls_enabled=true
	sample._teleport15(g+Vector2(-3,14.5)); await settle71()
	verify(await walk_to(sample,g+Vector2(-3,9)) and await walk_to(sample,g+Vector2(-3,4)) and await walk_to(sample,g),"hero climbs stone stair into forest clearing")
	verify(await walk_to(sample,g+Vector2(6,-1)) and await walk_to(sample,g+Vector2(12,-2)) and await walk_to(sample,g+Vector2(20,-1)) and await walk_to(sample,g+Vector2(25,5)),"broad east wooded slope reconnects to lowland")
	verify(await walk_to(sample,g+Vector2(16,13)) and await walk_to(sample,g+Vector2(-3,14.5)),"front footpath reconnects both approaches")
	verify(sample.navigation.path(g+Vector2(-3,14.5),g).size()>5,"enemy navigation still reaches clearing through staircase")
	verify(sample.navigation.path(g+Vector2(20,-1),g).size()>5,"enemy navigation reaches clearing along open east slope")
	sample.label.get_parent().hide(); sample.frames66.panel.hide()
	await shot71(sample,Vector2(3,13.5),"entrance")
	await shot71(sample,Vector2(-3,4),"clearing")
	await shot71(sample,Vector2(0,-3),"rear_belt")
	await shot71(sample,Vector2(18,-1),"east_slope")
	sample.review71=true; sample.review_anchor71=sample.hero.global_position
	await settle71()
	var overview := await snapshot()
	overview.save_png("res://docs/captures/world_restart/woodland71_overview.png")
	sample.review71=false
	sample.time55.preview_at(22.); sample.time55.visual_hour=22.; sample.time55.apply_look()
	await shot71(sample,Vector2(-3,4),"night")
	sample.time55.preview_at(12.); sample.time55.visual_hour=12.; sample.time55.apply_look()
	sample._teleport15(g); sample.start_combat(); await settle71(60)
	verify(sample.enemies.size()>0 and sample.hero.is_on_floor(),"existing combat starts with hero grounded in the upland clearing")
	sample.label.get_parent().show(); sample.frames66.panel.show()
	var perf := await record(sample,240,false)
	var file := FileAccess.open("res://docs/woodland71-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"raised_trees":raised_trees,"combat_sample":perf},"\t"))
	print("WOODLAND71 ",checks," checks; failures=",failures.size()," ",JSON.stringify(perf))
	quit(0 if failures.is_empty() else 1)
