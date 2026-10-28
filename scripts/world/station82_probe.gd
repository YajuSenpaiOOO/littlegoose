extends "res://scripts/world/station81_probe.gd"
class Sample82:
	extends "res://scripts/world/world82.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass

func shot82(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(90)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station82_"+tag+".png")

func run() -> void:
	var sample := Sample82.new();root.add_child(sample)
	while not is_instance_valid(sample.station81): await physics_frame
	await settle72()
	var kit: Node3D=sample.station81;var s: RefCounted=sample.meadow;var station: Vector2=s.landmarks.station
	verify(absf(kit.hall81.position.x)<.001,"hall is centred on the station forecourt axis")
	verify(kit.platform81.mesh.get_aabb().size.x==40. and closed80(kit.platform81.mesh),"continuous 40m platform covers square width and remains a closed solid")
	verify(kit.canopies82.size()==2 and kit.post_bodies81.size()==8,"two flanking roofs have eight independent timber posts")
	verify(sample.rail72.front_steps80.material_override.shader.code.contains("hash73") and sample.rail72.side_steps80.material_override.shader.code.contains("face_paint79"),"front square stairs use plaza brick and lower junction stairs restore painted moss stone")
	var feet_ok := true
	for foot in kit.pillar_feet82:
		feet_ok=feet_ok and absf(foot.y-kit.global_position.y-kit.platform_top81)<.002
		feet_ok=feet_ok and absf(foot.x-station.x)<18.5 and foot.z>s.rail_z73+1.65 and foot.z<s.rail_z73+6.85
	verify(feet_ok,"every actual pillar bottom sits on the platform top and inside its footprint")
	var wheels_ok := true
	for point in kit.wheel_points82:
		wheels_ok=wheels_ok and absf(point.y-s.rail_level73()-.25)<.002 and absf(point.z-s.rail_z73-.85)<.002
	verify(wheels_ok and is_zero_approx(kit.visuals81[1].rotation.x),"four painted wheel contact pixels align with the visible rail top rather than track centre")
	verify(kit.dressing82.size()==5 and kit.emitters81.size()==5,"board freight group and two flower boxes organise forecourt with five bounded light sources")
	# Both side passages stay usable. Stop in front of the raised platform first.
	for sign_value in [-1.,1.]:
		sample.hero.controls_enabled=true;sample._teleport15(station+Vector2(sign_value*10.8,0));await settle72(8)
		var route_ok := await walk_to(sample,station+Vector2(sign_value*10.8,-8.))
		route_ok=route_ok and await walk_to(sample,Vector2(station.x+sign_value*10.8,s.rail_z73+8.))
		verify(route_ok,"actual hero passes "+("west" if sign_value<0 else "east")+" of hall to rear platform approach")
	# Enter both platform ends and cross each open shelter bay.
	for sign_value in [-1.,1.]:
		sample.hero.controls_enabled=true;sample._teleport15(Vector2(station.x+sign_value*19.9,s.rail_z73+4.3));await settle72(8)
		var deck_ok := await walk_to(sample,Vector2(station.x+sign_value*17.5,s.rail_z73+4.3))
		deck_ok=deck_ok and await walk_to(sample,Vector2(station.x+sign_value*11.4,s.rail_z73+4.3))
		verify(deck_ok and sample.hero.position.y>kit.global_position.y+.25,"actual hero climbs "+("west" if sign_value<0 else "east")+" end ramp and walks under roof on raised deck")
	var front: Vector2=s.stair_start73()
	sample.hero.controls_enabled=true;sample._teleport15(front+Vector2(0,.9));await settle72(8)
	verify(await walk_to(sample,front-Vector2(0,s.station_stair_run74()+1.)),"brick forecourt stairs retain smooth physical climb")
	sample._teleport15(s.SIDE_FOOT75);await settle72(8)
	verify(await walk_to(sample,s.SIDE_TOP75),"restored moss side stairs retain smooth physical climb")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot82(sample,station+Vector2(0,6.5),"hall_day")
	await shot82(sample,station+Vector2(0,12.),"square_day")
	await shot82(sample,Vector2(station.x+11.4,s.rail_z73+9.),"platform_day")
	await shot82(sample,Vector2(station.x+4.,s.rail_z73+1.5),"wheels")
	await shot82(sample,Vector2(station.x+11.4,s.rail_z73+4.3),"under_canopy")
	await shot82(sample,station+Vector2(0,-11.),"behind_hall")
	verify(kit.fades81[0]<.005,"centred hall completely hides when blocking hero on rear passage")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot82(sample,station+Vector2(0,6.5),"hall_night")
	await shot82(sample,Vector2(station.x+11.4,s.rail_z73+9.),"platform_night")
	var lights_ok := true
	for emitter in kit.emitters81: lights_ok=lights_ok and emitter.light.light_energy>1. and not emitter.light.shadow_enabled
	verify(lights_ok and sample.local68.sources.size()==8,"all station lights follow night without extra shadow maps and register actor shadow sources")
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	sample.set_review72(true);await settle72(10)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station82_overview.png")
	var data := {"checks":checks,"failures":failures}
	var file := FileAccess.open("res://docs/station82-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STATION82_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
