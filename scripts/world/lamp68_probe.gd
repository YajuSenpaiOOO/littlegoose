extends "res://scripts/world/air52_performance_probe.gd"
class Sample:
	extends "res://scripts/world/world68.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func hour(sample: Node3D,value: float) -> void:
	sample.time55.preview_at(value); sample.time55.visual_hour=value; sample.time55.apply_look()

func settle(frames: int=45) -> void:
	for i in frames: await physics_frame

func shot(tag: String) -> Image:
	var frame := await snapshot()
	frame.save_png("res://docs/captures/world_restart/lamp68_"+tag+".png")
	return frame

func run() -> void:
	var sample := Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.local68): await physics_frame
	await settle()
	sample.hero.controls_enabled=false
	var lamps: Node3D=sample.local68
	verify(lamps.sources.size()==2 and lamps.projection.get_parent()==sample.hero,"one hero projection is shared by the window and lantern")
	verify(not sample.time55.window_spill56.shadow_enabled and not sample.woodland_life.lantern_light.shadow_enabled,"native omnidirectional shadow maps remain disabled")
	hour(sample,12.)
	await settle()
	verify(lamps.strength<.001 and not lamps.projection.visible,"daytime does not add a local shadow")
	hour(sample,22.)
	var lamp: Vector3=sample.woodland_life.lantern_light.global_position
	for side in [-1.,1.]:
		sample._teleport15(Vector2(lamp.x+side*1.5,lamp.z+1.5))
		await settle()
		verify(lamps.source_tag=="路灯" and lamps.strength>.1,"nearby lantern is selected on side "+str(side))
		var away := Vector2(sample.hero.global_position.x-lamp.x,sample.hero.global_position.z-lamp.z)
		var direction: Vector3=lamps.projection.light_direction
		verify(Vector2(direction.x,direction.z).dot(away)>0. and direction.is_finite() and direction.y<0.,"local projection points away from the lamp and remains bounded")
		sample.label.get_parent().hide(); sample.frames66.panel.hide()
		await shot("lantern_"+str(side))
	var before: int=lamps.projection.rebuilds68
	await settle(30)
	verify(lamps.projection.rebuilds68-before<=12,"static projection mesh rebuilds stay bounded")
	var window: Vector3=sample.time55.window_spill56.global_position
	sample._teleport15(Vector2(window.x+1.5,window.z+1.8))
	await settle(70)
	verify(lamps.source_tag=="小屋暖窗" and lamps.strength>.1,"warm window becomes the dominant nearby shadow source")
	await shot("window")
	var shadow: MeshInstance3D=lamps.projection
	var points: PackedVector3Array=shadow.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var seated := true
	for p in points:
		var world_point: Vector3=shadow.to_global(p)
		seated=seated and absf(world_point.y-sample.floor_height(Vector2(world_point.x,world_point.z))-.022)<.002
	verify(seated,"projected silhouette follows the actual ground")
	paused=true
	lamps.enabled=false
	lamps.update_shadow(.5); lamps.projection._physics_process(.1)
	var unshadowed := await shot("window_off")
	lamps.enabled=true
	for i in 12: lamps.update_shadow(.1); lamps.projection._physics_process(.1)
	var shadowed := await shot("window_on")
	var darkened := 0
	for y in range(0,shadowed.get_height(),2):
		for x in range(0,shadowed.get_width(),2):
			var before_color := unshadowed.get_pixel(x,y)
			var after_color := shadowed.get_pixel(x,y)
			if before_color.get_luminance()-after_color.get_luminance()>.008: darkened+=1
	verify(darkened>30,"the local silhouette visibly darkens the night ground")
	paused=false
	var obstruction := StaticBody3D.new()
	obstruction.collision_layer=2
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new(); box.size=Vector3(.5,2.,.5)
	collider.shape=box; obstruction.add_child(collider)
	obstruction.position=(sample.time55.window_spill56.global_position+sample.hero.global_position+Vector3.UP*.75)*.5
	sample.add_child(obstruction)
	await settle(3)
	verify(lamps._score(sample.time55.window_spill56)==0.,"an intervening obstacle blocks the local-light shadow influence")
	obstruction.queue_free()
	await settle(3)
	sample._teleport15(sample.meadow.landmarks.junction+Vector2(0,6.2))
	await settle(70)
	verify(lamps.strength<.001 and not lamps.projection.visible,"far from either light the local shadow disappears")
	sample._teleport15(Vector2(lamp.x+1.5,lamp.z+1.5))
	await settle()
	sample.label.get_parent().show(); sample.frames66.panel.show()
	var results := {}
	for enabled in [false,true,true,false]:
		lamps.enabled=enabled
		await settle(30)
		var tag := ("on" if enabled else "off")+str(results.size())
		results[tag]=await record(sample,180,false)
		print("LAMP68_PERF ",tag," ",JSON.stringify(results[tag]))
	lamps.enabled=true
	await settle()
	sample.frames66.clear_samples()
	await settle(70)
	await shot("live")
	var file := FileAccess.open("res://docs/lamp68-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"performance_with_guide_visible":results},"\t"))
	print("LAMP68 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
