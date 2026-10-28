extends "res://scripts/world/stairs80_probe.gd"
class StationSample:
	extends "res://scripts/world/world81.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false
	func hurt_player(_damage: float,_from: Vector2) -> void: pass
	func start_combat(_reposition := true) -> void: pass

func shot81(sample: Node3D,at: Vector2,tag: String) -> void:
	sample.hero.controls_enabled=false;sample._teleport15(at);await settle72(50)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station81_"+tag+".png")

func run() -> void:
	var sample := StationSample.new();root.add_child(sample)
	while not is_instance_valid(sample.station81): await physics_frame
	await settle72()
	var kit: Node3D=sample.station81
	var s: RefCounted=sample.meadow
	var at: Vector2=s.landmarks.station
	verify(kit.visuals81.size()==3 and kit.post_bodies81.size()==4,"three painted modules and four separate canopy post collisions")
	verify(closed80(sample.rail72.front_steps80.mesh) and closed80(sample.rail72.side_steps80.mesh),"both stairs remain closed solids")
	verify(closed80(kit.platform81.mesh),"platform and end ramps form one closed solid with no exposed underside gaps")
	verify(sample.rail72.front_steps80.material_override.shader.code.contains("vec3(0.48,0.42,0.34)") or sample.rail72.front_steps80.material_override.shader.code.contains("vec3(.48,.42,.34)"),"stairs use the same brick palette and world aligned pattern as plaza")
	var low_lights := true
	for emitter in kit.emitters81: low_lights=low_lights and not emitter.light.shadow_enabled
	verify(low_lights and kit.emitters81.size()==4,"four bounded warm lights with no additional shadow maps")
	sample.hero.controls_enabled=true
	sample._teleport15(at+Vector2(2.,0));await settle72(8)
	var passage := await walk_to(sample,at+Vector2(2.,-8.))
	passage=passage and await walk_to(sample,at+Vector2(2.,-12.))
	verify(passage,"actual hero passes east of hall from forecourt to platform approach")
	# Walk onto the low platform via an end ramp, then through the open canopy.
	sample._teleport15(Vector2(at.x-2.5,s.rail_z73+4.3));await settle72(8)
	var deck_ok := await walk_to(sample,Vector2(at.x+1.,s.rail_z73+4.3))
	deck_ok=deck_ok and await walk_to(sample,Vector2(at.x+8.,s.rail_z73+4.3))
	print("STATION81_DECK_HEIGHT ",sample.hero.position.y," wanted=",kit.global_position.y+kit.platform_top81)
	verify(deck_ok and sample.hero.position.y>kit.global_position.y+.25,"actual hero climbs end ramp and walks above deck beneath canopy")
	sample.hero.wish=Vector2.ZERO;await settle72(50)
	var under_frame := await snapshot();under_frame.save_png("res://docs/captures/world_restart/station81_under_canopy.png")
	verify(kit.visuals81[1].material_override.get_shader_parameter("glass_band81")==Vector2.ONE and kit.visuals81[2].material_override.get_shader_parameter("glass_band81")==Vector2(.30,.64),"glow is masked to coach windows and disabled on wooden canopy")
	sample._teleport15(at+Vector2(-8.,-2.8));await settle72(8)
	sample.hero.wish=Vector2.UP;await settle72(60);sample.hero.wish=Vector2.ZERO
	verify(sample.hero.position.z>kit.hall81.global_position.z-.25,"hall body stops hero at painted front wall")
	sample._teleport15(Vector2(at.x+7.,s.rail_z73+2.));await settle72(8)
	sample.hero.wish=Vector2.UP;await settle72(55);sample.hero.wish=Vector2.ZERO
	verify(sample.hero.position.z>s.rail_z73+.85,"static carriage body blocks walking through train")
	sample.label.get_parent().hide();sample.frames66.panel.hide()
	sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
	await shot81(sample,at+Vector2(-2.,9.),"square_day")
	await shot81(sample,at+Vector2(-8.,1.),"hall_day")
	await shot81(sample,Vector2(at.x+10.,s.rail_z73+9.),"platform_day")
	await shot81(sample,at+Vector2(-8.,-11.),"behind_hall")
	verify(kit.fades81[0]<.005,"painted hall fully fades as a whole when standing behind its visible silhouette")
	sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
	await shot81(sample,at+Vector2(-2.,9.),"square_night")
	verify(kit.emitters81[0].light.light_energy>1. and sample.local68.sources.size()==7,"station warm light follows night and registers with existing actor shadow selector")
	await shot81(sample,Vector2(at.x+10.,s.rail_z73+9.),"platform_night")
	sample.set_review72(true);await settle72(8)
	var frame := await snapshot();frame.save_png("res://docs/captures/world_restart/station81_overview.png")
	var data := {"checks":checks,"failures":failures}
	var file := FileAccess.open("res://docs/station81-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
	print("STATION81_VALIDATION ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
