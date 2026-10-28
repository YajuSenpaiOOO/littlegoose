extends "res://scripts/world/terrain72_probe.gd"

func snapshot() -> Image:
	for i in 3: await process_frame
	# A minimized test window may not emit frame_post_draw. Explicitly render
	# this validation frame rather than waiting indefinitely for window redraw.
	RenderingServer.force_draw(false)
	return root.get_texture().get_image()

class WideSample:
	extends "res://scripts/world/world75.gd"
	var permit_combat73 := false
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(reposition := true) -> void:
		if permit_combat73: super.start_combat(reposition)

func route_length73(surface: RefCounted,name: String) -> float:
	for entry in surface.named_routes:
		if entry.name!=name: continue
		var length := 0.
		for i in range(1,entry.points.size()): length+=entry.points[i].distance_to(entry.points[i-1])
		return length
	return 0.

func shot73(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72()
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/depth75_"+tag+".png")

func run() -> void:
	var sample := WideSample.new();root.add_child(sample)
	while not is_instance_valid(sample.rail72): await physics_frame
	await settle72()
	var s: RefCounted=sample.meadow
	var old := preload("res://scripts/world/world_surface72.gd").new()
	var g: Vector2=s.landmarks.grove
	var station: Vector2=s.landmarks.station
	var hub: Vector2=s.landmarks.junction
	verify(g.distance_to(old.landmarks.grove)>9. and station.y<old.landmarks.station.y-17.,"forest and station move apart in the original world")
	verify(s.GROVE_RADII73.x*s.GROVE_RADII73.y>=150.,"woodland clearing gains 50 percent floor area")
	verify(route_length73(s,"junction_to_station")>route_length73(old,"junction_to_station")*1.35,"winding station approach creates a longer buffer")
	verify(sample.boundary_count73==4 and s.world_bounds.position.x<old.world_bounds.position.x-13.,"expanded west/north world boundaries relocate together")
	verify(absf(sample.floor_height(g)-2.1)<.05,"enlarged combat floor stays on main woodland shelf")
	verify(absf(sample.floor_height(station)-3.4)<.05,"station is a full masonry storey above main shelf")
	verify(absf(sample.floor_height(s.stair_start73())-2.1)<.05,"station stair foot joins the main regional terrace")
	verify(is_equal_approx(sample.rail72.rail_span73.x,s.world_bounds.position.x) and is_equal_approx(sample.rail72.rail_span73.y,s.world_bounds.end.x),"rails end exactly at both map boundaries")
	var flat := true
	for x in [-25.,0.,station.x,30.,s.world_bounds.end.x-1.]:
		for dz in [-1.9,0.,1.9]:
			var h: float=sample.floor_height(Vector2(x,s.rail_z73+dz))
			if absf(h-3.4)>.025: print("RAIL73_HEIGHT ",Vector2(x,s.rail_z73+dz)," ",h)
			flat=flat and absf(h-3.4)<.025
	verify(flat,"physical train strip stays flat along the full exposed span")
	verify(sample.get_node("DeparturePlaza").material_override==sample.rail72.station_mesh73.material_override,"platform top and full side use the same brick construction")
	var track_bounds: AABB=sample.rail72.rail_mesh72.mesh.get_aabb()
	verify(absf(track_bounds.position.x-s.world_bounds.position.x)<.01 and absf(track_bounds.end.x-s.world_bounds.end.x)<.01,"actual track vertices stay within the map edges")
	verify(not sample.rail72.has_node("RailBackgroundLandBeyondBoundary73"),"no extra track support projects beyond the map")
	var old74 := preload("res://scripts/world/world_surface74.gd").new()
	verify(s.station_rect73.size.x==40. and s.station_rect73.size.y>old74.station_rect73.size.y+11.9,"station gains 12m depth without more width")
	verify(s.station_stair_run74()<old74.station_stair_run74()*.51 and s.station_stair_count74()==7,"forecourt stair run halves to 3.4m with seven steps")
	verify(s.hall_reserve75.position.y-s.platform_reserve75.end.y>2. and s.hall_reserve75.end.y<s.station_front74(station.x)-10.,"hall and platform footprints leave a rear passage and a front forecourt")
	verify(is_equal_approx(sample.floor_height(s.landmarks.home),.12),"approved cottage foundation remains")
	var bridge: Vector2=s.bridge_rect.get_center()
	verify(is_equal_approx(s.bridge_height(bridge.x),old.bridge_height(bridge.x)),"bridge and water level remain unchanged")
	for name in ["home_to_junction","junction_to_grove","junction_to_station","junction_to_shore","home_to_landing","woodland_return72"]:
		verify(await walk_route72(sample,name),"actual character traverses "+name)
	verify(await walk_route72(sample,"junction_to_station",true),"character descends new station stairs and winding return")
	sample.hero.controls_enabled=true;sample._teleport15(g+Vector2(-13.5,0));await settle72(8)
	# Each movement target has a 320-physics-frame timeout. A 27m crossing at
	# the actual 4.1m/s walk speed exceeds that timeout even on clear ground.
	var cross_ok := true
	for dx in [-4.5,4.5,13.5]:
		if not await walk_to(sample,g+Vector2(dx,0)):
			cross_ok=false;print("BATTLE74_BLOCKED hero=",sample.hero.position," target=",g+Vector2(dx,0))
			break
	verify(cross_ok,"actual hero crosses 27m of enlarged battle floor")
	var connected := true
	for dz in [7.,2.,-3.,-8.,-12.,-20.]:
		connected=connected and absf(sample.floor_height(station+Vector2(12.,dz))-3.4)<.04
	verify(connected,"plaza rear continues onto the railway and northern land without a drop")
	var sides_continue := true
	for dx in [-25.,25.,36.]:
		sides_continue=sides_continue and sample.floor_height(station+Vector2(dx,-1.))>2.55
	verify(sides_continue,"high land extends sideways beyond paving bounds")
	verify(not sample.rail72.has_node("StationBrickFoundationCollision73"),"station uses continuous terrain rather than an independent box foundation")
	sample._teleport15(station+Vector2(12.,6.));await settle72(8)
	var rear_walk := await walk_to(sample,station+Vector2(12.,-5.))
	rear_walk=rear_walk and await walk_to(sample,Vector2(station.x+12.,s.rail_z73+3.))
	verify(rear_walk,"actual hero walks from square rear to trackside on one level")
	sample._teleport15(s.SIDE_FOOT75);await settle72(8);sample.hero.controls_enabled=true
	var side_walk := await walk_to(sample,s.SIDE_TOP75)
	side_walk=side_walk and await walk_to(sample,Vector2(s.SIDE_TOP75.x,-50.))
	side_walk=side_walk and await walk_to(sample,s.SIDE_TOP75)
	side_walk=side_walk and await walk_to(sample,s.SIDE_FOOT75)
	verify(side_walk,"actual hero climbs side stairs onto regional shelf and returns")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	await shot73(sample,station+Vector2(1,15),"station_front")
	await shot73(sample,station+Vector2(18,9),"brick_side")
	await shot73(sample,Vector2(station.x,s.rail_z73+2.5),"platform_rail")
	await shot73(sample,Vector2(s.world_bounds.end.x-4.,s.rail_z73+3.),"east_rail")
	await shot73(sample,g+Vector2(3,5),"forest")
	await shot73(sample,hub+Vector2(0,-18),"winding_path")
	await shot73(sample,s.SIDE_FOOT75+Vector2(1.,2.),"side_stairs")
	var old_far: float=sample.camera.far
	sample.set_review72(true);await settle72()
	var overview := await snapshot();overview.save_png("res://docs/captures/world_restart/depth75_overview.png")
	sample.set_review72(false)
	verify(is_equal_approx(sample.camera.far,old_far) and sample.atmosphere41.enabled,"normal camera and atmosphere restore after expanded overview")
	sample.label.get_parent().show();sample.frames66.panel.show()
	sample.permit_combat73=true;sample.start_combat();await settle72(60)
	verify(sample.enemies.size()>0 and sample.hero.is_on_floor(),"original battle starts on relocated enlarged clearing")
	var perf := await record(sample,240,false)
	var data := {"checks":checks,"failures":failures,"station_route_old":route_length73(old,"junction_to_station"),"station_route_new":route_length73(s,"junction_to_station"),"combat_sample":perf}
	var file := FileAccess.open("res://docs/depth75-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("DEPTH75 ",JSON.stringify(data))
	quit(0 if failures.is_empty() else 1)


