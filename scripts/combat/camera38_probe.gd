extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	func movement_input() -> Vector2: return Vector2.ZERO
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world38.gd"
	func _hero_script() -> Script: return Actor
	func fire_at(_target: Vector3) -> void: pass

func settle(sample: Node3D) -> void:
	for i in 100: sample._update_impact_camera(1./60.)

func actor_height(sample: Node3D) -> float:
	return sample.camera.unproject_position(sample.hero.position).distance_to(sample.camera.unproject_position(sample.hero.position+Vector3.UP*1.6))

func capture(name: String) -> void:
	var shot: Image=await snapshot()
	shot.save_png("res://docs/captures/world_restart/camera38_"+name+".png")

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.encounter37_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.start_combat(); sample.set_cup_phone(false)
	for enemy in sample.enemies: enemy.active_ai=false; enemy.set_physics_process(false)
	for i in 25: await physics_frame
	sample.set_process(false); sample.set_physics_process(false); sample.hero.set_physics_process(false)
	sample._update_camera(0.,true)
	settle(sample)
	var fighting_fov: float=sample.camera.fov
	var fighting_height := actor_height(sample)
	var distance: float=sample.camera_distance
	verify(is_equal_approx(sample.camera_gain,1.3),"combat keeps the approved 1.3 framing gain")
	verify(is_equal_approx(fighting_fov,rad_to_deg(2.*atan(tan(deg_to_rad(21.))/1.3))),"combat FOV exactly matches world37")
	await capture("combat")
	sample.between_left=2.
	verify(sample._base_zoom_delta()==1.2,"breathers stay wide instead of pumping between rounds")
	sample.between_left=0.; sample.wave_state="cleared"; sample.result_dismissed=false
	verify(sample._base_zoom_delta()==1.2,"victory camera and result retain the combat frame")
	sample.wave_state="defeated"
	verify(sample._base_zoom_delta()==1.2,"defeat result retains the combat frame")
	sample.wave_state="cleared"; sample.result_dismissed=true
	var before: float=sample.camera_gain
	sample._update_impact_camera(1./60.)
	verify(sample.camera_gain>before and sample.camera_gain<1.55,"continuing exploration blends toward the closer frame without a hard jump")
	settle(sample)
	verify(is_equal_approx(sample.camera_gain,1.55) and sample.camera.fov<fighting_fov,"exploration settles to the closer 1.55 frame")
	verify(absf(actor_height(sample)/fighting_height-1.55/1.3)<.002,"hero is about nineteen percent larger in exploration at the same location")
	verify(sample.camera_distance==distance and is_equal_approx(sample.camera.rotation_degrees.x,-25.),"framing preserves camera distance and the 25-degree viewing angle")
	for enemy in sample.enemies: enemy.hide()
	await capture("exploration")
	var exploration_fov: float=sample.camera.fov
	sample.start_combat(false)
	for enemy in sample.enemies: enemy.active_ai=false; enemy.set_physics_process(false)
	verify(is_equal_approx(sample.camera_gain,1.55) and sample.camera.fov==exploration_fov,"entering battle preserves the current view rather than flashing to the old wide baseline")
	sample._update_impact_camera(1./60.)
	verify(sample.camera_gain<1.55 and sample.camera_gain>1.3,"battle entry eases outward toward the original combat frame")
	settle(sample)
	verify(is_equal_approx(sample.camera.fov,fighting_fov),"battle transition returns to exactly the previous combat FOV")
	var wheel := InputEventMouseButton.new()
	wheel.button_index=MOUSE_BUTTON_WHEEL_UP; wheel.pressed=true
	sample._unhandled_input(wheel)
	verify(is_equal_approx(sample.camera_distance,distance/1.1),"manual wheel zoom still controls camera distance")
	sample._travel_region("home")
	settle(sample)
	verify(is_equal_approx(sample.camera_gain,1.55) and is_equal_approx(sample.camera_distance,distance/1.1),"leaving battle restores exploration framing while retaining manual zoom")
	print("CAMERA38 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
