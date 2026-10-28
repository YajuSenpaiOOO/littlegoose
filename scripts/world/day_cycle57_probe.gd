extends "res://scripts/world/woodland46_probe.gd"
class DaySample:
	extends "res://scripts/world/world57.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot55(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/day57_"+name+".png")
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
	var settings: Resource=load("res://assets/lighting55/woodland_day57.tres")
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
	var directions56: Array[Vector3]=[]
	var projection56: Array[float]=[]
	var images: Array[Image]=[]
	var averages: Array[Color]=[]
	var cache_count: int=sample.porch49.shader_cache.size()
	for hour in [8.,12.,18.,22.]:
		time.preview_at(hour)
		time.visual_hour=hour
		time.apply_look()
		var direction56: Vector3=-sample.sun.global_basis.z.normalized()
		directions56.append(direction56)
		projection56.append(Vector2(direction56.x,direction56.z).length()/absf(direction56.y))
		for shadow in sample.actor_shadows: shadow._physics_process(0.)
		images.append(await shot55("home_"+str(int(hour))))
		averages.append(average55(images[-1]))
	verify(directions56[0].x>0. and directions56[2].x<0.,"morning and evening shadows face opposite horizontal directions")
	verify(projection56[2]>projection56[1]*3.,"late-afternoon projection is more than three times noon length")
	verify(sample.actor_shadows[0].light_direction.is_equal_approx(directions56[3]),"actor silhouette follows current sun/moon direction")
	verify(sample.sun.shadow_opacity<.3 and sample.actor_shadows[0].opacity_scale<.5,"night native and actor shadows soften together")
	verify(not time.window_spill56.shadow_enabled and time.window_spill56.light_energy>1.,"one bounded cottage spill lights nearby surfaces without a shadow map")
	verify(sample.woodland_life.lantern_light.omni_range==5. and sample.woodland_life.lantern_light.light_energy>2.,"night lantern lights the surrounding path")
	var area := Rect2i(Vector2i.ZERO,images[0].get_size())
	var trajectory_ok := true
	var previous_azimuth := 65.
	for step in 81:
		var hour := 18.+float(step)*.05
		var look: Dictionary=settings.sample(hour)
		if hour<=19.: trajectory_ok=trajectory_ok and look.azimuth56>=previous_azimuth-.001
		if hour>19. and hour<=20.5: trajectory_ok=trajectory_ok and look.shadow_opacity56==0.
		if hour>20.5: trajectory_ok=trajectory_ok and is_equal_approx(look.azimuth56,-32.)
		previous_azimuth=look.azimuth56
	verify(trajectory_ok,"sunset continues forward; moon direction changes only while shadows are absent")
	verify(time.accents57.flies.size()==32 and time.accents57.firefly_emitter.light==null,"32 pooled fireflies use no individual point lights")
	time.preview_at(19.8)
	time.visual_hour=19.8
	time.apply_look()
	verify(sample.sun.shadow_opacity==0. and sample.actor_shadows[0].opacity_scale==0.,"native and actor shadows disappear together during moon handoff")
	time.preview_at(22.)
	time.visual_hour=22.
	time.apply_look()
	time.accents57.update_accents(0.)
	verify(time.accents57.stage_light.visible and not time.accents57.stage_light.shadow_enabled,"night spotlight is one unshadowed light")
	verify(time.cottage_emitter57.preset.spill_night==2.6 and time.lantern_emitter57.preset.range_night==5.,"house and lantern use reusable glow presets")
	var all_on: Image=await shot55("night_all_on")
	time.accents57.fireflies_enabled=false
	time.apply_look()
	var no_flies: Image=await shot55("night_no_flies")
	verify(changed(all_on,no_flies,area)>30,"fireflies change actual night pixels")
	time.accents57.stage_enabled=false
	time.apply_look()
	var no_stage: Image=await shot55("night_no_stage")
	verify(changed(no_flies,no_stage,area)>100,"spotlight and soft air cone change actual night pixels")
	verify(sample.porch49.stage_strength57==0.,"turning off stage light also removes actor warm response")
	time.haze_enabled57=false
	time.apply_look()
	var no_haze: Image=await shot55("night_no_haze")
	verify(changed(no_stage,no_haze,area)>100,"distance haze changes actual distant scenery pixels")
	var pose_count: int=time.pose_updates57
	for i in 30: time.apply_look()
	verify(time.pose_updates57==pose_count,"paused time does not repeatedly update the sun transform")
	time.accents57.fireflies_enabled=true
	time.accents57.stage_enabled=true
	time.haze_enabled57=true
	time.visual_hour=12.
	time.apply_look()
	verify(not time.accents57.fireflies.visible and not time.accents57.stage_light.visible,"night accents switch off during daytime")
	time.visual_hour=22.
	time.apply_look()
	verify(sample.camera.transform==camera_before,"four times preserve identical camera and layout")
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
	time.preview_at(8.)
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
	var file := FileAccess.open("res://docs/day57-validation.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"home_average_colors":averages,"shader_cache":cache_count,"projection_ratios":projection56},"\t"))
	print("DAY57 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
