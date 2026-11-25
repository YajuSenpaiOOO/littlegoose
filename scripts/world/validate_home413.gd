extends SceneTree
var failures: Array=[]
func check(ok: bool,label: String) -> void:
 print("PASS " if ok else "FAIL ",label)
 if not ok:failures.append(label)
func _initialize() -> void:call_deferred("run")
func settle(w: Node) -> void:
 while w.moving_camera403 or w.pending_door404 or w.yard403.door_moving404:await process_frame
 for i in 10:await physics_frame
func capture(tag: String) -> void:
 for i in 5:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/home413-"+tag+".png")
func run() -> void:
 var session=load("res://scenes/world/world413.tscn").instantiate();root.add_child(session);current_scene=session
 var start:=Time.get_ticks_msec()
 while not session.ready403:
  if Time.get_ticks_msec()-start>150000:print("HOME413_TIMEOUT");quit(2);return
  await process_frame
 var w=session.host403
 check(w.ready411 and w.hero.get_world_3d()==w.map410.get_world_3d(),"map room and hero share one physical world")
 check(w.yard403.scale.is_equal_approx(Vector3(.92,.98,.92)),"exterior covers compact interior")
 var shot: Transform3D=w.camera_target403(false)
 check(absf(rad_to_deg(shot.basis.get_euler().x)+25.)<.01 and shot.origin.distance_to(Vector3(0,1.1,2.0))<16.501,"restores close 25 degree 16.5m outdoor shot" )
 check(absf(w.yard403.rotation.y)<.0001 and w.yard403.tiles413==198,"C shell faces front and uses chunky native slate tiles" )
 check(w.yard403.inside_roof413!=null,"matching pitched interior built" )
 var id: int=w.hero.get_instance_id()
 for i in 30:await physics_frame
 check(w.hero.position.y>-.3 and w.hero.position.y<.5,"hero remains supported on paused map terrain")
 w.hero.set_physics_process(false);w.companion373.hold373();w.auto_door404=false
 w.yard403.set_open404(false);await settle(w)
 await capture("outside")
 w.set_night355(true);await capture("outside-night");w.set_night355(false)
 var shot_before: Transform3D=w.camera.global_transform
 var follow_before: bool=w.follow_preferred403
 w.set_follow363(false);w.camera.position=Vector3(0,3.4,0)+w.camera.basis.z*23.
 await capture("whole-shell")
 w.camera.global_transform=shot_before;w.camera.reset_physics_interpolation();w.set_follow363(follow_before)
 w.hero.position=Vector3(0,.05,3.6)
 for i in 45:w.hero.velocity=Vector3(0,0,-2.5);w.hero.move_and_slide();await physics_frame
 check(w.hero.position.z>2.4 and not w.inside403,"closed scaled door physically blocks walking")
 w.yard403.set_open404(true);await settle(w)
 check(absf(w.yard403.door404.rotation_degrees.y-104.)<.1,"real hinged door opens with collider")
 await capture("door-open")
 for i in 48:w.hero.velocity=Vector3(0,-.3,-2.5);w.hero.move_and_slide();await physics_frame
 print("HOME413_WALK_AT ",w.hero.position)
 for i in w.hero.get_slide_collision_count():print("HOME413_WALK_HIT ",w.hero.get_slide_collision(i).get_collider().get_path())
 await settle(w)
 check(w.hero.position.z<2.15 and w.inside403,"actual walking crosses into compact room without teleport")
 check(w.room.visible and w.map410.visible and not w.yard403.facade403.visible,"room and exterior cutaway switch together")
 await capture("inside")
 check(w.yard403.inside_roof413.visible and not w.room.roof402.visible and not w.room.frame399.visible,"new pitched interior replaces old curved cutaway")
 w.set_night355(true);await capture("inside-night");w.set_night355(false)
 for i in 65:w.hero.velocity=Vector3(0,0,2.5);w.hero.move_and_slide();await physics_frame
 await settle(w)
 check(not w.inside403 and w.hero.position.z>2.95,"walking out restores exterior")
 for i in 3:
  w.enter403();await process_frame;check(w.room.visible and w.map410.visible,"both spaces remain visible at entry start" );await capture("entry-mid" );await settle(w);check(w.inside403,"F3 style entry")
  w.leave371();await process_frame;check(w.yard403.facade403.visible,"exterior restores at exit start" );await capture("exit-mid" );await settle(w);check(not w.inside403 and w.hero.get_instance_id()==id,"same actor survives return")
 w.enter403();await settle(w)
 var bed: Dictionary=w.room.item356("bed");w.hero.position=Vector3(bed.approach.x,.05,bed.approach.y);w.interact355()
 check(w.sleeping362,"compact bed still sleeps")
 w.leave371();await settle(w);check(not w.sleeping362,"exit wakes hero")
 w.hero.position=Vector3(0,.05,5.8);w.companion373.position=Vector3(.7,.05,5.8)
 w.auto_door404=true;w.refresh367();w.hero.set_physics_process(true);w.companion373.resume373()
 for i in 35:await physics_frame
 check(w.hero.position.y>-.3,"returning hero remains above outdoor terrain")
 await capture("return")
 var all_visible:=true
 for frame in w.sample411:all_visible=all_visible and frame.room and frame.map and frame.shell==not frame.inside
 check(all_visible and w.sample411.size()>100,"every sampled transition frame keeps room and map with correct shell" )
 print("HOME413_DONE ",failures)
 if not failures.is_empty() or not "--play-after" in OS.get_cmdline_user_args():quit(0 if failures.is_empty() else 1)
