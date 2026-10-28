extends "res://scripts/world/station82_probe.gd"
class Sample83:
	extends "res://scripts/world/world83.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass

func shot83(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(90)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station83_"+tag+".png")

func run() -> void:
	var sample := Sample83.new();root.add_child(sample)
	while not is_instance_valid(sample.station81): await physics_frame
	await settle72()
	var kit: Node3D=sample.station81;var s: RefCounted=sample.meadow;var station: Vector2=s.landmarks.station
	verify(is_equal_approx(kit.hall81.position.z,-8.5),"hall moves back four metres with its collisions and lights")
	var rear: float=kit.hall_body81.global_position.z-2.55
	var platform_front: float=kit.platform81.global_position.z+2.6
	verify(absf(rear-platform_front)<.20,"back of hall reaches platform front within twenty centimetres")
	verify(kit.beds83.size()==2 and kit.fences83.size()==2,"two low border beds and two short fence segments leave main axis open")
	verify(sample.rail72.has_node("MossStairLandingAndReturns83") and not sample.rail72.get_node("RetainingWallAndOutsideCurb80").visible,"old isolated curb fragments replaced with continuous stone landing and returns")
	verify(sample.stair_cuts80()[1].x<3.2 and sample.stair_cuts80()[1].w> -44.3,"terrain shoulder render cut includes exposed green fragments outside stair core")
	sample.hero.controls_enabled=true;sample._teleport15(s.SIDE_FOOT75+Vector2(.7,0));await settle72(8)
	var stairs_ok := await walk_to(sample,s.SIDE_TOP75)
	stairs_ok=stairs_ok and await walk_to(sample,Vector2(4.8,-49.)) and await walk_to(sample,s.SIDE_TOP75) and await walk_to(sample,s.SIDE_FOOT75)
	verify(stairs_ok,"actual hero climbs side stairs turns onto upper shelf and returns without snag")
	for sign_value in [-1.,1.]:
		sample.hero.controls_enabled=true;sample._teleport15(station+Vector2(sign_value*10.8,0));await settle72(8)
		var route_ok := await walk_to(sample,station+Vector2(sign_value*10.8,-8.))
		route_ok=route_ok and await walk_to(sample,Vector2(station.x+sign_value*10.8,s.rail_z73+8.))
		verify(route_ok,"rearward hall and border props retain "+("west" if sign_value<0 else "east")+" passage")
	sample.hero.controls_enabled=true;sample._teleport15(station+Vector2(0,6.5));await settle72(8)
	verify(await walk_to(sample,station+Vector2(0,-6.5)),"expanded centre forecourt stays open for movement")
	# Verify that saved editor markers are the actual source, not decorative gizmos.
	verify(kit.hall81.position==kit.layout83.get_node("Hall").position and kit.beds83[0].position==kit.layout83.get_node("WestBed").position,"runtime modules use saved editor markers")
	verify(kit.layout83.get_child_count()==12,"runtime layout scene contains markers only and no editor preview geometry")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot83(sample,s.SIDE_FOOT75+Vector2(-1.6,3.),"side_stairs")
	await shot83(sample,station+Vector2(0,6.5),"square_day")
	await shot83(sample,station+Vector2(-14.,5.),"border_day")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot83(sample,station+Vector2(0,6.5),"square_night")
	var data := {"checks":checks,"failures":failures}
	var file := FileAccess.open("res://docs/station83-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STATION83_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
