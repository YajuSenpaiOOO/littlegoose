extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room397-"+tag+".png")
func geometry_state(r: Node3D) -> Array:
 var state: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):state.append([c.get_instance_id(),c.shape.get_instance_id(),c.global_transform])
 for c in r.desk_model395.pieces395:state.append([c.get_instance_id(),c.mesh.get_instance_id(),c.global_transform,c.cast_shadow,c.visible])
 state.append([r.lamp_light394.global_transform,r.lamp_light394.light_energy,r.lamp_light394.omni_range])
 return state
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world397.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room
 w.hero.set_physics_process(false);w.companion373.hold373()
 var initial: Array=geometry_state(r)
 var outside_mats: Array=[]
 for id in r.solids396:
  for piece in r.solids396[id].pieces396:outside_mats.append(piece.material_override)
 var changed:=0
 for row in r.materials397:
  if row.a!=row.b:changed+=1
 check(changed>15,"redrawn materials cover wood, book covers/pages and fabric")
 check(r.pixel397 and r.use_solids396,"B starts on same real desk model")
 var key:=InputEventKey.new();key.physical_keycode=KEY_M;key.pressed=true
 w._input(key);check(not r.pixel397,"actual M selects A")
 for row in r.materials397:check(row.piece.material_override==row.a,"A restores exact original material resource")
 w.hero.global_position=Vector3(-1.65,.05,-1.30);w.hero.reset_physics_interpolation()
 w.companion373.global_position=Vector3(.85,.05,-1.25);w.companion373.reset_physics_interpolation()
 await capture("normal-A")
 w._input(key);await capture("normal-B")
 check(geometry_state(r)==initial,"M leaves all meshes, transforms, shadow flags, collisions and lamp unchanged")
 var after: Array=[]
 for id in r.solids396:
  for piece in r.solids396[id].pieces396:after.append(piece.material_override)
 check(after==outside_mats,"tea table and all chairs keep their exact materials")
 var home: Transform3D=w.camera.transform
 w.camera.global_position=Vector3(-.5,1.,-2.4)+w.camera.global_basis.z*9.5
 r.set_pixel397(false);w.refresh367();await capture("compare-A")
 r.set_pixel397(true);w.refresh367();await capture("compare-B")
 w.set_night355(true);r.set_pixel397(false);w.refresh367();await capture("night-A")
 r.set_pixel397(true);w.refresh367();await capture("night-B");w.set_night355(false)
 w.camera.transform=home
 w.close_desk395(true)
 r.set_pixel397(false);w.refresh367();await capture("detail-A")
 r.set_pixel397(true);w.refresh367();await capture("detail-B")
 w.close_desk395(false)
 var tkey:=InputEventKey.new();tkey.physical_keycode=KEY_T;tkey.pressed=true
 w._input(tkey);check(not r.use_solids396,"T still selects historical complete card mode")
 w._input(key);check(r.use_solids396 and not r.pixel397,"M returns to real desk and selected A for material comparison")
 check(geometry_state(r)==initial,"T/M roundtrip restores same geometry/collision/light state")
 r.set_pixel397(true);w.refresh367()
 w.set_follow363(true)
 for i in 50:w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("follow-B")
 w.set_follow363(false)
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM397_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
