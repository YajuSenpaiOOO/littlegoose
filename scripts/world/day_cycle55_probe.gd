extends "res://scripts/world/woodland46_probe.gd"
class DaySample:
	extends "res://scripts/world/world55.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot55(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/day55_"+name+".png")
	return image

func average55(image: Image) -> Color:
	var sum := Vector3.ZERO
	var count := 0.
	for y in range(200,800,8):
		for x in range(200,1350,8):
			var c := image.get_pixel(x,y)
			sum+=Vector3(c.r,c.g,c.b)
			count+=1.
	return Color(sum.x/count,sum.y/count,sum.z/count)

func run() -> void:
	var settings: Resource=load("res://assets/lighting55/woodland_day.tres")
	var sim: RefCounted=load("res://scripts/world/day_clock55.gd").new(settings)
	var start: float=sim.hour
	sim.advance(60.)
	verify(is_equal_approx(sim.hour,start+.75),"normal time advances independently of battle waves")
	start=sim.hour
	sim.advance(60.,true)
	verify(sim.hour==start,"blocked time does not advance")
	sim.paused=true
	sim.advance(60.)
	verify(sim.hour==start,"manual pause stops clock")
	sim.paused=false
	sim.advance(100000.)
	verify(sim.hour==24. and sim.day==1 and sim.at_deep_night(),"deep night holds without automatic next day")
	sim.advance(100000.)
	verify(sim.hour==24. and sim.day==1,"deep-night hold is stable")
	sim.sleep_to_morning()
	verify(sim.day==2 and sim.hour==6.5,"sleep advances exactly one day to morning")
	var continuous := true
	for anchor in settings.keys:
		var before: Dictionary=settings.sample(anchor.hour-.001)
		var after: Dictionary=settings.sample(anchor.hour+.001)
		for key in ["energy","air","exposure","rays","daylight","lamps","dust"]:
			continuous=continuous and absf(before[key]-after[key])<.001
	verify(continuous,"all anchor boundaries preserve continuous light, haze, dust and lamp weights")
	var sample: Node3D=DaySample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.time55) or not sample.time55.is_node_ready(): await physics_frame
	for i in 40: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var time: Node=sample.time55
	var c: RefCounted=time.clock55
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd","original terrain retained, no lookout")
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	paused=true
	time.focused=true
	time.preview=false
	c.hour=10.
	sample.combat_paused=true
	time._process(1.)
	verify(c.hour==10.,"integrated battle/menu pause stops world time")
	sample.combat_paused=false
	time.focused=false
	time._process(1.)
	verify(c.hour==10.,"unfocused game stops world time")
	time.focused=true
	sample.draft_open=true
	time._process(1.)
	verify(c.hour==10.,"card selection stops world time")
	sample.draft_open=false
	time.preview_at(22.)
	var before_hour: float=time.visual_hour
	time._process(.016)
	verify(time.visual_hour>before_hour and time.visual_hour<22.,"debug preview transitions through intermediate light instead of snapping")
	time.resume_natural()
	c.hour=10.
	time._process(1.)
	verify(c.hour>10.,"normal exploration advances integrated world time")
	var camera_before: Transform3D=sample.camera.transform
	var images: Array[Image]=[]
	var averages: Array[Color]=[]
	var cache_count: int=sample.porch49.shader_cache.size()
	for hour in [8.,12.,18.,22.]:
		time.preview_at(hour)
		time.visual_hour=hour
		time.apply_look()
		images.append(await shot55("home_"+str(int(hour))))
		averages.append(average55(images[-1]))
	verify(sample.camera.transform==camera_before,"four times preserve identical camera and layout")
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	verify(changed(images[0],images[1],area)>50000 and changed(images[1],images[2],area)>50000 and changed(images[2],images[3],area)>50000,"four times visibly change actual scenery pixels")
	verify(averages[1].get_luminance()>averages[3].get_luminance()*1.45,"noon is visibly brighter than night")
	verify(averages[3].b/averages[3].r>averages[1].b/averages[1].r*1.10,"night scenery shifts cooler blue than noon")
	verify(sample.porch49.house_material.get_shader_parameter("window_emission55")>.7,"night keeps authored windows self-lit")
	verify(time.dust_day_material.get_shader_parameter("day_visibility55")==0. and not sample.atmosphere41.shafts.visible,"night removes sun dust and sun shafts")
	verify(sample.sun_dust52.motes.size()==96 and not sample.porch49.warm_light.shadow_enabled,"fixed particle pool and no new local shadow maps")
	verify(sample.porch49.shader_cache.size()==cache_count,"time changes reuse shaders rather than rebuilding the forest")
	paused=false
	sample._travel_region("trail")
	for i in 35: await physics_frame
	paused=true
	for hour in [8.,18.,22.]:
		time.preview_at(hour)
		time.visual_hour=hour
		time.apply_look()
		await shot55("trail_"+str(int(hour)))
	time.visual_hour=8.
	time.apply_look()
	var rays: Image=await shot55("trail_morning_rays")
	sample.atmosphere41.shafts.hide()
	var no_rays: Image=await shot55("trail_morning_clear")
	verify(changed(rays,no_rays,area)>100,"morning rays render at reusable nearby forest openings")
	sample.label.get_parent().show()
	time.update_guide()
	await shot55("guide")
	sample.label.get_parent().hide()
	paused=false
	sample._travel_region("home")
	for i in 20: await physics_frame
	var old_day: int=c.day
	var buff_summary: String=sample.buffs.summary()
	sample.player_hp=45.
	verify(await time.sleep_to_morning(),"home interaction can complete sleep fade")
	verify(c.day==old_day+1 and c.hour<6.6 and sample.player_hp==100.,"sleep restores health and wakes next morning")
	verify(sample.buffs.summary()==buff_summary and not sample.combat_paused,"sleep preserves cards and releases gameplay pause")
	sample.hero.controls_enabled=true
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	verify(not time.can_sleep() and sample.enemies.size()==1 and sample.round_index==0,"combat blocks sleep and preserves first-wave encounter")
	sample.hurt_flash=.2
	sample.porch49._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"daylight fill preserves damage feedback")
	var file := FileAccess.open("res://docs/day55-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"home_average_colors":averages,"shader_cache":cache_count},"\t"))
	print("DAY55 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
