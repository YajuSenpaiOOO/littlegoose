extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 10:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room402-"+tag+".png")
func ready402(w: Node3D) -> void:
 var deadline:=Time.get_ticks_msec()+45000
 while not w.companion373.ready373 and Time.get_ticks_msec()<deadline:await physics_frame
 check(w.companion373.ready373,"companion navigation ready after layout change")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world402.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while not is_instance_valid(w.companion373) and Time.get_ticks_msec()<deadline:await process_frame
 await ready402(w);w.hero.set_physics_process(false);w.companion373.hold373()
 var r=w.room
 await capture("new-day")
 check(r.compact402 and r.roof402.visible,"compact layout and physical vault enabled")
 check(r.item356("tea").at==Vector2(4.1,1.8),"tea table visual footprint and approach moved together")
 check(w.hero.position.z<2.7,"spawn is inside shortened room")
 var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=KEY_6;w._input(key);await ready402(w);w.companion373.hold373()
 check(not r.compact402 and not r.roof402.visible,"actual 6 restores old layout and removes roof")
 check(r.item356("tea").at==Vector2(3.8,1.9),"old table footprint restored")
 for body in r.blockers402:check(body.collision_layer==0,"hidden blockouts stop colliding in old layout")
 await capture("old-day")
 w._input(key);await ready402(w);w.companion373.hold373()
 w.set_night355(true);await capture("new-night");w.set_night355(false)
 w.hero.global_position=Vector3(0,.05,.5);w.hero.reset_physics_interpolation()
 for i in 36:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z<-.7,"central route between foreground and rear remains open")
 w.hero.global_position=Vector3(-4.65,.05,2.6);w.hero.reset_physics_interpolation()
 for i in 30:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>2.2,"blockout chest physically blocks actor")
 w.hero.global_position=Vector3(0,.05,3.05);check(w.choose355().get("id","")=="exit","new doorway has working exit approach")
 w.hero.global_position=Vector3(2.15,.05,-2.25);w.interact355();check("换洗用品" in w.message355,"wardrobe reachable")
 w.hero.global_position=Vector3(4.55,.05,-.05);w.interact355();check(w.message355=="洗漱柜","washstand reachable")
 var bed: Dictionary=r.item356("bed");w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y)
 w.interact355();check(w.sleeping362,"bed sleeps");w.interact355();check(not w.sleeping362,"bed wakes")
 w.set_follow363(true)
 for at in [Vector3(-5.7,.05,-2.),Vector3(5.7,.05,2.)]:
  w.hero.global_position=at;w.hero.reset_physics_interpolation()
  for i in 45:await physics_frame
  check(absf(w.camera.position.x-w.camera_home363.x)<1.61 and absf(w.camera.position.z-w.camera_home363.z)<.13,"follow remains within interior framing limits")
  var feet: Vector2=w.camera.unproject_position(w.hero.global_position)
  var width: float=w.camera.get_viewport().get_visible_rect().size.x
  print("EDGE402 ",feet.x," / ",width)
  check(feet.x>width*.06 and feet.x<width*.94,"edge actor remains inside horizontal frame")
 await capture("follow")
 w.set_follow363(false);w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM402_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
