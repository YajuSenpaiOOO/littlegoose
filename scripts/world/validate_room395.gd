extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room395-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world395.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room;var d=r.desk_model395
 w.hero.set_physics_process(false);w.companion373.hold373()
 var shapes: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):shapes.append(c.get_instance_id())
 check(d.visible and d.legs395.size()==4,"visible desk has four actual independent legs")
 check(not r.furniture394[0].sprite.visible,"complete painted desk card disabled")
 var ghosts:=0
 for c in r.furniture394[0].shadows:
  if c.is_visible_in_tree():ghosts+=1
 check(ghosts==0,"old separate desk shadow proxies disabled")
 var actual_casters:=0
 for piece in d.pieces395:
  if piece.cast_shadow==1 and piece.is_visible_in_tree():actual_casters+=1
 check(actual_casters==d.pieces395.size()-2,"visible solid meshes cast shadows; thin open book only receives")
 for leg in d.legs395:
  var aabb: AABB=leg.mesh.get_aabb()
  check(absf(aabb.position.y-.008)<.001 and leg.position.y==0.,"each real leg foot rests at original floor")
 check(r.lamp_light394.position==d.lamp_anchor395,"existing physical light follows real model lamp anchor")
 await capture("new-day")
 r.set_desk395(false);w.refresh367();await capture("card-day")
 check(not d.visible and r.furniture394[0].sprite.visible,"T comparison restores complete 394 card")
 check(r.lamp_light394.position==r.new_light394,"card comparison restores its own calibrated light")
 r.set_desk395(true);w.refresh367()
 r.set_window393(false);check(r.lamp_light394.position==d.lamp_anchor395,"window comparison cannot detach model light")
 r.set_window393(true)
 var after: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):after.append(c.get_instance_id())
 check(shapes==after,"model/card/window comparisons do not change room collisions")
 w.close_desk395(true);await capture("detail-new")
 w.set_night355(true);await capture("detail-night");w.set_night355(false)
 r.set_desk395(false);w.refresh367();await capture("detail-card")
 r.set_desk395(true);w.refresh367()
 var close_home: Vector3=w.camera.global_position
 for x in [-1.4,1.4]:
  w.camera.global_position=close_home+Vector3(x,0,0);await capture("detail-offset-"+str(x))
 w.close_desk395(false)
 var model_transform: Transform3D=d.global_transform
 var foot_transforms: Array=[]
 for leg in d.legs395:foot_transforms.append(leg.global_transform)
 # Exercise actual inherited F12 follow over a continuous physical walk, not just camera teleports.
 w.hero.global_position=Vector3(-2.,.05,-1.1);w.hero.reset_physics_interpolation()
 w.set_follow363(true)
 for i in 70:
  w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("follow-left")
 for i in 100:
  w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("follow-right")
 check(w.camera.global_position.distance_to(w.camera_home363)>.25,"F12 follow actually translates the camera")
 check(d.global_transform==model_transform,"desk remains fixed in world during follow")
 for i in 4:check(d.legs395[i].global_transform==foot_transforms[i],"leg and its shadow caster keep one transform")
 w.set_follow363(false)
 w.hero.global_position=Vector3(.35,.05,-1.7);w.hero.reset_physics_interpolation()
 for i in 55:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>-3.,"actual desk footprint blocks approaching actor")
 w.close_desk395(true)
 for pair in [["front",Vector3(-.5,.05,-1.65)],["rear",Vector3(-.5,.05,-4.25)]]:
  w.hero.global_position=pair[1];w.hero.reset_physics_interpolation();await capture("actor-"+pair[0])
 w.close_desk395(false)
 var bed: Dictionary=r.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355();check(w.sleeping362,"bed still sleeps")
 w.interact355();check(not w.sleeping362,"bed still wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM395_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
