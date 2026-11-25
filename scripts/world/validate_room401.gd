extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func state401(w: Node3D) -> Array:
 var state: Array=[]
 for c in w.room.find_children("*","CollisionShape3D",true,false):state.append([c.get_instance_id(),c.shape.get_instance_id(),c.global_transform])
 for c in w.room.find_children("*","MeshInstance3D",true,false):state.append([c.get_instance_id(),c.global_transform,c.visible,c.cast_shadow])
 for c in w.find_children("*","Light3D",true,false):state.append([c.get_instance_id(),c.global_transform,c.light_energy,c.light_color])
 state.append(w.hero.global_transform);return state
func capture(tag: String) -> void:
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room401-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world401.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:quit(1);return
 w.hero.set_physics_process(false);w.companion373.hold373()
 for i in 5:await process_frame
 # Freeze the host's decorative hourglass pulse for identical A/B/C frames.
 w.set_process(false);w.follow_label363.visible=false
 var initial: Array=state401(w)
 var original_camera: Transform3D=w.camera.global_transform
 for index in 3:
  var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_6+index;w._input(key)
  check(w.view401==index and w.camera.fov==42.,"actual preset key selects view with fixed FOV")
  await capture(["A","B","C"][index])
  check(state401(w)==initial,"preset changes no actor geometry furniture collision or lighting")
 w.set_view401(0);check(w.camera.global_transform.is_equal_approx(original_camera),"A restores original400 camera exactly")
 w.set_process(true)
 w.set_view401(2);w.set_night355(true);await capture("C-night");w.set_night355(false)
 w.close_cabinet398("wash");w.set_view401(1)
 check(w.close398.is_empty() and absf(w.camera.rotation_degrees.y)<.001,"preset exits side-angle wash inspector cleanly")
 w.set_follow363(true);w.set_view401(2)
 check(w.follow363,"preset switch preserves active follow preference")
 w.hero.global_position=Vector3(-2.,.05,-1.1);w.hero.reset_physics_interpolation()
 for i in 140:w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("C-follow")
 check(w.camera.global_position.distance_to(w.camera_home363)>.1,"C uses actual original follow controller")
 w.set_follow363(false);w.set_view401(0)
 var bed: Dictionary=w.room.item356("bed");w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y)
 w.interact355();check(w.sleeping362,"bed sleeps");w.interact355();check(not w.sleeping362,"bed wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM401_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
