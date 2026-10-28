extends "res://scripts/ground_lab_probe.gd"
class Sample:
	extends "res://scripts/world/world40.gd"
	func fire_input_held() -> bool: return false

func settle(sample: Node3D) -> void:
	for i in 120: sample._update_impact_camera(1./60.)

func run() -> void:
	var sample: Node3D=Sample.new()
	root.add_child(sample)
	while not sample.buff39_ready: await physics_frame
	sample.set_process_unhandled_input(false)
	sample.set_process(false); sample.set_physics_process(false); sample.hero.set_physics_process(false)
	for enemy in sample.enemies: enemy.set_physics_process(false)
	sample.wave_state="waiting"; sample._reset_impact_state()
	settle(sample)
	verify(sample.camera_gain==1. and is_equal_approx(sample.camera.fov,42.),"exploration restores world37's original gain 1.0 and 42-degree FOV")
	verify(sample._base_zoom_delta()==0. and sample._framing_gain(0.)==1.,"exploration no longer uses either portrait-camera zoom")
	sample.wave_state="fighting"
	sample._update_impact_camera(1./60.)
	verify(absf(sample.camera_gain-1.04)<.00001,"combat uses world37's original frame-by-frame camera response")
	settle(sample)
	verify(absf(sample.camera_gain-1.3)<.00001,"combat keeps the approved original gain 1.3")
	verify(is_equal_approx(sample.camera.fov,rad_to_deg(2.*atan(tan(deg_to_rad(21.))/1.3))),"combat FOV equals the pre-camera-change version")
	sample.wave_state="cleared"; sample.result_dismissed=false
	settle(sample)
	verify(absf(sample.camera_gain-1.)<.00001,"post-combat state also follows the old camera logic")
	sample.wave_state="defeated"
	verify(sample._base_zoom_delta()==0.,"defeat has the old non-fighting base zoom")
	sample.camera_look=Vector2(.5,.25); sample.camera_gain=1.4; sample.camera.fov=28.
	sample._reset_impact_state()
	verify(sample.camera_gain==1. and sample.camera.fov==42. and sample.camera_look==Vector2.ZERO,"camera reset fully restores world37 rather than preserving later portrait state")
	var distance: float=sample.camera_distance
	var wheel := InputEventMouseButton.new(); wheel.pressed=true; wheel.button_index=MOUSE_BUTTON_WHEEL_UP
	sample._unhandled_input(wheel)
	verify(is_equal_approx(sample.camera_distance,distance/1.1),"original wheel zoom remains available")
	verify(is_equal_approx(sample.camera.rotation_degrees.x,-25.),"rollback preserves the established perspective angle")
	print("CAMERA40 ",checks," checks; failures=",failures.size())
	sample.queue_free(); await process_frame
	quit(0 if failures.is_empty() else 1)
