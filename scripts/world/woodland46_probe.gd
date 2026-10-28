extends "res://scripts/world/garden44_probe.gd"
class LivingActor:
	extends "res://scripts/combat/hero36.gd"
	var wish := Vector2.ZERO
	func movement_input() -> Vector2: return wish
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class LivingSample:
	extends "res://scripts/world/world46.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot46(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/woodland46_"+name+".png")

func measure(frames: int) -> Dictionary:
	var wall: Array[float]=[]
	var previous: int=Time.get_ticks_usec()
	for i in frames:
		await process_frame
		var now: int=Time.get_ticks_usec()
		wall.append(float(now-previous)/1000.)
		previous=now
	wall.sort()
	return {"wall_median_ms":wall[frames/2],"wall_p95_ms":wall[int(frames*.95)],"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}

func run() -> void:
	var sample: Node3D=LivingSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.woodland_life): await physics_frame
	for i in 45: await physics_frame
	var life: Node3D=sample.woodland_life
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 30: await physics_frame
	sample.label.get_parent().hide()
	verify(sample.garden.material_stage==1,"approved original stepping-stone material remains default")
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility" and sample.atmosphere41.focus_level==2,"Compatibility and strong focus remain unchanged")
	verify(life.leaf_batch.multimesh.instance_count==32 and life.leaves.size()==32 and life.leaf_batch.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"leaves use a fixed 32-slot unshadowed pool")
	verify(life.near_trees.size()<=48 and life.wind_materials.size()<=96,"tree-wind material updates are bounded near the player")
	var roots: Array[Transform3D]=[]
	for tree in sample.trees: roots.append(tree.root.transform)
	for i in 90: await physics_frame
	var roots_ok := true
	for i in sample.trees.size(): roots_ok=roots_ok and sample.trees[i].root.transform==roots[i]
	verify(roots_ok,"wind leaves tree roots and their physical transforms unchanged")
	var sync := true
	for tree in life.near_trees:
		if tree.has("shadow19"):
			sync=sync and is_equal_approx(tree.visual.material_override.get_shader_parameter("wind_clock"),tree.shadow19.material_override.get_shader_parameter("wind_clock"))
	verify(sync,"nearby tree silhouettes and independent shadows share the wind clock")
	paused=true
	life.set_wind(false)
	var still: Image=await snapshot()
	life.set_wind(true)
	for material in life.wind_materials: material.set_shader_parameter("wind_clock",sample.clock+1.7)
	var moving: Image=await snapshot()
	var crown_pixels: int=changed(still,moving,Rect2i(Vector2i.ZERO,moving.get_size()))
	verify(crown_pixels>100,"crown wind visibly changes a frozen rendered scene (%d pixels)"%crown_pixels)
	paused=false
	verify(not life.lantern_light.shadow_enabled and life.lantern_body.collision_layer==2,"single warm lantern uses sun silhouette and no extra point-light shadow map")
	await shot46("home")
	paused=true
	var original_leaf: Transform3D=life.leaf_batch.multimesh.get_instance_transform(0)
	var original_color: Color=life.leaf_batch.multimesh.get_instance_custom_data(0)
	life.leaf_batch.multimesh.set_instance_transform(0,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*.6),sample.hero.position+Vector3(.7,1.3,0.)))
	life.leaf_batch.multimesh.set_instance_custom_data(0,Color(.6,.63,.25,1.))
	await shot46("leaf_detail_test")
	life.leaf_batch.multimesh.set_instance_transform(0,original_leaf)
	life.leaf_batch.multimesh.set_instance_custom_data(0,original_color)
	paused=false
	sample._teleport15(Vector2(-4.6,.7))
	for i in 20: await physics_frame
	await shot46("entrance")
	sample.hero.controls_enabled=true
	var clear_gate: bool=await walk_to(sample,Vector2(-4.6,-2.6))
	verify(clear_gate,"actual player walks through the courtyard entrance beside the lantern")
	sample.hero.controls_enabled=false
	life.set_lantern(false)
	verify(not life.lantern_root.visible and life.lantern_body.collision_layer==0,"lantern comparison disables art, light and collision together")
	life.set_lantern(true)
	life.set_leaves(false)
	life.set_wind(false)
	verify(not life.leaf_batch.visible and life.wind_materials[0].get_shader_parameter("wind_strength")==0.,"wind and falling leaves have independent off switches")
	sample._travel_region("home")
	for i in 25: await physics_frame
	await shot46("effects_off")
	life.set_lantern(false)
	life.set_process(false)
	for i in 25: await process_frame
	var baseline: Dictionary=await measure(120)
	life.set_process(true)
	life.set_wind(true); life.set_leaves(true); life.set_lantern(true)
	for i in 25: await process_frame
	var enabled: Dictionary=await measure(120)
	await shot46("effects_on")
	verify(life.leaf_batch.multimesh.instance_count==32,"effect toggles and simulation preserve the fixed leaf capacity")
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"existing first-wave encounter still starts")
	var report := {"checks":checks,"failures":failures,"effects_off":baseline,"effects_on":enabled,"leaf_capacity":32,"near_trees":life.near_trees.size(),"note":"same-machine warm scene sample; not a cross-device performance guarantee"}
	var output := FileAccess.open("res://docs/woodland46-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"\t"))
	print("WOODLAND46 ",checks," checks; failures=",failures.size()," PERF ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
