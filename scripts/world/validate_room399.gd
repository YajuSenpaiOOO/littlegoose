extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room399-"+tag+".png")
func collision_state(r: Node3D) -> Array:
 var state: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):state.append([c.get_instance_id(),c.shape.get_instance_id(),c.global_transform])
 return state
func light_state(w: Node3D) -> Array:
 var state: Array=[]
 for c in w.find_children("*","Light3D",true,false):state.append([c.get_instance_id(),c.global_transform,c.light_energy,c.light_color])
 return state
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world399.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room;var frame=r.frame399
 w.hero.set_physics_process(false);w.companion373.hold373()
 for i in 3:await process_frame
 var collisions: Array=collision_state(r);var lights: Array=light_state(w)
 check(r.use_frame399 and frame.visible,"new architectural frame starts enabled")
 check(r.old_frame399.size()==3,"only former straight lintel and two rear corner posts replaced")
 check(frame.gable399.material_override==r.paper392,"arched wall extension shares actual wallpaper coordinates/material")
 check(frame.find_children("*","CollisionShape3D",true,false).is_empty(),"overhead structure and shallow wall pilasters do not add floor obstacles")
 check(frame.braces399.size()==2,"two curved corner supports installed")
 check(frame.outer399(0.)>frame.outer399(6.25)+.9,"rear wall has an actual arched upper silhouette")
 await capture("new-day")
 var key:=InputEventKey.new();key.physical_keycode=KEY_3;key.pressed=true
 w._input(key);check(not frame.visible and not r.use_frame399,"actual 3 key selects original architecture")
 for c in r.old_frame399:check(c.visible,"old straight frame restored")
 await capture("old-day")
 w._input(key);w.set_night355(true);await capture("new-night")
 r.set_frame399(false);w.refresh367();await capture("old-night")
 w.set_night355(false);r.set_frame399(true);w.refresh367()
 for i in 3:await process_frame
 check(collision_state(r)==collisions,"new/old arch toggle preserves every floor/furniture collision")
 check(light_state(w)==lights,"day reset and architecture toggle preserve original light energy/colors/transforms")
 var camera_home: Transform3D=w.camera.global_transform
 w.camera.global_position=Vector3(0,2.,-3.8)+w.camera.global_basis.z*12.
 await capture("rear-detail")
 for x in [-1.4,1.4]:
  w.camera.global_position=Vector3(x,2.,-3.8)+w.camera.global_basis.z*12.;await capture("offset-"+str(x))
 w.camera.global_transform=camera_home
 w.hero.global_position=Vector3(-2.,.05,-1.1);w.hero.reset_physics_interpolation();w.set_follow363(true)
 var architecture_transform: Transform3D=frame.global_transform
 for i in 150:w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("follow")
 check(w.hero.global_position.x>.4,"existing interior route remains physically traversable")
 check(frame.global_transform==architecture_transform,"timbers and their shadow geometry remain fixed during follow")
 w.set_follow363(false)
 w.hero.global_position=Vector3(2.15,.05,-2.25);w.interact355()
 check("换洗用品" in w.message355,"wardrobe interaction remains accessible")
 w.hero.global_position=Vector3(4.55,.05,-.05);w.interact355()
 check(w.message355=="洗漱柜","washstand interaction remains accessible")
 var bed: Dictionary=r.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355();check(w.sleeping362,"bed still sleeps")
 w.interact355();check(not w.sleeping362,"bed still wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM399_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
