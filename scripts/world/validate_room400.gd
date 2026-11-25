extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room400-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world400.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:quit(1);return
 var r=w.room;w.hero.set_physics_process(false);w.companion373.hold373()
 var collisions: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):collisions.append(c.get_instance_id())
 check(r.vines400.leaf_count400>30,"three sparse vine groups have actual folded leaves")
 check(r.vines400.find_children("*","CollisionShape3D",true,false).is_empty(),"wall hanging vines add no navigation obstacles")
 await capture("new-day")
 var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_4;w._input(key)
 check(not w.warm400 and is_equal_approx(w.sun.light_energy,.72) and w.window400.light_energy==0.,"4 restores original daylight and disables added window pool")
 for row in w.lamps400:check(is_equal_approx(row.light.light_energy,row.energy),"original lamp energy restored")
 r.set_vines400(false);w.refresh367();await capture("old-day")
 w._input(key);await capture("light-only")
 key.physical_keycode=KEY_5;w._input(key);check(r.vines400.visible,"5 independently restores vines")
 await capture("new-day")
 w.set_night355(true);await capture("new-night")
 check(w.window400.light_energy==0. and is_equal_approx(w.sun.light_energy,.035),"night stops daytime window light")
 w.warm400=false;w.apply400();w.refresh367();await capture("old-night")
 w.warm400=true;w.set_night355(false);w.refresh367()
 var after: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):after.append(c.get_instance_id())
 check(after==collisions,"both visual toggles leave original collisions intact")
 var home: Transform3D=w.camera.global_transform
 w.camera.global_position=Vector3(0,2.,-3.8)+w.camera.global_basis.z*12.;await capture("rear-detail");w.camera.global_transform=home
 var vine_transform: Transform3D=r.vines400.global_transform
 w.hero.global_position=Vector3(-2.,.05,-1.1);w.hero.reset_physics_interpolation();w.set_follow363(true)
 for i in 150:w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.x>.4 and r.vines400.global_transform==vine_transform,"actual walk and camera follow retain vine anchors")
 w.set_follow363(false)
 var bed: Dictionary=r.item356("bed");w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y)
 w.interact355();check(w.sleeping362,"bed sleeps");w.interact355();check(not w.sleeping362,"bed wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM400_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
