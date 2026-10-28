extends "res://scripts/world/woodland46_probe.gd"
class LightSample:
	extends "res://scripts/world/world47.gd"
	func _hero_script() -> Script: return LivingActor
	func fire_input_held() -> bool: return false

func capture47(name: String) -> Image:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/light47_"+name+".png")
	return shot

func run() -> void:
	var sample: Node3D=LightSample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.lighting47): await physics_frame
	for i in 35: await physics_frame
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 25: await physics_frame
	sample.label.get_parent().hide()
	var life: Node3D=sample.woodland_life
	var light: Node=sample.lighting47
	var atmosphere: Node3D=sample.atmosphere41
	verify(RenderingServer.get_current_rendering_method()=="gl_compatibility" and atmosphere.focus_level==2,"all profiles retain Compatibility and the same strong depth of field")
	verify(sample.garden.material_stage==1,"original stepping-stone material remains selected")
	var sprite: Sprite3D=life.lantern_root.get_child(0)
	var collider: CollisionShape3D=life.lantern_body.get_child(0)
	verify(is_equal_approx(sprite.pixel_size*1376.,2.65) and is_equal_approx(collider.shape.height,2.65) and is_equal_approx(collider.position.y,1.325),"lantern art, collider height and grounded base agree at 2.65m")
	verify(is_equal_approx(life.lantern_light.position.y,1.02*2.65/1.85) and not life.lantern_light.shadow_enabled,"lantern emission position follows the taller glass without extra shadow maps")
	var camera_before: Transform3D=sample.camera.transform
	var hero_before: Vector3=sample.hero.position
	var lamp_before: Transform3D=life.lantern_root.transform
	paused=true
	var images: Array[Image]=[]
	for i in 3:
		light.set_profile(i)
		images.append(await capture47("home%d"%i))
		verify(sample.camera.transform==camera_before and sample.hero.position==hero_before and life.lantern_root.transform==lamp_before,"profile %d changes light, never framing or layout"%i)
	verify(changed(images[0],images[1],Rect2i(150,160,1140,600))>10000 and changed(images[1],images[2],Rect2i(150,160,1140,600))>10000,"all three profiles visibly differ in the actual render")
	light.set_profile(0)
	var restored: Image=await snapshot()
	verify(changed(images[0],restored,Rect2i(Vector2i.ZERO,restored.get_size()))<100,"original profile restores its frozen rendered image")
	verify(is_equal_approx(atmosphere.environment.ambient_light_energy,light.base.ambient_light_energy) and is_equal_approx(sample.sun.light_energy,light.base_sun_energy),"original profile restores actual ambient and sun settings")
	light.set_profile(2)
	verify(atmosphere.shafts.visible and atmosphere.shafts.get_child(0).visible and not atmosphere.shafts.get_child(1).visible and atmosphere.shafts.get_child(2).visible,"soft fog profile uses only two existing feathered beam accents")
	atmosphere._set_focus_level(0)
	verify(atmosphere.focus_card.visible and not atmosphere.focus_enabled,"light grading remains active when the user disables blur")
	atmosphere._set_focus_level(2)
	paused=false
	sample._teleport15(Vector2(.88,-2.7))
	for i in 25: await physics_frame
	paused=true
	for i in 3:
		light.set_profile(i)
		await capture47("garden%d"%i)
	paused=false
	sample._teleport15(Vector2(-4.6,.7))
	sample.hero.controls_enabled=true
	verify(await walk_to(sample,Vector2(-4.6,-2.6)),"actual player still crosses the open courtyard entrance beside the taller lamp")
	sample.hero.controls_enabled=false
	light.set_profile(1)
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	verify(sample.round_index==0 and sample.enemies.size()==1,"existing first-wave encounter still starts with the new lighting")
	var output := FileAccess.open("res://docs/light47-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"lamp_height":2.65,"profiles":light.NAMES},"\t"))
	print("LIGHT47 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
