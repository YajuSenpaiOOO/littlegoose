extends "res://scripts/world/woodland46_probe.gd"
class StrongSample:
	extends "res://scripts/world/world54.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func shot54(name: String) -> Image:
	var image: Image=await snapshot()
	image.save_png("res://docs/captures/world_restart/air54_"+name+".png")
	return image

func run() -> void:
	var sample: Node3D=StrongSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.guide54): await physics_frame
	for i in 35: await physics_frame
	sample.hero.controls_enabled=false
	sample.label.get_parent().hide()
	var light: Node3D=sample.porch49
	var dust: Node3D=sample.sun_dust52
	verify(sample.meadow.get_script().resource_path=="res://scripts/world/world_surface21.gd" and sample.get("lookout53")==null,"53 lookout, side path, raised ground and camera lift are absent")
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility","Compatibility retained")
	verify(dust.motes.size()==96 and not light.warm_light.shadow_enabled,"particle count and shadow-map count do not increase")
	verify(not light.has_node("DoorstepVolume") and sample.garden.material_stage==1,"original house stairs and stones retained")
	sample._teleport15(Vector2(-20.13845,-27.49882))
	for i in 35: await physics_frame
	paused=true
	dust.set_enabled(false)
	light.set_fill(true)
	sample.set_presence54(false)
	var faint: Image=await shot54("shade_faint")
	var faint_tint: Color=sample.hero.visual.modulate
	var camera_before: Transform3D=sample.camera.transform
	sample.set_presence54(true)
	var stronger: Image=await shot54("shade_stronger")
	verify(sample.camera.transform==camera_before,"presence comparison preserves camera framing")
	verify(light.warm_light.light_energy>.25 and light.warm_light.omni_range==2.,"stronger fill produces a wider warmer local light")
	verify(sample.hero.visual.modulate.r>faint_tint.r*1.05,"stronger fill noticeably lifts the shaded actor")
	var area := Rect2i(Vector2i.ZERO,stronger.get_size())
	verify(changed(faint,stronger,area)>100,"stronger fill changes actual rendered pixels")
	light.set_fill(false)
	var off: Image=await shot54("shade_off")
	verify(changed(off,stronger,area)>100,"warm fill remains independently switchable")
	light.set_fill(true)
	paused=false
	sample._travel_region("home")
	dust.set_enabled(true)
	dust.set_presence(2.1,1.55,1.7,.25)
	for i in 110: await physics_frame
	paused=true
	dust.set_enabled(false)
	var clear: Image=await shot54("home_clear")
	dust.set_enabled(true)
	var pollen: Image=await shot54("home_pollen")
	verify(dust.visible_motes>3 and changed(clear,pollen,area)>20,"larger pollen is rendered in the open courtyard")
	var max_size := 0.
	for mote in dust.motes: max_size=maxf(max_size,mote.size)
	verify(max_size>.08 and max_size<.13,"dust increases size without increasing pool capacity")
	dust.update_motes(1.5)
	var drift: Image=await shot54("home_drift")
	verify(changed(drift,pollen,area)>20,"stronger pollen visibly drifts")
	paused=false
	sample._teleport15(Vector2(-4.6,.7))
	sample.hero.controls_enabled=true
	verify(await walk_to(sample,Vector2(-4.6,-2.6)),"original courtyard route remains walkable")
	sample.hero.controls_enabled=false
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 12: await physics_frame
	verify(sample.enemies.size()==1 and sample.round_index==0,"first-wave combat retained")
	sample.hurt_flash=.2
	light._update_actor()
	verify(sample.hero.visual.modulate.r>sample.hero.visual.modulate.g*1.8,"stronger fill retains red damage feedback")
	var silhouette: MeshInstance3D=sample.hero.get_node("GroundedActorSilhouette")
	verify(not sample.hero_contact.visible and silhouette.visible,"original silhouette shadow remains without duplicate ellipse")
	var output := FileAccess.open("res://docs/air54-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"pool":dust.motes.size(),"max_size_m":max_size},"\t"))
	print("AIR54 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
