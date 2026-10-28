extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world72.gd"
	var permit_combat72 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat72: super.start_combat(reposition)

func settle72(frames: int=30) -> void:
	for i in frames: await physics_frame

func shot72(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false; sample._teleport15(at); await settle72()
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/terrain72_"+tag+".png")

func walk_route72(sample: Node3D,name: String,reverse: bool=false) -> bool:
	for route in sample.meadow.named_routes:
		if route.name!=name: continue
		var points: PackedVector2Array=route.points.duplicate()
		if name=="home_to_junction": points[0]=Vector2(-4.7,-2.5)
		if reverse: points.reverse()
		sample._teleport15(points[0]); await settle72(8)
		sample.hero.controls_enabled=true
		for at in points:
			if not await walk_to(sample,at):
				print("ROUTE72_STUCK ",name," target=",at," hero=",sample.hero.position)
				return false
		return true
	return false

func run() -> void:
	var sample := Sample.new(); root.add_child(sample)
	while not is_instance_valid(sample.rail72): await physics_frame
	await settle72()
	var surface: RefCounted=sample.meadow
	var g: Vector2=surface.landmarks.grove
	var station: Vector2=surface.landmarks.station
	var hub: Vector2=surface.landmarks.junction
	var base := preload("res://scripts/world/world_surface63.gd").new()
	verify(absf(surface.world_bounds.position.y-base.world_bounds.position.y+12.)<.01,"north expands 12m without squeezing existing geography")
	verify(absf(sample.floor_height(g)-2.1)<.05 and absf(sample.floor_height(station)-2.1)<.05,"forest and station forecourt share the main shelf")
	var connected := true
	for i in 25:
		var t := float(i)/24.
		var at := g.lerp(station,t)+Vector2(0,-3.)
		connected=connected and sample.floor_height(at)>1.85
	verify(connected,"one continuous raised land connects forest and station")
	verify(sample.floor_height(g+Vector2(-6,-15))>5.8 and sample.floor_height(g+Vector2(-6,-25))>5.8,"upper forest has a broad real top behind main clearing")
	verify(absf(sample.floor_height(hub)-.2)<.01 and absf(sample.floor_height(surface.landmarks.home)-.12)<.01,"home and great-tree root area grade onto lowland")
	var bridge: Vector2=surface.bridge_rect.get_center()
	verify(is_equal_approx(surface.bridge_height(bridge.x),base.bridge_height(bridge.x)),"approved bridge-water levels remain intact")
	var rail_flat := true
	for x in [-20.,-10.,0.,10.,20.,30.]:
		for z in [-63.3,-61.4,-59.5]:
			var h: float=sample.floor_height(Vector2(x,z))
			if absf(h-2.1)>=.01: print("RAIL72_HEIGHT ",Vector2(x,z)," physics=",h," function=",surface.height_at(x,z,true))
			rail_flat=rail_flat and absf(h-2.1)<.01
	verify(rail_flat,"full train clearance strip stays flat beside the raised platform")
	var blocked_trees := 0
	for tree in sample.trees:
		var p: Vector3=tree.root.position
		if surface.rail_rect72.grow(2.0).has_point(Vector2(p.x,p.z)): blocked_trees+=1
	verify(blocked_trees==0,"tree roots stay outside reserved train and track corridor")
	verify(sample.rail72.sleeper_count72==45 and is_instance_valid(sample.rail72.portal72),"track spacing and tunnel exit are reviewable in the original world")
	verify(sample.navigation.steep_cells72>0,"enemy grid excludes steep terrain breaks")
	for name in ["home_to_junction","junction_to_grove","junction_to_station","junction_to_shore","home_to_landing","woodland_return72"]:
		verify(await walk_route72(sample,name),"actual character traverses "+name)
	verify(await walk_route72(sample,"junction_to_grove",true),"return downhill from woodland remains playable")
	verify(await walk_route72(sample,"junction_to_station",true),"station downhill approach remains playable")
	sample.label.get_parent().hide(); sample.frames66.panel.hide()
	await shot72(sample,Vector2(-25,-31),"forest_approach")
	await shot72(sample,g,"forest")
	await shot72(sample,station+Vector2(0,8),"station_approach")
	await shot72(sample,Vector2(4,-59),"rail")
	await shot72(sample,Vector2(-16,-59),"tunnel")
	await shot72(sample,hub+Vector2(-11,-1),"junction")
	await shot72(sample,surface.landmarks.home+Vector2(0,3),"home")
	sample.set_review72(true); await settle72()
	verify(not sample.atmosphere41.enabled and sample.review_nodes72.size()>300,"overview keeps all trees visible and removes near-camera blur")
	var overview := await snapshot(); overview.save_png("res://docs/captures/world_restart/terrain72_overview.png")
	sample.set_review72(false)
	verify(sample.atmosphere41.enabled and sample.review_nodes72.is_empty(),"normal atmosphere and render ranges restore on leaving overview")
	sample.label.get_parent().show(); sample.map_panel.show(); await settle72()
	var map_shot := await snapshot(); map_shot.save_png("res://docs/captures/world_restart/terrain72_map.png")
	sample.map_panel.hide(); sample.frames66.panel.show()
	sample.permit_combat72=true; sample.start_combat(); await settle72(60)
	verify(sample.enemies.size()>0 and sample.hero.is_on_floor(),"original battle starts on connected terrain")
	var perf := await record(sample,240,false)
	var file := FileAccess.open("res://docs/terrain72-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"combat_sample":perf},"\t"))
	print("TERRAIN72 ",checks," checks; failures=",failures.size()," ",JSON.stringify(perf))
	quit(0 if failures.is_empty() else 1)
