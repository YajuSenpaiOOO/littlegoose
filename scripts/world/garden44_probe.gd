extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	var wish := Vector2.ZERO
	func movement_input() -> Vector2: return wish
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world44.gd"
	func _hero_script() -> Script: return Actor
	func fire_input_held() -> bool: return false

func walk_to(sample: Node3D,at: Vector2) -> bool:
	for i in 320:
		var now := Vector2(sample.hero.position.x,sample.hero.position.z)
		if now.distance_to(at)<.12:
			sample.hero.wish=Vector2.ZERO
			return true
		sample.hero.wish=(at-now).normalized()
		await physics_frame
	sample.hero.wish=Vector2.ZERO
	return false

func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/garden44_"+name+".png")

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not is_instance_valid(sample.garden): await physics_frame
	for i in 35: await physics_frame
	var garden: Node3D=sample.garden
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 20: await physics_frame
	sample.label.get_parent().hide()
	verify(garden.beds.size()==3 and garden.crops.size()==20,"three independent crop beds contain modular vegetables")
	verify(garden.grass_cutouts.size()>30,"grass is removed under soil beds and stepping stones")
	verify(sample.atmosphere41.focus_level==2 and RenderingServer.get_current_rendering_method()=="gl_compatibility","approved focus and Compatibility are retained")
	await capture("home")
	sample._teleport15(Vector2(.9,-2.65))
	for i in 25: await physics_frame
	await capture("entrance")
	sample.hero.controls_enabled=true
	var aisle_ok := true
	for point in [Vector2(.9,-3.4),Vector2(.9,-5.55),Vector2(.9,-7.),Vector2(.9,-5.55),Vector2(-.05,-5.55),Vector2(.9,-5.55),Vector2(.9,-2.65)]:
		if not await walk_to(sample,point): aisle_ok=false; print("BLOCKED_AISLE ",point); break
	verify(aisle_ok,"actual player walks into the garden, between beds and back out")
	sample._travel_region("home")
	var route_ok := true
	var points: PackedVector2Array=sample.meadow.main_route
	for i in range(1,5):
		if not await walk_to(sample,points[i]): route_ok=false; print("BLOCKED_ROAD ",points[i]); break
	verify(route_ok,"existing house-to-forest road remains physically passable")
	sample._travel_region("home")
	var gate_ok := await walk_to(sample,Vector2(-4.6,.7))
	verify(gate_ok,"open front courtyard entrance remains passable")
	sample.hero.controls_enabled=false
	sample._travel_region("home")
	for i in 20: await physics_frame
	garden.set_enabled(false)
	verify(not garden.content.visible and garden.bodies[0].collision_layer==0,"garden comparison removes both art and blocking bodies")
	await capture("before")
	garden.set_enabled(true)
	verify(garden.content.visible and garden.bodies[0].collision_layer==2,"garden comparison restores its fitted collision")
	await capture("after")
	sample.start_combat()
	for enemy in sample.enemies: enemy.active_ai=false
	for i in 15: await physics_frame
	verify(sample.round_index==0 and sample.enemies.size()==1,"original encounter still starts")
	var output := FileAccess.open("res://docs/garden44-validation.json",FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"beds":garden.beds.size(),"crops":garden.crops.size(),"grass_cutouts":garden.grass_cutouts.size()},"\t"))
	print("GARDEN44 ",checks," checks; failures=",failures.size())
	quit(0 if failures.is_empty() else 1)
