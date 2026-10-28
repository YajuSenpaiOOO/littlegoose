extends "res://scripts/ground_lab_probe.gd"
class Actor:
	extends "res://scripts/combat/hero36.gd"
	func movement_input() -> Vector2: return Vector2.ZERO
	func dash_key_down() -> bool: return false
	func parry_key_down() -> bool: return false
class Sample:
	extends "res://scripts/world/world39.gd"
	var test_time := 100.
	func _hero_script() -> Script: return Actor
	func _camera_time() -> float: return test_time
	func fire_input_held() -> bool: return false

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.buff39_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.set_process(false); sample.set_physics_process(false); sample.hero.set_physics_process(false)
	for enemy in sample.enemies: enemy.set_physics_process(false)
	sample.wave_state="waiting"; sample.framing_target=-1.
	verify(is_equal_approx(sample._framing_gain(0.),1.4),"exploration is only 7.7 percent larger than approved combat framing")
	sample.wave_state="fighting"
	verify(is_equal_approx(sample._framing_gain(0.),1.4),"combat entry begins at the current view without a zoom step")
	sample.test_time+=.1
	var early: float=sample._framing_gain(0.)
	verify(early<1.4 and early>1.398,"ease begins gently rather than using the old fast zoom step")
	sample.test_time=100.+.425
	verify(absf(sample._framing_gain(0.)-1.35)<.00001,"the new transition reaches its midpoint after 0.425 real seconds")
	sample.test_time=100.+.85
	verify(is_equal_approx(sample._framing_gain(0.),1.3),"combat settles to exactly the original framing after 0.85 seconds")
	sample.wave_state="cleared"; sample.result_dismissed=false
	verify(is_equal_approx(sample._framing_gain(0.),1.3),"result and draft keep the combat frame")
	sample.result_dismissed=true; sample._framing_gain(0.)
	sample.test_time+=.2
	var moving: float=sample._framing_gain(0.)
	sample.wave_state="fighting"
	verify(is_equal_approx(sample._framing_gain(0.),moving),"reversing a transition starts from its current value without a pop")
	sample.test_time+=1.
	sample.camera_gain=sample._framing_gain(0.)
	sample.camera.fov=rad_to_deg(2.*atan(tan(deg_to_rad(21.))/sample.camera_gain))
	sample.camera_look=Vector2(.4,.2)
	var fov: float=sample.camera.fov
	sample._reset_impact_state()
	verify(sample.camera_look==Vector2(.4,.2) and sample.camera.fov==fov and sample.camera_gain==1.3,"reset preserves both FOV and walking lookahead on auto-entry")
	var distance: float=sample.camera_distance
	var wheel := InputEventMouseButton.new(); wheel.pressed=true; wheel.button_index=MOUSE_BUTTON_WHEEL_UP
	sample._unhandled_input(wheel)
	verify(is_equal_approx(sample.camera_distance,distance/1.1),"manual wheel zoom remains independent of the cinematic blend")
	sample.wave_state="waiting"; sample.hero.controls_enabled=true
	sample.hero.velocity=Vector3(2.,-.3,-3.); sample.hero.locomotion=Vector2(2.,-3.)
	sample.start_combat(false)
	verify(sample.hero.velocity==Vector3(2.,-.3,-3.) and sample.hero.locomotion==Vector2(2.,-3.),"walking into combat preserves motion instead of applying the old trial restart brake")
	print("CAMERA39 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
