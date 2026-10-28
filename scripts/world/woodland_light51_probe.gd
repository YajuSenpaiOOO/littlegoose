extends "res://scripts/world/woodland46_probe.gd"
class WoodlandSample:
	extends "res://scripts/world/world51.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot51(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/woodland51_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=WoodlandSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.porch49): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var light: Node3D=sample.porch49
	var data: Dictionary=light.woodland_data
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(data.tree_count==sample.trees.size(),"density atlas includes actual scene trees and framing trees")
	verify(data.regions.size()==5 and data.openings.size()>10,"five routes use reusable regional presets")
	verify(not light.has_node("DoorstepVolume") and sample.garden.material_stage==1,"intact stairs and original stones retained")
	var config: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lighting51/regions.json"))
	var baker=preload("res://scripts/art/woodland_light_baker51.gd").new()
	baker.prepare(sample.trees,sample.meadow,config)
	var dense: Dictionary={}
	for opening in data.openings:
		var at := Vector2(opening.at[0],opening.at[1])
		if at.distance_to(Vector2(-4.7,-2.8))<16.: continue
		if dense.is_empty() or opening.density>dense.density: dense=opening
	var dense_at := Vector2(dense.at[0],dense.at[1])
	var base: Color=baker.tint_at(dense_at,false)
	var sun: Color=baker.tint_at(dense_at,true)
	verify(baker.density_at(dense_at)>.35 and sun.r>base.r+.15,"independent sunlight remains bright inside dense woodland")
	var sparse := baker.density_at(Vector2(-4.7,.5))
	verify(sparse<baker.density_at(dense_at),"open courtyard has lower canopy density than a wooded opening")
	var saved: Array=data.openings[5].at
	verify(baker.openings[5].at.distance_to(Vector2(saved[0],saved[1]))<.0001,"regional layouts reproduce deterministically")
	sample._travel_region("home")
	for i in 25: await physics_frame
	paused=true
	light.set_profile(0)
	var home_before: Image=await shot51("home50")
	light.set_profile(2)
	var home_after: Image=await shot51("home")
	var center: Vector2i=Vector2i(sample.camera.unproject_position(sample.house_art.global_position+Vector3.UP*2.))
	verify(changed(home_before,home_after,Rect2i(center-Vector2i(90,100),Vector2i(180,200)))<100,"central house lighting remains unchanged")
	paused=false
	sample._travel_region("trail")
	for i in 30: await physics_frame
	paused=true
	var camera_before: Transform3D=sample.camera.transform
	var images: Array[Image]=[]
	for i in 3:
		light.set_profile(i)
		images.append(await shot51("trail%d"%i))
		verify(camera_before==sample.camera.transform,"profile %d retains identical framing"%i)
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[2],area)>100000,"density and openings visibly change the same view")
	verify(changed(images[1],images[2],area)>10000,"independent openings visibly brighten density-only woodland")
	light.set_profile(0)
	var restored: Image=await snapshot()
	verify(changed(restored,images[0],area)<100,"original 50 lighting restores cleanly")
	paused=false
	sample._teleport15(dense_at)
	for i in 30: await physics_frame
	paused=true
	for mode in [1,2]:
		light.set_profile(mode)
		await shot51("dense%d"%mode)
	paused=false
	for region in ["grove","shore"]:
		sample._travel_region(region)
		for i in 30: await physics_frame
		await shot51(region)
		var p: Vector3=sample.hero.global_position
		verify(light.sample_field(Vector2(p.x,p.z)).a>.95,"regional atlas covers "+region)
	sample._teleport15(sample.meadow.main_route[1])
	sample.hero.controls_enabled=true
	var route_ok := true
	for i in range(2,7):
		if not await walk_to(sample,sample.meadow.main_route[i]): route_ok=false; break
	verify(route_ok,"actual player walks from courtyard into forest")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat retained")
	sample.hurt_flash=.2
	light._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"regional lighting preserves damage flash")
	var output := FileAccess.open("res://docs/woodland51-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"trees":data.tree_count,"regions":data.regions.size(),"openings":data.openings.size(),"dense_opening":dense},"\t"))
	print("WOODLAND51 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
