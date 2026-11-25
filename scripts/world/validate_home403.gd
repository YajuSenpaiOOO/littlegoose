extends SceneTree
var failures: Array[String]=[]
var frame_ms403: Array[float]=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func capture(tag: String) -> void:
 for i in 8:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/home403-"+tag+".png")
func key403(w: Node,code: int) -> void:
 var key:=InputEventKey.new();key.pressed=true;key.physical_keycode=code;w._input(key)
func settle(w: Node) -> void:
 while w.moving_camera403:
  var tick:=Time.get_ticks_usec();await process_frame;frame_ms403.append(float(Time.get_ticks_usec()-tick)/1000.)
 for i in 10:await physics_frame
func _initialize() -> void:call_deferred("run")
func run() -> void:
 var start:=Time.get_ticks_msec()
 var packed: PackedScene=load("res://scenes/world/world403.tscn");var session=packed.instantiate();root.add_child(session);current_scene=session
 while not session.ready403:
  if Time.get_ticks_msec()-start>60000:print("HOME403_TIMEOUT");quit(2);return
  await process_frame
 var w=session.host403;var r=w.room
 check(not w.inside403 and w.companion373.ready373,"starts in yard with both actors ready")
 check(r.floor391.position.z+r.floor391.mesh.size.y*.5<2.701,"indoor wood ends at threshold")
 for saved in r.shell_state402:
  if saved.has("mesh") and absf(saved.at.y+.22)<.01 and saved.mesh.size.x>12.:
   check(saved.node.position.z+saved.node.mesh.size.z*.5<2.701,"foundation remains trimmed after inherited layout setup")
 check(preload("res://scripts/room/mesh_cache403.gd").valid403,"baked bed geometry signatures match")
 check(not ResourceLoader.has_cached("res://scenes/world/world169.tscn"),"legacy world is not loaded into the home session")
 var scene_id:=session.get_instance_id();var hero_id: int=w.hero.get_instance_id();var room_id: int=r.get_instance_id();var yard_id: int=w.yard403.get_instance_id()
 w.hero.set_physics_process(false);w.companion373.hold373();await capture("yard-day")
 # Walk through the real doorway rather than only teleporting/toggling views.
 w.hero.global_position=Vector3(0,.05,4.1);w.hero.reset_physics_interpolation()
 for i in 66:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 await settle(w)
 check(w.hero.position.z<2.1 and w.inside403,"walk physically through threshold into room")
 check(not w.yard403.facade403.visible,"exterior facade cuts away inside")
 await capture("room-day")
 w.hero.global_position=Vector3(0,.05,1.8);w.hero.reset_physics_interpolation()
 for i in 50:w.hero.velocity=Vector3(0,0,2.5);w.hero.move_and_slide();await physics_frame
 await settle(w)
 check(not w.inside403 and w.hero.position.z>3.3,"walk physically out through threshold")
 w.enter403();await settle(w)
 var switches: Array=[]
 for i in 4:
  var before:=Time.get_ticks_msec();key403(w,KEY_F3);await settle(w);switches.append(Time.get_ticks_msec()-before)
  check(not w.inside403 and current_scene.get_instance_id()==scene_id,"F3 exits into retained local yard")
  check(w.hero.get_instance_id()==hero_id and r.get_instance_id()==room_id and w.yard403.get_instance_id()==yard_id,"same hero room and yard survive exit")
  w.hero.global_position=Vector3(0,.05,3.65);w.interact355();await settle(w)
  check(w.inside403,"E reenters retained room")
 # Sleeping and daylight are persistent in the shared home, no progress/save writes.
 var bed: Dictionary=r.item356("bed");w.hero.global_position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355()
 check(w.sleeping362,"bed still sleeps")
 w.leave371();await settle(w);check(not w.sleeping362 and not w.inside403,"exit wakes sleeping hero safely")
 w.set_night355(true);await capture("yard-night");w.enter403();await settle(w);await capture("room-night")
 check(w.night355,"time of day survives crossings")
 w.set_night355(false)
 # Follow offsets must not snap back to the old home position at the start of a tween.
 w.camera.position.x+=.6;var camera_before: Vector3=w.camera.position
 w.hero.global_position=Vector3(0,.05,3.65);w.switch_zone403(false)
 check(w.camera.position.distance_to(camera_before)<.001,"crossing starts from current follow camera without snapping")
 await settle(w)
 key403(w,KEY_F12);check(not w.follow363,"F12 can disable follow")
 w.enter403();await settle(w);check(not w.follow363,"fixed-camera preference survives entry")
 key403(w,KEY_F12)
 # Physical front-side wall and yard boundaries remain solid.
 w.hero.global_position=Vector3(3.,.05,3.7);w.hero.reset_physics_interpolation()
 for i in 35:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.position.z>2.9,"facade sides block actual movement")
 w.hero.global_position=Vector3(7.1,.05,10.);w.hero.reset_physics_interpolation()
 for i in 35:w.hero.velocity=Vector3(2.5,0,0);w.hero.move_and_slide();await physics_frame
 check(w.hero.position.x<7.65,"yard fence has real collision")
 w.hero.global_position=Vector3(7.,.05,3.4);w.hero.reset_physics_interpolation()
 for i in 35:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.position.z>2.8,"closed house-side edge prevents leaving loaded yard")
 # Verify companion can route through the opening across the same physical world.
 w.hero.global_position=Vector3(0,.05,6.);w.companion373.global_position=Vector3(0,.05,1.2);w.companion373.reset_physics_interpolation();w.companion373.resume373()
 var until:=Time.get_ticks_msec()+6500
 while w.companion373.position.z<4.2 and Time.get_ticks_msec()<until:await physics_frame
 check(w.companion373.position.z>4.2,"companion follows through doorway into yard")
 var node_count: int=w.transitions403[0].node_count
 var retained:=true
 for row in w.transitions403:retained=retained and row.node_count==node_count
 check(retained,"repeated crossings do not accumulate scene nodes")
 frame_ms403.sort()
 var out:={"startup":session.report403,"transition_with_settle_ms":switches,"crossing_frame_median_ms":frame_ms403[frame_ms403.size()/2],"crossing_frame_p95_ms":frame_ms403[int(frame_ms403.size()*.95)],"crossing_frame_max_ms":frame_ms403[-1],"crossings":w.transitions403,"failures":failures}
 FileAccess.open("res://docs/home403-validation.json",FileAccess.WRITE).store_string(JSON.stringify(out,"\t"))
 print("HOME403_DONE ",failures)
 quit(0 if failures.is_empty() else 1)
