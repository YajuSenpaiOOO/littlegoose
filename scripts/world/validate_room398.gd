extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 6:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room398-"+tag+".png")
func collision_state(r: Node3D) -> Array:
 var state: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):state.append([c.get_instance_id(),c.shape.get_instance_id(),c.global_transform])
 return state
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world398.gd").new();root.add_child(w);current_scene=w
 var deadline:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<deadline:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room
 w.hero.set_physics_process(false);w.companion373.hold373()
 check(r.desk_model395.wood395.shader==preload("res://scripts/room/wood395.gdshader"),"accepted A desk material restored as baseline")
 check(r.desk_model395.wood395.get_shader_parameter("paint").resource_path=="res://assets/room395/wood-atlas.png","no simplified pixel atlas in current desk")
 check(r.cabinets398.size()==2 and r.use_cabinets398,"wardrobe and washstand installed as separate real models")
 var transforms: Dictionary={}
 for id in r.cabinets398:
  var model=r.cabinets398[id];transforms[id]=model.global_transform
  check(model.legs396.size()==4,id+" has four actual feet")
  for leg in model.legs396:check(absf(leg.mesh.get_aabb().position.y-.008)<.001,id+" foot at ground")
 for row in r.old398:check(not row.node.is_visible_in_tree(),"old cabinet visual/shadow source hidden")
 var collisions: Array=collision_state(r)
 await capture("new-day")
 var key:=InputEventKey.new();key.physical_keycode=KEY_M;key.pressed=true
 w._input(key);check(not r.use_cabinets398,"actual M selects prior cabinet models")
 await capture("old-day")
 for row in r.old398:check(row.node.visible==row.visible,"comparison restores prior visibility exactly")
 w._input(key);check(r.use_cabinets398,"actual M restores new cabinets")
 check(collision_state(r)==collisions,"cabinet comparison leaves all room collision instances and transforms unchanged")
 r.set_art356(true)
 for row in r.old398:check(not row.node.is_visible_in_tree(),"legacy bed display refresh cannot re-enable old wardrobe")
 var camera_home: Transform3D=w.camera.global_transform
 w.close_cabinet398("wardrobe");await capture("wardrobe-detail")
 r.set_cabinets398(false);w.refresh367();await capture("wardrobe-old");r.set_cabinets398(true);w.refresh367()
 w.close_cabinet398("")
 check(w.camera.global_transform.is_equal_approx(camera_home),"wardrobe inspection restores normal camera")
 w.close_cabinet398("wash");await capture("wash-detail")
 w.set_night355(true);await capture("wash-night");w.set_night355(false)
 r.set_cabinets398(false);w.refresh367();await capture("wash-old");r.set_cabinets398(true);w.refresh367()
 for pair in [["front",Vector3(4.5,.05,-.05)],["north",Vector3(5.5,.05,-1.25)],["south",Vector3(5.5,.05,1.2)]]:
  w.hero.global_position=pair[1];w.hero.reset_physics_interpolation();await capture("wash-actor-"+pair[0])
 w.close_cabinet398("");check(w.camera.global_transform.is_equal_approx(camera_home),"side-angle wash inspection restores pitch yaw and position")
 w.set_night355(true);await capture("new-night");w.set_night355(false)
 w.hero.global_position=Vector3(2.15,.05,-2.0);w.hero.reset_physics_interpolation()
 for i in 55:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>-3.05,"wardrobe original footprint physically blocks actor")
 w.hero.global_position=Vector3(4.2,.05,-.05);w.hero.reset_physics_interpolation()
 for i in 45:w.hero.velocity=Vector3(2.5,0,0);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.x<5.16,"washstand original footprint physically blocks actor from its front")
 w.hero.global_position=Vector3(4.55,.05,-.05);w.interact355()
 check(w.choose355().get("id","")=="wash" and w.message355=="洗漱柜","washstand interaction approach and actual feedback retained")
 w.hero.global_position=Vector3(2.15,.05,-2.25);w.interact355()
 check(w.choose355().get("id","")=="wardrobe" and "换洗用品" in w.message355,"wardrobe actual interaction feedback retained")
 w.hero.global_position=Vector3(-2.,.05,-1.1);w.hero.reset_physics_interpolation();w.set_follow363(true)
 for i in 150:w.hero.velocity=Vector3(2.,0,0);w.hero.move_and_slide();await physics_frame
 await capture("follow")
 for id in r.cabinets398:check(r.cabinets398[id].global_transform==transforms[id],id+" and its shadow stay world-fixed under actual follow")
 w.set_follow363(false)
 var bed: Dictionary=r.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355();check(w.sleeping362,"bed still sleeps")
 w.interact355();check(not w.sleeping362,"bed still wakes")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 print("ROOM398_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
