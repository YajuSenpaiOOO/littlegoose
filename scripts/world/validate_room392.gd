extends SceneTree
var failures: Array[String]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/room392-"+tag+".png")
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var w=preload("res://scripts/world/room_world392.gd").new();root.add_child(w);current_scene=w
 var until:=Time.get_ticks_msec()+45000
 while (not is_instance_valid(w.companion373) or not w.companion373.ready373) and Time.get_ticks_msec()<until:await physics_frame
 if not is_instance_valid(w.companion373) or not w.companion373.ready373:check(false,"room ready deadline");quit(1);return
 var r=w.room
 w.companion373.hold373();w.hero.set_physics_process(false)
 check(r.use_ground391 and r.floor391.material_override==r.painted_floor391 and r.rug391.material_override==r.painted_rug391,"both painted surfaces installed")
 check(r.floor391.mesh.size==Vector2(12.6,8.8) and r.floor391.position==Vector3.ZERO,"actual floor plane and height retained")
 check(r.rug391.position==Vector3(0,.013,.55),"rug remains flat on original floor anchor")
 check(absf(r.rug391.mesh.size.x/r.rug391.mesh.size.y-1317./641.)<.0001,"rug source aspect preserved")
 check(r.floor391.cast_shadow==0 and r.rug391.cast_shadow==0,"ground surfaces receive light without duplicate shadow casters")
 var shapes: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):shapes.append(c.get_instance_id())
 check(r.tall392.size()==2 and r.walls392.size()==6,"two full side walls plus four rear segments")
 for wall in r.tall392:check(wall.mesh.size==Vector3(.22,3.6,9.) and wall.position.z==0.,"continuous full-height side wall casts continuous shadow")
 for style in 3:
  r.set_style392(style);w.refresh367();await capture("wall-"+["A","B","C"][style])
 r.set_full392(false);w.refresh367();await capture("half-walls")
 r.set_full392(true);r.set_style392(0);w.refresh367()
 await capture("new-day")
 r.set_ground391(false);w.refresh367();await capture("old-day")
 check(r.floor391.material_override==r.original_floor391 and r.rug391.mesh==r.original_rug_mesh391,"comparison restores both old surfaces")
 r.set_ground391(true);w.refresh367()
 var after: Array=[]
 for c in r.find_children("*","CollisionShape3D",true,false):after.append(c.get_instance_id())
 check(shapes==after,"surface toggle leaves furniture and floor collision objects unchanged")
 var query:=PhysicsRayQueryParameters3D.create(Vector3(0,1,.55),Vector3(0,-.4,.55),1)
 var hit: Dictionary=w.get_world_3d().direct_space_state.intersect_ray(query)
 check(not hit.is_empty() and absf(hit.position.y)<.002,"real supporting floor remains under rug")
 w.set_night355(true);await capture("new-night");r.set_ground391(false);await capture("old-night")
 r.set_ground391(true);w.set_night355(false)
 w.camera.global_position=Vector3(0,.6,.6)+w.camera.global_basis.z*10.;w.camera.reset_physics_interpolation()
 await capture("ground-detail")
 w.set_pair372(true);await capture("pair");w.set_pair372(false)
 var bed: Dictionary=r.item356("bed")
 w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355()
 check(w.sleeping362,"bed sleep interaction retained")
 w.interact355();check(not w.sleeping362,"bed wake interaction retained")
 w.hero.global_position=Vector3(0,.05,-.5);w.hero.reset_physics_interpolation()
 for i in 35:
  w.hero.velocity=Vector3(0,0,2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.global_position.z>.5,"hero crosses woven rug without a new collision edge")
 w.hero.set_physics_process(true);w.reset355();w.companion373.resume373()
 var f:=FileAccess.open("res://docs/room392-validation.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"failures":failures,"collision_shapes":shapes.size(),"rug_size":str(r.painted_rug_mesh391.size)},"\t"));f.close()
 print("ROOM392_DONE ",failures)
 if failures.is_empty() and "--play-after" in OS.get_cmdline_user_args():return
 quit(0 if failures.is_empty() else 1)
