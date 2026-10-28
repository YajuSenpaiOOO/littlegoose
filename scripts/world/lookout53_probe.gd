extends "res://scripts/world/woodland46_probe.gd"
class LookoutSample:
	extends "res://scripts/world/world53.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot53(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/lookout53_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=LookoutSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.lookout53): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var view: Node3D=sample.lookout53
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(not sample.porch49.has_node("DoorstepVolume") and sample.garden.material_stage==1,"original house stairs and stones retained")
	var old_surface=preload("res://scripts/world/world_surface21.gd").new()
	verify(absf(sample.meadow.height_at(-4.7,-4.8,true)-old_surface.height_at(-4.7,-4.8,true))<.001,"house level unchanged")
	verify(sample.meadow.height_at(-12.,-5.2,true)-old_surface.height_at(-12.,-5.2,true)>.8,"west shoulder rises gently above the original ground")
	verify(view.forest_batches==3 and view.ridge_count==3 and view.gap_trees.size()>5,"distant scene uses three forest batches and three ridges")
	sample._travel_region("home")
	for i in 25: await physics_frame
	await shot53("home")
	sample._travel_region("lookout")
	for i in 30: await physics_frame
	paused=true
	var camera_before: Transform3D=sample.camera.transform
	var images: Array[Image]=[]
	for i in 3:
		view.set_mode(i)
		images.append(await shot53("mode%d"%i))
		verify(camera_before==sample.camera.transform,"view mode %d retains identical camera"%i)
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[1],area)>10000,"opening the trees visibly changes the view")
	verify(changed(images[1],images[2],area)>10000,"distant layers visibly change the open view")
	view.set_mode(0)
	var restored: Image=await snapshot()
	verify(changed(images[0],restored,area)<100,"tree-wall comparison restores cleanly")
	view.set_mode(2)
	paused=false
	sample._teleport15(Vector2(-6.,-1.3))
	sample.hero.controls_enabled=true
	var walked := true
	for at in [Vector2(-8.4,-1.4),Vector2(-10.6,-3.),Vector2(-12.,-5.2),Vector2(-10.6,-3.),Vector2(-8.4,-1.4),Vector2(-6.,-1.3)]:
		if not await walk_to(sample,at): walked=false; print("LOOKOUT53_BLOCKED ",at); break
	verify(walked,"actual player walks up the side slope and back")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat remains available")
	var output := FileAccess.open("res://docs/lookout53-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"gap_trees":view.gap_trees.size(),"distant_batches":view.forest_batches+view.ridge_count},"\t"))
	print("LOOKOUT53 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
