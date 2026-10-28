extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world69.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func settle(frames: int=35) -> void:
	for i in frames: await physics_frame

func shot(tag: String) -> void:
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/terrain69_"+tag+".png")

func set_hour(sample: Node3D,hour: float) -> void:
	sample.time55.preview_at(hour); sample.time55.visual_hour=hour; sample.time55.apply_look()

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.local68): await physics_frame
	await settle()
	var surface: RefCounted=sample.meadow
	var grove: Vector2=surface.landmarks.grove
	var station: Vector2=surface.landmarks.station
	verify(surface.get_script().resource_path.ends_with("world_surface69.gd"),"new route and terrain rehearsal selected")
	verify(absf(sample.floor_height(grove)-.62)<.04,"grove has a low playable plateau")
	verify(absf(sample.floor_height(station)-1.25)<.04 and sample.floor_height(station+Vector2(0,7))<.7,"station platform and lower forecourt are distinct levels")
	var original := preload("res://scripts/world/world_surface63.gd").new()
	var hub: Vector2=surface.landmarks.junction
	verify(absf(surface.height_at(hub.x,hub.y,true)-original.height_at(hub.x,hub.y,true))<.005,"approved great-tree hub stays at its original level")
	var bridge: Vector2=surface.bridge_rect.get_center()
	verify(is_equal_approx(surface.bridge_height(bridge.x),original.bridge_height(bridge.x)),"bridge and lake connection retain their level")
	sample.hero.controls_enabled=true
	sample._teleport15(grove+Vector2(11,6))
	verify(await walk_to(sample,grove+Vector2(7,3.8)) and await walk_to(sample,grove+Vector2(0,4)) and await walk_to(sample,grove),"hero can enter and move across the combat plateau")
	sample._teleport15(station+Vector2(-1.4,4.5))
	verify(await walk_to(sample,station+Vector2(2,3)) and await walk_to(sample,station+Vector2(0,1.35)),"hero can climb the station approach without step snagging")
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide(); sample.frames66.panel.hide()
	sample._teleport15(grove+Vector2(9,5)); await settle(); await shot("grove")
	sample._teleport15(station+Vector2(0,8)); await settle(); await shot("station_approach")
	sample._teleport15(station+Vector2(0,2)); await settle(); await shot("platform")
	set_hour(sample,22.)
	var lamps: Node3D=sample.local68
	var native_lamp: Vector3=sample.woodland_life.lantern_light.global_position
	for offset in [Vector2(-1.5,0),Vector2(1.5,0),Vector2(0,1.5),Vector2(0,-1.5),Vector2.ZERO]:
		sample._teleport15(Vector2(native_lamp.x,native_lamp.z)+offset)
		await settle(65)
		var found := false
		for slot in lamps.slots69:
			if slot.tag=="路灯" and slot.weight>.03:
				found=true
				verify(slot.shadow.footprint_area69>.05,"lamp shadow keeps area at offset "+str(offset))
		verify(found,"lamp contributes at offset "+str(offset))
	await shot("under_lamp")
	for source in lamps.sources:
		if not source.has("pixel"): continue
		var anchor: Vector3=lamps.anchor69(source)
		sample._teleport15(Vector2(anchor.x,anchor.z)+Vector2(.3,1.2))
		await settle(70)
		var found := false
		for slot in lamps.slots69:
			if slot.tag!=source.tag or slot.weight<.03: continue
			found=true
			var direction: Vector3=slot.shadow.light_direction
			var actor: Vector3=sample.hero.global_position
			verify(Vector2(direction.x,direction.z).dot(Vector2(actor.x-anchor.x,actor.z-anchor.z))>=0.,"window shadow points away from its visible painted window")
		verify(found,"visible window contributes: "+source.tag)
		await shot("window_"+source.tag)
	verify(lamps.slots69.size()==2 and not sample.time55.window_spill56.shadow_enabled,"only two bounded local silhouettes, no native shadow maps")
	set_hour(sample,12.)
	sample.label.get_parent().show(); sample.frames66.panel.show()
	sample.start_combat()
	await settle(50)
	verify(sample.enemies.size()>0 and sample.hero.is_on_floor(),"combat still starts on the revised grove ground")
	var combat := await record(sample,240,false)
	print("TERRAIN69_COMBAT ",JSON.stringify(combat))
	sample._leave_encounter()
	sample.label.get_parent().show(); sample.frames66.panel.show()
	sample._teleport15(station+Vector2(0,7)); await settle(); await shot("live")
	var file := FileAccess.open("res://docs/terrain69-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"combat_sample":combat},"\t"))
	print("TERRAIN69 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
