extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room394-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world394.gd").new();root.add_child(w);current_scene=w
 var until:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<until:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room
 w.companion373.hold373();w.hero.set_physics_process(false)
 check(r.furniture394.size()==5 and r.use_furniture394,"two tables and three seats installed separately")
 var before: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):before.append(c.get_instance_id())
 for row in r.furniture394:
  check(is_equal_approx(row.sprite.pixel_size,row.density) and row.sprite.scale.is_equal_approx(Vector3.ONE),row.id+" source pixels preserve aspect")
  check(row.sprite.cast_shadow==0 and row.sprite.global_position.y>.0,row.id+" single shadow source and ground foot anchor")
  for c in row.originals:check(not c.visible or c.cast_shadow==3,row.id+" no old visible mesh behind art")
 await capture("new-day")
 r.set_furniture394(false);w.refresh367();await capture("old-day")
 check(r.lamp_light394.position==r.old_light394,"comparison restores previous physical lamp position")
 r.set_window393(false);r.set_furniture394(true);r.set_furniture394(false)
 check(r.lamp_light394.position.is_equal_approx(r.old_light394-Vector3(1.82,0,0)),"old window and old desk share old lamp anchor")
 r.set_window393(true);r.set_furniture394(true);w.refresh367()
 check(r.lamp_light394.position==r.new_light394,"painted shade and real lamp retain calibrated anchor")
 var after: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):after.append(c.get_instance_id())
 check(before==after,"comparison keeps original room and furniture collisions")
 w.set_night355(true);await capture("new-night");w.set_night355(false)
 var camera_home: Transform3D=w.camera.transform
 w.camera.global_position=Vector3(-.5,1.1,-3.)+w.camera.global_basis.z*6.5;await capture("desk-detail")
 w.camera.global_position=Vector3(3.8,.8,1.9)+w.camera.global_basis.z*5.5;await capture("tea-detail")
 for at in [Vector3(3.8,.05,3.05),Vector3(3.8,.05,.75),Vector3(2.55,.05,2.8),Vector3(5.,.05,2.8)]:
  w.hero.global_position=at;w.hero.reset_physics_interpolation();await capture("tea-actor-"+str(at.x)+"-"+str(at.z))
 w.camera.transform=camera_home
 # Actually drive the unchanged actor into each table, rather than only counting shapes.
 w.hero.global_position=Vector3(3.8,.05,3.25);w.hero.reset_physics_interpolation()
 for i in 40:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>2.55,"tea tabletop footprint physically blocks actor")
 w.hero.global_position=Vector3(.35,.05,-1.7);w.hero.reset_physics_interpolation()
 for i in 55:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>-3.,"desk footprint physically blocks actor")
 w.hero.global_position=Vector3(1.5,.05,.5);w.hero.reset_physics_interpolation()
 for i in 45:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z<-.9,"central route between tea group and desk remains open")
 var bed: Dictionary=r.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355();check(w.sleeping362,"bed still sleeps")
 w.interact355();check(not w.sleeping362,"bed still wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM394_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
