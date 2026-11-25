extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 18:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/home405-"+tag+".png")
func key405(w: Node,code: int) -> void:
 var key:=InputEventKey.new();key.physical_keycode=code;key.pressed=true;w._input(key)
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var session=load("res://scenes/world/world405.tscn").instantiate();root.add_child(session);current_scene=session
 var begin:=Time.get_ticks_msec()
 while not session.ready405 and Time.get_ticks_msec()-begin<160000:await process_frame
 check(session.ready405,"full map and fit preview ready")
 if not session.ready405:quit(2);return
 var w=session.host405
 w.hero.set_physics_process(false);w.time55.preview_at(10.);w.time55.visual_hour=10.;w.time55.apply_look()
 var old_body: int=w.cottage_body.get_instance_id();var hero_basis: Basis=w.hero.visual.basis;var camera_at: Transform3D=w.camera.global_transform
 var props: Array=[]
 for row in w.props15:props.append([row.root,row.root.global_transform])
 props.append([w.workshop116.pot,w.workshop116.pot.global_transform]);props.append([w.workshop116.tin,w.workshop116.tin.global_transform])
 for mode in [1,2,3]:
  key405(w,KEY_0+mode)
  for i in 4:await physics_frame
  check(w.mode405==mode,"actual numeric input selects mode "+str(mode))
  check(w.camera.global_transform==camera_at,"same camera across placement comparisons")
  check(w.cottage_body.get_instance_id()==old_body,"old house collider instance retained")
  check(w.hero.visual.basis==hero_basis,"192 display orientation unchanged")
  if mode==1:
   check(w.cottage_root.visible and w.cottage_body.collision_layer==w.old_layer405,"old visual and collision restored")
   var off:=true
   for body in w.model405.find_children("*","CollisionObject3D",true,false):off=off and body.collision_layer==0
   check(off,"new hidden house stops colliding in old mode")
  else:
   check(not w.cottage_root.visible and w.cottage_body.collision_layer==0,"old house and shadow proxy disabled")
   var q:=PhysicsRayQueryParameters3D.create(w.model405.position+Vector3(3,1.,4.),w.model405.position+Vector3(3,1.,1.),1<<25)
   var hit: Dictionary=w.get_world_3d().direct_space_state.intersect_ray(q)
   check(not hit.is_empty(),"native front wall has real collision")
   var door_at: Vector3=w.model405.door404.global_position
   check(door_at.distance_to(w.model405.to_global(Vector3(-1.015,.025,2.88)))<.001,"door leaf follows relocated house in world coordinates")
   q=PhysicsRayQueryParameters3D.create(w.model405.position+Vector3(0,1.,4.),w.model405.position+Vector3(0,1.,2.),1<<25)
   hit=w.get_world_3d().direct_space_state.intersect_ray(q)
   check(not hit.is_empty() and hit.collider==w.model405.door404,"closed door collision moves together with relocated facade")
  await capture("mode"+str(mode))
 var intact:=true
 for row in props:intact=intact and row[0].global_transform==row[1]
 check(intact,"original yard props and workshop were not relocated")
 key405(w,KEY_F9);check(not w.overview405,"ordinary follow can be selected");await capture("follow")
 key405(w,KEY_F8);key405(w,KEY_8)
 for i in 90:await process_frame
 await capture("night")
 key405(w,KEY_8);w.time55.visual_hour=10.;w.time55.apply_look();key405(w,KEY_3);w.home405()
 # A real ground query around the approach supplies traversability evidence without moving props.
 var nav=preload("res://scripts/combat/woodland_navigation21.gd").new()
 nav.bake(w.get_world_3d().direct_space_state,w.meadow,Vector2(-6.,-2.))
 var to_forest: PackedVector2Array=nav.path(w.door405()+Vector2(0,3.),Vector2(-15.,-2.))
 print("FIT405_APPROACH_ROUTE ",to_forest.size())
 FileAccess.open("res://docs/home405-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"failures":failures,"sites":w.reports405,"approach_route_points":to_forest.size()},"\t"))
 w.hero.set_physics_process(true);w.hero.controls_enabled=true
 print("FIT405_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
